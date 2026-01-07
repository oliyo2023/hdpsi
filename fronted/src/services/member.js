import api from './api'

// 会员服务
export default {
  // 获取会员列表
  getMembers(params = {}) {
    return api.get('/api/v1/members', { params })
  },
  
  // 获取单个会员
  getMember(id) {
    return api.get(`/api/v1/members/${id}`)
  },
  
  // 创建会员
  createMember(memberData) {
    return api.post('/api/v1/members', memberData)
  },
  
  // 更新会员
  updateMember(id, memberData) {
    return api.put(`/api/v1/members/${id}`, memberData)
  },
  
  // 删除会员
  deleteMember(id) {
    return api.delete(`/api/v1/members/${id}`)
  },

  // 获取会员积分
  getMemberPoints(id) {
    return api.get(`/api/v1/members/${id}/points`)
  },

  // 获取会员积分交易记录
  getMemberPointsTransactions(id, params = {}) {
    return api.get(`/api/v1/members/${id}/points/transactions`, { params })
  },

  // 添加会员积分
  addMemberPoints(id, pointsData) {
    return api.post(`/api/v1/members/${id}/points/add`, pointsData)
  },

  // 扣减会员积分
  deductMemberPoints(id, pointsData) {
    return api.post(`/api/v1/members/${id}/points/deduct`, pointsData)
  },

  // 计算会员等级
  calculateMemberLevel(id) {
    return api.post(`/api/v1/members/${id}/level/calculate`)
  }
}
