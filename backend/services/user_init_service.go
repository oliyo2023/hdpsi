package services

import (
	"hd_psi/backend/models"
	"hd_psi/backend/utils/logger"
	"time"

	"gorm.io/gorm"
)

// UserInitService 用户初始化服务
type UserInitService struct {
	db *gorm.DB
}

// NewUserInitService 创建用户初始化服务实例
func NewUserInitService(db *gorm.DB) *UserInitService {
	return &UserInitService{
		db: db,
	}
}

// InitDefaultUsers 初始化默认用户
func (s *UserInitService) InitDefaultUsers() error {
	log := &logger.Logger{Fields: make(map[string]interface{})}

	// 检查是否已存在管理员用户
	var adminCount int64
	if err := s.db.Model(&models.User{}).Where("role = ?", models.Admin).Count(&adminCount).Error; err != nil {
		log.Error("检查管理员用户失败", logger.F("error", err.Error()))
		return err
	}

	// 如果已存在管理员用户，则跳过初始化
	if adminCount > 0 {
		log.Info("管理员用户已存在，跳过初始化", logger.F("count", adminCount))
		return nil
	}

	// 创建默认管理员用户
	admin := &models.User{
		Username:  "admin",
		Password:  "admin123", // 这个密码会在BeforeSave钩子中自动加密
		Name:      "系统管理员",
		Email:     "admin@hdpsi.com",
		Phone:     "13800138000",
		Role:      models.Admin,
		Status:    true,
		StoreID:   nil, // 管理员不属于特定店铺
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	if err := s.db.Create(admin).Error; err != nil {
		log.Error("创建默认管理员用户失败", logger.F("error", err.Error()))
		return err
	}

	log.Info("默认管理员用户创建成功",
		logger.F("username", admin.Username),
		logger.F("name", admin.Name),
		logger.F("role", admin.Role))

	// 创建默认店长用户
	manager := &models.User{
		Username:  "manager",
		Password:  "manager123", // 这个密码会在BeforeSave钩子中自动加密
		Name:      "店长",
		Email:     "manager@hdpsi.com",
		Phone:     "13800138001",
		Role:      models.Manager,
		Status:    true,
		StoreID:   nil, // 可以后续分配到具体店铺
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	if err := s.db.Create(manager).Error; err != nil {
		log.Error("创建默认店长用户失败", logger.F("error", err.Error()))
		return err
	}

	log.Info("默认店长用户创建成功",
		logger.F("username", manager.Username),
		logger.F("name", manager.Name),
		logger.F("role", manager.Role))

	// 创建默认员工用户
	staff := &models.User{
		Username:  "staff",
		Password:  "staff123", // 这个密码会在BeforeSave钩子中自动加密
		Name:      "员工",
		Email:     "staff@hdpsi.com",
		Phone:     "13800138002",
		Role:      models.Staff,
		Status:    true,
		StoreID:   nil, // 可以后续分配到具体店铺
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	if err := s.db.Create(staff).Error; err != nil {
		log.Error("创建默认员工用户失败", logger.F("error", err.Error()))
		return err
	}

	log.Info("默认员工用户创建成功",
		logger.F("username", staff.Username),
		logger.F("name", staff.Name),
		logger.F("role", staff.Role))

	log.Info("所有默认用户创建完成")
	return nil
}

// CreateAdminUser 创建管理员用户（单独方法）
func (s *UserInitService) CreateAdminUser(username, password, name, email, phone string) error {
	log := &logger.Logger{Fields: make(map[string]interface{})}

	// 检查用户名是否已存在
	var existingUser models.User
	if err := s.db.Where("username = ?", username).First(&existingUser).Error; err == nil {
		log.Warn("用户名已存在", logger.F("username", username))
		return gorm.ErrDuplicatedKey
	}

	// 创建新用户
	user := &models.User{
		Username:  username,
		Password:  password, // 这个密码会在BeforeSave钩子中自动加密
		Name:      name,
		Email:     email,
		Phone:     phone,
		Role:      models.Admin,
		Status:    true,
		StoreID:   nil,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	if err := s.db.Create(user).Error; err != nil {
		log.Error("创建管理员用户失败", logger.F("error", err.Error()))
		return err
	}

	log.Info("管理员用户创建成功",
		logger.F("username", user.Username),
		logger.F("name", user.Name),
		logger.F("role", user.Role))

	return nil
}

// GetUserCount 获取用户总数
func (s *UserInitService) GetUserCount() (int64, error) {
	var count int64
	err := s.db.Model(&models.User{}).Count(&count).Error
	return count, err
}

// GetAdminCount 获取管理员用户数量
func (s *UserInitService) GetAdminCount() (int64, error) {
	var count int64
	err := s.db.Model(&models.User{}).Where("role = ?", models.Admin).Count(&count).Error
	return count, err
}
