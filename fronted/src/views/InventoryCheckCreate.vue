<template>
  <div class="inventory-check-create">
    <div class="page-header">
      <div class="header-left">
        <n-button quaternary @click="router.back()">
          <template #icon>
            <n-icon><arrow-back-outline /></n-icon>
          </template>
          返回
        </n-button>
        <h1 class="page-title">创建盘点单</h1>
      </div>
    </div>
    
    <div class="page-content">
      <n-card title="盘点单信息" class="form-card">
        <n-form
          ref="formRef"
          :model="formData"
          :rules="rules"
          label-placement="left"
          label-width="100"
          require-mark-placement="right-hanging"
        >
          <n-form-item label="店铺" path="storeId">
            <n-select
              v-model:value="formData.storeId"
              placeholder="请选择店铺"
              :options="storeOptions"
              clearable
            />
          </n-form-item>
          
          <n-form-item label="盘点类型" path="checkType">
            <n-radio-group v-model:value="formData.checkType">
              <n-space>
                <n-radio value="full_check">全盘</n-radio>
                <n-radio value="spot_check">抽盘</n-radio>
              </n-space>
            </n-radio-group>
          </n-form-item>
          
          <n-form-item label="计划日期" path="planDate">
            <n-date-picker
              v-model:value="formData.planDate"
              type="date"
              clearable
            />
          </n-form-item>
          
          <n-form-item v-if="formData.checkType === 'spot_check'" label="选择商品" path="productIds">
            <n-select
              v-model:value="formData.productIds"
              placeholder="请选择需要盘点的商品"
              :options="productOptions"
              multiple
              clearable
            />
          </n-form-item>
          
          <n-form-item label="说明" path="description">
            <n-input
              v-model:value="formData.description"
              type="textarea"
              placeholder="请输入盘点说明"
            />
          </n-form-item>
          
          <n-form-item>
            <n-space justify="end">
              <n-button @click="router.back()">取消</n-button>
              <n-button type="primary" @click="handleSubmit" :loading="submitting">
                创建盘点单
              </n-button>
            </n-space>
          </n-form-item>
        </n-form>
      </n-card>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { 
  NButton, NCard, NForm, NFormItem, NInput, NSelect, 
  NDatePicker, NSpace, NRadioGroup, NRadio, NIcon
} from 'naive-ui'
import { useMessage } from 'naive-ui'
import { ArrowBackOutline } from '@vicons/ionicons5'
import inventoryCheckService from '../services/inventory_check_service'

const router = useRouter()
const message = useMessage()
const formRef = ref(null)
const submitting = ref(false)

// 表单数据
const formData = reactive({
  storeId: null,
  checkType: 'full_check',
  planDate: Date.now(),
  productIds: [],
  description: ''
})

// 表单验证规则
const rules = {
  storeId: [
    { required: true, message: '请选择店铺', trigger: 'blur' }
  ],
  checkType: [
    { required: true, message: '请选择盘点类型', trigger: 'blur' }
  ],
  planDate: [
    { required: true, message: '请选择计划日期', trigger: 'blur' }
  ],
  productIds: [
    { 
      required: true, 
      message: '请选择需要盘点的商品', 
      trigger: 'blur',
      validator: (rule, value) => {
        if (formData.checkType === 'spot_check' && (!value || value.length === 0)) {
          return new Error('请选择需要盘点的商品')
        }
        return true
      }
    }
  ]
}

// 店铺选项
const storeOptions = [
  { label: '总店', value: 1 },
  { label: '分店1', value: 2 },
  { label: '分店2', value: 3 }
]

// 商品选项 - 实际应用中应该从API获取
const productOptions = [
  { label: '商品1', value: 1 },
  { label: '商品2', value: 2 },
  { label: '商品3', value: 3 },
  { label: '商品4', value: 4 },
  { label: '商品5', value: 5 }
]

// 提交表单
const handleSubmit = () => {
  formRef.value?.validate(async (errors) => {
    if (errors) {
      return
    }
    
    submitting.value = true
    try {
      // 准备提交数据
      const submitData = {
        store_id: formData.storeId,
        check_type: formData.checkType,
        plan_date: new Date(formData.planDate).toISOString(),
        operator_id: 1, // 这里应该使用当前登录用户的ID
        description: formData.description
      }
      
      // 如果是抽盘，添加商品ID列表
      if (formData.checkType === 'spot_check') {
        submitData.product_ids = formData.productIds
      }
      
      // 提交创建请求
      const response = await inventoryCheckService.createCheck(submitData)
      
      message.success('盘点单创建成功')
      
      // 跳转到盘点单详情页
      router.push(`/inventory-checks/${response.data.ID}`)
    } catch (error) {
      console.error('创建盘点单失败:', error)
      if (error.response && error.response.data && error.response.data.error) {
        message.error(`创建盘点单失败: ${error.response.data.error}`)
      } else {
        message.error('创建盘点单失败')
      }
    } finally {
      submitting.value = false
    }
  })
}
</script>

<style scoped>
.inventory-check-create {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 10px;
}

.page-title {
  margin: 0;
  font-size: 24px;
}

.form-card {
  max-width: 800px;
  margin: 0 auto;
}
</style>
