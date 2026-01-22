import api from './api'

// 库存服务
export default {
  // 获取库存列表
  getInventories(params = {}) {
    return api.get('/api/v1/inventory', { params })
  },
  
  // 获取单个库存
  getInventory(id) {
    return api.get(`/api/v1/inventory/${id}`)
  },
  
  // 创建库存
  createInventory(inventoryData) {
    return api.post('/api/v1/inventory', inventoryData)
  },
  
  // 更新库存
  updateInventory(id, inventoryData) {
    return api.put(`/api/v1/inventory/${id}`, inventoryData)
  },
  
  // 删除库存
  deleteInventory(id) {
    return api.delete(`/api/v1/inventory/${id}`)
  },
  
  // 获取库存交易记录
  getInventoryTransactions(params = {}) {
    return api.get('/api/v1/inventory-transactions', { params })
  },
  
  // 创建库存交易记录
  createInventoryTransaction(transactionData) {
    return api.post('/api/v1/inventory-transactions', transactionData)
  },
  
  // 获取库存预警
  getInventoryAlerts(params = {}) {
    return api.get('/api/v1/inventory-alerts', { params })
  },
  
  // 更新库存预警状态
  updateAlertStatus(id, status) {
    return api.put(`/api/v1/inventory-alerts/${id}/status`, { status })
  },
  
  // 检查库存水平
  checkInventoryLevels() {
    return api.post('/api/v1/inventory-alerts/check')
  }
}
