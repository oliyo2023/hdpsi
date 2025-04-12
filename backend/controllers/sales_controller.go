package controllers

import (
	"fmt"
	"hd_psi/backend/models"
	"hd_psi/backend/utils"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type SalesController struct {
	db *gorm.DB
}

func NewSalesController(db *gorm.DB) *SalesController {
	return &SalesController{db: db}
}

// GetRecentSales 获取最近的销售订单
func (sc *SalesController) GetRecentSales(c *gin.Context) {
	// 获取查询参数
	limit := 10 // 默认返回10条记录
	if limitParam := c.Query("limit"); limitParam != "" {
		if parsedLimit, err := fmt.Sscanf(limitParam, "%d", &limit); err != nil || parsedLimit < 1 {
			limit = 10
		}
	}

	// 查询最近的销售订单
	var orders []models.SalesOrder
	if err := sc.db.Order("created_at DESC").Limit(limit).Find(&orders).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取最近销售订单失败"})
		return
	}

	// 获取订单详情
	type OrderWithDetails struct {
		ID            uint      `json:"id"`
		OrderNumber   string    `json:"order_number"`
		StoreID       uint      `json:"store_id"`
		StoreName     string    `json:"store_name"`
		MemberID      *uint     `json:"member_id"`
		MemberName    string    `json:"member_name"`
		TotalAmount   float64   `json:"total_amount"`
		ActualAmount  float64   `json:"actual_amount"`
		Status        string    `json:"status"`
		PaymentMethod string    `json:"payment_method"`
		CreatedAt     time.Time `json:"created_at"`
	}

	var result []OrderWithDetails

	for _, order := range orders {
		// 获取店铺名称
		var store models.Store
		var storeName string
		if err := sc.db.Select("name").First(&store, order.StoreID).Error; err == nil {
			storeName = store.Name
		}

		// 获取会员名称
		var memberName string
		if order.MemberID != nil {
			var member models.Member
			if err := sc.db.Select("name").First(&member, *order.MemberID).Error; err == nil {
				memberName = member.Name
			}
		}

		// 构建结果
		orderWithDetails := OrderWithDetails{
			ID:            order.ID,
			OrderNumber:   order.OrderNumber,
			StoreID:       order.StoreID,
			StoreName:     storeName,
			MemberID:      order.MemberID,
			MemberName:    memberName,
			TotalAmount:   order.TotalAmount,
			ActualAmount:  order.ActualAmount,
			Status:        string(order.Status),
			PaymentMethod: string(order.PaymentMethod),
			CreatedAt:     order.CreatedAt,
		}

		result = append(result, orderWithDetails)
	}

	c.JSON(http.StatusOK, gin.H{
		"items": result,
		"total": len(result),
	})
}

// ListOrders 获取销售订单列表
func (sc *SalesController) ListOrders(c *gin.Context) {
	var orders []models.SalesOrder

	// 获取查询参数
	storeID := c.Query("store_id")
	memberID := c.Query("member_id")
	status := c.Query("status")
	startDate := c.Query("start_date")
	endDate := c.Query("end_date")

	// 构建查询
	query := sc.db.Model(&models.SalesOrder{})

	if storeID != "" {
		query = query.Where("store_id = ?", storeID)
	}

	if memberID != "" {
		query = query.Where("member_id = ?", memberID)
	}

	if status != "" {
		query = query.Where("status = ?", status)
	}

	if startDate != "" && endDate != "" {
		query = query.Where("created_at BETWEEN ? AND ?", startDate, endDate)
	} else if startDate != "" {
		query = query.Where("created_at >= ?", startDate)
	} else if endDate != "" {
		query = query.Where("created_at <= ?", endDate)
	}

	// 执行查询
	if err := query.Order("created_at DESC").Find(&orders).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, orders)
}

