package controllers

import (
	"hd_psi/backend/models"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type MemberController struct {
	db *gorm.DB
}

func NewMemberController(db *gorm.DB) *MemberController {
	return &MemberController{db: db}
}

func (mc *MemberController) ListMembers(c *gin.Context) {
	// 获取查询参数
	name := c.Query("name")
	phone := c.Query("phone")
	level := c.Query("level")
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("pageSize", "10"))

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
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取会员总数失败"})
		return
	}

	// 分页查询
	offset := (page - 1) * pageSize
	var members []models.Member
	if err := query.Offset(offset).Limit(pageSize).Find(&members).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取会员列表失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"items":    members,
		"total":    total,
		"page":     page,
		"pageSize": pageSize,
	})
}

func (mc *MemberController) GetMember(c *gin.Context) {
	id := c.Param("id")
	var member models.Member
	if err := mc.db.First(&member, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Member not found"})
		return
	}
	c.JSON(http.StatusOK, member)
}

func (mc *MemberController) CreateMember(c *gin.Context) {
	var member models.Member
	if err := c.ShouldBindJSON(&member); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 验证手机号是否已存在
	var existingMember models.Member
	if member.Phone != "" {
		if err := mc.db.Where("phone = ?", member.Phone).First(&existingMember).Error; err == nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "手机号已被注册"})
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
		c.JSON(http.StatusInternalServerError, gin.H{"error": "创建会员失败: " + err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "会员创建成功",
		"member":  member,
	})
}

func (mc *MemberController) UpdateMember(c *gin.Context) {
	id := c.Param("id")
	var member models.Member
	if err := mc.db.First(&member, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Member not found"})
		return
	}

	if err := c.ShouldBindJSON(&member); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := mc.db.Save(&member).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, member)
}

func (mc *MemberController) DeleteMember(c *gin.Context) {
	id := c.Param("id")
	if err := mc.db.Delete(&models.Member{}, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Member deleted"})
}
