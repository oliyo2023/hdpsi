<template>
  <n-timeline>
    <n-timeline-item
      v-for="record in records"
      :key="record.id"
      :type="record.type"
      :title="record.title"
      :content="record.content"
      :time="record.time"
    >
      <template #icon>
        <n-icon>
          <component :is="getTimelineIcon(record.type)" />
        </n-icon>
      </template>
    </n-timeline-item>
  </n-timeline>
</template>

<script setup>
import { NTimeline, NTimelineItem, NIcon } from 'naive-ui'
import {
  CheckmarkCircle,
  CloseCircle,
  Time,
  Create,
  Person,
  Sync
} from '@vicons/ionicons5'

const props = defineProps({
  records: {
    type: Array,
    required: true,
    default: () => []
  }
})

// 获取时间线图标
const getTimelineIcon = (type) => {
  const iconMap = {
    success: CheckmarkCircle,
    error: CloseCircle,
    info: Time,
    warning: Create,
    user: Person,
    process: Sync
  }
  return iconMap[type] || Time
}
</script>

<style scoped>
/* 可以根据需要添加自定义样式 */
</style>