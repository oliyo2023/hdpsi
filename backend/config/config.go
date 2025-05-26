package config

import (
	"fmt"
	"log"
	"os"
	"strings"
	"time"

	"github.com/spf13/viper"
)

// Config 全局配置结构体
type Config struct {
	Server                ServerConfig
	API                   APIConfig
	Database              DatabaseConfig
	JWT                   JWTConfig
	Log                   LogConfig
	CORS                  CORSConfig
	WechatOfficialAccount WechatOfficialAccountConfig // 修改这里
}

// APIConfig API配置
type APIConfig struct {
	Version             string // API版本，如 v1
	Prefix              string // API前缀，如 /api
	EnableVersionPrefix bool   // 是否启用版本前缀，如 /api/v1
}

// WechatOfficialAccountConfig 微信公众号配置 (修改结构体名称和字段)
type WechatOfficialAccountConfig struct {
	AppID       string
	AppSecret   string
	RedirectURI string
	Scope       string
	VerifyToken string // 新增
}

// ServerConfig 服务器配置
type ServerConfig struct {
	Port    int
	Mode    string
	Timeout int
}

// DatabaseConfig 数据库配置
type DatabaseConfig struct {
	Type            string `mapstructure:"type"`              // 数据库类型：mysql, sqlite
	SQLitePath      string `mapstructure:"sqlite_path"`       // SQLite数据库文件路径
	Host            string `mapstructure:"host"`              // MySQL主机地址
	Port            string `mapstructure:"port"`              // MySQL端口
	User            string `mapstructure:"user"`              // MySQL用户名
	Password        string `mapstructure:"password"`          // MySQL密码
	Name            string `mapstructure:"name"`              // MySQL数据库名
	Charset         string `mapstructure:"charset"`           // MySQL字符集
	ParseTime       bool   `mapstructure:"parse_time"`        // MySQL是否解析时间
	Loc             string `mapstructure:"loc"`               // MySQL时区
	MaxIdleConns    int    `mapstructure:"max_idle_conns"`    // 最大空闲连接数
	MaxOpenConns    int    `mapstructure:"max_open_conns"`    // 最大打开连接数
	ConnMaxLifetime int    `mapstructure:"conn_max_lifetime"` // 连接最大生命周期
	AutoMigrate     bool   `mapstructure:"auto_migrate"`      // 是否自动迁移数据库模型
}

// JWTConfig JWT配置
type JWTConfig struct {
	Secret     string
	Expiration JWTExpirationConfig
}

// JWTExpirationConfig JWT过期时间配置
type JWTExpirationConfig struct {
	Standard   int
	RememberMe int
	Refresh    int
	Reset      int
}

// LogConfig 日志配置
type LogConfig struct {
	Level      string // 日志级别：debug, info, warn, error
	Format     string // 日志格式：text, json
	Output     string // 日志输出：stdout, file, both
	Directory  string // 日志目录
	Filename   string // 日志文件名
	MaxSize    int    // 单个日志文件最大大小（MB）
	MaxAge     int    // 日志文件保留天数
	MaxBackups int    // 最大备份数量
	Compress   bool   // 是否压缩
}

// CORSConfig CORS配置
type CORSConfig struct {
	AllowedOrigins   []string
	AllowedMethods   []string
	AllowedHeaders   []string
	ExposedHeaders   []string
	AllowCredentials bool
	MaxAge           int
}

// 全局配置变量
var AppConfig Config

