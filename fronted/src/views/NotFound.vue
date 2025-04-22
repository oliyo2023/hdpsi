<template>
  <div class="not-found">
    <n-result
      status="404"
      title="404 页面不存在"
      description="您访问的页面不存在或已被删除"
    >
      <template #footer>
        <n-button type="primary" @click="goHome">返回首页</n-button>
      </template>
    </n-result>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
import { NResult, NButton } from 'naive-ui'

const router = useRouter()

const goHome = () => {
  router.push('/')
}
</script>

<style scoped>
.not-found {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100%;
  padding: 40px;
}
</style>
