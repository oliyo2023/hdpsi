<template>
  <div class="product-create">
    <div class="page-header">
      <div class="header-left">
        <n-icon size="24" class="header-icon">
          <AddCircleOutline />
        </n-icon>
        <div>
          <h1 class="page-title">添加商品</h1>
          <p class="page-subtitle">创建新的商品信息</p>
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

            <n-form-item-gi :span="8" label="类别" path="categoryId">
              <n-select 
                v-model:value="formData.categoryId" 
                :options="categoryOptions" 
                placeholder="请选择类别" 
              />
            </n-form-item-gi>

            <n-form-item-gi :span="8" label="品牌" path="brandId">
              <n-select 
                v-model:value="formData.brandId" 
                :options="brandOptions" 
                placeholder="请选择品牌" 
              />
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

            <n-form-item-gi :span="24" label="商品描述" path="description">
              <n-input 
                v-model:value="formData.description" 
                type="textarea" 
                placeholder="请输入商品描述" 
                :autosize="{ minRows: 3, maxRows: 6 }" 
              />
            </n-form-item-gi>
          </n-grid>
        </n-form>
      </n-card>

      <n-card title="商品变体" class="form-card">
        <n-space vertical>
          <n-alert type="info" title="提示">
            添加商品变体可以管理不同颜色、尺码等组合的库存。您可以在创建商品后添加变体，或者在此处预先添加常用变体。
          </n-alert>

          <n-space>
            <n-button type="primary" @click="addVariant">
              添加变体
            </n-button>
          </n-space>

          <n-data-table
            :columns="variantColumns"
            :data="variants"
            :bordered="false"
            :single-line="false"
            size="small"
          />
        </n-space>
      </n-card>

      <!-- 变体表单对话框 -->
      <n-modal
        v-model:show="showVariantModal"
        title="添加商品变体"
        preset="card"
        style="width: 600px"
        :mask-closable="false"
      >
        <n-form
          ref="variantFormRef"
          :model="variantForm"
          :rules="variantRules"
          label-placement="left"
          label-width="auto"
          require-mark-placement="right-hanging"
        >
          <n-grid :cols="24" :x-gap="24">
            <n-form-item-gi :span="12" label="颜色" path="colorId">
              <n-select 
                v-model:value="variantForm.colorId" 
                :options="colorOptions" 
                placeholder="请选择颜色" 
                :render-label="renderColorLabel"
              />
            </n-form-item-gi>

            <n-form-item-gi :span="12" label="尺码" path="sizeId">
              <n-select 
                v-model:value="variantForm.sizeId" 
                :options="sizeOptions" 
                placeholder="请选择尺码" 
              />
            </n-form-item-gi>

            <n-form-item-gi :span="12" label="季节" path="seasonId">
              <n-select 
                v-model:value="variantForm.seasonId" 
                :options="seasonOptions" 
                placeholder="请选择季节" 
              />
            </n-form-item-gi>

            <n-form-item-gi :span="12" label="面料" path="fabricId">
              <n-select 
                v-model:value="variantForm.fabricId" 
                :options="fabricOptions" 
                placeholder="请选择面料" 
              />
            </n-form-item-gi>

            <n-form-item-gi :span="12" label="成本价" path="costPrice">
              <n-input-number 
                v-model:value="variantForm.costPrice" 
                placeholder="请输入成本价" 
                :min="0" 
                :precision="2" 
              />
            </n-form-item-gi>

            <n-form-item-gi :span="12" label="零售价" path="retailPrice">
              <n-input-number 
                v-model:value="variantForm.retailPrice" 
                placeholder="请输入零售价" 
                :min="0" 
                :precision="2" 
              />
            </n-form-item-gi>

            <n-form-item-gi :span="24" label="条形码" path="barcode">
              <n-input 
                v-model:value="variantForm.barcode" 
                placeholder="请输入条形码" 
              />
            </n-form-item-gi>
          </n-grid>
        </n-form>

        <template #footer>
          <n-space justify="end">
            <n-button @click="showVariantModal = false">取消</n-button>
            <n-button type="primary" @click="handleAddVariant" :loading="savingVariant">确定</n-button>
          </n-space>
        </template>
      </n-modal>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, h } from 'vue'
import { useRouter } from 'vue-router'
import {
  NButton, NCard, NForm, NFormItem, NFormItemGi, NGrid, NInput,
  NInputNumber, NSelect, NSpace, NIcon, useMessage, NTag,
  NDataTable, NModal, NAlert
} from 'naive-ui'
import {
  AddCircleOutline, ArrowBackOutline, SaveOutline
} from '@vicons/ionicons5'
import productService from '../services/product'
import dictionaryService from '../services/dictionary'

// 路由
const router = useRouter()
const message = useMessage()

// 表单引用
const formRef = ref(null)
const variantFormRef = ref(null)

// 状态
const saving = ref(false)
const savingVariant = ref(false)
const showVariantModal = ref(false)

// 表单数据
const formData = reactive({
  sku: '',
  name: '',
  categoryId: null,
  brandId: null,
  description: '',
  costPrice: 0,
  retailPrice: 0,
  image: '',
  status: true
})

