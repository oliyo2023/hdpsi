<template>
  <div class="sales-order-form">
    <div class="page-header">
      <div class="header-left">
        <n-button text @click="handleBack">
          <template #icon>
            <n-icon><ArrowBackOutline /></n-icon>
          </template>
          返回
        </n-button>
        <h1 class="page-title">{{ isEdit ? '编辑销售订单' : '新建销售订单' }}</h1>
      </div>
      <div class="header-right">
        <n-space>
          <n-button @click="handleSaveDraft">
            <template #icon>
              <n-icon><SaveOutline /></n-icon>
            </template>
            保存草稿
          </n-button>
          <n-button type="primary" @click="handleSubmit">
            <template #icon>
              <n-icon><CheckmarkOutline /></n-icon>
            </template>
            {{ isEdit ? '更新订单' : '创建订单' }}
          </n-button>
        </n-space>
      </div>
    </div>

    <n-form
      ref="formRef"
      :model="formData"
      :rules="formRules"
      label-placement="left"
      :label-width="120"
    >
      <n-grid :cols="24" :x-gap="16">
        <!-- 基本信息 -->
        <n-gi :span="24">
          <n-card title="基本信息">
            <n-grid :cols="24" :x-gap="16">
              <n-form-item-gi :span="8" label="客户姓名" path="customer_name">
                <n-input
                  v-model:value="formData.customer_name"
                  placeholder="请输入客户姓名"
                />
              </n-form-item-gi>
              <n-form-item-gi :span="8" label="客户电话" path="customer_phone">
                <n-input
                  v-model:value="formData.customer_phone"
                  placeholder="请输入客户电话"
                />
              </n-form-item-gi>
              <n-form-item-gi :span="8" label="销售店铺" path="store_id">
                <n-select
                  v-model:value="formData.store_id"
                  placeholder="请选择销售店铺"
                  :options="storeOptions"
                />
              </n-form-item-gi>
              <n-form-item-gi :span="8" label="订单类型" path="order_type">
                <n-select
                  v-model:value="formData.order_type"
                  placeholder="请选择订单类型"
                  :options="orderTypeOptions"
                />
              </n-form-item-gi>
              <n-form-item-gi :span="8" label="会员" path="member_id">
                <n-select
                  v-model:value="formData.member_id"
                  placeholder="请选择会员（可选）"
                  :options="memberOptions"
                  clearable
                  filterable
                  @search="handleMemberSearch"
                />
              </n-form-item-gi>
              <n-form-item-gi :span="8" label="支付方式" path="payment_method">
                <n-select
                  v-model:value="formData.payment_method"
                  placeholder="请选择支付方式"
                  :options="paymentMethodOptions"
                />
              </n-form-item-gi>
              <n-form-item-gi :span="12" label="客户地址" path="customer_address">
                <n-input
                  v-model:value="formData.customer_address"
                  placeholder="请输入客户地址"
                />
              </n-form-item-gi>
              <n-form-item-gi :span="12" label="备注" path="note">
                <n-input
                  v-model:value="formData.note"
                  placeholder="请输入备注"
                />
              </n-form-item-gi>
            </n-grid>
          </n-card>
        </n-gi>

        <!-- 商品明细 -->
        <n-gi :span="24">
          <n-card title="商品明细">
            <template #header-extra>
              <n-button type="primary" @click="handleAddItem">
                <template #icon>
                  <n-icon><AddOutline /></n-icon>
                </template>
                添加商品
              </n-button>
            </template>

            <n-data-table
              :columns="itemColumns"
              :data="formData.items"
              :pagination="false"
              :bordered="false"
            />

            <!-- 金额汇总 -->
            <div class="amount-summary">
              <n-descriptions :column="1" size="small">
                <n-descriptions-item label="商品小计">
                  ¥{{ subtotalAmount.toFixed(2) }}
                </n-descriptions-item>
                <n-descriptions-item label="折扣金额">
                  -¥{{ totalDiscountAmount.toFixed(2) }}
                </n-descriptions-item>
                <n-descriptions-item label="订单总额">
                  <span class="total-amount">¥{{ totalAmount.toFixed(2) }}</span>
                </n-descriptions-item>
              </n-descriptions>
            </div>
          </n-card>
        </n-gi>
      </n-grid>
    </n-form>

    <!-- 商品选择对话框 -->
    <n-modal v-model:show="showProductModal" preset="dialog" title="选择商品" style="width: 80%">
      <div class="product-search">
        <n-input
          v-model:value="productSearchKeyword"
          placeholder="搜索商品名称或SKU"
          @input="handleProductSearch"
        >
          <template #prefix>
            <n-icon><SearchOutline /></n-icon>
          </template>
        </n-input>
      </div>
      
      <n-data-table
        :columns="productColumns"
        :data="filteredProducts"
        :pagination="productPagination"
        :max-height="400"
        class="product-table"
      />
      
      <template #action>
        <n-button @click="showProductModal = false">关闭</n-button>
      </template>
    </n-modal>

    <!-- 商品明细编辑对话框 -->
    <n-modal v-model:show="showItemModal" preset="dialog" title="编辑商品明细">
      <n-form ref="itemFormRef" :model="currentItem" :rules="itemRules">
        <n-form-item label="商品" path="product_id">
          <n-input :value="currentItem.productName" readonly />
        </n-form-item>
        <n-form-item label="数量" path="quantity">
          <n-input-number
            v-model:value="currentItem.quantity"
            :min="1"
            style="width: 100%"
            @update:value="updateItemTotal"
          />
        </n-form-item>
        <n-form-item label="单价" path="unit_price">
          <n-input-number
            v-model:value="currentItem.unit_price"
            :min="0"
            :precision="2"
            style="width: 100%"
            @update:value="updateItemTotal"
          />
        </n-form-item>
        <n-form-item label="折扣金额" path="discount_amount">
          <n-input-number
            v-model:value="currentItem.discount_amount"
            :min="0"
            :precision="2"
            style="width: 100%"
            @update:value="updateItemTotal"
          />
        </n-form-item>
        <n-form-item label="小计">
          <n-input :value="`¥${itemTotal.toFixed(2)}`" readonly />
        </n-form-item>
        <n-form-item label="是否试穿">
          <n-switch v-model:value="currentItem.is_tried" />
        </n-form-item>
        <n-form-item v-if="currentItem.is_tried" label="试穿尺码">
          <n-input v-model:value="currentItem.tried_size" placeholder="请输入试穿尺码" />
        </n-form-item>
        <n-form-item v-if="currentItem.is_tried" label="合身度评分">
          <n-rate v-model:value="currentItem.fit_rating" />
        </n-form-item>
        <n-form-item label="备注">
          <n-input
            v-model:value="currentItem.note"
            type="textarea"
            placeholder="请输入备注"
            :rows="3"
          />
        </n-form-item>
      </n-form>
      
      <template #action>
        <n-space>
          <n-button @click="showItemModal = false">取消</n-button>
          <n-button type="primary" @click="handleConfirmItem">确认</n-button>
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
  SaveOutline,
  CheckmarkOutline,
  AddOutline,
  SearchOutline,
  CreateOutline,
  TrashOutline
} from '@vicons/ionicons5'
import salesOrderService from '../services/salesOrderService'
import productService from '../services/productService'
import storeService from '../services/storeService'
import memberService from '../services/memberService'

