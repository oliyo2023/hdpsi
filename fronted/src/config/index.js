// API 基础 URL
export const API_URL = import.meta.env.VITE_API_URL || 'https://8.140.206.248/hdpsi/'

// 其他全局配置
export const APP_NAME = '服装进销存系统 (HD-PSI)'
export const APP_VERSION = '1.0.0'

// 分页默认配置
export const DEFAULT_PAGE_SIZE = 10
export const PAGE_SIZE_OPTIONS = [10, 20, 50, 100]

// 上传文件配置
export const UPLOAD_MAX_SIZE = 5 * 1024 * 1024 // 5MB
export const ALLOWED_IMAGE_TYPES = ['image/jpeg', 'image/png', 'image/gif', 'image/webp']

// 主题配置
export const THEME_LIGHT = 'light'
export const THEME_DARK = 'dark'
