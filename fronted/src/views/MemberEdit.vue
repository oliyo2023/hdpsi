<template>
  <div class="member-edit">
    <div class="page-header">
      <div class="header-left">
        <n-icon size="24" class="header-icon">
          <PersonOutline />
        </n-icon>
        <div>
          <h1 class="page-title">编辑会员</h1>
          <p class="page-subtitle">修改会员信息</p>
        </div>
      </div>
      <div class="header-actions">
        <n-space>
          <n-button @click="goBack" class="btn-cancel">
            <template #icon>
              <n-icon><ArrowBackOutline /></n-icon>
            </template>
            返回
          </n-button>
          <n-button type="primary" @click="handleSave" :loading="saving" class="btn-save">
            <template #icon>
              <n-icon><SaveOutline /></n-icon>
            </template>
            保存
          </n-button>
        </n-space>
      </div>
    </div>

    <div class="page-content">
      <n-spin :show="loading">
        <n-card title="基本信息" class="form-card">
          <n-form
            ref="formRef"
            :model="formData"
            :rules="rules"
            label-placement="left"
            label-width="auto"
            require-mark-placement="right-hanging"
          >
            <n-grid :cols="24" :x-gap="24">
              <!-- 基本信息 -->
              <n-form-item-gi :span="8" label="会员姓名" path="name">
                <n-input v-model:value="formData.name" placeholder="请输入会员姓名" />
              </n-form-item-gi>

              <n-form-item-gi :span="8" label="手机号码" path="phone">
                <n-input v-model:value="formData.phone" placeholder="请输入手机号码" />
              </n-form-item-gi>

              <n-form-item-gi :span="8" label="性别" path="gender">
                <n-select v-model:value="formData.gender" :options="genderOptions" placeholder="请选择性别" />
              </n-form-item-gi>

              <n-form-item-gi :span="8" label="生日" path="birthday">
                <n-date-picker v-model:value="formData.birthday" type="date" clearable />
              </n-form-item-gi>

              <n-form-item-gi :span="8" label="电子邮箱" path="email">
                <n-input v-model:value="formData.email" placeholder="请输入电子邮箱" />
              </n-form-item-gi>

              <n-form-item-gi :span="8" label="会员等级" path="level">
                <n-select v-model:value="formData.level" :options="levelOptions" placeholder="请选择会员等级" />
              </n-form-item-gi>

              <n-form-item-gi :span="24" label="地址" path="address">
                <n-input v-model:value="formData.address" placeholder="请输入地址" />
              </n-form-item-gi>
            </n-grid>
          </n-form>
        </n-card>

        <n-card title="体型数据" class="form-card">
          <n-form
            :model="formData"
            label-placement="left"
            label-width="auto"
          >
            <n-grid :cols="24" :x-gap="24">
              <n-form-item-gi :span="8" label="身高(cm)" path="bodyHeight">
                <n-input-number v-model:value="formData.bodyHeight" placeholder="请输入身高" />
              </n-form-item-gi>

              <n-form-item-gi :span="8" label="体重(kg)" path="bodyWeight">
                <n-input-number v-model:value="formData.bodyWeight" placeholder="请输入体重" />
              </n-form-item-gi>

              <n-form-item-gi :span="8" label="肩宽(cm)" path="shoulderWidth">
                <n-input-number v-model:value="formData.shoulderWidth" placeholder="请输入肩宽" />
              </n-form-item-gi>

              <n-form-item-gi :span="8" label="胸围(cm)" path="bustSize">
                <n-input-number v-model:value="formData.bustSize" placeholder="请输入胸围" />
              </n-form-item-gi>

              <n-form-item-gi :span="8" label="腰围(cm)" path="waistSize">
                <n-input-number v-model:value="formData.waistSize" placeholder="请输入腰围" />
              </n-form-item-gi>

              <n-form-item-gi :span="8" label="臀围(cm)" path="hipSize">
                <n-input-number v-model:value="formData.hipSize" placeholder="请输入臀围" />
              </n-form-item-gi>

              <n-form-item-gi :span="8" label="内侧长(cm)" path="inseam">
                <n-input-number v-model:value="formData.inseam" placeholder="请输入内侧长" />
              </n-form-item-gi>
            </n-grid>
          </n-form>
        </n-card>

        <n-card title="偏好数据" class="form-card">
          <n-form
            :model="formData"
            label-placement="left"
            label-width="auto"
          >
            <n-grid :cols="24" :x-gap="24">
              <n-form-item-gi :span="8" label="风格偏好" path="stylePreference">
                <n-select v-model:value="formData.stylePreference" :options="styleOptions" placeholder="请选择风格偏好" />
              </n-form-item-gi>

              <n-form-item-gi :span="8" label="喜爱颜色" path="favoriteColors">
                <n-select v-model:value="formData.favoriteColors" :options="colorOptions" multiple placeholder="请选择喜爱颜色" />
              </n-form-item-gi>

              <n-form-item-gi :span="8" label="喜爱品类" path="favoriteCategories">
                <n-select v-model:value="formData.favoriteCategories" :options="categoryOptions" multiple placeholder="请选择喜爱品类" />
              </n-form-item-gi>

              <n-form-item-gi :span="8" label="消费水平" path="consumptionLevel">
                <n-select v-model:value="formData.consumptionLevel" :options="consumptionOptions" placeholder="请选择消费水平" />
              </n-form-item-gi>
            </n-grid>
          </n-form>
        </n-card>

        <n-card title="备注信息" class="form-card">
          <n-form
            :model="formData"
            label-placement="left"
            label-width="auto"
          >
            <n-form-item label="备注" path="note">
              <n-input v-model:value="formData.note" type="textarea" placeholder="请输入备注信息" :autosize="{ minRows: 3, maxRows: 6 }" />
            </n-form-item>
          </n-form>
        </n-card>
      </n-spin>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import {
  NButton, NCard, NForm, NFormItem, NFormItemGi, NGrid, NInput,
  NInputNumber, NSelect, NSpace, NIcon, NDatePicker, useMessage, NSpin
} from 'naive-ui'
import {
  PersonOutline, ArrowBackOutline, SaveOutline
} from '@vicons/ionicons5'
import memberService from '../services/member'