const route = useRoute()
const router = useRouter()
const message = useMessage()

// 响应式数据
const loading = ref(false)
const isEdit = computed(() => !!route.params.id)
const showProductModal = ref(false)
const showItemModal = ref(false)
const currentItemIndex = ref(-1)

// 表单数据
const formData = reactive({
  customer_name: '',
  customer_phone: '',
  customer_address: '',
  store_id: null,
  member_id: null,
  order_type: 'offline',
  payment_method: '',
  note: '',
  items: []
})

// 当前编辑的商品明细
const currentItem = reactive({
  product_id: null,
  productName: '',
  productSku: '',
  quantity: 1,
  unit_price: 0,
  discount_amount: 0,
  is_tried: false,
  tried_size: '',
  fit_rating: null,
  note: ''
})

// 商品相关
const products = ref([])
const productSearchKeyword = ref('')
const filteredProducts = computed(() => {
  if (!productSearchKeyword.value) return products.value
  const keyword = productSearchKeyword.value.toLowerCase()
  return products.value.filter(product => 
    product.name.toLowerCase().includes(keyword) ||
    product.sku.toLowerCase().includes(keyword)
  )
})

const productPagination = reactive({
  page: 1,
  pageSize: 10,
  showSizePicker: true,
  pageSizes: [10, 20, 50]
})

// 选项数据
const storeOptions = ref([])
const memberOptions = ref([])
const orderTypeOptions = ref([])
const paymentMethodOptions = ref([])

