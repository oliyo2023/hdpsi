package controllers

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"

	"hd_psi/backend/models"
	"hd_psi/backend/services"
	"hd_psi/backend/utils/response"

	"github.com/kataras/iris/v12"
	"gorm.io/gorm"
)

// WechatLoginController 微信登录控制器
type WechatLoginController struct {
	userService *services.UserService
	authService *services.AuthService
}

// NewWechatLoginController 创建微信登录控制器
func NewWechatLoginController(db *gorm.DB) *WechatLoginController {
	return &WechatLoginController{
		userService: services.NewUserServiceWithDB(db),
		authService: services.NewAuthService(),
	}
}

// WechatLoginRequest 微信登录请求
type WechatLoginRequest struct {
	Code string `json:"code"`
}

// WechatUserInfo 微信用户信息
type WechatUserInfo struct {
	OpenID     string `json:"openid"`
	Nickname   string `json:"nickname"`
	Sex        int    `json:"sex"`
	Province   string `json:"province"`
	City       string `json:"city"`
	Country    string `json:"country"`
	HeadImgURL string `json:"headimgurl"`
	UnionID    string `json:"unionid"`
}

// WechatAccessTokenResponse 微信访问令牌响应
type WechatAccessTokenResponse struct {
	AccessToken  string `json:"access_token"`
	ExpiresIn    int    `json:"expires_in"`
	RefreshToken string `json:"refresh_token"`
	OpenID       string `json:"openid"`
	Scope        string `json:"scope"`
	UnionID      string `json:"unionid"`
	ErrCode      int    `json:"errcode"`
	ErrMsg       string `json:"errmsg"`
}

// Login 微信登录
func (wc *WechatLoginController) Login(c iris.Context) {
	var req WechatLoginRequest
	if err := c.ReadJSON(&req); err != nil {
		response.BadRequest(c, "参数错误")
		return
	}
	// 1. 通过code获取access_token
	accessTokenResp, err := wc.getAccessToken(req.Code)
	if err != nil {
		response.InternalError(c, "获取微信访问令牌失败: "+err.Error())
		return
	}

	if accessTokenResp.ErrCode != 0 {
		response.BadRequest(c, "微信授权失败: "+accessTokenResp.ErrMsg)
		return
	}

	// 2. 通过access_token获取用户信息
	userInfo, err := wc.getUserInfo(accessTokenResp.AccessToken, accessTokenResp.OpenID)
	if err != nil {
		response.InternalError(c, "获取微信用户信息失败: "+err.Error())
		return
	}

	// 3. 查找或创建用户
	user, err := wc.findOrCreateUser(userInfo)
	if err != nil {
		response.InternalError(c, "用户处理失败: "+err.Error())
		return
	}

	// 4. 生成JWT令牌
	token, refreshToken, err := wc.authService.GenerateTokens(user.ID)
	if err != nil {
		response.InternalError(c, "生成令牌失败: "+err.Error())
		return
	}

	// 5. 返回登录结果
	response.Success(c, iris.Map{
		"token":         token,
		"refresh_token": refreshToken,
		"user":          user,
	})
}

// getAccessToken 获取微信访问令牌
func (wc *WechatLoginController) getAccessToken(code string) (*WechatAccessTokenResponse, error) {
	// 微信应用配置 - 实际使用时需要从配置文件读取
	appID := "your_wechat_app_id"
	appSecret := "your_wechat_app_secret"

	url := fmt.Sprintf(
		"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%s&secret=%s&code=%s&grant_type=authorization_code",
		appID, appSecret, code,
	)

	resp, err := http.Get(url)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	var tokenResp WechatAccessTokenResponse
	if err := json.Unmarshal(body, &tokenResp); err != nil {
		return nil, err
	}

	return &tokenResp, nil
}

// getUserInfo 获取微信用户信息
func (wc *WechatLoginController) getUserInfo(accessToken, openID string) (*WechatUserInfo, error) {
	url := fmt.Sprintf(
		"https://api.weixin.qq.com/sns/userinfo?access_token=%s&openid=%s&lang=zh_CN",
		accessToken, openID,
	)

	resp, err := http.Get(url)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	var userInfo WechatUserInfo
	if err := json.Unmarshal(body, &userInfo); err != nil {
		return nil, err
	}

	return &userInfo, nil
}

// findOrCreateUser 查找或创建用户
func (wc *WechatLoginController) findOrCreateUser(wechatUser *WechatUserInfo) (*models.User, error) {
	// 首先尝试通过微信OpenID查找用户
	user, err := wc.userService.FindByWechatOpenID(wechatUser.OpenID)
	if err == nil {
		// 用户已存在，更新微信信息
		user.WechatNickname = wechatUser.Nickname
		user.WechatAvatar = wechatUser.HeadImgURL
		user.UpdatedAt = time.Now()
		return wc.userService.Update(user)
	}

	// 用户不存在，创建新用户
	newUser := &models.User{
		Username:       fmt.Sprintf("wx_%s", wechatUser.OpenID[:8]), // 使用OpenID前8位作为用户名
		Nickname:       wechatUser.Nickname,
		WechatOpenID:   &wechatUser.OpenID,
		WechatUnionID:  &wechatUser.UnionID,
		WechatNickname: wechatUser.Nickname,
		WechatAvatar:   wechatUser.HeadImgURL,
		Role:           "user", // 默认角色
		Status:         true,
		CreatedAt:      time.Now(),
		UpdatedAt:      time.Now(),
	}

	return wc.userService.Create(newUser)
}