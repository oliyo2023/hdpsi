package controllers

import (
	"hd_psi/backend/models"
	"net/http"

	"github.com/kataras/iris/v12"
	"gorm.io/gorm"
)

// DictionaryController 字典管理控制器
type DictionaryController struct {
	db *gorm.DB
}

// NewDictionaryController 创建字典控制器
func NewDictionaryController(db *gorm.DB) *DictionaryController {
	return &DictionaryController{db: db}
}

// ListDictionaries 获取字典类型列表
func (dc *DictionaryController) ListDictionaries(ctx iris.Context) {
	var dictionaries []models.Dictionary
	if err := dc.db.Find(&dictionaries).Error; err != nil {
		ctx.StatusCode(http.StatusInternalServerError)
		ctx.JSON(map[string]interface{}{"error": "获取字典类型列表失败: " + err.Error()})
		return
	}
	ctx.StatusCode(http.StatusOK)
	ctx.JSON(map[string]interface{}{"data": dictionaries})
}

// GetDictionary 获取字典类型详情
func (dc *DictionaryController) GetDictionary(ctx iris.Context) {
	code := ctx.Params().Get("code")
	var dictionary models.Dictionary
	if err := dc.db.Where("code = ?", code).First(&dictionary).Error; err != nil {
		ctx.StatusCode(http.StatusNotFound)
		ctx.JSON(map[string]interface{}{"error": "字典类型不存在"})
		return
	}
	ctx.StatusCode(http.StatusOK)
	ctx.JSON(map[string]interface{}{"data": dictionary})
}

// CreateDictionary 创建字典类型
func (dc *DictionaryController) CreateDictionary(ctx iris.Context) {
	var dictionary models.Dictionary
	if err := ctx.ReadJSON(&dictionary); err != nil {
		ctx.StatusCode(http.StatusBadRequest)
		ctx.JSON(map[string]interface{}{"error": "请求数据无效: " + err.Error()})
		return
	}

	// 检查编码是否已存在
	var existingDict models.Dictionary
	if err := dc.db.Where("code = ?", dictionary.Code).First(&existingDict).Error; err == nil {
		ctx.StatusCode(http.StatusBadRequest)
		ctx.JSON(map[string]interface{}{"error": "字典类型编码已存在"})
		return
	}

	if err := dc.db.Create(&dictionary).Error; err != nil {
		ctx.StatusCode(http.StatusInternalServerError)
		ctx.JSON(map[string]interface{}{"error": "创建字典类型失败: " + err.Error()})
		return
	}

	ctx.StatusCode(http.StatusCreated)
	ctx.JSON(map[string]interface{}{"data": dictionary})
}

// UpdateDictionary 更新字典类型
func (dc *DictionaryController) UpdateDictionary(ctx iris.Context) {
	code := ctx.Params().Get("code")
	var dictionary models.Dictionary
	if err := dc.db.Where("code = ?", code).First(&dictionary).Error; err != nil {
		ctx.StatusCode(http.StatusNotFound)
		ctx.JSON(map[string]interface{}{"error": "字典类型不存在"})
		return
	}

	var updateData models.Dictionary
	if err := ctx.ReadJSON(&updateData); err != nil {
		ctx.StatusCode(http.StatusBadRequest)
		ctx.JSON(map[string]interface{}{"error": "请求数据无效: " + err.Error()})
		return
	}

	// 不允许修改编码
	updateData.Code = dictionary.Code

	if err := dc.db.Model(&dictionary).Updates(updateData).Error; err != nil {
		ctx.StatusCode(http.StatusInternalServerError)
		ctx.JSON(map[string]interface{}{"error": "更新字典类型失败: " + err.Error()})
		return
	}

	ctx.StatusCode(http.StatusOK)
	ctx.JSON(map[string]interface{}{"data": dictionary})
}

// DeleteDictionary 删除字典类型
func (dc *DictionaryController) DeleteDictionary(ctx iris.Context) {
	code := ctx.Params().Get("code")

	// 检查是否有关联的字典项
	var count int64
	if err := dc.db.Model(&models.DictionaryItem{}).Where("dictionary_code = ?", code).Count(&count).Error; err != nil {
		ctx.StatusCode(http.StatusInternalServerError)
		ctx.JSON(map[string]interface{}{"error": "检查字典项失败: " + err.Error()})
		return
	}

	if count > 0 {
		ctx.StatusCode(http.StatusBadRequest)
		ctx.JSON(map[string]interface{}{"error": "该字典类型下有字典项，无法删除"})
		return
	}

	if err := dc.db.Where("code = ?", code).Delete(&models.Dictionary{}).Error; err != nil {
		ctx.StatusCode(http.StatusInternalServerError)
		ctx.JSON(map[string]interface{}{"error": "删除字典类型失败: " + err.Error()})
		return
	}

	ctx.StatusCode(http.StatusOK)
	ctx.JSON(map[string]interface{}{"message": "字典类型删除成功"})
}

