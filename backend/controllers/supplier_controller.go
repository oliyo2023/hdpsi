package controllers

import (
	"hd_psi/backend/models"
	"net/http"

	"github.com/kataras/iris/v12"
	"gorm.io/gorm"
)

type SupplierController struct {
	db *gorm.DB
}

func NewSupplierController(db *gorm.DB) *SupplierController {
	return &SupplierController{db: db}
}

// 供应商列表请求参数
type ListSuppliersQuery struct {
	Name   string `form:"name"`
	Code   string `form:"code"`
	Type   string `form:"type"`
	Status string `form:"status"`
	Page   int    `form:"page,default=1"`
	Limit  int    `form:"limit,default=10"`
}

// 供应商列表响应
type SuppliersResponse struct {
	Total int               `json:"total"`
	Items []models.Supplier `json:"items"`
}

// ListSuppliers 获取供应商列表
// @Summary 获取供应商列表
// @Description 获取供应商列表，支持按名称、编码、类型和状态筛选，并支持分页
// @Tags 供应商管理
// @Accept json
// @Produce json
// @Param name query string false "供应商名称（模糊查询）" example:"宏达"
// @Param code query string false "供应商编码（模糊查询）" example:"SUP001"
// @Param type query string false "供应商类型" Enums(manufacturer,distributor,retailer,wholesaler,other) example:"wholesaler"
// @Param status query string false "状态" Enums(active,inactive) example:"active"
// @Param page query int false "页码，默认1" minimum(1) example:"1"
// @Param limit query int false "每页数量，默认10" minimum(1) maximum(100) example:"10"
// @Success 200 {object} models.PaginatedResponse{items=[]models.Supplier} "成功获取供应商列表"
// @Failure 400 {object} models.ErrorResponse "请求参数错误"
// @Failure 401 {object} models.ErrorResponse "未授权"
// @Failure 500 {object} models.ErrorResponse "服务器内部错误"
// @Router /suppliers [get]
// @Security BearerAuth
func (sc *SupplierController) ListSuppliers(c iris.Context) {
	var query ListSuppliersQuery
	if err := c.ReadQuery(&query); err != nil {
		c.StatusCode(http.StatusBadRequest)
		c.JSON(iris.Map{"error": err.Error()})
		return
	}

	// 构建查询
	db := sc.db.Model(&models.Supplier{})

	// 应用过滤条件
	if query.Name != "" {
		db = db.Where("name LIKE ?", "%"+query.Name+"%")
	}
	if query.Code != "" {
		db = db.Where("code LIKE ?", "%"+query.Code+"%")
	}
	if query.Type != "" {
		db = db.Where("type = ?", query.Type)
	}
	if query.Status != "" {
		status := query.Status == "active"
		db = db.Where("status = ?", status)
	}

	// 计算总数
	var total int64
	db.Count(&total)

	// 分页
	offset := (query.Page - 1) * query.Limit
	var suppliers []models.Supplier

	if err := db.Offset(offset).Limit(query.Limit).
		Order("created_at DESC").
		Find(&suppliers).Error; err != nil {
		c.StatusCode(http.StatusInternalServerError)
		c.JSON(iris.Map{"error": err.Error()})
		return
	}

	c.StatusCode(http.StatusOK)
	c.JSON(SuppliersResponse{
		Total: int(total),
		Items: suppliers,
	})
}

// GetSupplier 获取供应商详情
// @Summary 获取供应商详情
// @Description 根据ID获取供应商的详细信息，包括基本信息、联系方式、评级等
// @Tags 供应商管理
// @Accept json
// @Produce json
// @Param id path int true "供应商ID" example:"1"
// @Success 200 {object} models.Supplier "成功获取供应商详情"
// @Failure 401 {object} models.ErrorResponse "未授权"
// @Failure 404 {object} models.ErrorResponse "供应商不存在"
// @Failure 500 {object} models.ErrorResponse "服务器内部错误"
// @Router /suppliers/{id} [get]
// @Security BearerAuth
func (sc *SupplierController) GetSupplier(c iris.Context) {
	id := c.Params().Get("id")
	var supplier models.Supplier

	if err := sc.db.First(&supplier, id).Error; err != nil {
		c.StatusCode(http.StatusNotFound)
		c.JSON(iris.Map{"error": "供应商不存在"})
		return
	}

	c.StatusCode(http.StatusOK)
	c.JSON(supplier)
}

