package controllers

import (
	"net/http"
	"strconv"

	"hd_psi/backend/middleware"
	"hd_psi/backend/models"
	"hd_psi/backend/services"
	"hd_psi/backend/utils"

	"github.com/kataras/iris/v12"
)

// ReturnController handles API requests for return orders
type ReturnController struct {
	ReturnService *services.ReturnService
}

// NewReturnController creates a new ReturnController
func NewReturnController(returnService *services.ReturnService) *ReturnController {
	return &ReturnController{ReturnService: returnService}
}

// CreateReturnOrder godoc
// @Summary Create a new return or exchange order
// @Description Creates a new return (RETURN) or exchange (EXCHANGE) order with items.
// @Tags Returns
// @Accept json
// @Produce json
// @Param order body services.CreateReturnOrderInput true "Return Order Creation Payload"
// @Success 201 {object} models.ReturnOrder
// @Failure 400 {object} models.ErrorResponse "Invalid input"
// @Failure 500 {object} models.ErrorResponse "Internal server error"
// @Router /returns [post]
// @Security ApiKeyAuth
func (rc *ReturnController) CreateReturnOrder(c iris.Context) {
	var input services.CreateReturnOrderInput
	if err := c.ReadJSON(&input); err != nil {
		c.StatusCode(http.StatusBadRequest)
		c.JSON(iris.Map{
			"error": "请求参数无效: " + err.Error(),
		})
		return
	}

	userID, userName, err := middleware.GetUserFromContext(c)
	if err != nil {
		c.StatusCode(http.StatusUnauthorized)
		c.JSON(iris.Map{
			"error": "无法获取用户信息",
		})
		return
	}
	input.UserID = userID
	input.UserName = userName

	// Basic validation based on type
	if input.Type == models.ReturnTypeReturn && len(input.ReturnOrderItems) == 0 {
		c.StatusCode(http.StatusBadRequest)
		c.JSON(iris.Map{
			"error": "退货申请必须包含退货商品信息",
		})
		return
	}
	if input.Type == models.ReturnTypeExchange && len(input.ExchangeOrderItems) == 0 {
		c.StatusCode(http.StatusBadRequest)
		c.JSON(iris.Map{
			"error": "换货申请必须包含换货商品信息",
		})
		return
	}
	if input.Type == models.ReturnTypeExchange && len(input.ReturnOrderItems) == 0 {
		c.StatusCode(http.StatusBadRequest)
		c.JSON(iris.Map{
			"error": "换货申请必须包含原始退回的商品信息",
		})
		return
	}

	returnOrder, err := rc.ReturnService.CreateReturnOrder(input)
	if err != nil {
		switch e := err.(type) {
		case *utils.ValidationError:
			c.StatusCode(http.StatusBadRequest)
			c.JSON(iris.Map{
				"error": e.Error(),
			})
		default:
			c.StatusCode(http.StatusInternalServerError)
			c.JSON(iris.Map{
				"error": "创建退换货订单失败: " + err.Error(),
			})
		}
		return
	}

	c.StatusCode(http.StatusCreated)
	c.JSON(returnOrder)
}

