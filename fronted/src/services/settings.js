import api from './api'
import authService from './auth'

// 系统设置服务
const settingsService = {
  /**
   * 获取系统设置
   * @param {string} group - 设置分组
   * @returns {Promise<Object>} - 设置数据
   */
  async getSettings(group = '') {
    try {
      const params = {}
      if (group) {
        params.group = group
      }

      return await api.get('/api/v1/settings', { params })
    } catch (error) {
      console.error('获取系统设置失败:', error)
      throw error
    }
  },

  /**
   * 更新系统设置
   * @param {string} group - 设置分组
   * @param {Object} settings - 设置数据
   * @returns {Promise<Object>} - 响应数据
   */
  async updateSettings(group, settings) {
    try {
      return await api.put('/api/v1/settings', { group, settings })
    } catch (error) {
      console.error('更新系统设置失败:', error)
      throw error
    }
  },

  /**
   * 获取用户主题设置
   * @returns {Promise<string>} - 主题名称
   */
  async getUserTheme() {
    try {
      const response = await api.get('/api/v1/settings/theme')
      return response.theme
    } catch (error) {
      console.error('获取用户主题设置失败:', error)
      return 'light' // 默认主题
    }
  },

  /**
   * 更新用户主题设置
   * @param {string} theme - 主题名称
   * @returns {Promise<Object>} - 响应数据
   */
  async updateUserTheme(theme) {
    try {
      return await api.put('/api/v1/settings/theme', { theme })
    } catch (error) {
      console.error('更新用户主题设置失败:', error)
      throw error
    }
  }
}

export default settingsService
