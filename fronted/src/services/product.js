import api from './api'

// 商品服务
export default {
  // 获取商品列表
  getProducts(params = {}) {
    return api.get('/api/products', { params })
  },
  
  // 获取单个商品
  getProduct(id) {
    return api.get(`/api/products/${id}`)
  },
  
  // 创建商品
  createProduct(productData) {
    return api.post('/api/products', productData)
  },
  
  // 更新商品
  updateProduct(id, productData) {
    return api.put(`/api/products/${id}`, productData)
  },
  
  // 删除商品
  deleteProduct(id) {
    return api.delete(`/api/products/${id}`)
  }
}
