<template>
  <div class="sales-order-detail">
    <div class="page-header">
      <div class="header-left">
        <n-button text @click="handleBack">
          <template #icon>
            <n-icon><ArrowBackOutline /></n-icon>
          </template>
          返回
        </n-button>
        <h1 class="page-title">销售订单详情</h1>
      </div>
      <div class="header-right">
        <n-space>
          <n-button
            v-if="['draft', 'pending'].includes(order.status)"
            type="primary"
            @click="handleEdit"
          >
            <template #icon>
              <n-icon><CreateOutline /></n-icon>
            </template>
            编辑订单
          </n-button>
          <n-button
            v-if="order.paymentStatus !== 'paid'"
            type="success"
            @click="showPaymentModal = true"
          >
            <template #icon>
              <n-icon><CardOutline /></n-icon>
            </template>
            添加支付
          </n-button>
          <n-button @click="handlePrint">
            <template #icon>
              <n-icon><PrintOutline /></n-icon>
            </template>
            打印订单
          </n-button>
        </n-space>
      </div>
    </div>

    <n-spin :show="loading">
      <div class="order-content">
        <!-- 订单基本信息 -->
        <n-card title="订单信息" class="info-card">
          <n-descriptions :column="3" bordered>
            <n-descriptions-item label="订单号">
              {{ order.orderNumber }}
            </n-descriptions-item>
            <n-descriptions-item label="订单状态">
              <n-tag :type="getStatusType(order.status)">
                {{ formatStatus(order.status) }}
              </n-tag>
            </n-descriptions-item>
            <n-descriptions-item label="订单类型">
              {{ formatOrderType(order.orderType) }}
            </n-descriptions-item>
            <n-descriptions-item label="客户姓名">
              {{ order.customerName }}
            </n-descriptions-item>
            <n-descriptions-item label="客户电话">
              {{ order.customerPhone || '-' }}
            </n-descriptions-item>
            <n-descriptions-item label="客户地址">
              {{ order.customerAddress || '-' }}
            </n-descriptions-item>
            <n-descriptions-item label="销售店铺">
              {{ order.store?.name || '-' }}
            </n-descriptions-item>
            <n-descriptions-item label="销售员">
              {{ order.salesperson?.name || '-' }}
            </n-descriptions-item>
            <n-descriptions-item label="收银员">
              {{ order.cashier?.name || '-' }}
            </n-descriptions-item>
            <n-descriptions-item label="下单时间">
              {{ formatDateTime(order.orderDate) }}
            </n-descriptions-item>
            <n-descriptions-item label="完成时间">
              {{ formatDateTime(order.completedAt) }}
            </n-descriptions-item>
            <n-descriptions-item label="备注">
              {{ order.note || '-' }}
            </n-descriptions-item>
          </n-descriptions>
        </n-card>

        <!-- 会员信息 -->
        <n-card v-if="order.member" title="会员信息" class="info-card">
          <n-descriptions :column="3" bordered>
            <n-descriptions-item label="会员姓名">
              {{ order.member.name }}
            </n-descriptions-item>
            <n-descriptions-item label="会员电话">
              {{ order.member.phone }}
            </n-descriptions-item>
            <n-descriptions-item label="会员等级">
              {{ order.member.level }}
            </n-descriptions-item>
            <n-descriptions-item label="当前积分">
              {{ order.member.points }}
            </n-descriptions-item>
            <n-descriptions-item label="累计消费">
              ¥{{ order.member.totalSpent?.toFixed(2) || '0.00' }}
            </n-descriptions-item>
          </n-descriptions>
        </n-card>

        <!-- 订单明细 -->
        <n-card title="订单明细" class="info-card">
          <n-data-table
            :columns="itemColumns"
            :data="order.items || []"
            :pagination="false"
            :bordered="false"
          />
          
          <!-- 金额汇总 -->
          <div class="amount-summary">
            <n-descriptions :column="1" size="small">
              <n-descriptions-item label="商品小计">
                ¥{{ order.subtotalAmount?.toFixed(2) || '0.00' }}
              </n-descriptions-item>
              <n-descriptions-item label="折扣金额">
                -¥{{ order.discountAmount?.toFixed(2) || '0.00' }}
              </n-descriptions-item>
              <n-descriptions-item label="积分抵扣">
                -¥{{ order.pointsDiscount?.toFixed(2) || '0.00' }}
              </n-descriptions-item>
              <n-descriptions-item label="订单总额">
                <span class="total-amount">¥{{ order.totalAmount?.toFixed(2) || '0.00' }}</span>
              </n-descriptions-item>
            </n-descriptions>
          </div>
        </n-card>

        <!-- 支付信息 -->
        <n-card title="支付信息" class="info-card">
          <n-descriptions :column="3" bordered>
            <n-descriptions-item label="支付状态">
              <n-tag :type="getPaymentStatusType(order.paymentStatus)">
                {{ formatPaymentStatus(order.paymentStatus) }}
              </n-tag>
            </n-descriptions-item>
            <n-descriptions-item label="支付方式">
              {{ formatPaymentMethod(order.paymentMethod) }}
            </n-descriptions-item>
            <n-descriptions-item label="支付时间">
              {{ formatDateTime(order.paymentTime) }}
            </n-descriptions-item>
            <n-descriptions-item label="已付金额">
              ¥{{ order.paidAmount?.toFixed(2) || '0.00' }}
            </n-descriptions-item>
            <n-descriptions-item label="待付金额">
              ¥{{ ((order.totalAmount || 0) - (order.paidAmount || 0)).toFixed(2) }}
            </n-descriptions-item>
            <n-descriptions-item label="交易流水号">
              {{ order.transactionId || '-' }}
            </n-descriptions-item>
          </n-descriptions>

          <!-- 支付记录 -->
          <div v-if="order.payments && order.payments.length > 0" class="payment-records">
            <h4>支付记录</h4>
            <n-data-table
              :columns="paymentColumns"
              :data="order.payments"
              :pagination="false"
              size="small"
            />
          </div>
        </n-card>

        <!-- 试衣信息 -->
        <n-card v-if="order.fittingRoomId" title="试衣信息" class="info-card">
          <n-descriptions :column="3" bordered>
            <n-descriptions-item label="试衣间">
              {{ order.fittingRoomId }}
            </n-descriptions-item>
            <n-descriptions-item label="试衣时长">
              {{ order.fittingDuration ? `${order.fittingDuration}分钟` : '-' }}
            </n-descriptions-item>
            <n-descriptions-item label="试衣备注">
              {{ order.fittingNote || '-' }}
            </n-descriptions-item>
          </n-descriptions>
        </n-card>

        <!-- 操作日志 -->
        <n-card v-if="order.logs && order.logs.length > 0" title="操作日志" class="info-card">
          <n-timeline>
            <n-timeline-item
              v-for="log in order.logs"
              :key="log.id"
              :time="formatDateTime(log.createdAt)"
            >
              <template #header>
                <span class="log-action">{{ log.action }}</span>
              </template>
              <div class="log-content">
                <div class="log-description">{{ log.description }}</div>
                <div v-if="log.operator" class="log-operator">
                  操作人：{{ log.operator.name }}
                </div>
                <div v-if="log.oldValue" class="log-change">
                  原值：{{ log.oldValue }}
                </div>
                <div v-if="log.newValue" class="log-change">
                  新值：{{ log.newValue }}
                </div>
              </div>
            </n-timeline-item>
          </n-timeline>
        </n-card>
      </div>
    </n-spin>

    <!-- 支付对话框 -->
    <n-modal v-model:show="showPaymentModal" preset="dialog" title="添加支付">
      <n-form ref="paymentFormRef" :model="paymentForm" :rules="paymentRules">
        <n-form-item label="支付方式" path="payment_method">
          <n-select
            v-model:value="paymentForm.payment_method"
            placeholder="请选择支付方式"
            :options="paymentMethodOptions"
          />
        </n-form-item>
        <n-form-item label="支付金额" path="amount">
          <n-input-number
            v-model:value="paymentForm.amount"
            placeholder="请输入支付金额"
            :min="0"
            :max="remainingAmount"
            :precision="2"
            style="width: 100%"
          />
        </n-form-item>
        <n-form-item label="交易流水号" path="transaction_id">
          <n-input
            v-model:value="paymentForm.transaction_id"
            placeholder="请输入交易流水号"
          />
        </n-form-item>
        <n-form-item label="备注" path="note">
          <n-input
            v-model:value="paymentForm.note"
            type="textarea"
            placeholder="请输入备注"
            :rows="3"
          />
        </n-form-item>
      </n-form>
      <template #action>
        <n-space>
          <n-button @click="showPaymentModal = false">取消</n-button>
          <n-button type="primary" @click="handleConfirmPayment">确认支付</n-button>
        </n-space>
      </template>
    </n-modal>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, h } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useMessage } from 'naive-ui'
