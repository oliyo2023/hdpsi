<template>
  <div class="dashboard-container">
    <div class="dashboard-header">
      <h1 class="dashboard-title">仪表盘</h1>
      <div class="dashboard-date">
        <n-icon size="18" class="date-icon">
          <CalendarOutline />
        </n-icon>
        <span>{{ currentDate }}</span>
      </div>
    </div>

    <div class="dashboard-content">
      <!-- 统计卡片区域 -->
      <div class="stats-section">
        <n-grid :cols="24" :x-gap="16" :y-gap="16">
          <n-grid-item :span="6">
            <div class="stat-card product-card">
              <div class="stat-card-inner">
                <div class="stat-icon-container">
                  <n-icon size="28" class="stat-icon">
                    <CubeOutline />
                  </n-icon>
                </div>
                <div class="stat-content">
                  <div class="stat-title">商品总数</div>
                  <div class="stat-value">{{ statistics.productCount }}</div>
                </div>
              </div>
              <div class="stat-footer">
                <div class="stat-trend positive">
                  <n-icon size="14">
                    <TrendingUpOutline />
                  </n-icon>
                  <span>5.2%</span>
                </div>
                <div class="stat-period">较上月</div>
              </div>
            </div>
          </n-grid-item>

          <n-grid-item :span="6">
            <div class="stat-card inventory-card">
              <div class="stat-card-inner">
                <div class="stat-icon-container">
                  <n-icon size="28" class="stat-icon">
                    <StorefrontOutline />
                  </n-icon>
                </div>
                <div class="stat-content">
                  <div class="stat-title">库存总量</div>
                  <div class="stat-value">{{ statistics.inventoryCount }}</div>
                </div>
              </div>
              <div class="stat-footer">
                <div class="stat-trend positive">
                  <n-icon size="14">
                    <TrendingUpOutline />
                  </n-icon>
                  <span>3.1%</span>
                </div>
                <div class="stat-period">较上月</div>
              </div>
            </div>
          </n-grid-item>

          <n-grid-item :span="6">
            <div class="stat-card member-card">
              <div class="stat-card-inner">
                <div class="stat-icon-container">
                  <n-icon size="28" class="stat-icon">
                    <PeopleOutline />
                  </n-icon>
                </div>
                <div class="stat-content">
                  <div class="stat-title">会员总数</div>
                  <div class="stat-value">{{ statistics.memberCount }}</div>
                </div>
              </div>
              <div class="stat-footer">
                <div class="stat-trend positive">
                  <n-icon size="14">
                    <TrendingUpOutline />
                  </n-icon>
                  <span>8.4%</span>
                </div>
                <div class="stat-period">较上月</div>
              </div>
            </div>
          </n-grid-item>

          <n-grid-item :span="6">
            <div class="stat-card order-card">
              <div class="stat-card-inner">
                <div class="stat-icon-container">
                  <n-icon size="28" class="stat-icon">
                    <CartOutline />
                  </n-icon>
                </div>
                <div class="stat-content">
                  <div class="stat-title">销售订单</div>
                  <div class="stat-value">{{ statistics.orderCount }}</div>
                </div>
              </div>
              <div class="stat-footer">
                <div class="stat-trend negative">
                  <n-icon size="14">
                    <TrendingDownOutline />
                  </n-icon>
                  <span>2.3%</span>
                </div>
                <div class="stat-period">较上月</div>
              </div>
            </div>
          </n-grid-item>
        </n-grid>
      </div>

      <!-- 数据卡片区域 -->
      <div class="data-section">
        <n-grid :cols="24" :x-gap="16" :y-gap="16">
          <!-- 库存预警 -->
          <n-grid-item :span="12">
            <div class="data-card">
              <div class="data-card-header">
                <div class="data-card-title">
                  <n-icon size="18" class="title-icon">
                    <AlertCircleOutline />
                  </n-icon>
                  <span>库存预警</span>
                </div>
                <n-button size="small" type="primary" ghost @click="checkInventoryLevels" class="action-button">
                  <n-icon size="14" class="button-icon">
                    <RefreshOutline />
                  </n-icon>
                  <span>检查库存</span>
                </n-button>
              </div>

              <div class="data-card-content">
                <n-data-table
                  :columns="alertColumns"
                  :data="inventoryAlerts"
                  :pagination="{ pageSize: 5 }"
                  :bordered="false"
                  size="small"
                  class="custom-table"
                />
              </div>
            </div>
          </n-grid-item>

          <!-- 最近销售 -->
          <n-grid-item :span="12">
            <div class="data-card">
              <div class="data-card-header">
                <div class="data-card-title">
                  <n-icon size="18" class="title-icon">
                    <TimeOutline />
                  </n-icon>
                  <span>最近销售</span>
                </div>
                <n-button size="small" type="primary" text>
                  查看全部
                </n-button>
              </div>

              <div class="data-card-content">
                <n-data-table
                  :columns="salesColumns"
                  :data="recentSales"
                  :pagination="{ pageSize: 5 }"
                  :bordered="false"
                  size="small"
                  class="custom-table"
                />
              </div>
            </div>
          </n-grid-item>
        </n-grid>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, h, computed } from 'vue'
