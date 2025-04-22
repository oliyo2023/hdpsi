<template>
  <div class="member-points">
    <div class="page-header">
      <div class="header-left">
        <n-icon size="24" class="header-icon">
          <WalletOutline />
        </n-icon>
        <div>
          <h1 class="page-title">会员积分管理</h1>
          <p class="page-subtitle">{{ memberInfo.name }} - {{ memberInfo.phone }}</p>
        </div>
      </div>
      <div class="header-actions">
        <n-space>
          <n-button @click="goBack" class="btn-back">
            <template #icon>
              <n-icon><ArrowBackOutline /></n-icon>
            </template>
            返回
          </n-button>
          <n-button type="primary" @click="showAddPointsModal = true">
            <template #icon>
              <n-icon><AddCircleOutline /></n-icon>
            </template>
            添加积分
          </n-button>
          <n-button type="warning" @click="showDeductPointsModal = true">
            <template #icon>
              <n-icon><RemoveCircleOutline /></n-icon>
            </template>
            扣减积分
          </n-button>
        </n-space>
      </div>
    </div>

    <div class="page-content">
      <n-spin :show="loading">
        <!-- 积分概览卡片 -->
        <n-card title="积分概览" class="points-overview">
          <n-grid :cols="3" :x-gap="16">
            <n-gi>
              <div class="stat-card">
                <div class="stat-title">当前积分</div>
                <div class="stat-value">{{ memberInfo.points || 0 }}</div>
              </div>
            </n-gi>
            <n-gi>
              <div class="stat-card">
                <div class="stat-title">累计获得</div>
                <div class="stat-value">{{ totalEarnedPoints }}</div>
              </div>
            </n-gi>
            <n-gi>
              <div class="stat-card">
                <div class="stat-title">累计使用</div>
                <div class="stat-value">{{ totalUsedPoints }}</div>
              </div>
            </n-gi>
          </n-grid>
        </n-card>

        <!-- 积分交易记录 -->
        <n-card title="积分交易记录" class="points-transactions">
          <div class="table-toolbar">
            <div class="table-search">
              <n-date-picker
                v-model:value="searchForm.dateRange"
                type="daterange"
                clearable
                placeholder="选择日期范围"
                style="width: 240px"
              />
              <n-select
                v-model:value="searchForm.type"
                placeholder="交易类型"
                clearable
                :options="transactionTypeOptions"
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

          <n-data-table
            ref="tableRef"
            :columns="columns"
            :data="transactions"
            :loading="transactionsLoading"
            :pagination="pagination"
            :row-key="row => row.id"
            @update:page="handlePageChange"
            @update:page-size="handlePageSizeChange"
          />
        </n-card>
      </n-spin>
    </div>

    <!-- 添加积分模态框 -->
    <n-modal
      v-model:show="showAddPointsModal"
      preset="card"
      title="添加积分"
      style="width: 500px"
      :mask-closable="false"
    >
      <n-form
        ref="addPointsFormRef"
        :model="addPointsForm"
        :rules="pointsFormRules"
        label-placement="left"
        label-width="auto"
        require-mark-placement="right-hanging"
      >
        <n-form-item label="积分数量" path="points">
          <n-input-number
            v-model:value="addPointsForm.points"
            :min="1"
            placeholder="请输入积分数量"
            style="width: 100%"
          />
        </n-form-item>
        <n-form-item label="交易类型" path="type">
          <n-select
            v-model:value="addPointsForm.type"
            :options="addPointsTypeOptions"
            placeholder="请选择交易类型"
          />
        </n-form-item>
        <n-form-item label="备注" path="note">
          <n-input
            v-model:value="addPointsForm.note"
            type="textarea"
            placeholder="请输入备注信息"
            :autosize="{ minRows: 3, maxRows: 5 }"
          />
        </n-form-item>
      </n-form>
      <template #footer>
        <n-space justify="end">
          <n-button @click="showAddPointsModal = false">取消</n-button>
          <n-button type="primary" @click="handleAddPoints" :loading="submitting">确认</n-button>
        </n-space>
      </template>
    </n-modal>

    <!-- 扣减积分模态框 -->
    <n-modal
      v-model:show="showDeductPointsModal"
      preset="card"
      title="扣减积分"
      style="width: 500px"
      :mask-closable="false"
    >
      <n-form
        ref="deductPointsFormRef"
        :model="deductPointsForm"
        :rules="pointsFormRules"
        label-placement="left"
        label-width="auto"
        require-mark-placement="right-hanging"
      >
        <n-form-item label="积分数量" path="points">
          <n-input-number
            v-model:value="deductPointsForm.points"
            :min="1"
            :max="memberInfo.points || 0"
            placeholder="请输入积分数量"
            style="width: 100%"
          />
        </n-form-item>
        <n-form-item label="交易类型" path="type">
          <n-select
            v-model:value="deductPointsForm.type"
            :options="deductPointsTypeOptions"
            placeholder="请选择交易类型"
          />
        </n-form-item>
        <n-form-item label="备注" path="note">
          <n-input
            v-model:value="deductPointsForm.note"
            type="textarea"
            placeholder="请输入备注信息"
            :autosize="{ minRows: 3, maxRows: 5 }"
          />
        </n-form-item>
      </n-form>
      <template #footer>
        <n-space justify="end">
          <n-button @click="showDeductPointsModal = false">取消</n-button>
          <n-button type="primary" @click="handleDeductPoints" :loading="submitting">确认</n-button>
        </n-space>
      </template>
    </n-modal>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, h } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import {
  NButton, NCard, NDataTable, NForm, NFormItem, NGrid, NGi, NInput,
  NInputNumber, NSelect, NSpace, NIcon, NDatePicker, useMessage,
  NSpin, NModal, NTag
} from 'naive-ui'
import {
  WalletOutline, ArrowBackOutline, AddCircleOutline,
  RemoveCircleOutline, TimeOutline
} from '@vicons/ionicons5'
import memberService from '../services/member'

