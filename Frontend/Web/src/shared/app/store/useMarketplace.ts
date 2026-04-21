import { computed, ref, watch } from "vue";
import { MarketplaceRealtime } from "../../services/marketplaceRealtime";
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
  fetchMarketplaceState,
  fetchWalletSellConfiguration,
  loginWithBackend,
  registerSellerWithBackend,
  updateSellerKycStatusByAdmin,
  updateWalletSellConfiguration,
  updateWebRequestStatus
} from "../../services/backendGateway";
import { mockMarketplaceState } from "../../services/mockMarketplaceRepository";

const SESSION_STORAGE_KEY = "goldwallet.web.session";

function persistSession(session: UserSession | null) {
  if (typeof window === "undefined") return;
  try {
    if (!session?.accessToken) {
      window.localStorage.removeItem(SESSION_STORAGE_KEY);
      window.sessionStorage.removeItem(SESSION_STORAGE_KEY);
      return;
    }
    const serialized = JSON.stringify(session);
    window.localStorage.setItem(SESSION_STORAGE_KEY, serialized);
    window.sessionStorage.setItem(SESSION_STORAGE_KEY, serialized);
  } catch {
    // Ignore storage availability errors.
  }
}

function readStoredSession(): UserSession | null {
  if (typeof window === "undefined") return null;
  try {
    const raw = window.localStorage.getItem(SESSION_STORAGE_KEY) ?? window.sessionStorage.getItem(SESSION_STORAGE_KEY);
    if (!raw) return null;
    const parsed = JSON.parse(raw) as UserSession;
    if (!parsed?.accessToken) return null;
    if (parsed.expiresAtUtc && new Date(parsed.expiresAtUtc).getTime() <= Date.now()) {
      persistSession(null);
      return null;
    }
    return parsed;
  } catch {
    return null;
  }
}

let marketplaceStore: any = null;

