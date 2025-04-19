package controllers

import (
	"hd_psi/backend/models"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// PointsTransaction 积分交易记录
type PointsTransaction struct {
	ID            uint   `gorm:"primaryKey"`
	MemberID      uint   `gorm:"not null"`         // 会员ID
	Points        int    `gorm:"not null"`         // 积分变动，正数为增加，负数为减少
	Type          string `gorm:"size:20;not null"` // 类型：购物/兑换/调整
	ReferenceID   *uint  // 关联单据ID
	ReferenceType string `gorm:"size:20"`  // 关联单据类型
	Description   string `gorm:"size:255"` // 描述
	OperatorID    uint   // 操作人ID
	Balance       int    `gorm:"not null;default:0"` // 交易后余额
	CreatedAt     time.Time
}

type MemberPointsController struct {
	db *gorm.DB
}

func NewMemberPointsController(db *gorm.DB) *MemberPointsController {
	return &MemberPointsController{db: db}
}

// GetMemberPoints 获取会员积分
func (mpc *MemberPointsController) GetMemberPoints(c *gin.Context) {
	memberID := c.Param("id")
	var member models.Member
	if err := mpc.db.First(&member, memberID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Member not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"member_id": member.ID,
		"name":      member.Name,
		"points":    member.Points,
	})
}

// ListPointsTransactions 获取会员积分交易记录
func (mpc *MemberPointsController) ListPointsTransactions(c *gin.Context) {
	memberID := c.Param("id")

	// 验证会员是否存在
	var member models.Member
	if err := mpc.db.First(&member, memberID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Member not found"})
		return
	}

	// 获取查询参数
	pageStr := c.DefaultQuery("page", "1")
	limitStr := c.DefaultQuery("limit", "10")
	transactionType := c.Query("type")
	startDate := c.Query("startDate")
	endDate := c.Query("endDate")

	// 将字符串转换为整数
	page, _ := strconv.Atoi(pageStr)
	limit, _ := strconv.Atoi(limitStr)

	// 防止非法值
	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 10
	}

	// 构建查询
	query := mpc.db.Model(&PointsTransaction{}).Where("member_id = ?", memberID)

	// 添加过滤条件
	if transactionType != "" {
		query = query.Where("type = ?", transactionType)
	}

	if startDate != "" {
		query = query.Where("created_at >= ?", startDate)
	}

	if endDate != "" {
		query = query.Where("created_at <= ?", endDate)
	}

	// 获取总记录数
	var total int64
	query.Count(&total)

	// 分页查询
	var transactions []PointsTransaction
	if err := query.Order("created_at DESC").Limit(limit).Offset((page - 1) * limit).Find(&transactions).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// 返回结果
	c.JSON(http.StatusOK, gin.H{
		"items":  transactions,
		"total":  total,
		"page":   page,
		"limit":  limit,
		"member": member,
	})
}

// AddPoints 增加会员积分
func (mpc *MemberPointsController) AddPoints(c *gin.Context) {
	memberID := c.Param("id")

	var input struct {
		Points        int    `json:"points" binding:"required"`
		Type          string `json:"type" binding:"required"`
		ReferenceID   *uint  `json:"reference_id"`
		ReferenceType string `json:"reference_type"`
		Description   string `json:"description"`
		OperatorID    uint   `json:"operator_id"` // 移除required标签，允许前端不传
		Note          string `json:"note"`        // 添加备注字段
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 如果前端没有提供操作人ID，默认设置为1（系统用户）
	if input.OperatorID == 0 {
		input.OperatorID = 1
	}

	// 如果有备注信息，添加到描述中
	if input.Note != "" {
		input.Description = input.Note
	}

	// 验证积分必须为正数
	if input.Points <= 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Points must be positive"})
		return
	}

	// 开始事务
	tx := mpc.db.Begin()

	// 获取会员信息
	var member models.Member
	if err := tx.First(&member, memberID).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusNotFound, gin.H{"error": "Member not found"})
		return
	}

	// 更新会员积分
	member.Points += input.Points
	if err := tx.Save(&member).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update member points"})
		return
	}

	// 创建积分交易记录
	transaction := PointsTransaction{
		MemberID:      member.ID,
		Points:        input.Points,
		Type:          input.Type,
		ReferenceID:   input.ReferenceID,
		ReferenceType: input.ReferenceType,
		Description:   input.Description,
		OperatorID:    input.OperatorID,
		Balance:       member.Points, // 设置交易后余额
		CreatedAt:     time.Now(),
	}

	if err := tx.Create(&transaction).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create points transaction"})
		return
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to commit transaction"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"member_id":   member.ID,
		"name":        member.Name,
		"points":      member.Points,
		"transaction": transaction,
	})
}

