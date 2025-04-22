<template>
  <div class="purchase-list">
    <div class="page-header">
      <h1 class="page-title">采购管理</h1>
      <n-button type="primary" @click="handleAddPurchase">
        创建采购单
      </n-button>
    </div>
    
    <div class="page-content">
      <!-- 搜索工具栏 -->
      <div class="table-toolbar">
        <div class="table-search">
          <n-select
            v-model:value="searchForm.status"
            placeholder="状态"
            clearable
            :options="statusOptions"
            style="width: 150px"
          />
          <n-select
            v-model:value="searchForm.supplierId"
            placeholder="供应商"
            clearable
            :options="supplierOptions"
            style="width: 200px"
          />
          <n-select
            v-model:value="searchForm.storeId"
            placeholder="店铺"
            clearable
            :options="storeOptions"
            style="width: 150px"
          />
          <n-date-picker
            v-model:value="searchForm.dateRange"
            type="daterange"
            clearable
            style="width: 240px"
          />
          <n-button type="primary" @click="handleSearch">
            查询
          </n-button>
          <n-button @click="resetSearch">
            重置
          </n-button>
        </div>
      </div>
      
      <!-- 采购单表格 -->
      <n-data-table
        ref="tableRef"
        :columns="columns"
        :data="purchases"
        :loading="loading"
        :pagination="pagination"
        :row-key="row => row.id"
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
  NButton, NDataTable, NSelect, NDatePicker, NSpace, NTag
} from 'naive-ui'

const router = useRouter()

// 响应式状态
const loading = ref(false)
const purchases = ref([])
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
  status: null,
  supplierId: null,
  storeId: null,
  dateRange: null
})

// 状态选项
const statusOptions = [
  { label: '草稿', value: 'draft' },
  { label: '待审核', value: 'pending' },
  { label: '已审核', value: 'approved' },
  { label: '已拒绝', value: 'rejected' },
  { label: '已下单', value: 'ordered' },
  { label: '待入库', value: 'receiving' },
  { label: '已完成', value: 'completed' },
  { label: '已取消', value: 'cancelled' }
]

// 供应商选项
const supplierOptions = [
  { label: '供应商A', value: 1 },
  { label: '供应商B', value: 2 },
  { label: '供应商C', value: 3 }
]

// 店铺选项
const storeOptions = [
  { label: '总店', value: 1 },
  { label: '分店1', value: 2 },
  { label: '分店2', value: 3 }
]

// 获取状态标签类型
const getStatusType = (status) => {
  const statusMap = {
    draft: 'default',
    pending: 'info',
    approved: 'success',
    rejected: 'error',
    ordered: 'warning',
    receiving: 'processing',
    completed: 'success',
    cancelled: 'error'
  }
  return statusMap[status] || 'default'
}

// 获取状态标签文本
const getStatusText = (status) => {
  const statusMap = {
    draft: '草稿',
    pending: '待审核',
    approved: '已审核',
    rejected: '已拒绝',
    ordered: '已下单',
    receiving: '待入库',
    completed: '已完成',
    cancelled: '已取消'
  }
  return statusMap[status] || '未知'
}

