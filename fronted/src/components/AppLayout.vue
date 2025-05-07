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
                            <n-button quaternary circle class="action-button" @click="toggleTheme">
                              <template #icon>
                                <n-icon size="18">
                                  <template v-if="currentTheme === THEME_LIGHT">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24">
                                      <path fill="currentColor" d="M12 21q-3.75 0-6.375-2.625T3 12t2.625-6.375T12 3q.35 0 .688.025t.662.075q-1.025.725-1.638 1.888T11.1 7.5q0 2.25 1.575 3.825T16.5 12.9q1.375 0 2.525-.613T20.9 10.65q.05.325.075.662T21 12q0 3.75-2.625 6.375T12 21" />
                                    </svg>
                                  </template>
                                  <template v-else>
                                    <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24">
                                      <path fill="currentColor" d="M12 17q-2.075 0-3.538-1.463T7 12q0-2.075 1.463-3.538T12 7q2.075 0 3.538 1.463T17 12q0 2.075-1.463 3.538T12 17M2 13h2q.425 0 .713-.288T5 12q0-.425-.288-.713T4 11H2q-.425 0-.713.288T1 12q0 .425.288.713T2 13m18 0h2q.425 0 .713-.288T23 12q0-.425-.288-.713T22 11h-2q-.425 0-.713.288T19 12q0 .425.288.713T20 13m-8-8q.425 0 .713-.288T13 4V2q0-.425-.288-.713T12 1q-.425 0-.713.288T11 2v2q0 .425.288.713T12 5m0 14q.425 0 .713-.288T13 18v-2q0-.425-.288-.713T12 15q-.425 0-.713.288T11 16v2q0 .425.288.713T12 19M5.65 7.05L4.575 6q-.3-.275-.288-.7t.288-.725q.3-.3.725-.3t.7.3L7.05 5.65q.275.3.275.7t-.275.7q-.275.3-.687.288T5.65 7.05M18.35 7.05q-.275-.3-.275-.7t.275-.7l1.075-1.05q.3-.3.713-.3t.712.3q.3.3.3.725t-.3.7L19.4 7.05q-.3.275-.7.275t-.7-.275M16.95 19.425l1.05 1.075q.3.3.3.713t-.3.712q-.3.3-.725.3t-.7-.3L15.5 20.35q-.3-.3-.288-.7t.288-.7q.3-.3.7-.288t.7.288M4.575 19.425q-.3-.3-.3-.725t.3-.7l1.05-1.075q.3-.275.7-.275t.7.275q.3.3.288.7t-.288.7l-1.05 1.075q-.3.3-.712.3t-.713-.3Z" />
                                    </svg>
                                  </template>
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
                                <div class="user-name">{{ currentUser?.Name || currentUser?.Username || 'User' }}</div>
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
  NDialogProvider, NLoadingBarProvider, NSwitch
} from 'naive-ui'
import { zhCN, darkTheme } from 'naive-ui'
import { useTheme, THEME_LIGHT, THEME_DARK } from '@/composables/useTheme'
import {
  HomeOutline, CartOutline, PeopleOutline,
  PersonOutline, LogOutOutline, SettingsOutline,
  MenuOutline, CloseOutline, ChevronDownOutline,
  BagHandleOutline, StorefrontOutline, CubeOutline,
  NotificationsOutline, SearchOutline, LockClosedOutline
} from '@vicons/ionicons5'
import auth from '../services/auth'

// 响应式状态
const router = useRouter()
const route = useRoute()
const collapsed = ref(false)
const isLoggedIn = ref(false)
const currentUser = ref({})

// 使用主题钩子
const { currentTheme, toggleTheme } = useTheme()

// 设置主题
const theme = computed(() => {
  return currentTheme.value === THEME_DARK ? darkTheme : null
})

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
  if (path.startsWith('/permissions')) return 'permissions'
  return ''
})

