package models

import (
	"encoding/json"
	"fmt"

	"gorm.io/gorm"
)

// BeforeSave 在保存前处理图片关联
func (p *Product) BeforeSave(tx *gorm.DB) error {
	// 将Images字段转换为JSON字符串存储在ImagesJSON字段
	if len(p.Images) > 0 {
		imagesJSON, err := json.Marshal(p.Images)
		if err != nil {
			return fmt.Errorf("无法序列化图片数组: %w", err)
		}
		p.ImagesJSON = string(imagesJSON)
	} else {
		p.ImagesJSON = "[]"
	}

	// 如果有图片，设置第一张为主图
	if len(p.Images) > 0 && p.Image == "" {
		p.Image = p.Images[0]
	}

	return nil
}

// AfterFind 在查询后处理图片数据
func (p *Product) AfterFind(tx *gorm.DB) error {
	// 从ImagesJSON字段解析图片数组
	if p.ImagesJSON != "" {
		if err := json.Unmarshal([]byte(p.ImagesJSON), &p.Images); err != nil {
			return fmt.Errorf("无法解析图片JSON: %w", err)
		}
	}

	// 如果没有图片但有主图，添加主图到图片数组
	if len(p.Images) == 0 && p.Image != "" {
		p.Images = []string{p.Image}
	}

	return nil
}

// AfterCreate 在创建后处理图片关联
func (p *Product) AfterCreate(tx *gorm.DB) error {
	// 创建商品图片记录
	if len(p.Images) > 0 {
		for i, url := range p.Images {
			image := ProductImage{
				ProductID: p.ID,
				URL:       url,
				Sort:      i,
			}
			if err := tx.Create(&image).Error; err != nil {
				return fmt.Errorf("创建商品图片记录失败: %w", err)
			}
		}
	}
	return nil
}

// AfterUpdate 在更新后处理图片关联
func (p *Product) AfterUpdate(tx *gorm.DB) error {
	// 如果有图片数据，先删除旧的图片关联，再创建新的
	if len(p.Images) > 0 {
		// 删除旧的图片关联
		if err := tx.Where("product_id = ?", p.ID).Delete(&ProductImage{}).Error; err != nil {
			return fmt.Errorf("删除旧的商品图片记录失败: %w", err)
		}

		// 创建新的图片关联
		for i, url := range p.Images {
			image := ProductImage{
				ProductID: p.ID,
				URL:       url,
				Sort:      i,
			}
			if err := tx.Create(&image).Error; err != nil {
				return fmt.Errorf("创建商品图片记录失败: %w", err)
			}
		}
	}
	return nil
}
