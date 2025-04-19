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
  NButton, NDataTable, NInput, NSelect, NSpace, NTag, useMessage, useDialog
} from 'naive-ui'
import memberService from '../services/member'

// 路由
const router = useRouter()
const message = useMessage()
const dialog = useDialog()

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
    key: 'ID',  // 根据API返回的字段调整
    width: 80
  },
  {
    title: '会员姓名',
    key: 'Name',  // 根据API返回的字段调整
    width: 120
  },
  {
    title: '手机号码',
    key: 'Phone',  // 根据API返回的字段调整
    width: 150
  },
  {
    title: '会员等级',
    key: 'Level',  // 根据API返回的字段调整
    width: 120,
    render(row) {
      const levelMap = {
        'regular': { type: 'default', text: '普通会员' },
        'silver': { type: 'info', text: '白银会员' },
        'gold': { type: 'warning', text: '黄金会员' },
        'platinum': { type: 'success', text: '铂金会员' },
        'diamond': { type: 'error', text: '钻石会员' }
      }

      // 如果等级字段不存在或不在预定义的映射中，使用默认值
      const level = (row.Level && levelMap[row.Level.toLowerCase()]) || levelMap['regular']

      return h(NTag, { type: level.type }, { default: () => level.text })
    }
  },
  {
    title: '积分',
    key: 'Points',  // 根据API返回的字段调整
    width: 100
  },
  {
    title: '累计消费',
    key: 'TotalSpent',  // 根据API返回的字段调整
    width: 120,
    render(row) {
      // 添加空值检查，防止TotalSpent为undefined时报错
      return row.TotalSpent !== undefined && row.TotalSpent !== null
        ? `¥${Number(row.TotalSpent).toFixed(2)}`
        : '¥0.00'
    }
  },
  {
    title: '生日',
    key: 'Birthday',  // 根据API返回的字段调整
    width: 120,
    render(row) {
      // 处理日期格式
      if (!row.Birthday) return '-'
      return new Date(row.Birthday).toLocaleDateString()
    }
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
    // 构建查询参数
    const params = {
      page: pagination.page,
      limit: pagination.pageSize,
      name: searchForm.name || undefined,
      phone: searchForm.phone || undefined,
      level: searchForm.level || undefined
    }

    // 调用API获取会员列表
    const response = await memberService.getMembers(params)

    // 打印响应数据，便于调试
    console.log('会员列表API响应:', response)

    // 处理响应数据
    if (response && response.data) {
      // 如果数据在data字段中
      if (Array.isArray(response.data.items)) {
        members.value = response.data.items
        pagination.itemCount = response.data.total || response.data.items.length
      } else if (Array.isArray(response.data)) {
        // 如果数据直接在data数组中
        members.value = response.data
        pagination.itemCount = response.data.length
      } else {
        // 如果数据在其他字段中
        members.value = []
        pagination.itemCount = 0
      }
    } else if (response && Array.isArray(response)) {
      // 如果响应直接是数组
      members.value = response
      pagination.itemCount = response.length
    } else if (response && response.items) {
      // 如果数据在items字段中
      members.value = response.items
      pagination.itemCount = response.total || response.items.length
    } else {
      // 如果后端还未实现，使用模拟数据
      members.value = [
        {
          id: 1,
          name: '张三',
          phone: '13800138001',
          level: 'gold',
          points: 2500,
          totalSpent: 15000.00,
          birthday: '1990-01-15'
        },
        {
          id: 2,
          name: '李四',
          phone: '13800138002',
          level: 'regular',
          points: 500,
          totalSpent: 2000.00,
          birthday: '1985-05-20'
        },
        {
          id: 3,
          name: '王五',
          phone: '13800138003',
          level: 'silver',
          points: 1200,
          totalSpent: 8000.00,
          birthday: '1992-11-08'
        },
        {
          id: 4,
          name: '赵六',
          phone: '13800138004',
          level: 'diamond',
          points: 5000,
          totalSpent: 30000.00,
          birthday: '1988-07-30'
        }
      ]
      pagination.itemCount = members.value.length
    }

    // 打印处理后的数据，便于调试
    console.log('处理后的会员数据:', members.value)
  } catch (error) {
    console.error('加载会员列表失败:', error)
    members.value = []
    pagination.itemCount = 0
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
  // 使用大写的ID字段
  const id = row.ID || row.id
  router.push(`/members/edit/${id}`)
}

const handlePoints = (row) => {
  // 使用大写的ID字段
  const id = row.ID || row.id
  router.push(`/members/points/${id}`)
}

const handleDelete = (row) => {
  // 使用Naive UI的对话框替代原生的confirm
  // 使用大写的Name和ID字段
  const name = row.Name || row.name
  const id = row.ID || row.id

  dialog.warning({
    title: '删除确认',
    content: `确定要删除会员 ${name} 吗？此操作不可恢复。`,
    positiveText: '确定删除',
    negativeText: '取消',
    onPositiveClick: async () => {
      try {
        loading.value = true
        await memberService.deleteMember(id)
        message.success('会员删除成功')
        loadMembers()
      } catch (error) {
        console.error('删除会员失败:', error)
        message.error('删除会员失败: ' + (error.response?.data?.error || '未知错误'))
      } finally {
        loading.value = false
      }
    }
  })
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
