<template>
  <div class="page-header">
    <div class="header-left">
      <div class="header-icon" v-if="$slots.icon">
        <slot name="icon"></slot>
      </div>
      <div class="header-content">
        <h1 class="page-title">{{ title }}</h1>
        <p v-if="subtitle" class="page-subtitle">{{ subtitle }}</p>
      </div>
    </div>
    <div class="header-right" v-if="$slots.default">
      <slot></slot>
    </div>
  </div>
</template>

<script setup>
defineProps({
  title: {
    type: String,
    required: true
  },
  subtitle: {
    type: String,
    default: ''
  }
})
</script>

<style scoped>
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.header-left {
  display: flex;
  align-items: center;
}

.header-icon {
  margin-right: 12px;
  color: var(--info-color);
  font-size: 24px;
  display: flex;
  align-items: center;
}

.header-content {
  display: flex;
  flex-direction: column;
}

.page-title {
  margin: 0;
  font-size: 20px;
  font-weight: 600;
  color: var(--text-color-primary);
  line-height: 1.2;
}

.page-subtitle {
  margin: 4px 0 0;
  font-size: 14px;
  color: var(--text-color-secondary);
}

.header-right {
  display: flex;
  align-items: center;
}
</style>
