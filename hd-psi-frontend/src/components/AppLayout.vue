<template>
  <n-config-provider :locale="zhCN" :theme="theme">
    <n-loading-bar-provider>
      <n-dialog-provider>
        <n-notification-provider>
          <n-message-provider>
            <div class="app-container">
              <template v-if="isLoggedIn">
                <n-layout has-sider>
                  <!-- 侧边栏 -->
                  <n-layout-sider
                    :collapsed="collapsed"
                    :collapsed-width="64"
                    :width="240"
                    show-trigger
                    collapse-mode="width"
                    @collapse="collapsed = true"
                    @expand="collapsed = false"
                    bordered
                    class="sidebar"
                  >
                    <div class="logo-container">
                      <div class="logo">
                        <div class="logo-icon">
                          <span>HD</span>
                        </div>
                        <h2 v-if="!collapsed" class="logo-text">服装进销存</h2>
                      </div>
                    </div>
                    <div class="menu-container">
                      <n-menu
                        :collapsed="collapsed"
                        :collapsed-width="64"
                        :collapsed-icon-size="22"
                        :options="menuOptions"
                        :render-label="renderMenuLabel"
                        :render-icon="renderMenuIcon"
                        :value="activeKey"
                        @update:value="handleMenuUpdate"
                        class="custom-menu"
                      />
                    </div>
                  </n-layout-sider>

                  <!-- 主内容区 -->
                  <n-layout>
                    <!-- 顶部导航栏 -->
                    <n-layout-header bordered class="header">
                      <div class="header-content">
                        <div class="left">
                          <n-button quaternary circle @click="collapsed = !collapsed" class="toggle-button">
                            <template #icon>
                              <n-icon size="20">
                                <MenuOutline v-if="collapsed" />
                                <CloseOutline v-else />
                              </n-icon>
                            </template>
                          </n-button>
                          <div class="page-title">
                            {{ getPageTitle() }}
                          </div>
                        </div>
                        <div class="right">
                          <div class="header-actions">
                            <n-button quaternary circle class="action-button">
                              <template #icon>
                                <n-icon size="18">
                                  <NotificationsOutline />
                                </n-icon>
                              </template>
                            </n-button>
                            <n-button quaternary circle class="action-button">
                              <template #icon>
                                <n-icon size="18">
                                  <SearchOutline />
                                </n-icon>
                              </template>
                            </n-button>
                          </div>
                          <n-dropdown :options="userOptions" @select="handleUserAction" trigger="click">
                            <div class="user-dropdown">
                              <div class="user-avatar">
                                {{ getUserInitials() }}
                              </div>
                              <div class="user-info" v-if="!collapsed">
                                <div class="user-name">{{ currentUser.name || currentUser.username }}</div>
                                <div class="user-role">{{ getUserRole() }}</div>
                              </div>
                              <n-icon size="14" class="dropdown-icon">
                                <ChevronDownOutline />
                              </n-icon>
                            </div>
                          </n-dropdown>
                        </div>
                      </div>
                    </n-layout-header>

                    <!-- 内容区 -->
                    <n-layout-content class="content">
                      <router-view />
                    </n-layout-content>

                    <!-- 页脚 -->
                    <n-layout-footer bordered class="footer">
                      <p>© {{ new Date().getFullYear() }} 服装进销存系统 (HD-PSI)</p>
                    </n-layout-footer>
                  </n-layout>
                </n-layout>
              </template>
              <template v-else>
                <router-view />
              </template>
            </div>
          </n-message-provider>
        </n-notification-provider>
      </n-dialog-provider>
    </n-loading-bar-provider>
  </n-config-provider>
</template>

<script setup>
import { ref, computed, onMounted, watch, h } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import {
  NConfigProvider, NLayout, NLayoutSider, NLayoutHeader,
  NLayoutContent, NLayoutFooter, NMenu, NButton, NIcon,
  NDropdown, NMessageProvider, NNotificationProvider,
  NDialogProvider, NLoadingBarProvider
} from 'naive-ui'
import { zhCN, darkTheme } from 'naive-ui'
import {
  HomeOutline, CartOutline, PeopleOutline,
  PersonOutline, LogOutOutline, SettingsOutline,
  MenuOutline, CloseOutline, ChevronDownOutline,
  BagHandleOutline, StorefrontOutline, CubeOutline,
  NotificationsOutline, SearchOutline
} from '@vicons/ionicons5'
import auth from '../services/auth'

// 响应式状态
const router = useRouter()
const route = useRoute()
const collapsed = ref(false)
const isLoggedIn = ref(false)
const currentUser = ref({})
const theme = ref(null) // 默认使用亮色主题

// 计算属性
const activeKey = computed(() => {
  const path = route.path
  if (path.startsWith('/dashboard')) return 'dashboard'
  if (path.startsWith('/products')) return 'products'
  if (path.startsWith('/inventory')) return 'inventory'
  if (path.startsWith('/members')) return 'members'
  if (path.startsWith('/purchases')) return 'purchases'
  if (path.startsWith('/suppliers')) return 'suppliers'
  if (path.startsWith('/dictionaries')) return 'dictionaries'
  return ''
})

