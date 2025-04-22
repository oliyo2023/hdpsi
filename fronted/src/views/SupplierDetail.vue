<template>
  <div class="supplier-detail">
    <div class="page-header">
      <div>
        <h1 class="page-title">供应商详情</h1>
        <p class="page-subtitle">{{ supplier.code }} - {{ supplier.name }}</p>
      </div>
      <div>
        <n-space>
          <n-button @click="goBack">返回</n-button>
          <n-button type="primary" @click="handleEdit" v-if="!isEditing">
            编辑
          </n-button>
          <template v-if="isEditing">
            <n-button @click="cancelEdit">取消</n-button>
            <n-button type="primary" @click="handleSave" :loading="saving">
              保存
            </n-button>
          </template>
        </n-space>
      </div>
    </div>

    <div class="page-content">
      <n-form
        v-if="isEditing"
        ref="formRef"
        :model="formData"
        :rules="rules"
        label-placement="left"
        label-width="auto"
        require-mark-placement="right-hanging"
      >
        <n-card title="基本信息">
          <n-grid :cols="3" :x-gap="24">
            <n-grid-item>
              <n-form-item label="供应商编码" path="code">
                <n-input v-model:value="formData.code" placeholder="请输入供应商编码" />
              </n-form-item>
            </n-grid-item>

            <n-grid-item>
              <n-form-item label="供应商名称" path="name">
                <n-input v-model:value="formData.name" placeholder="请输入供应商名称" />
              </n-form-item>
            </n-grid-item>

            <n-grid-item>
              <n-form-item label="供应商类型" path="type">
                <n-select
                  v-model:value="formData.type"
                  :options="typeOptions"
                  placeholder="请选择供应商类型"
                />
              </n-form-item>
            </n-grid-item>

            <n-grid-item>
              <n-form-item label="联系人" path="contactPerson">
                <n-input v-model:value="formData.contactPerson" placeholder="请输入联系人" />
              </n-form-item>
            </n-grid-item>

            <n-grid-item>
              <n-form-item label="联系电话" path="contactPhone">
                <n-input v-model:value="formData.contactPhone" placeholder="请输入联系电话" />
              </n-form-item>
            </n-grid-item>

            <n-grid-item>
              <n-form-item label="电子邮箱" path="email">
                <n-input v-model:value="formData.email" placeholder="请输入电子邮箱" />
              </n-form-item>
            </n-grid-item>
          </n-grid>
        </n-card>

        <n-card title="地址信息" class="mt-4">
          <n-grid :cols="3" :x-gap="24">
            <n-grid-item>
              <n-form-item label="城市" path="city">
                <n-input v-model:value="formData.city" placeholder="请输入城市" />
              </n-form-item>
            </n-grid-item>

            <n-grid-item span="2">
              <n-form-item label="详细地址" path="address">
                <n-input v-model:value="formData.address" placeholder="请输入详细地址" />
              </n-form-item>
            </n-grid-item>
          </n-grid>
        </n-card>

        <n-card title="合作信息" class="mt-4">
          <n-grid :cols="3" :x-gap="24">
            <n-grid-item>
              <n-form-item label="评级" path="rating">
                <n-select
                  v-model:value="formData.rating"
                  :options="ratingOptions"
                  placeholder="请选择评级"
                />
              </n-form-item>
            </n-grid-item>

            <n-grid-item>
              <n-form-item label="付款条件" path="paymentTerms">
                <n-input v-model:value="formData.paymentTerms" placeholder="请输入付款条件" />
              </n-form-item>
            </n-grid-item>

            <n-grid-item>
              <n-form-item label="交货条件" path="deliveryTerms">
                <n-input v-model:value="formData.deliveryTerms" placeholder="请输入交货条件" />
              </n-form-item>
            </n-grid-item>

            <n-grid-item span="2">
              <n-form-item label="资质证明" path="qualification">
                <n-input v-model:value="formData.qualification" placeholder="请输入资质证明" />
              </n-form-item>
            </n-grid-item>

            <n-grid-item>
              <n-form-item label="状态" path="status">
                <n-switch v-model:value="formData.status" />
              </n-form-item>
            </n-grid-item>
          </n-grid>
        </n-card>

        <n-card title="备注" class="mt-4">
          <n-form-item path="note">
            <n-input
              v-model:value="formData.note"
              type="textarea"
              placeholder="请输入备注信息"
              :autosize="{ minRows: 3, maxRows: 5 }"
            />
          </n-form-item>
        </n-card>
      </n-form>

      <template v-else>
        <n-card title="基本信息">
          <n-descriptions bordered :column="3">
            <n-descriptions-item label="供应商编码">
              {{ supplier.code }}
            </n-descriptions-item>
            <n-descriptions-item label="供应商名称">
              {{ supplier.name }}
            </n-descriptions-item>
            <n-descriptions-item label="供应商类型">
              {{ getTypeText(supplier.type) }}
            </n-descriptions-item>
            <n-descriptions-item label="联系人">
              {{ supplier.contactPerson }}
            </n-descriptions-item>
            <n-descriptions-item label="联系电话">
              {{ supplier.contactPhone }}
            </n-descriptions-item>
            <n-descriptions-item label="电子邮箱">
              {{ supplier.email }}
            </n-descriptions-item>
          </n-descriptions>
        </n-card>

        <n-card title="地址信息" class="mt-4">
          <n-descriptions bordered :column="3">
            <n-descriptions-item label="城市">
              {{ supplier.city }}
            </n-descriptions-item>
            <n-descriptions-item label="详细地址" :span="2">
              {{ supplier.address }}
            </n-descriptions-item>
          </n-descriptions>
        </n-card>

        <n-card title="合作信息" class="mt-4">
          <n-descriptions bordered :column="3">
            <n-descriptions-item label="评级">
              <n-tag :type="getRatingType(supplier.rating)">
                {{ supplier.rating }}
              </n-tag>
            </n-descriptions-item>
            <n-descriptions-item label="付款条件">
              {{ supplier.paymentTerms }}
            </n-descriptions-item>
            <n-descriptions-item label="交货条件">
              {{ supplier.deliveryTerms }}
            </n-descriptions-item>
            <n-descriptions-item label="资质证明" :span="2">
              {{ supplier.qualification }}
            </n-descriptions-item>
            <n-descriptions-item label="状态">
              <n-tag :type="supplier.status ? 'success' : 'error'">
                {{ supplier.status ? '启用' : '禁用' }}
              </n-tag>
            </n-descriptions-item>
          </n-descriptions>
        </n-card>

        <n-card title="备注" class="mt-4">
          <p>{{ supplier.note || '无' }}</p>
        </n-card>
      </template>

      <n-card title="采购记录" class="mt-4">
        <n-data-table
          :columns="purchaseColumns"
          :data="purchases"
          :pagination="{ pageSize: 5 }"
          :loading="loading"
        />
      </n-card>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { h } from 'vue'
