import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router';

const routes: Array<RouteRecordRaw> = [
  {
    path: '/',
    redirect: '/Login',
  },
  {
    path: '/Login',
    name: 'Login',
    component: () => import('../features/auth/pages/LoginPage.vue'),
  },
  {
    path: '/Register',
    name: 'Register',
    component: () => import('../features/auth/pages/RegisterPage.vue'),
  },
  {
    path: '/OverView',
    name: 'OverView',
    component: () => import('../features/auth/pages/LoginPage.vue'),
  },
  {
    path: '/overview',
    redirect: '/OverView',
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