// 菜单配置
const menuOptions = [
  {
    label: '仪表盘',
    key: 'dashboard',
    icon: HomeOutline,
    path: '/dashboard'
  },
  {
    label: '商品管理',
    key: 'products',
    icon: CubeOutline,
    path: '/products'
  },
  {
    label: '库存管理',
    key: 'inventory',
    icon: StorefrontOutline,
    path: '/inventory'
  },
  {
    label: '采购管理',
    key: 'purchases',
    icon: BagHandleOutline,
    children: [
      {
        label: '采购单',
        key: 'purchase-orders',
        path: '/purchases'
      },
      {
        label: '供应商',
        key: 'suppliers',
        path: '/suppliers'
      }
    ]
  },
  {
    label: '会员管理',
    key: 'members',
    icon: PeopleOutline,
    path: '/members'
  },
  {
    label: '销售管理',
    key: 'sales',
    icon: CartOutline,
    path: '/sales'
  },
  {
    label: '系统管理',
    key: 'system',
    icon: SettingsOutline,
    children: [
      {
        label: '字典管理',
        key: 'dictionaries',
        path: '/dictionaries'
      }
    ]
  }
]

// 用户下拉菜单选项
const userOptions = [
  {
    label: '个人信息',
    key: 'profile',
    icon: () => h(NIcon, null, { default: () => h(PersonOutline) })
  },
  {
    label: '系统设置',
    key: 'settings',
    icon: () => h(NIcon, null, { default: () => h(SettingsOutline) })
  },
  {
    type: 'divider',
    key: 'd1'
  },
  {
    label: '退出登录',
    key: 'logout',
    icon: () => h(NIcon, null, { default: () => h(LogOutOutline) })
  }
]

// 方法
const renderMenuLabel = (option) => {
  return option.label
}

const renderMenuIcon = (option) => {
  return option.icon ? h(NIcon, null, { default: () => h(option.icon) }) : null
}

const handleMenuUpdate = (key) => {
  const findPath = (options, key) => {
    for (const option of options) {
      if (option.key === key) return option.path
      if (option.children) {
        const path = findPath(option.children, key)
        if (path) return path
      }
    }
    return null
  }

  const path = findPath(menuOptions, key)
  if (path) router.push(path)
}

const handleUserAction = (key) => {
  if (key === 'logout') {
    auth.logout()
  } else if (key === 'profile') {
    router.push('/profile')
  } else if (key === 'settings') {
    router.push('/settings')
  }
}

// 获取页面标题
const getPageTitle = () => {
  const path = route.path
  const pageTitles = {
    '/dashboard': '仪表盘',
    '/products': '商品管理',
    '/inventory': '库存管理',
    '/members': '会员管理',
    '/purchases': '采购管理',
    '/suppliers': '供应商管理',
    '/sales': '销售管理',
    '/profile': '个人信息',
    '/dictionaries': '字典管理'
  }

  // 处理子路径
  if (path.startsWith('/purchases/')) {
    if (path.includes('create')) {
      return '创建采购单'
    }
    return '采购单详情'
  }

  if (path.startsWith('/suppliers/')) {
    return '供应商详情'
  }

  return pageTitles[path] || '服装进销存系统'
}

// 获取用户角色文本
const getUserRole = () => {
  const roleMap = {
    'admin': '管理员',
    'manager': '经理',
    'staff': '员工'
  }
  return roleMap[currentUser.value?.role] || '用户'
}

// 获取用户名首字母作为头像
const getUserInitials = () => {
  const name = currentUser.value?.name || currentUser.value?.username || ''
  if (!name) return 'U'

  // 如果是中文名字，取第一个字
  if (/[\u4e00-\u9fa5]/.test(name)) {
    return name.charAt(0)
  }

  // 如果是英文名字，取首字母
  return name.charAt(0).toUpperCase()
}

// 检查登录状态并更新用户信息
const checkAuthStatus = async () => {
  // 检查用户是否已登录
  isLoggedIn.value = auth.isAuthenticated()

  // 如果已登录，从后端获取最新的用户信息
  if (isLoggedIn.value) {
    try {
      // 尝试从后端获取用户信息
      const userProfile = await auth.fetchAndUpdateUserProfile()
      if (userProfile) {
        currentUser.value = userProfile
      } else {
        // 如果无法获取用户信息，尝试使用本地存储的信息
        currentUser.value = auth.getCurrentUser() || {}

        // 如果本地也没有用户信息，清除令牌并重定向到登录页
        if (!currentUser.value || !currentUser.value.username) {
          auth.logout()
          return
        }
      }
    } catch (error) {
      console.error('获取用户信息失败:', error)
      // 如果获取用户信息失败，清除本地存储并重定向到登录页
      if (error.response && error.response.status === 401) {
        auth.logout()
        return
      }
    }
  } else {
    // 如果未登录，清除用户信息
    currentUser.value = {}
  }

  console.log('Auth status checked, isLoggedIn:', isLoggedIn.value, 'currentUser:', currentUser.value)
}