import {
  NButton, NCard, NDescriptions, NDescriptionsItem, NForm, NFormItem,
  NGrid, NGridItem, NInput, NSelect, NSpace, NSwitch, NTag, NDataTable,
  useMessage
} from 'naive-ui'
import supplierService from '../services/supplier'

const route = useRoute()
const router = useRouter()
const message = useMessage()
const formRef = ref(null)

// 响应式状态
const loading = ref(true)
const saving = ref(false)
const isEditing = ref(false)
const supplier = ref({})
const purchases = ref([])

// 表单数据
const formData = reactive({
  code: '',
  name: '',
  type: 'manufacturer',
  contactPerson: '',
  contactPhone: '',
  email: '',
  address: '',
  city: '',
  rating: 'B',
  qualification: '',
  paymentTerms: '月结30天',
  deliveryTerms: '供应商送货',
  status: true,
  note: ''
})

// 表单验证规则
const rules = {
  code: {
    required: true,
    message: '请输入供应商编码',
    trigger: 'blur'
  },
  name: {
    required: true,
    message: '请输入供应商名称',
    trigger: 'blur'
  },
  type: {
    required: true,
    message: '请选择供应商类型',
    trigger: 'blur'
  },
  contactPerson: {
    required: true,
    message: '请输入联系人',
    trigger: 'blur'
  },
  contactPhone: {
    required: true,
    message: '请输入联系电话',
    trigger: 'blur'
  }
}

// 供应商类型选项
const typeOptions = [
  { label: '生产厂商', value: 'manufacturer' },
  { label: '批发商', value: 'wholesaler' },
  { label: '代理商', value: 'agent' },
  { label: '其他', value: 'other' }
]

// 评级选项
const ratingOptions = [
  { label: 'S级', value: 'S' },
  { label: 'A级', value: 'A' },
  { label: 'B级', value: 'B' },
  { label: 'C级', value: 'C' },
  { label: 'D级', value: 'D' }
]

