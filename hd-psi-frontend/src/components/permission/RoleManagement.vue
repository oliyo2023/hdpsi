<template>
  <div class="role-management">
    <n-card title="角色管理">
      <n-space vertical>
        <n-button type="primary" @click="showMessage">
          添加角色
        </n-button>
        
        <n-data-table
          :columns="columns"
          :data="roles"
          :loading="loading"
          :pagination="pagination"
          :bordered="false"
          striped
        />
      </n-space>
    </n-card>
  </div>
</template>

<script setup>
import { ref, reactive, h } from 'vue'
import { NCard, NButton, NDataTable, NSpace, useMessage } from 'naive-ui'

const message = useMessage()
const loading = ref(false)
const roles = ref([
  { role: 'admin', description: '系统管理员，拥有所有权限' },
  { role: 'manager', description: '店长，管理店铺的日常运营' },
  { role: 'staff', description: '普通员工，处理日常业务' }
])

// 表格分页
const pagination = reactive({
  page: 1,
  pageSize: 10,
  showSizePicker: true,
  pageSizes: [10, 20, 30, 50]
})

// 表格列定义
const columns = [
  {
    title: '角色名称',
    key: 'role',
    width: 200
  },
  {
    title: '描述',
    key: 'description'
  },
  {
    title: '操作',
    key: 'actions',
    width: 150,
    render(row) {
      return h(
        NButton,
        {
          size: 'small',
          type: 'primary',
          onClick: () => showMessage(row.role)
        },
        { default: () => '编辑' }
      )
    }
  }
]

const showMessage = (role) => {
  message.success(`这是一个简化版的角色管理组件，用于测试。${role ? `点击了角色: ${role}` : ''}`)
}
</script>

<style scoped>
.role-management {
  padding: 16px;
}
</style>