// GetReturnOrderList godoc
// @Summary Get a list of return orders
// @Description Retrieves a paginated list of return/exchange orders based on filter criteria.
// @Tags Returns
// @Accept json
// @Produce json
// @Param page query int false "Page number" default(1)
// @Param pageSize query int false "Number of items per page" default(10)
// @Param returnNo query string false "Filter by return number"
// @Param orderNo query string false "Filter by original order number"
// @Param type query string false "Filter by type (RETURN or EXCHANGE)" Enums(RETURN, EXCHANGE)
// @Param status query string false "Filter by status (e.g., PENDING_APPROVAL, APPROVED)"
// @Param customerName query string false "Filter by customer name"
// @Param customerPhone query string false "Filter by customer phone"
// @Param startDate query string false "Filter by apply date (YYYY-MM-DD) - start range"
// @Param endDate query string false "Filter by apply date (YYYY-MM-DD) - end range"
// @Success 200 {object} services.GetReturnOrderListResponse
// @Failure 500 {object} models.ErrorResponse "Internal server error"
// @Router /returns [get]
// @Security ApiKeyAuth
func (rc *ReturnController) GetReturnOrderList(c iris.Context) {
	var input services.GetReturnOrderListInput

	// Get query parameters manually since iris doesn't have ShouldBindQuery
	pageStr := c.URLParam("page")
	if pageStr == "" {
		pageStr = "1"
	}
	pageSizeStr := c.URLParam("pageSize")
	if pageSizeStr == "" {
		pageSizeStr = "10"
	}

	page, err := strconv.Atoi(pageStr)
	if err != nil {
		page = 1
	}
	pageSize, err := strconv.Atoi(pageSizeStr)
	if err != nil {
		pageSize = 10
	}

	// Set default values
	if page < 1 {
		page = 1
	}
	if pageSize < 1 {
		pageSize = 10
	}
	if pageSize > 100 {
		pageSize = 100
	}

	// Get other query parameters
	input.Page = page
	input.PageSize = pageSize
	input.ReturnNo = c.URLParam("returnNo")
	input.OrderNo = c.URLParam("orderNo")
	input.Type = c.URLParam("type")
	input.Status = c.URLParam("status")
	input.CustomerName = c.URLParam("customerName")
	input.CustomerPhone = c.URLParam("customerPhone")
	input.StartDate = c.URLParam("startDate")
	input.EndDate = c.URLParam("endDate")

	response, err := rc.ReturnService.GetReturnOrderList(input)
	if err != nil {
		c.StatusCode(http.StatusInternalServerError)
		c.JSON(iris.Map{
			"error": "获取退换货列表失败: " + err.Error(),
		})
		return
	}

	c.StatusCode(http.StatusOK)
	c.JSON(response)
}

// GetReturnOrderByID godoc
// @Summary Get a single return order by ID
// @Description Retrieves details of a specific return/exchange order by its ID.
// @Tags Returns
// @Accept json
// @Produce json
// @Param id path int true "Return Order ID"
// @Success 200 {object} models.ReturnOrder
// @Failure 400 {object} models.ErrorResponse "Invalid ID format"
// @Failure 404 {object} models.ErrorResponse "Return order not found"
// @Failure 500 {object} models.ErrorResponse "Internal server error"
// @Router /returns/{id} [get]
// @Security ApiKeyAuth
func (rc *ReturnController) GetReturnOrderByID(c iris.Context) {
	idStr := c.Params().Get("id")
	id, err := strconv.ParseUint(idStr, 10, 32)
	if err != nil {
		c.StatusCode(http.StatusBadRequest)
		c.JSON(iris.Map{
			"error": "无效的退换货单ID格式",
		})
		return
	}

	returnOrder, err := rc.ReturnService.GetReturnOrderByID(uint(id))
	if err != nil {
		switch e := err.(type) {
		case *utils.NotFoundError:
			c.StatusCode(http.StatusNotFound)
			c.JSON(iris.Map{
				"error": e.Error(),
			})
		default:
			c.StatusCode(http.StatusInternalServerError)
			c.JSON(iris.Map{
				"error": "获取退换货详情失败: " + err.Error(),
			})
		}
		return
	}

	c.StatusCode(http.StatusOK)
	c.JSON(returnOrder)
}

