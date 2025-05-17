<template>
  <div class="product-list">
    <div class="page-header">
      <h1 class="page-title">商品管理</h1>
      <div class="page-actions">
        <n-button @click="viewDeletedProducts" type="info">
          查看已删除商品
        </n-button>
        <n-button type="primary" @click="handleAddProduct">
          添加商品
        </n-button>
      </div>
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
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, h } from 'vue'
import { useRouter } from 'vue-router'
import {
  NButton, NDataTable, NInput, NSelect, NSpace, useMessage,
  NCollapse, NCollapseItem, NCard, NPopconfirm, NIcon
} from 'naive-ui'
import { RefreshOutline } from '@vicons/ionicons5'
import productService from '../services/product'
import { convertBackendFields } from '../utils/fieldConverter'

// 路由和消息
const router = useRouter()
const message = useMessage()

// 响应式状态
const loading = ref(false)
const products = ref([])

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
const categoryOptions = ref([])

// 加载字典数据
const loadDictionaryItems = async (code, options) => {
  try {
    const dictionaryService = (await import('../services/dictionary')).default
    const items = await dictionaryService.getDictionaryItems(code)
    console.log(`原始字典项数据: ${code}`, items)

    // 检查字典项数据结构
    if (items && items.length > 0) {
      console.log('字典项第一项字段:', Object.keys(items[0]))
    }

    // 构建选项
    options.value = items.map(item => {
      // 处理字段名称不一致的情况
      const name = item.Name || item.name || ''
      const id = item.ID || item.id || 0
      const status = item.Status !== undefined ? item.Status : (item.status !== undefined ? item.status : true)

      return {
        label: name,
        value: id,
        disabled: !status // 根据状态设置是否禁用
      }
    })

    console.log(`字典项加载成功: ${code}`, options.value)
  } catch (error) {
    console.error(`加载${code}字典数据失败:`, error)
    message.error(`加载${code}字典数据失败: ${error.message || '未知错误'}`)
  }
}

// 表格列定义
const columns = [
  {
    title: 'ID',
    key: 'id',
    width: 80,
    render(row) {
      return row.id || '-'
    }
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
            NPopconfirm,
            {
              onPositiveClick: () => handleDelete(row),
              negativeText: '取消',
              positiveText: '确定'
            },
            {
              trigger: () => h(
                NButton,
                {
                  size: 'small',
                  type: 'error'
                },
                { default: () => '删除' }
              ),
              default: () => `确定要删除商品 ${row.name || 'ID: ' + row.id} 吗？`
            }
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

    // 将参数转换为后端需要的格式（首字母大写）
    if (params.category) {
      params.category_id = params.category
      delete params.category
    }

    console.log('查询参数:', params)

    // 调用API获取商品数据
    const response = await productService.getProducts(params)

    // 处理响应数据
    if (response.items && response.total !== undefined) {
      // 确保每个商品都有必要的字段
      products.value = response.items.map(item => {

        // 使用原始字段名称或转换后的字段名称
        const id = item.ID !== undefined ? item.ID : (item.id || 0)
        const sku = item.SKU !== undefined ? item.SKU : (item.sku || '')

        return {
          ...item,
          // 确保必要字段存在，避免空值错误
          id: id,
          sku: sku,
          name: item.Name || item.name || '',
          category: item.Category?.Name || (item.category?.name) || '-',
          color: item.Color?.Name || (item.color?.name) || '-',
          size: item.Size?.Name || (item.size?.name) || '-',
          season: item.Season?.Name || (item.season?.name) || '-',
          costPrice: item.CostPrice || item.costPrice || 0,
          retailPrice: item.RetailPrice || item.retailPrice || 0
        }
      })

      pagination.itemCount = response.total
    } else {
      products.value = []
      pagination.itemCount = 0
    }
  } catch (error) {
    console.error('加载商品列表失败:', error)
    message.error('加载商品列表失败: ' + (error.response?.data?.error || '未知错误'))
    products.value = []
    pagination.itemCount = 0
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
  loading.value = true
  productService.deleteProduct(row.id)
    .then(() => {
      message.success('删除成功')
      loadProducts()
    })
    .catch(error => {
      console.error('删除商品失败:', error)
      message.error('删除失败: ' + (error.response?.data?.error || '未知错误'))
    })
    .finally(() => {
      loading.value = false
    })
}

const viewDeletedProducts = () => {
  router.push('/products/deleted')
}

// 生命周期钩子
onMounted(async () => {
  await loadDictionaryItems('category', categoryOptions)
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

.page-actions {
  display: flex;
  gap: 8px;
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

.mt-4 {
  margin-top: 16px;
}
</style>
