<template>
  <div class="product-deleted-list">
    <div class="page-header">
      <h2 class="page-title">已删除商品列表</h2>
      <div class="page-actions">
        <n-button @click="goBack" type="default">
          <template #icon>
            <n-icon>
              <ArrowBackOutline />
            </n-icon>
          </template>
          返回商品列表
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
  NCollapse, NCollapseItem, NCard, NIcon, NPopconfirm
} from 'naive-ui'
import { ArrowBackOutline, RefreshOutline } from '@vicons/ionicons5'
import productService from '../services/product'
import dictionaryService from '../services/dictionary'

// 路由和消息
const router = useRouter()
const message = useMessage()

// 响应式状态
const loading = ref(false)
const products = ref([])
const rawResponse = ref(null) // 原始响应数据
const showDebug = ref(true) // 显示调试信息，便于排查问题

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
    width: 120,
    render(row) {
      return row.sku || '-'
    }
  },
  {
    title: '商品名称',
    key: 'name',
    width: 200
  },
  {
    title: '类别',
    key: 'category',
    width: 120,
    render(row) {
      return row.category?.name || '-'
    }
  },
  {
    title: '成本价',
    key: 'costPrice',
    width: 100,
    render(row) {
      return row.costPrice ? `¥${row.costPrice.toFixed(2)}` : '-'
    }
  },
  {
    title: '零售价',
    key: 'retailPrice',
    width: 100,
    render(row) {
      return row.retailPrice ? `¥${row.retailPrice.toFixed(2)}` : '-'
    }
  },
  {
    title: '删除时间',
    key: 'deletedAt',
    width: 180,
    render(row) {
      return row.deletedAt ? new Date(row.deletedAt).toLocaleString() : '-'
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
            NPopconfirm,
            {
              onPositiveClick: () => handleRestore(row),
              negativeText: '取消',
              positiveText: '确定'
            },
            {
              trigger: () => h(
                NButton,
                {
                  size: 'small',
                  type: 'primary'
                },
                { default: () => '恢复' }
              ),
              default: () => `确定要恢复商品 ${row.name || 'ID: ' + row.id} 吗？`
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

    // 调用API获取已删除商品数据
    const response = await productService.getDeletedProducts(params)

    // 保存原始响应数据供调试使用
    rawResponse.value = response

    // 处理响应数据
    if (response.items && response.total !== undefined) {
      console.log('原始响应数据:', JSON.stringify(response.items, null, 2))

      // 确保每个商品都有必要的字段
      products.value = response.items.map(item => {
        // 检查原始字段名称
        console.log('单个商品原始数据:', item)
        console.log('商品字段名称:', Object.keys(item))

        // 使用原始字段名称或转换后的字段名称
        const id = item.ID !== undefined ? item.ID : (item.id || 0)
        const sku = item.SKU !== undefined ? item.SKU : (item.sku || '')

        return {
          ...item,
          // 确保必要字段存在，避免空值错误
          id: id,
          sku: sku,
          name: item.Name || item.name || '',
          costPrice: item.CostPrice || item.costPrice || 0,
          retailPrice: item.RetailPrice || item.retailPrice || 0,
          deletedAt: item.DeletedAt || item.deletedAt || null,
          category: item.Category || item.category || { id: 0, name: '-' }
        }
      })

      pagination.itemCount = response.total
      console.log('处理后的商品数据:', products.value)
    } else {
      products.value = []
      pagination.itemCount = 0
    }
  } catch (error) {
    console.error('加载已删除商品列表失败:', error)
    message.error('加载已删除商品列表失败: ' + (error.response?.data?.error || '未知错误'))
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

const handleRestore = (row) => {
  // 首先检查ID是否有效
  // 使用原始字段名称或转换后的字段名称
  const id = row.ID !== undefined ? row.ID : (row.id || 0)

  if (!id || id === 0) {
    message.error('商品ID无效，无法恢复')
    console.error('尝试恢复无效ID的商品:', row)
    return
  }

  console.log('尝试恢复商品:', row, '使用ID:', id)

  loading.value = true
  productService.restoreProduct(id)
    .then((response) => {
      console.log('恢复商品成功响应:', response)
      const name = row.Name || row.name || ''
      message.success(`商品 ${name || 'ID: ' + id} 恢复成功`)
      loadProducts()
    })
    .catch(error => {
      console.error('恢复商品失败:', error)
      message.error('恢复失败: ' + (error.response?.data?.error || '未知错误'))
    })
    .finally(() => {
      loading.value = false
    })
}

const goBack = () => {
  router.push('/products')
}

// 生命周期钩子
onMounted(async () => {
  await loadDictionaryItems('category', categoryOptions)
  loadProducts()
})
</script>

<style scoped>
.product-deleted-list {
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

.mt-4 {
  margin-top: 16px;
}
</style>
