import { request } from './api'

// 获取退换货列表
export const getReturnList = (params) => {
  return request({
    url: '/api/returns',
    method: 'get',
    params
  })
}

// 获取退换货详情
export const getReturnDetail = (id) => {
  return request({
    url: `/api/returns/${id}`,
    method: 'get'
  })
}

// 创建退换货申请
export const createReturn = (data) => {
  return request({
    url: '/api/returns',
    method: 'post',
    data
  })
}

// 更新退换货状态
export const updateReturnStatus = (id, data) => {
  return request({
    url: `/api/returns/${id}/status`,
    method: 'put',
    data
  })
}

// 获取订单详情（用于退换货申请）
export const getOrderDetail = (orderNo) => {
  return request({
    url: `/api/orders/${orderNo}`,
    method: 'get'
  })
}

// 上传退换货凭证
export const uploadReturnAttachment = (data) => {
  return request({
    url: '/api/returns/attachments',
    method: 'post',
    data,
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}

// 获取退换货统计数据
export const getReturnStatistics = (params) => {
  return request({
    url: '/api/returns/statistics',
    method: 'get',
    params
  })
}

// 获取退换货原因选项
export const getReturnReasons = () => {
  return request({
    url: '/api/returns/reasons',
    method: 'get'
  })
}

// 添加处理记录
export const addProcessingRecord = (returnId, data) => {
  return request({
    url: `/api/returns/${returnId}/records`,
    method: 'post',
    data
  })
}

// 获取处理记录列表
export const getProcessingRecords = (returnId) => {
  return request({
    url: `/api/returns/${returnId}/records`,
    method: 'get'
  })
}