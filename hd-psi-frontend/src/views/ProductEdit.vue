<template>
  <div class="product-edit">
    <div class="page-header">
      <div class="header-left">
        <n-icon size="24" class="header-icon">
          <CreateOutline />
        </n-icon>
        <div>
          <h1 class="page-title">编辑商品</h1>
          <p class="page-subtitle">{{ formData.sku }} - {{ formData.name }}</p>
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
      <n-spin :show="loading">
        <n-card title="商品信息" class="form-card">
          <n-form
            ref="formRef"
            :model="formData"
            :rules="rules"
            label-placement="left"
            label-width="auto"
            require-mark-placement="right-hanging"
          >
            <n-grid :cols="24" :x-gap="24">
              <n-form-item-gi :span="8" label="SKU" path="sku">
                <n-input v-model:value="formData.sku" placeholder="请输入商品SKU" />
              </n-form-item-gi>

              <n-form-item-gi :span="16" label="商品名称" path="name">
                <n-input v-model:value="formData.name" placeholder="请输入商品名称" />
              </n-form-item-gi>

              <n-form-item-gi :span="8" label="类别" path="category">
                <n-select v-model:value="formData.category" :options="categoryOptions" placeholder="请选择类别" />
              </n-form-item-gi>

              <n-form-item-gi :span="8" label="颜色" path="color">
                <n-select v-model:value="formData.color" :options="colorOptions" placeholder="请选择颜色" />
              </n-form-item-gi>

              <n-form-item-gi :span="8" label="尺码" path="size">
                <n-select v-model:value="formData.size" :options="sizeOptions" placeholder="请选择尺码" />
              </n-form-item-gi>

              <n-form-item-gi :span="8" label="季节" path="season">
                <n-select v-model:value="formData.season" :options="seasonOptions" placeholder="请选择季节" />
              </n-form-item-gi>

              <n-form-item-gi :span="8" label="成本价" path="costPrice">
                <n-input-number v-model:value="formData.costPrice" placeholder="请输入成本价" :min="0" :precision="2" />
              </n-form-item-gi>

              <n-form-item-gi :span="8" label="零售价" path="retailPrice">
                <n-input-number v-model:value="formData.retailPrice" placeholder="请输入零售价" :min="0" :precision="2" />
              </n-form-item-gi>

              <n-form-item-gi :span="24" label="商品图片" path="image">
                <n-input v-model:value="formData.image" placeholder="请输入商品图片URL" />
              </n-form-item-gi>
            </n-grid>
          </n-form>
        </n-card>
      </n-spin>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import {
  NButton, NCard, NForm, NFormItem, NFormItemGi, NGrid, NInput,
  NInputNumber, NSelect, NSpace, NIcon, NSpin, useMessage
} from 'naive-ui'
import {
  CreateOutline, ArrowBackOutline, SaveOutline
} from '@vicons/ionicons5'
import productService from '../services/product'

// 路由
const router = useRouter()
const route = useRoute()
const message = useMessage()

// 表单引用
const formRef = ref(null)

// 状态
const loading = ref(false)
const saving = ref(false)
const productId = ref(parseInt(route.params.id))

// 表单数据
const formData = reactive({
  sku: '',
  name: '',
  category: null,
  color: null,
  size: null,
  season: null,
  costPrice: 0,
  retailPrice: 0,
  image: ''
})

// 表单验证规则
const rules = {
  sku: {
    required: true,
    message: '请输入商品SKU',
    trigger: 'blur'
  },
  name: {
    required: true,
    message: '请输入商品名称',
    trigger: 'blur'
  },
  category: {
    required: true,
    message: '请选择商品类别',
    trigger: 'change'
  },
  retailPrice: {
    required: true,
    type: 'number',
    message: '请输入零售价',
    trigger: 'change'
  }
}

