<template>
  <div class="sales-order-list">
    <div class="page-header">
      <h1 class="page-title">销售订单管理</h1>
      <n-button type="primary" @click="handleCreateOrder">
        <template #icon>
          <n-icon><AddOutline /></n-icon>
        </template>
        新建订单
      </n-button>
    </div>

    <!-- 搜索筛选 -->
    <n-card class="search-card">
      <n-form
        ref="searchFormRef"
        :model="searchForm"
        label-placement="left"
        :label-width="80"
        class="search-form"
      >
        <n-grid :cols="24" :x-gap="16">
          <n-form-item-gi :span="6" label="订单号">
            <n-input
              v-model:value="searchForm.order_number"
              placeholder="请输入订单号"
              clearable
            />
          </n-form-item-gi>
          <n-form-item-gi :span="6" label="客户姓名">
            <n-input
              v-model:value="searchForm.customer_name"
              placeholder="请输入客户姓名"
              clearable
            />
          </n-form-item-gi>
          <n-form-item-gi :span="6" label="订单状态">
            <n-select
              v-model:value="searchForm.status"
              placeholder="请选择订单状态"
              :options="statusOptions"
              clearable
            />
          </n-form-item-gi>
          <n-form-item-gi :span="6" label="订单类型">
            <n-select
              v-model:value="searchForm.order_type"
              placeholder="请选择订单类型"
              :options="orderTypeOptions"
              clearable
            />
          </n-form-item-gi>
          <n-form-item-gi :span="6" label="销售店铺">
            <n-select
              v-model:value="searchForm.store_id"
              placeholder="请选择店铺"
              :options="storeOptions"
              clearable
            />
          </n-form-item-gi>
          <n-form-item-gi :span="6" label="下单日期">
            <n-date-picker
              v-model:value="searchForm.start_date"
              type="date"
              placeholder="开始日期"
              clearable
            />
          </n-form-item-gi>
          <n-form-item-gi :span="6" label="至">
            <n-date-picker
              v-model:value="searchForm.end_date"
              type="date"
              placeholder="结束日期"
              clearable
            />
          </n-form-item-gi>
          <n-form-item-gi :span="6">
            <n-space>
              <n-button type="primary" @click="handleSearch">
                <template #icon>
                  <n-icon><SearchOutline /></n-icon>
                </template>
                搜索
              </n-button>
              <n-button @click="handleReset">
                <template #icon>
                  <n-icon><RefreshOutline /></n-icon>
                </template>
                重置
              </n-button>
            </n-space>
          </n-form-item-gi>
        </n-grid>
      </n-form>
    </n-card>

    <!-- 统计卡片 -->
    <n-grid :cols="24" :x-gap="16" class="stats-grid">
      <n-gi :span="6">
        <n-card>
          <n-statistic label="今日订单" :value="statistics.todayOrders" />
        </n-card>
      </n-gi>
      <n-gi :span="6">
        <n-card>
          <n-statistic label="今日销售额" :value="statistics.todayAmount" :precision="2" />
        </n-card>
      </n-gi>
      <n-gi :span="6">
        <n-card>
          <n-statistic label="总订单数" :value="statistics.totalOrders" />
        </n-card>
      </n-gi>
      <n-gi :span="6">
        <n-card>
          <n-statistic label="总销售额" :value="statistics.totalAmount" :precision="2" />
        </n-card>
      </n-gi>
    </n-grid>

    <!-- 订单列表 -->
    <n-card class="table-card">
      <n-data-table
        ref="tableRef"
        :columns="columns"
        :data="salesOrders"
        :loading="loading"
        :pagination="pagination"
        :row-key="row => row.id"
        @update:page="handlePageChange"
        @update:page-size="handlePageSizeChange"
      />
    </n-card>

    <!-- 状态更新对话框 -->
    <n-modal v-model:show="showStatusModal" preset="dialog" title="更新订单状态">
      <n-form ref="statusFormRef" :model="statusForm" :rules="statusRules">
        <n-form-item label="新状态" path="status">
          <n-select
            v-model:value="statusForm.status"
            placeholder="请选择新状态"
            :options="statusOptions"
          />
        </n-form-item>
        <n-form-item label="备注" path="note">
          <n-input
            v-model:value="statusForm.note"
            type="textarea"
            placeholder="请输入备注"
            :rows="3"
          />
        </n-form-item>
      </n-form>
      <template #action>
        <n-space>
          <n-button @click="showStatusModal = false">取消</n-button>
          <n-button type="primary" @click="handleConfirmStatusUpdate">确认</n-button>
        </n-space>
      </template>
    </n-modal>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, h } from 'vue'