// ListDictionaryItems 获取字典项列表
func (dc *DictionaryController) ListDictionaryItems(ctx iris.Context) {
	code := ctx.Params().Get("code")

	// 检查字典类型是否存在
	var dictionary models.Dictionary
	if err := dc.db.Where("code = ?", code).First(&dictionary).Error; err != nil {
		ctx.StatusCode(http.StatusNotFound)
		ctx.JSON(map[string]interface{}{"error": "字典类型不存在"})
		return
	}

	var items []models.DictionaryItem
	if err := dc.db.Where("dictionary_code = ?", code).Order("sort").Find(&items).Error; err != nil {
		ctx.StatusCode(http.StatusInternalServerError)
		ctx.JSON(map[string]interface{}{"error": "获取字典项列表失败: " + err.Error()})
		return
	}

	ctx.StatusCode(http.StatusOK)
	ctx.JSON(map[string]interface{}{"data": items})
}

// GetDictionaryItem 获取字典项详情
func (dc *DictionaryController) GetDictionaryItem(ctx iris.Context) {
	code := ctx.Params().Get("code")
	itemID := ctx.Params().Get("itemId")

	var item models.DictionaryItem
	if err := dc.db.Where("dictionary_code = ? AND id = ?", code, itemID).First(&item).Error; err != nil {
		ctx.StatusCode(http.StatusNotFound)
		ctx.JSON(map[string]interface{}{"error": "字典项不存在"})
		return
	}

	ctx.StatusCode(http.StatusOK)
	ctx.JSON(map[string]interface{}{"data": item})
}

// CreateDictionaryItem 创建字典项
func (dc *DictionaryController) CreateDictionaryItem(ctx iris.Context) {
	code := ctx.Params().Get("code")

	// 检查字典类型是否存在
	var dictionary models.Dictionary
	if err := dc.db.Where("code = ?", code).First(&dictionary).Error; err != nil {
		ctx.StatusCode(http.StatusNotFound)
		ctx.JSON(map[string]interface{}{"error": "字典类型不存在"})
		return
	}

	var item models.DictionaryItem
	if err := ctx.ReadJSON(&item); err != nil {
		ctx.StatusCode(http.StatusBadRequest)
		ctx.JSON(map[string]interface{}{"error": "请求数据无效: " + err.Error()})
		return
	}

	// 设置字典类型编码
	item.DictionaryCode = code

	// 检查编码是否已存在
	var existingItem models.DictionaryItem
	if err := dc.db.Where("dictionary_code = ? AND code = ?", code, item.Code).First(&existingItem).Error; err == nil {
		ctx.StatusCode(http.StatusBadRequest)
		ctx.JSON(map[string]interface{}{"error": "字典项编码已存在"})
		return
	}

	if err := dc.db.Create(&item).Error; err != nil {
		ctx.StatusCode(http.StatusInternalServerError)
		ctx.JSON(map[string]interface{}{"error": "创建字典项失败: " + err.Error()})
		return
	}

	ctx.StatusCode(http.StatusCreated)
	ctx.JSON(map[string]interface{}{"data": item})
}

// UpdateDictionaryItem 更新字典项
func (dc *DictionaryController) UpdateDictionaryItem(ctx iris.Context) {
	code := ctx.Params().Get("code")
	itemID := ctx.Params().Get("itemId")

	var item models.DictionaryItem
	if err := dc.db.Where("dictionary_code = ? AND id = ?", code, itemID).First(&item).Error; err != nil {
		ctx.StatusCode(http.StatusNotFound)
		ctx.JSON(map[string]interface{}{"error": "字典项不存在"})
		return
	}

	var updateData models.DictionaryItem
	if err := ctx.ReadJSON(&updateData); err != nil {
		ctx.StatusCode(http.StatusBadRequest)
		ctx.JSON(map[string]interface{}{"error": "请求数据无效: " + err.Error()})
		return
	}

	// 不允许修改字典类型编码
	updateData.DictionaryCode = code

	// 检查编码是否已存在（如果修改了编码）
	if updateData.Code != item.Code {
		var existingItem models.DictionaryItem
		if err := dc.db.Where("dictionary_code = ? AND code = ? AND id != ?", code, updateData.Code, itemID).First(&existingItem).Error; err == nil {
			ctx.StatusCode(http.StatusBadRequest)
			ctx.JSON(map[string]interface{}{"error": "字典项编码已存在"})
			return
		}
	}

	if err := dc.db.Model(&item).Updates(updateData).Error; err != nil {
		ctx.StatusCode(http.StatusInternalServerError)
		ctx.JSON(map[string]interface{}{"error": "更新字典项失败: " + err.Error()})
		return
	}

	ctx.StatusCode(http.StatusOK)
	ctx.JSON(map[string]interface{}{"data": item})
}

