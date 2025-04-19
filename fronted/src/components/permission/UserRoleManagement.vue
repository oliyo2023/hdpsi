<template>
  <div class="user-role-management">
    <n-card title="用户角色分配" class="mb-4">
      <n-space vertical>
        <n-form inline :label-width="80">
          <n-form-item label="用户名">
            <n-input
              v-model:value="filterUsername"
              placeholder="输入用户名"
              clearable
              @update:value="handleFilterChange"
            />
          </n-form-item>
          <n-form-item label="角色">
            <n-select
              v-model:value="filterRole"
              :options="roleOptions"
              placeholder="选择角色"
              clearable
              @update:value="handleFilterChange"
            />
          </n-form-item>
        </n-form>

        <n-data-table
          :columns="columns"
          :data="filteredUsers"
          :loading="loading"
          :pagination="pagination"
          :bordered="false"
          striped
        />
      </n-space>
    </n-card>

    <!-- 编辑用户角色对话框 -->
    <n-modal v-model:show="showEditRolesModal" preset="card" title="编辑用户角色" style="width: 500px">
      <template #header>
        <div>编辑用户角色 - {{ currentUser?.username }}</div>
      </template>

      <n-transfer
        v-model:value="selectedRoles"
        :options="allRoleOptions"
        source-title="可用角色"
        target-title="已分配角色"
      />

      <template #footer>
        <n-space justify="end">
          <n-button @click="showEditRolesModal = false">取消</n-button>
          <n-button type="primary" @click="handleSaveUserRoles" :loading="submitting">保存</n-button>
        </n-space>
      </template>
    </n-modal>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, h } from 'vue'
import { NCard, NButton, NDataTable, NModal, NForm, NFormItem, NInput, NSelect, NSpace, NIcon, NTransfer, useMessage } from 'naive-ui'
import { PencilOutline } from '@vicons/ionicons5'
import { fetchRoles, getUserRoles, addRoleForUser, deleteRoleForUser } from '@/api/permission'
import { fetchUsers } from '@/api/user'

const message = useMessage()
const loading = ref(false)
const submitting = ref(false)
const users = ref([])
const roles = ref([])
const showEditRolesModal = ref(false)
const currentUser = ref(null)
const selectedRoles = ref([])
const userRoles = ref({}) // 用户角色映射

// 过滤条件
const filterUsername = ref('')
const filterRole = ref(null)

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

// 角色选项
const roleOptions = computed(() => {
  return roles.value.map(role => ({
    label: role,
    value: role
  }))
})

// 所有角色选项（用于Transfer组件）
const allRoleOptions = computed(() => {
  return roles.value.map(role => ({
    label: role,
    value: role,
    disabled: false
  }))
})

// 过滤后的用户
const filteredUsers = computed(() => {
  let result = users.value

  if (filterUsername.value) {
    result = result.filter(user => user.username.includes(filterUsername.value))
  }

  if (filterRole.value) {
    result = result.filter(user => {
      const userRoleList = userRoles.value[user.id] || []
      return userRoleList.includes(filterRole.value)
    })
  }

  return result
})

// 表格列定义
const columns = [
  {
    title: '用户ID',
    key: 'id',
    width: 80
  },
  {
    title: '用户名',
    key: 'username',
    width: 150
  },
  {
    title: '姓名',
    key: 'name',
    width: 120
  },
  {
    title: '角色',
    key: 'roles',
    render(row) {
      const userRoleList = userRoles.value[row.id] || []
      return h('div', {}, userRoleList.map(role => {
        return h(
          'n-tag',
          {
            style: {
              marginRight: '4px'
            },
            type: getTagType(role),
            size: 'small'
          },
          { default: () => role }
        )
      }))
    }
  },
  {
    title: '操作',
    key: 'actions',
    width: 100,
    render(row) {
      return h(
        NButton,
        {
          size: 'small',
          quaternary: true,
          type: 'info',
          onClick: () => handleEditUserRoles(row)
        },
        {
          default: () => h(NIcon, null, { default: () => h(PencilOutline) }),
        }
      )
    }
  }
]

