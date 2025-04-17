<template>
  <div class="purchase-create">
    <div class="page-header">
      <h1 class="page-title">创建采购单</h1>
      <n-space>
        <n-button @click="goBack">取消</n-button>
        <n-button type="primary" @click="handleSave" :loading="saving">
          保存
        </n-button>
      </n-space>
    </div>

    <div class="page-content">
      <n-form
        ref="formRef"
        :model="formData"
        :rules="rules"
        label-placement="left"
        label-width="auto"
        require-mark-placement="right-hanging"
      >
        <n-card title="基本信息">
          <n-grid :cols="3" :x-gap="24">
            <n-grid-item>
              <n-form-item label="供应商" path="supplierId">
                <n-select
                  v-model:value="formData.supplierId"
                  placeholder="请选择供应商"
                  :options="supplierOptions"
                  clearable
                />
              </n-form-item>
            </n-grid-item>

            <n-grid-item>
              <n-form-item label="店铺" path="storeId">
                <n-select
                  v-model:value="formData.storeId"
                  placeholder="请选择店铺"
                  :options="storeOptions"
                  clearable
                />
              </n-form-item>
            </n-grid-item>

            <n-grid-item>
              <n-form-item label="预计到货日期" path="expectedDate">
                <n-date-picker
                  v-model:value="formData.expectedDate"
                  type="date"
                  placeholder="请选择预计到货日期"
                  clearable
                  style="width: 100%"
                />
              </n-form-item>
            </n-grid-item>
          </n-grid>

          <n-form-item label="备注" path="note">
            <n-input
              v-model:value="formData.note"
              type="textarea"
              placeholder="请输入备注"
            />
          </n-form-item>
        </n-card>

        <n-card title="采购明细" class="mt-4">
          <div class="table-toolbar">
            <n-button type="primary" @click="handleAddItem">
              添加商品
            </n-button>
          </div>

          <n-data-table
            :columns="itemColumns"
            :data="formData.items"
            :bordered="false"
          />

          <div class="total-amount">
            <span>总金额：</span>
            <span class="amount">¥{{ totalAmount.toFixed(2) }}</span>
          </div>
        </n-card>
      </n-form>
    </div>

    <!-- 添加商品对话框 -->
    <n-modal
      v-model:show="showItemModal"
      title="添加商品"
      preset="card"
      style="width: 600px"
      :mask-closable="false"
    >
      <n-form
        ref="itemFormRef"
        :model="itemForm"
        :rules="itemRules"
        label-placement="left"
        label-width="auto"
        require-mark-placement="right-hanging"
      >
        <n-form-item label="商品" path="productId">
          <n-select
            v-model:value="itemForm.productId"
            placeholder="请选择商品"
            :options="productOptions"
            filterable
            clearable
          />
        </n-form-item>

        <n-form-item label="数量" path="quantity">
          <n-input-number
            v-model:value="itemForm.quantity"
            :min="1"
            style="width: 100%"
          />
        </n-form-item>

        <n-form-item label="单价" path="unitPrice">
          <n-input-number
            v-model:value="itemForm.unitPrice"
            :min="0"
            :precision="2"
            style="width: 100%"
          />
        </n-form-item>

        <n-form-item label="备注" path="note">
          <n-input
            v-model:value="itemForm.note"
            placeholder="请输入备注"
          />
        </n-form-item>
      </n-form>

      <template #footer>
        <n-space justify="end">
          <n-button @click="showItemModal = false">取消</n-button>
          <n-button type="primary" @click="handleItemSubmit">确定</n-button>
        </n-space>
      </template>
    </n-modal>
  </div>
</template>

