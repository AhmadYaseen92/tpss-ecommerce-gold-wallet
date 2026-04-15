import { computed, ref } from "vue";
import {
  addSellerProduct,
  buildFallbackAdminMetrics,
  deleteInvoice,
  deleteSellerProduct,
  markNotificationAsRead,
  selectSellerProducts,
  setInvestorStatus,
  setRequestStatus,
  updateFeeConfiguration,
  updateProductMarketPrice,
  updateSellerKycStatus,
  updateSellerProduct,
  upsertInvoice,
  upsertSeller
} from "../../../features/dashboard/services/marketplaceService";
import type {
  AuthCredentials,
  Invoice,
  MarketplaceState,
  NavigationKey,
  Product,
  SellerRegistration,
  UserRole,
  UserSession
} from "../../types/models";
import {
  fetchMarketplaceProducts,
  fetchMarketplaceRequests,
  fetchMarketplaceSellers,
  fetchMarketplaceState,
  loginWithBackend,
  registerSellerWithBackend,
  updateSellerKycStatusByAdmin,
  updateWebRequestStatus
} from "../../services/backendGateway";
import { mockMarketplaceState } from "../../services/mockMarketplaceRepository";
import { createMarketplaceRealtimeClient, type MarketplaceRealtimeClient, type MarketplaceRealtimeEvent } from "../../realtime/marketplaceRealtimeClient";

const SESSION_STORAGE_KEY = "goldwallet.web.session";
const ENABLE_REALTIME_FALLBACK_POLLING = false; // Temporary: disabled to validate pure SignalR behavior.

function readStoredSession(): UserSession | null {
  if (typeof window === "undefined") return null;
  try {
    const raw = window.localStorage.getItem(SESSION_STORAGE_KEY);
    if (!raw) return null;
    const parsed = JSON.parse(raw) as UserSession;
    return parsed?.accessToken ? parsed : null;
  } catch {
    return null;
  }
}