// 获取用户列表
const loadUsers = async () => {
  loading.value = true
  try {
    const res = await fetchUsers()
    console.log('获取用户列表响应:', res)

    // 处理不同的响应格式
    if (res.users) {
      users.value = res.users

      // 获取每个用户的角色
      for (const user of users.value) {
        await loadUserRoles(user)
      }
    } else if (res.data && res.data.users) {
      users.value = res.data.users

      // 获取每个用户的角色
      for (const user of users.value) {
        await loadUserRoles(user)
      }
    } else {
      message.error('获取用户列表数据格式不正确')
      console.error('用户列表数据格式不正确:', res)
    }
  } catch (error) {
    message.error('获取用户列表失败')
    console.error('获取用户列表错误:', error)
  } finally {
    loading.value = false
  }
}

// 获取角色列表
const loadRoles = async () => {
  try {
    const res = await fetchRoles()
    console.log('获取角色列表响应:', res)

    // 处理不同的响应格式
    if (res.roles) {
      roles.value = res.roles.map(role => {
        if (typeof role === 'object' && role.role) {
          return role.role
        }
        return role
      })
    } else if (res.data && res.data.roles) {
      roles.value = res.data.roles.map(role => {
        if (typeof role === 'object' && role.role) {
          return role.role
        }
        return role
      })
    } else {
      message.error('获取角色列表数据格式不正确')
      console.error('角色列表数据格式不正确:', res)
    }
  } catch (error) {
    message.error('获取角色列表失败')
    console.error('获取角色列表错误:', error)
  }
}

// 获取用户角色
const loadUserRoles = async (user) => {
  try {
    const res = await getUserRoles(user.username)
    console.log(`获取用户 ${user.username} 的角色响应:`, res)

    // 处理不同的响应格式
    if (res.roles) {
      userRoles.value[user.id] = res.roles.map(role => {
        if (typeof role === 'object' && role.role) {
          return role.role
        }
        return role
      })
    } else if (res.data && res.data.roles) {
      userRoles.value[user.id] = res.data.roles.map(role => {
        if (typeof role === 'object' && role.role) {
          return role.role
        }
        return role
      })
    } else {
      console.error(`获取用户 ${user.username} 的角色数据格式不正确:`, res)
      userRoles.value[user.id] = []
    }
  } catch (error) {
    console.error(`获取用户 ${user.username} 的角色失败`, error)
    userRoles.value[user.id] = []
  }
}

// 编辑用户角色
const handleEditUserRoles = (user) => {
  currentUser.value = user
  selectedRoles.value = userRoles.value[user.id] || []
  showEditRolesModal.value = true
}

// 保存用户角色
const handleSaveUserRoles = async () => {
  if (!currentUser.value) return

  submitting.value = true
  try {
    const oldRoles = userRoles.value[currentUser.value.id] || []
    const newRoles = selectedRoles.value

    console.log('当前用户:', currentUser.value)
    console.log('原有角色:', oldRoles)
    console.log('新角色:', newRoles)

    // 找出需要添加的角色
    const rolesToAdd = newRoles.filter(role => !oldRoles.includes(role))

    // 找出需要删除的角色
    const rolesToRemove = oldRoles.filter(role => !newRoles.includes(role))

    console.log('需要添加的角色:', rolesToAdd)
    console.log('需要删除的角色:', rolesToRemove)

    // 添加角色
    for (const role of rolesToAdd) {
      const res = await addRoleForUser(currentUser.value.username, role)
      console.log(`为用户 ${currentUser.value.username} 添加角色 ${role} 响应:`, res)
    }

    // 删除角色
    for (const role of rolesToRemove) {
      const res = await deleteRoleForUser(currentUser.value.username, role)
      console.log(`删除用户 ${currentUser.value.username} 的角色 ${role} 响应:`, res)
    }

    message.success('保存用户角色成功')
    showEditRolesModal.value = false

    // 更新用户角色
    await loadUserRoles(currentUser.value)
  } catch (error) {
    message.error('保存用户角色失败')
    console.error('保存用户角色错误:', error)
  } finally {
    submitting.value = false
  }
}

// 处理过滤条件变化
const handleFilterChange = () => {
  pagination.page = 1
}

// 获取标签类型
const getTagType = (role) => {
  const types = {
    admin: 'error',
    manager: 'warning',
    staff: 'info',
    cashier: 'success',
    operator: 'default'
  }
  return types[role] || 'default'
}

onMounted(() => {
  loadUsers()
  loadRoles()
})
</script>

<style scoped>
.mb-4 {
  margin-bottom: 16px;
}
</style>
