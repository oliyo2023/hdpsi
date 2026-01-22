import api from './api'

// 认证服务
export default {
  // 用户登录
  login(username, password, rememberMe = false) {
    return api.post('/api/v1/auth/login', { username, password, remember_me: rememberMe })
  },

  // 用户注册
  register(userData) {
    return api.post('/api/v1/auth/register', userData)
  },

  // 获取当前用户信息
  getProfile() {
    return api.get('/api/v1/profile')
  },

  // 获取并更新当前用户信息
  async fetchAndUpdateUserProfile() {
    try {
      const userData = await this.getProfile()
      if (userData) {
        console.log('从后端获取的用户信息:', userData)
        try {
          localStorage.setItem('user', JSON.stringify(userData))
        } catch (parseError) {
          console.error('存储用户信息失败:', parseError)
        }
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
    return api.put('/api/v1/profile', userData)
  },

  // 修改密码
  changePassword(oldPassword, newPassword) {
    return api.put('/api/v1/change-password', {
      old_password: oldPassword,
      new_password: newPassword
    })
  },

  // 刷新令牌
  refreshToken(refreshToken, rememberMe = false) {
    // 验证刷新令牌是否有效
    if (!refreshToken || refreshToken === 'undefined') {
      return Promise.reject(new Error('刷新令牌不存在或无效'));
    }

    console.log('发送刷新令牌请求:', { refresh_token: refreshToken, remember_me: rememberMe });

    return api.post('/api/v1/auth/refresh-token', {
      refresh_token: refreshToken,
      remember_me: rememberMe
    });
  },

  // 忘记密码
  forgotPassword(email) {
    return api.post('/api/v1/auth/forgot-password', { email })
  },

  // 重置密码
  resetPassword(token, newPassword) {
    return api.post('/api/v1/auth/reset-password', {
      token,
      new_password: newPassword
    })
  },

  // 用户登出
  logout() {
    // 使用统一的方法清除认证数据
    this.clearAuthData()
    console.log('用户登出，重定向到登录页面')
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
    if (!refreshToken || refreshToken === 'undefined') {
      console.error('刷新令牌不存在或无效:', refreshToken)
      this.clearAuthData()
      return false
    }

    try {
      const rememberMe = localStorage.getItem('rememberMe') === 'true'
      console.log('尝试刷新令牌:', { refreshToken, rememberMe })
      const response = await this.refreshToken(refreshToken, rememberMe)

      // 更新本地存储
      localStorage.setItem('token', response.token)
      localStorage.setItem('refreshToken', response.refresh_token)
      localStorage.setItem('tokenExpires', response.expires_at)
      if (response.user) {
        localStorage.setItem('user', JSON.stringify(response.user))
      }

      console.log('刷新令牌成功')
      return true
    } catch (error) {
      console.error('刷新令牌失败:', error)
      // 清除所有认证数据
      this.clearAuthData()

      // 如果不在登录页，重定向到登录页
      const currentPath = window.location.pathname
      if (currentPath !== '/login') {
        console.log('重定向到登录页面...')
        setTimeout(() => {
          window.location.href = `/login?redirect=${encodeURIComponent(currentPath)}`
        }, 1000)
      }

      return false
    }
  },

  // 清除所有认证数据
  clearAuthData() {
    console.log('清除所有认证数据')
    localStorage.removeItem('token')
    localStorage.removeItem('refreshToken')
    localStorage.removeItem('tokenExpires')
    localStorage.removeItem('user')
    localStorage.removeItem('rememberMe')
  },

  // 获取当前用户
  getCurrentUser() {
    try {
      const userJson = localStorage.getItem('user')
      return userJson ? JSON.parse(userJson) : null
    } catch (error) {
      console.error('解析用户信息失败:', error)
      return null
    }
  },

  // 获取认证令牌
  getToken() {
    return localStorage.getItem('token')
  },

  // 保存登录响应
  saveLoginResponse(response) {
    console.log('登录响应数据:', response)

    // 检查响应格式
    if (!response) {
      console.error('登录响应为空')
      return
    }

    // 保存令牌信息
    localStorage.setItem('token', response.token)
    localStorage.setItem('refreshToken', response.refresh_token)
    localStorage.setItem('tokenExpires', response.expires_at)

    // 保存用户信息
    if (response.user) {
      try {
        localStorage.setItem('user', JSON.stringify(response.user))
        console.log('已保存用户信息到本地存储:', response.user)
      } catch (error) {
        console.error('保存用户信息失败:', error)
      }
    } else {
      console.warn('登录响应中没有用户信息')
    }
  }
}