// 路由
const router = useRouter()
const route = useRoute()
const message = useMessage()

// 会员ID
const memberId = route.params.id

// 状态
const loading = ref(true)
const transactionsLoading = ref(false)
const submitting = ref(false)
const memberInfo = ref({})
const transactions = ref([])
const showAddPointsModal = ref(false)
const showDeductPointsModal = ref(false)

// 表单引用
const addPointsFormRef = ref(null)
const deductPointsFormRef = ref(null)

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

// 搜索表单
const searchForm = reactive({
  dateRange: null,
  type: null
})

// 添加积分表单
const addPointsForm = reactive({
  points: 0,
  type: 'purchase',
  note: ''
})

// 扣减积分表单
const deductPointsForm = reactive({
  points: 0,
  type: 'redeem',
  note: ''
})

// 表单验证规则
const pointsFormRules = {
  points: {
    required: true,
    type: 'number',
    message: '请输入积分数量',
    trigger: ['blur', 'change'],
    validator(rule, value) {
      if (!value || value <= 0) {
        return new Error('积分数量必须大于0')
      }
      return true
    }
  },
  type: {
    required: true,
    message: '请选择交易类型',
    trigger: ['blur', 'change']
  }
}

// 交易类型选项
const transactionTypeOptions = [
  { label: '全部类型', value: '' },
  { label: '购物获得', value: 'purchase' },
  { label: '活动奖励', value: 'promotion' },
  { label: '注册奖励', value: 'register' },
  { label: '积分兑换', value: 'redeem' },
  { label: '积分过期', value: 'expired' },
  { label: '手动调整', value: 'adjustment' }
]

// 添加积分类型选项
const addPointsTypeOptions = [
  { label: '购物获得', value: 'purchase' },
  { label: '活动奖励', value: 'promotion' },
  { label: '注册奖励', value: 'register' },
  { label: '手动调整', value: 'adjustment' }
]

