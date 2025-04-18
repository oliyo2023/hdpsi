package controllers

import (
	"hd_psi/backend/models"
	"hd_psi/backend/services"
	"hd_psi/backend/utils/errors"
	"hd_psi/backend/utils/logger"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// PermissionController 处理权限相关的请求
type PermissionController struct {
	db             *gorm.DB
	casbinService  *services.CasbinService
}

// NewPermissionController 创建一个新的PermissionController实例
func NewPermissionController(db *gorm.DB, casbinService *services.CasbinService) *PermissionController {
	return &PermissionController{
		db:             db,
		casbinService:  casbinService,
	}
}

// GetAllPolicies 获取所有策略
func (pc *PermissionController) GetAllPolicies(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)
	log.Info("获取所有权限策略")

	policies := pc.casbinService.GetAllPolicies()
	c.JSON(http.StatusOK, gin.H{"policies": policies})
}

// GetAllRoles 获取所有角色
func (pc *PermissionController) GetAllRoles(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)
	log.Info("获取所有角色")

	roles := pc.casbinService.GetAllRoles()
	c.JSON(http.StatusOK, gin.H{"roles": roles})
}

// GetRolePermissions 获取角色的所有权限
func (pc *PermissionController) GetRolePermissions(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)
	
	role := c.Param("role")
	log.Info("获取角色权限", logger.F("role", role))

	permissions := pc.casbinService.GetPermissionsForRole(role)
	c.JSON(http.StatusOK, gin.H{"permissions": permissions})
}

