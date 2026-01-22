package controllers

import (
	"crypto/sha1"  // Import for SHA-1 hashing
	"encoding/hex" // Import for hex encoding
	"encoding/xml"
	"fmt"
	"io/ioutil"
	"net/http"
	"sort" // Import for sorting
	"strings"

	"hd_psi/backend/config"       // Import config package
	"hd_psi/backend/models"       // Import models package
	"hd_psi/backend/utils/logger" // Import logger package

	"github.com/kataras/iris/v12"
	"gorm.io/gorm"
)

// WechatController 处理微信公众号相关请求
type WechatController struct {
	db *gorm.DB
}

// NewWechatController 创建一个新的 WechatController 实例
func NewWechatController(db *gorm.DB) *WechatController {
	return &WechatController{db: db}
}

// WeChatEventMessage 定义微信服务器推送的事件消息结构
type WeChatEventMessage struct {
	XMLName      xml.Name `xml:"xml"`
	ToUserName   string   `xml:"ToUserName"`
	FromUserName string   `xml:"FromUserName"` // 用户的 OpenID
	CreateTime   int64    `xml:"CreateTime"`
	MsgType      string   `xml:"MsgType"` // 消息类型，event
	Event        string   `xml:"Event"`   // 事件类型，subscribe, unsubscribe, SCAN 等
	EventKey     string   `xml:"EventKey"`
	Ticket       string   `xml:"Ticket"`
}

// HandleWechatEvent 处理微信公众号推送的事件
func (wc *WechatController) HandleWechatEvent(c iris.Context) {
	log := logger.WithContext(c) // Get logger from context

	// 获取微信发送的参数
	signature := c.URLParam("signature")
	timestamp := c.URLParam("timestamp")
	nonce := c.URLParam("nonce")
	echostr := c.URLParam("echostr") // Only for GET requests

	// 获取配置中的 Token
	token := config.GetWechatOfficialAccountConfig().VerifyToken

	// 验证签名
	// 1. 将 token, timestamp, nonce 三个参数进行字典序排序
	// 2. 将三个参数字符串拼接成一个字符串进行 sha1 加密
	// 3. 开发者获得加密后的字符串可与 signature 对比，标识该请求来源于微信
	s := []string{token, timestamp, nonce}
	sort.Strings(s)
	joinedStr := strings.Join(s, "")

	h := sha1.New()
	h.Write([]byte(joinedStr))
	sha1Hash := hex.EncodeToString(h.Sum(nil))

	if sha1Hash != signature {
		log.Warn("微信签名验证失败",
			logger.F("signature", signature),
			logger.F("timestamp", timestamp),
			logger.F("nonce", nonce),
			logger.F("calculated_signature", sha1Hash),
		)
		c.StatusCode(http.StatusUnauthorized)
		c.WriteString("Invalid signature")
		return
	}

	// 签名验证成功
	log.Info("微信签名验证成功")

	// 处理 GET 请求 (用于微信服务器验证 URL 有效性)
	if c.Request().Method == http.MethodGet {
		log.Info("处理微信 URL 验证请求", logger.F("echostr", echostr))
		c.StatusCode(http.StatusOK)
		c.WriteString(echostr)
		return
	}

	// 处理 POST 请求 (接收事件推送)

	// 读取请求体
	body, err := ioutil.ReadAll(c.Request().Body)
	if err != nil {
		log.Error("读取微信请求体失败", logger.F("error", err.Error()))
		c.StatusCode(http.StatusInternalServerError)
		c.WriteString("Error reading request body")
		return
	}

	// 解析 XML 数据
	var msg WeChatEventMessage
	err = xml.Unmarshal(body, &msg)
	if err != nil {
		log.Error("解析微信 XML 数据失败", logger.F("error", err.Error()), logger.F("body", string(body)))
		c.StatusCode(http.StatusBadRequest)
		c.WriteString("Error parsing XML")
		return
	}

	// 检查是否是关注事件
	if msg.MsgType == "event" && msg.Event == "subscribe" {
		log.Info("收到用户关注事件", logger.F("openid", msg.FromUserName))

		// 检查会员是否已存在
		var member models.Member
		result := wc.db.Where("open_id = ?", msg.FromUserName).First(&member)

		if result.Error != nil && result.Error != gorm.ErrRecordNotFound {
			// 查询出错
			log.Error("查询会员失败", logger.F("openid", msg.FromUserName), logger.F("error", result.Error.Error()))
			c.StatusCode(http.StatusInternalServerError)
			c.WriteString("Error checking member")
			return
		}

		if result.RowsAffected == 0 {
			// 会员不存在，创建新会员
			newMember := models.Member{
				OpenID: msg.FromUserName,
				Name:   "微信用户_" + msg.FromUserName[:8], // 设置默认名称
				Level:  models.Regular,                 // 默认普通会员
				Points: 0,
			}

			if err := wc.db.Create(&newMember).Error; err != nil {
				// 创建会员失败
				log.Error("创建新会员失败", logger.F("openid", msg.FromUserName), logger.F("error", err.Error()))
				c.StatusCode(http.StatusInternalServerError)
				c.WriteString("Error creating member")
				return
			}

			log.Info("新会员创建成功", logger.F("openid", msg.FromUserName), logger.F("member_id", newMember.ID))
		} else {
			// 会员已存在
			log.Info("会员已存在", logger.F("openid", msg.FromUserName), logger.F("member_id", member.ID))
		}

		// 返回成功响应给微信服务器
		c.StatusCode(http.StatusOK)
		c.WriteString("success")
	} else {
		// 处理其他类型的消息或事件
		fmt.Printf("收到其他微信消息/事件，MsgType: %s, Event: %s\n", msg.MsgType, msg.Event)
		c.StatusCode(http.StatusOK)
		c.WriteString("success") // 总是返回 success，避免微信重试
	}
}