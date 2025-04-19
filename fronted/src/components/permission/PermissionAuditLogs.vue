<template>
  <div class="permission-audit-logs">
    <n-card title="权限审计日志" class="mb-4">
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
          <n-form-item label="操作类型">
            <n-select
              v-model:value="filterAction"
              :options="actionOptions"
              placeholder="选择操作类型"
              clearable
              @update:value="handleFilterChange"
            />
          </n-form-item>
          <n-form-item label="资源类型">
            <n-select
              v-model:value="filterResource"
              :options="resourceOptions"
              placeholder="选择资源类型"
              clearable
              @update:value="handleFilterChange"
            />
          </n-form-item>
          <n-form-item label="时间范围">
            <n-date-picker
              v-model:value="dateRange"
              type="daterange"
              clearable
              @update:value="handleFilterChange"
            />
          </n-form-item>
          <n-form-item>
            <n-button type="primary" @click="loadAuditLogs">
              <template #icon>
                <n-icon>
                  <SearchOutline />
                </n-icon>
              </template>
              查询
            </n-button>
          </n-form-item>
        </n-form>

        <n-data-table
          :columns="columns"
          :data="auditLogs"
          :loading="loading"
          :pagination="pagination"
          :bordered="false"
          striped
        />
      </n-space>
    </n-card>

    <!-- 日志详情对话框 -->
    <n-modal v-model:show="showLogDetailModal" preset="card" title="日志详情" style="width: 600px">
      <template #header>
        <div>日志详情 - {{ formatTime(currentLog?.created_at) }}</div>
      </template>

      <n-descriptions bordered>
        <n-descriptions-item label="用户ID">{{ currentLog?.user_id }}</n-descriptions-item>
        <n-descriptions-item label="用户名">{{ currentLog?.username }}</n-descriptions-item>
        <n-descriptions-item label="操作类型">{{ getActionName(currentLog?.action) }}</n-descriptions-item>
        <n-descriptions-item label="资源类型">{{ currentLog?.resource }}</n-descriptions-item>
        <n-descriptions-item label="IP地址">{{ currentLog?.ip }}</n-descriptions-item>
        <n-descriptions-item label="用户代理">{{ currentLog?.user_agent }}</n-descriptions-item>
        <n-descriptions-item label="店铺ID">{{ currentLog?.store_id }}</n-descriptions-item>
        <n-descriptions-item label="操作结果">
          <n-tag :type="currentLog?.success ? 'success' : 'error'">
            {{ currentLog?.success ? '成功' : '失败' }}
          </n-tag>
        </n-descriptions-item>
        <n-descriptions-item label="详细信息" span="3">
          <n-code :code="formatDetails(currentLog?.details)" language="json" />
        </n-descriptions-item>
      </n-descriptions>

      <template #footer>
        <n-space justify="end">
          <n-button @click="showLogDetailModal = false">关闭</n-button>
        </n-space>
      </template>
    </n-modal>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, h } from 'vue'
import { NCard, NButton, NDataTable, NModal, NForm, NFormItem, NInput, NSelect, NSpace, NIcon, NDatePicker, NDescriptions, NDescriptionsItem, NTag, NCode, useMessage } from 'naive-ui'
import { SearchOutline, EyeOutline } from '@vicons/ionicons5'
import { fetchAuditLogs } from '@/api/permission'

const message = useMessage()
const loading = ref(false)
const auditLogs = ref([])
const showLogDetailModal = ref(false)
const currentLog = ref(null)

// 过滤条件
const filterUsername = ref('')
const filterAction = ref(null)
const filterResource = ref(null)
const dateRange = ref(null)

// 表格分页
const pagination = reactive({
  page: 1,
  pageSize: 10,
  itemCount: 0,
  showSizePicker: true,
  pageSizes: [10, 20, 30, 50],
  onChange: (page) => {
    pagination.page = page
    loadAuditLogs()
  },
  onUpdatePageSize: (pageSize) => {
    pagination.pageSize = pageSize
    pagination.page = 1
    loadAuditLogs()
  }
})

