<template>
  <div class="dictionary-item-list">
    <div class="page-header">
      <div class="header-left">
        <n-button @click="goBack" class="btn-back">
          <template #icon>
            <n-icon><ArrowBackOutline /></n-icon>
          </template>
          返回
        </n-button>
        <h1 class="page-title">{{ dictionary.name || dictionary.Name || '' }} - 字典项管理</h1>
      </div>
      <div class="header-right">
        <n-button @click="toggleDebug" type="warning" class="mr-2">
          {{ showDebug ? '隐藏调试' : '显示调试' }}
        </n-button>
        <n-button type="primary" @click="handleAddItem">
          添加字典项
        </n-button>
      </div>
    </div>

    <div class="page-content">
      <n-data-table
        ref="tableRef"
        :columns="columns"
        :data="items"
        :loading="loading"
        :pagination="pagination"
        :row-key="row => row.id || row.ID"
        @update:page="handlePageChange"
        @update:page-size="handlePageSizeChange"
      />
    </div>

    <!-- 调试信息区域 -->
    <n-collapse v-if="showDebug">
      <n-collapse-item title="调试信息" name="debug">
        <n-card title="原始字典信息">
          <pre>{{ JSON.stringify(rawDictionary, null, 2) }}</pre>
        </n-card>
        <n-card title="原始字典项数据" class="mt-4">
          <pre>{{ JSON.stringify(rawItems, null, 2) }}</pre>
        </n-card>
        <n-card title="处理后的字典项数据" class="mt-4">
          <pre>{{ JSON.stringify(items, null, 2) }}</pre>
        </n-card>
      </n-collapse-item>
    </n-collapse>

    <!-- 字典项表单对话框 -->
    <n-modal
      v-model:show="showItemModal"
      :title="isEditing ? '编辑字典项' : '添加字典项'"
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
          <n-input v-model:value="formData.code" placeholder="请输入字典项编码" />
        </n-form-item>

        <n-form-item label="名称" path="name">
          <n-input v-model:value="formData.name" placeholder="请输入字典项名称" />
        </n-form-item>

        <n-form-item label="值" path="value">
          <n-input v-model:value="formData.value" placeholder="请输入字典项值" />
        </n-form-item>

        <n-form-item label="颜色" path="color" v-if="dictionaryCode === 'color'">
          <n-color-picker v-model:value="formData.color" />
        </n-form-item>

        <n-form-item label="排序" path="sort">
          <n-input-number v-model:value="formData.sort" placeholder="请输入排序值" :min="0" />
        </n-form-item>

        <n-form-item label="状态" path="status">
          <n-switch v-model:value="formData.status" />
        </n-form-item>

        <n-form-item label="描述" path="description">
          <n-input v-model:value="formData.description" placeholder="请输入字典项描述" type="textarea" />
        </n-form-item>
      </n-form>

      <template #footer>
        <n-space justify="end">
          <n-button @click="showItemModal = false">取消</n-button>
          <n-button type="primary" @click="handleSaveItem" :loading="saving">保存</n-button>
        </n-space>
      </template>
    </n-modal>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, h, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import {
  NButton, NDataTable, NModal, NForm, NFormItem, NInput, NInputNumber, NSwitch,
  NSpace, NTag, NIcon, NColorPicker, useMessage, NCollapse, NCollapseItem, NCard
} from 'naive-ui'
import { ArrowBackOutline } from '@vicons/ionicons5'
import dictionaryService from '../services/dictionary'

// 路由和消息
const router = useRouter()
const route = useRoute()
const message = useMessage()

// 获取字典类型编码
const dictionaryCode = route.params.code

// 响应式状态
const loading = ref(false)
const saving = ref(false)
const dictionary = ref({})
const rawDictionary = ref({}) // 原始字典数据
const items = ref([])
const rawItems = ref([]) // 原始字典项数据
const showItemModal = ref(false)
const isEditing = ref(false)
const formRef = ref(null)
const currentItemId = ref(null)
const showDebug = ref(true) // 显示调试信息

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
  value: '',
  color: '',
  sort: 0,
  status: true,
  description: ''
})

// 表单验证规则
const rules = {
  code: {
    required: true,
    message: '请输入字典项编码',
    trigger: 'blur'
  },
  name: {
    required: true,
    message: '请输入字典项名称',
    trigger: 'blur'
  }
}