// 菜单配置
const menuOptions = computed(() => {
  const isAdmin = currentUser.value?.Role === 'admin'
  console.log('当前用户信息:', currentUser.value)
  console.log('是否管理员:', isAdmin)

  // 基础菜单项
  const baseMenuItems = [
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
      children: [
        {
          label: '商品列表',
          key: 'product-list',
          path: '/products'
        },
        {
          label: '已删除商品',
          key: 'product-deleted',
          path: '/products/deleted'
        }
      ]
    },
    {
      label: '库存管理',
      key: 'inventory',
      icon: StorefrontOutline,
      children: [
        {
          label: '库存列表',
          key: 'inventory-list',
          path: '/inventory'
        },
        {
          label: '库存盘点',
          key: 'inventory-check',
          path: '/inventory-checks'
        }
      ]
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
    }
  ]

  // 系统管理子菜单项
  const systemChildren = [
    {
      label: '字典管理',
      key: 'dictionaries',
      path: '/dictionaries'
    }
  ]

  // 只有管理员才能看到权限管理
  if (isAdmin) {
    systemChildren.push({
      label: '权限管理',
      key: 'permissions',
      path: '/permissions'
    })
  }

  // 添加系统管理菜单
  baseMenuItems.push({
    label: '系统管理',
    key: 'system',
    icon: SettingsOutline,
    children: systemChildren
  })

  return baseMenuItems
})

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
  console.log('菜单点击:', key)

  const findPath = (options, key) => {
    for (const option of options) {
      if (option.key === key) {
        console.log('找到菜单项:', option)
        return option.path
      }
      if (option.children) {
        const path = findPath(option.children, key)
        if (path) return path
      }
    }
    return null
  }

  const path = findPath(menuOptions.value, key)
  console.log('菜单路径:', path)

  if (path) {
    console.log('将跳转到:', path)
    router.push(path)
  } else {
    console.log('未找到对应路径')
  }
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
    '/inventory-checks': '库存盘点',
    '/inventory-checks/create': '创建盘点单',
    '/members': '会员管理',
    '/purchases': '采购管理',
    '/suppliers': '供应商管理',
    '/sales': '销售管理',
    '/profile': '个人信息',
    '/settings': '系统设置',
    '/dictionaries': '字典管理',
    '/permissions': '权限管理'
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

  if (path.startsWith('/inventory-checks/')) {
    if (path.includes('create')) {
      return '创建盘点单'
    }
    return '盘点单详情'
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
  return roleMap[currentUser.value?.Role] || '用户'
}

// 获取用户名首字母作为头像
const getUserInitials = () => {
  try {
    const name = currentUser.value?.Name || currentUser.value?.Username || ''
    console.log('获取用户头像时的用户名:', name)
    if (!name) return 'U'

    // 如果是中文名字，取第一个字
    if (/[\u4e00-\u9fa5]/.test(name)) {
      return name.charAt(0)
    }

    // 如果是英文名字，取首字母
    return name.charAt(0).toUpperCase()
  } catch (error) {
    console.error('获取用户头像失败:', error)
    return 'U'
  }
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
        console.log('更新后的当前用户信息:', currentUser.value)
      } else {
        // 如果无法获取用户信息，尝试使用本地存储的信息
        currentUser.value = auth.getCurrentUser() || {}
        console.log('从本地存储获取的用户信息:', currentUser.value)

        // 如果本地也没有用户信息，清除令牌并重定向到登录页
        if (!currentUser.value || !currentUser.value.username) {
          console.log('本地没有用户信息，执行登出')
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
  background-color: var(--card-background);
  border-right: 1px solid var(--border-color-light) !important;
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
  border-bottom: 1px solid var(--border-color-light);
  margin-bottom: 8px;
  background: var(--card-background);
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
  color: var(--text-color-regular);
  transition: all 0.3s;
}

.custom-menu :deep(.n-menu-item:hover) {
  color: var(--primary-color);
  background-color: var(--primary-bg-color);
}

.custom-menu :deep(.n-menu-item-content) {
  padding: 0 12px;
}

.custom-menu :deep(.n-menu-item-content__icon) {
  margin-right: 10px;
  font-size: 18px;
}

.custom-menu :deep(.n-menu-item.n-menu-item--selected) {
  background-color: var(--primary-bg-color);
  color: var(--primary-color);
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
  background: var(--primary-color);
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
  background-color: var(--card-background);
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
  color: var(--text-color-secondary);
}

.page-title {
  font-size: 18px;
  font-weight: 600;
  color: var(--text-color-primary);
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
  color: var(--text-color-secondary);
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
  background-color: var(--table-hover-background);
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
  color: var(--text-color-primary);
  line-height: 1.2;
}

.user-role {
  font-size: 12px;
  color: var(--text-color-secondary);
}

.dropdown-icon {
  color: var(--text-color-secondary);
}

/* 内容区域 */
.content {
  padding: 16px;
  min-height: calc(100vh - 64px - 48px);
  background-color: var(--background-color);
  overflow-x: hidden;
}

/* 页脚 */
.footer {
  height: 48px;
  padding: 0 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--text-color-secondary);
  background-color: var(--card-background);
  border-top: 1px solid var(--border-color-light);
}
</style>