// 创建供应商请求
type CreateSupplierRequest struct {
	Name          string                `json:"name"`
	Code          string                `json:"code"`
	Type          models.SupplierType   `json:"type"`
	ContactPerson string                `json:"contact_person"`
	ContactPhone  string                `json:"contact_phone"`
	Email         string                `json:"email"`
	Address       string                `json:"address"`
	City          string                `json:"city"`
	Rating        models.SupplierRating `json:"rating"`
	Qualification string                `json:"qualification"`
	PaymentTerms  string                `json:"payment_terms"`
	DeliveryTerms string                `json:"delivery_terms"`
	Status        bool                  `json:"status"`
	Note          string                `json:"note"`
}

// CreateSupplier 创建供应商
// @Summary 创建供应商
// @Description 创建新的供应商，需提供必要的供应商信息
// @Tags 供应商管理
// @Accept json
// @Produce json
// @Param supplier body CreateSupplierRequest true "供应商信息"
// @Success 201 {object} models.Supplier "创建成功"
// @Failure 400 {object} models.ErrorResponse "请求参数错误或供应商编码已存在"
// @Failure 401 {object} models.ErrorResponse "未授权"
// @Failure 500 {object} models.ErrorResponse "服务器内部错误"
// @Router /suppliers [post]
// @Security BearerAuth
// @Example 请求示例
//
//	{
//	  "name": "宏达服饰供应商",
//	  "code": "SUP001",
//	  "type": "wholesaler",
//	  "contact_person": "张三",
//	  "contact_phone": "13800138000",
//	  "email": "supplier@example.com",
//	  "address": "北京市朝阳区",
//	  "city": "北京市",
//	  "rating": "S",
//	  "qualification": "ISO9001认证",
//	  "payment_terms": "月结30天",
//	  "delivery_terms": "送货上门",
//	  "status": true,
//	  "note": "优质供应商"
//	}
func (sc *SupplierController) CreateSupplier(c iris.Context) {
	var request CreateSupplierRequest
	if err := c.ReadJSON(&request); err != nil {
		c.StatusCode(http.StatusBadRequest)
		c.JSON(iris.Map{"error": err.Error()})
		return
	}

	// 检查供应商编码是否已存在
	var existingSupplier models.Supplier
	if err := sc.db.Where("code = ?", request.Code).First(&existingSupplier).Error; err == nil {
		c.StatusCode(http.StatusBadRequest)
		c.JSON(iris.Map{"error": "供应商编码已存在"})
		return
	}

	// 创建供应商
	supplier := models.Supplier{
		Name:          request.Name,
		Code:          request.Code,
		Type:          request.Type,
		ContactPerson: request.ContactPerson,
		ContactPhone:  request.ContactPhone,
		Email:         request.Email,
		Address:       request.Address,
		City:          request.City,
		Rating:        request.Rating,
		Qualification: request.Qualification,
		PaymentTerms:  request.PaymentTerms,
		DeliveryTerms: request.DeliveryTerms,
		Status:        request.Status,
		Note:          request.Note,
	}

	if err := sc.db.Create(&supplier).Error; err != nil {
		c.StatusCode(http.StatusInternalServerError)
		c.JSON(iris.Map{"error": "创建供应商失败: " + err.Error()})
		return
	}

	c.StatusCode(http.StatusCreated)
	c.JSON(supplier)
}