// GetOrder 获取销售订单详情
func (sc *SalesController) GetOrder(c *gin.Context) {
	id := c.Param("id")
	var order models.SalesOrder
	if err := sc.db.First(&order, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Order not found"})
		return
	}

	// 获取订单明细
	var items []models.SalesOrderItem
	if err := sc.db.Where("order_id = ?", order.ID).Find(&items).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// 获取议价记录
	var negotiations []models.NegotiationRecord
	if err := sc.db.Where("order_id = ?", order.ID).Find(&negotiations).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"order":        order,
		"items":        items,
		"negotiations": negotiations,
	})
}

// CreateOrder 创建销售订单
func (sc *SalesController) CreateOrder(c *gin.Context) {
	var input struct {
		StoreID       uint   `json:"store_id" binding:"required"`
		MemberID      *uint  `json:"member_id"`
		Source        string `json:"source" binding:"required"`
		SalesPersonID uint   `json:"sales_person_id" binding:"required"`
		FittingRoomID *uint  `json:"fitting_room_id"`
		PaymentMethod string `json:"payment_method"`
		PointsUsed    int    `json:"points_used"`
		Note          string `json:"note"`
		Items         []struct {
			ProductID        uint    `json:"product_id" binding:"required"`
			Quantity         int     `json:"quantity" binding:"required"`
			RetailPrice      float64 `json:"retail_price" binding:"required"`
			ActualPrice      float64 `json:"actual_price" binding:"required"`
			QRCodeData       string  `json:"qr_code_data"`
			InitialPrice     float64 `json:"initial_price"`
			NegotiationCount int     `json:"negotiation_count"`
			NegotiationNote  string  `json:"negotiation_note"`
		} `json:"items" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 开始事务
	tx := sc.db.Begin()

	// 生成订单编号 (格式: SO + 年月日 + 4位序号)
	now := time.Now()
	var count int64
	tx.Model(&models.SalesOrder{}).Where("DATE(created_at) = DATE(?)", now).Count(&count)
	orderNumber := fmt.Sprintf("SO%s%04d", now.Format("20060102"), count+1)

	// 计算订单金额
	var totalAmount, discountAmount, actualAmount float64
	for _, item := range input.Items {
		totalAmount += float64(item.Quantity) * item.RetailPrice
		discountAmount += float64(item.Quantity) * (item.RetailPrice - item.ActualPrice)
		actualAmount += float64(item.Quantity) * item.ActualPrice
	}

	// 处理积分抵扣
	if input.PointsUsed > 0 {
		// 假设500积分抵现10元
		pointsDiscount := float64(input.PointsUsed) / 500.0 * 10.0
		if pointsDiscount > actualAmount {
			pointsDiscount = actualAmount
		}
		discountAmount += pointsDiscount
		actualAmount -= pointsDiscount
	}

	// 计算获得的积分 (假设1元=1积分)
	pointsEarned := int(actualAmount)

	// 创建订单
	order := models.SalesOrder{
		OrderNumber:    orderNumber,
		StoreID:        input.StoreID,
		MemberID:       input.MemberID,
		Source:         models.OrderSource(input.Source),
		Status:         models.Created,
		TotalAmount:    totalAmount,
		DiscountAmount: discountAmount,
		ActualAmount:   actualAmount,
		PaymentMethod:  models.PaymentMethod(input.PaymentMethod),
		PointsUsed:     input.PointsUsed,
		PointsEarned:   pointsEarned,
		SalesPersonID:  input.SalesPersonID,
		FittingRoomID:  input.FittingRoomID,
		Note:           input.Note,
	}

	if err := tx.Create(&order).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create order: " + err.Error()})
		return
	}

	// 创建订单明细和议价记录
	var orderItems []models.SalesOrderItem
	var negotiations []models.NegotiationRecord

	for _, item := range input.Items {
		// 验证QR码数据
		if item.QRCodeData != "" {
			// 假设有一个密钥用于验证QR码
			secretKey := "your-secret-key" // 实际应用中应从配置中获取
			qrData, valid, err := utils.VerifyQRCode(item.QRCodeData, secretKey)
			if err != nil || !valid {
				tx.Rollback()
				c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid QR code data"})
				return
			}

			// 验证商品SKU是否匹配
			var product models.Product
			if err := tx.First(&product, item.ProductID).Error; err != nil {
				tx.Rollback()
				c.JSON(http.StatusNotFound, gin.H{"error": "Product not found"})
				return
			}

			if product.SKU != qrData.SKU {
				tx.Rollback()
				c.JSON(http.StatusBadRequest, gin.H{"error": "QR code does not match product"})
				return
			}
		}

		// 创建订单明细
		orderItem := models.SalesOrderItem{
			OrderID:          order.ID,
			ProductID:        item.ProductID,
			ProductVariantID: item.ProductID, // 暂时使用ProductID替代
			Quantity:         item.Quantity,
			RetailPrice:      item.RetailPrice,
			ActualPrice:      item.ActualPrice,
			DiscountAmount:   item.RetailPrice - item.ActualPrice,
			QRCodeData:       item.QRCodeData,
		}

		if err := tx.Create(&orderItem).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create order item: " + err.Error()})
			return
		}

		orderItems = append(orderItems, orderItem)

		// 如果有议价，创建议价记录
		if item.NegotiationCount > 0 {
			negotiation := models.NegotiationRecord{
				OrderID:          order.ID,
				OrderItemID:      orderItem.ID,
				InitialPrice:     item.InitialPrice,
				FinalPrice:       item.ActualPrice,
				NegotiationCount: item.NegotiationCount,
				SalesPersonID:    input.SalesPersonID,
				Note:             item.NegotiationNote,
			}

			if err := tx.Create(&negotiation).Error; err != nil {
				tx.Rollback()
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create negotiation record: " + err.Error()})
				return
			}

			negotiations = append(negotiations, negotiation)
		}

		// 更新库存
		var inventory models.Inventory
		result := tx.Where("store_id = ? AND product_variant_id = ?", input.StoreID, item.ProductID).First(&inventory)

		if result.Error != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get inventory: " + result.Error.Error()})
			return
		}

		// 检查库存是否足够
		if inventory.Quantity < item.Quantity {
			tx.Rollback()
			c.JSON(http.StatusBadRequest, gin.H{"error": "Insufficient inventory for product ID " + fmt.Sprint(item.ProductID)})
			return
		}

		// 减少库存
		inventory.Quantity -= item.Quantity
		if err := tx.Save(&inventory).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update inventory: " + err.Error()})
			return
		}

		// 创建库存交易记录
		transaction := models.InventoryTransaction{
			TransactionType:  models.SaleOut,
			ProductVariantID: item.ProductID, // 暂时使用ProductID替代
			StoreID:          input.StoreID,
			Quantity:         -item.Quantity, // 负数表示出库
			ReferenceID:      &order.ID,
			ReferenceType:    "sales_order",
			OperatorID:       input.SalesPersonID,
		}

		if err := tx.Create(&transaction).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create inventory transaction: " + err.Error()})
			return
		}
	}

	// 如果有会员，更新会员积分
	if input.MemberID != nil && *input.MemberID > 0 {
		var member models.Member
		if err := tx.First(&member, *input.MemberID).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusNotFound, gin.H{"error": "Member not found"})
			return
		}

		// 这里假设Member模型有Points字段，如果没有需要先添加
		// 扣除使用的积分，增加获得的积分
		// member.Points = member.Points - input.PointsUsed + pointsEarned
		// if err := tx.Save(&member).Error; err != nil {
		//     tx.Rollback()
		//     c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update member points: " + err.Error()})
		//     return
		// }
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to commit transaction: " + err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"order":        order,
		"items":        orderItems,
		"negotiations": negotiations,
	})
}

// UpdateOrderStatus 更新订单状态
func (sc *SalesController) UpdateOrderStatus(c *gin.Context) {
	id := c.Param("id")
	var order models.SalesOrder
	if err := sc.db.First(&order, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Order not found"})
		return
	}

	var input struct {
		Status string `json:"status" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 更新状态
	order.Status = models.OrderStatus(input.Status)

	if err := sc.db.Save(&order).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, order)
}

