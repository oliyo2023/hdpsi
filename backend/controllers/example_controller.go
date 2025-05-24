package controllers

import (
	"hd_psi/backend/models"
	"hd_psi/backend/utils/errors"
	"hd_psi/backend/utils/logger"
	"hd_psi/backend/utils/response"
	"strconv"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// ExampleController 示例控制器，展示如何使用统一响应格式
type ExampleController struct {
	db *gorm.DB
}

// NewExampleController 创建示例控制器实例
func NewExampleController(db *gorm.DB) *ExampleController {
	return &ExampleController{db: db}
}

// GetUser 获取用户信息
// @Summary 获取用户信息
// @Description 根据ID获取用户的详细信息
// @Tags 示例
// @Accept json
// @Produce json
// @Param id path int true "用户ID" example:"1"
// @Success 200 {object} models.APIResponse{data=models.User} "成功获取用户信息"
// @Failure 400 {object} models.APIResponse "请求参数错误"
// @Failure 401 {object} models.APIResponse "未授权"
// @Failure 404 {object} models.APIResponse "用户不存在"
// @Failure 500 {object} models.APIResponse "服务器内部错误"
// @Router /examples/users/{id} [get]
// @Security BearerAuth
func (ec *ExampleController) GetUser(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)
	log.Info("获取用户信息")

	// 获取用户ID
	id := c.Param("id")
	userID, err := strconv.ParseUint(id, 10, 32)
	if err != nil {
		log.Warn("无效的用户ID格式", logger.F("id", id))
		response.BadRequest(c, "无效的用户ID格式")
		return
	}

	// 查询用户信息
	var user models.User
	if err := ec.db.First(&user, userID).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			log.Warn("用户不存在", logger.F("user_id", userID))
			response.NotFound(c, "用户不存在")
			return
		}
		log.Error("获取用户信息失败", 
			logger.F("user_id", userID),
			logger.F("error", err.Error()))
		response.DatabaseError(c, "获取用户信息失败")
		return
	}

	// 返回成功响应
	log.Info("获取用户信息成功", logger.F("user_id", user.ID))
	response.Success(c, user)
}

// ListUsers 获取用户列表
// @Summary 获取用户列表
// @Description 获取用户列表，支持分页和筛选
// @Tags 示例
// @Accept json
// @Produce json
// @Param page query int false "页码" default:"1"
// @Param pageSize query int false "每页记录数" default:"10"
// @Param name query string false "用户名" 
// @Success 200 {object} models.APIResponse{data=models.PaginatedResponse{items=[]models.User}} "成功获取用户列表"
// @Failure 400 {object} models.APIResponse "请求参数错误"
// @Failure 401 {object} models.APIResponse "未授权"
// @Failure 500 {object} models.APIResponse "服务器内部错误"
// @Router /examples/users [get]
// @Security BearerAuth
func (ec *ExampleController) ListUsers(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)
	log.Info("获取用户列表")

	// 获取查询参数
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("pageSize", "10"))
	name := c.Query("name")

	// 构建查询
	query := ec.db.Model(&models.User{})
	if name != "" {
		query = query.Where("username LIKE ?", "%"+name+"%")
	}

	// 计算总数
	var total int64
	if err := query.Count(&total).Error; err != nil {
		log.Error("获取用户总数失败", logger.F("error", err.Error()))
		response.DatabaseError(c, "获取用户总数失败")
		return
	}

	// 分页查询
	offset := (page - 1) * pageSize
	var users []models.User
	if err := query.Offset(offset).Limit(pageSize).Find(&users).Error; err != nil {
		log.Error("获取用户列表失败", logger.F("error", err.Error()))
		response.DatabaseError(c, "获取用户列表失败")
		return
	}

	// 返回分页响应
	log.Info("获取用户列表成功", 
		logger.F("total", total),
		logger.F("page", page),
		logger.F("pageSize", pageSize))
	response.Paginated(c, users, total, page, pageSize)
}

// CreateUser 创建用户
// @Summary 创建用户
// @Description 创建新用户
// @Tags 示例
// @Accept json
// @Produce json
// @Param user body models.User true "用户信息"
// @Success 201 {object} models.APIResponse{data=models.User} "用户创建成功"
// @Failure 400 {object} models.APIResponse "请求参数错误"
// @Failure 401 {object} models.APIResponse "未授权"
// @Failure 409 {object} models.APIResponse "用户已存在"
// @Failure 500 {object} models.APIResponse "服务器内部错误"
// @Router /examples/users [post]
// @Security BearerAuth
func (ec *ExampleController) CreateUser(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)
	log.Info("创建用户")

	// 解析请求参数
	var user models.User
	if err := c.ShouldBindJSON(&user); err != nil {
		log.Warn("无效的用户信息", logger.F("error", err.Error()))
		response.BadRequest(c, "无效的用户信息")
		return
	}

	// 检查用户名是否已存在
	var count int64
	if err := ec.db.Model(&models.User{}).Where("username = ?", user.Username).Count(&count).Error; err != nil {
		log.Error("检查用户名是否存在失败", 
			logger.F("username", user.Username),
			logger.F("error", err.Error()))
		response.DatabaseError(c, "检查用户名是否存在失败")
		return
	}

	if count > 0 {
		log.Warn("用户名已存在", logger.F("username", user.Username))
		response.Fail(c, errors.CodeUserAlreadyExists, "用户名已存在")
		return
	}

	// 创建用户
	if err := ec.db.Create(&user).Error; err != nil {
		log.Error("创建用户失败", 
			logger.F("username", user.Username),
			logger.F("error", err.Error()))
		response.DatabaseError(c, "创建用户失败")
		return
	}

	// 返回创建成功响应
	log.Info("创建用户成功", 
		logger.F("user_id", user.ID),
		logger.F("username", user.Username))
	response.Created(c, user)
}

