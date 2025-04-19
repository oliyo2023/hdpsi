<template>
  <div class="product-list">
    <div class="page-header">
      <h1 class="page-title">商品管理</h1>
      <n-button type="primary" @click="handleAddProduct">
        添加商品
      </n-button>
    </div>

    <div class="page-content">
      <!-- 搜索工具栏 -->
      <div class="table-toolbar">
        <div class="table-search">
          <n-input
            v-model:value="searchForm.name"
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
            v-model:value="searchForm.category"
            placeholder="类别"
            clearable
            :options="categoryOptions"
            style="width: 150px"
          />
          <n-button type="primary" @click="handleSearch">
            查询
          </n-button>
          <n-button @click="resetSearch">
            重置
          </n-button>
          <n-button @click="handleRefresh" type="info">
            刷新
          </n-button>
          <n-button @click="toggleDebug" type="warning">
            {{ showDebug ? '隐藏调试' : '显示调试' }}
          </n-button>
        </div>
      </div>

      <!-- 商品表格 -->
      <n-data-table
        ref="tableRef"
        :columns="columns"
        :data="products"
        :loading="loading"
        :pagination="pagination"
        :row-key="row => row.id"
        @update:page="handlePageChange"
        @update:page-size="handlePageSizeChange"
      />

      <!-- 调试信息区域 -->
      <n-collapse v-if="showDebug">
        <n-collapse-item title="调试信息" name="debug">
          <n-card title="原始响应数据">
            <pre>{{ JSON.stringify(rawResponse, null, 2) }}</pre>
          </n-card>
          <n-card title="处理后的数据" class="mt-4">
            <pre>{{ JSON.stringify(products, null, 2) }}</pre>
          </n-card>
        </n-collapse-item>
      </n-collapse>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, h } from 'vue'
import { useRouter } from 'vue-router'
import {
  NButton, NDataTable, NInput, NSelect, NSpace, useMessage,
  NCollapse, NCollapseItem, NCard
} from 'naive-ui'
import productService from '../services/product'

// 路由和消息
const router = useRouter()
const message = useMessage()

// 响应式状态
const loading = ref(false)
const products = ref([])
const rawResponse = ref(null) // 原始响应数据
const showDebug = ref(false) // 默认不显示调试信息

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
  name: '',
  sku: '',
  category: null
})

