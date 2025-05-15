<template>
  <div class="product-edit">
    <div class="page-header">
      <div class="header-left">
        <n-button @click="goBack" class="btn-back">
          <template #icon>
            <n-icon><ArrowBackOutline /></n-icon>
          </template>
          返回
        </n-button>
        <h1 class="page-title">{{ isEditing ? '编辑商品' : '添加商品' }}</h1>
      </div>
      <div class="header-right">
        <n-button @click="toggleDebug" type="warning" class="mr-2">
          {{ showDebug ? '隐藏调试' : '显示调试' }}
        </n-button>
      </div>
    </div>

    <div class="page-content">
      <n-form
        ref="formRef"
        :model="formData"
        label-placement="left"
        label-width="auto"
        require-mark-placement="right-hanging"
      >
        <n-card title="商品信息" class="mb-4">
          <n-grid :cols="2" :x-gap="24">
            <n-form-item-gi label="SKU" path="sku">
              <n-input-group>
                <n-input v-model:value="formData.sku" placeholder="请输入商品SKU" />
                <n-button type="primary" @click="generateSKU" :disabled="!formData.category || !formData.brand">
                  生成SKU
                </n-button>
              </n-input-group>
              <n-text depth="3" style="font-size: 12px;">
                提示: 选择类别和品牌后可自动生成SKU
              </n-text>
            </n-form-item-gi>
            <n-form-item-gi label="商品名称" path="name">
              <n-input v-model:value="formData.name" placeholder="请输入商品名称" />
            </n-form-item-gi>
          </n-grid>

          <n-grid :cols="2" :x-gap="24">
            <n-form-item-gi label="类别" path="category">
              <n-select
                v-model:value="formData.category"
                placeholder="请选择类别"
                :options="categoryOptions"
                clearable
              />
            </n-form-item-gi>
            <n-form-item-gi label="品牌" path="brand">
              <n-select
                v-model:value="formData.brand"
                placeholder="请选择品牌"
                :options="brandOptions"
                clearable
              />
            </n-form-item-gi>
          </n-grid>

          <n-grid :cols="3" :x-gap="24">
            <n-form-item-gi label="颜色" path="color">
              <n-select
                v-model:value="formData.color"
                placeholder="请选择颜色"
                :options="colorOptions"
                clearable
              />
            </n-form-item-gi>
            <n-form-item-gi label="尺码" path="size">
              <n-select
                v-model:value="formData.size"
                placeholder="请选择尺码"
                :options="sizeOptions"
                clearable
              />
            </n-form-item-gi>
            <n-form-item-gi label="季节" path="season">
              <n-select
                v-model:value="formData.season"
                placeholder="请选择季节"
                :options="seasonOptions"
                clearable
              />
            </n-form-item-gi>
          </n-grid>

          <n-grid :cols="2" :x-gap="24">
            <n-form-item-gi label="成本价" path="costPrice">
              <n-input-number
                v-model:value="formData.costPrice"
                placeholder="请输入成本价"
                :min="0"
                :precision="2"
                prefix="¥"
              />
            </n-form-item-gi>
            <n-form-item-gi label="零售价" path="retailPrice">
              <n-input-number
                v-model:value="formData.retailPrice"
                placeholder="请输入零售价"
                :min="0"
                :precision="2"
                prefix="¥"
              />
            </n-form-item-gi>
          </n-grid>
        </n-card>

        <n-card title="商品图片" class="mb-4">
          <n-upload
            list-type="image-card"
            :default-upload="false"
            :max="5"
            :on-before-upload="beforeUpload"
            :on-change="handleUploadChange"
          >
            <div style="margin-bottom: 8px">
              <n-icon size="48" :depth="3">
                <CloudUploadOutline />
              </n-icon>
            </div>
            <n-text style="font-size: 16px">
              点击或拖动文件到此区域上传
            </n-text>
            <n-p depth="3" style="margin: 8px 0 0 0">
              支持单个或批量上传，最多5张图片
            </n-p>
          </n-upload>
        </n-card>

        <n-card title="商品描述" class="mb-4">
          <n-form-item path="description">
            <div class="editor-container">
              <div ref="editorRef" class="editor"></div>
            </div>
          </n-form-item>
        </n-card>

        <div class="form-actions">
          <n-space justify="end">
            <n-button @click="goBack">取消</n-button>
            <n-button type="primary" @click="handleSave" :loading="saving">保存</n-button>
          </n-space>
        </div>
      </n-form>
    </div>

    <!-- 调试信息区域 -->
    <n-collapse v-if="showDebug">
      <n-collapse-item title="调试信息" name="debug">
        <n-card title="原始商品数据">
          <pre>{{ JSON.stringify(rawProduct, null, 2) }}</pre>
        </n-card>
        <n-card title="表单数据" class="mt-4">
          <pre>{{ JSON.stringify(formData, null, 2) }}</pre>
        </n-card>
        <n-card title="字典选项" class="mt-4">
          <h3>类别选项</h3>
          <pre>{{ JSON.stringify(categoryOptions, null, 2) }}</pre>
          <h3>颜色选项</h3>
          <pre>{{ JSON.stringify(colorOptions, null, 2) }}</pre>
          <h3>尺码选项</h3>
          <pre>{{ JSON.stringify(sizeOptions, null, 2) }}</pre>
          <h3>季节选项</h3>
          <pre>{{ JSON.stringify(seasonOptions, null, 2) }}</pre>
        </n-card>
      </n-collapse-item>
    </n-collapse>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, nextTick } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import {
  NButton, NForm, NFormItem, NFormItemGi, NInput, NInputNumber, NSelect,
  NUpload, NCard, NGrid, NSpace, NIcon, NText, NP, useMessage,
  NCollapse, NCollapseItem, NInputGroup
} from 'naive-ui'
import { ArrowBackOutline, CloudUploadOutline } from '@vicons/ionicons5'
import productService from '../services/product'
import { generateSKU as genSKU, generateVariantSKU } from '../utils/skuGenerator'