import {
  NGrid, NGridItem, NIcon, NDataTable,
  NButton, NTag, useMessage
} from 'naive-ui'
import api from '../services/api'
import inventoryService from '../services/inventory'
import {
  CubeOutline, StorefrontOutline, PeopleOutline, CartOutline,
  CalendarOutline, AlertCircleOutline, TimeOutline, RefreshOutline,
  TrendingUpOutline, TrendingDownOutline
} from '@vicons/ionicons5'

const message = useMessage()

// 格式化当前日期
const currentDate = computed(() => {
  const now = new Date()
  const year = now.getFullYear()
  const month = String(now.getMonth() + 1).padStart(2, '0')
  const day = String(now.getDate()).padStart(2, '0')
  const weekdays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六']
  const weekday = weekdays[now.getDay()]
  return `${year}年${month}月${day}日 ${weekday}`
})

// 统计数据
const statistics = reactive({
  productCount: 0,
  inventoryCount: 0,
  memberCount: 0,
  orderCount: 0
})

// 库存预警数据
const inventoryAlerts = ref([])

// 最近销售数据
const recentSales = ref([])

// 库存预警表格列
const alertColumns = [
  {
    title: '商品名称',
    key: 'productName',
    width: 150
  },
  {
    title: '店铺',
    key: 'storeName',
    width: 100
  },
  {
    title: '预警类型',
    key: 'alertType',
    width: 100,
    render(row) {
      return h(
        NTag,
        {
          type: row.alertType === 'low' ? 'error' : 'warning',
          size: 'small'
        },
        { default: () => row.alertType === 'low' ? '库存不足' : '库存过多' }
      )
    }
  },
  {
    title: '当前库存',
    key: 'currentQty',
    width: 100
  },
  {
    title: '阈值',
    key: 'threshold',
    width: 100
  }
]

// 最近销售表格列
const salesColumns = [
  {
    title: '订单编号',
    key: 'orderNumber',
    width: 150
  },
  {
    title: '店铺',
    key: 'storeName',
    width: 100
  },
  {
    title: '金额',
    key: 'amount',
    width: 100,
    render(row) {
      return `¥${row.amount.toFixed(2)}`
    }
  },
  {
    title: '状态',
    key: 'status',
    width: 100,
    render(row) {
      const statusMap = {
        completed: { type: 'success', text: '已完成' },
        processing: { type: 'info', text: '处理中' },
        pending: { type: 'warning', text: '待处理' },
        cancelled: { type: 'error', text: '已取消' }
      }
      const status = statusMap[row.status] || { type: 'default', text: '未知' }

      return h(
        NTag,
        {
          type: status.type,
          size: 'small'
        },
        { default: () => status.text }
      )
    }
  },
  {
    title: '创建时间',
    key: 'createdAt',
    width: 150
  }
]

