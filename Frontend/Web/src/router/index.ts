import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router';

const routes: Array<RouteRecordRaw> = [
	{
		path: '/Register',
		name: 'Register',
		component: () => import('../features/auth/pages/RegisterPage.vue'),
	},
	// Add other routes as needed
];

const router = createRouter({
	history: createWebHistory(),
	routes,
});

export default router;
