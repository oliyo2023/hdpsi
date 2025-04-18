package services

import (
	"github.com/casbin/casbin/v2"
	gormadapter "github.com/casbin/gorm-adapter/v3"
	"gorm.io/gorm"
)

// CasbinService 提供基于Casbin的权限管理服务
type CasbinService struct {
	enforcer *casbin.Enforcer
	db       *gorm.DB
}

// NewCasbinService 创建一个新的CasbinService实例
func NewCasbinService(db *gorm.DB) *CasbinService {
	// 使用GORM适配器
	adapter, _ := gormadapter.NewAdapterByDB(db)
	
	// 创建enforcer
	enforcer, _ := casbin.NewEnforcer("config/rbac_model.conf", adapter)
	
	// 加载策略
	enforcer.LoadPolicy()
	
	return &CasbinService{
		enforcer: enforcer,
		db:       db,
	}
}

// GetEnforcer 获取Casbin enforcer实例
func (s *CasbinService) GetEnforcer() *casbin.Enforcer {
	return s.enforcer
}

// AddPolicy 添加策略
func (s *CasbinService) AddPolicy(sub, obj, act string) (bool, error) {
	return s.enforcer.AddPolicy(sub, obj, act)
}

// RemovePolicy 删除策略
func (s *CasbinService) RemovePolicy(sub, obj, act string) (bool, error) {
	return s.enforcer.RemovePolicy(sub, obj, act)
}

// Enforce 检查权限
func (s *CasbinService) Enforce(sub, obj, act string) (bool, error) {
	return s.enforcer.Enforce(sub, obj, act)
}

// GetAllPolicies 获取所有策略
func (s *CasbinService) GetAllPolicies() [][]string {
	return s.enforcer.GetPolicy()
}

// AddRoleForUser 为用户添加角色
func (s *CasbinService) AddRoleForUser(user, role string) (bool, error) {
	return s.enforcer.AddRoleForUser(user, role)
}

// DeleteRoleForUser 删除用户的角色
func (s *CasbinService) DeleteRoleForUser(user, role string) (bool, error) {
	return s.enforcer.DeleteRoleForUser(user, role)
}

// GetRolesForUser 获取用户的所有角色
func (s *CasbinService) GetRolesForUser(user string) ([]string, error) {
	return s.enforcer.GetRolesForUser(user)
}

// GetUsersForRole 获取具有指定角色的所有用户
func (s *CasbinService) GetUsersForRole(role string) ([]string, error) {
	return s.enforcer.GetUsersForRole(role)
}

// HasRoleForUser 检查用户是否具有指定角色
func (s *CasbinService) HasRoleForUser(user, role string) (bool, error) {
	return s.enforcer.HasRoleForUser(user, role)
}

// GetAllRoles 获取所有角色
func (s *CasbinService) GetAllRoles() []string {
	return s.enforcer.GetAllRoles()
}

// GetPermissionsForUser 获取用户的所有权限
func (s *CasbinService) GetPermissionsForUser(user string) [][]string {
	return s.enforcer.GetPermissionsForUser(user)
}

// GetPermissionsForRole 获取角色的所有权限
func (s *CasbinService) GetPermissionsForRole(role string) [][]string {
	return s.enforcer.GetPermissionsForRole(role)
}
