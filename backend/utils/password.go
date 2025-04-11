package utils

import (
	"golang.org/x/crypto/bcrypt"
)

// HashPassword 对密码进行bcrypt哈希处理
// 参数：
//   - password: 要哈希的原始密码
//
// 返回：
//   - string: 哈希后的密码
//   - error: 如果哈希过程出错则返回错误，否则返回nil
func HashPassword(password string) (string, error) {
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return "", err
	}
	return string(hashedPassword), nil
}

// CheckPasswordHash 验证密码是否与哈希值匹配
// 参数：
//   - password: 原始密码
//   - hash: 哈希值
//
// 返回：
//   - bool: 如果密码与哈希值匹配返回true，否则返回false
func CheckPasswordHash(password, hash string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
	return err == nil
}
