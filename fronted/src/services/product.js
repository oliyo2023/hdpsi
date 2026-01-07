import api from './api'
import { convertBackendFields, convertFrontendFields } from '../utils/fieldConverter'

// 商品服务
export default {
  // 获取商品列表
  async getProducts(params = {}) {
    const response = await api.get('/api/v1/products', { params })
    return convertBackendFields(response)
  },

  // 获取单个商品
  async getProduct(id) {
    const response = await api.get(`/api/v1/products/${id}`)
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
    const response = await api.post('/api/v1/products', convertFrontendFields(productData))
    return convertBackendFields(response)
  },

  // 更新商品
  async updateProduct(id, productData) {
    // 移除可能导致问题的时间字段
    const cleanData = { ...productData };
    delete cleanData.createdAt;
    delete cleanData.updatedAt;

    const response = await api.put(`/api/v1/products/${id}`, convertFrontendFields(cleanData))
    return convertBackendFields(response)
  },

  // 删除商品
  async deleteProduct(id) {
    const response = await api.delete(`/api/v1/products/${id}`)
    return convertBackendFields(response)
  },

  // 获取已删除的商品列表
  async getDeletedProducts(params = {}) {
    const response = await api.get('/api/v1/products/deleted/list', { params })
    return convertBackendFields(response)
  },

  // 恢复已删除的商品
  async restoreProduct(id) {
    const response = await api.post(`/api/v1/products/deleted/${id}/restore`)
    return convertBackendFields(response)
  }
}
