<template>
  <n-layout>
    <n-layout-header bordered>
      <n-page-header 
        title="创建退换货申请" 
        @back="handleBack"
      />
    </n-layout-header>

    <n-layout-content class="content">
      <n-card>
        <n-form
          ref="formRef"
          :model="formData"
          :rules="rules"
          label-placement="left"
          label-width="120"
          require-mark-placement="right-hanging"
        >
          <!-- 退换货类型选择 -->
          <n-form-item label="退换类型" path="type">
            <return-type-selector v-model:value="formData.type" @change="handleTypeChange" />
          </n-form-item>

          <!-- 原订单信息 -->
          <n-form-item label="原订单号" path="orderNo">
            <n-input-group>
              <n-input v-model:value="formData.orderNo" placeholder="请输入原订单号" />
              <n-button type="primary" @click="handleSearchOrder">
                查找订单
              </n-button>
            </n-input-group>
          </n-form-item>

          <!-- 订单信息展示 -->
          <div v-if="orderInfo" class="order-info">
            <n-descriptions bordered>
              <n-descriptions-item label="订单日期">
                {{ orderInfo.orderDate }}
              </n-descriptions-item>
              <n-descriptions-item label="订单金额">
                ¥{{ orderInfo.totalAmount }}
              </n-descriptions-item>
              <n-descriptions-item label="支付方式">
                {{ orderInfo.paymentMethod }}
              </n-descriptions-item>
            </n-descriptions>
          </div>

          <!-- 商品选择 -->
          <n-form-item label="退换商品" path="items">
            <n-dynamic-input
              v-model:value="formData.items"
              :on-create="onCreateItem"
              :min="1"
            >
              <template #create-button-default>
                添加商品
              </template>
              <template #default="{ value }">
                <div style="display: flex; align-items: center; gap: 12px;">
                  <product-selector
                    v-model:value="value.productId"
                    :store-id="currentStoreId"
                    :exclude-ids="getExcludeProductIds()"
                    style="width: 200px;"
                    @select="handleProductSelect($event, value)"
                  />
                  <n-input-number
                    v-model:value="value.quantity"
                    :min="1"
                    placeholder="数量"
                  />
                  <n-select
                    v-model:value="value.reason"
                    :options="reasonOptions"
                    placeholder="退换原因"
                    style="width: 150px;"
                  />
                </div>
              </template>
            </n-dynamic-input>
          </n-form-item>

          <!-- 换货商品选择（仅在换货时显示） -->
          <template v-if="formData.type === 'EXCHANGE'">
            <n-form-item label="换货商品" path="exchangeItems">
              <n-dynamic-input
                v-model:value="formData.exchangeItems"
                :on-create="onCreateExchangeItem"
                :min="1"
              >
                <template #create-button-default>
                  添加换货商品
                </template>
                <template #default="{ value }">
                  <div style="display: flex; align-items: center; gap: 12px;">
                    <n-select
                      v-model:value="value.productId"
                      :options="productOptions"
                      placeholder="选择商品"
                      style="width: 200px;"
                    />
                    <n-input-number
                      v-model:value="value.quantity"
                      :min="1"
                      placeholder="数量"
                    />
                  </div>
                </template>
              </n-dynamic-input>
            </n-form-item>

            <!-- 差价计算 -->
            <n-form-item label="差价">
              <n-statistic>
                <template #prefix>
                  ¥
                </template>
                {{ calculatePriceDifference() }}
              </n-statistic>
            </n-form-item>
          </template>

          <!-- 退款信息（仅在退货时显示） -->
          <template v-if="formData.type === 'RETURN'">
            <n-form-item label="退款金额" path="refundAmount">
              <n-input-number
                v-model:value="formData.refundAmount"
                :min="0"
                :precision="2"
                prefix="¥"
              />
            </n-form-item>
          </template>

          <!-- 凭证上传 -->
          <n-form-item label="上传凭证" path="attachments">
            <n-upload
              action="/api/upload"
              :max="5"
              :default-upload="false"
              @change="handleUploadChange"
            >
              <n-button>上传图片</n-button>
            </n-upload>
          </n-form-item>

          <!-- 备注信息 -->
          <n-form-item label="备注" path="remarks">
            <n-input
              v-model:value="formData.remarks"
              type="textarea"
              placeholder="请输入备注信息"
            />
          </n-form-item>

          <!-- 提交按钮 -->
          <n-form-item>
            <n-space justify="end">
              <n-button @click="handleBack">取消</n-button>
              <n-button type="primary" @click="handleSubmit">提交申请</n-button>
            </n-space>
          </n-form-item>
        </n-form>
      </n-card>
    </n-layout-content>
  </n-layout>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { 
  NLayout,
  NLayoutHeader,
  NLayoutContent,
  NPageHeader,
  NCard,
  NForm,
  NFormItem,
  NInput,
  NInputNumber,
  NInputGroup,
  NSpace,
  NButton,
  NSelect,
  NDynamicInput,
  NUpload,
  NDescriptions,
  NDescriptionsItem,
  NStatistic,
  useMessage
} from 'naive-ui'
import ReturnTypeSelector from '@/components/sales/ReturnTypeSelector.vue'
import ProductSelector from '@/components/sales/ProductSelector.vue'

