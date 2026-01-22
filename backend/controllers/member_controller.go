package controllers

import (
	"hd_psi/backend/models"
	"strconv"
	"time"

	"github.com/kataras/iris/v12"
	"gorm.io/gorm"
)

type MemberController struct {
	db *gorm.DB
}

func NewMemberController(db *gorm.DB) *MemberController {
	return &MemberController{db: db}
}

// ListMembers godoc
// @Summary 获取会员列表
// @Description 获取会员列表，支持按名称、手机号和等级筛选，并支持分页
// @Tags 会员管理
// @Accept json
// @Produce json
// @Param name query string false "会员名称（模糊查询）" example:"张三"
// @Param phone query string false "手机号码（模糊查询）" example:"1380013"
// @Param level query string false "会员等级" Enums(regular,silver,gold,platinum,diamond) example:"gold"
// @Param page query int false "页码，默认1" minimum(1) example:"1"
// @Param pageSize query int false "每页数量，默认10" minimum(1) maximum(100) example:"10"
// @Success 200 {object} models.PaginatedResponse{items=[]models.Member} "成功获取会员列表"
// @Failure 400 {object} models.ErrorResponse "请求参数错误"
// @Failure 401 {object} models.ErrorResponse "未授权"
// @Failure 500 {object} models.ErrorResponse "服务器内部错误"
// @Router /members [get]
// @Security BearerAuth
func (mc *MemberController) ListMembers(c iris.Context) {
	// 获取查询参数
	name := c.URLParam("name")
	phone := c.URLParam("phone")
	level := c.URLParam("level")
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

	// 构建查询
	query := mc.db.Model(&models.Member{})

	// 添加过滤条件
	if name != "" {
		query = query.Where("name LIKE ?", "%"+name+"%")
	}
	if phone != "" {
		query = query.Where("phone LIKE ?", "%"+phone+"%")
	}
	if level != "" {
		query = query.Where("level = ?", level)
	}

	// 计算总数
	var total int64
	if err := query.Count(&total).Error; err != nil {
		c.JSON(iris.Map{"error": "获取会员总数失败"})
		c.StatusCode(iris.StatusInternalServerError)
		return
	}

	// 分页查询
	offset := (page - 1) * pageSize
	var members []models.Member
	if err := query.Offset(offset).Limit(pageSize).Find(&members).Error; err != nil {
		c.JSON(iris.Map{"error": "获取会员列表失败"})
		c.StatusCode(iris.StatusInternalServerError)
		return
	}

	c.JSON(iris.Map{
		"items":    members,
		"total":    total,
		"page":     page,
		"pageSize": pageSize,
	})
}

// GetMember godoc
// @Summary 获取会员详情
// @Description 根据ID获取会员的详细信息，包括基本信息、等级、积分等
// @Tags 会员管理
// @Accept json
// @Produce json
// @Param id path int true "会员ID" example:"1"
// @Success 200 {object} models.Member "成功获取会员详情"
// @Failure 401 {object} models.ErrorResponse "未授权"
// @Failure 404 {object} models.ErrorResponse "会员不存在"
// @Failure 500 {object} models.ErrorResponse "服务器内部错误"
// @Router /members/{id} [get]
// @Security BearerAuth
func (mc *MemberController) GetMember(c iris.Context) {
	id := c.Params().Get("id")
	var member models.Member
	if err := mc.db.First(&member, id).Error; err != nil {
		c.JSON(iris.Map{"error": "Member not found"})
		c.StatusCode(iris.StatusNotFound)
		return
	}
	c.JSON(member)
}