import { useRouter } from 'vue-router'
import { useMessage } from 'naive-ui'
import {
  AddOutline,
  SearchOutline,
  RefreshOutline,
  EyeOutline,
  CreateOutline,
  TrashOutline
} from '@vicons/ionicons5'
import salesOrderService from '../services/salesOrderService'
import storeService from '../services/storeService'

const router = useRouter()
const message = useMessage()

// 响应式数据
const loading = ref(false)
const salesOrders = ref([])
const statistics = ref({
  todayOrders: 0,
  todayAmount: 0,
  totalOrders: 0,
  totalAmount: 0
})

// 搜索表单
const searchForm = reactive({
  order_number: '',
  customer_name: '',
  status: null,
  order_type: null,
  store_id: null,
  start_date: null,
  end_date: null
})

// 分页
const pagination = reactive({
  page: 1,
  pageSize: 10,
  itemCount: 0,
  showSizePicker: true,
  pageSizes: [10, 20, 50, 100]
})

// 状态更新
const showStatusModal = ref(false)
const currentOrderId = ref(null)
const statusForm = reactive({
  status: '',
  note: ''
})

const statusRules = {
  status: [
    { required: true, message: '请选择状态', trigger: 'change' }
  ]
}

// 选项数据
const statusOptions = ref([])
const orderTypeOptions = ref([])
const storeOptions = ref([])

// 表格列定义
const columns = [
  {
    title: '订单号',
    key: 'orderNumber',
    width: 150,
    ellipsis: {
      tooltip: true
    }
  },
  {
    title: '客户姓名',
    key: 'customerName',
    width: 120
  },
  {
    title: '订单类型',
    key: 'orderType',
    width: 100,
    render(row) {
      return salesOrderService.formatOrderType(row.orderType)
    }
  },
  {
    title: '订单状态',
    key: 'status',
    width: 100,
    render(row) {
      const statusOption = statusOptions.value.find(opt => opt.value === row.status)
      return h('n-tag', {
        type: statusOption?.type || 'default'
      }, {
        default: () => salesOrderService.formatStatus(row.status)
      })
    }
  },
  {
    title: '订单金额',
    key: 'totalAmount',
    width: 120,
    render(row) {
      return `¥${row.totalAmount.toFixed(2)}`
    }
  },
  {
    title: '已付金额',
    key: 'paidAmount',
    width: 120,
    render(row) {
      return `¥${row.paidAmount.toFixed(2)}`
    }
  },
  {
    title: '支付状态',
    key: 'paymentStatus',
    width: 100,
    render(row) {
      const paymentStatusOptions = salesOrderService.getPaymentStatusOptions()
      const statusOption = paymentStatusOptions.find(opt => opt.value === row.paymentStatus)
      return h('n-tag', {
        type: statusOption?.type || 'default'
      }, {
        default: () => salesOrderService.formatPaymentStatus(row.paymentStatus)
      })
    }
  },
  {
    title: '下单时间',
    key: 'orderDate',
    width: 160,
    render(row) {
      return new Date(row.orderDate).toLocaleString()
    }
  },
  {
    title: '销售员',
    key: 'salesperson',
    width: 100,
    render(row) {
      return row.salesperson?.name || '-'
    }
  },
  {
    title: '操作',
    key: 'actions',
    width: 200,
    fixed: 'right',
    render(row) {
      return h('n-space', {}, {
        default: () => [
          h('n-button', {
            size: 'small',
            onClick: () => handleViewOrder(row.id)
          }, {
            default: () => '查看',
            icon: () => h('n-icon', {}, { default: () => h(EyeOutline) })
          }),
          h('n-button', {
            size: 'small',
            type: 'primary',
            onClick: () => handleEditOrder(row.id),
            disabled: !['draft', 'pending'].includes(row.status)
          }, {
            default: () => '编辑',
            icon: () => h('n-icon', {}, { default: () => h(CreateOutline) })
          }),
          h('n-button', {
            size: 'small',
            type: 'warning',
            onClick: () => handleUpdateStatus(row.id)
          }, {
            default: () => '状态'
          }),
          h('n-button', {
            size: 'small',
            type: 'error',
            onClick: () => handleDeleteOrder(row.id),
            disabled: !['draft', 'cancelled'].includes(row.status)
          }, {
            default: () => '删除',
            icon: () => h('n-icon', {}, { default: () => h(TrashOutline) })
          })
        ]
      })
    }
  }
]

