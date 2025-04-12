import api from './api'

// 字典服务
export default {
  // 获取字典类型列表
  getDictionaries() {
    return api.get('/api/dictionaries')
  },
  
  // 获取字典类型详情
  getDictionary(code) {
    return api.get(`/api/dictionaries/${code}`)
  },
  
  // 创建字典类型
  createDictionary(data) {
    return api.post('/api/dictionaries', data)
  },
  
  // 更新字典类型
  updateDictionary(code, data) {
    return api.put(`/api/dictionaries/${code}`, data)
  },
  
  // 删除字典类型
  deleteDictionary(code) {
    return api.delete(`/api/dictionaries/${code}`)
  },
  
  // 获取字典项列表
  getDictionaryItems(code) {
    return api.get(`/api/dictionaries/${code}/items`)
  },
  
  // 获取字典项详情
  getDictionaryItem(code, itemId) {
    return api.get(`/api/dictionaries/${code}/items/${itemId}`)
  },
  
  // 创建字典项
  createDictionaryItem(code, data) {
    return api.post(`/api/dictionaries/${code}/items`, data)
  },
  
  // 更新字典项
  updateDictionaryItem(code, itemId, data) {
    return api.put(`/api/dictionaries/${code}/items/${itemId}`, data)
  },
  
  // 删除字典项
  deleteDictionaryItem(code, itemId) {
    return api.delete(`/api/dictionaries/${code}/items/${itemId}`)
  }
}