// 扣减积分类型选项
const deductPointsTypeOptions = [
  { label: '积分兑换', value: 'redeem' },
  { label: '积分过期', value: 'expired' },
  { label: '手动调整', value: 'adjustment' }
]

// 计算属性
const totalEarnedPoints = computed(() => {
  // 如果没有交易记录，直接返回0
  if (transactions.value.length === 0) return 0

  return transactions.value
    .filter(t => t.amount > 0)
    .reduce((sum, t) => sum + t.amount, 0)
})

const totalUsedPoints = computed(() => {
  // 如果没有交易记录，直接返回0
  if (transactions.value.length === 0) return 0

  return transactions.value
    .filter(t => t.amount < 0)
    .reduce((sum, t) => sum + Math.abs(t.amount), 0)
})

// 表格列定义
const columns = [
  {
    title: '交易ID',
    key: 'id',
    width: 80
  },
  {
    title: '交易时间',
    key: 'createdAt',
    width: 160,
    render(row) {
      return h('div', {}, [
        h(NIcon, { style: 'margin-right: 4px;' }, { default: () => h(TimeOutline) }),
        // 添加空值检查
        row.createdAt ? new Date(row.createdAt).toLocaleString() : '-'
      ])
    }
  },
  {
    title: '交易类型',
    key: 'type',
    width: 120,
    render(row) {
      const typeMap = {
        'purchase': { type: 'success', text: '购物获得' },
        'promotion': { type: 'info', text: '活动奖励' },
        'register': { type: 'primary', text: '注册奖励' },
        'redeem': { type: 'warning', text: '积分兑换' },
        'expired': { type: 'error', text: '积分过期' },
        'adjustment': { type: 'default', text: '手动调整' }
      }

      const type = typeMap[row.type] || typeMap['adjustment']

      return h(NTag, { type: type.type }, { default: () => type.text })
    }
  },
  {
    title: '积分变动',
    key: 'amount',
    width: 100,
    render(row) {
      const isPositive = row.amount > 0
      return h('span', {
        style: {
          color: isPositive ? '#18a058' : '#d03050',
          fontWeight: 'bold'
        }
      }, isPositive ? `+${row.amount}` : row.amount)
    }
  },
  {
    title: '交易后积分',
    key: 'balance',
    width: 100
  },
  {
    title: '关联订单',
    key: 'orderId',
    width: 120
  },
  {
    title: '备注',
    key: 'note',
    width: 200
  },
  {
    title: '操作人',
    key: 'operator',
    width: 120
  }
]

// 方法
// 加载会员信息
const loadMemberInfo = async () => {
  loading.value = true
  try {
    const response = await memberService.getMember(memberId)
    memberInfo.value = response
  } catch (error) {
    console.error('加载会员信息失败:', error)
    message.error('加载会员信息失败: ' + (error.response?.data?.error || '未知错误'))
  } finally {
    loading.value = false
  }
}

// 加载积分交易记录
const loadTransactions = async () => {
  transactionsLoading.value = true
  try {
    // 构建查询参数
    const params = {
      page: pagination.page,
      limit: pagination.pageSize,
      type: searchForm.type || undefined
    }

    // 处理日期范围
    if (searchForm.dateRange && searchForm.dateRange.length === 2) {
      params.startDate = new Date(searchForm.dateRange[0]).toISOString()
      params.endDate = new Date(searchForm.dateRange[1]).toISOString()
    }

    const response = await memberService.getMemberPointsTransactions(memberId, params)

    // 处理响应数据
    if (response && response.items) {
      // 将后端返回的数据转换为前端需要的格式
      transactions.value = response.items.map(item => ({
        id: item.ID,
        createdAt: item.CreatedAt,
        type: item.Type,
        amount: item.Points,  // 积分变动
        balance: item.Balance,  // 交易后余额
        orderId: item.ReferenceID ? `ORD${item.ReferenceID}` : null,
        note: item.Description,
        operator: `ID:${item.OperatorID}`  // 暂时只有操作人ID
      }))
      pagination.itemCount = response.total || 0

      // 更新会员信息
      if (response.member) {
        memberInfo.value = response.member
      }
    } else {
      console.error('响应数据格式不正确:', response)
      message.error('加载积分交易记录失败: 数据格式不正确')
      transactions.value = []
      pagination.itemCount = 0
    }
  } catch (error) {
    console.error('加载积分交易记录失败:', error)
    message.error('加载积分交易记录失败: ' + (error.response?.data?.error || '未知错误'))
    transactions.value = []
    pagination.itemCount = 0
  } finally {
    transactionsLoading.value = false
  }
}

