import api from './api'

/**
 * 商品图片服务
 */
export default {
  /**
   * 获取商品图片列表
   * @param {string} productId - 商品ID或SN
   * @returns {Promise} 图片列表
   */
  async getProductImages(productId) {
    try {
      const response = await api.get(`/api/v1/products/${productId}/images`)
      return response || []
    } catch (error) {
      console.error('获取商品图片失败:', error)
      throw error
    }
  },

  /**
   * 上传单张商品图片
   * @param {string} productId - 商品ID或SN
   * @param {File} file - 图片文件
   * @param {number} sort - 排序顺序
   * @returns {Promise} 上传结果
   */
  async uploadProductImage(productId, file, sort = 0) {
    try {
      const formData = new FormData()
      formData.append('file', file)
      formData.append('sort', sort)

      const response = await api.post(
        `/api/v1/products/${productId}/images`,
        formData,
        {
          headers: {
            'Content-Type': 'multipart/form-data'
          }
        }
      )
      return response
    } catch (error) {
      console.error('上传商品图片失败:', error)
      throw error
    }
  },

  /**
   * 批量上传商品图片
   * @param {string} productId - 商品ID或SN
   * @param {File[]} files - 图片文件数组
   * @returns {Promise} 批量上传结果
   */
  async batchUploadProductImages(productId, files) {
    try {
      const formData = new FormData()
      files.forEach(file => {
        formData.append('files', file)
      })

      const response = await api.post(
        `/api/v1/products/${productId}/images/batch`,
        formData,
        {
          headers: {
            'Content-Type': 'multipart/form-data'
          }
        }
      )
      return response
    } catch (error) {
      console.error('批量上传商品图片失败:', error)
      throw error
    }
  },

  /**
   * 更新图片排序
   * @param {string} productId - 商品ID或SN
   * @param {number} imageId - 图片ID
   * @param {number} sort - 新的排序顺序
   * @returns {Promise} 更新结果
   */
  async updateImageSort(productId, imageId, sort) {
    try {
      const response = await api.put(
        `/api/v1/products/${productId}/images/${imageId}/sort`,
        { sort }
      )
      return response
    } catch (error) {
      console.error('更新图片排序失败:', error)
      throw error
    }
  },

  /**
   * 删除商品图片
   * @param {string} productId - 商品ID或SN
   * @param {number} imageId - 图片ID
   * @returns {Promise} 删除结果
   */
  async deleteProductImage(productId, imageId) {
    try {
      const response = await api.delete(
        `/api/v1/products/${productId}/images/${imageId}`
      )
      return response
    } catch (error) {
      console.error('删除商品图片失败:', error)
      throw error
    }
  },

  /**
   * 生成商品SN
   * 生成16位唯一商品序列号
   * @returns {string} 16位商品SN
   */
  generateProductSN() {
    const timestamp = Date.now().toString(36)
    const random = Math.random().toString(36).substring(2, 8)
    const uuid = Math.random().toString(36).substring(2, 6)
    return (timestamp + random + uuid).substring(0, 16).toUpperCase()
  },

  /**
   * 验证图片文件
   * @param {File} file - 图片文件
   * @returns {Object} 验证结果 { valid: boolean, message: string }
   */
  validateImageFile(file) {
    // 检查文件类型
    const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp']
    if (!allowedTypes.includes(file.type)) {
      return {
        valid: false,
        message: '只支持 JPG、PNG、GIF、WebP 格式的图片'
      }
    }

    // 检查文件大小 (10MB)
    const maxSize = 10 * 1024 * 1024
    if (file.size > maxSize) {
      return {
        valid: false,
        message: '图片大小不能超过 10MB'
      }
    }

    return {
      valid: true,
      message: ''
    }
  },

  /**
   * 批量验证图片文件
   * @param {File[]} files - 图片文件数组
   * @returns {Object} 验证结果 { valid: boolean, message: string, validFiles: File[], invalidFiles: File[] }
   */
  validateImageFiles(files) {
    const validFiles = []
    const invalidFiles = []
    const errors = []

    files.forEach(file => {
      const result = this.validateImageFile(file)
      if (result.valid) {
        validFiles.push(file)
      } else {
        invalidFiles.push(file)
        errors.push(`${file.name}: ${result.message}`)
      }
    })

    return {
      valid: invalidFiles.length === 0,
      message: errors.join('; '),
      validFiles,
      invalidFiles
    }
  },

  /**
   * 获取图片完整URL
   * @param {string} url - 图片相对路径或完整URL
   * @returns {string} 完整的图片URL
   */
  getImageUrl(url) {
    if (!url) return ''
    if (url.startsWith('http')) return url
    return `${window.location.origin}${url}`
  },

  /**
   * 格式化日期
   * @param {string} dateString - 日期字符串
   * @returns {string} 格式化后的日期
   */
  formatDate(dateString) {
    if (!dateString) return '-'
    return new Date(dateString).toLocaleString('zh-CN')
  }
}