// UpdateReturnOrderStatus godoc
// @Summary Update the status of a return order
// @Description Updates the status of a specific return/exchange order (e.g., approve, reject, process, complete).
// @Tags Returns
// @Accept json
// @Produce json
// @Param id path int true "Return Order ID"
// @Param statusUpdate body services.UpdateReturnOrderStatusInput true "Status Update Payload"
// @Success 200 {object} models.ReturnOrder
// @Failure 400 {object} models.ErrorResponse "Invalid input or ID format"
// @Failure 404 {object} models.ErrorResponse "Return order not found"
// @Failure 500 {object} models.ErrorResponse "Internal server error or invalid status transition"
// @Router /returns/{id}/status [put]
// @Security ApiKeyAuth
func (rc *ReturnController) UpdateReturnOrderStatus(c iris.Context) {
	idStr := c.Params().Get("id")
	id, err := strconv.ParseUint(idStr, 10, 32)
	if err != nil {
		c.StatusCode(http.StatusBadRequest)
		c.JSON(iris.Map{
			"error": "无效的退换货单ID格式",
		})
		return
	}

	var input services.UpdateReturnOrderStatusInput
	if err := c.ReadJSON(&input); err != nil {
		c.StatusCode(http.StatusBadRequest)
		c.JSON(iris.Map{
			"error": "请求参数无效: " + err.Error(),
		})
		return
	}

	userID, userName, err := middleware.GetUserFromContext(c)
	if err != nil {
		c.StatusCode(http.StatusUnauthorized)
		c.JSON(iris.Map{
			"error": "无法获取用户信息",
		})
		return
	}
	input.UserID = userID
	input.UserName = userName

	updatedOrder, err := rc.ReturnService.UpdateReturnOrderStatus(uint(id), input)
	if err != nil {
		switch e := err.(type) {
		case *utils.NotFoundError:
			c.StatusCode(http.StatusNotFound)
			c.JSON(iris.Map{
				"error": e.Error(),
			})
		case *utils.ValidationError:
			c.StatusCode(http.StatusBadRequest)
			c.JSON(iris.Map{
				"error": e.Error(),
			})
		default:
			c.StatusCode(http.StatusInternalServerError)
			c.JSON(iris.Map{
				"error": "更新退换货状态失败: " + err.Error(),
			})
		}
		return
	}

	c.StatusCode(http.StatusOK)
	c.JSON(updatedOrder)
}

// ApproveReturnOrder godoc
// @Summary Approve a return order
// @Description Sets the status of a return order to 'APPROVED'.
// @Tags Returns
// @Accept json
// @Produce json
// @Param id path int true "Return Order ID"
// @Success 200 {object} models.ReturnOrder
// @Failure 400 {object} models.ErrorResponse "Invalid ID format"
// @Failure 404 {object} models.ErrorResponse "Return order not found"
// @Failure 500 {object} models.ErrorResponse "Internal server error or invalid status transition"
// @Router /returns/{id}/approve [post]
// @Security ApiKeyAuth
func (rc *ReturnController) ApproveReturnOrder(c iris.Context) {
	idStr := c.Params().Get("id")
	id, err := strconv.ParseUint(idStr, 10, 32)
	if err != nil {
		c.StatusCode(http.StatusBadRequest)
		c.JSON(iris.Map{
			"error": "无效的退换货单ID格式",
		})
		return
	}

	userID, userName, err := middleware.GetUserFromContext(c)
	if err != nil {
		c.StatusCode(http.StatusUnauthorized)
		c.JSON(iris.Map{
			"error": "无法获取用户信息",
		})
		return
	}

	updatedOrder, err := rc.ReturnService.ApproveReturnOrder(uint(id), userID, userName)
	if err != nil {
		switch e := err.(type) {
		case *utils.NotFoundError:
			c.StatusCode(http.StatusNotFound)
			c.JSON(iris.Map{
				"error": e.Error(),
			})
		case *utils.ValidationError:
			c.StatusCode(http.StatusBadRequest)
			c.JSON(iris.Map{
				"error": e.Error(),
			})
		default:
			c.StatusCode(http.StatusInternalServerError)
			c.JSON(iris.Map{
				"error": "审批退换货订单失败: " + err.Error(),
			})
		}
		return
	}
	c.StatusCode(http.StatusOK)
	c.JSON(updatedOrder)
}

// RejectReturnOrder godoc
// @Summary Reject a return order
// @Description Sets the status of a return order to 'REJECTED' with a reason.
// @Tags Returns
// @Accept json
// @Produce json
// @Param id path int true "Return Order ID"
// @Param payload body controllers.RejectPayload true "Rejection Payload"
// @Success 200 {object} models.ReturnOrder
// @Failure 400 {object} models.ErrorResponse "Invalid input or ID format"
// @Failure 404 {object} models.ErrorResponse "Return order not found"
// @Failure 500 {object} models.ErrorResponse "Internal server error or invalid status transition"
// @Router /returns/{id}/reject [post]
// @Security ApiKeyAuth