// DeleteDictionaryItem 删除字典项
func (dc *DictionaryController) DeleteDictionaryItem(ctx iris.Context) {
	code := ctx.Params().Get("code")
	itemID := ctx.Params().Get("itemId")

	// 检查是否有关联的数据
	// TODO: 根据实际情况检查是否有关联数据

	if err := dc.db.Where("dictionary_code = ? AND id = ?", code, itemID).Delete(&models.DictionaryItem{}).Error; err != nil {
		ctx.StatusCode(http.StatusInternalServerError)
		ctx.JSON(map[string]interface{}{"error": "删除字典项失败: " + err.Error()})
		return
	}

	ctx.StatusCode(http.StatusOK)
	ctx.JSON(map[string]interface{}{"message": "字典项删除成功"})
}

// InitDefaultDictionaries 初始化默认字典数据
func (dc *DictionaryController) InitDefaultDictionaries() error {
	// 开始事务
	tx := dc.db.Begin()

	// 1. 商品类别
	categoryDict := models.Dictionary{
		Code:        models.DictCategory,
		Name:        "商品类别",
		Description: "商品分类",
		Sort:        1,
		Status:      true,
	}
	if err := tx.Where("code = ?", categoryDict.Code).FirstOrCreate(&categoryDict).Error; err != nil {
		tx.Rollback()
		return err
	}

	categoryItems := []models.DictionaryItem{
		{DictionaryCode: models.DictCategory, Code: "coat", Name: "外套", Sort: 1, Status: true},
		{DictionaryCode: models.DictCategory, Code: "pants", Name: "裤装", Sort: 2, Status: true},
		{DictionaryCode: models.DictCategory, Code: "shirt", Name: "衬衫", Sort: 3, Status: true},
		{DictionaryCode: models.DictCategory, Code: "tshirt", Name: "T恤", Sort: 4, Status: true},
		{DictionaryCode: models.DictCategory, Code: "underwear", Name: "内衣", Sort: 5, Status: true},
		{DictionaryCode: models.DictCategory, Code: "accessory", Name: "配饰", Sort: 6, Status: true},
	}
	for _, item := range categoryItems {
		if err := tx.Where("dictionary_code = ? AND code = ?", item.DictionaryCode, item.Code).FirstOrCreate(&item).Error; err != nil {
			tx.Rollback()
			return err
		}
	}

	// 2. 颜色
	colorDict := models.Dictionary{
		Code:        models.DictColor,
		Name:        "颜色",
		Description: "商品颜色",
		Sort:        2,
		Status:      true,
	}
	if err := tx.Where("code = ?", colorDict.Code).FirstOrCreate(&colorDict).Error; err != nil {
		tx.Rollback()
		return err
	}

	colorItems := []models.DictionaryItem{
		{DictionaryCode: models.DictColor, Code: "black", Name: "黑色", Color: "#000000", Sort: 1, Status: true},
		{DictionaryCode: models.DictColor, Code: "white", Name: "白色", Color: "#FFFFFF", Sort: 2, Status: true},
		{DictionaryCode: models.DictColor, Code: "red", Name: "红色", Color: "#FF0000", Sort: 3, Status: true},
		{DictionaryCode: models.DictColor, Code: "blue", Name: "蓝色", Color: "#0000FF", Sort: 4, Status: true},
		{DictionaryCode: models.DictColor, Code: "green", Name: "绿色", Color: "#00FF00", Sort: 5, Status: true},
		{DictionaryCode: models.DictColor, Code: "yellow", Name: "黄色", Color: "#FFFF00", Sort: 6, Status: true},
		{DictionaryCode: models.DictColor, Code: "purple", Name: "紫色", Color: "#800080", Sort: 7, Status: true},
		{DictionaryCode: models.DictColor, Code: "pink", Name: "粉色", Color: "#FFC0CB", Sort: 8, Status: true},
		{DictionaryCode: models.DictColor, Code: "gray", Name: "灰色", Color: "#808080", Sort: 9, Status: true},
		{DictionaryCode: models.DictColor, Code: "brown", Name: "棕色", Color: "#A52A2A", Sort: 10, Status: true},
	}
	for _, item := range colorItems {
		if err := tx.Where("dictionary_code = ? AND code = ?", item.DictionaryCode, item.Code).FirstOrCreate(&item).Error; err != nil {
			tx.Rollback()
			return err
		}
	}

	// 3. 尺码
	sizeDict := models.Dictionary{
		Code:        models.DictSize,
		Name:        "尺码",
		Description: "商品尺码",
		Sort:        3,
		Status:      true,
	}
	if err := tx.Where("code = ?", sizeDict.Code).FirstOrCreate(&sizeDict).Error; err != nil {
		tx.Rollback()
		return err
	}

	sizeItems := []models.DictionaryItem{
		{DictionaryCode: models.DictSize, Code: "xs", Name: "XS", Sort: 1, Status: true},
		{DictionaryCode: models.DictSize, Code: "s", Name: "S", Sort: 2, Status: true},
		{DictionaryCode: models.DictSize, Code: "m", Name: "M", Sort: 3, Status: true},
		{DictionaryCode: models.DictSize, Code: "l", Name: "L", Sort: 4, Status: true},
		{DictionaryCode: models.DictSize, Code: "xl", Name: "XL", Sort: 5, Status: true},
		{DictionaryCode: models.DictSize, Code: "xxl", Name: "XXL", Sort: 6, Status: true},
		{DictionaryCode: models.DictSize, Code: "free", Name: "均码", Sort: 7, Status: true},
	}
	for _, item := range sizeItems {
		if err := tx.Where("dictionary_code = ? AND code = ?", item.DictionaryCode, item.Code).FirstOrCreate(&item).Error; err != nil {
			tx.Rollback()
			return err
		}
	}

	// 4. 季节
	seasonDict := models.Dictionary{
		Code:        models.DictSeason,
		Name:        "季节",
		Description: "商品适用季节",
		Sort:        4,
		Status:      true,
	}
	if err := tx.Where("code = ?", seasonDict.Code).FirstOrCreate(&seasonDict).Error; err != nil {
		tx.Rollback()
		return err
	}

	seasonItems := []models.DictionaryItem{
		{DictionaryCode: models.DictSeason, Code: "spring", Name: "春季", Sort: 1, Status: true},
		{DictionaryCode: models.DictSeason, Code: "summer", Name: "夏季", Sort: 2, Status: true},
		{DictionaryCode: models.DictSeason, Code: "autumn", Name: "秋季", Sort: 3, Status: true},
		{DictionaryCode: models.DictSeason, Code: "winter", Name: "冬季", Sort: 4, Status: true},
		{DictionaryCode: models.DictSeason, Code: "all", Name: "四季", Sort: 5, Status: true},
	}
	for _, item := range seasonItems {
		if err := tx.Where("dictionary_code = ? AND code = ?", item.DictionaryCode, item.Code).FirstOrCreate(&item).Error; err != nil {
			tx.Rollback()
			return err
		}
	}

	// 5. 品牌
	brandDict := models.Dictionary{
		Code:        models.DictBrand,
		Name:        "品牌",
		Description: "商品品牌",
		Sort:        5,
		Status:      true,
	}
	if err := tx.Where("code = ?", brandDict.Code).FirstOrCreate(&brandDict).Error; err != nil {
		tx.Rollback()
		return err
	}

	brandItems := []models.DictionaryItem{
		{DictionaryCode: models.DictBrand, Code: "brand1", Name: "品牌1", Sort: 1, Status: true},
		{DictionaryCode: models.DictBrand, Code: "brand2", Name: "品牌2", Sort: 2, Status: true},
		{DictionaryCode: models.DictBrand, Code: "brand3", Name: "品牌3", Sort: 3, Status: true},
	}
	for _, item := range brandItems {
		if err := tx.Where("dictionary_code = ? AND code = ?", item.DictionaryCode, item.Code).FirstOrCreate(&item).Error; err != nil {
			tx.Rollback()
			return err
		}
	}

	// 6. 面料
	fabricDict := models.Dictionary{
		Code:        models.DictFabric,
		Name:        "面料",
		Description: "商品面料",
		Sort:        6,
		Status:      true,
	}
	if err := tx.Where("code = ?", fabricDict.Code).FirstOrCreate(&fabricDict).Error; err != nil {
		tx.Rollback()
		return err
	}

	fabricItems := []models.DictionaryItem{
		{DictionaryCode: models.DictFabric, Code: "cotton", Name: "棉", Sort: 1, Status: true},
		{DictionaryCode: models.DictFabric, Code: "linen", Name: "麻", Sort: 2, Status: true},
		{DictionaryCode: models.DictFabric, Code: "silk", Name: "丝", Sort: 3, Status: true},
		{DictionaryCode: models.DictFabric, Code: "wool", Name: "毛", Sort: 4, Status: true},
		{DictionaryCode: models.DictFabric, Code: "polyester", Name: "涤纶", Sort: 5, Status: true},
		{DictionaryCode: models.DictFabric, Code: "denim", Name: "牛仔", Sort: 6, Status: true},
	}
	for _, item := range fabricItems {
		if err := tx.Where("dictionary_code = ? AND code = ?", item.DictionaryCode, item.Code).FirstOrCreate(&item).Error; err != nil {
			tx.Rollback()
			return err
		}
	}

	// 提交事务
	return tx.Commit().Error
}