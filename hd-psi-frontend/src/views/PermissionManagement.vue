<template>
  <div class="permission-management">
    <div class="page-header">
      <h1>权限管理</h1>
      <p>管理系统角色和权限</p>
    </div>

    <div class="page-content">
      <n-tabs type="line" animated>
        <n-tab-pane name="roles" tab="角色管理">
          <role-management />
        </n-tab-pane>
        <n-tab-pane name="policies" tab="权限策略">
          <policy-management />
        </n-tab-pane>
        <n-tab-pane name="user-roles" tab="用户角色分配">
          <user-role-management />
        </n-tab-pane>
        <n-tab-pane name="audit-logs" tab="权限审计日志">
          <permission-audit-logs />
        </n-tab-pane>
      </n-tabs>
    </div>
  </div>
</template>

<script setup>
import { defineAsyncComponent } from 'vue'
import { NTabs, NTabPane } from 'naive-ui'

// 使用动态导入以避免找不到组件的问题
const RoleManagement = defineAsyncComponent(() =>
  import('@/components/permission/RoleManagement.vue')
)

const PolicyManagement = defineAsyncComponent(() =>
  import('@/components/permission/PolicyManagement.vue')
)

const UserRoleManagement = defineAsyncComponent(() =>
  import('@/components/permission/UserRoleManagement.vue')
)

const PermissionAuditLogs = defineAsyncComponent(() =>
  import('@/components/permission/PermissionAuditLogs.vue')
)
</script>

<style scoped>
.permission-management {
  padding: 16px;
  background-color: #f5f7fa;
  min-height: calc(100vh - 64px);
}

.page-header {
  margin-bottom: 16px;
}

.page-header h1 {
  margin: 0;
  font-size: 24px;
  font-weight: 600;
}

.page-header p {
  margin: 4px 0 0;
  color: #606266;
}

.page-content {
  background-color: #fff;
  border-radius: 4px;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
  padding: 16px;
}

.placeholder {
  padding: 40px;
  text-align: center;
  color: #909399;
  font-size: 16px;
}
</style>
