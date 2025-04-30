/**
 * 将后端返回的字段名（首字母大写的驼峰命名法）转换为前端使用的字段名（全小写的驼峰命名法）
 * @param {Object} obj - 需要转换的对象
 * @returns {Object} - 转换后的对象
 */
export function convertBackendFields(obj) {
  if (!obj || typeof obj !== 'object') return obj;

  // 处理数组
  if (Array.isArray(obj)) {
    return obj.map(item => convertBackendFields(item));
  }

  const result = {};

  // 打印原始对象的字段名称
  console.log('字段转换器收到的原始字段:', Object.keys(obj));

  // 处理对象
  Object.keys(obj).forEach(key => {
    // 首字母转小写
    const newKey = key.charAt(0).toLowerCase() + key.slice(1);

    // 特殊处理常见字段
    if (key === 'ID') {
      result['id'] = obj[key];
    }
    else if (key === 'SKU') {
      result['sku'] = obj[key];
    }
    else if (key === 'Name') {
      result['name'] = obj[key];
    }
    else if (key === 'CategoryID') {
      // 确保 categoryId 是数字类型
      result['categoryId'] = obj[key] ? (typeof obj[key] === 'string' ? parseInt(obj[key]) : obj[key]) : null;
      console.log('转换后的categoryId:', result['categoryId'], typeof result['categoryId']);
    }
    else if (key === 'BrandID') {
      // 确保 brandId 是数字类型
      result['brandId'] = obj[key] ? (typeof obj[key] === 'string' ? parseInt(obj[key]) : obj[key]) : null;
      console.log('转换后的brandId:', result['brandId'], typeof result['brandId']);
    }
    else if (key === 'CostPrice') {
      result['costPrice'] = obj[key];
    }
    else if (key === 'RetailPrice') {
      result['retailPrice'] = obj[key];
    }
    else if (key === 'Description') {
      result['description'] = obj[key];
    }
    else if (key === 'Status') {
      result['status'] = obj[key];
    }
    // 处理小写开头的字段（可能已经转换过）
    else if (key === 'id') {
      result['id'] = obj[key];
    }
    else if (key === 'sku') {
      result['sku'] = obj[key];
    }
    else if (key === 'name') {
      result['name'] = obj[key];
    }
    else if (key === 'categoryId') {
      result['categoryId'] = obj[key];
    }
    else if (key === 'brandId') {
      result['brandId'] = obj[key];
    }
    else if (key === 'costPrice') {
      result['costPrice'] = obj[key];
    }
    else if (key === 'retailPrice') {
      result['retailPrice'] = obj[key];
    }
    else if (key === 'description') {
      result['description'] = obj[key];
    }
    else if (key === 'status') {
      result['status'] = obj[key];
    }
    // 递归处理嵌套对象
    else if (obj[key] && typeof obj[key] === 'object') {
      result[newKey] = convertBackendFields(obj[key]);
    } else {
      result[newKey] = obj[key];
    }
  });

  // 添加调试日志
  if (!Array.isArray(obj) && Object.keys(obj).length > 0) {
    console.log('字段转换 (后端 -> 前端):', obj, ' => ', result);
  }

  return result;
}

/**
 * 将前端使用的字段名（全小写的驼峰命名法）转换为后端需要的字段名（首字母大写的驼峰命名法）
 * @param {Object} obj - 需要转换的对象
 * @returns {Object} - 转换后的对象
 */
export function convertFrontendFields(obj) {
  if (!obj || typeof obj !== 'object') return obj;

  // 处理数组
  if (Array.isArray(obj)) {
    return obj.map(item => convertFrontendFields(item));
  }

  const result = {};

  // 处理对象
  Object.keys(obj).forEach(key => {
    // 特殊处理常见字段
    if (key === 'id') {
      result['ID'] = obj[key];
    }
    else if (key === 'sku') {
      result['SKU'] = obj[key];
    }
    else if (key === 'name') {
      result['Name'] = obj[key];
    }
    else if (key === 'categoryId') {
      // 确保 CategoryID 是数字类型
      result['CategoryID'] = obj[key] ? (typeof obj[key] === 'string' ? parseInt(obj[key]) : obj[key]) : null;
      console.log('转换后的CategoryID:', result['CategoryID'], typeof result['CategoryID']);
    }
    else if (key === 'brandId') {
      // 确保 BrandID 是数字类型
      result['BrandID'] = obj[key] ? (typeof obj[key] === 'string' ? parseInt(obj[key]) : obj[key]) : null;
      console.log('转换后的BrandID:', result['BrandID'], typeof result['BrandID']);
    }
    else if (key === 'costPrice') {
      result['CostPrice'] = obj[key];
    }
    else if (key === 'retailPrice') {
      result['RetailPrice'] = obj[key];
    }
    else if (key === 'description') {
      result['Description'] = obj[key];
    }
    else if (key === 'status') {
      result['Status'] = obj[key];
    }
    // 其他字段首字母转大写
    else {
      const newKey = key.charAt(0).toUpperCase() + key.slice(1);

      // 递归处理嵌套对象
      if (obj[key] && typeof obj[key] === 'object') {
        result[newKey] = convertFrontendFields(obj[key]);
      } else {
        result[newKey] = obj[key];
      }
    }
  });

  // 添加调试日志
  if (!Array.isArray(obj) && Object.keys(obj).length > 0) {
    console.log('字段转换 (前端 -> 后端):', obj, ' => ', result);
  }

  return result;
}
