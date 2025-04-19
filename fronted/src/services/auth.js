import api from './api'

// 认证服务
export default {
  // 用户登录
  login(username, password, rememberMe = false) {
    return api.post('/api/auth/login', { username, password, remember_me: rememberMe })
  },

  // 用户注册
  register(userData) {
    return api.post('/api/auth/register', userData)
  },

  // 获取当前用户信息
  getProfile() {
    return api.get('/api/profile')
  },

  // 获取并更新当前用户信息
  async fetchAndUpdateUserProfile() {
    try {
      const userData = await this.getProfile()
      if (userData) {
        console.log('从后端获取的用户信息:', userData)
        localStorage.setItem('user', JSON.stringify(userData))
        return userData
      }
      return null
    } catch (error) {
      console.error('获取用户信息失败:', error)
      return null
    }
  },

  // 更新用户信息
  updateProfile(userData) {
    return api.put('/api/profile', userData)
  },

  // 修改密码
  changePassword(oldPassword, newPassword) {
    return api.put('/api/change-password', {
      old_password: oldPassword,
      new_password: newPassword
    })
  },

  // 刷新令牌
  refreshToken(refreshToken, rememberMe = false) {
    return api.post('/api/auth/refresh-token', {
      refresh_token: refreshToken,
      remember_me: rememberMe
    })
  },

  // 忘记密码
  forgotPassword(email) {
    return api.post('/api/auth/forgot-password', { email })
  },

  // 重置密码
  resetPassword(token, newPassword) {
    return api.post('/api/auth/reset-password', {
      token,
      new_password: newPassword
    })
  },

  // 用户登出
  logout() {
    localStorage.removeItem('token')
    localStorage.removeItem('refreshToken')
    localStorage.removeItem('tokenExpires')
    localStorage.removeItem('user')
    window.location.href = '/login'
  },

  // 检查用户是否已认证
  isAuthenticated() {
    const token = localStorage.getItem('token')
    const expiresStr = localStorage.getItem('tokenExpires')

    if (!token || !expiresStr) {
      return false
    }

    // 检查令牌是否过期
    const expires = new Date(expiresStr)
    const now = new Date()

    // 如果令牌即将过期（小于5分钟），尝试刷新
    if (expires.getTime() - now.getTime() < 5 * 60 * 1000) {
      this.tryRefreshToken()
    }

    return now < expires
  },

  // 尝试刷新令牌
  async tryRefreshToken() {
    const refreshToken = localStorage.getItem('refreshToken')
    if (!refreshToken) {
      return false
    }

    try {
      const rememberMe = localStorage.getItem('rememberMe') === 'true'
      const response = await this.refreshToken(refreshToken, rememberMe)

      // 更新本地存储
      localStorage.setItem('token', response.token)
      localStorage.setItem('refreshToken', response.refresh_token)
      localStorage.setItem('tokenExpires', response.expires_at)
      localStorage.setItem('user', JSON.stringify(response.user))

      return true
    } catch (error) {
      console.error('刷新令牌失败:', error)
      return false
    }
  },

  // 获取当前用户
  getCurrentUser() {
    const userJson = localStorage.getItem('user')
    return userJson ? JSON.parse(userJson) : null
  },

  // 获取认证令牌
  getToken() {
    return localStorage.getItem('token')
  },

  // 保存登录响应
  saveLoginResponse(response) {
    console.log('登录响应数据:', response)
    localStorage.setItem('token', response.token)
    localStorage.setItem('refreshToken', response.refresh_token)
    localStorage.setItem('tokenExpires', response.expires_at)
    localStorage.setItem('user', JSON.stringify(response.user))
    console.log('已保存用户信息到本地存储:', response.user)
  }
}
