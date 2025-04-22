<template>
  <div class="product-form">
    <div class="page-header">
      <div class="header-left">
        <n-icon size="24" class="header-icon">
          <CreateOutline />
        </n-icon>
        <div>
          <h1 class="page-title">{{ isEdit ? '编辑商品' : '添加商品' }}</h1>
          <p v-if="isEdit" class="page-subtitle">{{ formData.sku }} - {{ formData.name }}</p>
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

              <n-form-item-gi :span="24" label="商品图片" path="images">
                <n-upload
                  ref="uploadRef"
                  multiple
                  :default-upload="false"
                  :max="5"
                  list-type="image-card"
                  :default-file-list="fileList"
                  :custom-request="customUploadRequest"
                  :on-remove="handleRemoveImage"
                  :on-before-upload="beforeUpload"
                >
                  <n-upload-trigger>
                    <div class="upload-trigger">
                      <n-icon size="24">
                        <ImageOutline />
                      </n-icon>
                      <span style="margin-top: 8px">点击或拖拽上传</span>
                    </div>
                  </n-upload-trigger>
                </n-upload>
                <n-text depth="3" style="margin-top: 8px; display: block">
                  支持 jpg、png、gif、webp 格式，单张图片不超过 5MB，最多上传 5 张图片
                </n-text>
              </n-form-item-gi>

              <n-form-item-gi :span="24" label="商品描述" path="description">
                <div class="editor-container">
                  <Toolbar
                    style="border-bottom: 1px solid #ccc"
                    :editor="editor"
                    :defaultConfig="toolbarConfig"
                    :mode="mode"
                  />
                  <Editor
                    style="height: 300px; overflow-y: hidden;"
                    :defaultHtml="formData.description || ''"
                    :defaultConfig="editorConfig"
                    :mode="mode"
                    @onChange="handleEditorChange"
                    @onCreated="handleEditorCreated"
                  />
                  <div style="margin-top: 8px;">
                    <n-text depth="3">
                      {{ formData.description ? '当前描述内容长度: ' + formData.description.length : '暂无描述内容' }}
                    </n-text>
                  </div>
                </div>
              </n-form-item-gi>
            </n-grid>
          </n-form>
        </n-card>

        <!-- 调试信息卡片 -->
        <n-card title="调试信息" class="form-card" v-if="isEdit.value">
          <n-space vertical>
            <n-alert type="info" title="当前表单数据状态">
              <pre>{{ JSON.stringify(formData, null, 2) }}</pre>
            </n-alert>
          </n-space>
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
      </n-spin>

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

            <n-form-item-gi :span="24" label="条码" path="barcode">
              <n-input v-model:value="variantForm.barcode" placeholder="请输入条码" />
            </n-form-item-gi>

            <n-form-item-gi :span="12" label="成本价" path="costPrice">
              <n-input-number
                v-model:value="variantForm.costPrice"
                :min="0"
                :precision="2"
                style="width: 100%"
              />
            </n-form-item-gi>

            <n-form-item-gi :span="12" label="零售价" path="retailPrice">
              <n-input-number
                v-model:value="variantForm.retailPrice"
                :min="0"
                :precision="2"
                style="width: 100%"
              />
            </n-form-item-gi>
          </n-grid>

          <div style="display: flex; justify-content: flex-end; margin-top: 24px">
            <n-space>
              <n-button @click="showVariantModal = false">取消</n-button>
              <n-button type="primary" @click="handleAddVariant" :loading="savingVariant">
                确认
              </n-button>
            </n-space>
          </div>
        </n-form>
      </n-modal>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onBeforeUnmount, h, computed, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import {
  NButton, NCard, NForm, NFormItem, NFormItemGi, NGrid, NInput,
  NInputNumber, NSelect, NSpace, NIcon, NSpin, useMessage, NTag,
  NDataTable, NModal, NAlert, NUpload, NUploadTrigger, NText
} from 'naive-ui'
import {
  CreateOutline, ArrowBackOutline, SaveOutline, ImageOutline
} from '@vicons/ionicons5'
// 使用wangEditor替代AiEditor
import { Editor, Toolbar } from '@wangeditor/editor-for-vue'
import '@wangeditor/editor/dist/css/style.css'
import productService from '../services/product'
import dictionaryService from '../services/dictionary'
import { UPLOAD_MAX_SIZE, ALLOWED_IMAGE_TYPES, API_URL } from '../config'

