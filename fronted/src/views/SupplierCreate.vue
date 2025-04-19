<template>
  <div class="supplier-create">
    <div class="page-header">
      <div class="header-left">
        <n-icon size="24" class="header-icon">
          <StorefrontOutline />
        </n-icon>
        <div>
          <h1 class="page-title">添加供应商</h1>
          <p class="page-subtitle">创建新的供应商信息</p>
        </div>
      </div>
      <div class="header-actions">
        <n-space>
          <n-button @click="goBack" class="btn-cancel">
            <template #icon>
              <n-icon><ArrowBackOutline /></n-icon>
            </template>
            返回
          </n-button>
          <n-button type="primary" @click="handleSave" :loading="saving" class="btn-save">
            <template #icon>
              <n-icon><SaveOutline /></n-icon>
            </template>
            保存
          </n-button>
        </n-space>
      </div>
    </div>

    <div class="page-content">
      <n-form
        ref="formRef"
        :model="formData"
        :rules="rules"
        label-placement="left"
        label-width="auto"
        require-mark-placement="right-hanging"
      >
        <n-card title="基本信息" class="card-section">
          <template #header-extra>
            <n-icon size="18" color="#2080f0">
              <InformationCircleOutline />
            </n-icon>
          </template>
          <n-grid :cols="3" :x-gap="24">
            <n-grid-item>
              <n-form-item label="供应商编码" path="code">
                <n-input v-model:value="formData.code" placeholder="请输入供应商编码">
                  <template #prefix>
                    <n-icon><CardOutline /></n-icon>
                  </template>
                </n-input>
              </n-form-item>
            </n-grid-item>

            <n-grid-item>
              <n-form-item label="供应商名称" path="name">
                <n-input v-model:value="formData.name" placeholder="请输入供应商名称">
                  <template #prefix>
                    <n-icon><StorefrontOutline /></n-icon>
                  </template>
                </n-input>
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
                <n-input v-model:value="formData.contactPerson" placeholder="请输入联系人">
                  <template #prefix>
                    <n-icon><PersonOutline /></n-icon>
                  </template>
                </n-input>
              </n-form-item>
            </n-grid-item>

            <n-grid-item>
              <n-form-item label="联系电话" path="contactPhone">
                <n-input v-model:value="formData.contactPhone" placeholder="请输入联系电话">
                  <template #prefix>
                    <n-icon><CallOutline /></n-icon>
                  </template>
                </n-input>
              </n-form-item>
            </n-grid-item>

            <n-grid-item>
              <n-form-item label="电子邮箱" path="email">
                <n-input v-model:value="formData.email" placeholder="请输入电子邮箱">
                  <template #prefix>
                    <n-icon><MailOutline /></n-icon>
                  </template>
                </n-input>
              </n-form-item>
            </n-grid-item>
          </n-grid>
        </n-card>

        <n-card title="地址信息" class="mt-4 card-section">
          <template #header-extra>
            <n-icon size="18" color="#18a058">
              <LocationOutline />
            </n-icon>
          </template>
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

        <n-card title="合作信息" class="mt-4 card-section">
          <template #header-extra>
            <n-icon size="18" color="#f0a020">
              <BusinessOutline />
            </n-icon>
          </template>
          <n-grid :cols="3" :x-gap="24">
            <n-grid-item>
              <n-form-item label="评级" path="rating">
                <n-select
                  v-model:value="formData.rating"
                  :options="ratingOptions"
                  placeholder="请选择评级"
                  :render-label="renderRatingLabel"
                />
              </n-form-item>
            </n-grid-item>

            <n-grid-item>
              <n-form-item label="付款条件" path="paymentTerms">
                <n-input v-model:value="formData.paymentTerms" placeholder="请输入付款条件">
                  <template #prefix>
                    <n-icon><CashOutline /></n-icon>
                  </template>
                </n-input>
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
                <n-switch v-model:value="formData.status">
                  <template #checked>
                    启用
                  </template>
                  <template #unchecked>
                    禁用
                  </template>
                </n-switch>
              </n-form-item>
            </n-grid-item>
          </n-grid>
        </n-card>

        <n-card title="备注" class="mt-4 card-section">
          <template #header-extra>
            <n-icon size="18" color="#d03050">
              <DocumentTextOutline />
            </n-icon>
          </template>
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
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, h } from 'vue'
import { useRouter } from 'vue-router'
import { useMessage } from 'naive-ui'
import {
  NButton, NCard, NForm, NFormItem, NGrid, NGridItem,
  NInput, NSelect, NSpace, NSwitch, NIcon, NTag, NAvatar
} from 'naive-ui'
import {
  StorefrontOutline, SaveOutline, ArrowBackOutline,
  InformationCircleOutline, LocationOutline, BusinessOutline,
  DocumentTextOutline, PersonOutline, CallOutline, MailOutline,
  CardOutline, CashOutline, StarOutline
} from '@vicons/ionicons5'
import supplierService from '../services/supplier'

