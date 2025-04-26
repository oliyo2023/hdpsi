import { createRouter, createWebHistory } from 'vue-router'

// 导入视图组件
import Dashboard from '../views/Dashboard.vue'
import Login from '../views/Login.vue'
import ProductList from '../views/ProductList.vue'
import ProductCreate from '../views/ProductCreate.vue'
import ProductEdit from '../views/ProductEdit.vue'
import ProductFormNew from '../views/ProductFormNew.vue'
import ProductDeletedList from '../views/ProductDeletedList.vue'
import InventoryList from '../views/InventoryList.vue'
import MemberList from '../views/MemberList.vue'
import MemberCreate from '../views/MemberCreate.vue'
import MemberEdit from '../views/MemberEdit.vue'
import MemberPoints from '../views/MemberPoints.vue'
import PurchaseList from '../views/PurchaseList.vue'
import PurchaseDetail from '../views/PurchaseDetail.vue'
import PurchaseCreate from '../views/PurchaseCreate.vue'
import SupplierList from '../views/SupplierList.vue'
import SupplierDetail from '../views/SupplierDetail.vue'
import SupplierCreate from '../views/SupplierCreate.vue'
import DictionaryList from '../views/DictionaryList.vue'
import DictionaryItemList from '../views/DictionaryItemList.vue'
import Profile from '../views/Profile.vue'
import Settings from '../views/Settings.vue'
import PermissionManagement from '../views/permission/index.vue'
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
    path: '/products/create',
    name: 'ProductCreate',
    component: ProductFormNew,
    meta: { requiresAuth: true }
  },
  {
    path: '/products/new',
    name: 'ProductFormNew',
    component: ProductFormNew,
    meta: { requiresAuth: true }
  },
  {
    path: '/products/edit/:id',
    name: 'ProductEdit',
    component: ProductFormNew,
    meta: { requiresAuth: true }
  },
  {
    path: '/products/deleted',
    name: 'ProductDeletedList',
    component: ProductDeletedList,
    meta: { requiresAuth: true, requiresAdmin: true }
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
    path: '/members/edit/:id',
    name: 'MemberEdit',
    component: MemberEdit,
    meta: { requiresAuth: true }
  },
  {
    path: '/members/points/:id',
    name: 'MemberPoints',
    component: MemberPoints,
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
    path: '/settings',
    name: 'Settings',
    component: Settings,
    meta: { requiresAuth: true }
  },
  {
    path: '/dictionaries',
    name: 'DictionaryList',
    component: DictionaryList,
    meta: { requiresAuth: true }
  },
  {
    path: '/dictionaries/:code/items',
    name: 'DictionaryItemList',
    component: DictionaryItemList,
    meta: { requiresAuth: true }
  },
  {
    path: '/permissions',
    name: 'PermissionManagement',
    component: PermissionManagement,
    meta: { requiresAuth: true, requiresAdmin: true }
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
  const userJson = localStorage.getItem('user') || '{}'
  const userInfo = JSON.parse(userJson)
  const requiresAuth = to.matched.some(record => record.meta.requiresAuth)
  const requiresAdmin = to.matched.some(record => record.meta.requiresAdmin)

  console.log('路由守卫中的用户信息:', userInfo)

  // 如果需要认证且没有token，重定向到登录页
  if (requiresAuth && !token) {
    next({ path: '/login', query: { redirect: to.fullPath } })
  }
  // 如果需要管理员权限但用户不是管理员
  else if (requiresAdmin && userInfo.Role !== 'admin') {
    console.log('用户不是管理员，重定向到仪表盘')
    next({ path: '/dashboard' })
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