// 路由
const router = useRouter()
const route = useRoute()
const message = useMessage()

// 表单引用
const formRef = ref(null)
const variantFormRef = ref(null)
const uploadRef = ref(null)

// 状态
const loading = ref(false)
const saving = ref(false)
const savingVariant = ref(false)
const showVariantModal = ref(false)
const isEdit = computed(() => !!route.params.id)
const productId = ref(isEdit.value ? parseInt(route.params.id) : null)

// 文件列表
const fileList = ref([])

// 表单数据
const formData = reactive({
  sku: '',
  name: '',
  categoryId: null,
  brandId: null,
  description: '',
  costPrice: 0,
  retailPrice: 0,
  images: [],
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

// wangEditor
const editor = ref(null)
const mode = ref('default') // 或 'simple'

// 工具栏配置
const toolbarConfig = {
  toolbarKeys: [
    'bold', 'italic', 'underline', 'through', 'fontSize', 'color', 'bgColor',
    'bulletedList', 'numberedList', 'insertTable', 'insertImage', 'codeBlock', 'blockquote'
  ]
}

// 编辑器配置
const editorConfig = {
  placeholder: '请输入商品描述...',
  MENU_CONF: {
    uploadImage: {
      server: `${API_URL}/api/upload/image`,
      fieldName: 'file',
      headers: {
        Authorization: `Bearer ${localStorage.getItem('token')}`
      },
      maxFileSize: UPLOAD_MAX_SIZE,
      allowedFileTypes: ALLOWED_IMAGE_TYPES,
      customInsert(res, insertFn) {
        // res 是服务器的响应内容
        insertFn(res.url, res.fileName, res.url)
      }
    }
  }
}

// 创建编辑器
const handleEditorCreated = (createdEditor) => {
  console.log('编辑器创建成功')
  editor.value = createdEditor

  // 如果已经有描述内容，设置到编辑器中
  if (formData.description && formData.description.trim() !== '') {
    console.log('在handleEditorCreated中设置编辑器内容:', formData.description)
    try {
      createdEditor.setHtml(formData.description)
      console.log('编辑器内容设置成功')
    } catch (error) {
      console.error('设置编辑器内容失败:', error)
    }
  } else {
    console.log('没有描述内容可设置到编辑器')
  }
}

// 编辑器内容变化时的回调
const handleEditorChange = (editor) => {
  console.log('编辑器内容变化')
  formData.description = editor.getHtml()
  console.log('更新后的描述内容:', formData.description)
}

// 监听描述内容变化
watch(() => formData.description, (newValue) => {
  console.log('描述内容变化:', newValue)
  if (editor.value && newValue) {
    console.log('通过watch设置编辑器内容')
    editor.value.setHtml(newValue)
  }
})

// 组件卸载时销毁编辑器
onBeforeUnmount(() => {
  const editorInstance = editor.value
  if (editorInstance == null) return
  editorInstance.destroy()
})

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

// 渲染颜色标签
const renderColorLabel = (option) => {
  return h('div', { style: 'display: flex; align-items: center;' }, [
    h('div', {
      style: {
        width: '16px',
        height: '16px',
        borderRadius: '4px',
        backgroundColor: option.color || '#ccc',
        marginRight: '8px'
      }
    }),
    option.label
  ])
}

// 变体表格列
const variantColumns = [
  {
    title: '颜色',
    key: 'color',
    render(row) {
      const color = colorOptions.value.find(c => c.value === row.colorId)
      return h('div', { style: 'display: flex; align-items: center;' }, [
        h('div', {
          style: {
            width: '16px',
            height: '16px',
            borderRadius: '4px',
            backgroundColor: color?.color || '#ccc',
            marginRight: '8px'
          }
        }),
        color?.label || '未知'
      ])
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

// 文件上传相关方法
const beforeUpload = (data) => {
  const { file } = data

  // 检查文件类型
  if (!ALLOWED_IMAGE_TYPES.includes(file.type)) {
    message.error(`不支持的文件类型: ${file.type}，请上传 jpg、png、gif 或 webp 格式的图片`)
    return false
  }

  // 检查文件大小
  if (file.size > UPLOAD_MAX_SIZE) {
    message.error(`文件过大，请上传不超过 ${UPLOAD_MAX_SIZE / 1024 / 1024}MB 的图片`)
    return false
  }

  return true
}

const customUploadRequest = ({ file, onFinish, onError }) => {
  const formData = new FormData()
  formData.append('file', file.file)

  // 创建请求
  const xhr = new XMLHttpRequest()
  xhr.open('POST', `${API_URL}/api/upload/image`)

  // 设置请求头
  const token = localStorage.getItem('token')
  if (token) {
    xhr.setRequestHeader('Authorization', `Bearer ${token}`)
  }

  xhr.onload = () => {
    if (xhr.status === 200) {
      try {
        const response = JSON.parse(xhr.responseText)
        // 将上传成功的图片URL添加到formData.images数组中
        formData.images.push(response.url)
        onFinish()
      } catch (err) {
        onError()
        message.error('解析响应失败')
      }
    } else {
      onError()
      message.error(`上传失败: ${xhr.status}`)
    }
  }

  xhr.onerror = () => {
    onError()
    message.error('网络错误，上传失败')
  }

  xhr.send(formData)
}

const handleRemoveImage = (file) => {
  // 从formData.images数组中移除被删除的图片URL
  const index = formData.images.findIndex(url => url === file.url)
  if (index !== -1) {
    formData.images.splice(index, 1)
  }
  return true
}

// 加载商品数据
const loadProduct = async () => {
  if (!isEdit.value) return

  loading.value = true
  try {
    console.log('正在加载商品数据，商品ID:', productId.value)
    const product = await productService.getProduct(productId.value)
    console.log('从后端获取的商品数据:', product)
    console.log('商品描述内容:', product.Description)

    // 将后端字段名称转换为前端字段名称
    console.log('开始设置表单数据')

    // 打印每个字段的值
    console.log('ID:', product.ID)
    console.log('SKU:', product.SKU)
    console.log('Name:', product.Name)
    console.log('CategoryID:', product.CategoryID)
    console.log('BrandID:', product.BrandID)
    console.log('Description:', product.Description)
    console.log('CostPrice:', product.CostPrice)
    console.log('RetailPrice:', product.RetailPrice)

    // 设置表单数据
    formData.id = product.ID
    formData.sku = product.SKU || ''
    formData.name = product.Name || ''
    formData.categoryId = product.CategoryID || null
    formData.brandId = product.BrandID || null
    formData.costPrice = product.CostPrice || 0
    formData.retailPrice = product.RetailPrice || 0

    // 特意将description放在最后设置，并确保其值不为空
    if (product.Description) {
      console.log('设置描述内容:', product.Description)
      formData.description = product.Description
    } else {
      console.log('商品描述为空')
      formData.description = ''
    }

    console.log('表单数据设置完成')

    // 处理图片
    if (product.Images && Array.isArray(product.Images)) {
      formData.images = product.Images

      // 为上传组件创建文件列表
      fileList.value = product.Images.map((url, index) => ({
        id: `existing-${index}`,
        name: url.split('/').pop() || `image-${index}.jpg`,
        status: 'finished',
        url
      }))
    }

    // 处理变体
    if (product.Variants && Array.isArray(product.Variants)) {
      variants.value = product.Variants.map(v => ({
        colorId: v.ColorID,
        sizeId: v.SizeID,
        seasonId: v.SeasonID,
        fabricId: v.FabricID,
        barcode: v.Barcode,
        costPrice: v.CostPrice,
        retailPrice: v.RetailPrice
      }))
    }

    // 手动更新编辑器内容
    if (editor.value && formData.description) {
      console.log('尝试设置编辑器内容:', formData.description)
      setTimeout(() => {
        editor.value.setHtml(formData.description)
        console.log('编辑器内容已设置')
      }, 100) // 延迟一点时间确保编辑器已完全初始化
    } else {
      console.log('编辑器或描述内容不存在:', {
        editorExists: !!editor.value,
        descriptionExists: !!formData.description,
        description: formData.description
      })
    }

    console.log('转换后的表单数据:', formData)
  } catch (error) {
    console.error('加载商品数据失败:', error)
    message.error('加载商品数据失败: ' + (error.response?.data?.error || '未知错误'))
    router.push('/products')
  } finally {
    loading.value = false
  }
}

const handleSave = () => {
  formRef.value?.validate(async (errors) => {
    if (errors) {
      return
    }

    saving.value = true
    try {
      // 从编辑器获取最新的HTML内容
      if (editor.value) {
        formData.description = editor.value.getHtml()
      }

      // 将字段名称转换为大写，以匹配后端模型
      const productData = {
        SKU: formData.sku,
        Name: formData.name,
        CategoryID: formData.categoryId,
        BrandID: formData.brandId,
        Description: formData.description,
        CostPrice: formData.costPrice,
        RetailPrice: formData.retailPrice,
        Images: formData.images,
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
      if (isEdit.value) {
        productData.ID = productId.value
        await productService.updateProduct(productId.value, productData)
        message.success('商品更新成功')
      } else {
        await productService.createProduct(productData)
        message.success('商品添加成功')
      }

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
  console.log('组件挂载完成')

  // 加载字典数据
  await Promise.all([
    loadDictionaryItems('category', categoryOptions),
    loadDictionaryItems('color', colorOptions),
    loadDictionaryItems('size', sizeOptions),
    loadDictionaryItems('season', seasonOptions),
    loadDictionaryItems('brand', brandOptions),
    loadDictionaryItems('fabric', fabricOptions)
  ])

  console.log('字典数据加载完成')

  // 如果是编辑模式，加载商品数据
  if (isEdit.value) {
    await loadProduct()

    // 添加延迟处理，确保编辑器已初始化并数据已加载
    setTimeout(() => {
      console.log('延迟检查编辑器和数据状态')
      if (editor.value && formData.description) {
        console.log('尝试再次设置编辑器内容:', formData.description)
        editor.value.setHtml(formData.description)
      } else {
        console.log('延迟检查结果: 编辑器或描述内容不存在', {
          editorExists: !!editor.value,
          descriptionExists: !!formData.description
        })
      }
    }, 500)
  }
})
</script>

<style scoped>
.product-form {
  width: 100%;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.header-left {
  display: flex;
  align-items: center;
}

.header-icon {
  margin-right: 12px;
}

.page-title {
  margin: 0;
  font-size: 24px;
  font-weight: 500;
}

.page-subtitle {
  margin: 4px 0 0;
  color: rgba(0, 0, 0, 0.45);
}

.form-card {
  margin-bottom: 24px;
}

.upload-trigger {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
}

.editor-container {
  border: 1px solid #e0e0e0;
  border-radius: 3px;
}

:deep(.n-upload-trigger) {
  width: 100%;
}

:deep(.n-upload-file-list) {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

:deep(.n-upload-file-list__container) {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

:deep(.n-upload-file-list .n-upload-file) {
  width: 104px;
  height: 104px;
}

:deep(.n-upload-trigger) {
  width: 104px;
  height: 104px;
}
</style>
