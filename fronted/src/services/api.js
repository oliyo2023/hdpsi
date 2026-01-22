import axios from 'axios'
import { createDiscreteApi } from 'naive-ui'

/**
 * 全局统一的axios实例
 * 所有API请求都应该使用这个实例
 * 不要创建新的axios实例，以保持代码一致性
 */
const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:8081',
  timeout: 15000, // 请求超时时间
  headers: {
    'Content-Type': 'application/json'
  }
})

// 请求拦截器
api.interceptors.request.use(
  config => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers['Authorization'] = `Bearer ${token}`
    }

    // 添加调试信息
    console.log('API请求 (services/api.js):', {
      url: config.url,
      method: config.method,
      data: config.data,
      params: config.params,
      baseURL: config.baseURL
    })

    return config
  },
  error => {
    return Promise.reject(error)
  }
)

// 响应拦截器
api.interceptors.response.use(
  response => {
    // 添加调试信息
    console.log('API响应 (services/api.js):', {
      url: response.config.url,
      status: response.status,
      data: response.data,
      baseURL: response.config.baseURL
    })

    // 如果是单个商品请求，打印更详细的信息
    if (response.config.url.includes('/api/v1/products/') && !response.config.url.includes('/list')) {
      console.log('商品详情原始数据:', response.data)
      console.log('商品详情数据字段:', Object.keys(response.data))
    }

    // 处理统一API响应格式
    const responseData = response.data

    // 检查是否是新的统一响应格式
    if (responseData && responseData.code !== undefined) {
      // 如果是成功响应码（20000-29999）
      if (responseData.code >= 20000 && responseData.code < 30000) {
        // 返回data字段
        return responseData.data
      } else {
        // 如果是错误响应码，抛出错误
        const error = new Error(responseData.message || '请求失败')
        error.response = {
          status: response.status,
          data: responseData
        }
        throw error
      }
    }

    // 如果不是新的统一响应格式，直接返回数据
    return responseData
  },
  async error => {
    // 注意: 不要在拦截器中使用 useMessage，因为它需要在组件中使用
    console.error('API 请求错误:', error)

    // 显示错误提示
    if (error.response && error.response.data) {
      const errorData = error.response.data

      // 检查是否是新的统一响应格式
      if (errorData.code !== undefined && errorData.message) {
        handleError(errorData.message)
      } else if (errorData.error) {
        handleError(errorData.error)
      } else {
        handleError(error.message || '请求失败')
      }
    } else if (error.message) {
      handleError(error.message)
    } else {
      handleError('请求失败')
    }

    const originalRequest = error.config

    if (error.response) {
      // 服务器返回错误状态码
      const status = error.response.status

      // 如果是401错误且不是刷新令牌的请求
      if (status === 401 && !originalRequest._retry) {
        // 标记该请求已尝试过刷新令牌
        originalRequest._retry = true

        try {
          // 尝试使用刷新令牌获取新的访问令牌
          const refreshToken = localStorage.getItem('refreshToken')
          if (!refreshToken || refreshToken === 'undefined') {
            // 如果没有刷新令牌或值为undefined，直接跳转到登录页
            console.error('刷新令牌不存在或无效:', refreshToken)
            throw new Error('刷新令牌不存在或无效')
          }

          const rememberMe = localStorage.getItem('rememberMe') === 'true'

          // 引入auth服务
          const auth = await import('./auth').then(module => module.default)

          // 尝试刷新令牌
          console.log('尝试刷新令牌:', refreshToken)
          const response = await auth.refreshToken(refreshToken, rememberMe)

          // 更新本地存储
          // 注意：response可能是从data字段提取的，所以直接使用
          localStorage.setItem('token', response.token)
          localStorage.setItem('refreshToken', response.refresh_token)
          localStorage.setItem('tokenExpires', response.expires_at)
          if (response.user) {
            localStorage.setItem('user', JSON.stringify(response.user))
          }

          // 更新原始请求的认证信息
          originalRequest.headers['Authorization'] = `Bearer ${response.token}`

          // 重新发送原始请求
          return axios(originalRequest)
        } catch (refreshError) {
          console.error('刷新令牌失败:', refreshError)

          // 刷新令牌失败，清除所有认证信息
          localStorage.removeItem('token')
          localStorage.removeItem('refreshToken')
          localStorage.removeItem('tokenExpires')
          localStorage.removeItem('user')
          localStorage.removeItem('rememberMe')

          // 显示错误提示
          handleError('登录已过期，请重新登录')

          // 重定向到登录页
          const currentPath = window.location.pathname
          if (currentPath !== '/login') {
            console.log('重定向到登录页面...')
            // 使用延迟确保错误消息能够显示
            setTimeout(() => {
              window.location.href = `/login?redirect=${encodeURIComponent(currentPath)}`
            }, 1000)
          }

          // 中断Promise链，防止继续处理
          return Promise.reject(new Error('登录已过期，请重新登录'))
        }
      } else if (status === 401) {
        // 如果已经尝试过刷新令牌依然失败，清除信息并重定向
        localStorage.removeItem('token')
        localStorage.removeItem('refreshToken')
        localStorage.removeItem('tokenExpires')
        localStorage.removeItem('user')
        localStorage.removeItem('rememberMe')

        // 显示错误提示
        handleError('登录已过期或无效，请重新登录')

        // 重定向到登录页
        const currentPath = window.location.pathname
        if (currentPath !== '/login') {
          console.log('重定向到登录页面...')
          // 使用延迟确保错误消息能够显示
          setTimeout(() => {
            window.location.href = `/login?redirect=${encodeURIComponent(currentPath)}`
          }, 1000)
        }

        // 中断Promise链
        return Promise.reject(new Error('登录已过期或无效，请重新登录'))
      }
    }

    return Promise.reject(error)
  }
)

// 错误处理函数
function handleError(message) {
  const { message: messageApi } = createDiscreteApi(['message'])
  messageApi.error(message)
}

export default api