// CreateReturnOrder 创建退换货单
func (sc *SalesController) CreateReturnOrder(c *gin.Context) {
	var input struct {
		OrderID      uint   `json:"order_id" binding:"required"`
		StoreID      uint   `json:"store_id" binding:"required"`
		MemberID     *uint  `json:"member_id"`
		ReturnType   string `json:"return_type" binding:"required"`
		ReturnReason string `json:"return_reason" binding:"required"`
		ProcessorID  uint   `json:"processor_id" binding:"required"`
		Note         string `json:"note"`
		Items        []struct {
			OrderItemID       uint    `json:"order_item_id" binding:"required"`
			ProductID         uint    `json:"product_id" binding:"required"`
			Quantity          int     `json:"quantity" binding:"required"`
			ReturnPrice       float64 `json:"return_price" binding:"required"`
			QRCodeData        string  `json:"qr_code_data"`
			ExchangeProductID *uint   `json:"exchange_product_id"`
			ExchangeQuantity  *int    `json:"exchange_quantity"`
		} `json:"items" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 验证原订单是否存在
	var originalOrder models.SalesOrder
	if err := sc.db.First(&originalOrder, input.OrderID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Original order not found"})
		return
	}

	// 开始事务
	tx := sc.db.Begin()

	// 生成退货单号 (格式: RT + 年月日 + 4位序号)
	now := time.Now()
	var count int64
	tx.Model(&models.ReturnOrder{}).Where("DATE(created_at) = DATE(?)", now).Count(&count)
	returnNumber := fmt.Sprintf("RT%s%04d", now.Format("20060102"), count+1)

	// 计算退款总金额
	var returnAmount float64
	for _, item := range input.Items {
		returnAmount += float64(item.Quantity) * item.ReturnPrice
	}

	// 创建退货单
	returnOrder := models.ReturnOrder{
		OrderID:      input.OrderID,
		ReturnNumber: returnNumber,
		StoreID:      input.StoreID,
		MemberID:     input.MemberID,
		ReturnType:   input.ReturnType,
		ReturnReason: input.ReturnReason,
		ReturnAmount: returnAmount,
		Status:       "pending",
		ProcessorID:  input.ProcessorID,
		Note:         input.Note,
	}

	if err := tx.Create(&returnOrder).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create return order: " + err.Error()})
		return
	}

	// 创建退货明细
	var returnItems []models.ReturnOrderItem

	for _, item := range input.Items {
		// 验证原订单明细是否存在
		var originalItem models.SalesOrderItem
		if err := tx.First(&originalItem, item.OrderItemID).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusNotFound, gin.H{"error": "Original order item not found"})
			return
		}

		// 验证退货数量不超过原订单数量
		if item.Quantity > originalItem.Quantity {
			tx.Rollback()
			c.JSON(http.StatusBadRequest, gin.H{"error": "Return quantity exceeds original quantity"})
			return
		}

		// 创建退货明细
		returnItem := models.ReturnOrderItem{
			ReturnOrderID:     returnOrder.ID,
			OrderItemID:       item.OrderItemID,
			ProductID:         item.ProductID,
			ProductVariantID:  item.ProductID, // 暂时使用ProductID替代
			Quantity:          item.Quantity,
			ReturnPrice:       item.ReturnPrice,
			QRCodeData:        item.QRCodeData,
			ExchangeProductID: item.ExchangeProductID,
			ExchangeQuantity:  item.ExchangeQuantity,
		}

		if err := tx.Create(&returnItem).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create return item: " + err.Error()})
			return
		}

		returnItems = append(returnItems, returnItem)

		// 更新库存（退货入库）
		var inventory models.Inventory
		result := tx.Where("store_id = ? AND product_variant_id = ?", input.StoreID, item.ProductID).First(&inventory)

		if result.Error != nil {
			if result.Error == gorm.ErrRecordNotFound {
				// 如果库存记录不存在，创建新记录
				inventory = models.Inventory{
					StoreID:          input.StoreID,
					ProductVariantID: item.ProductID, // 暂时使用ProductID替代
					Quantity:         item.Quantity,
				}
				if err := tx.Create(&inventory).Error; err != nil {
					tx.Rollback()
					c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create inventory: " + err.Error()})
					return
				}
			} else {
				tx.Rollback()
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get inventory: " + result.Error.Error()})
				return
			}
		} else {
			// 增加库存
			inventory.Quantity += item.Quantity
			if err := tx.Save(&inventory).Error; err != nil {
				tx.Rollback()
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update inventory: " + err.Error()})
				return
			}
		}

		// 创建库存交易记录（退货入库）
		transaction := models.InventoryTransaction{
			TransactionType:  models.ReturnIn,
			ProductVariantID: item.ProductID, // 暂时使用ProductID替代
			StoreID:          input.StoreID,
			Quantity:         item.Quantity, // 正数表示入库
			ReferenceID:      &returnOrder.ID,
			ReferenceType:    "return_order",
			OperatorID:       input.ProcessorID,
		}

		if err := tx.Create(&transaction).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create inventory transaction: " + err.Error()})
			return
		}

		// 如果是换货，处理换货商品出库
		if input.ReturnType == "exchange" && item.ExchangeProductID != nil && item.ExchangeQuantity != nil {
			// 验证换货商品库存是否足够
			var exchangeInventory models.Inventory
			result := tx.Where("store_id = ? AND product_variant_id = ?", input.StoreID, *item.ExchangeProductID).First(&exchangeInventory)

			if result.Error != nil {
				tx.Rollback()
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get exchange product inventory: " + result.Error.Error()})
				return
			}

			if exchangeInventory.Quantity < *item.ExchangeQuantity {
				tx.Rollback()
				c.JSON(http.StatusBadRequest, gin.H{"error": "Insufficient inventory for exchange product"})
				return
			}

			// 减少换货商品库存
			exchangeInventory.Quantity -= *item.ExchangeQuantity
			if err := tx.Save(&exchangeInventory).Error; err != nil {
				tx.Rollback()
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update exchange product inventory: " + err.Error()})
				return
			}

			// 创建库存交易记录（换货出库）
			exchangeTransaction := models.InventoryTransaction{
				TransactionType:  models.ExchangeOut,
				ProductVariantID: *item.ExchangeProductID, // 暂时使用ExchangeProductID替代
				StoreID:          input.StoreID,
				Quantity:         -*item.ExchangeQuantity, // 负数表示出库
				ReferenceID:      &returnOrder.ID,
				ReferenceType:    "exchange_order",
				OperatorID:       input.ProcessorID,
			}

			if err := tx.Create(&exchangeTransaction).Error; err != nil {
				tx.Rollback()
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create exchange inventory transaction: " + err.Error()})
				return
			}
		}
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to commit transaction: " + err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"return_order": returnOrder,
		"items":        returnItems,
	})
}

// UpdateReturnOrderStatus 更新退货单状态
func (sc *SalesController) UpdateReturnOrderStatus(c *gin.Context) {
	id := c.Param("id")
	var returnOrder models.ReturnOrder
	if err := sc.db.First(&returnOrder, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Return order not found"})
		return
	}

	var input struct {
		Status string `json:"status" binding:"required"`
		Note   string `json:"note"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 更新状态
	returnOrder.Status = input.Status
	if input.Note != "" {
		returnOrder.Note = input.Note
	}

	if err := sc.db.Save(&returnOrder).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, returnOrder)
}
