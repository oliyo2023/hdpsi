package models

import (
	"reflect"
	"time"

	"hd_psi/backend/utils"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

// Role 定义系统中的用户角色类型
type Role string

// 系统中的用户角色常量定义
const (
	// Admin 管理员角色，拥有系统的全部权限
	Admin Role = "admin"
	// Manager 店长角色，负责管理单个店铺的运营
	Manager Role = "manager"
	// Staff 普通员工角色，执行日常业务操作
	Staff Role = "staff"
	// Cashier 收银员角色，负责处理销售和收款
	Cashier Role = "cashier"
	// Operator 操作员角色，负责特定的系统操作任务
	Operator Role = "operator"
)

// User 定义系统用户模型，存储用户账户信息和权限
type User struct {
	// ID 用户唯一标识
	ID uint `gorm:"primaryKey"`
	// Username 用户登录名，必须唯一
	Username string `gorm:"size:50;uniqueIndex;not null"`
	// Password 用户密码，存储加密后的哈希值
	Password string `gorm:"size:255;not null"`
	// Name 用户真实姓名
	Name string `gorm:"size:50;not null"`
	// Email 用户电子邮箱
	Email string `gorm:"size:100"`
	// Phone 用户手机号码
	Phone string `gorm:"size:20"`
	// Nickname 用户昵称
	Nickname string `gorm:"size:100"`
	// WechatOpenID 微信开放平台用户唯一标识
	WechatOpenID *string `gorm:"size:128;uniqueIndex;default:null"`
	// WechatUnionID 微信开放平台用户统一标识
	WechatUnionID *string `gorm:"size:128;default:null"`
	// WechatNickname 微信昵称
	WechatNickname string `gorm:"size:100"`
	// WechatAvatar 微信头像URL
	WechatAvatar string `gorm:"size:255"`
	// Role 用户角色，决定用户权限
	Role Role `gorm:"size:20;not null;default:'staff'"`
	// StoreID 用户所属店铺ID，可以为空表示总部人员
	StoreID *uint `gorm:"default:null"`
	// LastLogin 用户最后登录时间
	LastLogin *time.Time
	// Status 用户状态，true表示启用，false表示禁用
	Status bool `gorm:"default:true"`
	// LoginAttempts 登录尝试次数，用于限制登录失败次数
	LoginAttempts int `gorm:"default:0"`
	// LockedUntil 账户锁定时间，如果设置了未来时间，表示账户被临时锁定
	LockedUntil *time.Time
	// RefreshToken 用户刷新令牌，用于延长会话时间
	RefreshToken string `gorm:"size:255"`
	// RefreshTokenExpiresAt 刷新令牌过期时间
	RefreshTokenExpiresAt *time.Time
	// ResetPasswordToken 密码重置令牌
	ResetPasswordToken string `gorm:"size:255"`
	// ResetPasswordExpires 密码重置令牌过期时间
	ResetPasswordExpires *time.Time
	// RememberMe 记住我标志，用于延长会话时间
	RememberMe bool `gorm:"default:false"`
	// CreatedAt 用户创建时间
	CreatedAt time.Time
	// UpdatedAt 用户信息最后更新时间
	UpdatedAt time.Time
}

// BeforeSave 在用户信息保存到数据库前自动加密密码
// 这是 GORM 的钩子函数，在创建或更新用户时自动调用
// 参数：
//   - tx: GORM 数据库事务对象
//
// 返回：
//   - error: 如果加密过程出错则返回错误，否则返回 nil
func (u *User) BeforeSave(tx *gorm.DB) error {
	// 检查是否是新记录（创建操作）
	isNewRecord := !tx.Statement.SkipHooks && (tx.Statement.Schema == nil || tx.Statement.Schema.PrioritizedPrimaryField == nil || tx.Statement.Context == nil || tx.Statement.ReflectValue.Kind() != reflect.Struct || tx.Statement.ReflectValue.FieldByName("ID").Uint() == 0)

	// 检查密码是否被明确更改（密码字段在当前操作中被更新）
	var passwordChanged bool
	if tx.Statement.Changed("Password") {
		passwordChanged = true
	}

	// 只有在新记录或密码被明确更改时才进行密码加密
	if (isNewRecord || passwordChanged) && len(u.Password) > 0 {
		// 检查密码是否已经是哈希值（以$开头的bcrypt哈希值）
		if len(u.Password) < 60 || u.Password[0] != '$' {
			hashedPassword, err := bcrypt.GenerateFromPassword([]byte(u.Password), bcrypt.DefaultCost)
			if err != nil {
				return err
			}
			u.Password = string(hashedPassword)
		}
	}
	return nil
}

// CheckPassword 验证用户密码是否正确
// 将用户输入的原始密码与数据库中存储的加密密码进行比对
// 参数：
//   - password: 用户输入的原始密码
//
// 返回：
//   - bool: 如果密码正确返回 true，否则返回 false
func (u *User) CheckPassword(password string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(u.Password), []byte(password))
	return err == nil
}