// 生命周期
onMounted(() => {
  initializeData()
})

// 初始化数据
const initializeData = async () => {
  await Promise.all([
    loadStatusOptions(),
    loadOrderTypeOptions(),
    loadStoreOptions(),
    loadSalesOrders(),
    loadStatistics()
  ])
}

// 加载状态选项
const loadStatusOptions = () => {
  statusOptions.value = salesOrderService.getStatusOptions()
}

// 加载订单类型选项
const loadOrderTypeOptions = () => {
  orderTypeOptions.value = salesOrderService.getOrderTypeOptions()
}

// 加载店铺选项
const loadStoreOptions = async () => {
  try {
    const response = await storeService.getStores()
    storeOptions.value = response.map(store => ({
      label: store.name,
      value: store.id
    }))
  } catch (error) {
    console.error('加载店铺选项失败:', error)
  }
}

// 加载销售订单列表
const loadSalesOrders = async () => {
  loading.value = true
  try {
    const params = {
      ...searchForm,
      page: pagination.page,
      page_size: pagination.pageSize
    }
    
    // 处理日期格式
    if (params.start_date) {
      params.start_date = new Date(params.start_date).toISOString().split('T')[0]
    }
    if (params.end_date) {
      params.end_date = new Date(params.end_date).toISOString().split('T')[0]
    }

    const response = await salesOrderService.getSalesOrders(params)
    salesOrders.value = response.items
    pagination.itemCount = response.total
  } catch (error) {
    console.error('加载销售订单列表失败:', error)
    message.error('加载销售订单列表失败')
  } finally {
    loading.value = false
  }
}

// 加载统计数据
const loadStatistics = async () => {
  try {
    const response = await salesOrderService.getSalesStatistics()
    statistics.value = response
  } catch (error) {
    console.error('加载统计数据失败:', error)
  }
}

// 事件处理
const handleSearch = () => {
  pagination.page = 1
  loadSalesOrders()
}

const handleReset = () => {
  Object.keys(searchForm).forEach(key => {
    searchForm[key] = key.includes('date') ? null : ''
  })
  pagination.page = 1
  loadSalesOrders()
}

const handlePageChange = (page) => {
  pagination.page = page
  loadSalesOrders()
}

const handlePageSizeChange = (pageSize) => {
  pagination.pageSize = pageSize
  pagination.page = 1
  loadSalesOrders()
}

const handleCreateOrder = () => {
  router.push('/sales/create')
}

const handleViewOrder = (id) => {
  router.push(`/sales/${id}`)
}

const handleEditOrder = (id) => {
  router.push(`/sales/${id}/edit`)
}

const handleUpdateStatus = (id) => {
  currentOrderId.value = id
  statusForm.status = ''
  statusForm.note = ''
  showStatusModal.value = true
}

const handleConfirmStatusUpdate = async () => {
  try {
    await salesOrderService.updateSalesOrderStatus(
      currentOrderId.value,
      statusForm.status,
      statusForm.note
    )
    message.success('订单状态更新成功')
    showStatusModal.value = false
    loadSalesOrders()
    loadStatistics()
  } catch (error) {
    console.error('更新订单状态失败:', error)
    message.error('更新订单状态失败')
  }
}

const handleDeleteOrder = (id) => {
  window.$dialog.warning({
    title: '确认删除',
    content: '确定要删除这个销售订单吗？此操作不可恢复。',
    positiveText: '确定',
    negativeText: '取消',
    onPositiveClick: async () => {
      try {
        await salesOrderService.deleteSalesOrder(id)
        message.success('销售订单删除成功')
        loadSalesOrders()
        loadStatistics()
      } catch (error) {
        console.error('删除销售订单失败:', error)
        message.error('删除销售订单失败')
      }
    }
  })
}
</script>

<style scoped>
.sales-order-list {
  padding: 16px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.page-title {
  margin: 0;
  font-size: 24px;
  font-weight: 600;
}

.search-card {
  margin-bottom: 16px;
}

.search-form {
  margin-bottom: 0;
}

.stats-grid {
  margin-bottom: 16px;
}

.table-card {
  margin-bottom: 16px;
}
</style>