// AddPolicy 添加策略
func (pc *PermissionController) AddPolicy(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)
	log.Info("添加权限策略")

	var input struct {
		Sub string `json:"sub" binding:"required"`
		Obj string `json:"obj" binding:"required"`
		Act string `json:"act" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		log.Warn("添加权限策略请求参数无效", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrInvalidInput).
			WithDetails("请提供有效的策略信息").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	log = log.WithFields(
		logger.F("sub", input.Sub),
		logger.F("obj", input.Obj),
		logger.F("act", input.Act),
	)

	added, err := pc.casbinService.AddPolicy(input.Sub, input.Obj, input.Act)
	if err != nil {
		log.Error("添加权限策略失败", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrInternal).
			WithDetails("添加权限策略失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 记录审计日志
	userID, _ := c.Get("userID")
	auditLog := models.PermissionAuditLog{
		UserID:    userID.(uint),
		Action:    "add_policy",
		Resource:  input.Obj,
		Operation: input.Act,
		Subject:   input.Sub,
		CreatedAt: time.Now(),
	}
	pc.db.Create(&auditLog)

	log.Info("添加权限策略成功", logger.F("added", added))
	c.JSON(http.StatusOK, gin.H{"success": added})
}

// RemovePolicy 删除策略
func (pc *PermissionController) RemovePolicy(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)
	log.Info("删除权限策略")

	var input struct {
		Sub string `json:"sub" binding:"required"`
		Obj string `json:"obj" binding:"required"`
		Act string `json:"act" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		log.Warn("删除权限策略请求参数无效", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrInvalidInput).
			WithDetails("请提供有效的策略信息").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	log = log.WithFields(
		logger.F("sub", input.Sub),
		logger.F("obj", input.Obj),
		logger.F("act", input.Act),
	)

	removed, err := pc.casbinService.RemovePolicy(input.Sub, input.Obj, input.Act)
	if err != nil {
		log.Error("删除权限策略失败", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrInternal).
			WithDetails("删除权限策略失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 记录审计日志
	userID, _ := c.Get("userID")
	auditLog := models.PermissionAuditLog{
		UserID:    userID.(uint),
		Action:    "remove_policy",
		Resource:  input.Obj,
		Operation: input.Act,
		Subject:   input.Sub,
		CreatedAt: time.Now(),
	}
	pc.db.Create(&auditLog)

	log.Info("删除权限策略成功", logger.F("removed", removed))
	c.JSON(http.StatusOK, gin.H{"success": removed})
}

// AddRoleForUser 为用户添加角色
func (pc *PermissionController) AddRoleForUser(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)
	log.Info("为用户添加角色")

	var input struct {
		User string `json:"user" binding:"required"`
		Role string `json:"role" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		log.Warn("为用户添加角色请求参数无效", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrInvalidInput).
			WithDetails("请提供有效的用户和角色信息").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	log = log.WithFields(
		logger.F("user", input.User),
		logger.F("role", input.Role),
	)

	added, err := pc.casbinService.AddRoleForUser(input.User, input.Role)
	if err != nil {
		log.Error("为用户添加角色失败", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrInternal).
			WithDetails("为用户添加角色失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 记录审计日志
	userID, _ := c.Get("userID")
	auditLog := models.PermissionAuditLog{
		UserID:    userID.(uint),
		Action:    "add_role",
		Resource:  "user",
		Operation: "assign_role",
		Subject:   input.User,
		Details:   input.Role,
		CreatedAt: time.Now(),
	}
	pc.db.Create(&auditLog)

	log.Info("为用户添加角色成功", logger.F("added", added))
	c.JSON(http.StatusOK, gin.H{"success": added})
}

// DeleteRoleForUser 删除用户的角色
func (pc *PermissionController) DeleteRoleForUser(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)
	log.Info("删除用户的角色")

	var input struct {
		User string `json:"user" binding:"required"`
		Role string `json:"role" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		log.Warn("删除用户的角色请求参数无效", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrInvalidInput).
			WithDetails("请提供有效的用户和角色信息").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	log = log.WithFields(
		logger.F("user", input.User),
		logger.F("role", input.Role),
	)

	deleted, err := pc.casbinService.DeleteRoleForUser(input.User, input.Role)
	if err != nil {
		log.Error("删除用户的角色失败", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrInternal).
			WithDetails("删除用户的角色失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 记录审计日志
	userID, _ := c.Get("userID")
	auditLog := models.PermissionAuditLog{
		UserID:    userID.(uint),
		Action:    "delete_role",
		Resource:  "user",
		Operation: "remove_role",
		Subject:   input.User,
		Details:   input.Role,
		CreatedAt: time.Now(),
	}
	pc.db.Create(&auditLog)

	log.Info("删除用户的角色成功", logger.F("deleted", deleted))
	c.JSON(http.StatusOK, gin.H{"success": deleted})
}

// GetRolesForUser 获取用户的所有角色
func (pc *PermissionController) GetRolesForUser(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)
	
	user := c.Param("user")
	log.Info("获取用户的所有角色", logger.F("user", user))

	roles, err := pc.casbinService.GetRolesForUser(user)
	if err != nil {
		log.Error("获取用户的所有角色失败", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrInternal).
			WithDetails("获取用户的所有角色失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	log.Info("获取用户的所有角色成功", logger.F("roles_count", len(roles)))
	c.JSON(http.StatusOK, gin.H{"roles": roles})
}

// GetUsersForRole 获取具有指定角色的所有用户
func (pc *PermissionController) GetUsersForRole(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)
	
	role := c.Param("role")
	log.Info("获取具有指定角色的所有用户", logger.F("role", role))

	users, err := pc.casbinService.GetUsersForRole(role)
	if err != nil {
		log.Error("获取具有指定角色的所有用户失败", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrInternal).
			WithDetails("获取具有指定角色的所有用户失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	log.Info("获取具有指定角色的所有用户成功", logger.F("users_count", len(users)))
	c.JSON(http.StatusOK, gin.H{"users": users})
}

// CheckPermission 检查权限
func (pc *PermissionController) CheckPermission(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)
	log.Info("检查权限")

	var input struct {
		Sub string `json:"sub" binding:"required"`
		Obj string `json:"obj" binding:"required"`
		Act string `json:"act" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		log.Warn("检查权限请求参数无效", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrInvalidInput).
			WithDetails("请提供有效的权限检查信息").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	log = log.WithFields(
		logger.F("sub", input.Sub),
		logger.F("obj", input.Obj),
		logger.F("act", input.Act),
	)

	allowed, err := pc.casbinService.Enforce(input.Sub, input.Obj, input.Act)
	if err != nil {
		log.Error("检查权限失败", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrInternal).
			WithDetails("检查权限失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	log.Info("检查权限成功", logger.F("allowed", allowed))
	c.JSON(http.StatusOK, gin.H{"allowed": allowed})
}

// GetAuditLogs 获取权限审计日志
func (pc *PermissionController) GetAuditLogs(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)
	log.Info("获取权限审计日志")

	var logs []models.PermissionAuditLog
	if err := pc.db.Order("created_at DESC").Limit(100).Find(&logs).Error; err != nil {
		log.Error("获取权限审计日志失败", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrDatabaseQuery).
			WithDetails("获取权限审计日志失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	log.Info("获取权限审计日志成功", logger.F("logs_count", len(logs)))
	c.JSON(http.StatusOK, gin.H{"logs": logs})
}