// 路由和消息
const router = useRouter()
const route = useRoute()
const message = useMessage()

// 获取商品ID（如果是编辑模式）
const productId = ref(route.params.id)
const isEditing = ref(!!productId.value)
const rawProduct = ref(null) // 原始商品数据
const showDebug = ref(true) // 显示调试信息

// 表单和验证
const formRef = ref(null)
const saving = ref(false)

// 表单数据
const formData = reactive({
  id: 0,
  sku: '',
  name: '',
  category: null,
  brand: null,
  color: null,
  size: null,
  season: null,
  costPrice: 0,
  retailPrice: 0,
  image: '',
  description: ''
})

// 移除表单验证规则，改为手动验证
const rules = {}

// 选项数据
const categoryOptions = ref([])
const brandOptions = ref([])
const colorOptions = ref([])
const sizeOptions = ref([])
const seasonOptions = ref([])

// 加载字典项
const loadDictionaryItems = async (code, optionsRef) => {
  try {
    const dictionaryService = (await import('../services/dictionary')).default
    const items = await dictionaryService.getDictionaryItems(code)
    console.log(`原始${code}字典项数据:`, items)

    // 构建选项
    optionsRef.value = items.map(item => {
      // 处理字段名称不一致的情况
      const name = item.Name || item.name || ''
      const id = item.ID || item.id || 0
      const status = item.Status !== undefined ? item.Status : (item.status !== undefined ? item.status : true)

      return {
        label: name,
        value: id, // 使用ID作为选择器的值，这样更可靠
        name: name, // 保存名称以便于显示
        disabled: !status // 根据状态设置是否禁用
      }
    })

    console.log(`${code}字典项加载成功:`, optionsRef.value)
  } catch (error) {
    console.error(`加载${code}字典数据失败:`, error)
    message.error(`加载${code}字典数据失败: ${error.message || '未知错误'}`)
  }
}

// 这些函数现在直接返回ID，因为选择器的值已经是ID了
const getCategoryID = (id) => {
  return id
}

const getBrandID = (id) => {
  return id
}

const getColorID = (id) => {
  return id
}

const getSizeID = (id) => {
  return id
}

const getSeasonID = (id) => {
  return id
}

