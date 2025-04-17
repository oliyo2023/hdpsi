<template>
  <div class="audit-log-management">
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

    <!-- 查看详情对话框 -->
    <n-modal v-model:show="showDetailsModal" preset="card" title="审计日志详情" style="width: 600px">
      <n-descriptions bordered :column="1" label-placement="left">
        <n-descriptions-item label="ID">{{ selectedLog?.id }}</n-descriptions-item>
        <n-descriptions-item label="用户">{{ selectedLog?.username }}</n-descriptions-item>
        <n-descriptions-item label="操作">{{ getActionName(selectedLog?.action) }}</n-descriptions-item>
        <n-descriptions-item label="资源">{{ getResourceName(selectedLog?.resource) }}</n-descriptions-item>
        <n-descriptions-item label="IP地址">{{ selectedLog?.ip }}</n-descriptions-item>
        <n-descriptions-item label="用户代理">{{ selectedLog?.user_agent }}</n-descriptions-item>
        <n-descriptions-item label="店铺ID">{{ selectedLog?.store_id }}</n-descriptions-item>
        <n-descriptions-item label="状态">
          <n-tag :type="selectedLog?.success ? 'success' : 'error'">
            {{ selectedLog?.success ? '成功' : '失败' }}
          </n-tag>
        </n-descriptions-item>
        <n-descriptions-item label="时间">{{ formatDateTime(selectedLog?.created_at) }}</n-descriptions-item>
        <n-descriptions-item label="详情">
          <n-code :code="formatDetails(selectedLog?.details)" language="json" />
        </n-descriptions-item>
      </n-descriptions>

      <template #footer>
        <n-space justify="end">
          <n-button @click="showDetailsModal = false">关闭</n-button>
        </n-space>
      </template>
    </n-modal>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, h } from 'vue'
import { NCard, NButton, NDataTable, NModal, NForm, NFormItem, NInput, NSelect, NSpace, NIcon, NDescriptions, NDescriptionsItem, NTag, NCode, useMessage } from 'naive-ui'
import { SearchOutline, EyeOutline } from '@vicons/ionicons5'
import { fetchAuditLogs } from '@/api/permission'

const message = useMessage()
const loading = ref(false)
const auditLogs = ref([])
const showDetailsModal = ref(false)
const selectedLog = ref(null)

// 过滤条件
const filterUsername = ref('')
const filterAction = ref(null)
const filterResource = ref(null)

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
  { label: '添加用户角色', value: 'add_role_for_user' },
  { label: '删除用户角色', value: 'remove_role_for_user' },
  { label: '检查权限', value: 'enforce_policy' }
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
    title: '用户',
    key: 'username',
    width: 120
  },
  {
    title: '操作',
    key: 'action',
    width: 150,
    render(row) {
      return getActionName(row.action)
    }
  },
  {
    title: '资源',
    key: 'resource',
    width: 120,
    render(row) {
      return getResourceName(row.resource)
    }
  },
  {
    title: '状态',
    key: 'success',
    width: 80,
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
    title: '时间',
    key: 'created_at',
    width: 180,
    render(row) {
      return formatDateTime(row.created_at)
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
          onClick: () => handleViewDetails(row)
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

    const res = await fetchAuditLogs(params)
    console.log('获取审计日志响应:', res)

    // 处理不同的响应格式
    if (res.logs) {
      auditLogs.value = res.logs
      pagination.itemCount = res.total || 0
    } else if (res.data && res.data.logs) {
      auditLogs.value = res.data.logs
      pagination.itemCount = res.data.total || 0
    } else {
      message.error('获取审计日志数据格式不正确')
      console.error('审计日志数据格式不正确:', res)
    }
  } catch (error) {
    message.error('获取审计日志失败')
    console.error('获取审计日志错误:', error)
  } finally {
    loading.value = false
  }
}

// 查看详情
const handleViewDetails = (log) => {
  selectedLog.value = log
  showDetailsModal.value = true
}

// 处理过滤条件变化
const handleFilterChange = () => {
  pagination.page = 1
}

// 获取操作名称
const getActionName = (action) => {
  const names = {
    add_policy: '添加策略',
    remove_policy: '删除策略',
    add_role: '添加角色',
    remove_role: '删除角色',
    add_role_for_user: '添加用户角色',
    remove_role_for_user: '删除用户角色',
    enforce_policy: '检查权限'
  }
  return names[action] || action
}

// 获取资源名称
const getResourceName = (resource) => {
  const names = {
    policy: '策略',
    role: '角色',
    user_role: '用户角色',
    permission_check: '权限检查'
  }
  return names[resource] || resource
}

// 格式化日期时间
const formatDateTime = (dateTime) => {
  if (!dateTime) return ''
  const date = new Date(dateTime)
  return date.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit'
  })
}

// 格式化详情
const formatDetails = (details) => {
  if (!details) return '{}'
  try {
    const obj = typeof details === 'string' ? JSON.parse(details) : details
    return JSON.stringify(obj, null, 2)
  } catch (error) {
    return details
  }
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
