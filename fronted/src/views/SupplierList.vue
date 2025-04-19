<template>
  <div class="supplier-list">
    <div class="page-header">
      <h1 class="page-title">供应商管理</h1>
      <n-button type="primary" @click="handleAddSupplier">
        添加供应商
      </n-button>
    </div>

    <div class="page-content">
      <!-- 搜索工具栏 -->
      <div class="table-toolbar">
        <div class="table-search">
          <n-input
            v-model:value="searchForm.name"
            placeholder="供应商名称"
            clearable
            style="width: 200px"
          />
          <n-input
            v-model:value="searchForm.code"
            placeholder="供应商编码"
            clearable
            style="width: 150px"
          />
          <n-select
            v-model:value="searchForm.type"
            placeholder="供应商类型"
            clearable
            :options="typeOptions"
            style="width: 150px"
          />
          <n-select
            v-model:value="searchForm.status"
            placeholder="状态"
            clearable
            :options="statusOptions"
            style="width: 100px"
          />
          <n-button type="primary" @click="handleSearch">
            查询
          </n-button>
          <n-button @click="resetSearch">
            重置
          </n-button>
        </div>
      </div>

      <!-- 供应商表格 -->
      <n-data-table
        ref="tableRef"
        :columns="columns"
        :data="suppliers"
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
  NButton, NDataTable, NInput, NSelect, NSpace, NTag, useMessage
} from 'naive-ui'
import supplierService from '../services/supplier'

const router = useRouter()
const message = useMessage()

// 响应式状态
const loading = ref(false)
const suppliers = ref([])
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
  code: '',
  type: null,
  status: null
})

// 供应商类型选项
const typeOptions = [
  { label: '生产厂商', value: 'manufacturer' },
  { label: '批发商', value: 'wholesaler' },
  { label: '代理商', value: 'agent' },
  { label: '其他', value: 'other' }
]

// 状态选项
const statusOptions = [
  { label: '启用', value: 'active' },
  { label: '禁用', value: 'inactive' }
]

// 获取供应商类型文本
const getTypeText = (type) => {
  const typeMap = {
    manufacturer: '生产厂商',
    wholesaler: '批发商',
    agent: '代理商',
    other: '其他'
  }
  return typeMap[type] || '未知'
}

// 获取评级标签类型
const getRatingType = (rating) => {
  const ratingMap = {
    'S': 'success',
    'A': 'info',
    'B': 'default',
    'C': 'warning',
    'D': 'error'
  }
  return ratingMap[rating] || 'default'
}

// 表格列定义
const columns = [
  {
    title: 'ID',
    key: 'id',
    width: 80
  },
  {
    title: '供应商编码',
    key: 'code',
    width: 120
  },
  {
    title: '供应商名称',
    key: 'name',
    width: 200
  },
  {
    title: '类型',
    key: 'type',
    width: 100,
    render(row) {
      return getTypeText(row.type)
    }
  },
  {
    title: '联系人',
    key: 'contactPerson',
    width: 120
  },
  {
    title: '联系电话',
    key: 'contactPhone',
    width: 150
  },
  {
    title: '评级',
    key: 'rating',
    width: 80,
    render(row) {
      return h(
        NTag,
        { type: getRatingType(row.rating) },
        { default: () => row.rating }
      )
    }
  },
  {
    title: '状态',
    key: 'status',
    width: 80,
    render(row) {
      return h(
        NTag,
        { type: row.status ? 'success' : 'error' },
        { default: () => row.status ? '启用' : '禁用' }
      )
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
              onClick: () => handleView(row)
            },
            { default: () => '查看' }
          ),
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
const loadSuppliers = async () => {
  loading.value = true
  try {
    // 构建查询参数
    const params = {
      page: pagination.page,
      limit: pagination.pageSize,
      name: searchForm.name || undefined,
      code: searchForm.code || undefined,
      type: searchForm.type || undefined,
      status: searchForm.status || undefined
    }

    // 调用API获取供应商列表
    const response = await supplierService.getSuppliers(params)

    // 处理响应数据
    if (response && response.items) {
      suppliers.value = response.items
      pagination.itemCount = response.total || 0
    } else {
      suppliers.value = []
      pagination.itemCount = 0
    }
  } catch (error) {
    console.error('加载供应商列表失败:', error)
    message.error('加载供应商列表失败: ' + (error.message || '未知错误'))
    suppliers.value = []
    pagination.itemCount = 0
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  pagination.page = 1
  loadSuppliers()
}

const resetSearch = () => {
  searchForm.name = ''
  searchForm.code = ''
  searchForm.type = null
  searchForm.status = null
  pagination.page = 1
  loadSuppliers()
}

const handlePageChange = (page) => {
  pagination.page = page
  loadSuppliers()
}

const handlePageSizeChange = (pageSize) => {
  pagination.pageSize = pageSize
  pagination.page = 1
  loadSuppliers()
}

const handleAddSupplier = () => {
  router.push('/suppliers/create')
}

const handleView = (row) => {
  if (!row || !row.id) {
    message.error('无效的供应商ID，无法查看')
    return
  }
  router.push(`/suppliers/${row.id}`)
}

const handleEdit = (row) => {
  if (!row || !row.id) {
    message.error('无效的供应商ID，无法编辑')
    return
  }
  router.push(`/suppliers/${row.id}?edit=true`)
}

const handleDelete = async (row) => {
  if (!row || !row.id) {
    message.error('无效的供应商ID，无法删除')
    return
  }

  if (confirm(`确定要删除供应商 ${row.name} 吗？`)) {
    try {
      loading.value = true
      await supplierService.deleteSupplier(row.id)
      message.success('删除成功')
      loadSuppliers() // 重新加载供应商列表
    } catch (error) {
      console.error('删除供应商失败:', error)
      message.error('删除供应商失败: ' + (error.message || '未知错误'))
    } finally {
      loading.value = false
    }
  }
}

// 生命周期钩子
onMounted(() => {
  loadSuppliers()
})
</script>

<style scoped>
.supplier-list {
  padding: 16px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.page-title {
  margin: 0;
  font-size: 24px;
  font-weight: 500;
}

.table-toolbar {
  margin-bottom: 16px;
}

.table-search {
  display: flex;
  gap: 16px;
  align-items: center;
}
</style>