// 搜索
const handleSearch = () => {
  pagination.page = 1
  loadTransactions()
}

// 重置搜索
const resetSearch = () => {
  searchForm.dateRange = null
  searchForm.type = null
  pagination.page = 1
  loadTransactions()
}

// 分页
const handlePageChange = (page) => {
  pagination.page = page
  loadTransactions()
}

const handlePageSizeChange = (pageSize) => {
  pagination.pageSize = pageSize
  pagination.page = 1
  loadTransactions()
}

// 返回上一页
const goBack = () => {
  router.back()
}

// 添加积分
const handleAddPoints = () => {
  addPointsFormRef.value?.validate(async (errors) => {
    if (errors) {
      return
    }

    submitting.value = true
    try {
      await memberService.addMemberPoints(memberId, addPointsForm)

      message.success('积分添加成功')
      showAddPointsModal.value = false

      // 重新加载数据
      await loadMemberInfo()
      await loadTransactions()

      // 重置表单
      addPointsForm.points = 0
      addPointsForm.type = 'purchase'
      addPointsForm.note = ''
    } catch (error) {
      console.error('添加积分失败:', error)
      message.error('添加积分失败: ' + (error.response?.data?.error || '未知错误'))
    } finally {
      submitting.value = false
    }
  })
}

// 扣减积分
const handleDeductPoints = () => {
  deductPointsFormRef.value?.validate(async (errors) => {
    if (errors) {
      return
    }

    // 检查积分是否足够
    if (deductPointsForm.points > memberInfo.value.points) {
      message.error('会员积分不足')
      return
    }

    submitting.value = true
    try {
      await memberService.deductMemberPoints(memberId, deductPointsForm)

      message.success('积分扣减成功')
      showDeductPointsModal.value = false

      // 重新加载数据
      await loadMemberInfo()
      await loadTransactions()

      // 重置表单
      deductPointsForm.points = 0
      deductPointsForm.type = 'redeem'
      deductPointsForm.note = ''
    } catch (error) {
      console.error('扣减积分失败:', error)
      message.error('扣减积分失败: ' + (error.response?.data?.error || '未知错误'))
    } finally {
      submitting.value = false
    }
  })
}

// 生命周期钩子
onMounted(async () => {
  await loadMemberInfo()
  await loadTransactions()
})
</script>

<style scoped>
.member-points {
  padding: 16px;
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
  gap: 12px;
}

.header-icon {
  color: var(--primary-color);
}

.page-title {
  margin: 0;
  font-size: 20px;
  font-weight: 500;
}

.page-subtitle {
  margin: 4px 0 0;
  font-size: 14px;
  color: var(--text-color-secondary);
}

.points-overview {
  margin-bottom: 16px;
}

.stat-card {
  padding: 16px;
  text-align: center;
  border-radius: 4px;
  background-color: var(--card-color);
}

.stat-title {
  font-size: 14px;
  color: var(--text-color-secondary);
  margin-bottom: 8px;
}

.stat-value {
  font-size: 24px;
  font-weight: bold;
  color: var(--primary-color);
}

.table-toolbar {
  margin-bottom: 16px;
}

.table-search {
  display: flex;
  gap: 8px;
}

.btn-back {
  margin-right: 8px;
}
</style>
