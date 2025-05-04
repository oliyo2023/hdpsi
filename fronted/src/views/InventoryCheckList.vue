<template>
  <div class="inventory-check-list">
    <div class="page-header">
      <h1 class="page-title">库存盘点</h1>
      <n-button type="primary" @click="handleCreateCheck">
        创建盘点单
      </n-button>
    </div>
    
    <div class="page-content">
      <!-- 搜索工具栏 -->
      <div class="table-toolbar">
        <div class="table-search">
          <n-select
            v-model:value="searchForm.storeId"
            placeholder="店铺"
            clearable
            :options="storeOptions"
            style="width: 150px"
          />
          <n-select
            v-model:value="searchForm.status"
            placeholder="状态"
            clearable
            :options="statusOptions"
            style="width: 150px"
          />
          <n-select
            v-model:value="searchForm.checkType"
            placeholder="盘点类型"
            clearable
            :options="checkTypeOptions"
            style="width: 150px"
          />
          <n-button type="primary" @click="handleSearch">
            查询
          </n-button>
          <n-button @click="resetSearch">
            重置
          </n-button>
        </div>
      </div>
      
      <!-- 盘点单表格 -->
      <n-data-table
        ref="tableRef"
        :columns="columns"
        :data="checks"
        :loading="loading"
        :pagination="pagination"
        :row-key="row => row.ID"
        @update:page="handlePageChange"
        @update:page-size="handlePageSizeChange"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, h } from 'vue'
import { useRouter } from 'vue-router'
import { 
  NButton, NDataTable, NSelect, NTag, NSpace, NPopconfirm
} from 'naive-ui'
import { useMessage } from 'naive-ui'
import inventoryCheckService from '../services/inventory_check_service'

const router = useRouter()
const message = useMessage()

// 响应式状态
const loading = ref(false)
const checks = ref([])
const pagination = reactive({
  page: 1,
  pageSize: 10,
  itemCount: 0,
  pageSizes: [10, 20, 50, 100],
  showSizePicker: true,
  prefix({ itemCount }) {
    return `共 ${itemCount} 条`
  }
})

// 搜索表单
const searchForm = reactive({
  storeId: null,
  status: null,
  checkType: null
})

// 店铺选项
const storeOptions = [
  { label: '总店', value: 1 },
  { label: '分店1', value: 2 },
  { label: '分店2', value: 3 }
]

// 状态选项
const statusOptions = [
  { label: '计划中', value: 'planned' },
  { label: '进行中', value: 'in_process' },
  { label: '已完成', value: 'completed' },
  { label: '已取消', value: 'cancelled' }
]

// 盘点类型选项
const checkTypeOptions = [
  { label: '全盘', value: 'full_check' },
  { label: '抽盘', value: 'spot_check' }
]

// 表格列定义
const columns = [
  {
    title: 'ID',
    key: 'ID',
    width: 80
  },
  {
    title: '盘点单号',
    key: 'CheckCode',
    width: 150
  },
  {
    title: '店铺',
    key: 'StoreID',
    width: 100,
    render(row) {
      const store = storeOptions.find(item => item.value === row.StoreID)
      return store ? store.label : row.StoreID
    }
  },
  {
    title: '盘点类型',
    key: 'CheckType',
    width: 100,
    render(row) {
      return row.CheckType === 'full_check' ? '全盘' : '抽盘'
    }
  },
  {
    title: '状态',
    key: 'Status',
    width: 100,
    render(row) {
      let type = 'default'
      let text = row.Status
      
      switch (row.Status) {
        case 'planned':
          type = 'info'
          text = '计划中'
          break
        case 'in_process':
          type = 'warning'
          text = '进行中'
          break
        case 'completed':
          type = 'success'
          text = '已完成'
          break
        case 'cancelled':
          type = 'error'
          text = '已取消'
          break
      }
      
      return h(NTag, { type }, { default: () => text })
    }
  },
  {
    title: '计划日期',
    key: 'PlanDate',
    width: 150,
    render(row) {
      return new Date(row.PlanDate).toLocaleDateString()
    }
  },
  {
    title: '创建时间',
    key: 'CreatedAt',
    width: 150,
    render(row) {
      return new Date(row.CreatedAt).toLocaleString()
    }
  },
  {
    title: '操作',
    key: 'actions',
    width: 250,
    fixed: 'right',
    render(row) {
      return h(NSpace, {}, {
        default: () => [
          h(NButton, {
            size: 'small',
            onClick: () => handleViewCheck(row)
          }, { default: () => '查看' }),
          
          // 根据状态显示不同的操作按钮
          row.Status === 'planned' ? h(NButton, {
            size: 'small',
            type: 'primary',
            onClick: () => handleStartCheck(row)
          }, { default: () => '开始盘点' }) : null,
          
          row.Status === 'in_process' ? h(NButton, {
            size: 'small',
            type: 'success',
            onClick: () => handleCompleteCheck(row)
          }, { default: () => '完成盘点' }) : null,
          
          (row.Status === 'planned' || row.Status === 'in_process') ? h(NPopconfirm, {
            onPositiveClick: () => handleCancelCheck(row)
          }, {
            default: () => '确定取消该盘点单吗？',
            trigger: () => h(NButton, {
              size: 'small',
              type: 'error'
            }, { default: () => '取消盘点' })
          }) : null
        ].filter(Boolean)
      })
    }
  }
]

