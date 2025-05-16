<template>
  <div class="product-selector">
    <n-select
      v-model:value="selectedProductId"
      :options="productOptions"
      :loading="loading"
      :disabled="disabled"
      :clearable="clearable"
      :placeholder="placeholder"
      filterable
      remote
      :remote-method="handleSearch"
      @update:value="handleProductChange"
    >
      <template #option="{ option }">
        <div class="product-option">
          <div class="product-info">
            <div class="product-name">{{ option.label }}</div>
            <div class="product-sku">SKU: {{ option.sku }}</div>
          </div>
          <div class="product-price">¥{{ option.price }}</div>
        </div>
      </template>
    </n-select>
  </div>
</template>

<script setup>
import { ref, watch, onMounted } from 'vue'
import { NSelect } from 'naive-ui'
import { debounce } from 'lodash-es'

const props = defineProps({
  modelValue: {
    type: [Number, String],
    default: null
  },
  disabled: {
    type: Boolean,
    default: false
  },
  clearable: {
    type: Boolean,
    default: true
  },
  placeholder: {
    type: String,
    default: '请选择商品'
  },
  storeId: {
    type: [Number, String],
    default: null
  },
  excludeIds: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['update:modelValue', 'change', 'select'])

// 状态
const loading = ref(false)
const selectedProductId = ref(props.modelValue)
const productOptions = ref([])

// 监听外部值变化
watch(() => props.modelValue, (newValue) => {
  selectedProductId.value = newValue
})

// 处理商品变化
const handleProductChange = (value) => {
  emit('update:modelValue', value)
  
  // 查找选中的商品对象
  const selectedProduct = productOptions.value.find(item => item.value === value)
  emit('change', value)
  emit('select', selectedProduct)
}

// 搜索商品
const handleSearch = debounce(async (query) => {
  if (!query) return
  
  loading.value = true
  try {
    // TODO: 调用API搜索商品
    // const response = await api.get('/api/products/search', {
    //   params: {
    //     keyword: query,
    //     storeId: props.storeId,
    //     excludeIds: props.excludeIds.join(',')
    //   }
    // })
    
    // 模拟数据
    const mockData = [
      { id: 1, name: '商品1', sku: 'SKU001', price: 199.00 },
      { id: 2, name: '商品2', sku: 'SKU002', price: 299.00 },
      { id: 3, name: '商品3', sku: 'SKU003', price: 399.00 }
    ].filter(item => item.name.includes(query) || item.sku.includes(query))
    
    productOptions.value = mockData.map(item => ({
      label: item.name,
      value: item.id,
      sku: item.sku,
      price: item.price
    }))
  } catch (error) {
    console.error('搜索商品失败:', error)
  } finally {
    loading.value = false
  }
}, 300)

// 初始化
const initProductOptions = async () => {
  if (props.modelValue) {
    loading.value = true
    try {
      // TODO: 调用API获取商品详情
      // const response = await api.get(`/api/products/${props.modelValue}`)
      // const product = response.data
      
      // 模拟数据
      const product = { id: props.modelValue, name: `商品${props.modelValue}`, sku: `SKU00${props.modelValue}`, price: 199.00 }
      
      productOptions.value = [{
        label: product.name,
        value: product.id,
        sku: product.sku,
        price: product.price
      }]
    } catch (error) {
      console.error('获取商品详情失败:', error)
    } finally {
      loading.value = false
    }
  }
}

onMounted(() => {
  initProductOptions()
})
</script>

<style scoped>
.product-selector {
  width: 100%;
}

.product-option {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 4px 0;
}

.product-info {
  display: flex;
  flex-direction: column;
}

.product-name {
  font-weight: bold;
}

.product-sku {
  font-size: 12px;
  color: #999;
}

.product-price {
  font-weight: bold;
  color: #d03050;
}
</style>