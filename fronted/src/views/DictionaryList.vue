<template>
  <div class="dictionary-list">
    <div class="page-header">
      <h1 class="page-title">字典管理</h1>
      <n-button type="primary" @click="handleAddDictionary">
        添加字典类型
      </n-button>
    </div>

    <div class="page-content">
      <n-data-table
        ref="tableRef"
        :columns="columns"
        :data="dictionaries"
        :loading="loading"
        :pagination="pagination"
        :row-key="row => row.code || row.Code"
        @update:page="handlePageChange"
        @update:page-size="handlePageSizeChange"
      />
    </div>

    <!-- 调试信息区域 -->
    <n-collapse v-if="showDebug">
      <n-collapse-item title="调试信息" name="debug">
        <n-card title="原始响应数据">
          <pre>{{ JSON.stringify(rawResponse, null, 2) }}</pre>
        </n-card>
        <n-card title="处理后的数据" class="mt-4">
          <pre>{{ JSON.stringify(dictionaries, null, 2) }}</pre>
        </n-card>
      </n-collapse-item>
    </n-collapse>

    <!-- 字典类型表单对话框 -->
    <n-modal
      v-model:show="showDictionaryModal"
      :title="isEditing ? '编辑字典类型' : '添加字典类型'"
      preset="card"
      style="width: 600px"
      :mask-closable="false"
    >
      <n-form
        ref="formRef"
        :model="formData"
        :rules="rules"
        label-placement="left"
        label-width="auto"
        require-mark-placement="right-hanging"
      >
        <n-form-item label="编码" path="code">
          <n-input v-model:value="formData.code" placeholder="请输入字典类型编码" :disabled="isEditing" />
        </n-form-item>

        <n-form-item label="名称" path="name">
          <n-input v-model:value="formData.name" placeholder="请输入字典类型名称" />
        </n-form-item>

        <n-form-item label="描述" path="description">
          <n-input v-model:value="formData.description" placeholder="请输入字典类型描述" />
        </n-form-item>

        <n-form-item label="排序" path="sort">
          <n-input-number v-model:value="formData.sort" placeholder="请输入排序值" :min="0" />
        </n-form-item>

        <n-form-item label="状态" path="status">
          <n-switch v-model:value="formData.status" />
        </n-form-item>
      </n-form>

      <template #footer>
        <n-space justify="end">
          <n-button @click="showDictionaryModal = false">取消</n-button>
          <n-button type="primary" @click="handleSaveDictionary" :loading="saving">保存</n-button>
        </n-space>
      </template>
    </n-modal>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, h } from 'vue'
import { useRouter } from 'vue-router'
import {
  NButton, NDataTable, NModal, NForm, NFormItem, NInput, NInputNumber, NSwitch,
  NSpace, NTag, useMessage, NCollapse, NCollapseItem, NCard
} from 'naive-ui'
import dictionaryService from '../services/dictionary'
import { convertBackendFields } from '../utils/fieldConverter'

// 路由和消息
const router = useRouter()
const message = useMessage()

// 响应式状态
const loading = ref(false)
const saving = ref(false)
const dictionaries = ref([])
const rawResponse = ref(null) // 原始响应数据
const showDebug = ref(true) // 显示调试信息
const showDictionaryModal = ref(false)
const isEditing = ref(false)
const formRef = ref(null)

// 分页
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

// 表单数据
const formData = reactive({
  code: '',
  name: '',
  description: '',
  sort: 0,
  status: true
})

// 表单验证规则
const rules = {
  code: {
    required: true,
    message: '请输入字典类型编码',
    trigger: 'blur'
  },
  name: {
    required: true,
    message: '请输入字典类型名称',
    trigger: 'blur'
  }
}