// 计算属性
const subtotalAmount = computed(() => {
  return formData.items.reduce((sum, item) => {
    return sum + (item.unit_price * item.quantity)
  }, 0)
})

const totalDiscountAmount = computed(() => {
  return formData.items.reduce((sum, item) => {
    return sum + (item.discount_amount || 0)
  }, 0)
})

const totalAmount = computed(() => {
  return subtotalAmount.value - totalDiscountAmount.value
})

const itemTotal = computed(() => {
  return (currentItem.unit_price * currentItem.quantity) - (currentItem.discount_amount || 0)
})

// 表单验证规则
const formRules = {
  customer_name: [
    { required: true, message: '请输入客户姓名', trigger: 'blur' }
  ],
  store_id: [
    { required: true, message: '请选择销售店铺', trigger: 'change' }
  ],
  order_type: [
    { required: true, message: '请选择订单类型', trigger: 'change' }
  ]
}

const itemRules = {
  quantity: [
    { required: true, message: '请输入数量', trigger: 'blur' },
    { type: 'number', min: 1, message: '数量必须大于0', trigger: 'blur' }
  ],
  unit_price: [
    { required: true, message: '请输入单价', trigger: 'blur' },
    { type: 'number', min: 0, message: '单价不能为负数', trigger: 'blur' }
  ]
}

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
    key: 'unit_price',
    width: 100,
    render(row) {
      return `¥${row.unit_price.toFixed(2)}`
    }
  },
  {
    title: '折扣',
    key: 'discount_amount',
    width: 100,
    render(row) {
      return row.discount_amount > 0 ? `-¥${row.discount_amount.toFixed(2)}` : '-'
    }
  },
  {
    title: '小计',
    key: 'total',
    width: 120,
    render(row) {
      const total = (row.unit_price * row.quantity) - (row.discount_amount || 0)
      return `¥${total.toFixed(2)}`
    }
  },
  {
    title: '试穿',
    key: 'is_tried',
    width: 80,
    render(row) {
      return row.is_tried ? '是' : '否'
    }
  },
  {
    title: '操作',
    key: 'actions',
    width: 120,
    fixed: 'right',
    render(row, index) {
      return h('n-space', {}, {
        default: () => [
          h('n-button', {
            size: 'small',
            onClick: () => handleEditItem(index)
          }, {
            default: () => '编辑',
            icon: () => h('n-icon', {}, { default: () => h(CreateOutline) })
          }),
          h('n-button', {
            size: 'small',
            type: 'error',
            onClick: () => handleRemoveItem(index)
          }, {
            default: () => '删除',
            icon: () => h('n-icon', {}, { default: () => h(TrashOutline) })
          })
        ]
      })
    }
  }
]

const productColumns = [
  {
    title: '商品名称',
    key: 'name',
    width: 200
  },
  {
    title: 'SKU',
    key: 'sku',
    width: 120
  },
  {
    title: '零售价',
    key: 'retailPrice',
    width: 100,
    render(row) {
      return `¥${row.retailPrice.toFixed(2)}`
    }
  },
  {
    title: '库存',
    key: 'stock',
    width: 80,
    render(row) {
      // 这里需要根据实际情况获取库存信息
      return '-'
    }
  },
  {
    title: '操作',
    key: 'actions',
    width: 100,
    render(row) {
      return h('n-button', {
        size: 'small',
        type: 'primary',
        onClick: () => handleSelectProduct(row)
      }, {
        default: () => '选择'
      })
    }
  }
]

// 生命周期
onMounted(() => {
  initializeData()
  if (isEdit.value) {
    loadOrderData()
  }
})

// 初始化数据
const initializeData = async () => {
  await Promise.all([
    loadStoreOptions(),
    loadOrderTypeOptions(),
    loadPaymentMethodOptions(),
    loadProducts()
  ])
}

// 加载选项数据
const loadStoreOptions = async () => {
  try {
    const response = await storeService.getStores()
    storeOptions.value = response.map(store => ({
      label: store.name,
      value: store.id
    }))
  } catch (error) {
    console.error('加载店铺选项失败:', error)
  }
}

const loadOrderTypeOptions = () => {
  orderTypeOptions.value = salesOrderService.getOrderTypeOptions()
}

const loadPaymentMethodOptions = () => {
  paymentMethodOptions.value = salesOrderService.getPaymentMethodOptions()
}

const loadProducts = async () => {
  try {
    const response = await productService.getProducts({ page_size: 1000 })
    products.value = response.items || []
  } catch (error) {
    console.error('加载商品列表失败:', error)
  }
}

