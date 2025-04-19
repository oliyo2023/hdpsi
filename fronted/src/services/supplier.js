import api from './api'

// 供应商服务
export default {
  // 获取供应商列表
  getSuppliers(params = {}) {
    return api.get('/api/suppliers', { params })
  },
  
  // 获取单个供应商
  getSupplier(id) {
    return api.get(`/api/suppliers/${id}`)
  },
  
  // 创建供应商
  createSupplier(supplierData) {
    return api.post('/api/suppliers', supplierData)
  },
  
  // 更新供应商
  updateSupplier(id, supplierData) {
    return api.put(`/api/suppliers/${id}`, supplierData)
  },
  
  // 删除供应商
  deleteSupplier(id) {
    return api.delete(`/api/suppliers/${id}`)
  }
}
