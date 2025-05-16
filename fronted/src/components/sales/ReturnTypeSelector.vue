<template>
  <n-select
    v-model:value="selectedType"
    :options="typeOptions"
    :disabled="disabled"
    :clearable="clearable"
    :placeholder="placeholder"
    @update:value="handleTypeChange"
  />
</template>

<script setup>
import { ref, watch } from 'vue'
import { NSelect } from 'naive-ui'

const props = defineProps({
  modelValue: {
    type: String,
    default: ''
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
    default: '请选择退换类型'
  }
})

const emit = defineEmits(['update:modelValue', 'change'])

// 类型选项
const typeOptions = [
  {
    label: '退货',
    value: 'RETURN',
    description: '将商品退回并退款'
  },
  {
    label: '换货',
    value: 'EXCHANGE',
    description: '将商品更换为其他商品'
  }
]

// 选中的类型
const selectedType = ref(props.modelValue)

// 监听外部值变化
watch(() => props.modelValue, (newValue) => {
  selectedType.value = newValue
})

// 处理类型变化
const handleTypeChange = (value) => {
  emit('update:modelValue', value)
  emit('change', value)
}
</script>

<style scoped>
/* 可以根据需要添加自定义样式 */
</style>