export function useMarketplace() {
  if (marketplaceStore) return marketplaceStore;
  const persistedSession = readStoredSession();
  const role = ref<UserRole>(persistedSession?.role ?? "Admin");
  const activeMenu = ref<NavigationKey>("overview");
  const session = ref<UserSession | null>(persistedSession);
  const state = ref<MarketplaceState>(structuredClone(mockMarketplaceState));
  const loading = ref(false);
  const error = ref("");
  const realtimeRefreshTick = ref(0);
  const walletSellConfiguration = ref<{ mode: "locked_30_seconds" | "live_price"; lockSeconds: number }>({
    mode: "locked_30_seconds",
    lockSeconds: 30
  });

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


  const realtime = new MarketplaceRealtime();
  const signalRConnected = ref(false);
  let fallbackPollingTimer: ReturnType<typeof setInterval> | null = null;

  const stopFallbackPolling = () => {
    if (!fallbackPollingTimer) return;
    clearInterval(fallbackPollingTimer);
    fallbackPollingTimer = null;
  };

  const startFallbackPolling = () => {
    if (fallbackPollingTimer || signalRConnected.value || !session.value?.accessToken) return;
    fallbackPollingTimer = setInterval(() => {
      void refreshMarketplaceState();
    }, 5000);
  };

  const configureRealtime = async () => {
    if (!session.value?.accessToken) {
      signalRConnected.value = false;
      stopFallbackPolling();
      await realtime.stop();
      return;
    }

    await realtime.start({
      accessTokenFactory: () => session.value?.accessToken ?? "",
      onRefreshRequested: () => {
        realtimeRefreshTick.value += 1;
        void refreshMarketplaceState();
      },
      onConnectionStateChanged: (connected) => {
        signalRConnected.value = connected;
        if (connected) {
          stopFallbackPolling();
          return;
        }
        startFallbackPolling();
      }
    });

    if (!signalRConnected.value) {
      startFallbackPolling();
    }
  };

  const login = async (credentials: AuthCredentials) => {
    loading.value = true;
    error.value = "";
    try {
      const authSession = await loginWithBackend(credentials);
      session.value = authSession;
      role.value = authSession.role;
      persistSession(authSession);
      state.value = await fetchMarketplaceState(authSession);
      await loadWalletSellConfiguration();
      await configureRealtime();
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
      role.value = "Admin";
    } catch (err) {
      error.value = err instanceof Error ? err.message : "Registration failed";
    } finally {
      loading.value = false;
    }
  };

  const approveKyc = async (sellerId: string) => {
    state.value.sellers = updateSellerKycStatus(state.value.sellers, sellerId, "approved");
    if (session.value?.accessToken) {
      await updateSellerKycStatusByAdmin(session.value.accessToken, sellerId, "approved");
    }
  };

  const rejectKyc = async (sellerId: string) => {
    state.value.sellers = updateSellerKycStatus(state.value.sellers, sellerId, "rejected");
    if (session.value?.accessToken) {
      await updateSellerKycStatusByAdmin(session.value.accessToken, sellerId, "rejected");
    }
  };

  const blockKyc = async (sellerId: string) => {
    state.value.sellers = updateSellerKycStatus(state.value.sellers, sellerId, "blocked");
    if (session.value?.accessToken) {
      await updateSellerKycStatusByAdmin(session.value.accessToken, sellerId, "blocked");
    }
  };

  const markKycUnderReview = async (sellerId: string) => {
    state.value.sellers = updateSellerKycStatus(state.value.sellers, sellerId, "underreview");
    if (session.value?.accessToken) {
      await updateSellerKycStatusByAdmin(session.value.accessToken, sellerId, "underreview");
    }
  };

  const setMarketPrice = (productId: string, marketPrice: number) => {
    state.value.products = updateProductMarketPrice(state.value.products, productId, marketPrice);
  };

  const addProduct = (productDraft: Omit<Product, "id" | "updatedAt">) => {
    state.value.products = addSellerProduct(state.value.products, productDraft);
  };

  const updateProduct = (productId: string, payload: Partial<Product>) => {
    state.value.products = updateSellerProduct(state.value.products, productId, payload);
  };

  const deleteProduct = (productId: string) => {
    state.value.products = deleteSellerProduct(state.value.products, productId);
  };

  const saveInvoice = (invoice: Invoice) => {
    state.value.invoices = upsertInvoice(state.value.invoices, invoice);
  };

  const removeInvoice = (invoiceId: string) => {
    state.value.invoices = deleteInvoice(state.value.invoices, invoiceId);
  };

  const updateFees = (deliveryFee: number, storageFee: number, serviceChargePercent: number) => {
    state.value.fees = updateFeeConfiguration(state.value.fees, {
      deliveryFee,
      storageFee,
      serviceChargePercent
    });
  };

  const updateInvestorStatus = (investorId: string, status: "active" | "review" | "blocked") => {
    state.value.investors = setInvestorStatus(state.value.investors, investorId, status);
  };

  const updateRequestStatus = async (requestId: string, status: "pending" | "approved" | "rejected" | "delivered" | "cancelled") => {
    state.value.requests = setRequestStatus(state.value.requests, requestId, status);
    if (session.value?.accessToken) {
      await updateWebRequestStatus(session.value.accessToken, requestId, status);
      state.value = await fetchMarketplaceState(session.value);
      realtimeRefreshTick.value += 1;
    }
  };

  const readNotification = (notificationId: string) => {
    state.value.notifications = markNotificationAsRead(state.value.notifications, notificationId);
  };

  const logout = () => {
    void realtime.stop();
    signalRConnected.value = false;
    stopFallbackPolling();
    session.value = null;
    role.value = "Admin";
    activeMenu.value = "overview";
    if (typeof window !== "undefined") {
      persistSession(null);
    }
  };

  const refreshMarketplaceState = async () => {
    if (!session.value?.accessToken) return;
    try {
      state.value = await fetchMarketplaceState(session.value);
      realtimeRefreshTick.value += 1;
    } catch {
      // Keep current UI state and session on intermittent refresh failures.
    }
  };

  const saveWalletSellConfiguration = async (mode: "locked_30_seconds" | "live_price", lockSeconds = 30) => {
    walletSellConfiguration.value = { mode, lockSeconds };
    if (!session.value?.accessToken) return;
    await updateWalletSellConfiguration(session.value.accessToken, walletSellConfiguration.value);
  };

  const loadWalletSellConfiguration = async () => {
    if (!session.value?.accessToken) return;
    try {
      walletSellConfiguration.value = await fetchWalletSellConfiguration(session.value.accessToken);
    } catch {
      walletSellConfiguration.value = { mode: "locked_30_seconds", lockSeconds: 30 };
    }
  };

  const restoreSession = async () => {
    if (!session.value?.accessToken) return;
    role.value = session.value.role;
    persistSession(session.value);
    await refreshMarketplaceState();
    await loadWalletSellConfiguration();
    await configureRealtime();
  };

  watch(session, (value) => persistSession(value), { deep: true });

  marketplaceStore = {
    role,
    activeMenu,
    session,
    state,
    loading,
    error,
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
    blockKyc,
    markKycUnderReview,
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
    signalRConnected,
    realtimeRefreshTick,
    walletSellConfiguration,
    saveWalletSellConfiguration
  };

  return marketplaceStore;
}


export type ReturnTypeUseMarketplace = ReturnType<typeof useMarketplace>;