// 加载统计数据
const loadStatistics = async () => {
  try {
    // 从 API 获取统计数据
    const response = await api.get('/api/dashboard/statistics')
    console.log('从后端获取的统计数据:', response)
    if (response) {
      statistics.productCount = response.productCount || 0
      statistics.inventoryCount = response.inventoryCount || 0
      statistics.memberCount = response.memberCount || 0
      statistics.orderCount = response.orderCount || 0
    }
  } catch (error) {
    console.error('加载统计数据失败:', error)
    message.error('加载统计数据失败')

    // 使用默认值
    statistics.productCount = 0
    statistics.inventoryCount = 0
    statistics.memberCount = 0
    statistics.orderCount = 0
  }
}

// 加载库存预警数据
const loadInventoryAlerts = async () => {
  try {
    // 从 API 获取库存预警数据
    const response = await inventoryService.getInventoryAlerts({ status: 'active' })
    if (response) {
      inventoryAlerts.value = response || []
    }
  } catch (error) {
    console.error('加载库存预警数据失败:', error)
    message.error('加载库存预警数据失败')

    // 使用空数组
    inventoryAlerts.value = []
  }
}

// 加载最近销售数据
const loadRecentSales = async () => {
  try {
    // 从 API 获取最近销售数据
    const response = await api.get('/api/sales/recent')
    if (response && response.items) {
      recentSales.value = response.items || []
    }
  } catch (error) {
    console.error('加载最近销售数据失败:', error)

    // 使用空数组
    recentSales.value = []
  }
}

// 检查库存水平
const checkInventoryLevels = async () => {
  try {
    // 显示加载中消息
    message.loading('正在检查库存水平...', { duration: 0 })

    // 调用API检查库存水平
    const result = await inventoryService.checkInventoryLevels()

    // 关闭加载中消息
    message.destroyAll()

    // 显示成功消息
    message.success('库存水平检查完成')

    // 重新加载库存预警数据
    await loadInventoryAlerts()

    return result
  } catch (error) {
    // 关闭加载中消息
    message.destroyAll()

    console.error('库存水平检查失败:', error)

    // 显示错误消息
    if (error.response && error.response.data && error.response.data.error) {
      message.error(`库存水平检查失败: ${error.response.data.error}`)
    } else {
      message.error('库存水平检查失败，请检查网络连接或登录状态')
    }

    // 如果是权限问题，提示用户
    if (error.response && error.response.status === 403) {
      message.warning('您没有执行此操作的权限，请联系管理员')
    }
  }
}

// 生命周期钩子
onMounted(async () => {
  await Promise.all([
    loadStatistics(),
    loadInventoryAlerts(),
    loadRecentSales()
  ])
})
</script>

<style scoped>
/* 主容器样式 */
.dashboard-container {
  padding: 16px;
  background-color: var(--background-color);
  min-height: calc(100vh - 64px - 48px);
  overflow-x: hidden;
}

/* 仪表盘头部 */
.dashboard-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.dashboard-title {
  font-size: 24px;
  font-weight: 600;
  color: var(--text-color-primary);
  margin: 0;
}

.dashboard-date {
  display: flex;
  align-items: center;
  color: var(--text-color-secondary);
  font-size: 14px;
}

.date-icon {
  margin-right: 6px;
}

/* 仪表盘内容区 */
.dashboard-content {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

/* 统计卡片区域 */
.stats-section {
  margin-bottom: 8px;
}

/* 统计卡片样式 */
.stat-card {
  height: 140px;
  border-radius: 12px;
  padding: 20px;
  background-color: var(--card-background);
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  transition: all 0.3s ease;
  overflow: hidden;
  position: relative;
  border: 1px solid var(--border-color-light);
}

.stat-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
}