import {
  ArrowBackOutline,
  CreateOutline,
  CardOutline,
  PrintOutline
} from '@vicons/ionicons5'
import salesOrderService from '../services/salesOrderService'

const route = useRoute()
const router = useRouter()
const message = useMessage()

// 响应式数据
const loading = ref(false)
const order = ref({})
const showPaymentModal = ref(false)

// 支付表单
const paymentForm = reactive({
  payment_method: '',
  amount: 0,
  transaction_id: '',
  note: ''
})

const paymentRules = {
  payment_method: [
    { required: true, message: '请选择支付方式', trigger: 'change' }
  ],
  amount: [
    { required: true, message: '请输入支付金额', trigger: 'blur' },
    { type: 'number', min: 0.01, message: '支付金额必须大于0', trigger: 'blur' }
  ]
}

// 计算属性
const remainingAmount = computed(() => {
  return (order.value.totalAmount || 0) - (order.value.paidAmount || 0)
})

const paymentMethodOptions = computed(() => {
  return salesOrderService.getPaymentMethodOptions()
})

// 表格列定义
const itemColumns = [
  {
    title: '商品名称',
    key: 'productName',
    width: 200
  },
  {
    title: 'SKU',
    key: 'productSku',
    width: 120
  },
  {
    title: '数量',
    key: 'quantity',
    width: 80,
    align: 'center'
  },
  {
    title: '单价',
    key: 'unitPrice',
    width: 100,
    render(row) {
      return `¥${row.unitPrice.toFixed(2)}`
    }
  },
  {
    title: '原价',
    key: 'originalPrice',
    width: 100,
    render(row) {
      return `¥${row.originalPrice.toFixed(2)}`
    }
  },
  {
    title: '折扣',
    key: 'discountAmount',
    width: 100,
    render(row) {
      return row.discountAmount > 0 ? `-¥${row.discountAmount.toFixed(2)}` : '-'
    }
  },
  {
    title: '小计',
    key: 'totalPrice',
    width: 120,
    render(row) {
      return `¥${row.totalPrice.toFixed(2)}`
    }
  },
  {
    title: '试穿',
    key: 'isTried',
    width: 80,
    render(row) {
      return row.isTried ? '是' : '否'
    }
  },
  {
    title: '备注',
    key: 'note',
    ellipsis: {
      tooltip: true
    }
  }
]