// CreateMember godoc
// @Summary 创建会员
// @Description 创建新的会员，需提供必要的会员信息
// @Tags 会员管理
// @Accept json
// @Produce json
// @Param member body models.Member true "会员信息"
// @Success 201 {object} models.APIResponse{data=models.Member} "创建成功"
// @Failure 400 {object} models.ErrorResponse "请求参数错误或手机号已被注册"
// @Failure 401 {object} models.ErrorResponse "未授权"
// @Failure 500 {object} models.ErrorResponse "服务器内部错误"
// @Router /members [post]
// @Security BearerAuth
// @Example 请求示例
//
//	{
//	  "name": "张三",
//	  "phone": "13800138000",
//	  "gender": "male",
//	  "birthday": "1990-01-01",
//	  "email": "zhangsan@example.com",
//	  "address": "北京市朝阳区",
//	  "level": "gold",
//	  "points": 1000,
//	  "style_preference": "casual",
//	  "consumption_level": "medium",
//	  "note": "重要客户"
//	}
func (mc *MemberController) CreateMember(c iris.Context) {
	var member models.Member
	if err := c.ReadJSON(&member); err != nil {
		c.JSON(iris.Map{"error": err.Error()})
		c.StatusCode(iris.StatusBadRequest)
		return
	}

	// 验证手机号是否已存在
	var existingMember models.Member
	if member.Phone != "" {
		if err := mc.db.Where("phone = ?", member.Phone).First(&existingMember).Error; err == nil {
			c.JSON(iris.Map{"error": "手机号已被注册"})
			c.StatusCode(iris.StatusBadRequest)
			return
		}
	}

	// 设置默认值
	if member.Level == "" {
		member.Level = models.Regular
	}

	// 设置创建时间
	member.CreatedAt = time.Now()
	member.UpdatedAt = time.Now()

	// 创建会员
	if err := mc.db.Create(&member).Error; err != nil {
		c.JSON(iris.Map{"error": "创建会员失败: " + err.Error()})
		c.StatusCode(iris.StatusInternalServerError)
		return
	}

	c.StatusCode(iris.StatusCreated)
	c.JSON(iris.Map{
		"message": "会员创建成功",
		"member":  member,
	})
}

// UpdateMember godoc
// @Summary 更新会员
// @Description 更新现有会员的信息，需提供完整的会员信息
// @Tags 会员管理
// @Accept json
// @Produce json
// @Param id path int true "会员ID" example:"1"
// @Param member body models.Member true "会员信息"
// @Success 200 {object} models.Member "更新成功"
// @Failure 400 {object} models.ErrorResponse "请求参数错误"
// @Failure 401 {object} models.ErrorResponse "未授权"
// @Failure 404 {object} models.ErrorResponse "会员不存在"
// @Failure 500 {object} models.ErrorResponse "服务器内部错误"
// @Router /members/{id} [put]
// @Security BearerAuth
// @Example 请求示例
//
//	{
//	  "name": "张三（更新）",
//	  "phone": "13900139000",
//	  "gender": "male",
//	  "birthday": "1990-01-01",
//	  "email": "zhangsan_updated@example.com",
//	  "address": "北京市海淀区",
//	  "level": "platinum",
//	  "points": 2000,
//	  "style_preference": "business",
//	  "consumption_level": "high",
//	  "note": "VIP客户"
//	}
func (mc *MemberController) UpdateMember(c iris.Context) {
	id := c.Params().Get("id")
	var member models.Member
	if err := mc.db.First(&member, id).Error; err != nil {
		c.JSON(iris.Map{"error": "Member not found"})
		c.StatusCode(iris.StatusNotFound)
		return
	}

	if err := c.ReadJSON(&member); err != nil {
		c.JSON(iris.Map{"error": err.Error()})
		c.StatusCode(iris.StatusBadRequest)
		return
	}

	if err := mc.db.Save(&member).Error; err != nil {
		c.JSON(iris.Map{"error": err.Error()})
		c.StatusCode(iris.StatusInternalServerError)
		return
	}
	c.JSON(member)
}

// DeleteMember godoc
// @Summary 删除会员
// @Description 删除指定ID的会员，此操作不可逆
// @Tags 会员管理
// @Accept json
// @Produce json
// @Param id path int true "会员ID" example:"1"
// @Success 200 {object} models.APIResponse "删除成功"
// @Failure 401 {object} models.ErrorResponse "未授权"
// @Failure 404 {object} models.ErrorResponse "会员不存在"
// @Failure 500 {object} models.ErrorResponse "服务器内部错误"
// @Router /members/{id} [delete]
// @Security BearerAuth
func (mc *MemberController) DeleteMember(c iris.Context) {
	id := c.Params().Get("id")
	if err := mc.db.Delete(&models.Member{}, id).Error; err != nil {
		c.JSON(iris.Map{"error": err.Error()})
		c.StatusCode(iris.StatusInternalServerError)
		return
	}
	c.JSON(iris.Map{"message": "Member deleted"})
}