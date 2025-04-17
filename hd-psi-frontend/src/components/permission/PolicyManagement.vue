<template>
  <div class="policy-management">
    <n-card title="权限策略管理" class="mb-4">
      <template #header-extra>
        <n-button type="primary" @click="showAddPolicyModal = true">
          <template #icon>
            <n-icon>
              <AddOutline />
            </n-icon>
          </template>
          添加策略
        </n-button>
      </template>

      <n-space vertical>
        <n-form inline :label-width="80">
          <n-form-item label="角色">
            <n-select
              v-model:value="filterRole"
              :options="roleOptions"
              placeholder="选择角色"
              clearable
              @update:value="handleFilterChange"
            />
          </n-form-item>
          <n-form-item label="资源路径">
            <n-input
              v-model:value="filterPath"
              placeholder="输入资源路径"
              clearable
              @update:value="handleFilterChange"
            />
          </n-form-item>
          <n-form-item label="操作方法">
            <n-select
              v-model:value="filterMethod"
              :options="methodOptions"
              placeholder="选择方法"
              clearable
              @update:value="handleFilterChange"
            />
          </n-form-item>
        </n-form>

        <n-data-table
          :columns="columns"
          :data="filteredPolicies"
          :loading="loading"
          :pagination="pagination"
          :bordered="false"
          striped
        />
      </n-space>
    </n-card>

    <!-- 添加策略对话框 -->
    <n-modal v-model:show="showAddPolicyModal" preset="card" title="添加权限策略" style="width: 500px">
      <n-form
        ref="addPolicyFormRef"
        :model="addPolicyForm"
        :rules="addPolicyRules"
        label-placement="left"
        label-width="80"
        require-mark-placement="right-hanging"
      >
        <n-form-item label="角色" path="role">
          <n-select
            v-model:value="addPolicyForm.role"
            :options="roleOptions"
            placeholder="请选择角色"
          />
        </n-form-item>
        <n-form-item label="资源路径" path="path">
          <n-input v-model:value="addPolicyForm.path" placeholder="请输入资源路径，例如 /api/products/*" />
        </n-form-item>
        <n-form-item label="操作方法" path="method">
          <n-select
            v-model:value="addPolicyForm.method"
            :options="methodOptions"
            placeholder="请选择操作方法"
          />
        </n-form-item>
      </n-form>

      <template #footer>
        <n-space justify="end">
          <n-button @click="showAddPolicyModal = false">取消</n-button>
          <n-button type="primary" @click="handleAddPolicy" :loading="submitting">确定</n-button>
        </n-space>
      </template>
    </n-modal>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, h } from 'vue'
import { NCard, NButton, NDataTable, NModal, NForm, NFormItem, NInput, NSelect, NSpace, NIcon, useMessage } from 'naive-ui'
import { AddOutline, TrashOutline } from '@vicons/ionicons5'
import { fetchPolicies, addPolicy, removePolicy, fetchRoles } from '@/api/permission'

const message = useMessage()
const loading = ref(false)
const submitting = ref(false)
const policies = ref([])
const roles = ref([])
const showAddPolicyModal = ref(false)

// 过滤条件
const filterRole = ref(null)
const filterPath = ref('')
const filterMethod = ref(null)

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

// 方法选项
const methodOptions = [
  { label: 'GET', value: 'GET' },
  { label: 'POST', value: 'POST' },
  { label: 'PUT', value: 'PUT' },
  { label: 'DELETE', value: 'DELETE' },
  { label: '所有方法', value: '*' }
]

// 过滤后的策略
const filteredPolicies = computed(() => {
  let result = policies.value

  if (filterRole.value) {
    result = result.filter(policy => policy.role === filterRole.value)
  }

  if (filterPath.value) {
    result = result.filter(policy => policy.path.includes(filterPath.value))
  }

  if (filterMethod.value) {
    result = result.filter(policy => policy.method === filterMethod.value)
  }

  return result
})

// 表格列定义
const columns = [
  {
    title: '角色',
    key: 'role',
    width: 150
  },
  {
    title: '资源路径',
    key: 'path',
    ellipsis: {
      tooltip: true
    }
  },
  {
    title: '操作方法',
    key: 'method',
    width: 120
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
          type: 'error',
          onClick: () => handleRemovePolicy(row)
        },
        {
          default: () => h(NIcon, null, { default: () => h(TrashOutline) }),
        }
      )
    }
  }
]

// 添加策略表单
const addPolicyFormRef = ref(null)
const addPolicyForm = reactive({
  role: null,
  path: '',
  method: null
})

// 表单验证规则
const addPolicyRules = {
  role: [
    { required: true, message: '请选择角色', trigger: 'blur' }
  ],
  path: [
    { required: true, message: '请输入资源路径', trigger: 'blur' }
  ],
  method: [
    { required: true, message: '请选择操作方法', trigger: 'blur' }
  ]
}

// 获取策略列表
const loadPolicies = async () => {
  loading.value = true
  try {
    const res = await fetchPolicies()
    policies.value = res.data.policies.map(policy => ({
      role: policy[0],
      path: policy[1],
      method: policy[2]
    }))
  } catch (error) {
    message.error('获取策略列表失败')
    console.error(error)
  } finally {
    loading.value = false
  }
}

// 获取角色列表
const loadRoles = async () => {
  try {
    const res = await fetchRoles()
    roles.value = res.data.roles
  } catch (error) {
    message.error('获取角色列表失败')
    console.error(error)
  }
}

// 添加策略
const handleAddPolicy = async () => {
  addPolicyFormRef.value?.validate(async (errors) => {
    if (!errors) {
      submitting.value = true
      try {
        await addPolicy(addPolicyForm.role, addPolicyForm.path, addPolicyForm.method)
        message.success('添加策略成功')
        showAddPolicyModal.value = false
        loadPolicies()
        // 重置表单
        addPolicyForm.role = null
        addPolicyForm.path = ''
        addPolicyForm.method = null
      } catch (error) {
        message.error('添加策略失败')
        console.error(error)
      } finally {
        submitting.value = false
      }
    }
  })
}

// 删除策略
const handleRemovePolicy = async (row) => {
  try {
    await removePolicy(row.role, row.path, row.method)
    message.success('删除策略成功')
    loadPolicies()
  } catch (error) {
    message.error('删除策略失败')
    console.error(error)
  }
}

// 处理过滤条件变化
const handleFilterChange = () => {
  pagination.page = 1
}

onMounted(() => {
  loadPolicies()
  loadRoles()
})
</script>

<style scoped>
.mb-4 {
  margin-bottom: 16px;
}
</style>