// UpdateUser 更新用户信息
// @Summary 更新用户信息
// @Description 更新用户的详细信息
// @Tags 示例
// @Accept json
// @Produce json
// @Param id path int true "用户ID" example:"1"
// @Param user body models.User true "用户信息"
// @Success 200 {object} models.APIResponse{data=models.User} "用户更新成功"
// @Failure 400 {object} models.APIResponse "请求参数错误"
// @Failure 401 {object} models.APIResponse "未授权"
// @Failure 404 {object} models.APIResponse "用户不存在"
// @Failure 500 {object} models.APIResponse "服务器内部错误"
// @Router /examples/users/{id} [put]
// @Security BearerAuth
func (ec *ExampleController) UpdateUser(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)
	log.Info("更新用户信息")

	// 获取用户ID
	id := c.Param("id")
	userID, err := strconv.ParseUint(id, 10, 32)
	if err != nil {
		log.Warn("无效的用户ID格式", logger.F("id", id))
		response.BadRequest(c, "无效的用户ID格式")
		return
	}

	// 解析请求参数
	var updateData models.User
	if err := c.ShouldBindJSON(&updateData); err != nil {
		log.Warn("无效的用户信息", logger.F("error", err.Error()))
		response.BadRequest(c, "无效的用户信息")
		return
	}

	// 查询用户是否存在
	var user models.User
	if err := ec.db.First(&user, userID).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			log.Warn("用户不存在", logger.F("user_id", userID))
			response.NotFound(c, "用户不存在")
			return
		}
		log.Error("查询用户失败", 
			logger.F("user_id", userID),
			logger.F("error", err.Error()))
		response.DatabaseError(c, "查询用户失败")
		return
	}

	// 更新用户信息
	if err := ec.db.Model(&user).Updates(updateData).Error; err != nil {
		log.Error("更新用户信息失败", 
			logger.F("user_id", userID),
			logger.F("error", err.Error()))
		response.DatabaseError(c, "更新用户信息失败")
		return
	}

	// 重新获取更新后的用户信息
	if err := ec.db.First(&user, userID).Error; err != nil {
		log.Error("获取更新后的用户信息失败", 
			logger.F("user_id", userID),
			logger.F("error", err.Error()))
		response.DatabaseError(c, "获取更新后的用户信息失败")
		return
	}

	// 返回成功响应
	log.Info("更新用户信息成功", logger.F("user_id", user.ID))
	response.Success(c, user)
}

// DeleteUser 删除用户
// @Summary 删除用户
// @Description 根据ID删除用户
// @Tags 示例
// @Accept json
// @Produce json
// @Param id path int true "用户ID" example:"1"
// @Success 200 {object} models.APIResponse "用户删除成功"
// @Failure 400 {object} models.APIResponse "请求参数错误"
// @Failure 401 {object} models.APIResponse "未授权"
// @Failure 404 {object} models.APIResponse "用户不存在"
// @Failure 500 {object} models.APIResponse "服务器内部错误"
// @Router /examples/users/{id} [delete]
// @Security BearerAuth
func (ec *ExampleController) DeleteUser(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)
	log.Info("删除用户")

	// 获取用户ID
	id := c.Param("id")
	userID, err := strconv.ParseUint(id, 10, 32)
	if err != nil {
		log.Warn("无效的用户ID格式", logger.F("id", id))
		response.BadRequest(c, "无效的用户ID格式")
		return
	}

	// 查询用户是否存在
	var user models.User
	if err := ec.db.First(&user, userID).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			log.Warn("用户不存在", logger.F("user_id", userID))
			response.NotFound(c, "用户不存在")
			return
		}
		log.Error("查询用户失败", 
			logger.F("user_id", userID),
			logger.F("error", err.Error()))
		response.DatabaseError(c, "查询用户失败")
		return
	}

	// 删除用户
	if err := ec.db.Delete(&user).Error; err != nil {
		log.Error("删除用户失败", 
			logger.F("user_id", userID),
			logger.F("error", err.Error()))
		response.DatabaseError(c, "删除用户失败")
		return
	}

	// 返回成功响应
	log.Info("删除用户成功", logger.F("user_id", userID))
	response.Success(c, nil)
}
