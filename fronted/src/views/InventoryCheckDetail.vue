<template>
  <div class="inventory-check-detail">
    <div class="page-header">
      <div class="header-left">
        <n-button quaternary @click="router.back()">
          <template #icon>
            <n-icon><arrow-back-outline /></n-icon>
          </template>
          返回
        </n-button>
        <h1 class="page-title">盘点单详情</h1>
      </div>
      <div class="header-actions">
        <!-- 根据状态显示不同的操作按钮 -->
        <n-button v-if="check.Status === 'planned'" type="primary" @click="handleStartCheck">
          开始盘点
        </n-button>
        <n-button v-if="check.Status === 'in_process'" type="success" @click="handleCompleteCheck">
          完成盘点
        </n-button>
        <n-popconfirm v-if="['planned', 'in_process'].includes(check.Status)" @positive-click="handleCancelCheck">
          <template #trigger>
            <n-button type="error">取消盘点</n-button>
          </template>
          确定取消该盘点单吗？
        </n-popconfirm>
      </div>
    </div>
    
    <div class="page-content">
      <n-card title="基本信息" class="detail-card">
        <n-descriptions bordered :column="3">
          <n-descriptions-item label="盘点单号">
            {{ check.CheckCode }}
          </n-descriptions-item>
          <n-descriptions-item label="盘点类型">
            {{ check.CheckType === 'full_check' ? '全盘' : '抽盘' }}
          </n-descriptions-item>
          <n-descriptions-item label="状态">
            <n-tag :type="getStatusType(check.Status)">
              {{ getStatusText(check.Status) }}
            </n-tag>
          </n-descriptions-item>
          <n-descriptions-item label="店铺">
            {{ getStoreName(check.StoreID) }}
          </n-descriptions-item>
          <n-descriptions-item label="计划日期">
            {{ formatDate(check.PlanDate) }}
          </n-descriptions-item>
          <n-descriptions-item label="创建时间">
            {{ formatDateTime(check.CreatedAt) }}
          </n-descriptions-item>
          <n-descriptions-item v-if="check.StartTime" label="开始时间">
            {{ formatDateTime(check.StartTime) }}
          </n-descriptions-item>
          <n-descriptions-item v-if="check.EndTime" label="结束时间">
            {{ formatDateTime(check.EndTime) }}
          </n-descriptions-item>
          <n-descriptions-item label="说明" :span="3">
            {{ check.Description || '无' }}
          </n-descriptions-item>
        </n-descriptions>
      </n-card>
      
      <n-card title="盘点明细" class="detail-card">
        <n-data-table
          :columns="itemColumns"
          :data="items"
          :loading="loading"
          :pagination="pagination"
          :row-key="row => row.ID"
        />
      </n-card>
    </div>
    
    <!-- 盘点明细编辑对话框 -->
    <n-modal
      v-model:show="showEditModal"
      preset="card"
      title="更新盘点数量"
      style="width: 500px"
    >
      <n-form
        ref="formRef"
        :model="editForm"
        :rules="rules"
        label-placement="left"
        label-width="100"
        require-mark-placement="right-hanging"
      >
        <n-form-item label="商品" path="productName">
          <n-input v-model:value="editForm.productName" disabled />
        </n-form-item>
        <n-form-item label="系统数量" path="systemQuantity">
          <n-input-number v-model:value="editForm.systemQuantity" disabled />
        </n-form-item>
        <n-form-item label="实际数量" path="actualQuantity">
          <n-input-number v-model:value="editForm.actualQuantity" :min="0" />
        </n-form-item>
        <n-form-item label="差异数量">
          <n-input-number 
            v-model:value="differenceQty" 
            disabled 
            :status="differenceQty !== 0 ? 'warning' : ''" 
          />
        </n-form-item>
        <n-form-item label="备注" path="note">
          <n-input v-model:value="editForm.note" type="textarea" />
        </n-form-item>
      </n-form>
      <template #footer>
        <n-space justify="end">
          <n-button @click="showEditModal = false">取消</n-button>
          <n-button type="primary" @click="handleSaveCheckItem">保存</n-button>
        </n-space>
      </template>
    </n-modal>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, h } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { 
  NButton, NCard, NDescriptions, NDescriptionsItem, NDataTable, 
  NTag, NSpace, NPopconfirm, NModal, NForm, NFormItem, 
  NInput, NInputNumber, NIcon
} from 'naive-ui'
import { useMessage } from 'naive-ui'
import { ArrowBackOutline } from '@vicons/ionicons5'
import inventoryCheckService from '../services/inventory_check_service'

const router = useRouter()
const route = useRoute()
const message = useMessage()

// 响应式状态
const loading = ref(false)
const check = ref({})
const items = ref([])
const pagination = reactive({
  page: 1,
  pageSize: 10,
  itemCount: 0,
  pageSizes: [10, 20, 50, 100],
  showSizePicker: true
})

// 编辑对话框
const showEditModal = ref(false)
const editForm = reactive({
  id: null,
  productName: '',
  systemQuantity: 0,
  actualQuantity: 0,
  note: ''
})
const currentItem = ref(null)

// 计算差异数量
const differenceQty = computed(() => {
  return editForm.actualQuantity - editForm.systemQuantity
})

// 表单验证规则
const rules = {
  actualQuantity: [
    { required: true, message: '请输入实际数量', trigger: 'blur' },
    { type: 'number', min: 0, message: '数量不能小于0', trigger: 'blur' }
  ]
}