// 采购记录表格列定义
const purchaseColumns = [
  {
    title: '订单编号',
    key: 'orderNumber',
    width: 150
  },
  {
    title: '店铺',
    key: 'storeName',
    width: 120
  },
  {
    title: '金额',
    key: 'totalAmount',
    width: 120,
    render(row) {
      return `¥${row.totalAmount.toFixed(2)}`
    }
  },
  {
    title: '状态',
    key: 'status',
    width: 100,
    render(row) {
      const statusMap = {
        draft: { type: 'default', text: '草稿' },
        pending: { type: 'info', text: '待审核' },
        approved: { type: 'success', text: '已审核' },
        rejected: { type: 'error', text: '已拒绝' },
        ordered: { type: 'warning', text: '已下单' },
        receiving: { type: 'processing', text: '待入库' },
        completed: { type: 'success', text: '已完成' },
        cancelled: { type: 'error', text: '已取消' }
      }

      const status = statusMap[row.status] || { type: 'default', text: '未知' }

      return h(NTag, { type: status.type }, { default: () => status.text })
    }
  },
  {
    title: '创建时间',
    key: 'createdAt',
    width: 150
  },
  {
    title: '操作',
    key: 'actions',
    width: 100,
    render(row) {
      return h(
        NButton,
        {
          size: 'small',
          onClick: () => viewPurchase(row)
        },
        { default: () => '查看' }
      )
    }
  }
]

// 获取供应商类型文本
const getTypeText = (type) => {
  const typeMap = {
    manufacturer: '生产厂商',
    wholesaler: '批发商',
    agent: '代理商',
    other: '其他'
  }
  return typeMap[type] || '未知'
}

// 获取评级标签类型
const getRatingType = (rating) => {
  const ratingMap = {
    'S': 'success',
    'A': 'info',
    'B': 'default',
    'C': 'warning',
    'D': 'error'
  }
  return ratingMap[rating] || 'default'
}

// 方法
const loadSupplier = async () => {
  const id = route.params.id

  // 检查ID是否有效
  if (!id || id === 'undefined' || id === 'null') {
    message.error('无效的供应商ID')
    router.push('/suppliers')
    return
  }

  loading.value = true
  try {
    // 从 API 获取供应商详情
    const response = await supplierService.getSupplier(id)
    if (response) {
      supplier.value = response

      // 复制数据到表单
      Object.keys(formData).forEach(key => {
        if (key in supplier.value) {
          formData[key] = supplier.value[key]
        }
      })
    } else {
      message.error('未找到供应商信息')
      router.push('/suppliers')
      return
    }

    // 加载供应商相关的采购记录
    try {
      // 实际应用中取消下面注释，使用真实API调用
      // const purchaseResponse = await purchaseService.getPurchasesBySupplier(id)
      // purchases.value = purchaseResponse.items || []

      // 模拟数据，实际应用中删除
      purchases.value = [
        {
          id: 1,
          orderNumber: 'PO20230501001',
          storeId: 1,
          storeName: '总店',
          totalAmount: 5000.00,
          status: 'completed',
          createdAt: '2023-05-01 10:30:00'
        },
        {
          id: 3,
          orderNumber: 'PO20230503001',
          storeId: 2,
          storeName: '分店1',
          totalAmount: 2800.00,
          status: 'approved',
          createdAt: '2023-05-03 09:15:00'
        }
      ]
    } catch (error) {
      console.error('加载采购记录失败:', error)
      message.error('加载采购记录失败')
      purchases.value = []
    }

    // 检查是否是编辑模式
    isEditing.value = route.query.edit === 'true'
  } catch (error) {
    console.error('加载供应商详情失败:', error)
    message.error('加载供应商详情失败: ' + (error.message || '未知错误'))
    router.push('/suppliers')
  } finally {
    loading.value = false
  }
}

const goBack = () => {
  router.push('/suppliers')
}

const handleEdit = () => {
  isEditing.value = true
}

const cancelEdit = () => {
  isEditing.value = false
  // 重置表单数据
  Object.keys(formData).forEach(key => {
    if (key in supplier.value) {
      formData[key] = supplier.value[key]
    }
  })
}

const handleSave = () => {
  formRef.value?.validate(async (errors) => {
    if (!errors) {
      // 检查ID是否有效
      if (!supplier.value || !supplier.value.id) {
        message.error('无效的供应商ID，无法保存')
        return
      }

      saving.value = true
      try {
        // 调用API保存供应商数据
        await supplierService.updateSupplier(supplier.value.id, formData)

        // 更新本地数据
        Object.keys(formData).forEach(key => {
          supplier.value[key] = formData[key]
        })

        isEditing.value = false
        message.success('供应商信息保存成功')
      } catch (error) {
        console.error('保存供应商失败:', error)
        message.error('保存供应商失败: ' + (error.message || '未知错误'))
      } finally {
        saving.value = false
      }
    }
  })
}

const viewPurchase = (row) => {
  router.push(`/purchases/${row.id}`)
}

// 生命周期钩子
onMounted(() => {
  loadSupplier()
})
</script>

<style scoped>
.supplier-detail {
  padding: 16px;
}

.page-subtitle {
  margin-top: 4px;
  color: #909399;
}

.mt-4 {
  margin-top: 16px;
}
</style>