// 生命周期钩子
onMounted(() => {
  loadChecks()
})

// 加载盘点单列表
const loadChecks = async () => {
  loading.value = true
  try {
    // 构建查询参数
    const params = {}
    if (searchForm.storeId) params.store_id = searchForm.storeId
    if (searchForm.status) params.status = searchForm.status
    if (searchForm.checkType) params.check_type = searchForm.checkType
    
    const response = await inventoryCheckService.getChecks(params)
    checks.value = response.data
    pagination.itemCount = checks.value.length
  } catch (error) {
    console.error('加载盘点单列表失败:', error)
    message.error('加载盘点单列表失败')
  } finally {
    loading.value = false
  }
}

// 搜索处理
const handleSearch = () => {
  pagination.page = 1
  loadChecks()
}

// 重置搜索
const resetSearch = () => {
  searchForm.storeId = null
  searchForm.status = null
  searchForm.checkType = null
  pagination.page = 1
  loadChecks()
}

// 分页处理
const handlePageChange = (page) => {
  pagination.page = page
  loadChecks()
}

const handlePageSizeChange = (pageSize) => {
  pagination.pageSize = pageSize
  pagination.page = 1
  loadChecks()
}

// 创建盘点单
const handleCreateCheck = () => {
  router.push('/inventory-checks/create')
}

// 查看盘点单
const handleViewCheck = (row) => {
  router.push(`/inventory-checks/${row.ID}`)
}

// 开始盘点
const handleStartCheck = async (row) => {
  try {
    await inventoryCheckService.startCheck(row.ID)
    message.success('盘点已开始')
    loadChecks()
  } catch (error) {
    console.error('开始盘点失败:', error)
    message.error('开始盘点失败')
  }
}

// 完成盘点
const handleCompleteCheck = async (row) => {
  try {
    await inventoryCheckService.completeCheck(row.ID)
    message.success('盘点已完成')
    loadChecks()
  } catch (error) {
    console.error('完成盘点失败:', error)
    if (error.response && error.response.data && error.response.data.error) {
      message.error(`完成盘点失败: ${error.response.data.error}`)
    } else {
      message.error('完成盘点失败')
    }
  }
}

// 取消盘点
const handleCancelCheck = async (row) => {
  try {
    await inventoryCheckService.cancelCheck(row.ID)
    message.success('盘点已取消')
    loadChecks()
  } catch (error) {
    console.error('取消盘点失败:', error)
    message.error('取消盘点失败')
  }
}
</script>

<style scoped>
.inventory-check-list {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.page-title {
  margin: 0;
  font-size: 24px;
}

.table-toolbar {
  margin-bottom: 20px;
  display: flex;
  justify-content: space-between;
}

.table-search {
  display: flex;
  gap: 10px;
}
</style>