// 路由
const router = useRouter()
const route = useRoute()
const message = useMessage()

// 会员ID
const memberId = route.params.id

// 加载和保存状态
const loading = ref(true)
const saving = ref(false)

// 表单引用
const formRef = ref(null)

// 表单数据
const formData = reactive({
  name: '',
  phone: '',
  gender: null,
  birthday: null,
  email: '',
  address: '',
  level: 'regular',

  // 体型数据
  bodyHeight: null,
  bodyWeight: null,
  shoulderWidth: null,
  bustSize: null,
  waistSize: null,
  hipSize: null,
  inseam: null,

  // 偏好数据
  stylePreference: null,
  favoriteColors: [],
  favoriteCategories: [],
  consumptionLevel: null,

  // 备注
  note: ''
})

// 表单验证规则
const rules = {
  name: {
    required: true,
    message: '请输入会员姓名',
    trigger: 'blur'
  },
  phone: {
    required: true,
    message: '请输入手机号码',
    trigger: 'blur',
    validator(rule, value) {
      if (!value) {
        return new Error('请输入手机号码')
      }
      if (!/^1[3-9]\d{9}$/.test(value)) {
        return new Error('请输入有效的手机号码')
      }
      return true
    }
  }
}

// 选项数据
const genderOptions = [
  { label: '男', value: '男' },
  { label: '女', value: '女' },
  { label: '其他', value: '其他' }
]

const levelOptions = [
  { label: '普通会员', value: 'regular' },
  { label: '白银会员', value: 'silver' },
  { label: '黄金会员', value: 'gold' },
  { label: '铂金会员', value: 'platinum' },
  { label: '钻石会员', value: 'diamond' }
]

const styleOptions = [
  { label: '休闲', value: 'casual' },
  { label: '正式', value: 'formal' },
  { label: '运动', value: 'sportswear' },
  { label: '复古', value: 'vintage' },
  { label: '极简', value: 'minimalist' },
  { label: '浪漫', value: 'romantic' },
  { label: '波西米亚', value: 'bohemian' },
  { label: '街头', value: 'street' }
]

const colorOptions = [
  { label: '黑色', value: 'black' },
  { label: '白色', value: 'white' },
  { label: '灰色', value: 'gray' },
  { label: '红色', value: 'red' },
  { label: '蓝色', value: 'blue' },
  { label: '绿色', value: 'green' },
  { label: '黄色', value: 'yellow' },
  { label: '紫色', value: 'purple' },
  { label: '粉色', value: 'pink' },
  { label: '棕色', value: 'brown' }
]

