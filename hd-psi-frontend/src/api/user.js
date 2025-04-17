import api from '@/services/api'

/**
 * 获取用户列表
 * @returns {Promise} 返回用户列表
 */
export function fetchUsers() {
  return api({
    url: '/api/users',
    method: 'get'
  })
}

/**
 * 获取用户详情
 * @param {number} id 用户ID
 * @returns {Promise} 返回用户详情
 */
export function fetchUserDetail(id) {
  return api({
    url: `/api/users/${id}`,
    method: 'get'
  })
}

/**
 * 更新用户信息
 * @param {number} id 用户ID
 * @param {Object} data 用户信息
 * @returns {Promise} 返回更新结果
 */
export function updateUser(id, data) {
  return api({
    url: `/api/users/${id}`,
    method: 'put',
    data
  })
}

/**
 * 更新用户密码
 * @param {Object} data 密码信息
 * @returns {Promise} 返回更新结果
 */
export function updatePassword(data) {
  return api({
    url: '/api/users/password',
    method: 'put',
    data
  })
}

/**
 * 创建用户
 * @param {Object} data 用户信息
 * @returns {Promise} 返回创建结果
 */
export function createUser(data) {
  return api({
    url: '/api/users',
    method: 'post',
    data
  })
}

/**
 * 删除用户
 * @param {number} id 用户ID
 * @returns {Promise} 返回删除结果
 */
export function deleteUser(id) {
  return api({
    url: `/api/users/${id}`,
    method: 'delete'
  })
}