// 变体数据
const variants = ref([])
const variantForm = reactive({
  colorId: null,
  sizeId: null,
  seasonId: null,
  fabricId: null,
  barcode: '',
  costPrice: 0,
  retailPrice: 0
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
  categoryId: {
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

// 变体表单验证规则
const variantRules = {
  colorId: {
    required: true,
    message: '请选择颜色',
    trigger: 'change'
  },
  sizeId: {
    required: true,
    message: '请选择尺码',
    trigger: 'change'
  }
}

// 选项数据
const categoryOptions = ref([])
const colorOptions = ref([])
const sizeOptions = ref([])
const seasonOptions = ref([])
const brandOptions = ref([])
const fabricOptions = ref([])

// 加载字典项
const loadDictionaryItems = async (code, optionsRef) => {
  try {
    const items = await dictionaryService.getDictionaryItems(code)
    optionsRef.value = items.map(item => ({
      label: item.name,
      value: item.id,
      color: item.color,
      code: item.code,
      disabled: !item.status
    }))
  } catch (error) {
    console.error(`加载${code}字典项失败:`, error)
    message.error(`加载${code}字典项失败`)
  }
}

// 渲染颜色选项
const renderColorLabel = (option) => {
  return h(
    'div',
    {
      style: {
        display: 'flex',
        alignItems: 'center'
      }
    },
    [
      h(
        'div',
        {
          style: {
            width: '16px',
            height: '16px',
            borderRadius: '4px',
            backgroundColor: option.color || '#fff',
            border: '1px solid #ddd',
            marginRight: '8px'
          }
        }
      ),
      option.label
    ]
  )
}

// 变体表格列定义
const variantColumns = [
  {
    title: '颜色',
    key: 'color',
    render(row) {
      const color = colorOptions.value.find(c => c.value === row.colorId)
      return h(
        'div',
        {
          style: {
            display: 'flex',
            alignItems: 'center'
          }
        },
        [
          h(
            'div',
            {
              style: {
                width: '16px',
                height: '16px',
                borderRadius: '4px',
                backgroundColor: color?.color || '#fff',
                border: '1px solid #ddd',
                marginRight: '8px'
              }
            }
          ),
          color?.label || '未知'
        ]
      )
    }
  },
  {
    title: '尺码',
    key: 'size',
    render(row) {
      const size = sizeOptions.value.find(s => s.value === row.sizeId)
      return size?.label || '未知'
    }
  },
  {
    title: '季节',
    key: 'season',
    render(row) {
      const season = seasonOptions.value.find(s => s.value === row.seasonId)
      return season?.label || '未知'
    }
  },
  {
    title: '面料',
    key: 'fabric',
    render(row) {
      const fabric = fabricOptions.value.find(f => f.value === row.fabricId)
      return fabric?.label || '未知'
    }
  },
  {
    title: '成本价',
    key: 'costPrice'
  },
  {
    title: '零售价',
    key: 'retailPrice'
  },
  {
    title: '操作',
    key: 'actions',
    render(row, index) {
      return h(
        NButton,
        {
          size: 'small',
          type: 'error',
          onClick: () => removeVariant(index)
        },
        { default: () => '删除' }
      )
    }
  }
]

// 方法
const goBack = () => {
  router.push('/products')
}

const addVariant = () => {
  // 重置变体表单
  variantForm.colorId = null
  variantForm.sizeId = null
  variantForm.seasonId = null
  variantForm.fabricId = null
  variantForm.barcode = ''
  variantForm.costPrice = formData.costPrice
  variantForm.retailPrice = formData.retailPrice
  
  showVariantModal.value = true
}

const handleAddVariant = () => {
  variantFormRef.value?.validate(async (errors) => {
    if (errors) {
      return
    }

    // 检查是否已存在相同的变体
    const existingVariant = variants.value.find(
      v => v.colorId === variantForm.colorId && v.sizeId === variantForm.sizeId
    )

    if (existingVariant) {
      message.warning('已存在相同颜色和尺码的变体')
      return
    }

    // 添加到变体列表
    variants.value.push({ ...variantForm })
    showVariantModal.value = false
  })
}

const removeVariant = (index) => {
  variants.value.splice(index, 1)
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
        SKU: formData.sku,
        Name: formData.name,
        CategoryID: formData.categoryId,
        BrandID: formData.brandId,
        Description: formData.description,
        CostPrice: formData.costPrice,
        RetailPrice: formData.retailPrice,
        Image: formData.image,
        Status: formData.status,
        Variants: variants.value.map(v => ({
          ColorID: v.colorId,
          SizeID: v.sizeId,
          SeasonID: v.seasonId,
          FabricID: v.fabricId,
          Barcode: v.barcode,
          CostPrice: v.costPrice,
          RetailPrice: v.retailPrice
        }))
      }

      // 调试输出
      console.log('发送到后端的数据:', productData)

      // 调用API保存商品数据
      await productService.createProduct(productData)

      message.success('商品添加成功')

      // 显示成功消息后返回列表页面
      setTimeout(() => {
        router.push('/products')
      }, 500)
    } catch (error) {
      console.error('保存商品失败:', error)
      message.error('保存商品失败: ' + (error.response?.data?.error || '未知错误'))
    } finally {
      saving.value = false
    }
  })
}

// 生命周期钩子
onMounted(async () => {
  // 加载字典数据
  await Promise.all([
    loadDictionaryItems('category', categoryOptions),
    loadDictionaryItems('color', colorOptions),
    loadDictionaryItems('size', sizeOptions),
    loadDictionaryItems('season', seasonOptions),
    loadDictionaryItems('brand', brandOptions),
    loadDictionaryItems('fabric', fabricOptions)
  ])
})
</script>

<style scoped>
.product-create {
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
