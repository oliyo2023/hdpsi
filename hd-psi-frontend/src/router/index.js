import { createRouter, createWebHistory } from 'vue-router'

// 导入视图组件
import Dashboard from '../views/Dashboard.vue'
import Login from '../views/Login.vue'
import ProductList from '../views/ProductList.vue'
import InventoryList from '../views/InventoryList.vue'
import MemberList from '../views/MemberList.vue'
import MemberCreate from '../views/MemberCreate.vue'
import PurchaseList from '../views/PurchaseList.vue'
import PurchaseDetail from '../views/PurchaseDetail.vue'
import PurchaseCreate from '../views/PurchaseCreate.vue'
import SupplierList from '../views/SupplierList.vue'
import SupplierDetail from '../views/SupplierDetail.vue'
import SupplierCreate from '../views/SupplierCreate.vue'
import Profile from '../views/Profile.vue'
import NotFound from '../views/NotFound.vue'

// 路由配置
const routes = [
  {
    path: '/',
    redirect: '/dashboard'
  },
  {
    path: '/login',
    name: 'Login',
    component: Login,
    meta: { requiresAuth: false }
  },
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: Dashboard,
    meta: { requiresAuth: true }
  },
  {
    path: '/products',
    name: 'ProductList',
    component: ProductList,
    meta: { requiresAuth: true }
  },
  {
    path: '/inventory',
    name: 'InventoryList',
    component: InventoryList,
    meta: { requiresAuth: true }
  },
  {
    path: '/members',
    name: 'MemberList',
    component: MemberList,
    meta: { requiresAuth: true }
  },
  {
    path: '/members/create',
    name: 'MemberCreate',
    component: MemberCreate,
    meta: { requiresAuth: true }
  },
  {
    path: '/purchases',
    name: 'PurchaseList',
    component: PurchaseList,
    meta: { requiresAuth: true }
  },
  {
    path: '/purchases/create',
    name: 'PurchaseCreate',
    component: PurchaseCreate,
    meta: { requiresAuth: true }
  },
  {
    path: '/purchases/:id',
    name: 'PurchaseDetail',
    component: PurchaseDetail,
    meta: { requiresAuth: true }
  },
  {
    path: '/suppliers',
    name: 'SupplierList',
    component: SupplierList,
    meta: { requiresAuth: true }
  },
  {
    path: '/suppliers/create',
    name: 'SupplierCreate',
    component: SupplierCreate,
    meta: { requiresAuth: true }
  },
  {
    path: '/suppliers/:id',
    name: 'SupplierDetail',
    component: SupplierDetail,
    meta: { requiresAuth: true }
  },
  {
    path: '/profile',
    name: 'Profile',
    component: Profile,
    meta: { requiresAuth: true }
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'NotFound',
    component: NotFound
  }
]

// 创建路由实例
const router = createRouter({
  history: createWebHistory(),
  routes
})

// 路由守卫
router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token')
  const requiresAuth = to.matched.some(record => record.meta.requiresAuth)

  // 如果需要认证且没有token，重定向到登录页
  if (requiresAuth && !token) {
    next({ path: '/login', query: { redirect: to.fullPath } })
  }
  // 如果已登录且访问登录页，重定向到首页
  else if (to.path === '/login' && token) {
    next({ path: '/dashboard' })
  }
  // 其他情况正常导航
  else {
    next()
  }
})

export default router