// IsLocked 检查用户账户是否被锁定
// 如果用户的锁定时间在当前时间之后，则账户被锁定
// 返回：
//   - bool: 如果账户被锁定返回 true，否则返回 false
//   - time.Duration: 如果账户被锁定，返回还需要等待的时间，否则返回 0
func (u *User) IsLocked() (bool, time.Duration) {
	if u.LockedUntil == nil {
		return false, 0
	}

	now := time.Now()
	if now.Before(*u.LockedUntil) {
		return true, u.LockedUntil.Sub(now)
	}

	return false, 0
}

// IncrementLoginAttempts 增加登录尝试次数
// 如果超过最大尝试次数，则锁定账户
// 参数：
//   - maxAttempts: 最大尝试次数
//   - lockDuration: 锁定时间
//
// 返回：
//   - bool: 如果账户被锁定返回 true，否则返回 false
func (u *User) IncrementLoginAttempts(maxAttempts int, lockDuration time.Duration) bool {
	u.LoginAttempts++

	if u.LoginAttempts >= maxAttempts {
		lockTime := time.Now().Add(lockDuration)
		u.LockedUntil = &lockTime
		return true
	}

	return false
}

// ResetLoginAttempts 重置登录尝试次数
func (u *User) ResetLoginAttempts() {
	u.LoginAttempts = 0
	u.LockedUntil = nil
}

// GeneratePasswordResetToken 生成密码重置令牌
// 参数：
//   - expiresDuration: 令牌过期时间
//
// 返回：
//   - string: 生成的密码重置令牌
func (u *User) GeneratePasswordResetToken(expiresDuration time.Duration) string {
	// 生成随机令牌
	token := utils.GenerateRandomToken(32)

	// 设置过期时间
	expiresAt := time.Now().Add(expiresDuration)
	u.ResetPasswordToken = token
	u.ResetPasswordExpires = &expiresAt

	return token
}

// VerifyPasswordResetToken 验证密码重置令牌
// 参数：
//   - token: 要验证的密码重置令牌
//
// 返回：
//   - bool: 如果令牌有效返回 true，否则返回 false
func (u *User) VerifyPasswordResetToken(token string) bool {
	// 检查令牌是否存在
	if u.ResetPasswordToken == "" || u.ResetPasswordExpires == nil {
		return false
	}

	// 检查令牌是否匹配
	if u.ResetPasswordToken != token {
		return false
	}

	// 检查令牌是否过期
	if time.Now().After(*u.ResetPasswordExpires) {
		return false
	}

	return true
}

// ClearPasswordResetToken 清除密码重置令牌
func (u *User) ClearPasswordResetToken() {
	u.ResetPasswordToken = ""
	u.ResetPasswordExpires = nil
}

// GenerateRefreshToken 生成刷新令牌
// 参数：
//   - expiresDuration: 令牌过期时间
//
// 返回：
//   - string: 生成的刷新令牌
func (u *User) GenerateRefreshToken(expiresDuration time.Duration) string {
	// 生成随机令牌
	token := utils.GenerateRandomToken(32)

	// 设置过期时间
	expiresAt := time.Now().Add(expiresDuration)
	u.RefreshToken = token
	u.RefreshTokenExpiresAt = &expiresAt

	return token
}

// VerifyRefreshToken 验证刷新令牌
// 参数：
//   - token: 要验证的刷新令牌
//
// 返回：
//   - bool: 如果令牌有效返回 true，否则返回 false
func (u *User) VerifyRefreshToken(token string) bool {
	// 检查令牌是否存在
	if u.RefreshToken == "" || u.RefreshTokenExpiresAt == nil {
		return false
	}

	// 检查令牌是否匹配
	if u.RefreshToken != token {
		return false
	}

	// 检查令牌是否过期
	if time.Now().After(*u.RefreshTokenExpiresAt) {
		return false
	}

	return true
}