// 选项数据
const categoryOptions = [
  { label: '外套', value: '外套' },
  { label: '裤装', value: '裤装' },
  { label: '衬衫', value: '衬衫' },
  { label: 'T恤', value: 'T恤' },
  { label: '内衣', value: '内衣' },
  { label: '配饰', value: '配饰' }
]

const colorOptions = [
  { label: '黑色', value: '黑色' },
  { label: '白色', value: '白色' },
  { label: '红色', value: '红色' },
  { label: '蓝色', value: '蓝色' },
  { label: '绿色', value: '绿色' },
  { label: '黄色', value: '黄色' },
  { label: '紫色', value: '紫色' },
  { label: '粉色', value: '粉色' },
  { label: '灰色', value: '灰色' },
  { label: '棕色', value: '棕色' }
]

const sizeOptions = [
  { label: 'XS', value: 'XS' },
  { label: 'S', value: 'S' },
  { label: 'M', value: 'M' },
  { label: 'L', value: 'L' },
  { label: 'XL', value: 'XL' },
  { label: 'XXL', value: 'XXL' },
  { label: '均码', value: '均码' }
]

const seasonOptions = [
  { label: '春季', value: '春季' },
  { label: '夏季', value: '夏季' },
  { label: '秋季', value: '秋季' },
  { label: '冬季', value: '冬季' },
  { label: '四季', value: '四季' }
]

// 加载商品数据
const loadProduct = async () => {
  if (!productId.value) {
    message.error('无效的商品ID')
    router.push('/products')
    return
  }

  loading.value = true
  try {
    const product = await productService.getProduct(productId.value)
    console.log('从后端获取的商品数据:', product)

    // 将后端字段名称转换为前端字段名称
    formData.id = product.ID
    formData.sku = product.SKU || ''
    formData.name = product.Name || ''
    formData.category = product.Category || null
    formData.color = product.Color || null
    formData.size = product.Size || null
    formData.season = product.Season || null
    formData.costPrice = product.CostPrice || 0
    formData.retailPrice = product.RetailPrice || 0
    formData.image = product.Image || ''

    console.log('转换后的表单数据:', formData)
  } catch (error) {
    console.error('加载商品数据失败:', error)
    message.error('加载商品数据失败: ' + (error.response?.data?.error || '未知错误'))
    router.push('/products')
  } finally {
    loading.value = false
  }
}

// 方法
const goBack = () => {
  router.push('/products')
}

const handleSave = () => {
  formRef.value?.validate(async (errors) => {
    if (errors) {
      return
    }

    saving.value = true
    try {
      // 将字段名称转换为大写，以匹配后端模型
      const productData = {
        ID: productId.value,
        SKU: formData.sku,
        Name: formData.name,
        Category: formData.category,
        Color: formData.color,
        Size: formData.size,
        Season: formData.season,
        CostPrice: formData.costPrice,
        RetailPrice: formData.retailPrice,
        Image: formData.image
      }

      // 调试输出
      console.log('发送到后端的数据:', productData)

      // 调用API更新商品数据
      await productService.updateProduct(productId.value, productData)

      message.success('商品更新成功')

      // 显示成功消息后返回列表页面
      setTimeout(() => {
        router.push('/products')
      }, 500)
    } catch (error) {
      console.error('更新商品失败:', error)
      message.error('更新商品失败: ' + (error.response?.data?.error || '未知错误'))
    } finally {
      saving.value = false
    }
  })
}

// 生命周期钩子
onMounted(() => {
  loadProduct()
})
</script>

<style scoped>
.product-edit {
  padding: 16px;
  background-color: #f5f7fa;
  min-height: calc(100vh - 64px);
}

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
  color: #2080f0;
}

.page-title {
  margin: 0;
  font-size: 20px;
  font-weight: 500;
}

.page-subtitle {
  margin: 4px 0 0;
  font-size: 14px;
  color: #909399;
}

.form-card {
  margin-bottom: 16px;
}

.btn-save {
  min-width: 100px;
}
</style>