<script setup>
import { ref, reactive, computed, h, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import {
  NButton, NCard, NForm, NFormItem, NInput, NInputNumber,
  NSelect, NDatePicker, NSpace, NGrid, NGridItem,
  NDataTable, NModal
} from 'naive-ui'

const router = useRouter()

// 响应式状态
const formRef = ref(null)
const formData = reactive({
  supplierId: null,
  storeId: null,
  expectedDate: null,
  note: '',
  items: []
})
const saving = ref(false)

// 商品选择对话框
const showItemModal = ref(false)
const itemFormRef = ref(null)
const itemForm = reactive({
  productId: null,
  quantity: 1,
  unitPrice: 0,
  note: ''
})
const editingItemIndex = ref(-1)

// 选项数据
const supplierOptions = [
  { label: '供应商A', value: 1 },
  { label: '供应商B', value: 2 },
  { label: '供应商C', value: 3 }
]

const storeOptions = [
  { label: '总店', value: 1 },
  { label: '分店1', value: 2 },
  { label: '分店2', value: 3 }
]

const productOptions = [
  { label: '男士休闲衬衫 (MS001)', value: 1, sku: 'MS001', price: 100.00 },
  { label: '女士连衣裙 (WD001)', value: 2, sku: 'WD001', price: 200.00 },
  { label: '男士T恤 (MT001)', value: 3, sku: 'MT001', price: 50.00 }
]

// 计算属性
const totalAmount = computed(() => {
  return formData.items.reduce((sum, item) => sum + item.totalPrice, 0)
})

// 表单验证规则
const rules = {
  supplierId: [
    { required: true, message: '请选择供应商', trigger: 'change' }
  ],
  storeId: [
    { required: true, message: '请选择店铺', trigger: 'change' }
  ],
  expectedDate: [
    { required: true, message: '请选择预计到货日期', trigger: 'change' }
  ]
}

const itemRules = {
  productId: [
    { required: true, message: '请选择商品', trigger: 'change' }
  ],
  quantity: [
    { required: true, type: 'number', message: '请输入数量', trigger: 'change' },
    { type: 'number', min: 1, message: '数量必须大于0', trigger: 'change' }
  ],
  unitPrice: [
    { required: true, type: 'number', message: '请输入单价', trigger: 'change' },
    { type: 'number', min: 0, message: '单价必须大于等于0', trigger: 'change' }
  ]
}

// 采购明细表格列
const itemColumns = [
  {
    title: '商品',
    key: 'productName',
    render(row) {
      const product = productOptions.find(p => p.value === row.productId)
      return product ? product.label.split(' (')[0] : ''
    }
  },
  {
    title: 'SKU',
    key: 'productSku',
    render(row) {
      const product = productOptions.find(p => p.value === row.productId)
      return product ? product.sku : ''
    }
  },
  {
    title: '数量',
    key: 'quantity'
  },
  {
    title: '单价',
    key: 'unitPrice',
    render(row) {
      return `¥${row.unitPrice.toFixed(2)}`
    }
  },
  {
    title: '总价',
    key: 'totalPrice',
    render(row) {
      return `¥${row.totalPrice.toFixed(2)}`
    }
  },
  {
    title: '备注',
    key: 'note'
  },
  {
    title: '操作',
    key: 'actions',
    render(row, index) {
      return h(NSpace, { justify: 'center' }, {
        default: () => [
          h(
            NButton,
            {
              size: 'small',
              onClick: () => handleEditItem(row, index)
            },
            { default: () => '编辑' }
          ),
          h(
            NButton,
            {
              size: 'small',
              type: 'error',
              onClick: () => handleRemoveItem(index)
            },
            { default: () => '删除' }
          )
        ]
      })
    }
  }
]

// 方法
const goBack = () => {
  router.push('/purchases')
}

const handleSave = () => {
  formRef.value?.validate(async (errors) => {
    if (!errors) {
      if (formData.items.length === 0) {
        alert('请至少添加一个商品')
        return
      }

      saving.value = true
      try {
        // 模拟保存，实际应该调用API
        console.log('保存采购单:', formData)
        alert('采购单保存成功')
        router.push('/purchases')
      } catch (error) {
        console.error('保存采购单失败:', error)
      } finally {
        saving.value = false
      }
    }
  })
}

const handleAddItem = () => {
  editingItemIndex.value = -1
  itemForm.productId = null
  itemForm.quantity = 1
  itemForm.unitPrice = 0
  itemForm.note = ''
  showItemModal.value = true
}

const handleEditItem = (row, index) => {
  editingItemIndex.value = index
  itemForm.productId = row.productId
  itemForm.quantity = row.quantity
  itemForm.unitPrice = row.unitPrice
  itemForm.note = row.note
  showItemModal.value = true
}

const handleRemoveItem = (index) => {
  formData.items.splice(index, 1)
}

const handleItemSubmit = () => {
  itemFormRef.value?.validate(async (errors) => {
    if (!errors) {
      const product = productOptions.find(p => p.value === itemForm.productId)
      const totalPrice = itemForm.quantity * itemForm.unitPrice

      const item = {
        productId: itemForm.productId,
        quantity: itemForm.quantity,
        unitPrice: itemForm.unitPrice,
        totalPrice: totalPrice,
        note: itemForm.note
      }

      if (editingItemIndex.value === -1) {
        // 添加新商品
        formData.items.push(item)
      } else {
        // 更新现有商品
        formData.items[editingItemIndex.value] = item
      }

      showItemModal.value = false
    }
  })
}

// 监听商品选择变化，自动填充单价
const watchProductChange = () => {
  const product = productOptions.find(p => p.value === itemForm.productId)
  if (product) {
    itemForm.unitPrice = product.price
  }
}

// 生命周期钩子
onMounted(() => {
  // 监听商品选择变化
  watch(() => itemForm.productId, watchProductChange)
})
</script>

<style scoped>
.purchase-create {
  padding: 16px;
}

.mt-4 {
  margin-top: 16px;
}

.table-toolbar {
  margin-bottom: 16px;
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