// 表格列定义
const columns = [
  {
    title: '采购单号',
    key: 'orderNumber',
    width: 150
  },
  {
    title: '供应商',
    key: 'supplierName',
    width: 150
  },
  {
    title: '店铺',
    key: 'storeName',
    width: 100
  },
  {
    title: '总金额',
    key: 'totalAmount',
    width: 120,
    render(row) {
      return `¥${row.totalAmount.toFixed(2)}`
    }
  },
  {
    title: '状态',
    key: 'status',
    width: 100,
    render(row) {
      return h(
        NTag,
        { type: getStatusType(row.status) },
        { default: () => getStatusText(row.status) }
      )
    }
  },
  {
    title: '预计到货日期',
    key: 'expectedDate',
    width: 120
  },
  {
    title: '创建时间',
    key: 'createdAt',
    width: 150
  },
  {
    title: '操作',
    key: 'actions',
    width: 250,
    fixed: 'right',
    render(row) {
      return h(NSpace, { justify: 'center' }, {
        default: () => [
          h(
            NButton,
            {
              size: 'small',
              onClick: () => handleView(row)
            },
            { default: () => '查看' }
          ),
          h(
            NButton,
            {
              size: 'small',
              type: 'primary',
              disabled: !['draft'].includes(row.status),
              onClick: () => handleEdit(row)
            },
            { default: () => '编辑' }
          ),
          h(
            NButton,
            {
              size: 'small',
              type: 'info',
              disabled: !['approved', 'ordered', 'receiving'].includes(row.status),
              onClick: () => handleReceiving(row)
            },
            { default: () => '入库' }
          ),
          h(
            NButton,
            {
              size: 'small',
              type: 'error',
              disabled: !['draft'].includes(row.status),
              onClick: () => handleDelete(row)
            },
            { default: () => '删除' }
          )
        ]
      })
    }
  }
]

// 方法
const loadPurchases = async () => {
  loading.value = true
  try {
    // 模拟数据，实际应该从API获取
    purchases.value = [
      {
        id: 1,
        orderNumber: 'PO20230501001',
        supplierId: 1,
        supplierName: '供应商A',
        storeId: 1,
        storeName: '总店',
        totalAmount: 5000.00,
        status: 'draft',
        expectedDate: '2023-05-10',
        createdAt: '2023-05-01 10:30:00'
      },
      {
        id: 2,
        orderNumber: 'PO20230502001',
        supplierId: 2,
        supplierName: '供应商B',
        storeId: 1,
        storeName: '总店',
        totalAmount: 3500.00,
        status: 'pending',
        expectedDate: '2023-05-12',
        createdAt: '2023-05-02 14:20:00'
      },
      {
        id: 3,
        orderNumber: 'PO20230503001',
        supplierId: 1,
        supplierName: '供应商A',
        storeId: 2,
        storeName: '分店1',
        totalAmount: 2800.00,
        status: 'approved',
        expectedDate: '2023-05-15',
        createdAt: '2023-05-03 09:15:00'
      },
      {
        id: 4,
        orderNumber: 'PO20230504001',
        supplierId: 3,
        supplierName: '供应商C',
        storeId: 1,
        storeName: '总店',
        totalAmount: 6200.00,
        status: 'ordered',
        expectedDate: '2023-05-20',
        createdAt: '2023-05-04 16:45:00'
      },
      {
        id: 5,
        orderNumber: 'PO20230505001',
        supplierId: 2,
        supplierName: '供应商B',
        storeId: 3,
        storeName: '分店2',
        totalAmount: 4100.00,
        status: 'completed',
        expectedDate: '2023-05-18',
        createdAt: '2023-05-05 11:30:00'
      }
    ]
    pagination.itemCount = purchases.value.length
  } catch (error) {
    console.error('加载采购单列表失败:', error)
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  pagination.page = 1
  loadPurchases()
}

const resetSearch = () => {
  searchForm.status = null
  searchForm.supplierId = null
  searchForm.storeId = null
  searchForm.dateRange = null
  pagination.page = 1
  loadPurchases()
}

const handlePageChange = (page) => {
  pagination.page = page
  loadPurchases()
}

const handlePageSizeChange = (pageSize) => {
  pagination.pageSize = pageSize
  pagination.page = 1
  loadPurchases()
}

const handleAddPurchase = () => {
  router.push('/purchases/create')
}

const handleView = (row) => {
  router.push(`/purchases/${row.id}`)
}

const handleEdit = (row) => {
  router.push(`/purchases/${row.id}?edit=true`)
}

const handleReceiving = (row) => {
  alert(`创建入库单: ${row.orderNumber}`)
}

const handleDelete = (row) => {
  alert(`删除采购单: ${row.orderNumber}`)
}

// 生命周期钩子
onMounted(() => {
  loadPurchases()
})
</script>

<style scoped>
.purchase-list {
  padding: 16px;
}
</style>
