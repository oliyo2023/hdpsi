<template>
  <div class="member-list">
    <div class="page-header">
      <h1 class="page-title">会员管理</h1>
      <n-button type="primary" @click="handleAddMember">
        添加会员
      </n-button>
    </div>

    <div class="page-content">
      <!-- 搜索工具栏 -->
      <div class="table-toolbar">
        <div class="table-search">
          <n-input
            v-model:value="searchForm.name"
            placeholder="会员姓名"
            clearable
            style="width: 200px"
          />
          <n-input
            v-model:value="searchForm.phone"
            placeholder="手机号码"
            clearable
            style="width: 150px"
          />
          <n-select
            v-model:value="searchForm.level"
            placeholder="会员等级"
            clearable
            :options="levelOptions"
            style="width: 150px"
          />
          <n-button type="primary" @click="handleSearch">
            查询
          </n-button>
          <n-button @click="resetSearch">
            重置
          </n-button>
        </div>
      </div>

      <!-- 会员表格 -->
      <n-data-table
        ref="tableRef"
        :columns="columns"
        :data="members"
        :loading="loading"
        :pagination="pagination"
        :row-key="row => row.id"
        @update:page="handlePageChange"
        @update:page-size="handlePageSizeChange"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, h } from 'vue'
import { useRouter } from 'vue-router'
import {
  NButton, NDataTable, NInput, NSelect, NSpace, NTag
} from 'naive-ui'
import memberService from '../services/member'

// 路由
const router = useRouter()

// 响应式状态
const loading = ref(false)
const members = ref([])
const pagination = reactive({
  page: 1,
  pageSize: 10,
  itemCount: 0,
  pageSizes: [10, 20, 50, 100],
  showSizePicker: true,
  prefix({ itemCount }) {
    return `共 ${itemCount} 条`
  }
})

// 搜索表单
const searchForm = reactive({
  name: '',
  phone: '',
  level: null
})

// 会员等级选项
const levelOptions = [
  { label: '普通会员', value: 'regular' },
  { label: '白银会员', value: 'silver' },
  { label: '黄金会员', value: 'gold' },
  { label: '铂金会员', value: 'platinum' },
  { label: '钻石会员', value: 'diamond' }
]

// 表格列定义
const columns = [
  {
    title: 'ID',
    key: 'id',
    width: 80
  },
  {
    title: '会员姓名',
    key: 'name',
    width: 120
  },
  {
    title: '手机号码',
    key: 'phone',
    width: 150
  },
  {
    title: '会员等级',
    key: 'level',
    width: 120,
    render(row) {
      const levelMap = {
        'regular': { type: 'default', text: '普通会员' },
        'silver': { type: 'info', text: '白银会员' },
        'gold': { type: 'warning', text: '黄金会员' },
        'platinum': { type: 'success', text: '铂金会员' },
        'diamond': { type: 'error', text: '钻石会员' }
      }

      const level = levelMap[row.level] || levelMap['regular']

      return h(NTag, { type: level.type }, { default: () => level.text })
    }
  },
  {
    title: '积分',
    key: 'points',
    width: 100
  },
  {
    title: '累计消费',
    key: 'totalSpent',
    width: 120,
    render(row) {
      return `¥${row.totalSpent.toFixed(2)}`
    }
  },
  {
    title: '生日',
    key: 'birthday',
    width: 120
  },
  {
    title: '操作',
    key: 'actions',
    width: 250,
    fixed: 'right',
    render(row) {
      return h(NSpace, { justify: 'center' }, {
        default: () => [
          h(
            NButton,
            {
              size: 'small',
              type: 'primary',
              onClick: () => handleEdit(row)
            },
            { default: () => '编辑' }
          ),
          h(
            NButton,
            {
              size: 'small',
              type: 'info',
              onClick: () => handlePoints(row)
            },
            { default: () => '积分' }
          ),
          h(
            NButton,
            {
              size: 'small',
              type: 'error',
              onClick: () => handleDelete(row)
            },
            { default: () => '删除' }
          )
        ]
      })
    }
  }
]

// 方法
const loadMembers = async () => {
  loading.value = true
  try {
    // 模拟数据，实际应该从API获取
    members.value = [
      {
        id: 1,
        name: '张三',
        phone: '13800138001',
        level: '金卡会员',
        points: 2500,
        totalSpent: 15000.00,
        birthday: '1990-01-15'
      },
      {
        id: 2,
        name: '李四',
        phone: '13800138002',
        level: '普通会员',
        points: 500,
        totalSpent: 2000.00,
        birthday: '1985-05-20'
      },
      {
        id: 3,
        name: '王五',
        phone: '13800138003',
        level: '银卡会员',
        points: 1200,
        totalSpent: 8000.00,
        birthday: '1992-11-08'
      },
      {
        id: 4,
        name: '赵六',
        phone: '13800138004',
        level: '钻石会员',
        points: 5000,
        totalSpent: 30000.00,
        birthday: '1988-07-30'
      }
    ]
    pagination.itemCount = members.value.length
  } catch (error) {
    console.error('加载会员列表失败:', error)
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  pagination.page = 1
  loadMembers()
}

const resetSearch = () => {
  searchForm.name = ''
  searchForm.phone = ''
  searchForm.level = null
  pagination.page = 1
  loadMembers()
}

const handlePageChange = (page) => {
  pagination.page = page
  loadMembers()
}

const handlePageSizeChange = (pageSize) => {
  pagination.pageSize = pageSize
  pagination.page = 1
  loadMembers()
}

const handleAddMember = () => {
  router.push('/members/create')
}

const handleEdit = (row) => {
  router.push(`/members/edit/${row.id}`)
}

const handlePoints = (row) => {
  router.push(`/members/points/${row.id}`)
}

const handleDelete = (row) => {
  if (confirm(`确定要删除会员 ${row.name} 吗？`)) {
    memberService.deleteMember(row.id)
      .then(() => {
        alert('删除成功')
        loadMembers()
      })
      .catch(error => {
        console.error('删除会员失败:', error)
        alert('删除失败')
      })
  }
}

// 生命周期钩子
onMounted(() => {
  loadMembers()
})
</script>

<style scoped>
.member-list {
  padding: 16px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.page-title {
  margin: 0;
  font-size: 20px;
  font-weight: 500;
}

.table-toolbar {
  margin-bottom: 16px;
}

.table-search {
  display: flex;
  gap: 8px;
}
</style>