// 加载订单数据（编辑模式）
const loadOrderData = async () => {
  loading.value = true
  try {
    const response = await salesOrderService.getSalesOrder(route.params.id)
    
    // 填充表单数据
    Object.keys(formData).forEach(key => {
      if (key === 'items') {
        formData.items = response.items?.map(item => ({
          product_id: item.productId,
          productName: item.productName,
          productSku: item.productSku,
          quantity: item.quantity,
          unit_price: item.unitPrice,
          discount_amount: item.discountAmount || 0,
          is_tried: item.isTried || false,
          tried_size: item.triedSize || '',
          fit_rating: item.fitRating,
          note: item.note || ''
        })) || []
      } else {
        const responseKey = key.replace(/_([a-z])/g, (match, letter) => letter.toUpperCase())
        if (response[responseKey] !== undefined) {
          formData[key] = response[responseKey]
        }
      }
    })
  } catch (error) {
    console.error('加载订单数据失败:', error)
    message.error('加载订单数据失败')
  } finally {
    loading.value = false
  }
}

// 会员搜索
const handleMemberSearch = async (query) => {
  if (!query) {
    memberOptions.value = []
    return
  }
  
  try {
    const response = await memberService.getMembers({
      search: query,
      page_size: 20
    })
    memberOptions.value = response.items?.map(member => ({
      label: `${member.name} (${member.phone})`,
      value: member.id
    })) || []
  } catch (error) {
    console.error('搜索会员失败:', error)
  }
}

// 商品搜索
const handleProductSearch = () => {
  // 搜索逻辑已在计算属性中实现
}

// 选择商品
const handleSelectProduct = (product) => {
  currentItem.product_id = product.id
  currentItem.productName = product.name
  currentItem.productSku = product.sku
  currentItem.unit_price = product.retailPrice
  currentItem.quantity = 1
  currentItem.discount_amount = 0
  currentItem.is_tried = false
  currentItem.tried_size = ''
  currentItem.fit_rating = null
  currentItem.note = ''
  
  currentItemIndex.value = -1
  showProductModal.value = false
  showItemModal.value = true
}

// 添加商品
const handleAddItem = () => {
  showProductModal.value = true
}

// 编辑商品明细
const handleEditItem = (index) => {
  const item = formData.items[index]
  Object.keys(currentItem).forEach(key => {
    currentItem[key] = item[key]
  })
  currentItemIndex.value = index
  showItemModal.value = true
}

// 删除商品明细
const handleRemoveItem = (index) => {
  formData.items.splice(index, 1)
}

// 更新商品明细小计
const updateItemTotal = () => {
  // 计算逻辑已在计算属性中实现
}

// 确认商品明细
const handleConfirmItem = () => {
  if (currentItemIndex.value >= 0) {
    // 编辑模式
    Object.keys(currentItem).forEach(key => {
      formData.items[currentItemIndex.value][key] = currentItem[key]
    })
  } else {
    // 新增模式
    formData.items.push({ ...currentItem })
  }
  
  showItemModal.value = false
}

// 保存草稿
const handleSaveDraft = async () => {
  try {
    const orderData = {
      ...formData,
      status: 'draft'
    }
    
    if (isEdit.value) {
      await salesOrderService.updateSalesOrder(route.params.id, orderData)
      message.success('草稿保存成功')
    } else {
      await salesOrderService.createSalesOrder(orderData)
      message.success('草稿创建成功')
      router.push('/sales')
    }
  } catch (error) {
    console.error('保存草稿失败:', error)
    message.error('保存草稿失败')
  }
}

// 提交表单
const handleSubmit = async () => {
  try {
    // 验证表单
    const errors = salesOrderService.validateOrderData(formData)
    if (errors.length > 0) {
      message.error(errors[0])
      return
    }
    
    const orderData = {
      ...formData,
      status: 'pending'
    }
    
    if (isEdit.value) {
      await salesOrderService.updateSalesOrder(route.params.id, orderData)
      message.success('订单更新成功')
    } else {
      await salesOrderService.createSalesOrder(orderData)
      message.success('订单创建成功')
    }
    
    router.push('/sales')
  } catch (error) {
    console.error('提交订单失败:', error)
    message.error('提交订单失败')
  }
}

// 返回
const handleBack = () => {
  router.back()
}
</script>

<style scoped>
.sales-order-form {
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

.product-search {
  margin-bottom: 16px;
}

.product-table {
  margin-top: 16px;
}
</style>
