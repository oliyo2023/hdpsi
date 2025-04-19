import api from './api'

// 采购服务
export default {
  // 获取采购单列表
  getPurchaseOrders(params = {}) {
    return api.get('/api/purchases', { params })
  },
  
  // 获取单个采购单
  getPurchaseOrder(id) {
    return api.get(`/api/purchases/${id}`)
  },
  
  // 创建采购单
  createPurchaseOrder(purchaseData) {
    return api.post('/api/purchases', purchaseData)
  },
  
  // 更新采购单
  updatePurchaseOrder(id, purchaseData) {
    return api.put(`/api/purchases/${id}`, purchaseData)
  },
  
  // 更新采购单状态
  updatePurchaseOrderStatus(id, status, note = '') {
    return api.put(`/api/purchases/${id}/status`, { status, note })
  },
  
  // 删除采购单
  deletePurchaseOrder(id) {
    return api.delete(`/api/purchases/${id}`)
  },
  
  // 获取采购入库列表
  getPurchaseReceivings(params = {}) {
    return api.get('/api/purchase-receivings', { params })
  },
  
  // 获取单个采购入库
  getPurchaseReceiving(id) {
    return api.get(`/api/purchase-receivings/${id}`)
  },
  
  // 创建采购入库
  createPurchaseReceiving(receivingData) {
    return api.post('/api/purchase-receivings', receivingData)
  },
  
  // 删除采购入库
  deletePurchaseReceiving(id) {
    return api.delete(`/api/purchase-receivings/${id}`)
  }
}
