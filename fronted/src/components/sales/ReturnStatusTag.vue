<template>
  <n-tag :type="statusType" :bordered="false">
    {{ statusText }}
  </n-tag>
</template>

<script setup>
import { computed } from 'vue'
import { NTag } from 'naive-ui'

const props = defineProps({
  status: {
    type: String,
    required: true,
    validator: (value) => {
      return ['PENDING', 'APPROVED', 'REJECTED', 'COMPLETED'].includes(value)
    }
  }
})

// 状态类型映射
const statusType = computed(() => {
  const typeMap = {
    PENDING: 'warning',
    APPROVED: 'success',
    REJECTED: 'error',
    COMPLETED: 'success'
  }
  return typeMap[props.status] || 'default'
})

// 状态文本映射
const statusText = computed(() => {
  const textMap = {
    PENDING: '待处理',
    APPROVED: '已批准',
    REJECTED: '已拒绝',
    COMPLETED: '已完成'
  }
  return textMap[props.status] || props.status
})
</script>

<style scoped>
/* 可以根据需要添加自定义样式 */
</style>