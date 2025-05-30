package services

import (
	"errors"
	"time"

	"hd_psi/backend/models"

	"gorm.io/gorm"
)

// UserService 用户服务
type UserService struct {
	db *gorm.DB
}

// NewUserService 创建用户服务实例
func NewUserService() *UserService {
	// 这里需要从全局获取数据库连接
	// 实际项目中应该通过依赖注入传入
	return &UserService{
		// db: database.GetDB(), // 需要根据实际项目结构调整
	}
}

// NewUserServiceWithDB 使用指定数据库连接创建用户服务
func NewUserServiceWithDB(db *gorm.DB) *UserService {
	return &UserService{
		db: db,
	}
}

// FindByWechatOpenID 通过微信OpenID查找用户
func (s *UserService) FindByWechatOpenID(openID string) (*models.User, error) {
	var user models.User
	err := s.db.Where("wechat_open_id = ?", openID).First(&user).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("用户不存在")
		}
		return nil, err
	}
	return &user, nil
}

// FindByWechatUnionID 通过微信UnionID查找用户
func (s *UserService) FindByWechatUnionID(unionID string) (*models.User, error) {
	var user models.User
	err := s.db.Where("wechat_union_id = ?", unionID).First(&user).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("用户不存在")
		}
		return nil, err
	}
	return &user, nil
}

// Create 创建新用户
func (s *UserService) Create(user *models.User) (*models.User, error) {
	err := s.db.Create(user).Error
	if err != nil {
		return nil, err
	}
	return user, nil
}

// Update 更新用户信息
func (s *UserService) Update(user *models.User) (*models.User, error) {
	user.UpdatedAt = time.Now()
	err := s.db.Save(user).Error
	if err != nil {
		return nil, err
	}
	return user, nil
}

// FindByID 通过ID查找用户
func (s *UserService) FindByID(id uint) (*models.User, error) {
	var user models.User
	err := s.db.First(&user, id).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("用户不存在")
		}
		return nil, err
	}
	return &user, nil
}

// FindByUsername 通过用户名查找用户
func (s *UserService) FindByUsername(username string) (*models.User, error) {
	var user models.User
	err := s.db.Where("username = ?", username).First(&user).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("用户不存在")
		}
		return nil, err
	}
	return &user, nil
}

// UpdateLastLogin 更新用户最后登录时间
func (s *UserService) UpdateLastLogin(userID uint) error {
	now := time.Now()
	return s.db.Model(&models.User{}).Where("id = ?", userID).Update("last_login", now).Error
}

// List 获取用户列表
func (s *UserService) List(offset, limit int) ([]*models.User, int64, error) {
	var users []*models.User
	var total int64

	// 获取总数
	err := s.db.Model(&models.User{}).Count(&total).Error
	if err != nil {
		return nil, 0, err
	}

	// 获取分页数据
	err = s.db.Offset(offset).Limit(limit).Find(&users).Error
	if err != nil {
		return nil, 0, err
	}

	return users, total, nil
}

// Delete 删除用户
func (s *UserService) Delete(id uint) error {
	return s.db.Delete(&models.User{}, id).Error
}
