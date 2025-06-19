import axios from 'axios'
import { API_URL } from '../config'

const API_BASE = `${API_URL}api/v1/stores`

class StoreService {
  // 获取店铺列表
  async getStores(params = {}) {
    try {
      const response = await axios.get(API_BASE, { params })
      return response.data
    } catch (error) {
      console.error('获取店铺列表失败:', error)
      throw error
    }
  }

  // 获取店铺详情
  async getStore(id) {
    try {
      const response = await axios.get(`${API_BASE}/${id}`)
      return response.data
    } catch (error) {
      console.error('获取店铺详情失败:', error)
      throw error
    }
  }

  // 创建店铺
  async createStore(data) {
    try {
      const response = await axios.post(API_BASE, data)
      return response.data
    } catch (error) {
      console.error('创建店铺失败:', error)
      throw error
    }
  }

  // 更新店铺
  async updateStore(id, data) {
    try {
      const response = await axios.put(`${API_BASE}/${id}`, data)
      return response.data
    } catch (error) {
      console.error('更新店铺失败:', error)
      throw error
    }
  }

  // 删除店铺
  async deleteStore(id) {
    try {
      const response = await axios.delete(`${API_BASE}/${id}`)
      return response.data
    } catch (error) {
      console.error('删除店铺失败:', error)
      throw error
    }
  }

  // 获取店铺统计信息
  async getStoreStatistics(id) {
    try {
      const response = await axios.get(`${API_BASE}/${id}/statistics`)
      return response.data
    } catch (error) {
      console.error('获取店铺统计失败:', error)
      throw error
    }
  }

  // 获取店铺类型选项
  getStoreTypeOptions() {
    return [
      { label: '男装店', value: 'mens' },
      { label: '女装店', value: 'womens' },
      { label: '综合店', value: 'mixed' }
    ]
  }

  // 获取店铺状态选项
  getStoreStatusOptions() {
    return [
      { label: '营业中', value: 'active', type: 'success' },
      { label: '暂停营业', value: 'inactive', type: 'warning' },
      { label: '装修中', value: 'renovation', type: 'info' },
      { label: '已关闭', value: 'closed', type: 'error' }
    ]
  }

  // 格式化店铺类型
  formatStoreType(type) {
    const typeMap = {
      'mens': '男装店',
      'womens': '女装店',
      'mixed': '综合店'
    }
    return typeMap[type] || type
  }

  // 格式化店铺状态
  formatStoreStatus(status) {
    const statusMap = {
      'active': '营业中',
      'inactive': '暂停营业',
      'renovation': '装修中',
      'closed': '已关闭'
    }
    return statusMap[status] || status
  }

  // 验证店铺数据
  validateStoreData(storeData) {
    const errors = []

    if (!storeData.name?.trim()) {
      errors.push('店铺名称不能为空')
    }

    if (!storeData.type) {
      errors.push('请选择店铺类型')
    }

    if (!storeData.address?.trim()) {
      errors.push('店铺地址不能为空')
    }

    if (storeData.phone && !/^1[3-9]\d{9}$/.test(storeData.phone)) {
      errors.push('请输入正确的手机号码')
    }

    return errors
  }

  // 生成店铺摘要
  generateStoreSummary(store) {
    return {
      id: store.id,
      name: store.name,
      type: this.formatStoreType(store.type),
      status: this.formatStoreStatus(store.status),
      address: store.address,
      phone: store.phone,
      manager: store.manager,
      createdAt: store.createdAt
    }
  }
}

export default new StoreService()
