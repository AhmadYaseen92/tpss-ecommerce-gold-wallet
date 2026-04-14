import { createRouter, createWebHashHistory } from "vue-router";
import DashboardFeaturePage from "../features/dashboard/pages/DashboardFeaturePage.vue";
import ProductFeaturePage from "../features/products/pages/ProductFeaturePage.vue";
import InvestorsFeaturePage from "../features/investors/pages/InvestorsFeaturePage.vue";
import TransactionsFeaturePage from "../features/transactions/pages/TransactionsFeaturePage.vue";
import ReportsFeaturePage from "../features/reports/pages/ReportsFeaturePage.vue";
import FeesFeaturePage from "../features/fees/pages/FeesFeaturePage.vue";

export const routes = [
  { path: "/", redirect: "/overview" },
  { path: "/overview", name: "overview", component: DashboardFeaturePage },
  { path: "/products", name: "products", component: ProductFeaturePage },
  { path: "/products/:id", name: "product-details", component: ProductFeaturePage },
  { path: "/products/:id/edit", name: "product-edit", component: ProductFeaturePage },
  { path: "/products/new", name: "product-new", component: ProductFeaturePage },
  { path: "/investors", name: "investors", component: InvestorsFeaturePage },
  { path: "/transactions", name: "requests", component: TransactionsFeaturePage },
  { path: "/reports", name: "reports", component: ReportsFeaturePage },
  { path: "/fees", name: "fees", component: FeesFeaturePage }
];

export const router = createRouter({
  history: createWebHashHistory(),
  routes
});
