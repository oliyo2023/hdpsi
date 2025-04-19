<template>
  <div class="profile-container">
    <div class="page-header">
      <h1 class="page-title">个人信息</h1>
    </div>

    <n-card class="profile-card">
      <n-tabs type="line" animated>
        <!-- 基本信息标签页 -->
        <n-tab-pane name="basic" tab="基本信息">
          <div class="profile-content">
            <div class="profile-header">
              <div class="avatar-section">
                <div class="user-avatar large">
                  {{ getUserInitials() }}
                </div>
                <div class="user-info">
                  <h2>{{ userForm.Name || userForm.Username }}</h2>
                  <div class="user-role">{{ getUserRole() }}</div>
                </div>
              </div>
            </div>

            <n-divider />

            <n-form
              ref="formRef"
              :model="userForm"
              :rules="rules"
              label-placement="left"
              label-width="100px"
              require-mark-placement="right-hanging"
              size="medium"
            >
              <n-grid :cols="24" :x-gap="24">
                <n-form-item-gi :span="12" label="用户名" path="Username">
                  <n-input v-model:value="userForm.Username" disabled placeholder="用户名" />
                </n-form-item-gi>

                <n-form-item-gi :span="12" label="姓名" path="Name">
                  <n-input v-model:value="userForm.Name" placeholder="请输入姓名" />
                </n-form-item-gi>

                <n-form-item-gi :span="12" label="电子邮箱" path="Email">
                  <n-input v-model:value="userForm.Email" placeholder="请输入电子邮箱" />
                </n-form-item-gi>

                <n-form-item-gi :span="12" label="手机号码" path="Phone">
                  <n-input v-model:value="userForm.Phone" placeholder="请输入手机号码" />
                </n-form-item-gi>

                <n-form-item-gi :span="12" label="角色">
                  <n-input :value="getUserRole()" disabled />
                </n-form-item-gi>

                <n-form-item-gi :span="12" label="最后登录">
                  <n-input :value="formatDate(userForm.LastLogin)" disabled />
                </n-form-item-gi>
              </n-grid>

              <div class="form-actions">
                <n-button type="primary" @click="handleUpdateProfile" :loading="loading">
                  保存修改
                </n-button>
              </div>
            </n-form>
          </div>
        </n-tab-pane>

        <!-- 修改密码标签页 -->
        <n-tab-pane name="password" tab="修改密码">
          <div class="profile-content">
            <n-form
              ref="passwordFormRef"
              :model="passwordForm"
              :rules="passwordRules"
              label-placement="left"
              label-width="100px"
              require-mark-placement="right-hanging"
              size="medium"
            >
              <n-form-item label="当前密码" path="oldPassword">
                <n-input
                  v-model:value="passwordForm.oldPassword"
                  type="password"
                  show-password-on="click"
                  placeholder="请输入当前密码"
                />
              </n-form-item>

              <n-form-item label="新密码" path="newPassword">
                <n-input
                  v-model:value="passwordForm.newPassword"
                  type="password"
                  show-password-on="click"
                  placeholder="请输入新密码"
                />
              </n-form-item>

              <n-form-item label="确认新密码" path="confirmPassword">
                <n-input
                  v-model:value="passwordForm.confirmPassword"
                  type="password"
                  show-password-on="click"
                  placeholder="请再次输入新密码"
                />
              </n-form-item>

              <div class="form-actions">
                <n-button type="primary" @click="handleChangePassword" :loading="passwordLoading">
                  修改密码
                </n-button>
              </div>
            </n-form>
          </div>
        </n-tab-pane>
      </n-tabs>
    </n-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import {
  NCard, NTabs, NTabPane, NForm, NFormItem, NFormItemGi,
  NInput, NButton, NDivider, NGrid, useMessage
} from 'naive-ui'
import auth from '../services/auth'

// 消息提示
const message = useMessage()

// 表单引用
const formRef = ref(null)
const passwordFormRef = ref(null)

// 加载状态
const loading = ref(false)
const passwordLoading = ref(false)

// 用户表单数据
const userForm = reactive({
  Username: '',
  Name: '',
  Email: '',
  Phone: '',
  Role: '',
  LastLogin: null
})

// 密码表单数据
const passwordForm = reactive({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})

// 表单验证规则
const rules = {
  Name: [
    { required: true, message: '请输入姓名', trigger: 'blur' }
  ],
  Email: [
    { type: 'email', message: '请输入有效的电子邮箱地址', trigger: 'blur' }
  ],
  Phone: [
    { pattern: /^1[3-9]\d{9}$/, message: '请输入有效的手机号码', trigger: 'blur' }
  ]
}