// 店铺选项
const storeOptions = [
  { label: '总店', value: 1 },
  { label: '分店1', value: 2 },
  { label: '分店2', value: 3 }
]

// 表格列定义
const itemColumns = [
  {
    title: 'ID',
    key: 'ID',
    width: 80
  },
  {
    title: '商品',
    key: 'ProductVariantID',
    width: 200,
    render(row) {
      // 这里应该根据ProductVariantID获取商品名称
      return `商品 #${row.ProductVariantID}`
    }
  },
  {
    title: '系统数量',
    key: 'SystemQuantity',
    width: 100
  },
  {
    title: '实际数量',
    key: 'ActualQuantity',
    width: 100,
    render(row) {
      return row.Status === 'checked' ? row.ActualQuantity : '-'
    }
  },
  {
    title: '差异数量',
    key: 'DifferenceQty',
    width: 100,
    render(row) {
      if (row.Status !== 'checked') return '-'
      
      const diff = row.DifferenceQty
      let color = ''
      if (diff > 0) color = 'green'
      else if (diff < 0) color = 'red'
      
      return h('span', { style: { color } }, diff)
    }
  },
  {
    title: '状态',
    key: 'Status',
    width: 100,
    render(row) {
      const status = row.Status === 'checked' ? 'success' : 'warning'
      const text = row.Status === 'checked' ? '已盘点' : '待盘点'
      return h(NTag, { type: status }, { default: () => text })
    }
  },
  {
    title: '备注',
    key: 'Note',
    width: 200
  },
  {
    title: '操作',
    key: 'actions',
    width: 150,
    fixed: 'right',
    render(row) {
      if (check.value.Status !== 'in_process') {
        return null
      }
      
      return h(NButton, {
        size: 'small',
        onClick: () => handleEditItem(row)
      }, { default: () => '盘点' })
    }
  }
]

// 生命周期钩子
onMounted(() => {
  const id = route.params.id
  if (id) {
    loadCheckDetail(id)
  }
})

// 加载盘点单详情
const loadCheckDetail = async (id) => {
  loading.value = true
  try {
    const response = await inventoryCheckService.getCheck(id)
    check.value = response.data.check
    items.value = response.data.items
    pagination.itemCount = items.value.length
  } catch (error) {
    console.error('加载盘点单详情失败:', error)
    message.error('加载盘点单详情失败')
  } finally {
    loading.value = false
  }
}

// 获取状态类型
const getStatusType = (status) => {
  switch (status) {
    case 'planned': return 'info'
    case 'in_process': return 'warning'
    case 'completed': return 'success'
    case 'cancelled': return 'error'
    default: return 'default'
  }
}

// 获取状态文本
const getStatusText = (status) => {
  switch (status) {
    case 'planned': return '计划中'
    case 'in_process': return '进行中'
    case 'completed': return '已完成'
    case 'cancelled': return '已取消'
    default: return status
  }
}

// 获取店铺名称
const getStoreName = (storeId) => {
  const store = storeOptions.find(item => item.value === storeId)
  return store ? store.label : storeId
}

// 格式化日期
const formatDate = (dateString) => {
  if (!dateString) return '-'
  return new Date(dateString).toLocaleDateString()
}

// 格式化日期时间
const formatDateTime = (dateString) => {
  if (!dateString) return '-'
  return new Date(dateString).toLocaleString()
}

// 开始盘点
const handleStartCheck = async () => {
  try {
    await inventoryCheckService.startCheck(check.value.ID)
    message.success('盘点已开始')
    loadCheckDetail(check.value.ID)
  } catch (error) {
    console.error('开始盘点失败:', error)
    message.error('开始盘点失败')
  }
}

// 完成盘点
const handleCompleteCheck = async () => {
  try {
    await inventoryCheckService.completeCheck(check.value.ID)
    message.success('盘点已完成')
    loadCheckDetail(check.value.ID)
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
const handleCancelCheck = async () => {
  try {
    await inventoryCheckService.cancelCheck(check.value.ID)
    message.success('盘点已取消')
    loadCheckDetail(check.value.ID)
  } catch (error) {
    console.error('取消盘点失败:', error)
    message.error('取消盘点失败')
  }
}

// 编辑盘点明细
const handleEditItem = (row) => {
  currentItem.value = row
  editForm.id = row.ID
  editForm.productName = `商品 #${row.ProductVariantID}` // 这里应该获取实际商品名称
  editForm.systemQuantity = row.SystemQuantity
  editForm.actualQuantity = row.Status === 'checked' ? row.ActualQuantity : row.SystemQuantity
  editForm.note = row.Note || ''
  showEditModal.value = true
}

// 保存盘点明细
const handleSaveCheckItem = async () => {
  try {
    const data = {
      actual_quantity: editForm.actualQuantity,
      note: editForm.note
    }
    
    await inventoryCheckService.updateCheckItem(check.value.ID, currentItem.value.ID, data)
    message.success('盘点明细已更新')
    showEditModal.value = false
    loadCheckDetail(check.value.ID)
  } catch (error) {
    console.error('更新盘点明细失败:', error)
    message.error('更新盘点明细失败')
  }
}
</script>

<style scoped>
.inventory-check-detail {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 10px;
}

.page-title {
  margin: 0;
  font-size: 24px;
}

.detail-card {
  margin-bottom: 20px;
}
</style>
