<template>
  <div class="inventory-list">
    <div class="page-header">
      <h1 class="page-title">库存管理</h1>
      <n-button type="primary" @click="handleAddInventory">
        添加库存
      </n-button>
    </div>
    
    <div class="page-content">
      <!-- 搜索工具栏 -->
      <div class="table-toolbar">
        <div class="table-search">
          <n-input
            v-model:value="searchForm.productName"
            placeholder="商品名称"
            clearable
            style="width: 200px"
          />
          <n-input
            v-model:value="searchForm.sku"
            placeholder="SKU"
            clearable
            style="width: 150px"
          />
          <n-select
            v-model:value="searchForm.storeId"
            placeholder="店铺"
            clearable
            :options="storeOptions"
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
      
      <!-- 库存表格 -->
      <n-data-table
        ref="tableRef"
        :columns="columns"
        :data="inventories"
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
import { 
  NButton, NDataTable, NInput, NSelect, NSpace, NTag
} from 'naive-ui'

// 响应式状态
const loading = ref(false)
const inventories = ref([])
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
  productName: '',
  sku: '',
  storeId: null
})

// 店铺选项
const storeOptions = [
  { label: '总店', value: 1 },
  { label: '分店1', value: 2 },
  { label: '分店2', value: 3 }
]

// 表格列定义
const columns = [
  {
    title: 'ID',
    key: 'id',
    width: 80
  },
  {
    title: 'SKU',
    key: 'productSku',
    width: 150
  },
  {
    title: '商品名称',
    key: 'productName',
    width: 200
  },
  {
    title: '店铺',
    key: 'storeName',
    width: 100
  },
  {
    title: '库存数量',
    key: 'quantity',
    width: 100
  },
  {
    title: '库位',
    key: 'location',
    width: 100
  },
  {
    title: '状态',
    key: 'status',
    width: 100,
    render(row) {
      let type = 'success'
      let text = '正常'
      
      if (row.quantity <= 0) {
        type = 'error'
        text = '缺货'
      } else if (row.quantity <= 10) {
        type = 'warning'
        text = '低库存'
      }
      
      return h(NTag, { type }, { default: () => text })
    }
  },
  {
    title: '操作',
    key: 'actions',
    width: 200,
    fixed: 'right',
    render(row) {
      return h(NSpace, { justify: 'center' }, {
        default: () => [
          h(
            NButton,
            {
              size: 'small',
              type: 'primary',
              onClick: () => handleEdit(row)
            },
            { default: () => '编辑' }
          ),
          h(
            NButton,
            {
              size: 'small',
              type: 'info',
              onClick: () => handleTransaction(row)
            },
            { default: () => '调整' }
          )
        ]
      })
    }
  }
]

// 方法
const loadInventories = async () => {
  loading.value = true
  try {
    // 模拟数据，实际应该从API获取
    inventories.value = [
      {
        id: 1,
        productId: 1,
        productSku: 'MS001',
        productName: '男士休闲衬衫',
        storeId: 1,
        storeName: '总店',
        quantity: 25,
        location: 'A-01-01'
      },
      {
        id: 2,
        productId: 2,
        productSku: 'WD001',
        productName: '女士连衣裙',
        storeId: 1,
        storeName: '总店',
        quantity: 15,
        location: 'A-02-01'
      },
      {
        id: 3,
        productId: 3,
        productSku: 'MT001',
        productName: '男士T恤',
        storeId: 2,
        storeName: '分店1',
        quantity: 8,
        location: 'B-01-01'
      },
      {
        id: 4,
        productId: 1,
        productSku: 'MS001',
        productName: '男士休闲衬衫',
        storeId: 2,
        storeName: '分店1',
        quantity: 0,
        location: 'B-01-02'
      }
    ]
    pagination.itemCount = inventories.value.length
  } catch (error) {
    console.error('加载库存列表失败:', error)
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  pagination.page = 1
  loadInventories()
}

const resetSearch = () => {
  searchForm.productName = ''
  searchForm.sku = ''
  searchForm.storeId = null
  pagination.page = 1
  loadInventories()
}

const handlePageChange = (page) => {
  pagination.page = page
  loadInventories()
}

const handlePageSizeChange = (pageSize) => {
  pagination.pageSize = pageSize
  pagination.page = 1
  loadInventories()
}

const handleAddInventory = () => {
  alert('添加库存功能尚未实现')
}

const handleEdit = (row) => {
  alert(`编辑库存: ${row.productName} - ${row.storeName}`)
}

const handleTransaction = (row) => {
  alert(`调整库存: ${row.productName} - ${row.storeName}`)
}

// 生命周期钩子
onMounted(() => {
  loadInventories()
})
</script>

<style scoped>
.inventory-list {
  padding: 16px;
}
</style>