// 加载商品数据
const loadProduct = async () => {
  if (!productId.value) {
    return
  }

  try {
    const product = await productService.getProduct(productId.value)
    console.log('从后端获取的商品数据:', product)
    rawProduct.value = product

    // 将后端字段名称转换为前端字段名称
    // 注意：字段名称已经被 convertBackendFields 函数转换为小写了
    formData.id = product.id || 0
    formData.sku = product.sku || ''
    formData.name = product.name || ''

    // 处理关联字段 - 现在使用ID作为选择器的值
    if (product.category) {
      // 使用ID作为选择器的值
      const categoryId = product.category.id || (typeof product.category === 'number' ? product.category : null);
      formData.category = categoryId;
      console.log('设置类别ID:', formData.category, '类别对象:', product.category)
    } else if (product.categoryId) {
      // 直接使用categoryId字段（如果存在）
      formData.category = product.categoryId;
      console.log('使用categoryId字段:', formData.category)
    } else {
      formData.category = null
    }

    if (product.brand) {
      const brandId = product.brand.id || (typeof product.brand === 'number' ? product.brand : null);
      formData.brand = brandId;
      console.log('设置品牌ID:', formData.brand, '品牌对象:', product.brand)
    } else if (product.brandId) {
      formData.brand = product.brandId;
      console.log('使用brandId字段:', formData.brand)
    } else {
      formData.brand = null
    }

    if (product.color) {
      const colorId = product.color.id || (typeof product.color === 'number' ? product.color : null);
      formData.color = colorId;
      console.log('设置颜色ID:', formData.color, '颜色对象:', product.color)
    } else if (product.colorId) {
      formData.color = product.colorId;
      console.log('使用colorId字段:', formData.color)
    } else {
      formData.color = null
    }

    if (product.size) {
      const sizeId = product.size.id || (typeof product.size === 'number' ? product.size : null);
      formData.size = sizeId;
      console.log('设置尺码ID:', formData.size, '尺码对象:', product.size)
    } else if (product.sizeId) {
      formData.size = product.sizeId;
      console.log('使用sizeId字段:', formData.size)
    } else {
      formData.size = null
    }

    if (product.season) {
      const seasonId = product.season.id || (typeof product.season === 'number' ? product.season : null);
      formData.season = seasonId;
      console.log('设置季节ID:', formData.season, '季节对象:', product.season)
    } else if (product.seasonId) {
      formData.season = product.seasonId;
      console.log('使用seasonId字段:', formData.season)
    } else {
      formData.season = null
    }

    formData.costPrice = product.costPrice || 0
    formData.retailPrice = product.retailPrice || 0
    formData.image = product.image || ''
    formData.description = product.description || ''

    console.log('转换后的表单数据:', formData)
  } catch (error) {
    console.error('加载商品数据失败:', error)
    message.error('加载商品数据失败: ' + (error.response?.data?.error || '未知错误'))
    router.push('/products')
  }
}

// 切换调试信息显示
const toggleDebug = () => {
  showDebug.value = !showDebug.value
}

// 返回商品列表
const goBack = () => {
  router.push('/products')
}

// 生成SKU
const generateSKU = async () => {
  if (!formData.category || !formData.brand) {
    message.warning('请先选择商品类别和品牌')
    return
  }

  try {
    // 获取类别和品牌信息
    const category = categoryOptions.value.find(item => item.value === formData.category)
    const brand = brandOptions.value.find(item => item.value === formData.brand)

    // 获取当前商品序列号
    const response = await productService.getProducts({
      pageSize: 1,
      categoryId: formData.category,
      brandId: formData.brand
    })

    // 计算序列号
    let sequence = 1
    if (response && response.total > 0) {
      // 尝试从现有SKU中提取序列号
      const existingSKUs = response.items.map(item => item.sku)
      const maxSequence = existingSKUs.reduce((max, sku) => {
        const parts = sku.split('-')
        if (parts.length >= 4) {
          const seq = parseInt(parts[3])
          return seq > max ? seq : max
        }
        return max
      }, 0)
      sequence = maxSequence + 1
    }

    // 生成SKU
    const sku = genSKU({
      category,
      brand,
      sequence,
      date: new Date()
    })

    // 更新表单
    formData.sku = sku
    message.success('SKU生成成功')
  } catch (error) {
    console.error('生成SKU失败:', error)
    message.error('生成SKU失败: ' + (error.message || '未知错误'))
  }
}

