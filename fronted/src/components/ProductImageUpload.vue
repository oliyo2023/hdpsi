<template>
  <div class="product-image-upload">
    <!-- 图片上传区域 -->
    <div class="upload-section">
      <n-space vertical>
        <div class="upload-header">
          <n-text strong>商品图片</n-text>
          <n-button
            type="primary"
            size="small"
            @click="showImageManager = true"
            :disabled="!productSN"
          >
            <template #icon>
              <n-icon><ImageOutline /></n-icon>
            </template>
            管理图片
          </n-button>
        </div>
        
        <n-upload
          ref="uploadRef"
          :action="uploadUrl"
          :headers="uploadHeaders"
          :data="uploadData"
          :file-list="fileList"
          list-type="image-card"
          :max="10"
          multiple
          accept="image/*"
          @before-upload="beforeUpload"
          @finish="handleUploadFinish"
          @error="handleUploadError"
          @remove="handleRemove"
          @preview="handlePreview"
        >
          <n-upload-dragger>
            <div style="margin-bottom: 12px">
              <n-icon size="48" :depth="3">
                <CloudUploadOutline />
              </n-icon>
            </div>
            <n-text style="font-size: 16px">
              点击或者拖动文件到该区域来上传
            </n-text>
            <n-p depth="3" style="margin: 8px 0 0 0">
              支持 JPG、PNG、GIF、WebP 格式，单个文件不超过 10MB
            </n-p>
          </n-upload-dragger>
        </n-upload>
        
        <n-alert v-if="!productSN" type="warning" title="提示">
          请先保存商品基本信息后再上传图片
        </n-alert>
      </n-space>
    </div>

    <!-- 图片管理弹窗 -->
    <n-modal
      v-model:show="showImageManager"
      preset="card"
      title="图片管理"
      size="huge"
      :bordered="false"
      :segmented="true"
      style="width: 90%; max-width: 1200px;"
    >
      <div class="image-manager">
        <div class="manager-header">
          <n-space justify="space-between">
            <n-text>共 {{ images.length }} 张图片</n-text>
            <n-space>
              <n-button
                type="primary"
                @click="triggerUpload"
                :loading="uploading"
              >
                <template #icon>
                  <n-icon><AddOutline /></n-icon>
                </template>
                添加图片
              </n-button>
              <n-button @click="refreshImages">
                <template #icon>
                  <n-icon><RefreshOutline /></n-icon>
                </template>
                刷新
              </n-button>
            </n-space>
          </n-space>
        </div>

        <div class="image-grid" v-if="images.length > 0">
          <div
            v-for="(image, index) in images"
            :key="image.ID"
            class="image-item"
            :class="{ 'dragging': dragIndex === index }"
            draggable="true"
            @dragstart="handleDragStart(index)"
            @dragover.prevent
            @drop="handleDrop(index)"
          >
            <div class="image-wrapper">
              <img
                :src="getImageUrl(image.URL)"
                :alt="`商品图片 ${index + 1}`"
                @click="previewImage(image)"
              />
              <div class="image-overlay">
                <n-space>
                  <n-button
                    size="small"
                    type="primary"
                    @click="previewImage(image)"
                  >
                    <template #icon>
                      <n-icon><EyeOutline /></n-icon>
                    </template>
                  </n-button>
                  <n-button
                    size="small"
                    type="error"
                    @click="deleteImage(image)"
                  >
                    <template #icon>
                      <n-icon><TrashOutline /></n-icon>
                    </template>
                  </n-button>
                </n-space>
              </div>
            </div>
            <div class="image-info">
              <n-text depth="3" style="font-size: 12px;">
                排序: {{ image.Sort }}
              </n-text>
              <n-input-number
                v-model:value="image.Sort"
                size="small"
                :min="0"
                :max="999"
                @blur="updateImageSort(image)"
                style="width: 80px;"
              />
            </div>
          </div>
        </div>

        <n-empty
          v-else
          description="暂无图片"
          style="margin: 40px 0;"
        >
          <template #extra>
            <n-button type="primary" @click="triggerUpload">
              上传第一张图片
            </n-button>
          </template>
        </n-empty>
      </div>

      <!-- 隐藏的文件上传输入 -->
      <input
        ref="hiddenUploadRef"
        type="file"
        multiple
        accept="image/*"
        style="display: none;"
        @change="handleFileSelect"
      />
    </n-modal>

    <!-- 图片预览弹窗 -->
    <n-modal
      v-model:show="showPreview"
      preset="card"
      title="图片预览"
      size="huge"
      :bordered="false"
    >
      <div class="image-preview" v-if="previewImageData">
        <img
          :src="getImageUrl(previewImageData.URL)"
          :alt="`商品图片预览`"
          style="max-width: 100%; max-height: 70vh; object-fit: contain;"
        />
        <div class="preview-info">
          <n-descriptions :column="2" bordered>
            <n-descriptions-item label="图片ID">
              {{ previewImageData.ID }}
            </n-descriptions-item>
            <n-descriptions-item label="排序">
              {{ previewImageData.Sort }}
            </n-descriptions-item>
            <n-descriptions-item label="上传时间">
              {{ formatDate(previewImageData.CreatedAt) }}
            </n-descriptions-item>
            <n-descriptions-item label="更新时间">
              {{ formatDate(previewImageData.UpdatedAt) }}
            </n-descriptions-item>
          </n-descriptions>
        </div>
      </div>
    </n-modal>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { useMessage } from 'naive-ui'