// 表格列定义
const columns = [
  {
    title: '编码',
    key: 'code',
    width: 150,
    render(row) {
      return row.code || row.Code || '-'
    }
  },
  {
    title: '名称',
    key: 'name',
    width: 150,
    render(row) {
      return row.name || row.Name || '-'
    }
  },
  {
    title: '描述',
    key: 'description',
    width: 200,
    render(row) {
      return row.description || row.Description || '-'
    }
  },
  {
    title: '排序',
    key: 'sort',
    width: 100,
    render(row) {
      return row.sort !== undefined ? row.sort : (row.Sort !== undefined ? row.Sort : '-')
    }
  },
  {
    title: '状态',
    key: 'status',
    width: 100,
    render(row) {
      const status = row.status !== undefined ? row.status : (row.Status !== undefined ? row.Status : false)
      return h(
        NTag,
        {
          type: status ? 'success' : 'error',
          size: 'small'
        },
        { default: () => status ? '启用' : '禁用' }
      )
    }
  },
  {
    title: '操作',
    key: 'actions',
    width: 250,
    fixed: 'right',
    render(row) {
      const code = row.code || row.Code
      return h(NSpace, { justify: 'center' }, {
        default: () => [
          h(
            NButton,
            {
              size: 'small',
              type: 'primary',
              onClick: () => handleViewItems(row)
            },
            { default: () => '查看字典项' }
          ),
          h(
            NButton,
            {
              size: 'small',
              type: 'info',
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
const loadDictionaries = async () => {
  loading.value = true
  try {
    const response = await dictionaryService.getDictionaries()
    
    // 保存原始响应数据供调试使用
    rawResponse.value = response
    console.log('原始字典数据:', response)
    
    // 处理响应数据，确保字段名称一致
    dictionaries.value = response.map(item => {
      // 检查原始字段名称
      console.log('单个字典原始数据:', item)
      console.log('字典字段名称:', Object.keys(item))
      
      return {
        ...item,
        // 确保必要字段存在，避免空值错误
        code: item.Code || item.code || '',
        name: item.Name || item.name || '',
        description: item.Description || item.description || '',
        sort: item.Sort !== undefined ? item.Sort : (item.sort !== undefined ? item.sort : 0),
        status: item.Status !== undefined ? item.Status : (item.status !== undefined ? item.status : false)
      }
    })
    
    pagination.itemCount = dictionaries.value.length
    console.log('处理后的字典数据:', dictionaries.value)
  } catch (error) {
    console.error('加载字典类型列表失败:', error)
    message.error('加载字典类型列表失败: ' + (error.response?.data?.error || '未知错误'))
    dictionaries.value = []
    pagination.itemCount = 0
  } finally {
    loading.value = false
  }
}

const handlePageChange = (page) => {
  pagination.page = page
}

const handlePageSizeChange = (pageSize) => {
  pagination.pageSize = pageSize
  pagination.page = 1
}

const handleAddDictionary = () => {
  isEditing.value = false
  formData.code = ''
  formData.name = ''
  formData.description = ''
  formData.sort = 0
  formData.status = true
  showDictionaryModal.value = true
}

const handleEdit = (row) => {
  isEditing.value = true
  formData.code = row.code || row.Code || ''
  formData.name = row.name || row.Name || ''
  formData.description = row.description || row.Description || ''
  formData.sort = row.sort !== undefined ? row.sort : (row.Sort !== undefined ? row.Sort : 0)
  formData.status = row.status !== undefined ? row.status : (row.Status !== undefined ? row.Status : false)
  showDictionaryModal.value = true
}

const handleDelete = async (row) => {
  const code = row.code || row.Code
  const name = row.name || row.Name
  
  if (!code) {
    message.error('字典类型编码无效，无法删除')
    return
  }
  
  if (confirm(`确定要删除字典类型 ${name || code} 吗？`)) {
    try {
      await dictionaryService.deleteDictionary(code)
      message.success('删除成功')
      loadDictionaries()
    } catch (error) {
      console.error('删除字典类型失败:', error)
      message.error('删除失败: ' + (error.response?.data?.error || '未知错误'))
    }
  }
}

const handleViewItems = (row) => {
  const code = row.code || row.Code
  
  if (!code) {
    message.error('字典类型编码无效，无法查看字典项')
    return
  }
  
  router.push(`/dictionaries/${code}/items`)
}

const handleSaveDictionary = () => {
  formRef.value?.validate(async (errors) => {
    if (errors) {
      return
    }

    saving.value = true
    try {
      if (isEditing.value) {
        await dictionaryService.updateDictionary(formData.code, formData)
        message.success('字典类型更新成功')
      } else {
        await dictionaryService.createDictionary(formData)
        message.success('字典类型添加成功')
      }
      showDictionaryModal.value = false
      loadDictionaries()
    } catch (error) {
      console.error('保存字典类型失败:', error)
      message.error('保存失败: ' + (error.response?.data?.error || '未知错误'))
    } finally {
      saving.value = false
    }
  })
}

// 生命周期钩子
onMounted(() => {
  loadDictionaries()
})
</script>

<style scoped>
.dictionary-list {
  padding: 16px;
  background-color: var(--background-color-base);
  min-height: calc(100vh - 64px);
}

.dark .dictionary-list {
  background-color: var(--background-color);
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

.page-content {
  background-color: var(--card-background);
  border-radius: 4px;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
  padding: 16px;
}

.dark .page-content {
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.2);
}

.mt-4 {
  margin-top: 16px;
}
</style>