// RejectPayload defines a structure for rejection reason
type RejectPayload struct {
	Reason string `json:"reason" binding:"required"`
}

func (rc *ReturnController) RejectReturnOrder(c iris.Context) {
	idStr := c.Params().Get("id")
	id, err := strconv.ParseUint(idStr, 10, 32)
	if err != nil {
		c.StatusCode(http.StatusBadRequest)
		c.JSON(iris.Map{
			"error": "无效的退换货单ID格式",
		})
		return
	}

	var payload RejectPayload
	if err := c.ReadJSON(&payload); err != nil {
		c.StatusCode(http.StatusBadRequest)
		c.JSON(iris.Map{
			"error": "请求参数无效，必须提供拒绝原因: " + err.Error(),
		})
		return
	}

	userID, userName, err := middleware.GetUserFromContext(c)
	if err != nil {
		c.StatusCode(http.StatusUnauthorized)
		c.JSON(iris.Map{
			"error": "无法获取用户信息",
		})
		return
	}

	updatedOrder, err := rc.ReturnService.RejectReturnOrder(uint(id), payload.Reason, userID, userName)
	if err != nil {
		switch e := err.(type) {
		case *utils.NotFoundError:
			c.StatusCode(http.StatusNotFound)
			c.JSON(iris.Map{
				"error": e.Error(),
			})
		case *utils.ValidationError:
			c.StatusCode(http.StatusBadRequest)
			c.JSON(iris.Map{
				"error": e.Error(),
			})
		default:
			c.StatusCode(http.StatusInternalServerError)
			c.JSON(iris.Map{
				"error": "拒绝退换货订单失败: " + err.Error(),
			})
		}
		return
	}
	c.StatusCode(http.StatusOK)
	c.JSON(updatedOrder)
}

// DeleteReturnOrder godoc
// @Summary Delete a return order (soft delete)
// @Description Soft deletes a return/exchange order by its ID.
// @Tags Returns
// @Accept json
// @Produce json
// @Param id path int true "Return Order ID"
// @Success 204 "Successfully deleted"
// @Failure 400 {object} models.ErrorResponse "Invalid ID format"
// @Failure 404 {object} models.ErrorResponse "Return order not found"
// @Failure 500 {object} models.ErrorResponse "Internal server error"
// @Router /returns/{id} [delete]
// @Security ApiKeyAuth
func (rc *ReturnController) DeleteReturnOrder(c iris.Context) {
	idStr := c.Params().Get("id")
	id, err := strconv.ParseUint(idStr, 10, 32)
	if err != nil {
		c.StatusCode(http.StatusBadRequest)
		c.JSON(iris.Map{
			"error": "无效的退换货单ID格式",
		})
		return
	}

	userID, userName, err := middleware.GetUserFromContext(c)
	if err != nil {
		c.StatusCode(http.StatusUnauthorized)
		c.JSON(iris.Map{
			"error": "无法获取用户信息",
		})
		return
	}

	err = rc.ReturnService.DeleteReturnOrder(uint(id), userID, userName)
	if err != nil {
		switch e := err.(type) {
		case *utils.NotFoundError:
			c.StatusCode(http.StatusNotFound)
			c.JSON(iris.Map{
				"error": e.Error(),
			})
		default:
			c.StatusCode(http.StatusInternalServerError)
			c.JSON(iris.Map{
				"error": "删除退换货订单失败: " + err.Error(),
			})
		}
		return
	}

	c.StatusCode(http.StatusNoContent)
}