const router = useRouter()
const message = useMessage()
const formRef = ref(null)
const saving = ref(false)

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

// 供应商类型选项
const typeOptions = [
  { label: '生产厂商', value: 'manufacturer' },
  { label: '批发商', value: 'wholesaler' },
  { label: '代理商', value: 'agent' },
  { label: '其他', value: 'other' }
]

// 评级选项
const ratingOptions = [
  { label: 'S级', value: 'S', type: 'success' },
  { label: 'A级', value: 'A', type: 'info' },
  { label: 'B级', value: 'B', type: 'default' },
  { label: 'C级', value: 'C', type: 'warning' },
  { label: 'D级', value: 'D', type: 'error' }
]

// 自定义渲染评级选项
function renderRatingLabel(option) {
  return h(
    NTag,
    {
      type: option.type,
      bordered: false,
      style: {
        padding: '0 10px'
      }
    },
    {
      default: () => [
        h(NIcon, { style: { marginRight: '4px' } }, { default: () => h(StarOutline) }),
        option.label
      ]
    }
  )
}

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

// 返回上一页
const goBack = () => {
  router.back()
}

// 保存供应商
const handleSave = () => {
  formRef.value?.validate(async (errors) => {
    if (errors) {
      return
    }

    saving.value = true
    try {
      // 调用API保存供应商数据
      await supplierService.createSupplier(formData)

      message.success('供应商添加成功')

      // 显示成功消息后返回列表页面
      setTimeout(() => {
        router.push('/suppliers')
      }, 500)
    } catch (error) {
      console.error('保存供应商失败:', error)
      message.error('保存供应商失败: ' + (error.message || '未知错误'))
    } finally {
      saving.value = false
    }
  })
}
</script>

<style scoped>
.supplier-create {
  padding: 16px;
  background-color: #f5f7fa;
  min-height: calc(100vh - 64px);
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  background-color: #fff;
  padding: 16px 24px;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.05);
}

.header-left {
  display: flex;
  align-items: center;
}

.header-icon {
  margin-right: 12px;
  color: #2080f0;
}

.page-title {
  margin: 0;
  font-size: 24px;
  font-weight: 500;
  color: #333;
}

.page-subtitle {
  margin: 4px 0 0;
  font-size: 14px;
  color: #8a9299;
}

.header-actions {
  display: flex;
  align-items: center;
}

.btn-cancel {
  margin-right: 12px;
}

.btn-save {
  font-weight: 500;
}

.page-content {
  background-color: transparent;
}

.card-section {
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.05);
  margin-bottom: 16px;
  overflow: hidden;
}

.card-section :deep(.n-card-header) {
  font-weight: 500;
  font-size: 16px;
  padding: 16px 24px;
  border-bottom: 1px solid #f0f0f0;
}

.card-section :deep(.n-card__content) {
  padding: 24px;
}

.mt-4 {
  margin-top: 16px;
}

:deep(.n-form-item-label) {
  font-weight: 500;
}

:deep(.n-input-wrapper) {
  border-radius: 4px;
}

:deep(.n-input__prefix) {
  color: #8a9299;
}
</style>
