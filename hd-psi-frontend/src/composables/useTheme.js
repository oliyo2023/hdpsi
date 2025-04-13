import { ref, onMounted, watch } from 'vue'
import settingsService from '@/services/settings'

// 主题类型
export const THEME_LIGHT = 'light'
export const THEME_DARK = 'dark'

// 创建主题钩子
export function useTheme() {
  // 当前主题
  const currentTheme = ref(THEME_LIGHT)
  
  // 加载主题
  const loadTheme = async () => {
    try {
      // 从后端获取用户主题设置
      const theme = await settingsService.getUserTheme()
      currentTheme.value = theme
      applyTheme(theme)
    } catch (error) {
      console.error('加载主题设置失败:', error)
      // 使用默认主题
      applyTheme(THEME_LIGHT)
    }
  }
  
  // 切换主题
  const toggleTheme = async () => {
    const newTheme = currentTheme.value === THEME_LIGHT ? THEME_DARK : THEME_LIGHT
    await changeTheme(newTheme)
  }
  
  // 更改主题
  const changeTheme = async (theme) => {
    try {
      // 更新后端主题设置
      await settingsService.updateUserTheme(theme)
      currentTheme.value = theme
      applyTheme(theme)
    } catch (error) {
      console.error('更新主题设置失败:', error)
    }
  }
  
  // 应用主题
  const applyTheme = (theme) => {
    // 移除现有主题类
    document.documentElement.classList.remove(THEME_LIGHT, THEME_DARK)
    // 添加新主题类
    document.documentElement.classList.add(theme)
    
    // 更新CSS变量
    if (theme === THEME_DARK) {
      document.documentElement.style.setProperty('--primary-color', '#36ad6a')
      document.documentElement.style.setProperty('--background-color', '#121212')
      document.documentElement.style.setProperty('--text-color', '#ffffff')
      document.documentElement.style.setProperty('--border-color', '#333333')
      document.documentElement.style.setProperty('--card-background', '#1e1e1e')
    } else {
      document.documentElement.style.setProperty('--primary-color', '#18a058')
      document.documentElement.style.setProperty('--background-color', '#f5f5f5')
      document.documentElement.style.setProperty('--text-color', '#333333')
      document.documentElement.style.setProperty('--border-color', '#e0e0e0')
      document.documentElement.style.setProperty('--card-background', '#ffffff')
    }
  }
  
  // 监听主题变化
  watch(currentTheme, (newTheme) => {
    applyTheme(newTheme)
  })
  
  // 组件挂载时加载主题
  onMounted(() => {
    loadTheme()
  })
  
  return {
    currentTheme,
    loadTheme,
    toggleTheme,
    changeTheme
  }
}