// InitConfig 初始化配置
func InitConfig() {
	// 设置配置文件名
	viper.SetConfigName("config")
	// 设置配置文件类型
	viper.SetConfigType("yaml")
	// 添加配置文件路径
	viper.AddConfigPath("./config")
	// 添加当前目录作为配置文件路径
	viper.AddConfigPath(".")

	// 设置环境变量前缀
	viper.SetEnvPrefix("HD_PSI")
	// 使用环境变量替换配置
	viper.AutomaticEnv()
	// 将环境变量中的下划线转换为点号
	viper.SetEnvKeyReplacer(strings.NewReplacer(".", "_"))

	// 读取配置文件
	err := viper.ReadInConfig()
	if err != nil {
		// 如果找不到配置文件，创建默认配置文件
		if _, ok := err.(viper.ConfigFileNotFoundError); ok {
			log.Println("未找到配置文件，使用默认配置")
			// 设置默认值
			setDefaultConfig()
			// 创建配置目录
			if err := os.MkdirAll("./config", 0755); err != nil {
				log.Fatalf("创建配置目录失败: %v", err)
			}
			// 保存默认配置到文件
			if err := viper.SafeWriteConfigAs("./config/config.yaml"); err != nil {
				log.Fatalf("保存默认配置文件失败: %v", err)
			}
			log.Println("已创建默认配置文件: ./config/config.yaml")
		} else {
			log.Fatalf("读取配置文件失败: %v", err)
		}
	} else {
		log.Printf("使用配置文件: %s\n", viper.ConfigFileUsed())
	}

	// 将配置映射到结构体
	if err := viper.Unmarshal(&AppConfig); err != nil {
		log.Fatalf("解析配置文件失败: %v", err)
	}

	// 确保数据库自动迁移设置被正确读取
	AppConfig.Database.AutoMigrate = viper.GetBool("database.auto_migrate")
	log.Printf("数据库自动迁移设置: %v\n", AppConfig.Database.AutoMigrate)
}

// setDefaultConfig 设置默认配置
func setDefaultConfig() {
	// 服务器配置
	viper.SetDefault("server.port", 8080)
	viper.SetDefault("server.mode", "debug")
	viper.SetDefault("server.timeout", 30)

	// API配置
	viper.SetDefault("api.version", "v1")
	viper.SetDefault("api.prefix", "/api")
	viper.SetDefault("api.enable_version_prefix", true)

	// 数据库配置
	viper.SetDefault("database.type", "sqlite")
	viper.SetDefault("database.sqlite_path", "./data/hd_psi.db")
	viper.SetDefault("database.host", "192.168.1.5")
	viper.SetDefault("database.port", "3306")
	viper.SetDefault("database.user", "root")
	viper.SetDefault("database.password", "gemini4094")
	viper.SetDefault("database.name", "hd_psi_dev")
	viper.SetDefault("database.charset", "utf8mb4")
	viper.SetDefault("database.parse_time", true)
	viper.SetDefault("database.loc", "Local")
	viper.SetDefault("database.max_idle_conns", 10)
	viper.SetDefault("database.max_open_conns", 100)
	viper.SetDefault("database.conn_max_lifetime", 3600)
	viper.SetDefault("database.auto_migrate", true) // SQLite默认自动迁移

	// JWT配置
	viper.SetDefault("jwt.secret", "hd_psi_secret_key")
	viper.SetDefault("jwt.expiration.standard", 86400)     // 24小时
	viper.SetDefault("jwt.expiration.remember_me", 604800) // 7天
	viper.SetDefault("jwt.expiration.refresh", 2592000)    // 30天
	viper.SetDefault("jwt.expiration.reset", 3600)         // 1小时

	// 日志配置
	viper.SetDefault("log.level", "info")
	viper.SetDefault("log.format", "text")
	viper.SetDefault("log.output", "both")
	viper.SetDefault("log.directory", "./logs")
	viper.SetDefault("log.filename", "hd_psi.log")
	viper.SetDefault("log.max_size", 100)
	viper.SetDefault("log.max_age", 30)
	viper.SetDefault("log.max_backups", 10)
	viper.SetDefault("log.compress", true)

	// CORS配置
	viper.SetDefault("cors.allowed_origins", []string{"*"})
	viper.SetDefault("cors.allowed_methods", []string{"GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"})
	viper.SetDefault("cors.allowed_headers", []string{"Origin", "Content-Type", "Content-Length", "Accept-Encoding", "X-CSRF-Token", "Authorization"})
	viper.SetDefault("cors.exposed_headers", []string{"Content-Length"})
	viper.SetDefault("cors.allow_credentials", true)
	viper.SetDefault("cors.max_age", 86400)

	// 微信公众号配置 (修改这里)
	viper.SetDefault("wechat_official_account.appid", "your_default_appid")
	viper.SetDefault("wechat_official_account.appsecret", "your_default_appsecret")
	viper.SetDefault("wechat_official_account.redirect_uri", "http://localhost:8081/api/v1/auth/wechat_callback")
	viper.SetDefault("wechat_official_account.scope", "snsapi_userinfo")
	viper.SetDefault("wechat_official_account.verify_token", "your_default_verify_token") // 新增
}

