import api from '@/services/api'

/**
 * 获取所有角色
 * @returns {Promise} 返回角色列表
 */
export function fetchRoles() {
  return api({
    url: '/api/v1/permissions/roles',
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
  return api({
    url: '/api/v1/permissions/roles',
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
  // 使用特殊用户名 'role_delete' 来表示这是一个角色删除操作
  return api({
    url: '/api/v1/permissions/roles',
    method: 'delete',
    data: {
      user: 'role_delete',
      role
    }
  })
}

/**
 * 获取所有策略
 * @returns {Promise} 返回策略列表
 */
export function fetchPolicies() {
  return api({
    url: '/api/v1/permissions/policies',
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
  return api({
    url: '/api/v1/permissions/policies',
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
  return api({
    url: '/api/v1/permissions/policies',
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
  return api({
    url: `/api/v1/v1/permissions/roles/${role}`,
    method: 'get'
  })
}

/**
 * 获取用户列表
 * @returns {Promise} 返回用户列表
 */
export function fetchUsers() {
  return api({
    url: '/api/v1/users',
    method: 'get'
  })
}

/**
 * 获取用户的角色
 * @param {string} username 用户名
 * @returns {Promise} 返回用户角色列表
 */
export function getUserRoles(username) {
  return api({
    url: `/api/v1/v1/permissions/users/${username}/roles`,
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
  return api({
    url: '/api/v1/permissions/roles',
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
  return api({
    url: '/api/v1/permissions/roles',
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
  return api({
    url: '/api/v1/permissions/check',
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
  return api({
    url: '/api/v1/permissions/audit-logs',
    method: 'get',
    params
  })
}