import {
  CloudUploadOutline,
  ImageOutline,
  AddOutline,
  RefreshOutline,
  EyeOutline,
  TrashOutline
} from '@vicons/ionicons5'
import api from '../services/api'

const props = defineProps({
  productSN: {
    type: String,
    default: ''
  },
  modelValue: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['update:modelValue', 'upload-success'])

const message = useMessage()

// 响应式数据
const uploadRef = ref(null)
const hiddenUploadRef = ref(null)
const fileList = ref([])
const images = ref([])
const showImageManager = ref(false)
const showPreview = ref(false)
const previewImageData = ref(null)
const uploading = ref(false)
const dragIndex = ref(-1)

// 计算属性
const uploadUrl = computed(() => {
  return props.productSN ? `/api/v1/products/${props.productSN}/images/batch` : ''
})

const uploadHeaders = computed(() => {
  const token = localStorage.getItem('token')
  return {
    'Authorization': `Bearer ${token}`
  }
})

const uploadData = computed(() => {
  return {
    product_id: props.productSN
  }
})

// 监听器
watch(() => props.productSN, (newSN) => {
  if (newSN) {
    loadImages()
  }
})

watch(() => props.modelValue, (newValue) => {
  images.value = newValue || []
}, { immediate: true })

// 方法
const generateProductSN = () => {
  // 生成16位商品SN
  const timestamp = Date.now().toString(36)
  const random = Math.random().toString(36).substring(2, 8)
  return (timestamp + random).substring(0, 16).toUpperCase()
}

const beforeUpload = (data) => {
  const { file } = data
  
  // 检查文件类型
  const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp']
  if (!allowedTypes.includes(file.type)) {
    message.error('只支持 JPG、PNG、GIF、WebP 格式的图片')
    return false
  }
  
  // 检查文件大小 (10MB)
  if (file.size > 10 * 1024 * 1024) {
    message.error('图片大小不能超过 10MB')
    return false
  }
  
  if (!props.productSN) {
    message.error('请先保存商品信息获取商品编号')
    return false
  }
  
  return true
}

const handleUploadFinish = ({ file, event }) => {
  try {
    const response = JSON.parse(event.target.response)
    if (response.uploaded_images) {
      message.success(`成功上传 ${response.success_count} 张图片`)
      loadImages()
      emit('upload-success', response.uploaded_images)
    }
  } catch (error) {
    console.error('上传响应解析失败:', error)
    message.error('上传失败')
  }
}

const handleUploadError = ({ file, event }) => {
  console.error('上传失败:', event)
  message.error('图片上传失败')
}

const handleRemove = ({ file }) => {
  // 这里可以添加删除逻辑
  return true
}

const handlePreview = ({ file }) => {
  // 预览逻辑
}

const loadImages = async () => {
  if (!props.productSN) return
  
  try {
    const response = await api.get(`/api/v1/products/${props.productSN}/images`)
    images.value = response || []
    emit('update:modelValue', images.value)
  } catch (error) {
    console.error('加载图片失败:', error)
    message.error('加载图片失败')
  }
}

const refreshImages = () => {
  loadImages()
}

const triggerUpload = () => {
  hiddenUploadRef.value?.click()
}

const handleFileSelect = async (event) => {
  const files = Array.from(event.target.files)
  if (files.length === 0) return
  
  uploading.value = true
  
  try {
    const formData = new FormData()
    files.forEach(file => {
      formData.append('files', file)
    })
    
    const response = await api.post(
      `/api/v1/products/${props.productSN}/images/batch`,
      formData,
      {
        headers: {
          'Content-Type': 'multipart/form-data',
          ...uploadHeaders.value
        }
      }
    )
    
    if (response.uploaded_images) {
      message.success(`成功上传 ${response.success_count} 张图片`)
      loadImages()
      emit('upload-success', response.uploaded_images)
    }
  } catch (error) {
    console.error('批量上传失败:', error)
    message.error('批量上传失败')
  } finally {
    uploading.value = false
    // 清空文件选择
    event.target.value = ''
  }
}

const previewImage = (image) => {
  previewImageData.value = image
  showPreview.value = true
}

const deleteImage = async (image) => {
  try {
    await api.delete(`/api/v1/products/${props.productSN}/images/${image.ID}`)
    message.success('删除成功')
    loadImages()
  } catch (error) {
    console.error('删除图片失败:', error)
    message.error('删除图片失败')
  }
}

const updateImageSort = async (image) => {
  try {
    await api.put(
      `/api/v1/products/${props.productSN}/images/${image.ID}/sort`,
      { sort: image.Sort }
    )
    message.success('排序更新成功')
    loadImages()
  } catch (error) {
    console.error('更新排序失败:', error)
    message.error('更新排序失败')
  }
}

const handleDragStart = (index) => {
  dragIndex.value = index
}

const handleDrop = async (targetIndex) => {
  if (dragIndex.value === -1 || dragIndex.value === targetIndex) {
    dragIndex.value = -1
    return
  }
  
  // 交换排序
  const dragImage = images.value[dragIndex.value]
  const targetImage = images.value[targetIndex]
  
  const tempSort = dragImage.Sort
  dragImage.Sort = targetImage.Sort
  targetImage.Sort = tempSort
  
  try {
    await Promise.all([
      updateImageSort(dragImage),
      updateImageSort(targetImage)
    ])
    message.success('排序更新成功')
  } catch (error) {
    console.error('拖拽排序失败:', error)
    message.error('拖拽排序失败')
  }
  
  dragIndex.value = -1
}

const getImageUrl = (url) => {
  if (!url) return ''
  if (url.startsWith('http')) return url
  return `${window.location.origin}${url}`
}

const formatDate = (dateString) => {
  if (!dateString) return '-'
  return new Date(dateString).toLocaleString('zh-CN')
}

// 暴露方法给父组件
defineExpose({
  generateProductSN,
  loadImages,
  refreshImages
})

// 组件挂载时加载图片
onMounted(() => {
  if (props.productSN) {
    loadImages()
  }
})
</script>

<style scoped>
.product-image-upload {
  width: 100%;
}

.upload-section {
  margin-bottom: 16px;
}

.upload-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.image-manager {
  padding: 16px 0;
}

.manager-header {
  margin-bottom: 24px;
  padding-bottom: 16px;
  border-bottom: 1px solid var(--n-border-color);
}

.image-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 16px;
  margin-top: 16px;
}

.image-item {
  border: 1px solid var(--n-border-color);
  border-radius: 8px;
  overflow: hidden;
  transition: all 0.3s ease;
  cursor: move;
}

.image-item:hover {
  border-color: var(--n-color-primary);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.image-item.dragging {
  opacity: 0.5;
  transform: scale(0.95);
}

.image-wrapper {
  position: relative;
  aspect-ratio: 1;
  overflow: hidden;
}

.image-wrapper img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  cursor: pointer;
  transition: transform 0.3s ease;
}

.image-wrapper:hover img {
  transform: scale(1.05);
}

.image-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.3s ease;
}

.image-wrapper:hover .image-overlay {
  opacity: 1;
}

.image-info {
  padding: 12px;
  background: var(--n-color-base);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.image-preview {
  text-align: center;
}

.preview-info {
  margin-top: 24px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .image-grid {
    grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
    gap: 12px;
  }
  
  .image-info {
    padding: 8px;
    flex-direction: column;
    gap: 8px;
  }
}
</style>