.stat-card::before {
  content: '';
  position: absolute;
  top: 0;
  right: 0;
  width: 100px;
  height: 100px;
  border-radius: 50%;
  opacity: 0.1;
  transform: translate(30%, -30%);
}

.product-card::before {
  background: linear-gradient(135deg, #4f46e5, #8b5cf6);
}

.inventory-card::before {
  background: linear-gradient(135deg, #0ea5e9, #06b6d4);
}

.member-card::before {
  background: linear-gradient(135deg, #f97316, #f43f5e);
}

.order-card::before {
  background: linear-gradient(135deg, #10b981, #14b8a6);
}

.stat-card-inner {
  display: flex;
  align-items: center;
}

.stat-icon-container {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 16px;
}

.product-card .stat-icon-container {
  background-color: rgba(79, 70, 229, 0.1);
}

.product-card .stat-icon {
  color: #4f46e5;
}

.inventory-card .stat-icon-container {
  background-color: rgba(14, 165, 233, 0.1);
}

.inventory-card .stat-icon {
  color: #0ea5e9;
}

.member-card .stat-icon-container {
  background-color: rgba(249, 115, 22, 0.1);
}

.member-card .stat-icon {
  color: #f97316;
}

.order-card .stat-icon-container {
  background-color: rgba(16, 185, 129, 0.1);
}

.order-card .stat-icon {
  color: #10b981;
}

.stat-content {
  flex: 1;
}

.stat-title {
  font-size: 14px;
  color: var(--text-color-secondary);
  margin-bottom: 8px;
}

.stat-value {
  font-size: 28px;
  font-weight: 700;
  color: var(--text-color-primary);
  line-height: 1.2;
}

.stat-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 16px;
  font-size: 12px;
}

.stat-trend {
  display: flex;
  align-items: center;
  gap: 4px;
}

.stat-trend.positive {
  color: var(--success-color);
}

.stat-trend.negative {
  color: var(--error-color);
}

.stat-period {
  color: var(--text-color-secondary);
}

/* 数据卡片区域 */
.data-section {
  margin-bottom: 24px;
}

.data-card {
  background-color: var(--card-background);
  border-radius: 12px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  padding: 0;
  height: 400px;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  border: 1px solid var(--border-color-light);
}

.data-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  border-bottom: 1px solid var(--border-color-light);
}

.data-card-title {
  display: flex;
  align-items: center;
  font-size: 16px;
  font-weight: 600;
  color: var(--text-color-primary);
}

.title-icon {
  margin-right: 8px;
  color: var(--text-color-secondary);
}

.action-button {
  display: flex;
  align-items: center;
  gap: 4px;
}

.button-icon {
  margin-right: 2px;
}

.data-card-content {
  flex: 1;
  padding: 16px 20px;
  overflow: auto;
}

/* 自定义表格样式 */
.custom-table :deep(.n-data-table-th) {
  background-color: var(--table-header-background);
  font-weight: 600;
  color: var(--text-color-primary);
}

.custom-table :deep(.n-data-table-tr:hover) {
  background-color: var(--table-hover-background);
}

/* 暗色模式下的图标容器背景调整 */
.dark .product-card .stat-icon-container {
  background-color: rgba(79, 70, 229, 0.2);
}

.dark .inventory-card .stat-icon-container {
  background-color: rgba(14, 165, 233, 0.2);
}

.dark .member-card .stat-icon-container {
  background-color: rgba(249, 115, 22, 0.2);
}

.dark .order-card .stat-icon-container {
  background-color: rgba(16, 185, 129, 0.2);
}

/* 响应式调整 */
@media (max-width: 1200px) {
  .dashboard-container {
    padding: 16px;
  }

  .stat-card {
    height: 130px;
    padding: 16px;
  }

  .stat-value {
    font-size: 24px;
  }
}

@media (max-width: 768px) {
  .dashboard-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }

  .stat-card {
    height: 120px;
  }

  .data-card {
    height: 350px;
  }
}
</style>