// 类别选项
const categoryOptions = [
  { label: '外套', value: '外套' },
  { label: '裤装', value: '裤装' },
  { label: '衬衫', value: '衬衫' },
  { label: 'T恤', value: 'T恤' },
  { label: '内衣', value: '内衣' },
  { label: '配饰', value: '配饰' }
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
    key: 'sku',
    width: 150,
    render(row) {
      return row.sku || '-'
    }
  },
  {
    title: '商品名称',
    key: 'name',
    width: 200,
    render(row) {
      return row.name || '-'
    }
  },
  {
    title: '类别',
    key: 'category',
    width: 100,
    render(row) {
      return row.category || '-'
    }
  },
  {
    title: '颜色',
    key: 'color',
    width: 100,
    render(row) {
      return row.color || '-'
    }
  },
  {
    title: '尺码',
    key: 'size',
    width: 100,
    render(row) {
      return row.size || '-'
    }
  },
  {
    title: '季节',
    key: 'season',
    width: 100,
    render(row) {
      return row.season || '-'
    }
  },
  {
    title: '零售价',
    key: 'retailPrice',
    width: 120,
    render(row) {
      return row.retailPrice ? `¥${row.retailPrice.toFixed(2)}` : '¥0.00'
    }
  },
  {
    title: '操作',
    key: 'actions',
    width: 150,
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
              type: 'error',
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
const loadProducts = async () => {
  loading.value = true
  try {
    // 构建查询参数
    const params = {
      page: pagination.page,
      pageSize: pagination.pageSize,
      name: searchForm.name || undefined,
      sku: searchForm.sku || undefined,
      category: searchForm.category || undefined
    }

    // 调用API获取商品数据
    const response = await productService.getProducts(params)

    // 保存原始响应数据供调试使用
    rawResponse.value = response

    // 调试输出响应数据
    console.log('API响应数据:', JSON.stringify(response, null, 2))

    // 处理响应数据
    if (response.items && response.total !== undefined) {
      // 如果返回的是分页数据结构
      // 将字段名称转换为小写并处理关联对象
      products.value = response.items.map(item => ({
        id: item.ID,
        sku: item.SKU,
        name: item.Name,
        category: item.Category?.Name || '-',
        color: item.Color?.Name || '-',
        size: item.Size?.Name || '-',
        season: item.Season?.Name || '-',
        costPrice: item.CostPrice,
        retailPrice: item.RetailPrice,
        image: item.Image
      }))
      pagination.itemCount = response.total
      console.log('处理后的商品数据:', JSON.stringify(products.value, null, 2))
    } else {
      // 如果返回的是简单数组
      // 将字段名称转换为小写并处理关联对象
      products.value = Array.isArray(response) ? response.map(item => ({
        id: item.ID,
        sku: item.SKU,
        name: item.Name,
        category: item.Category?.Name || '-',
        color: item.Color?.Name || '-',
        size: item.Size?.Name || '-',
        season: item.Season?.Name || '-',
        costPrice: item.CostPrice,
        retailPrice: item.RetailPrice,
        image: item.Image
      })) : []
      pagination.itemCount = products.value.length
      console.log('处理后的商品数据:', JSON.stringify(products.value, null, 2))
    }
  } catch (error) {
    console.error('加载商品列表失败:', error)
    message.error('加载商品列表失败: ' + (error.response?.data?.error || '未知错误'))
    // 如果API调用失败，使用模拟数据以便于测试
    products.value = [
      {
        id: 1,
        sku: 'MS001',
        name: '男士休闲衬衫',
        category: '衬衫',
        color: '白色',
        size: 'L',
        season: '春季',
        costPrice: 89.00,
        retailPrice: 199.00
      },
      {
        id: 2,
        sku: 'WD001',
        name: '女士连衣裙',
        category: '裤装',
        color: '蓝色',
        size: 'M',
        season: '夏季',
        costPrice: 120.00,
        retailPrice: 299.00
      },
      {
        id: 3,
        sku: 'MT001',
        name: '男士T恤',
        category: 'T恤',
        color: '黑色',
        size: 'XL',
        season: '夏季',
        costPrice: 45.00,
        retailPrice: 99.00
      }
    ]
    pagination.itemCount = products.value.length
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  pagination.page = 1
  loadProducts()
}

const resetSearch = () => {
  searchForm.name = ''
  searchForm.sku = ''
  searchForm.category = null
  pagination.page = 1
  loadProducts()
}

const handleRefresh = () => {
  loadProducts()
  message.success('刷新成功')
}

const toggleDebug = () => {
  showDebug.value = !showDebug.value
}

const handlePageChange = (page) => {
  pagination.page = page
  loadProducts()
}

const handlePageSizeChange = (pageSize) => {
  pagination.pageSize = pageSize
  pagination.page = 1
  loadProducts()
}

const handleAddProduct = () => {
  router.push('/products/create')
}

const handleEdit = (row) => {
  router.push(`/products/edit/${row.id}`)
}

const handleDelete = (row) => {
  if (confirm(`确定要删除商品 ${row.name} 吗？`)) {
    productService.deleteProduct(row.id)
      .then(() => {
        message.success('删除成功')
        loadProducts()
      })
      .catch(error => {
        console.error('删除商品失败:', error)
        message.error('删除失败: ' + (error.response?.data?.error || '未知错误'))
      })
  }
}

// 生命周期钩子
onMounted(() => {
  loadProducts()
})
</script>

<style scoped>
.product-list {
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
  font-size: 20px;
  font-weight: 500;
}

.table-toolbar {
  margin-bottom: 16px;
}

.table-search {
  display: flex;
  gap: 8px;
}
</style>