// 生命周期钩子
onMounted(async () => {
  await checkAuthStatus()
})

// 监听路由变化
watch(
  () => route.path,
  async () => {
    await checkAuthStatus()
  }
)
</script>

<style scoped>
.app-container {
  height: 100vh;
  width: 100%;
  overflow-x: hidden;
}

/* 侧边栏样式 */
.sidebar {
  background-color: #ffffff;
  border-right: 1px solid #f1f5f9 !important;
  box-shadow: 0 0 20px rgba(0, 0, 0, 0.03);
  position: relative;
  z-index: 10;
}

/* Logo 区域 */
.logo-container {
  height: 64px;
  padding: 0 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-bottom: 1px solid #f1f5f9;
  margin-bottom: 8px;
  background: linear-gradient(to right, #f8fafc, #ffffff);
}

.logo {
  display: flex;
  align-items: center;
  overflow: hidden;
}

.logo-icon {
  width: 36px;
  height: 36px;
  background: linear-gradient(135deg, #0ea5e9, #06b6d4);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 12px;
  box-shadow: 0 2px 8px rgba(14, 165, 233, 0.2);
}

.logo-icon span {
  font-size: 18px;
  font-weight: bold;
  color: #ffffff;
}

.logo-text {
  font-size: 18px;
  font-weight: 600;
  margin: 0;
  white-space: nowrap;
  color: #0ea5e9;
}

/* 菜单容器 */
.menu-container {
  padding: 8px;
  height: calc(100% - 64px);
  overflow: hidden;
}

/* 自定义菜单样式 */
.custom-menu :deep(.n-menu-item) {
  height: 44px;
  margin-bottom: 2px;
  border-radius: 8px;
  color: #64748b;
  transition: all 0.3s;
}

.custom-menu :deep(.n-menu-item:hover) {
  color: #0ea5e9;
  background-color: #f1f5f9;
}

.custom-menu :deep(.n-menu-item-content) {
  padding: 0 12px;
}

.custom-menu :deep(.n-menu-item-content__icon) {
  margin-right: 10px;
  font-size: 18px;
}

.custom-menu :deep(.n-menu-item.n-menu-item--selected) {
  background-color: rgba(14, 165, 233, 0.1);
  color: #0ea5e9;
  font-weight: 500;
}

.custom-menu :deep(.n-menu-item.n-menu-item--selected::before) {
  content: '';
  position: absolute;
  left: 0;
  top: 50%;
  transform: translateY(-50%);
  width: 4px;
  height: 20px;
  background: #0ea5e9;
  border-radius: 0 4px 4px 0;
}

.custom-menu :deep(.n-submenu) {
  margin-bottom: 2px;
  color: #1e293b;
}

.custom-menu :deep(.n-submenu-children) {
  padding-left: 4px;
}

.custom-menu :deep(.n-submenu-children .n-menu-item) {
  height: 40px;
  margin-bottom: 1px;
}

.custom-menu :deep(.n-submenu.n-submenu--selected) {
  color: #0ea5e9;
}

.custom-menu :deep(.n-submenu:hover) {
  color: #0ea5e9;
}

/* 头部样式 */
.header {
  height: 64px;
  padding: 0 24px;
  background-color: #fff;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.05);
}

.header-content {
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.left {
  display: flex;
  align-items: center;
}

.toggle-button {
  margin-right: 16px;
  color: #64748b;
}

.page-title {
  font-size: 18px;
  font-weight: 600;
  color: #1e293b;
}

.right {
  display: flex;
  align-items: center;
}

.header-actions {
  display: flex;
  margin-right: 16px;
}

.action-button {
  margin-right: 8px;
  color: #64748b;
}

.user-dropdown {
  display: flex;
  align-items: center;
  cursor: pointer;
  padding: 4px 8px;
  border-radius: 8px;
  transition: all 0.3s;
}

.user-dropdown:hover {
  background-color: #f1f5f9;
}

.user-avatar {
  width: 36px;
  height: 36px;
  border-radius: 8px;
  background: linear-gradient(135deg, #0ea5e9, #06b6d4);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  font-weight: 600;
  margin-right: 10px;
  box-shadow: 0 2px 8px rgba(14, 165, 233, 0.2);
}

.user-info {
  margin-right: 8px;
}

.user-name {
  font-size: 14px;
  font-weight: 500;
  color: #1e293b;
  line-height: 1.2;
}

.user-role {
  font-size: 12px;
  color: #64748b;
}

.dropdown-icon {
  color: #64748b;
}

/* 内容区域 */
.content {
  padding: 16px;
  min-height: calc(100vh - 64px - 48px);
  background-color: #f8fafc;
  overflow-x: hidden;
}

/* 页脚 */
.footer {
  height: 48px;
  padding: 0 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #94a3b8;
  background-color: #fff;
  border-top: 1px solid #f1f5f9;
}
</style>