const router = useRouter()
const message = useMessage()
const formRef = ref(null)
const currentStoreId = ref(null) // 当前店铺ID

// 获取需要排除的商品ID列表（已选择的商品）
const getExcludeProductIds = () => {
  const ids = formData.items.map(item => item.productId).filter(Boolean)
  if (formData.type === 'EXCHANGE') {
    ids.push(...formData.exchangeItems.map(item => item.productId).filter(Boolean))
  }
  return ids
}

// 处理商品选择
const handleProductSelect = (product, item) => {
  if (product) {
    item.price = product.price
    item.productName = product.label
    item.sku = product.sku
    // 自动计算退款金额（仅退货时）
    if (formData.type === 'RETURN') {
      calculateRefundAmount()
    }
    // 换货时计算差价
    if (formData.type === 'EXCHANGE') {
      calculatePriceDifference()
    }
  }
}

// 计算退款金额
const calculateRefundAmount = () => {
  formData.refundAmount = formData.items.reduce((total, item) => {
    return total + (item.price || 0) * (item.quantity || 0)
  }, 0)
}

// 表单数据
const formData = reactive({
  type: 'RETURN',
  orderNo: '',
  items: [],
  exchangeItems: [],
  refundAmount: 0,
  remarks: '',
  attachments: [],
  // 新增字段
  storeId: null,
  customerId: null,
  orderInfo: null,
  totalAmount: 0,
  priceDifference: 0
})

// 计算差价
const calculatePriceDifference = () => {
  const originalTotal = formData.items.reduce((total, item) => {
    return total + (item.price || 0) * (item.quantity || 0)
  }, 0)
  
  const exchangeTotal = formData.exchangeItems.reduce((total, item) => {
    return total + (item.price || 0) * (item.quantity || 0)
  }, 0)
  
  formData.priceDifference = exchangeTotal - originalTotal
  return formData.priceDifference
}

// 监听商品数量变化
const handleQuantityChange = () => {
  if (formData.type === 'RETURN') {
    calculateRefundAmount()
  } else {
    calculatePriceDifference()
  }
}

// 表单验证规则
const rules = {
  type: {
    required: true,
    message: '请选择退换类型'
  },
  orderNo: {
    required: true,
    message: '请输入原订单号'
  },
  items: {
    required: true,
    type: 'array',
    min: 1,
    message: '请至少选择一件商品'
  }
}

// 订单信息
const orderInfo = ref(null)

// 商品选项
const productOptions = ref([
  { label: '商品1', value: 1 },
  { label: '商品2', value: 2 }
])

// 退换原因选项
const reasonOptions = ref([
  { label: '质量问题', value: 'QUALITY' },
  { label: '尺寸不合适', value: 'SIZE' },
  { label: '款式不喜欢', value: 'STYLE' },
  { label: '其他原因', value: 'OTHER' }
])

// 创建退货商品项
const onCreateItem = () => ({
  productId: null,
  quantity: 1,
  reason: null
})

// 创建换货商品项
const onCreateExchangeItem = () => ({
  productId: null,
  quantity: 1
})

// 处理类型变化
const handleTypeChange = (value) => {
  // 根据类型重置相关字段
  if (value === 'RETURN') {
    formData.exchangeItems = []
  } else if (value === 'EXCHANGE') {
    formData.refundAmount = 0
  }
}

// 处理订单搜索
const handleSearchOrder = async () => {
  try {
    // TODO: 调用API搜索订单
    orderInfo.value = {
      orderDate: '2023-01-01',
      totalAmount: 299.00,
      paymentMethod: '微信支付'
    }
  } catch (error) {
    message.error('查找订单失败')
  }
}

// 处理上传变化
const handleUploadChange = (options) => {
  console.log('上传变化:', options)
}

// 处理表单提交
const handleSubmit = async () => {
  try {
    await formRef.value?.validate()
    // TODO: 调用API提交退换货申请
    message.success('提交成功')
    router.push('/sales/returns')
  } catch (error) {
    console.error('表单验证失败:', error)
  }
}

// 返回列表页
const handleBack = () => {
  router.back()
}
</script>

<style scoped>
.content {
  padding: 0 24px 24px;
}

.n-card {
  margin-top: 24px;
  border-radius: 8px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.02);
}

.n-form {
  padding: 24px;
}

.n-form-item {
  margin-bottom: 24px;
}

.order-info {
  margin: 16px 0 24px;
  padding: 16px;
  background-color: #fafafa;
  border-radius: 6px;
  border: 1px solid #f0f0f0;
}

.section-title {
  margin: 24px 0 12px;
  font-size: 16px;
  font-weight: 500;
  color: #333;
}

.price-difference {
  margin: 24px 0;
  padding: 16px;
  background-color: #f8f8f8;
  border-radius: 6px;
  text-align: right;
  font-size: 16px;
}

.n-space {
  justify-content: flex-end;
}

.n-button {
  min-width: 120px;
}

@media (max-width: 768px) {
  .content {
    padding: 0 16px 16px;
  }
  
  .n-form {
    padding: 16px;
  }
  
  .n-form-item {
    margin-bottom: 20px;
  }
  
  .n-space {
    flex-direction: column-reverse;
    gap: 12px;
  }
  
  .n-button {
    width: 100%;
  }
}
</style>