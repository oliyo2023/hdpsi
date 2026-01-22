import axios from 'axios'
import { API_URL } from '../config'

const API_BASE = `${API_URL}api/v1/sales`

class SalesOrderService {
  // 获取销售订单列表
  async getSalesOrders(params = {}) {
    try {
      const response = await axios.get(API_BASE, { params })
      return response.data
    } catch (error) {
      console.error('获取销售订单列表失败:', error)
      throw error
    }
  }

  // 获取销售订单详情
  async getSalesOrder(id) {
    try {
      const response = await axios.get(`${API_BASE}/${id}`)
      return response.data
    } catch (error) {
      console.error('获取销售订单详情失败:', error)
      throw error
    }
  }

  // 创建销售订单
  async createSalesOrder(data) {
    try {
      const response = await axios.post(API_BASE, data)
      return response.data
    } catch (error) {
      console.error('创建销售订单失败:', error)
      throw error
    }
  }

  // 更新销售订单
  async updateSalesOrder(id, data) {
    try {
      const response = await axios.put(`${API_BASE}/${id}`, data)
      return response.data
    } catch (error) {
      console.error('更新销售订单失败:', error)
      throw error
    }
  }

  // 更新销售订单状态
  async updateSalesOrderStatus(id, status, note = '') {
    try {
      const response = await axios.put(`${API_BASE}/${id}/status`, {
        status,
        note
      })
      return response.data
    } catch (error) {
      console.error('更新销售订单状态失败:', error)
      throw error
    }
  }

  // 删除销售订单
  async deleteSalesOrder(id) {
    try {
      const response = await axios.delete(`${API_BASE}/${id}`)
      return response.data
    } catch (error) {
      console.error('删除销售订单失败:', error)
      throw error
    }
  }

  // 添加支付记录
  async addPayment(id, paymentData) {
    try {
      const response = await axios.post(`${API_BASE}/${id}/payments`, paymentData)
      return response.data
    } catch (error) {
      console.error('添加支付记录失败:', error)
      throw error
    }
  }

  // 获取销售统计
  async getSalesStatistics() {
    try {
      const response = await axios.get(`${API_BASE}/statistics`)
      return response.data
    } catch (error) {
      console.error('获取销售统计失败:', error)
      throw error
    }
  }

  // 获取订单状态选项
  getStatusOptions() {
    return [
      { label: '草稿', value: 'draft', type: 'default' },
      { label: '待确认', value: 'pending', type: 'info' },
      { label: '已确认', value: 'confirmed', type: 'warning' },
      { label: '已付款', value: 'paid', type: 'success' },
      { label: '已发货', value: 'shipped', type: 'processing' },
      { label: '已送达', value: 'delivered', type: 'success' },
      { label: '已完成', value: 'completed', type: 'success' },
      { label: '已取消', value: 'cancelled', type: 'error' },
      { label: '已退货', value: 'returned', type: 'error' }
    ]
  }

  // 获取订单类型选项
  getOrderTypeOptions() {
    return [
      { label: '线上订单', value: 'online' },
      { label: '线下订单', value: 'offline' },
      { label: '移动端订单', value: 'mobile' }
    ]
  }

  // 获取支付方式选项
  getPaymentMethodOptions() {
    return [
      { label: '现金', value: 'cash' },
      { label: '银行卡', value: 'card' },
      { label: '微信支付', value: 'wechat' },
      { label: '支付宝', value: 'alipay' },
      { label: '积分抵扣', value: 'points' },
      { label: '混合支付', value: 'mixed' }
    ]
  }

  // 获取支付状态选项
  getPaymentStatusOptions() {
    return [
      { label: '未付款', value: 'unpaid', type: 'error' },
      { label: '部分付款', value: 'partial', type: 'warning' },
      { label: '已付款', value: 'paid', type: 'success' },
      { label: '已退款', value: 'refunded', type: 'default' }
    ]
  }

  // 格式化订单状态
  formatStatus(status) {
    const statusMap = {
      'draft': '草稿',
      'pending': '待确认',
      'confirmed': '已确认',
      'paid': '已付款',
      'shipped': '已发货',
      'delivered': '已送达',
      'completed': '已完成',
      'cancelled': '已取消',
      'returned': '已退货'
    }
    return statusMap[status] || status
  }

  // 格式化订单类型
  formatOrderType(type) {
    const typeMap = {
      'online': '线上订单',
      'offline': '线下订单',
      'mobile': '移动端订单'
    }
    return typeMap[type] || type
  }

  // 格式化支付方式
  formatPaymentMethod(method) {
    const methodMap = {
      'cash': '现金',
      'card': '银行卡',
      'wechat': '微信支付',
      'alipay': '支付宝',
      'points': '积分抵扣',
      'mixed': '混合支付'
    }
    return methodMap[method] || method
  }

  // 格式化支付状态
  formatPaymentStatus(status) {
    const statusMap = {
      'unpaid': '未付款',
      'partial': '部分付款',
      'paid': '已付款',
      'refunded': '已退款'
    }
    return statusMap[status] || status
  }

  // 计算订单统计信息
  calculateOrderStats(order) {
    const stats = {
      itemCount: order.items?.length || 0,
      totalQuantity: 0,
      averagePrice: 0,
      discountRate: 0
    }

    if (order.items && order.items.length > 0) {
      stats.totalQuantity = order.items.reduce((sum, item) => sum + item.quantity, 0)
      stats.averagePrice = order.subtotalAmount / stats.totalQuantity
      
      if (order.subtotalAmount > 0) {
        stats.discountRate = (order.discountAmount / order.subtotalAmount * 100).toFixed(2)
      }
    }

    return stats
  }

  // 验证订单数据
  validateOrderData(orderData) {
    const errors = []

    if (!orderData.customer_name?.trim()) {
      errors.push('客户姓名不能为空')
    }

    if (!orderData.store_id) {
      errors.push('请选择销售店铺')
    }

    if (!orderData.order_type) {
      errors.push('请选择订单类型')
    }

    if (!orderData.items || orderData.items.length === 0) {
      errors.push('订单明细不能为空')
    } else {
      orderData.items.forEach((item, index) => {
        if (!item.product_id) {
          errors.push(`第${index + 1}行：请选择商品`)
        }
        if (!item.quantity || item.quantity <= 0) {
          errors.push(`第${index + 1}行：数量必须大于0`)
        }
        if (!item.unit_price || item.unit_price < 0) {
          errors.push(`第${index + 1}行：单价不能为负数`)
        }
      })
    }

    return errors
  }

  // 生成订单摘要
  generateOrderSummary(order) {
    const stats = this.calculateOrderStats(order)
    return {
      orderNumber: order.orderNumber || order.order_number,
      customerName: order.customerName || order.customer_name,
      status: this.formatStatus(order.status),
      orderType: this.formatOrderType(order.orderType || order.order_type),
      totalAmount: order.totalAmount || order.total_amount,
      paidAmount: order.paidAmount || order.paid_amount,
      paymentStatus: this.formatPaymentStatus(order.paymentStatus || order.payment_status),
      itemCount: stats.itemCount,
      totalQuantity: stats.totalQuantity,
      orderDate: order.orderDate || order.order_date,
      storeName: order.store?.name || order.storeName,
      salespersonName: order.salesperson?.name || order.salespersonName
    }
  }
}

export default new SalesOrderService()
