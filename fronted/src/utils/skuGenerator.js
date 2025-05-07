/**
 * SKU生成工具
 * 用于根据商品信息自动生成SKU编码
 */

/**
 * 生成商品SKU
 * 格式: 类别代码(2位) + 品牌代码(2位) + 年份(2位) + 序号(4位)
 * 例如: CL-NK-23-0001 表示 服装-Nike-2023年-0001号
 * 
 * @param {Object} options - SKU生成选项
 * @param {Object} options.category - 商品类别对象，包含id和label属性
 * @param {Object} options.brand - 品牌对象，包含id和label属性
 * @param {Number} options.sequence - 序列号，用于确保SKU唯一性
 * @param {Date} options.date - 日期，默认为当前日期
 * @returns {String} 生成的SKU
 */
export function generateSKU(options) {
  const { category, brand, sequence = 1, date = new Date() } = options;
  
  // 获取类别代码 (使用类别名称的前两个字符，如果是中文则取前两个字)
  let categoryCode = '00';
  if (category && category.label) {
    if (/^[\u4e00-\u9fa5]+$/.test(category.label)) {
      // 中文类别名称
      categoryCode = category.label.substring(0, 2);
    } else {
      // 英文类别名称
      categoryCode = category.label.substring(0, 2).toUpperCase();
    }
  }
  
  // 获取品牌代码 (使用品牌名称的前两个字符)
  let brandCode = '00';
  if (brand && brand.label) {
    if (/^[\u4e00-\u9fa5]+$/.test(brand.label)) {
      // 中文品牌名称
      brandCode = brand.label.substring(0, 2);
    } else {
      // 英文品牌名称
      brandCode = brand.label.substring(0, 2).toUpperCase();
    }
  }
  
  // 获取年份后两位
  const year = date.getFullYear().toString().substring(2);
  
  // 序列号，补齐4位
  const sequenceStr = sequence.toString().padStart(4, '0');
  
  // 组合SKU
  return `${categoryCode}-${brandCode}-${year}-${sequenceStr}`;
}

/**
 * 生成商品变体SKU
 * 在基础SKU上添加颜色、尺码等信息
 * 
 * @param {String} baseSKU - 基础SKU
 * @param {Object} options - 变体选项
 * @param {Object} options.color - 颜色对象，包含label属性
 * @param {Object} options.size - 尺码对象，包含label属性
 * @returns {String} 生成的变体SKU
 */
export function generateVariantSKU(baseSKU, options) {
  const { color, size } = options;
  
  let variantCode = '';
  
  // 添加颜色代码
  if (color && color.label) {
    if (/^[\u4e00-\u9fa5]+$/.test(color.label)) {
      // 中文颜色名称
      variantCode += color.label.substring(0, 1);
    } else {
      // 英文颜色名称
      variantCode += color.label.substring(0, 1).toUpperCase();
    }
  }
  
  // 添加尺码代码
  if (size && size.label) {
    variantCode += size.label;
  }
  
  // 如果没有变体信息，直接返回基础SKU
  if (!variantCode) {
    return baseSKU;
  }
  
  return `${baseSKU}-${variantCode}`;
}

/**
 * 解析SKU
 * 将SKU解析为各个组成部分
 * 
 * @param {String} sku - 要解析的SKU
 * @returns {Object} 解析结果
 */
export function parseSKU(sku) {
  // 基础SKU格式: 类别代码(2位) + 品牌代码(2位) + 年份(2位) + 序号(4位)
  // 例如: CL-NK-23-0001
  const parts = sku.split('-');
  
  if (parts.length < 4) {
    return {
      valid: false,
      message: 'SKU格式不正确'
    };
  }
  
  const categoryCode = parts[0];
  const brandCode = parts[1];
  const year = parts[2];
  const sequence = parts[3];
  
  // 变体信息
  let variantInfo = null;
  if (parts.length > 4) {
    variantInfo = parts[4];
  }
  
  return {
    valid: true,
    categoryCode,
    brandCode,
    year,
    sequence,
    variantInfo,
    isVariant: !!variantInfo
  };
}

/**
 * 验证SKU是否有效
 * 
 * @param {String} sku - 要验证的SKU
 * @returns {Boolean} 是否有效
 */
export function isValidSKU(sku) {
  if (!sku) return false;
  
  // 基本格式验证
  const basicPattern = /^[A-Z0-9\u4e00-\u9fa5]{2}-[A-Z0-9\u4e00-\u9fa5]{2}-\d{2}-\d{4}(-[A-Z0-9\u4e00-\u9fa5]+)?$/;
  return basicPattern.test(sku);
}
