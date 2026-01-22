import api from './api'
import { convertBackendFields, convertFrontendFields } from '../utils/fieldConverter'

// 字典服务
export default {
  // 获取字典类型列表
  async getDictionaries() {
    const response = await api.get('/api/v1/dictionaries')
    return convertBackendFields(response)
  },

  // 获取字典类型详情
  async getDictionary(code) {
    const response = await api.get(`/api/v1/dictionaries/${code}`)
    return convertBackendFields(response)
  },

  // 创建字典类型
  async createDictionary(data) {
    const response = await api.post('/api/v1/dictionaries', convertFrontendFields(data))
    return convertBackendFields(response)
  },

  // 更新字典类型
  async updateDictionary(code, data) {
    const response = await api.put(`/api/v1/dictionaries/${code}`, convertFrontendFields(data))
    return convertBackendFields(response)
  },

  // 删除字典类型
  async deleteDictionary(code) {
    const response = await api.delete(`/api/v1/dictionaries/${code}`)
    return convertBackendFields(response)
  },

  // 获取字典项列表
  async getDictionaryItems(code) {
    const response = await api.get(`/api/v1/dictionaries/${code}/items`)
    return convertBackendFields(response)
  },

  // 获取字典项详情
  async getDictionaryItem(code, itemId) {
    const response = await api.get(`/api/v1/dictionaries/${code}/items/${itemId}`)
    return convertBackendFields(response)
  },

  // 创建字典项
  async createDictionaryItem(code, data) {
    const response = await api.post(`/api/v1/dictionaries/${code}/items`, convertFrontendFields(data))
    return convertBackendFields(response)
  },

  // 更新字典项
  async updateDictionaryItem(code, itemId, data) {
    const response = await api.put(`/api/v1/dictionaries/${code}/items/${itemId}`, convertFrontendFields(data))
    return convertBackendFields(response)
  },

  // 删除字典项
  async deleteDictionaryItem(code, itemId) {
    const response = await api.delete(`/api/v1/dictionaries/${code}/items/${itemId}`)
    return convertBackendFields(response)
  }
}
