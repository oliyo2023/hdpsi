<template>
  <n-layout>
    <n-layout-header bordered>
      <n-page-header 
        title="退换货详情" 
        @back="handleBack"
      >
        <template #extra>
          <n-space>
            <n-button v-if="canApprove" type="primary" @click="handleApprove">
              审批通过
            </n-button>
            <n-button v-if="canReject" type="error" @click="handleReject">
              拒绝申请
            </n-button>
            <n-button v-if="canComplete" type="success" @click="handleComplete">
              完成处理
            </n-button>
          </n-space>
        </template>
      </n-page-header>
    </n-layout-header>

    <n-layout-content class="content">
      <n-grid :cols="2" :x-gap="24">
        <!-- 基本信息 -->
        <n-grid-item>
          <n-card title="基本信息">
            <n-descriptions bordered>
              <n-descriptions-item label="退换货单号">
                {{ returnInfo.returnNo }}
              </n-descriptions-item>
              <n-descriptions-item label="原订单号">
                {{ returnInfo.orderNo }}
              </n-descriptions-item>
              <n-descriptions-item label="申请类型">
                {{ returnInfo.type === 'RETURN' ? '退货' : '换货' }}
              </n-descriptions-item>
              <n-descriptions-item label="当前状态">
                <return-status-tag :status="returnInfo.status" />
              </n-descriptions-item>
              <n-descriptions-item label="申请时间">
                {{ returnInfo.createdAt }}
              </n-descriptions-item>
              <n-descriptions-item label="申请人">
                {{ returnInfo.applicant }}
              </n-descriptions-item>
            </n-descriptions>
          </n-card>
        </n-grid-item>

        <!-- 商品信息 -->
        <n-grid-item>
          <n-card title="商品信息">
            <n-data-table
              :columns="itemColumns"
              :data="returnInfo.items"
              :pagination="false"
            />
            
            <!-- 换货商品信息 -->
            <template v-if="returnInfo.type === 'EXCHANGE'">
              <div class="section-title">换货商品</div>
              <n-data-table
                :columns="exchangeItemColumns"
                :data="returnInfo.exchangeItems"
                :pagination="false"
              />
              <div class="price-difference">
                差价：
                <span :class="{ 'positive': priceDifference > 0, 'negative': priceDifference < 0 }">
                  {{ priceDifference > 0 ? '+' : '' }}¥{{ priceDifference }}
                </span>
              </div>
            </template>

            <!-- 退款信息 -->
            <template v-else>
              <div class="refund-info">
                退款金额：¥{{ returnInfo.refundAmount }}
              </div>
            </template>
          </n-card>
        </n-grid-item>

        <!-- 处理记录 -->
        <n-grid-item span="2">
          <n-card title="处理记录">
            <return-timeline :records="processingRecords" />
          </n-card>
        </n-grid-item>

        <!-- 凭证图片 -->
        <n-grid-item span="2">
          <n-card title="凭证图片">
            <n-image-group>
              <n-space>
                <n-image
                  v-for="(image, index) in returnInfo.attachments"
                  :key="index"
                  :src="image.url"
                  :alt="'凭证' + (index + 1)"
                  width="120"
                />
              </n-space>
            </n-image-group>
          </n-card>
        </n-grid-item>
      </n-grid>

      <!-- 审批对话框 -->
      <n-modal
        v-model:show="showApprovalModal"
        :title="approvalModalTitle"
        preset="dialog"
        positive-text="确认"
        negative-text="取消"
        @positive-click="handleApprovalConfirm"
        @negative-click="handleApprovalCancel"
      >
        <n-form :model="approvalForm">
          <n-form-item label="处理意见">
            <n-input
              v-model:value="approvalForm.remarks"
              type="textarea"
              placeholder="请输入处理意见"
            />
          </n-form-item>
        </n-form>
      </n-modal>
    </n-layout-content>
  </n-layout>
</template>