// GetDBConfig 获取数据库连接配置
func GetDBConfig() (string, string) {
	// 如果配置未初始化，则初始化配置
	if AppConfig.Database.Type == "" {
		InitConfig()
	}

	dbType := AppConfig.Database.Type
	var dsn string

	switch dbType {
	case "sqlite":
		dsn = AppConfig.Database.SQLitePath
	case "mysql":
		// 构建MySQL DSN连接字符串
		// 确保parseTime=true以正确处理datetime类型
		dsn = fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?charset=%s&parseTime=true&loc=%s",
			AppConfig.Database.User,
			AppConfig.Database.Password,
			AppConfig.Database.Host,
			AppConfig.Database.Port,
			AppConfig.Database.Name,
			AppConfig.Database.Charset,
			AppConfig.Database.Loc)
	default:
		// 默认使用SQLite
		dbType = "sqlite"
		dsn = "./data/hd_psi.db"
	}

	return dbType, dsn
}

// GetJWTSecret 获取JWT密钥
func GetJWTSecret() []byte {
	// 如果配置未初始化，则初始化配置
	if AppConfig.JWT.Secret == "" {
		InitConfig()
	}

	return []byte(AppConfig.JWT.Secret)
}

// GetJWTExpiration 获取JWT过期时间
func GetJWTExpiration(rememberMe bool) time.Duration {
	// 如果配置未初始化，则初始化配置
	if AppConfig.JWT.Expiration.Standard == 0 {
		InitConfig()
	}

	if rememberMe {
		return time.Duration(AppConfig.JWT.Expiration.RememberMe) * time.Second
	}
	return time.Duration(AppConfig.JWT.Expiration.Standard) * time.Second
}

// GetRefreshTokenExpiration 获取刷新令牌过期时间
func GetRefreshTokenExpiration() time.Duration {
	// 如果配置未初始化，则初始化配置
	if AppConfig.JWT.Expiration.Refresh == 0 {
		InitConfig()
	}

	return time.Duration(AppConfig.JWT.Expiration.Refresh) * time.Second
}

// GetResetTokenExpiration 获取密码重置令牌过期时间
func GetResetTokenExpiration() time.Duration {
	// 如果配置未初始化，则初始化配置
	if AppConfig.JWT.Expiration.Reset == 0 {
		InitConfig()
	}

	return time.Duration(AppConfig.JWT.Expiration.Reset) * time.Second
}

// GetServerPort 获取服务器端口
func GetServerPort() string {
	// 如果配置未初始化，则初始化配置
	if AppConfig.Server.Port == 0 {
		InitConfig()
	}

	return fmt.Sprintf(":%d", AppConfig.Server.Port)
}

// GetServerMode 获取服务器模式
func GetServerMode() string {
	// 如果配置未初始化，则初始化配置
	if AppConfig.Server.Mode == "" {
		InitConfig()
	}

	return AppConfig.Server.Mode
}

// GetCORSConfig 获取CORS配置
func GetCORSConfig() CORSConfig {
	// 如果配置未初始化，则初始化配置
	if len(AppConfig.CORS.AllowedOrigins) == 0 {
		InitConfig()
	}

	return AppConfig.CORS
}

// GetWechatOfficialAccountConfig 获取微信公众号配置 (新增 Getter)
func GetWechatOfficialAccountConfig() WechatOfficialAccountConfig {
	if AppConfig.WechatOfficialAccount.AppID == "" {
		InitConfig()
	}
	return AppConfig.WechatOfficialAccount
}

// GetAPIBasePath 获取API基础路径
func GetAPIBasePath() string {
	// 如果配置未初始化，则初始化配置
	if AppConfig.API.Prefix == "" {
		InitConfig()
	}

	if AppConfig.API.EnableVersionPrefix {
		return fmt.Sprintf("%s/%s", AppConfig.API.Prefix, AppConfig.API.Version)
	}
	return AppConfig.API.Prefix
}

// GetAPIVersion 获取API版本
func GetAPIVersion() string {
	// 如果配置未初始化，则初始化配置
	if AppConfig.API.Version == "" {
		InitConfig()
	}
	return AppConfig.API.Version
}
