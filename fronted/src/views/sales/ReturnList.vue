<template>
  <n-layout>
    <n-layout-header bordered>
      <n-page-header title="退换货管理" subtitle="查看和处理退换货申请">
        <template #extra>
          <n-button type="primary" @click="handleCreate">
            <template #icon>
              <n-icon>
                <Add />
              </n-icon>
            </template>
            新建退换货
          </n-button>
        </template>
      </n-page-header>
    </n-layout-header>

    <n-layout-content>
      <n-card>
        <n-data-table
          :columns="columns"
          :data="data"
          :pagination="pagination"
          :loading="loading"
          @update:sorter="handleSortChange"
        />
      </n-card>
    </n-layout-content>
  </n-layout>
</template>

<script setup>
import { ref, onMounted, h } from 'vue'
import { useRouter } from 'vue-router'
import { Add } from '@vicons/ionicons5'
import { NButton, NDataTable, NIcon, NLayout, NLayoutHeader, NLayoutContent, NPageHeader, NCard, NSpace } from 'naive-ui'
import ReturnStatusTag from '@/components/sales/ReturnStatusTag.vue'

const router = useRouter()
const loading = ref(false)
const data = ref([])
const pagination = ref({
  page: 1,
  pageSize: 10,
  showSizePicker: true,
  pageSizes: [10, 20, 50],
  onChange: (page) => {
    pagination.value.page = page
    fetchData()
  },
  onUpdatePageSize: (pageSize) => {
    pagination.value.pageSize = pageSize
    pagination.value.page = 1
    fetchData()
  }
})

const columns = ref([
  {
    title: '退换货单号',
    key: 'returnNo',
    sorter: true
  },
  {
    title: '原订单号',
    key: 'orderNo'
  },
  {
    title: '类型',
    key: 'type',
    render: (row) => {
      const typeMap = {
        RETURN: '退货',
        EXCHANGE: '换货'
      }
      return typeMap[row.type] || row.type
    }
  },
  {
    title: '状态',
    key: 'status',
    render: (row) => {
      return h(ReturnStatusTag, {
        status: row.status
      })
    }
  },
  {
    title: '申请时间',
    key: 'createdAt',
    sorter: true
  },
  {
    title: '操作',
    key: 'actions',
    render: (row) => {
      return h(
        NButton,
        {
          size: 'small',
          onClick: () => handleViewDetail(row.id)
        },
        { default: () => '查看详情' }
      )
    }
  }
])

const fetchData = async () => {
  loading.value = true
  try {
    // TODO: 调用API获取退换货列表
    // const response = await api.get('/api/returns', {
    //   params: {
    //     page: pagination.value.page,
    //     pageSize: pagination.value.pageSize
    //   }
    // })
    // data.value = response.data.items
    // pagination.value.itemCount = response.data.total
    
    // 模拟数据
    data.value = [
      {
        id: 1,
        returnNo: 'RT20230001',
        orderNo: 'ORD20230001',
        type: 'RETURN',
        status: 'PENDING',
        createdAt: '2023-01-01 10:00:00'
      },
      {
        id: 2,
        returnNo: 'RT20230002',
        orderNo: 'ORD20230002',
        type: 'EXCHANGE',
        status: 'APPROVED',
        createdAt: '2023-01-02 11:00:00'
      }
    ]
    pagination.value.itemCount = 2
  } catch (error) {
    console.error('获取退换货列表失败:', error)
  } finally {
    loading.value = false
  }
}

const handleSortChange = (sorter) => {
  console.log('排序变化:', sorter)
  // TODO: 根据排序条件重新获取数据
}

const handleCreate = () => {
  router.push('/sales/returns/create')
}

const handleViewDetail = (id) => {
  router.push(`/sales/returns/${id}`)
}

onMounted(() => {
  fetchData()
})
</script>

<style scoped>
.n-layout {
  height: 100%;
  padding: 24px;
}

.n-layout-header {
  padding: 0 24px;
  margin-bottom: 24px;
}

.n-layout-content {
  background: transparent;
}

.n-card {
  border-radius: 8px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.02);
}

.n-data-table {
  margin-top: 16px;
}

.n-page-header {
  padding: 16px 0;
}

.n-button {
  margin-left: 12px;
}

@media (max-width: 768px) {
  .n-layout {
    padding: 16px;
  }
  
  .n-layout-header {
    padding: 0 16px;
  }
  
  .n-page-header {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .n-page-header__extra {
    margin-top: 12px;
    width: 100%;
  }
  
  .n-button {
    margin-left: 0;
    margin-top: 8px;
    width: 100%;
  }
}
</style>