// UpdateSupplier 更新供应商
// @Summary 更新供应商
// @Description 更新现有供应商的信息，需提供完整的供应商信息
// @Tags 供应商管理
// @Accept json
// @Produce json
// @Param id path int true "供应商ID" example:"1"
// @Param supplier body CreateSupplierRequest true "供应商信息"
// @Success 200 {object} models.Supplier "更新成功"
// @Failure 400 {object} models.ErrorResponse "请求参数错误或供应商编码已被其他供应商使用"
// @Failure 401 {object} models.ErrorResponse "未授权"
// @Failure 404 {object} models.ErrorResponse "供应商不存在"
// @Failure 500 {object} models.ErrorResponse "服务器内部错误"
// @Router /suppliers/{id} [put]
// @Security BearerAuth
// @Example 请求示例
//
//	{
//	  "name": "宏达服饰供应商（更新）",
//	  "code": "SUP001",
//	  "type": "wholesaler",
//	  "contact_person": "李四",
//	  "contact_phone": "13900139000",
//	  "email": "supplier_updated@example.com",
//	  "address": "北京市海淀区",
//	  "city": "北京市",
//	  "rating": "A",
//	  "qualification": "ISO9001认证,ISO14001认证",
//	  "payment_terms": "月结45天",
//	  "delivery_terms": "送货上门，包安装",
//	  "status": true,
//	  "note": "长期合作伙伴"
//	}
func (sc *SupplierController) UpdateSupplier(c iris.Context) {
	id := c.Params().Get("id")
	var supplier models.Supplier

	// 查询供应商
	if err := sc.db.First(&supplier, id).Error; err != nil {
		c.StatusCode(http.StatusNotFound)
		c.JSON(iris.Map{"error": "供应商不存在"})
		return
	}

	var request CreateSupplierRequest
	if err := c.ReadJSON(&request); err != nil {
		c.StatusCode(http.StatusBadRequest)
		c.JSON(iris.Map{"error": err.Error()})
		return
	}

	// 检查供应商编码是否已被其他供应商使用
	if request.Code != supplier.Code {
		var existingSupplier models.Supplier
		if err := sc.db.Where("code = ? AND id != ?", request.Code, id).First(&existingSupplier).Error; err == nil {
			c.StatusCode(http.StatusBadRequest)
			c.JSON(iris.Map{"error": "供应商编码已被其他供应商使用"})
			return
		}
	}

	// 更新供应商
	supplier.Name = request.Name
	supplier.Code = request.Code
	supplier.Type = request.Type
	supplier.ContactPerson = request.ContactPerson
	supplier.ContactPhone = request.ContactPhone
	supplier.Email = request.Email
	supplier.Address = request.Address
	supplier.City = request.City
	supplier.Rating = request.Rating
	supplier.Qualification = request.Qualification
	supplier.PaymentTerms = request.PaymentTerms
	supplier.DeliveryTerms = request.DeliveryTerms
	supplier.Status = request.Status
	supplier.Note = request.Note

	if err := sc.db.Save(&supplier).Error; err != nil {
		c.StatusCode(http.StatusInternalServerError)
		c.JSON(iris.Map{"error": "更新供应商失败: " + err.Error()})
		return
	}

	c.StatusCode(http.StatusOK)
	c.JSON(supplier)
}

// DeleteSupplier 删除供应商
// @Summary 删除供应商
// @Description 删除指定ID的供应商，如果供应商已被采购单引用则无法删除
// @Tags 供应商管理
// @Accept json
// @Produce json
// @Param id path int true "供应商ID" example:"1"
// @Success 200 {object} models.APIResponse "删除成功"
// @Failure 400 {object} models.ErrorResponse "供应商已被采购单引用，无法删除"
// @Failure 401 {object} models.ErrorResponse "未授权"
// @Failure 404 {object} models.ErrorResponse "供应商不存在"
// @Failure 500 {object} models.ErrorResponse "服务器内部错误"
// @Router /suppliers/{id} [delete]
// @Security BearerAuth
func (sc *SupplierController) DeleteSupplier(c iris.Context) {
	id := c.Params().Get("id")

	// 检查供应商是否存在
	var supplier models.Supplier
	if err := sc.db.First(&supplier, id).Error; err != nil {
		c.StatusCode(http.StatusNotFound)
		c.JSON(iris.Map{"error": "供应商不存在"})
		return
	}

	// 检查供应商是否被采购单引用
	var count int64
	sc.db.Model(&models.PurchaseOrder{}).Where("supplier_id = ?", id).Count(&count)
	if count > 0 {
		c.StatusCode(http.StatusBadRequest)
		c.JSON(iris.Map{"error": "供应商已被采购单引用，无法删除"})
		return
	}

	// 删除供应商
	if err := sc.db.Delete(&supplier).Error; err != nil {
		c.StatusCode(http.StatusInternalServerError)
		c.JSON(iris.Map{"error": "删除供应商失败: " + err.Error()})
		return
	}

	c.StatusCode(http.StatusOK)
	c.JSON(iris.Map{"message": "供应商删除成功"})
}