const paymentColumns = [
  {
    title: '支付方式',
    key: 'paymentMethod',
    render(row) {
      return salesOrderService.formatPaymentMethod(row.paymentMethod)
    }
  },
  {
    title: '支付金额',
    key: 'amount',
    render(row) {
      return `¥${row.amount.toFixed(2)}`
    }
  },
  {
    title: '交易流水号',
    key: 'transactionId'
  },
  {
    title: '支付时间',
    key: 'paymentTime',
    render(row) {
      return formatDateTime(row.paymentTime)
    }
  },
  {
    title: '状态',
    key: 'status'
  },
  {
    title: '备注',
    key: 'note'
  }
]

// 生命周期
onMounted(() => {
  const id = route.params.id
  if (id) {
    loadOrderDetail(id)
  }
})

// 加载订单详情
const loadOrderDetail = async (id) => {
  loading.value = true
  try {
    const response = await salesOrderService.getSalesOrder(id)
    order.value = response
  } catch (error) {
    console.error('加载订单详情失败:', error)
    message.error('加载订单详情失败')
  } finally {
    loading.value = false
  }
}

// 格式化方法
const formatStatus = (status) => {
  return salesOrderService.formatStatus(status)
}

const formatOrderType = (type) => {
  return salesOrderService.formatOrderType(type)
}

const formatPaymentMethod = (method) => {
  return salesOrderService.formatPaymentMethod(method)
}

const formatPaymentStatus = (status) => {
  return salesOrderService.formatPaymentStatus(status)
}

const formatDateTime = (dateTime) => {
  if (!dateTime) return '-'
  return new Date(dateTime).toLocaleString()
}

const getStatusType = (status) => {
  const statusOptions = salesOrderService.getStatusOptions()
  const option = statusOptions.find(opt => opt.value === status)
  return option?.type || 'default'
}

const getPaymentStatusType = (status) => {
  const statusOptions = salesOrderService.getPaymentStatusOptions()
  const option = statusOptions.find(opt => opt.value === status)
  return option?.type || 'default'
}

// 事件处理
const handleBack = () => {
  router.back()
}

const handleEdit = () => {
  router.push(`/sales/${order.value.id}/edit`)
}

const handlePrint = () => {
  window.print()
}

const handleConfirmPayment = async () => {
  try {
    await salesOrderService.addPayment(order.value.id, paymentForm)
    message.success('支付记录添加成功')
    showPaymentModal.value = false
    
    // 重新加载订单详情
    loadOrderDetail(order.value.id)
    
    // 重置表单
    Object.keys(paymentForm).forEach(key => {
      paymentForm[key] = key === 'amount' ? 0 : ''
    })
  } catch (error) {
    console.error('添加支付记录失败:', error)
    message.error('添加支付记录失败')
  }
}
</script>

<style scoped>
.sales-order-detail {
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

.page-title {
  margin: 0;
  font-size: 24px;
  font-weight: 600;
}

.order-content {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.info-card {
  margin-bottom: 16px;
}

.amount-summary {
  margin-top: 16px;
  padding: 16px;
  background-color: var(--n-color-target);
  border-radius: 6px;
  text-align: right;
}

.total-amount {
  font-size: 18px;
  font-weight: 600;
  color: var(--n-color-primary);
}

.payment-records {
  margin-top: 16px;
}

.payment-records h4 {
  margin: 0 0 12px 0;
  font-size: 16px;
  font-weight: 600;
}

.log-action {
  font-weight: 600;
  color: var(--n-color-primary);
}

.log-content {
  margin-top: 4px;
}

.log-description {
  margin-bottom: 4px;
}

.log-operator,
.log-change {
  font-size: 12px;
  color: var(--n-text-color-disabled);
  margin-bottom: 2px;
}

@media print {
  .page-header {
    display: none;
  }
  
  .order-content {
    margin: 0;
    padding: 0;
  }
}
</style>
