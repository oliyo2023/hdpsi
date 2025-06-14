/**
 * 商品SN生成器
 * 生成16位唯一商品序列号，用于商品标识
 */

/**
 * 生成16位商品SN
 * 格式：时间戳(8位) + 随机字符(4位) + 序列号(4位)
 * @returns {string} 16位大写字母数字组合的SN
 */
export function generateProductSN() {
  // 获取当前时间戳的36进制表示
  const timestamp = Date.now().toString(36).toUpperCase()
  
  // 生成随机字符串
  const randomStr = Math.random().toString(36).substring(2, 8).toUpperCase()
  
  // 生成额外的随机字符
  const extraRandom = Math.random().toString(36).substring(2, 6).toUpperCase()
  
  // 组合并截取前16位
  let sn = (timestamp + randomStr + extraRandom).substring(0, 16)
  
  // 如果长度不足16位，用随机字符补齐
  while (sn.length < 16) {
    sn += Math.random().toString(36).substring(2, 3).toUpperCase()
  }
  
  return sn.substring(0, 16)
}

/**
 * 生成带前缀的商品SN
 * @param {string} prefix - 前缀（如：PRD、SKU等）
 * @param {number} length - 总长度（默认16位）
 * @returns {string} 带前缀的SN
 */
export function generateProductSNWithPrefix(prefix = 'PRD', length = 16) {
  const prefixLength = prefix.length
  const remainingLength = length - prefixLength
  
  if (remainingLength <= 0) {
    throw new Error('前缀长度不能大于等于总长度')
  }
  
  // 生成剩余长度的随机字符
  let randomPart = ''
  while (randomPart.length < remainingLength) {
    randomPart += Math.random().toString(36).substring(2).toUpperCase()
  }
  
  return prefix.toUpperCase() + randomPart.substring(0, remainingLength)
}

/**
 * 验证SN格式
 * @param {string} sn - 要验证的SN
 * @returns {Object} 验证结果 { valid: boolean, message: string }
 */
export function validateProductSN(sn) {
  if (!sn) {
    return {
      valid: false,
      message: 'SN不能为空'
    }
  }
  
  if (typeof sn !== 'string') {
    return {
      valid: false,
      message: 'SN必须是字符串类型'
    }
  }
  
  if (sn.length !== 16) {
    return {
      valid: false,
      message: 'SN长度必须为16位'
    }
  }
  
  // 检查是否只包含字母和数字
  const alphanumericRegex = /^[A-Z0-9]+$/
  if (!alphanumericRegex.test(sn)) {
    return {
      valid: false,
      message: 'SN只能包含大写字母和数字'
    }
  }
  
  return {
    valid: true,
    message: 'SN格式正确'
  }
}

/**
 * 批量生成商品SN
 * @param {number} count - 生成数量
 * @param {string} prefix - 可选前缀
 * @returns {string[]} SN数组
 */
export function batchGenerateProductSN(count = 1, prefix = '') {
  const sns = []
  const generated = new Set() // 用于避免重复
  
  while (sns.length < count) {
    let sn
    if (prefix) {
      sn = generateProductSNWithPrefix(prefix)
    } else {
      sn = generateProductSN()
    }
    
    // 确保不重复
    if (!generated.has(sn)) {
      generated.add(sn)
      sns.push(sn)
    }
  }
  
  return sns
}

/**
 * 从SN中提取时间信息（如果SN包含时间戳）
 * @param {string} sn - 商品SN
 * @returns {Object} 时间信息 { timestamp: number, date: Date, readable: string }
 */
export function extractTimeFromSN(sn) {
  try {
    // 假设前8位包含时间戳信息
    const timeStr = sn.substring(0, 8)
    const timestamp = parseInt(timeStr, 36)
    
    if (isNaN(timestamp) || timestamp <= 0) {
      return {
        timestamp: null,
        date: null,
        readable: '无法解析时间信息'
      }
    }
    
    const date = new Date(timestamp)
    
    return {
      timestamp,
      date,
      readable: date.toLocaleString('zh-CN')
    }
  } catch (error) {
    return {
      timestamp: null,
      date: null,
      readable: '时间解析失败'
    }
  }
}

/**
 * 格式化SN显示
 * @param {string} sn - 商品SN
 * @param {string} separator - 分隔符（默认为'-'）
 * @param {number} groupSize - 分组大小（默认为4）
 * @returns {string} 格式化后的SN
 */
export function formatSNDisplay(sn, separator = '-', groupSize = 4) {
  if (!sn) return ''
  
  const groups = []
  for (let i = 0; i < sn.length; i += groupSize) {
    groups.push(sn.substring(i, i + groupSize))
  }
  
  return groups.join(separator)
}

export default {
  generateProductSN,
  generateProductSNWithPrefix,
  validateProductSN,
  batchGenerateProductSN,
  extractTimeFromSN,
  formatSNDisplay
}