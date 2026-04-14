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
} from "../services/marketplaceService";
import type {
  AuthCredentials,
  Invoice,
  MarketplaceState,
  NavigationKey,
  Product,
  SellerRegistration,
  UserRole,
  UserSession
} from "../../../shared/types/models";
import { fetchMarketplaceState, loginWithBackend, registerSellerWithBackend } from "../../../shared/services/backendGateway";
import { mockMarketplaceState } from "../../../shared/services/mockMarketplaceRepository";

export function useMarketplace() {
  const role = ref<UserRole>("admin");
  const activeMenu = ref<NavigationKey>("overview");
  const session = ref<UserSession | null>(null);
  const state = ref<MarketplaceState>(structuredClone(mockMarketplaceState));
  const loading = ref(false);
  const error = ref("");

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

  const approveKyc = (sellerId: string) => {
    state.value.sellers = updateSellerKycStatus(state.value.sellers, sellerId, "approved");
  };

  const rejectKyc = (sellerId: string) => {
    state.value.sellers = updateSellerKycStatus(state.value.sellers, sellerId, "rejected");
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

  const updateRequestStatus = (requestId: string, status: "approved" | "rejected") => {
    state.value.requests = setRequestStatus(state.value.requests, requestId, status);
  };

  const readNotification = (notificationId: string) => {
    state.value.notifications = markNotificationAsRead(state.value.notifications, notificationId);
  };

  const logout = () => {
    session.value = null;
    role.value = "admin";
    activeMenu.value = "overview";
  };

  return {
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
    readNotification
  };
}


export type ReturnTypeUseMarketplace = ReturnType<typeof useMarketplace>;
