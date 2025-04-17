import request from '@/utils/request'

/**
 * 获取所有角色
 * @returns {Promise} 返回角色列表
 */
export function fetchRoles() {
  return request({
    url: '/api/permissions/roles',
    method: 'get'
  })
}

/**
 * 添加角色
 * @param {string} role 角色名称
 * @param {string} description 角色描述
 * @returns {Promise} 返回添加结果
 */
export function addRole(role, description) {
  return request({
    url: '/api/permissions/roles',
    method: 'post',
    data: {
      role,
      description
    }
  })
}

/**
 * 删除角色
 * @param {string} role 角色名称
 * @returns {Promise} 返回删除结果
 */
export function deleteRole(role) {
  return request({
    url: '/api/permissions/roles',
    method: 'delete',
    data: {
      role
    }
  })
}

/**
 * 获取所有策略
 * @returns {Promise} 返回策略列表
 */
export function fetchPolicies() {
  return request({
    url: '/api/permissions/policies',
    method: 'get'
  })
}

/**
 * 添加策略
 * @param {string} role 角色名称
 * @param {string} path 资源路径
 * @param {string} method 操作方法
 * @returns {Promise} 返回添加结果
 */
export function addPolicy(role, path, method) {
  return request({
    url: '/api/permissions/policies',
    method: 'post',
    data: {
      role,
      path,
      method
    }
  })
}

/**
 * 删除策略
 * @param {string} role 角色名称
 * @param {string} path 资源路径
 * @param {string} method 操作方法
 * @returns {Promise} 返回删除结果
 */
export function removePolicy(role, path, method) {
  return request({
    url: '/api/permissions/policies',
    method: 'delete',
    data: {
      role,
      path,
      method
    }
  })
}

/**
 * 获取角色的权限
 * @param {string} role 角色名称
 * @returns {Promise} 返回角色权限列表
 */
export function getRolePermissions(role) {
  return request({
    url: `/api/permissions/roles/${role}`,
    method: 'get'
  })
}

/**
 * 获取用户列表
 * @returns {Promise} 返回用户列表
 */
export function fetchUsers() {
  return request({
    url: '/api/users',
    method: 'get'
  })
}

/**
 * 获取用户的角色
 * @param {string} username 用户名
 * @returns {Promise} 返回用户角色列表
 */
export function getUserRoles(username) {
  return request({
    url: `/api/permissions/users/${username}/roles`,
    method: 'get'
  })
}

/**
 * 为用户添加角色
 * @param {string} username 用户名
 * @param {string} role 角色名称
 * @returns {Promise} 返回添加结果
 */
export function addRoleForUser(username, role) {
  return request({
    url: '/api/permissions/roles',
    method: 'post',
    data: {
      user: username,
      role
    }
  })
}

/**
 * 删除用户的角色
 * @param {string} username 用户名
 * @param {string} role 角色名称
 * @returns {Promise} 返回删除结果
 */
export function deleteRoleForUser(username, role) {
  return request({
    url: '/api/permissions/roles',
    method: 'delete',
    data: {
      user: username,
      role
    }
  })
}

/**
 * 检查权限
 * @param {string} role 角色名称
 * @param {string} path 资源路径
 * @param {string} method 操作方法
 * @returns {Promise} 返回检查结果
 */
export function checkPermission(role, path, method) {
  return request({
    url: '/api/permissions/check',
    method: 'post',
    data: {
      role,
      path,
      method
    }
  })
}

/**
 * 获取权限审计日志
 * @param {Object} params 查询参数
 * @returns {Promise} 返回审计日志列表
 */
export function fetchAuditLogs(params) {
  return request({
    url: '/api/permissions/audit-logs',
    method: 'get',
    params
  })
}