// 表格列定义
const columns = computed(() => {
  const cols = [
    {
      title: 'ID',
      key: 'id',
      width: 80,
      render(row) {
        return row.id || row.ID || '-'
      }
    },
    {
      title: '编码',
      key: 'code',
      width: 120,
      render(row) {
        return row.code || row.Code || '-'
      }
    },
    {
      title: '名称',
      key: 'name',
      width: 120,
      render(row) {
        return row.name || row.Name || '-'
      }
    },
    {
      title: '值',
      key: 'value',
      width: 120,
      render(row) {
        return row.value || row.Value || '-'
      }
    },
    {
      title: '排序',
      key: 'sort',
      width: 80,
      render(row) {
        return row.sort !== undefined ? row.sort : (row.Sort !== undefined ? row.Sort : '-')
      }
    },
    {
      title: '状态',
      key: 'status',
      width: 80,
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
      title: '描述',
      key: 'description',
      width: 200,
      render(row) {
        return row.description || row.Description || '-'
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

  // 如果是颜色字典，添加颜色列
  if (dictionaryCode === 'color') {
    cols.splice(4, 0, {
      title: '颜色',
      key: 'color',
      width: 100,
      render(row) {
        const colorValue = row.color || row.Color || '#fff'
        return h('div', {
          style: {
            width: '20px',
            height: '20px',
            backgroundColor: colorValue,
            border: '1px solid var(--border-color-base)',
            borderRadius: '4px'
          }
        })
      }
    })
  }

  return cols
})

// 切换调试信息显示
const toggleDebug = () => {
  showDebug.value = !showDebug.value
}

// 方法
const loadDictionary = async () => {
  loading.value = true
  try {
    // 获取字典类型信息
    const dictResponse = await dictionaryService.getDictionary(dictionaryCode)
    rawDictionary.value = dictResponse
    console.log('原始字典数据:', dictResponse)
    
    // 处理字典数据，确保字段名称一致
    dictionary.value = {
      ...dictResponse,
      code: dictResponse.Code || dictResponse.code || '',
      name: dictResponse.Name || dictResponse.name || '',
      description: dictResponse.Description || dictResponse.description || '',
      sort: dictResponse.Sort !== undefined ? dictResponse.Sort : (dictResponse.sort !== undefined ? dictResponse.sort : 0),
      status: dictResponse.Status !== undefined ? dictResponse.Status : (dictResponse.status !== undefined ? dictResponse.status : false)
    }
    
    console.log('处理后的字典数据:', dictionary.value)

    // 获取字典项列表
    const itemsResponse = await dictionaryService.getDictionaryItems(dictionaryCode)
    rawItems.value = itemsResponse
    console.log('原始字典项数据:', itemsResponse)
    
    // 处理字典项数据，确保字段名称一致
    items.value = itemsResponse.map(item => {
      return {
        ...item,
        id: item.ID || item.id || 0,
        code: item.Code || item.code || '',
        name: item.Name || item.name || '',
        value: item.Value || item.value || '',
        color: item.Color || item.color || '',
        sort: item.Sort !== undefined ? item.Sort : (item.sort !== undefined ? item.sort : 0),
        status: item.Status !== undefined ? item.Status : (item.status !== undefined ? item.status : false),
        description: item.Description || item.description || ''
      }
    })
    
    pagination.itemCount = items.value.length
    console.log('处理后的字典项数据:', items.value)
  } catch (error) {
    console.error('加载字典数据失败:', error)
    message.error('加载字典数据失败: ' + (error.response?.data?.error || '未知错误'))
    router.push('/dictionaries')
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

const goBack = () => {
  router.push('/dictionaries')
}

const handleAddItem = () => {
  isEditing.value = false
  currentItemId.value = null
  formData.code = ''
  formData.name = ''
  formData.value = ''
  formData.color = ''
  formData.sort = 0
  formData.status = true
  formData.description = ''
  showItemModal.value = true
}

const handleEdit = (row) => {
  isEditing.value = true
  currentItemId.value = row.id || row.ID
  formData.code = row.code || row.Code || ''
  formData.name = row.name || row.Name || ''
  formData.value = row.value || row.Value || ''
  formData.color = row.color || row.Color || ''
  formData.sort = row.sort !== undefined ? row.sort : (row.Sort !== undefined ? row.Sort : 0)
  formData.status = row.status !== undefined ? row.status : (row.Status !== undefined ? row.Status : false)
  formData.description = row.description || row.Description || ''
  showItemModal.value = true
}

const handleDelete = async (row) => {
  const id = row.id || row.ID
  const name = row.name || row.Name || row.code || row.Code
  
  if (!id) {
    message.error('字典项ID无效，无法删除')
    return
  }
  
  if (confirm(`确定要删除字典项 ${name} 吗？`)) {
    try {
      await dictionaryService.deleteDictionaryItem(dictionaryCode, id)
      message.success('删除成功')
      loadDictionary()
    } catch (error) {
      console.error('删除字典项失败:', error)
      message.error('删除失败: ' + (error.response?.data?.error || '未知错误'))
    }
  }
}

const handleSaveItem = () => {
  formRef.value?.validate(async (errors) => {
    if (errors) {
      return
    }

    saving.value = true
    try {
      if (isEditing.value) {
        await dictionaryService.updateDictionaryItem(dictionaryCode, currentItemId.value, formData)
        message.success('字典项更新成功')
      } else {
        await dictionaryService.createDictionaryItem(dictionaryCode, formData)
        message.success('字典项添加成功')
      }
      showItemModal.value = false
      loadDictionary()
    } catch (error) {
      console.error('保存字典项失败:', error)
      message.error('保存失败: ' + (error.response?.data?.error || '未知错误'))
    } finally {
      saving.value = false
    }
  })
}

// 生命周期钩子
onMounted(() => {
  loadDictionary()
})
</script>

<style scoped>
.dictionary-item-list {
  padding: 16px;
  background-color: var(--background-color-base);
  min-height: calc(100vh - 64px);
}

.dark .dictionary-item-list {
  background-color: var(--background-color);
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.header-left {
  display: flex;
  align-items: center;
}

.header-right {
  display: flex;
  gap: 8px;
}

.btn-back {
  margin-right: 16px;
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

.mr-2 {
  margin-right: 8px;
}
</style>