// MarkGoodsReceived godoc
// @Summary Mark return order as goods received
// @Description Sets the status of a return order to 'GOODS_RECEIVED'.
// @Tags Returns
// @Accept json
// @Produce json
// @Param id path int true "Return Order ID"
// @Success 200 {object} models.ReturnOrder
// @Failure 400 {object} models.ErrorResponse "Invalid ID format"
// @Failure 404 {object} models.ErrorResponse "Return order not found"
// @Failure 500 {object} models.ErrorResponse "Internal server error or invalid status transition"
// @Router /returns/{id}/goods-received [post]
// @Security ApiKeyAuth
func (rc *ReturnController) MarkGoodsReceived(c iris.Context) {
	idStr := c.Params().Get("id")
	id, err := strconv.ParseUint(idStr, 10, 32)
	if err != nil {
		c.StatusCode(http.StatusBadRequest)
		c.JSON(iris.Map{
			"error": "无效的退换货单ID格式",
		})
		return
	}

	userID, userName, err := middleware.GetUserFromContext(c)
	if err != nil {
		c.StatusCode(http.StatusUnauthorized)
		c.JSON(iris.Map{
			"error": "无法获取用户信息",
		})
		return
	}

	updatedOrder, err := rc.ReturnService.MarkGoodsReceived(uint(id), userID, userName)
	if err != nil {
		switch e := err.(type) {
		case *utils.NotFoundError:
			c.StatusCode(http.StatusNotFound)
			c.JSON(iris.Map{
				"error": e.Error(),
			})
		case *utils.ValidationError:
			c.StatusCode(http.StatusBadRequest)
			c.JSON(iris.Map{
				"error": e.Error(),
			})
		default:
			c.StatusCode(http.StatusInternalServerError)
			c.JSON(iris.Map{
				"error": "标记已收货失败: " + err.Error(),
			})
		}
		return
	}
	c.StatusCode(http.StatusOK)
	c.JSON(updatedOrder)
}

// MarkExchangeShipped godoc
// @Summary Mark exchange order as shipped
// @Description Sets the status of an exchange order to 'EXCHANGE_SHIPPED'. Requires shipping details.
// @Tags Returns
// @Accept json
// @Produce json
// @Param id path int true "Return Order ID"
// @Param payload body services.MarkExchangeShippedInput true "Shipping Details"
// @Success 200 {object} models.ReturnOrder
// @Failure 400 {object} models.ErrorResponse "Invalid input or ID format"
// @Failure 404 {object} models.ErrorResponse "Return order not found"
// @Failure 500 {object} models.ErrorResponse "Internal server error or invalid status transition"
// @Router /returns/{id}/exchange-shipped [post]
// @Security ApiKeyAuth
func (rc *ReturnController) MarkExchangeShipped(c iris.Context) {
	idStr := c.Params().Get("id")
	id, err := strconv.ParseUint(idStr, 10, 32)
	if err != nil {
		c.StatusCode(http.StatusBadRequest)
		c.JSON(iris.Map{
			"error": "无效的退换货单ID格式",
		})
		return
	}

	var input services.MarkExchangeShippedInput
	if err := c.ReadJSON(&input); err != nil {
		c.StatusCode(http.StatusBadRequest)
		c.JSON(iris.Map{
			"error": "请求参数无效: " + err.Error(),
		})
		return
	}

	userID, userName, err := middleware.GetUserFromContext(c)
	if err != nil {
		c.StatusCode(http.StatusUnauthorized)
		c.JSON(iris.Map{
			"error": "无法获取用户信息",
		})
		return
	}
	input.UserID = userID
	input.UserName = userName

	updatedOrder, err := rc.ReturnService.MarkExchangeShipped(uint(id), input)
	if err != nil {
		switch e := err.(type) {
		case *utils.NotFoundError:
			c.StatusCode(http.StatusNotFound)
			c.JSON(iris.Map{
				"error": e.Error(),
			})
		case *utils.ValidationError:
			c.StatusCode(http.StatusBadRequest)
			c.JSON(iris.Map{
				"error": e.Error(),
			})
		default:
			c.StatusCode(http.StatusInternalServerError)
			c.JSON(iris.Map{
				"error": "标记换货已发货失败: " + err.Error(),
			})
		}
		return
	}
	c.StatusCode(http.StatusOK)
	c.JSON(updatedOrder)
}