export function useMarketplace() {
  const persistedSession = readStoredSession();
  const role = ref<UserRole>(persistedSession?.role ?? "admin");
  const activeMenu = ref<NavigationKey>("overview");
  const session = ref<UserSession | null>(persistedSession);
  const state = ref<MarketplaceState>(structuredClone(mockMarketplaceState));
  const loading = ref(false);
  const error = ref("");
  const realtimeConnected = ref(false);
  const stateVersion = ref(0);
  let realtimeClient: MarketplaceRealtimeClient | null = null;
  let fallbackRefreshTimer: ReturnType<typeof setInterval> | null = null;
  const bumpStateVersion = () => {
    stateVersion.value += 1;
  };

  const activeSeller = computed(() => {
    if (!session.value?.sellerId) return state.value.sellers[0];
    return state.value.sellers.find((seller) => seller.id === `s-${session.value?.sellerId}`) ?? state.value.sellers[0];
  });

  const sellerProducts = computed(() =>
    activeSeller.value ? selectSellerProducts(state.value, activeSeller.value.id) : []
  );

  const adminMetrics = computed(() =>
    state.value.reports.length > 0 ? state.value.reports : buildFallbackAdminMetrics(state.value)
  );

  const overviewCards = computed(() => [
    ...adminMetrics.value,
    { title: "Invoices", value: `${state.value.invoices.length}`, trend: "Seller billing" },
    { title: "Fees", value: `${state.value.fees.serviceChargePercent}%`, trend: "Service charge" }
  ]);

  const login = async (credentials: AuthCredentials) => {
    loading.value = true;
    error.value = "";
    try {
      const authSession = await loginWithBackend(credentials);
      session.value = authSession;
      role.value = authSession.role;
      state.value = await fetchMarketplaceState(authSession);
      bumpStateVersion();
      await ensureRealtimeSync();
      if (typeof window !== "undefined") {
        window.localStorage.setItem(SESSION_STORAGE_KEY, JSON.stringify(authSession));
      }
    } catch (err) {
      if (err instanceof TypeError) {
        error.value = "Cannot reach API server. Check VITE_API_BASE_URL and backend CORS/run status.";
      } else {
        error.value = err instanceof Error ? err.message : "Login failed";
      }
    } finally {
      loading.value = false;
    }
  };

  const registerSeller = async (payload: SellerRegistration) => {
    loading.value = true;
    error.value = "";
    try {
      const seller = await registerSellerWithBackend(payload);
      state.value.sellers = upsertSeller(state.value.sellers, seller);
      activeMenu.value = "investors";
      role.value = "admin";
    } catch (err) {
      error.value = err instanceof Error ? err.message : "Registration failed";
    } finally {
      loading.value = false;
    }
  };

  const approveKyc = async (sellerId: string) => {
    state.value.sellers = updateSellerKycStatus(state.value.sellers, sellerId, "approved");
    bumpStateVersion();
    if (session.value?.accessToken) {
      await updateSellerKycStatusByAdmin(session.value.accessToken, sellerId, "approved");
    }
  };

  const rejectKyc = async (sellerId: string) => {
    state.value.sellers = updateSellerKycStatus(state.value.sellers, sellerId, "rejected");
    bumpStateVersion();
    if (session.value?.accessToken) {
      await updateSellerKycStatusByAdmin(session.value.accessToken, sellerId, "rejected");
    }
  };

  const setMarketPrice = (productId: string, marketPrice: number) => {
    state.value.products = updateProductMarketPrice(state.value.products, productId, marketPrice);
    bumpStateVersion();
  };

  const addProduct = (productDraft: Omit<Product, "id" | "updatedAt">) => {
    state.value.products = addSellerProduct(state.value.products, productDraft);
    bumpStateVersion();
  };

  const updateProduct = (productId: string, payload: Partial<Product>) => {
    state.value.products = updateSellerProduct(state.value.products, productId, payload);
    bumpStateVersion();
  };

  const deleteProduct = (productId: string) => {
    state.value.products = deleteSellerProduct(state.value.products, productId);
    bumpStateVersion();
  };

  const saveInvoice = (invoice: Invoice) => {
    state.value.invoices = upsertInvoice(state.value.invoices, invoice);
    bumpStateVersion();
  };

  const removeInvoice = (invoiceId: string) => {
    state.value.invoices = deleteInvoice(state.value.invoices, invoiceId);
    bumpStateVersion();
  };

  const updateFees = (deliveryFee: number, storageFee: number, serviceChargePercent: number) => {
    state.value.fees = updateFeeConfiguration(state.value.fees, {
      deliveryFee,
      storageFee,
      serviceChargePercent
    });
    bumpStateVersion();
  };

  const updateInvestorStatus = (investorId: string, status: "active" | "review" | "blocked") => {
    state.value.investors = setInvestorStatus(state.value.investors, investorId, status);
    bumpStateVersion();
  };

  const updateRequestStatus = async (requestId: string, status: "pending" | "approved" | "rejected") => {
    state.value.requests = setRequestStatus(state.value.requests, requestId, status);
    bumpStateVersion();
    if (session.value?.accessToken) {
      await updateWebRequestStatus(session.value.accessToken, requestId, status);
      state.value = await fetchMarketplaceState(session.value);
      bumpStateVersion();
    }
  };

  const readNotification = (notificationId: string) => {
    state.value.notifications = markNotificationAsRead(state.value.notifications, notificationId);
    bumpStateVersion();
  };

  const logout = () => {
    void stopRealtimeSync();
    session.value = null;
    role.value = "admin";
    activeMenu.value = "overview";
    if (typeof window !== "undefined") {
      window.localStorage.removeItem(SESSION_STORAGE_KEY);
    }
  };

  const refreshMarketplaceState = async () => {
    if (!session.value?.accessToken) return;
    try {
      state.value = await fetchMarketplaceState(session.value);
      bumpStateVersion();
    } catch {
      // Keep current UI state and session on intermittent refresh failures.
    }
  };

  const refreshProductsOnly = async () => {
    if (!session.value?.accessToken) return;
    try {
      state.value.products = await fetchMarketplaceProducts(session.value.accessToken);
      bumpStateVersion();
    } catch {
      // Keep current rendered products on transient errors.
    }
  };

  const refreshRequestsOnly = async () => {
    if (!session.value?.accessToken) return;
    try {
      state.value.requests = await fetchMarketplaceRequests(session.value.accessToken);
      bumpStateVersion();
    } catch {
      // Keep current rendered requests on transient errors.
    }
  };

  const refreshSellersOnly = async () => {
    if (!session.value?.accessToken) return;
    try {
      state.value.sellers = await fetchMarketplaceSellers(session.value.accessToken);
      bumpStateVersion();
    } catch {
      // Keep current rendered sellers on transient errors.
    }
  };

  const stopFallbackPolling = () => {
    if (!fallbackRefreshTimer) return;
    clearInterval(fallbackRefreshTimer);
    fallbackRefreshTimer = null;
  };

  const ensureFallbackPolling = () => {
    if (!ENABLE_REALTIME_FALLBACK_POLLING) return;
    if (fallbackRefreshTimer) return;
    fallbackRefreshTimer = setInterval(() => {
      void refreshMarketplaceState();
    }, 30000);
  };

  const onRealtimeAvailabilityChange = (isAvailable: boolean) => {
    realtimeConnected.value = isAvailable;
    if (isAvailable) {
      stopFallbackPolling();
      return;
    }

    ensureFallbackPolling();
  };

  const handleRealtimeEvent = async (event: MarketplaceRealtimeEvent) => {
    const entity = event.entity.trim().toLowerCase();
    switch (entity) {
      case "product":
      case "products":
        await refreshProductsOnly();
        break;
      case "request":
      case "order":
      case "requests":
        await refreshRequestsOnly();
        break;
      case "seller":
      case "sellers":
        await refreshSellersOnly();
        break;
      case "wallet":
      case "invoice":
      case "dashboard":
      case "investor":
      case "notification":
      default:
        await refreshMarketplaceState();
        break;
    }
  };

  const stopRealtimeSync = async () => {
    stopFallbackPolling();
    realtimeConnected.value = false;
    if (!realtimeClient) return;
    await realtimeClient.stop();
    realtimeClient = null;
  };

  const ensureRealtimeSync = async () => {
    if (!session.value?.accessToken) {
      await stopRealtimeSync();
      return;
    }

    if (realtimeClient) return;

    realtimeClient = createMarketplaceRealtimeClient({
      accessToken: session.value.accessToken,
      onEvent: (event) => {
        void handleRealtimeEvent(event);
      },
      onAvailabilityChange: onRealtimeAvailabilityChange
    });

    await realtimeClient.start();
  };

  const restoreSession = async () => {
    if (!session.value?.accessToken) return;
    role.value = session.value.role;
    await refreshMarketplaceState();
    await ensureRealtimeSync();
  };

  return {
    role,
    activeMenu,
    session,
    state,
    loading,
    error,
    realtimeConnected,
    stateVersion,
    adminMetrics,
    overviewCards,
    activeSeller,
    sellerProducts,
    login,
    logout,
    restoreSession,
    registerSeller,
    approveKyc,
    rejectKyc,
    setMarketPrice,
    addProduct,
    updateProduct,
    deleteProduct,
    saveInvoice,
    removeInvoice,
    updateFees,
    updateInvestorStatus,
    updateRequestStatus,
    readNotification,
    refreshMarketplaceState,
    refreshProductsOnly,
    refreshRequestsOnly,
    ensureRealtimeSync,
    stopRealtimeSync
  };
}


export type ReturnTypeUseMarketplace = ReturnType<typeof useMarketplace>;