<script setup>
import { ref, computed, h, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import {
  NLayout,
  NLayoutHeader,
  NLayoutContent,
  NPageHeader,
  NCard,
  NGrid,
  NGridItem,
  NDescriptions,
  NDescriptionsItem,
  NDataTable,
  NSpace,
  NButton,
  NModal,
  NForm,
  NFormItem,
  NInput,
  NImage,
  NImageGroup,
  useMessage
} from 'naive-ui'
import ReturnStatusTag from '@/components/sales/ReturnStatusTag.vue'
import ReturnTimeline from '@/components/sales/ReturnTimeline.vue'
import {
  CheckmarkCircle,
  CloseCircle,
  Time,
  Create
} from '@vicons/ionicons5'

const router = useRouter()
const route = useRoute()
const message = useMessage()

// 模拟数据
const returnInfo = ref({
  returnNo: 'RT20230001',
  orderNo: 'ORD20230001',
  type: 'RETURN',
  status: 'PENDING',
  createdAt: '2023-01-01 10:00:00',
  applicant: '张三',
  items: [
    {
      id: 1,
      productName: '商品1',
      quantity: 1,
      price: 199.00,
      reason: '质量问题'
    }
  ],
  exchangeItems: [],
  refundAmount: 199.00,
  attachments: [
    { url: 'https://example.com/image1.jpg' }
  ]
})

// 商品列表列定义
const itemColumns = [
  {
    title: '商品名称',
    key: 'productName'
  },
  {
    title: '数量',
    key: 'quantity'
  },
  {
    title: '单价',
    key: 'price',
    render: (row) => `¥${row.price}`
  },
  {
    title: '退换原因',
    key: 'reason'
  }
]

// 换货商品列表列定义
const exchangeItemColumns = [
  {
    title: '商品名称',
    key: 'productName'
  },
  {
    title: '数量',
    key: 'quantity'
  },
  {
    title: '单价',
    key: 'price',
    render: (row) => `¥${row.price}`
  }
]

// 处理记录
const processingRecords = ref([
  {
    id: 1,
    type: 'info',
    title: '提交申请',
    content: '用户提交退换货申请',
    time: '2023-01-01 10:00:00'
  }
])

// 差价计算
const priceDifference = computed(() => {
  if (returnInfo.value.type !== 'EXCHANGE') return 0
  // TODO: 实现差价计算逻辑
  return 0
})

// 状态相关
const getStatusType = (status) => {
  const typeMap = {
    PENDING: 'warning',
    APPROVED: 'success',
    REJECTED: 'error',
    COMPLETED: 'success'
  }
  return typeMap[status] || 'default'
}

const getStatusText = (status) => {
  const textMap = {
    PENDING: '待处理',
    APPROVED: '已批准',
    REJECTED: '已拒绝',
    COMPLETED: '已完成'
  }
  return textMap[status] || status
}

// 操作权限
const canApprove = computed(() => returnInfo.value.status === 'PENDING')
const canReject = computed(() => returnInfo.value.status === 'PENDING')
const canComplete = computed(() => returnInfo.value.status === 'APPROVED')

// 审批相关
const showApprovalModal = ref(false)
const approvalModalTitle = ref('')
const approvalForm = ref({
  remarks: ''
})
let currentAction = ref(null)

const handleApprove = () => {
  approvalModalTitle.value = '审批通过'
  currentAction.value = 'approve'
  showApprovalModal.value = true
}

const handleReject = () => {
  approvalModalTitle.value = '拒绝申请'
  currentAction.value = 'reject'
  showApprovalModal.value = true
}

const handleComplete = () => {
  approvalModalTitle.value = '完成处理'
  currentAction.value = 'complete'
  showApprovalModal.value = true
}

const handleApprovalConfirm = async () => {
  try {
    // TODO: 调用API处理审批
    message.success('处理成功')
    showApprovalModal.value = false
    // 重新加载数据
    await loadReturnInfo()
  } catch (error) {
    message.error('处理失败')
  }
}

const handleApprovalCancel = () => {
  showApprovalModal.value = false
  approvalForm.value.remarks = ''
}

// 获取时间线图标
const getTimelineIcon = (type) => {
  const iconMap = {
    success: CheckmarkCircle,
    error: CloseCircle,
    info: Time,
    warning: Create
  }
  return iconMap[type] || Time
}

// 加载退换货信息
const loadReturnInfo = async () => {
  try {
    // TODO: 调用API获取退换货详情
  } catch (error) {
    message.error('加载数据失败')
  }
}

// 返回列表页
const handleBack = () => {
  router.back()
}

// 页面加载时获取数据
onMounted(() => {
  const id = route.params.id
  if (id) {
    loadReturnInfo()
  }
})
</script>

<style scoped>
.content {
  padding: 24px;
  background-color: #f8fafc;
}

.n-layout-header {
  padding: 0 24px;
  margin-bottom: 24px;
}

.n-card {
  margin-bottom: 24px;
  border-radius: 8px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.02);
}

.n-grid {
  margin-bottom: 24px;
}

.section-title {
  margin: 24px 0 16px;
  font-size: 16px;
  font-weight: 500;
  color: #333;
}

.price-difference {
  margin: 16px 0;
  padding: 12px 16px;
  background-color: #f8f8f8;
  border-radius: 6px;
  text-align: right;
  font-size: 16px;
}

.positive {
  color: #18a058;
  font-weight: 500;
}

.negative {
  color: #d03050;
  font-weight: 500;
}

.refund-info {
  margin: 16px 0;
  padding: 12px 16px;
  background-color: #f8f8f8;
  border-radius: 6px;
  text-align: right;
  font-size: 16px;
  font-weight: 500;
}

.n-space {
  justify-content: flex-end;
  margin-top: 24px;
}

.n-button {
  min-width: 120px;
}

@media (max-width: 768px) {
  .content {
    padding: 16px;
  }
  
  .n-layout-header {
    padding: 0 16px;
  }
  
  .n-grid {
    grid-template-columns: 1fr !important;
    gap: 16px;
  }
  
  .n-space {
    flex-direction: column;
    gap: 12px;
  }
  
  .n-button {
    width: 100%;
  }
}
</style>