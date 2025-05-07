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
    // 转换字段名称以匹配后端API
    const apiData = {
      name: supplierData.name,
      code: supplierData.code,
      type: supplierData.type,
      contact_person: supplierData.contactPerson,
      contact_phone: supplierData.contactPhone,
      email: supplierData.email,
      address: supplierData.address,
      city: supplierData.city,
      rating: supplierData.rating,
      qualification: supplierData.qualification,
      payment_terms: supplierData.paymentTerms,
      delivery_terms: supplierData.deliveryTerms,
      status: supplierData.status,
      note: supplierData.note
    }

    console.log('发送到后端的供应商数据:', apiData)
    return api.post('/api/suppliers', apiData)
  },

  // 更新供应商
  updateSupplier(id, supplierData) {
    // 转换字段名称以匹配后端API
    const apiData = {
      name: supplierData.name,
      code: supplierData.code,
      type: supplierData.type,
      contact_person: supplierData.contactPerson,
      contact_phone: supplierData.contactPhone,
      email: supplierData.email,
      address: supplierData.address,
      city: supplierData.city,
      rating: supplierData.rating,
      qualification: supplierData.qualification,
      payment_terms: supplierData.paymentTerms,
      delivery_terms: supplierData.deliveryTerms,
      status: supplierData.status,
      note: supplierData.note
    }

    console.log('更新供应商数据:', apiData)
    return api.put(`/api/suppliers/${id}`, apiData)
  },

  // 删除供应商
  deleteSupplier(id) {
    return api.delete(`/api/suppliers/${id}`)
  }
}
