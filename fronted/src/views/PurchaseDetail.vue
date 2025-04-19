<template>
  <div class="purchase-detail">
    <div class="page-header">
      <div>
        <h1 class="page-title">采购单详情</h1>
        <p class="page-subtitle">{{ purchase.orderNumber }}</p>
      </div>
      <div>
        <n-space>
          <n-button @click="goBack">返回</n-button>
          <n-button
            type="primary"
            v-if="purchase.status === 'draft'"
            @click="handleEdit"
          >
            编辑
          </n-button>
          <n-button
            type="info"
            v-if="purchase.status === 'draft'"
            @click="handleSubmit"
          >
            提交审核
          </n-button>
          <n-button
            type="success"
            v-if="purchase.status === 'pending'"
            @click="handleApprove"
          >
            审核通过
          </n-button>
          <n-button
            type="error"
            v-if="purchase.status === 'pending'"
            @click="handleReject"
          >
            审核拒绝
          </n-button>
          <n-button
            type="warning"
            v-if="purchase.status === 'approved'"
            @click="handleOrder"
          >
            确认下单
          </n-button>
          <n-button
            type="info"
            v-if="['approved', 'ordered', 'receiving'].includes(purchase.status)"
            @click="handleReceiving"
          >
            创建入库单
          </n-button>
        </n-space>
      </div>
    </div>

    <div class="page-content">
      <n-card title="基本信息">
        <n-grid :cols="3" :x-gap="24">
          <n-grid-item>
            <n-space vertical>
              <div class="info-item">
                <span class="info-label">采购单号：</span>
                <span class="info-value">{{ purchase.orderNumber }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">状态：</span>
                <n-tag :type="getStatusType(purchase.status)">
                  {{ getStatusText(purchase.status) }}
                </n-tag>
              </div>
            </n-space>
          </n-grid-item>

          <n-grid-item>
            <n-space vertical>
              <div class="info-item">
                <span class="info-label">供应商：</span>
                <span class="info-value">{{ purchase.supplierName }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">店铺：</span>
                <span class="info-value">{{ purchase.storeName }}</span>
              </div>
            </n-space>
          </n-grid-item>

          <n-grid-item>
            <n-space vertical>
              <div class="info-item">
                <span class="info-label">预计到货日期：</span>
                <span class="info-value">{{ purchase.expectedDate }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">创建时间：</span>
                <span class="info-value">{{ purchase.createdAt }}</span>
              </div>
            </n-space>
          </n-grid-item>
        </n-grid>

        <div class="info-item" v-if="purchase.note">
          <span class="info-label">备注：</span>
          <span class="info-value">{{ purchase.note }}</span>
        </div>
      </n-card>

      <n-card title="采购明细" class="mt-4">
        <n-data-table
          :columns="itemColumns"
          :data="purchase.items"
          :bordered="false"
        />

        <div class="total-amount">
          <span>总金额：</span>
          <span class="amount">¥{{ purchase.totalAmount?.toFixed(2) }}</span>
        </div>
      </n-card>

      <n-card title="审核信息" class="mt-4" v-if="purchase.approverName">
        <n-grid :cols="3" :x-gap="24">
          <n-grid-item>
            <div class="info-item">
              <span class="info-label">审核人：</span>
              <span class="info-value">{{ purchase.approverName }}</span>
            </div>
          </n-grid-item>

          <n-grid-item>
            <div class="info-item">
              <span class="info-label">审核时间：</span>
              <span class="info-value">{{ purchase.approvalTime }}</span>
            </div>
          </n-grid-item>

          <n-grid-item>
            <div class="info-item">
              <span class="info-label">审核结果：</span>
              <n-tag :type="purchase.status === 'approved' ? 'success' : 'error'">
                {{ purchase.status === 'approved' ? '通过' : '拒绝' }}
              </n-tag>
            </div>
          </n-grid-item>
        </n-grid>

        <div class="info-item" v-if="purchase.approvalNote">
          <span class="info-label">审核备注：</span>
          <span class="info-value">{{ purchase.approvalNote }}</span>
        </div>
      </n-card>

      <n-card title="入库记录" class="mt-4" v-if="receivings.length > 0">
        <n-data-table
          :columns="receivingColumns"
          :data="receivings"
          :bordered="false"
        />
      </n-card>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed, h } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import {
  NButton, NCard, NSpace, NGrid, NGridItem,
  NDataTable, NTag
} from 'naive-ui'

const route = useRoute()
const router = useRouter()

// 响应式状态
const loading = ref(false)
const purchase = ref({
  id: null,
  orderNumber: '',
  supplierId: null,
  supplierName: '',
  storeId: null,
  storeName: '',
  status: '',
  totalAmount: 0,
  expectedDate: '',
  actualDate: '',
  creatorId: null,
  creatorName: '',
  approverName: '',
  approvalTime: '',
  approvalNote: '',
  note: '',
  createdAt: '',
  items: []
})
const receivings = ref([])

// 获取状态标签类型
const getStatusType = (status) => {
  const statusMap = {
    draft: 'default',
    pending: 'info',
    approved: 'success',
    rejected: 'error',
    ordered: 'warning',
    receiving: 'processing',
    completed: 'success',
    cancelled: 'error'
  }
  return statusMap[status] || 'default'
}

// 获取状态标签文本
const getStatusText = (status) => {
  const statusMap = {
    draft: '草稿',
    pending: '待审核',
    approved: '已审核',
    rejected: '已拒绝',
    ordered: '已下单',
    receiving: '待入库',
    completed: '已完成',
    cancelled: '已取消'
  }
  return statusMap[status] || '未知'
}

// 采购明细表格列
const itemColumns = [
  {
    title: '商品',
    key: 'productName',
    width: 200
  },
  {
    title: 'SKU',
    key: 'productSku',
    width: 150
  },
  {
    title: '数量',
    key: 'quantity',
    width: 100
  },
  {
    title: '单价',
    key: 'unitPrice',
    width: 120,
    render(row) {
      return `¥${row.unitPrice.toFixed(2)}`
    }
  },
  {
    title: '总价',
    key: 'totalPrice',
    width: 120,
    render(row) {
      return `¥${row.totalPrice.toFixed(2)}`
    }
  },
  {
    title: '已入库数量',
    key: 'receivedQty',
    width: 120
  },
  {
    title: '备注',
    key: 'note',
    width: 200
  }
]

// 入库记录表格列
const receivingColumns = [
  {
    title: '入库单号',
    key: 'receivingNumber',
    width: 150
  },
  {
    title: '入库日期',
    key: 'receivingDate',
    width: 120
  },
  {
    title: '入库数量',
    key: 'totalQuantity',
    width: 100
  },
  {
    title: '操作人',
    key: 'operatorName',
    width: 120
  },
  {
    title: '备注',
    key: 'note',
    width: 200
  },
  {
    title: '操作',
    key: 'actions',
    width: 100,
    render(row) {
      return h(
        NButton,
        {
          size: 'small',
          onClick: () => viewReceiving(row)
        },
        { default: () => '查看' }
      )
    }
  }
]

// 方法
const loadPurchase = async () => {
  const id = route.params.id
  if (!id) return

  loading.value = true
  try {
    // 模拟数据，实际应该从API获取
    purchase.value = {
      id: 1,
      orderNumber: 'PO20230501001',
      supplierId: 1,
      supplierName: '供应商A',
      storeId: 1,
      storeName: '总店',
      status: 'approved',
      totalAmount: 5000.00,
      expectedDate: '2023-05-10',
      actualDate: '',
      creatorId: 1,
      creatorName: '管理员',
      approverName: '审核员',
      approvalTime: '2023-05-02 14:30:00',
      approvalNote: '审核通过',
      note: '紧急采购',
      createdAt: '2023-05-01 10:30:00',
      items: [
        {
          id: 1,
          productId: 1,
          productName: '男士休闲衬衫',
          productSku: 'MS001',
          quantity: 20,
          unitPrice: 100.00,
          totalPrice: 2000.00,
          receivedQty: 0,
          note: ''
        },
        {
          id: 2,
          productId: 2,
          productName: '女士连衣裙',
          productSku: 'WD001',
          quantity: 10,
          unitPrice: 200.00,
          totalPrice: 2000.00,
          receivedQty: 0,
          note: ''
        },
        {
          id: 3,
          productId: 3,
          productName: '男士T恤',
          productSku: 'MT001',
          quantity: 20,
          unitPrice: 50.00,
          totalPrice: 1000.00,
          receivedQty: 0,
          note: ''
        }
      ]
    }

    // 模拟入库记录
    receivings.value = []
  } catch (error) {
    console.error('加载采购单详情失败:', error)
  } finally {
    loading.value = false
  }
}

const goBack = () => {
  router.push('/purchases')
}

const handleEdit = () => {
  router.push(`/purchases/${purchase.value.id}?edit=true`)
}

const handleSubmit = () => {
  alert('提交审核功能尚未实现')
}

const handleApprove = () => {
  alert('审核通过功能尚未实现')
}

const handleReject = () => {
  alert('审核拒绝功能尚未实现')
}

const handleOrder = () => {
  alert('确认下单功能尚未实现')
}

const handleReceiving = () => {
  alert('创建入库单功能尚未实现')
}

const viewReceiving = (row) => {
  alert(`查看入库单: ${row.receivingNumber}`)
}

// 生命周期钩子
onMounted(() => {
  loadPurchase()
})
</script>

<style scoped>
.purchase-detail {
  padding: 16px;
}

.page-subtitle {
  margin-top: 4px;
  color: var(--text-color-secondary);
}

.mt-4 {
  margin-top: 16px;
}

.info-item {
  margin-bottom: 8px;
}

.info-label {
  color: var(--text-color-secondary);
  margin-right: 8px;
}

.info-value {
  color: var(--text-color-primary);
}

.total-amount {
  margin-top: 16px;
  text-align: right;
  font-size: 16px;
  color: var(--text-color-primary);
}

.amount {
  font-weight: bold;
  color: var(--error-color);
  font-size: 18px;
}

/* 注意：暗色模式的样式已移至 dark-theme.css */
</style>
