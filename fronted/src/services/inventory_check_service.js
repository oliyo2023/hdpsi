import axios from 'axios'
import { API_URL } from '../config'

/**
 * 库存盘点服务
 */
const InventoryCheckService = {
  /**
   * 获取盘点单列表
   * @param {Object} params 查询参数
   * @returns {Promise} 盘点单列表
   */
  getChecks(params = {}) {
    return axios.get(`${API_URL}/api/v1/inventory-checks`, { params })
  },

  /**
   * 获取盘点单详情
   * @param {number} id 盘点单ID
   * @returns {Promise} 盘点单详情
   */
  getCheck(id) {
    return axios.get(`${API_URL}/api/v1/inventory-checks/${id}`)
  },

  /**
   * 创建盘点单
   * @param {Object} data 盘点单数据
   * @returns {Promise} 创建结果
   */
  createCheck(data) {
    return axios.post(`${API_URL}/api/v1/inventory-checks`, data)
  },

  /**
   * 开始盘点
   * @param {number} id 盘点单ID
   * @returns {Promise} 操作结果
   */
  startCheck(id) {
    return axios.put(`${API_URL}/api/v1/inventory-checks/${id}/start`)
  },

  /**
   * 完成盘点
   * @param {number} id 盘点单ID
   * @returns {Promise} 操作结果
   */
  completeCheck(id) {
    return axios.put(`${API_URL}/api/v1/inventory-checks/${id}/complete`)
  },

  /**
   * 取消盘点
   * @param {number} id 盘点单ID
   * @returns {Promise} 操作结果
   */
  cancelCheck(id) {
    return axios.put(`${API_URL}/api/v1/inventory-checks/${id}/cancel`)
  },

  /**
   * 更新盘点明细
   * @param {number} checkId 盘点单ID
   * @param {number} itemId 盘点明细ID
   * @param {Object} data 更新数据
   * @returns {Promise} 操作结果
   */
  updateCheckItem(checkId, itemId, data) {
    return axios.put(`${API_URL}/api/v1/inventory-checks/${checkId}/items/${itemId}`, data)
  },

  /**
   * 创建库存调整
   * @param {number} checkId 盘点单ID
   * @param {Object} data 调整数据
   * @returns {Promise} 操作结果
   */
  createAdjustment(checkId, data) {
    return axios.post(`${API_URL}/api/v1/inventory-checks/${checkId}/adjustments`, data)
  },

  /**
   * 审批库存调整
   * @param {number} adjustmentId 调整记录ID
   * @param {Object} data 审批数据
   * @returns {Promise} 操作结果
   */
  approveAdjustment(adjustmentId, data) {
    return axios.put(`${API_URL}/api/v1/inventory-checks/adjustments/${adjustmentId}/approve`, data)
  }
}

export default InventoryCheckService
