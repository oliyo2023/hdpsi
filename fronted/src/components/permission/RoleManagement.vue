<template>
  <div class="role-management">
    <n-card title="角色管理" class="mb-4">
      <template #header-extra>
        <n-button type="primary" @click="showAddRoleModal = true">
          <template #icon>
            <n-icon>
              <AddOutline />
            </n-icon>
          </template>
          添加角色
        </n-button>
      </template>

      <n-data-table
        :columns="columns"
        :data="roles"
        :loading="loading"
        :pagination="pagination"
        :bordered="false"
        striped
      />
    </n-card>

    <!-- 添加角色对话框 -->
    <n-modal v-model:show="showAddRoleModal" preset="card" title="添加角色" style="width: 500px">
      <n-form
        ref="addRoleFormRef"
        :model="addRoleForm"
        :rules="addRoleRules"
        label-placement="left"
        label-width="80"
        require-mark-placement="right-hanging"
      >
        <n-form-item label="角色名称" path="role">
          <n-input v-model:value="addRoleForm.role" placeholder="请输入角色名称" />
        </n-form-item>
        <n-form-item label="描述" path="description">
          <n-input v-model:value="addRoleForm.description" type="textarea" placeholder="请输入角色描述" />
        </n-form-item>
      </n-form>

      <template #footer>
        <n-space justify="end">
          <n-button @click="showAddRoleModal = false">取消</n-button>
          <n-button type="primary" @click="handleAddRole" :loading="submitting">确定</n-button>
        </n-space>
      </template>
    </n-modal>

    <!-- 删除角色确认对话框 -->
    <n-modal v-model:show="showDeleteConfirm" preset="dialog" title="确认删除" positive-text="确认" negative-text="取消" @positive-click="confirmDeleteRole" @negative-click="cancelDeleteRole">
      <template #icon>
        <n-icon color="warning">
          <WarningOutline />
        </n-icon>
      </template>
      <p>确定要删除角色 "{{ roleToDelete }}" 吗？此操作不可撤销，并且会移除所有与该角色相关的权限。</p>
    </n-modal>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, h } from 'vue'
import { NCard, NButton, NDataTable, NModal, NForm, NFormItem, NInput, NSpace, NIcon, useMessage, useDialog } from 'naive-ui'
import { AddOutline, TrashOutline, PencilOutline, WarningOutline } from '@vicons/ionicons5'
import { fetchRoles, addRole, deleteRole } from '@/api/permission'

const message = useMessage()
const dialog = useDialog()
const loading = ref(false)
const submitting = ref(false)
const roles = ref([])
const showAddRoleModal = ref(false)
const showDeleteConfirm = ref(false)
const roleToDelete = ref('')

// 表格分页
const pagination = reactive({
  page: 1,
  pageSize: 10,
  showSizePicker: true,
  pageSizes: [10, 20, 30, 50],
  onChange: (page) => {
    pagination.page = page
  },
  onUpdatePageSize: (pageSize) => {
    pagination.pageSize = pageSize
    pagination.page = 1
  }
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
      return h(NSpace, { justify: 'center' }, [
        h(
          NButton,
          {
            size: 'small',
            quaternary: true,
            type: 'info',
            onClick: () => handleEditRole(row)
          },
          {
            default: () => h(NIcon, null, { default: () => h(PencilOutline) }),
          }
        ),
        h(
          NButton,
          {
            size: 'small',
            quaternary: true,
            type: 'error',
            onClick: () => handleDeleteRole(row)
          },
          {
            default: () => h(NIcon, null, { default: () => h(TrashOutline) }),
          }
        )
      ])
    }
  }
]

// 添加角色表单
const addRoleFormRef = ref(null)
const addRoleForm = reactive({
  role: '',
  description: ''
})

// 表单验证规则
const addRoleRules = {
  role: [
    { required: true, message: '请输入角色名称', trigger: 'blur' },
    { pattern: /^[a-zA-Z0-9_]+$/, message: '角色名称只能包含字母、数字和下划线', trigger: 'blur' }
  ],
  description: [
    { required: true, message: '请输入角色描述', trigger: 'blur' }
  ]
}

// 获取角色列表
const loadRoles = async () => {
  loading.value = true
  try {
    const res = await fetchRoles()
    console.log('获取角色列表响应:', res)

    // 处理不同的响应格式
    if (res.roles) {
      // 直接使用res.roles
      roles.value = res.roles.map(role => {
        if (typeof role === 'object' && role.role) {
          return role
        }
        return {
          role: role,
          description: getRoleDescription(role)
        }
      })
    } else if (res.data && res.data.roles) {
      // 使用res.data.roles
      roles.value = res.data.roles.map(role => {
        if (typeof role === 'object' && role.role) {
          return role
        }
        return {
          role: role,
          description: getRoleDescription(role)
        }
      })
    } else {
      message.error('获取角色列表数据格式不正确')
      console.error('角色列表数据格式不正确:', res)
    }
  } catch (error) {
    message.error('获取角色列表失败')
    console.error('获取角色列表错误:', error)
  } finally {
    loading.value = false
  }
}

// 添加角色
const handleAddRole = async () => {
  addRoleFormRef.value?.validate(async (errors) => {
    if (!errors) {
      submitting.value = true
      try {
        const res = await addRole(addRoleForm.role, addRoleForm.description)
        console.log('添加角色响应:', res)
        message.success('添加角色成功')
        showAddRoleModal.value = false
        loadRoles()
        // 重置表单
        addRoleForm.role = ''
        addRoleForm.description = ''
      } catch (error) {
        message.error('添加角色失败')
        console.error('添加角色错误:', error)
      } finally {
        submitting.value = false
      }
    }
  })
}

// 删除角色
const handleDeleteRole = (row) => {
  roleToDelete.value = row.role
  showDeleteConfirm.value = true
}

// 确认删除角色
const confirmDeleteRole = async () => {
  if (!roleToDelete.value) return

  submitting.value = true
  try {
    const res = await deleteRole(roleToDelete.value)
    console.log('删除角色响应:', res)
    message.success('删除角色成功')
    loadRoles()
  } catch (error) {
    console.error('删除角色错误:', error)

    // 显示更详细的错误信息
    if (error.response && error.response.data && error.response.data.error) {
      message.error(`删除角色失败: ${error.response.data.error}`)
    } else if (error.message) {
      message.error(`删除角色失败: ${error.message}`)
    } else {
      message.error('删除角色失败')
    }
  } finally {
    submitting.value = false
    roleToDelete.value = ''
    showDeleteConfirm.value = false
  }
}

// 取消删除角色
const cancelDeleteRole = () => {
  roleToDelete.value = ''
}

// 编辑角色
const handleEditRole = (row) => {
  dialog.warning({
    title: '编辑角色',
    content: `暂不支持编辑角色 "${row.role}"，请删除后重新添加。`,
    positiveText: '确定'
  })
}

// 获取角色描述
const getRoleDescription = (role) => {
  const descriptions = {
    admin: '系统管理员，拥有所有权限',
    manager: '店长，管理店铺的日常运营',
    staff: '普通员工，处理日常业务',
    cashier: '收银员，负责销售和收款',
    operator: '操作员，负责库存和采购'
  }
  return descriptions[role] || '未知角色'
}

onMounted(() => {
  loadRoles()
})
</script>

<style scoped>
.mb-4 {
  margin-bottom: 16px;
}
</style>