// ProcessRefund godoc
// @Summary Process refund for a return order
// @Description Sets the status of a return order to 'REFUND_PROCESSED'. Requires refund details.
// @Tags Returns
// @Accept json
// @Produce json
// @Param id path int true "Return Order ID"
// @Param payload body services.ProcessRefundInput true "Refund Details"
// @Success 200 {object} models.ReturnOrder
// @Failure 400 {object} models.ErrorResponse "Invalid input or ID format"
// @Failure 404 {object} models.ErrorResponse "Return order not found"
// @Failure 500 {object} models.ErrorResponse "Internal server error or invalid status transition"
// @Router /returns/{id}/process-refund [post]
// @Security ApiKeyAuth
func (rc *ReturnController) ProcessRefund(c iris.Context) {
	idStr := c.Params().Get("id")
	id, err := strconv.ParseUint(idStr, 10, 32)
	if err != nil {
		c.StatusCode(http.StatusBadRequest)
		c.JSON(iris.Map{
			"error": "无效的退换货单ID格式",
		})
		return
	}

	var input services.ProcessRefundInput
	if err := c.ReadJSON(&input); err != nil {
		c.StatusCode(http.StatusBadRequest)
		c.JSON(iris.Map{
			"error": "请求参数无效: " + err.Error(),
		})
		return
	}

	userID, userName, err := middleware.GetUserFromContext(c)
	if err != nil {
		c.StatusCode(http.StatusUnauthorized)
		c.JSON(iris.Map{
			"error": "无法获取用户信息",
		})
		return
	}
	input.UserID = userID
	input.UserName = userName

	updatedOrder, err := rc.ReturnService.ProcessRefund(uint(id), input)
	if err != nil {
		switch e := err.(type) {
		case *utils.NotFoundError:
			c.StatusCode(http.StatusNotFound)
			c.JSON(iris.Map{
				"error": e.Error(),
			})
		case *utils.ValidationError:
			c.StatusCode(http.StatusBadRequest)
			c.JSON(iris.Map{
				"error": e.Error(),
			})
		default:
			c.StatusCode(http.StatusInternalServerError)
			c.JSON(iris.Map{
				"error": "处理退款失败: " + err.Error(),
			})
		}
		return
	}
	c.StatusCode(http.StatusOK)
	c.JSON(updatedOrder)
}

// CompleteReturnOrder godoc
// @Summary Complete a return/exchange order
// @Description Sets the status of a return/exchange order to 'COMPLETED'.
// @Tags Returns
// @Accept json
// @Produce json
// @Param id path int true "Return Order ID"
// @Success 200 {object} models.ReturnOrder
// @Failure 400 {object} models.ErrorResponse "Invalid ID format"
// @Failure 404 {object} models.ErrorResponse "Return order not found"
// @Failure 500 {object} models.ErrorResponse "Internal server error or invalid status transition"
// @Router /returns/{id}/complete [post]
// @Security ApiKeyAuth
func (rc *ReturnController) CompleteReturnOrder(c iris.Context) {
	idStr := c.Params().Get("id")
	id, err := strconv.ParseUint(idStr, 10, 32)
	if err != nil {
		c.StatusCode(http.StatusBadRequest)
		c.JSON(iris.Map{
			"error": "无效的退换货单ID格式",
		})
		return
	}

	userID, userName, err := middleware.GetUserFromContext(c)
	if err != nil {
		c.StatusCode(http.StatusUnauthorized)
		c.JSON(iris.Map{
			"error": "无法获取用户信息",
		})
		return
	}

	updatedOrder, err := rc.ReturnService.CompleteReturnOrder(uint(id), userID, userName)
	if err != nil {
		switch e := err.(type) {
		case *utils.NotFoundError:
			c.StatusCode(http.StatusNotFound)
			c.JSON(iris.Map{
				"error": e.Error(),
			})
		case *utils.ValidationError:
			c.StatusCode(http.StatusBadRequest)
			c.JSON(iris.Map{
				"error": e.Error(),
			})
		default:
			c.StatusCode(http.StatusInternalServerError)
			c.JSON(iris.Map{
				"error": "完成退换货订单失败: " + err.Error(),
			})
		}
		return
	}
	c.StatusCode(http.StatusOK)
	c.JSON(updatedOrder)
}