// 上传相关方法
const beforeUpload = (data) => {
  console.log('准备上传:', data)
  return true
}

const handleUploadChange = (options) => {
  console.log('上传变化:', options)
}

// 保存商品
const handleSave = async () => {
  // 手动验证必填字段
  let hasError = false;

  // 检查保存时 formData.category 的值
  console.log('保存时formData.category的值:', formData.category);

  // 验证SKU
  if (!formData.sku) {
    message.error('请输入商品SKU');
    hasError = true;
  }

  // 验证商品名称
  if (!formData.name) {
    message.error('请输入商品名称');
    hasError = true;
  }

  // 验证商���类别
  if (!formData.category) {
    message.error('请选择商品类别');
    hasError = true;
  }

  // 如果有错误，不继续执行
  if (hasError) {
    return;
  }

  // 开始保存
  saving.value = true;
  try {
    // 打印表单数据，确保所有必填字段都有值
    console.log('准备保存的表单数据:', {
      id: formData.id,
      sku: formData.sku,
      name: formData.name,
      category: formData.category,
      brand: formData.brand,
      color: formData.color,
      size: formData.size,
      season: formData.season
    });

    // 将字段名称转换为大写，以匹配后端模型
    const productData = {
      id: productId.value,
      sku: formData.sku,
      name: formData.name,
      categoryID: getCategoryID(formData.category),
      brandID: getBrandID(formData.brand),
      colorID: getColorID(formData.color),
      sizeID: getSizeID(formData.size),
      seasonID: getSeasonID(formData.season),
      costPrice: formData.costPrice,
      retailPrice: formData.retailPrice,
      image: formData.image,
      description: formData.description
    }

    // 调试输出
    console.log('发送到后端的数据:', productData)

    if (isEditing.value) {
      await productService.updateProduct(productId.value, productData)
      message.success('商品更新成功')
    } else {
      const result = await productService.createProduct(productData)
      message.success('商品添加成功')
    }

    router.push('/products')
  } catch (error) {
    console.error('保存商品失败:', error)
    message.error('保存失败: ' + (error.response?.data?.error || '未知错误'))
  } finally {
    saving.value = false
  }
}

// 生命周期钩子
onMounted(async () => {
  try {
    // 先加载字典项
    console.log('开始加载字典项...')
    await Promise.all([
      loadDictionaryItems('category', categoryOptions),
      loadDictionaryItems('brand', brandOptions),
      loadDictionaryItems('color', colorOptions),
      loadDictionaryItems('size', sizeOptions),
      loadDictionaryItems('season', seasonOptions)
    ])
    console.log('字典项加载完成')

    // 等待字典项加载完成后再加载商品数据
    if (isEditing.value) {
      console.log('开始加载商品数据...')
      await loadProduct()
      console.log('商品数据加载完成')
    }
  } catch (error) {
    console.error('初始化数据失败:', error)
    message.error('初始化数据失败: ' + error.message)
  }
})
</script>

<style scoped>
.product-edit {
  padding: 16px;
  background-color: var(--background-color-base);
  min-height: calc(100vh - 64px);
}

.dark .product-edit {
  background-color: var(--background-color);
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

.header-right {
  display: flex;
  gap: 8px;
}

.btn-back {
  margin-right: 16px;
}

.page-title {
  margin: 0;
  font-size: 20px;
  font-weight: 500;
}

.page-content {
  background-color: var(--card-background);
  border-radius: 4px;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
  padding: 16px;
}

.dark .page-content {
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.2);
}

.mb-4 {
  margin-bottom: 16px;
}

.mt-4 {
  margin-top: 16px;
}

.mr-2 {
  margin-right: 8px;
}

.form-actions {
  margin-top: 24px;
}

.editor-container {
  border: 1px solid var(--border-color-base);
  border-radius: 4px;
  min-height: 300px;
}

.editor {
  min-height: 300px;
}
</style>
