import api from './api'
import { convertBackendFields, convertFrontendFields } from '../utils/fieldConverter'

// 商品服务
export default {
  // 获取商品列表
  async getProducts(params = {}) {
    const response = await api.get('/api/products', { params })
    return convertBackendFields(response)
  },

  // 获取单个商品
  async getProduct(id) {
    const response = await api.get(`/api/products/${id}`)
    console.log('产品服务收到的原始响应:', response)

    // 后端返回的是包含product和variants的对象
    // 需要提取product对象并转换字段
    const convertedData = {
      ...convertBackendFields(response.product || {}),
      variants: response.variants ? convertBackendFields(response.variants) : []
    }

    console.log('产品服务转换后的数据:', convertedData)
    return convertedData
  },

  // 创建商品
  async createProduct(productData) {
    const response = await api.post('/api/products', convertFrontendFields(productData))
    return convertBackendFields(response)
  },

  // 更新商品
  async updateProduct(id, productData) {
    const response = await api.put(`/api/products/${id}`, convertFrontendFields(productData))
    return convertBackendFields(response)
  },

  // 删除商品
  async deleteProduct(id) {
    const response = await api.delete(`/api/products/${id}`)
    return convertBackendFields(response)
  },

  // 获取已删除的商品列表
  async getDeletedProducts(params = {}) {
    const response = await api.get('/api/products/deleted/list', { params })
    return convertBackendFields(response)
  },

  // 恢复已删除的商品
  async restoreProduct(id) {
    const response = await api.post(`/api/products/deleted/${id}/restore`)
    return convertBackendFields(response)
  }
}
