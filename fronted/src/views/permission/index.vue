<template>
  <div class="permission-management">
    <div class="page-header">
      <h1>权限管理</h1>
      <p>管理系统角色和权限</p>
    </div>

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
        <audit-log-management />
      </n-tab-pane>
    </n-tabs>
  </div>
</template>

<script setup>
import { NTabs, NTabPane } from 'naive-ui'
import RoleManagement from '@/components/permission/RoleManagement.vue'
import PolicyManagement from '@/components/permission/PolicyManagement.vue'
import UserRoleManagement from '@/components/permission/UserRoleManagement.vue'
import AuditLogManagement from '@/components/permission/AuditLogManagement.vue'
</script>

<style scoped>
.permission-management {
  padding: 16px;
}

.page-header {
  margin-bottom: 24px;
}

.page-header h1 {
  font-size: 24px;
  margin: 0 0 8px 0;
}

.page-header p {
  margin: 0;
  color: rgba(0, 0, 0, 0.45);
}
</style>