// DeductPoints 扣减会员积分
func (mpc *MemberPointsController) DeductPoints(c *gin.Context) {
	memberID := c.Param("id")

	var input struct {
		Points        int    `json:"points" binding:"required"`
		Type          string `json:"type" binding:"required"`
		ReferenceID   *uint  `json:"reference_id"`
		ReferenceType string `json:"reference_type"`
		Description   string `json:"description"`
		OperatorID    uint   `json:"operator_id"` // 移除required标签，允许前端不传
		Note          string `json:"note"`        // 添加备注字段
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 如果前端没有提供操作人ID，默认设置为1（系统用户）
	if input.OperatorID == 0 {
		input.OperatorID = 1
	}

	// 如果有备注信息，添加到描述中
	if input.Note != "" {
		input.Description = input.Note
	}

	// 验证积分必须为正数
	if input.Points <= 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Points must be positive"})
		return
	}

	// 开始事务
	tx := mpc.db.Begin()

	// 获取会员信息
	var member models.Member
	if err := tx.First(&member, memberID).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusNotFound, gin.H{"error": "Member not found"})
		return
	}

	// 检查积分是否足够
	if member.Points < input.Points {
		tx.Rollback()
		c.JSON(http.StatusBadRequest, gin.H{"error": "Insufficient points"})
		return
	}

	// 更新会员积分
	member.Points -= input.Points
	if err := tx.Save(&member).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update member points"})
		return
	}

	// 创建积分交易记录
	transaction := PointsTransaction{
		MemberID:      member.ID,
		Points:        -input.Points, // 负数表示扣减
		Type:          input.Type,
		ReferenceID:   input.ReferenceID,
		ReferenceType: input.ReferenceType,
		Description:   input.Description,
		OperatorID:    input.OperatorID,
		Balance:       member.Points, // 设置交易后余额
		CreatedAt:     time.Now(),
	}

	if err := tx.Create(&transaction).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create points transaction"})
		return
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to commit transaction"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"member_id":   member.ID,
		"name":        member.Name,
		"points":      member.Points,
		"transaction": transaction,
	})
}

// CalculateMemberLevel 计算会员等级
func (mpc *MemberPointsController) CalculateMemberLevel(c *gin.Context) {
	memberID := c.Param("id")

	// 获取会员信息
	var member models.Member
	if err := mpc.db.First(&member, memberID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Member not found"})
		return
	}

	// 根据累计消费金额计算会员等级
	var newLevel models.MemberLevel

	switch {
	case member.TotalSpent >= 50000:
		newLevel = models.Diamond
	case member.TotalSpent >= 20000:
		newLevel = models.Platinum
	case member.TotalSpent >= 10000:
		newLevel = models.Gold
	case member.TotalSpent >= 5000:
		newLevel = models.Silver
	default:
		newLevel = models.Regular
	}

	// 如果等级有变化，更新会员等级
	if member.Level != newLevel {
		member.Level = newLevel
		if err := mpc.db.Save(&member).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update member level"})
			return
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"member_id":   member.ID,
		"name":        member.Name,
		"level":       member.Level,
		"total_spent": member.TotalSpent,
	})
}
