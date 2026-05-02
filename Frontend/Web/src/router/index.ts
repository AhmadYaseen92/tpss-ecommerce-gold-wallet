import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router';

const routes: Array<RouteRecordRaw> = [
  { path: '/', redirect: '/Login' },
  { path: '/Login', name: 'Login', component: () => import('../features/auth/pages/LoginPage.vue') },
  { path: '/Register', name: 'Register', component: () => import('../features/auth/pages/RegisterPage.vue') },
  { path: '/overview', name: 'overview', component: () => import('../features/auth/pages/LoginPage.vue') },
  { path: '/products', component: () => import('../features/auth/pages/LoginPage.vue') },
  { path: '/investors', component: () => import('../features/auth/pages/LoginPage.vue') },
  { path: '/sellers', component: () => import('../features/auth/pages/LoginPage.vue') },
  { path: '/settings', component: () => import('../features/auth/pages/LoginPage.vue') },
  { path: '/transactions', component: () => import('../features/auth/pages/LoginPage.vue') },
  { path: '/reports', component: () => import('../features/auth/pages/LoginPage.vue') },
  { path: '/market', component: () => import('../features/auth/pages/LoginPage.vue') },
  { path: '/forgot-password', name: 'ForgotPassword', component: () => import('../features/auth/pages/ForgotPasswordPage.vue') },
  { path: '/reset-password', name: 'ResetPassword', component: () => import('../features/auth/pages/ResetPasswordPage.vue') },
  { path: '/change-password', name: 'ChangePassword', component: () => import('../features/auth/pages/ChangePasswordPage.vue') },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