// 操作类型选项
const actionOptions = [
  { label: '添加策略', value: 'add_policy' },
  { label: '删除策略', value: 'remove_policy' },
  { label: '添加角色', value: 'add_role' },
  { label: '删除角色', value: 'remove_role' },
  { label: '为用户添加角色', value: 'add_role_for_user' },
  { label: '删除用户的角色', value: 'remove_role_for_user' },
  { label: '权限检查', value: 'enforce_policy' }
]

// 资源类型选项
const resourceOptions = [
  { label: '策略', value: 'policy' },
  { label: '角色', value: 'role' },
  { label: '用户角色', value: 'user_role' },
  { label: '权限检查', value: 'permission_check' }
]

// 表格列定义
const columns = [
  {
    title: 'ID',
    key: 'id',
    width: 80
  },
  {
    title: '用户名',
    key: 'username',
    width: 120
  },
  {
    title: '操作类型',
    key: 'action',
    width: 150,
    render(row) {
      return getActionName(row.action)
    }
  },
  {
    title: '资源类型',
    key: 'resource',
    width: 120
  },
  {
    title: '操作结果',
    key: 'success',
    width: 100,
    render(row) {
      return h(
        NTag,
        {
          type: row.success ? 'success' : 'error',
          size: 'small'
        },
        { default: () => row.success ? '成功' : '失败' }
      )
    }
  },
  {
    title: '操作时间',
    key: 'created_at',
    width: 180,
    render(row) {
      return formatTime(row.created_at)
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
          onClick: () => handleViewLogDetail(row)
        },
        {
          default: () => h(NIcon, null, { default: () => h(EyeOutline) }),
        }
      )
    }
  }
]

// 获取审计日志
const loadAuditLogs = async () => {
  loading.value = true
  try {
    const params = {
      page: pagination.page,
      page_size: pagination.pageSize
    }

    if (filterUsername.value) {
      params.username = filterUsername.value
    }

    if (filterAction.value) {
      params.action = filterAction.value
    }

    if (filterResource.value) {
      params.resource = filterResource.value
    }

    if (dateRange.value && dateRange.value.length === 2) {
      params.start_date = formatDate(dateRange.value[0])
      params.end_date = formatDate(dateRange.value[1])
    }

    console.log('查询审计日志参数:', params)
    const res = await fetchAuditLogs(params)
    console.log('获取审计日志响应:', res)

    if (res.data && res.data.logs) {
      auditLogs.value = res.data.logs
      pagination.itemCount = res.data.total || res.data.logs.length
    } else {
      message.error('获取审计日志数据格式不正确')
      console.error('审计日志数据格式不正确:', res)
      auditLogs.value = []
      pagination.itemCount = 0
    }
  } catch (error) {
    message.error('获取审计日志失败')
    console.error('获取审计日志错误:', error)
    auditLogs.value = []
    pagination.itemCount = 0
  } finally {
    loading.value = false
  }
}

// 查看日志详情
const handleViewLogDetail = (log) => {
  console.log('查看日志详情:', log)
  currentLog.value = log
  showLogDetailModal.value = true
}

// 处理过滤条件变化
const handleFilterChange = () => {
  pagination.page = 1
}

// 格式化时间
const formatTime = (timestamp) => {
  if (!timestamp) return ''
  const date = new Date(timestamp)
  return date.toLocaleString()
}

// 格式化日期
const formatDate = (date) => {
  if (!date) return ''
  const d = new Date(date)
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
}

// 格式化详情
const formatDetails = (details) => {
  if (!details) return '{}'
  try {
    const obj = JSON.parse(details)
    return JSON.stringify(obj, null, 2)
  } catch (error) {
    return details
  }
}

// 获取操作类型名称
const getActionName = (action) => {
  const names = {
    add_policy: '添加策略',
    remove_policy: '删除策略',
    add_role: '添加角色',
    remove_role: '删除角色',
    add_role_for_user: '为用户添加角色',
    remove_role_for_user: '删除用户的角色',
    enforce_policy: '权限检查'
  }
  return names[action] || action
}

onMounted(() => {
  loadAuditLogs()
})
</script>

<style scoped>
.mb-4 {
  margin-bottom: 16px;
}
</style>
