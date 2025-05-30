package services

import (
	"errors"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

// AuthService 认证服务
type AuthService struct {
	// JWT密钥，实际项目中应该从配置文件读取
	jwtSecret []byte
}

// NewAuthService 创建认证服务实例
func NewAuthService() *AuthService {
	return &AuthService{
		// 实际项目中应该从配置文件读取
		jwtSecret: []byte("your-secret-key-here"),
	}
}

// Claims JWT声明结构
type Claims struct {
	UserID uint `json:"user_id"`
	jwt.RegisteredClaims
}

// GenerateTokens 生成访问令牌和刷新令牌
func (s *AuthService) GenerateTokens(userID uint) (string, string, error) {
	// 生成访问令牌（有效期2小时）
	accessToken, err := s.generateToken(userID, 2*time.Hour)
	if err != nil {
		return "", "", err
	}

	// 生成刷新令牌（有效期7天）
	refreshToken, err := s.generateToken(userID, 7*24*time.Hour)
	if err != nil {
		return "", "", err
	}

	return accessToken, refreshToken, nil
}

// generateToken 生成JWT令牌
func (s *AuthService) generateToken(userID uint, duration time.Duration) (string, error) {
	claims := &Claims{
		UserID: userID,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(duration)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			NotBefore: jwt.NewNumericDate(time.Now()),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(s.jwtSecret)
}

// ValidateToken 验证JWT令牌
func (s *AuthService) ValidateToken(tokenString string) (*Claims, error) {
	token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
		return s.jwtSecret, nil
	})

	if err != nil {
		return nil, err
	}

	if claims, ok := token.Claims.(*Claims); ok && token.Valid {
		return claims, nil
	}

	return nil, errors.New("无效的令牌")
}

// RefreshToken 刷新访问令牌
func (s *AuthService) RefreshToken(refreshTokenString string) (string, error) {
	claims, err := s.ValidateToken(refreshTokenString)
	if err != nil {
		return "", err
	}

	// 生成新的访问令牌
	return s.generateToken(claims.UserID, 2*time.Hour)
}