const categoryOptions = [
  { label: '上衣', value: 'tops' },
  { label: '裤装', value: 'pants' },
  { label: '裙装', value: 'skirts' },
  { label: '外套', value: 'outerwear' },
  { label: '鞋履', value: 'shoes' },
  { label: '配饰', value: 'accessories' },
  { label: '内衣', value: 'underwear' },
  { label: '运动装', value: 'sportswear' }
]

const consumptionOptions = [
  { label: '低消费', value: 'low' },
  { label: '中等消费', value: 'medium' },
  { label: '高消费', value: 'high' },
  { label: '奢侈消费', value: 'luxury' }
]

// 加载会员数据
const loadMemberData = async () => {
  loading.value = true
  try {
    const response = await memberService.getMember(memberId)
    console.log('获取到的会员数据:', response)

    // 创建一个新对象，将大写字段名转换为小写字段名
    const formattedData = {}

    // 遍历API返回的数据，将字段名转换为小写开头
    Object.keys(response).forEach(key => {
      // 检查是否是大写开头的字段
      const lowerKey = key.charAt(0).toLowerCase() + key.slice(1)
      formattedData[lowerKey] = response[key]
    })

    console.log('格式化后的会员数据:', formattedData)

    // 处理日期格式
    if (formattedData.birthday) {
      formattedData.birthday = new Date(formattedData.birthday)
    }

    // 处理数组字段
    if (formattedData.favoriteColors && typeof formattedData.favoriteColors === 'string') {
      formattedData.favoriteColors = formattedData.favoriteColors.split(',').filter(Boolean)
    }

    if (formattedData.favoriteCategories && typeof formattedData.favoriteCategories === 'string') {
      formattedData.favoriteCategories = formattedData.favoriteCategories.split(',').filter(Boolean)
    }

    // 更新表单数据
    Object.assign(formData, formattedData)
  } catch (error) {
    console.error('加载会员数据失败:', error)
    message.error('加载会员数据失败: ' + (error.response?.data?.error || '未知错误'))
  } finally {
    loading.value = false
  }
}

// 返回上一页
const goBack = () => {
  router.back()
}

// 保存会员信息
const handleSave = () => {
  formRef.value?.validate(async (errors) => {
    if (errors) {
      return
    }

    saving.value = true
    try {
      // 处理数据格式
      const memberData = { ...formData }

      // 处理日期格式
      if (memberData.birthday) {
        memberData.birthday = new Date(memberData.birthday).toISOString()
      }

      // 处理数组字段
      if (Array.isArray(memberData.favoriteColors)) {
        memberData.favoriteColors = memberData.favoriteColors.join(',')
      }

      if (Array.isArray(memberData.favoriteCategories)) {
        memberData.favoriteCategories = memberData.favoriteCategories.join(',')
      }

      // 创建一个新对象，将小写字段名转换为大写字段名
      const formattedData = {}
      Object.keys(memberData).forEach(key => {
        // 将字段名转换为大写开头
        const upperKey = key.charAt(0).toUpperCase() + key.slice(1)
        formattedData[upperKey] = memberData[key]
      })

      console.log('提交的会员数据:', formattedData)

      // 调用API更新会员数据
      await memberService.updateMember(memberId, formattedData)

      message.success('会员信息更新成功')

      // 显示成功消息后返回列表页面
      setTimeout(() => {
        router.push('/members')
      }, 500)
    } catch (error) {
      console.error('更新会员失败:', error)
      message.error('更新会员失败: ' + (error.response?.data?.error || '未知错误'))
    } finally {
      saving.value = false
    }
  })
}

// 生命周期钩子
onMounted(() => {
  loadMemberData()
})
</script>

<style scoped>
.member-edit {
  padding: 16px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.header-icon {
  color: var(--primary-color);
}

.page-title {
  margin: 0;
  font-size: 20px;
  font-weight: 500;
}

.page-subtitle {
  margin: 4px 0 0;
  font-size: 14px;
  color: var(--text-color-secondary);
}

.form-card {
  margin-bottom: 16px;
}

.btn-cancel {
  margin-right: 8px;
}
</style>