// 密码表单验证规则
const passwordRules = {
  oldPassword: [
    { required: true, message: '请输入当前密码', trigger: 'blur' }
  ],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能少于6个字符', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请再次输入新密码', trigger: 'blur' },
    {
      validator: (rule, value) => {
        return value === passwordForm.newPassword
      },
      message: '两次输入的密码不一致',
      trigger: 'blur'
    }
  ]
}

// 获取用户角色文本
const getUserRole = () => {
  const roleMap = {
    'admin': '管理员',
    'manager': '经理',
    'staff': '员工',
    'cashier': '收银员',
    'operator': '操作员'
  }
  return roleMap[userForm.Role] || '用户'
}

// 获取用户名首字母作为头像
const getUserInitials = () => {
  const name = userForm.Name || userForm.Username || ''
  if (!name) return 'U'

  // 如果是中文名字，取第一个字
  if (/[\u4e00-\u9fa5]/.test(name)) {
    return name.charAt(0)
  }

  // 如果是英文名字，取首字母
  return name.charAt(0).toUpperCase()
}

// 格式化日期
const formatDate = (dateString) => {
  if (!dateString) return '从未登录'

  const date = new Date(dateString)
  return date.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit'
  })
}

// 加载用户信息
const loadUserProfile = async () => {
  try {
    const userData = await auth.getProfile()
    if (userData) {
      userForm.Username = userData.Username || ''
      userForm.Name = userData.Name || ''
      userForm.Email = userData.Email || ''
      userForm.Phone = userData.Phone || ''
      userForm.Role = userData.Role || ''
      userForm.LastLogin = userData.LastLogin || null
    }
  } catch (error) {
    console.error('获取用户信息失败:', error)
    message.error('获取用户信息失败')
  }
}

// 更新用户信息
const handleUpdateProfile = () => {
  formRef.value?.validate(async (errors) => {
    if (!errors) {
      loading.value = true
      try {
        const updateData = {
          Name: userForm.Name,
          Email: userForm.Email,
          Phone: userForm.Phone
        }

        await auth.updateProfile(updateData)
        message.success('个人信息更新成功')

        // 更新本地存储的用户信息
        await auth.fetchAndUpdateUserProfile()
      } catch (error) {
        console.error('更新用户信息失败:', error)
        if (error.response && error.response.data && error.response.data.error) {
          message.error(`更新失败: ${error.response.data.error}`)
        } else {
          message.error('更新用户信息失败')
        }
      } finally {
        loading.value = false
      }
    }
  })
}

// 修改密码
const handleChangePassword = () => {
  passwordFormRef.value?.validate(async (errors) => {
    if (!errors) {
      passwordLoading.value = true
      try {
        await auth.changePassword(
          passwordForm.oldPassword,
          passwordForm.newPassword
        )

        message.success('密码修改成功')

        // 清空密码表单
        passwordForm.oldPassword = ''
        passwordForm.newPassword = ''
        passwordForm.confirmPassword = ''
      } catch (error) {
        console.error('修改密码失败:', error)
        if (error.response && error.response.data && error.response.data.error) {
          message.error(`修改失败: ${error.response.data.error}`)
        } else {
          message.error('修改密码失败')
        }
      } finally {
        passwordLoading.value = false
      }
    }
  })
}

// 生命周期钩子
onMounted(() => {
  loadUserProfile()
})
</script>

<style scoped>
.profile-container {
  padding: 16px;
}

.page-header {
  margin-bottom: 24px;
}

.page-title {
  font-size: 24px;
  font-weight: 600;
  color: #1e293b;
  margin: 0;
}

.profile-card {
  background-color: #fff;
  border-radius: 8px;
}

.profile-content {
  padding: 16px 0;
}

.profile-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.avatar-section {
  display: flex;
  align-items: center;
  gap: 16px;
}

.user-avatar {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background-color: #0ea5e9;
  color: white;
  font-weight: 600;
  font-size: 16px;
}

.user-avatar.large {
  width: 80px;
  height: 80px;
  font-size: 32px;
}

.user-info h2 {
  margin: 0 0 4px 0;
  font-size: 20px;
  font-weight: 600;
  color: #1e293b;
}

.user-role {
  font-size: 14px;
  color: #64748b;
}

.form-actions {
  margin-top: 24px;
  display: flex;
  justify-content: flex-end;
}
</style>
