<template>
  <div class="login-container">
    <div class="login-background">
      <div class="login-shape shape-1"></div>
      <div class="login-shape shape-2"></div>
      <div class="login-shape shape-3"></div>
      <div class="login-shape shape-4"></div>
    </div>

    <div class="login-card">
      <div class="login-header">
        <div class="logo-container">
          <div class="logo">HD</div>
        </div>
        <h1>服装进销存系统</h1>
        <p>专业的服装库存管理解决方案</p>
      </div>

      <n-form
        ref="formRef"
        :model="formValue"
        :rules="rules"
        label-placement="top"
        size="large"
        class="login-form"
      >
        <n-form-item path="username">
          <template #label>
            <div class="form-label">
              <n-icon size="18" class="label-icon">
                <person-outline />
              </n-icon>
              <span>用户名</span>
            </div>
          </template>
          <n-input
            v-model:value="formValue.username"
            placeholder="请输入用户名"
            class="login-input"
          />
        </n-form-item>

        <n-form-item path="password">
          <template #label>
            <div class="form-label">
              <n-icon size="18" class="label-icon">
                <lock-closed-outline />
              </n-icon>
              <span>密码</span>
            </div>
          </template>
          <n-input
            v-model:value="formValue.password"
            type="password"
            show-password-on="click"
            placeholder="请输入密码"
            class="login-input"
          />
        </n-form-item>

        <div class="login-options">
          <n-checkbox v-model:checked="formValue.rememberMe">记住我</n-checkbox>
          <a href="#" class="forgot-password" @click.prevent="showForgotPasswordModal">忘记密码?</a>
        </div>

        <div class="login-actions">
          <n-button
            type="primary"
            size="large"
            block
            :loading="loading"
            @click="handleLogin"
            class="login-button"
          >
            登录
          </n-button>
        </div>
      </n-form>

      <div class="login-footer">
        <p>© {{ new Date().getFullYear() }} HD-PSI 服装进销存系统</p>
      </div>
    </div>
  </div>

  <!-- 忘记密码模态框 -->
  <n-modal v-model:show="showForgotModal" preset="card" title="忘记密码" style="width: 400px">
    <n-form
      ref="forgotFormRef"
      :model="forgotForm"
      :rules="forgotRules"
      label-placement="top"
    >
      <n-form-item path="email" label="邮箱地址">
        <n-input v-model:value="forgotForm.email" placeholder="请输入您的注册邮箱" />
      </n-form-item>

      <div class="modal-actions">
        <n-button @click="showForgotModal = false">取消</n-button>
        <n-button type="primary" :loading="forgotLoading" @click="handleForgotPassword">提交</n-button>
      </div>
    </n-form>
  </n-modal>

  <!-- 重置密码模态框 -->
  <n-modal v-model:show="showResetModal" preset="card" title="重置密码" style="width: 400px">
    <n-form
      ref="resetFormRef"
      :model="resetForm"
      :rules="resetRules"
      label-placement="top"
    >
      <n-form-item path="token" label="重置令牌">
        <n-input v-model:value="resetForm.token" placeholder="请输入重置令牌" />
      </n-form-item>

      <n-form-item path="newPassword" label="新密码">
        <n-input
          v-model:value="resetForm.newPassword"
          type="password"
          show-password-on="click"
          placeholder="请输入新密码"
        />
      </n-form-item>

      <n-form-item path="confirmPassword" label="确认密码">
        <n-input
          v-model:value="resetForm.confirmPassword"
          type="password"
          show-password-on="click"
          placeholder="请再次输入新密码"
        />
      </n-form-item>

      <div class="modal-actions">
        <n-button @click="showResetModal = false">取消</n-button>
        <n-button type="primary" :loading="resetLoading" @click="handleResetPassword">提交</n-button>
      </div>
    </n-form>
  </n-modal>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useMessage } from 'naive-ui'
import {
  NForm, NFormItem, NInput, NButton,
  NCheckbox, NIcon, NModal
} from 'naive-ui'
import {
  PersonOutline,
  LockClosedOutline
} from '@vicons/ionicons5'
import auth from '../services/auth'

const router = useRouter()
const route = useRoute()
const message = useMessage()

// 表单引用
const formRef = ref(null)
const forgotFormRef = ref(null)
const resetFormRef = ref(null)

// 加载状态
const loading = ref(false)
const forgotLoading = ref(false)
const resetLoading = ref(false)

// 模态框显示状态
const showForgotModal = ref(false)
const showResetModal = ref(false)

// 表单数据
const formValue = reactive({
  username: '',
  password: '',
  rememberMe: false
})

// 忘记密码表单
const forgotForm = reactive({
  email: ''
})

// 重置密码表单
const resetForm = reactive({
  token: '',
  newPassword: '',
  confirmPassword: ''
})

// 表单验证规则
const rules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能少于6个字符', trigger: 'blur' }
  ]
}

// 忘记密码表单验证规则
const forgotRules = {
  email: [
    { required: true, message: '请输入邮箱地址', trigger: 'blur' },
    { type: 'email', message: '请输入有效的邮箱地址', trigger: 'blur' }
  ]
}

// 重置密码表单验证规则
const resetRules = {
  token: [
    { required: true, message: '请输入重置令牌', trigger: 'blur' }
  ],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能少于6个字符', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请再次输入新密码', trigger: 'blur' },
    {
      validator: (rule, value) => {
        return value === resetForm.newPassword
      },
      message: '两次输入的密码不一致',
      trigger: 'blur'
    }
  ]
}

// 登录处理
const handleLogin = (e) => {
  e.preventDefault()
  formRef.value?.validate(async (errors) => {
    if (!errors) {
      loading.value = true
      try {
        const response = await auth.login(formValue.username, formValue.password, formValue.rememberMe)

        // 保存登录响应
        auth.saveLoginResponse(response)

        // 如果选择了记住我，保存记住我标志
        localStorage.setItem('rememberMe', formValue.rememberMe)

        message.success('登录成功')

        // 获取重定向URL
        const redirect = route.query.redirect || '/dashboard'
        router.push(redirect)
      } catch (error) {
        console.error('登录失败:', error)

        if (error.response && error.response.data) {
          const errorData = error.response.data

          // 显示错误信息
          if (errorData.error) {
            let errorMessage = errorData.error

            // 如果有详细错误信息，显示详细信息
            if (errorData.details) {
              errorMessage += ': ' + errorData.details
            }

            // 如果有剩余尝试次数，显示剩余次数
            if (errorData.remaining_attempts !== undefined) {
              errorMessage += ` (剩余尝试次数: ${errorData.remaining_attempts})`
            }

            // 如果账户被锁定，显示锁定时间
            if (errorData.wait_minutes) {
              errorMessage += ` (请等待 ${errorData.wait_minutes} 分钟后再试)`
            }

            message.error(errorMessage)
          } else {
            message.error('登录失败: ' + (error.message || '请检查用户名和密码'))
          }
        } else {
          message.error('登录失败: ' + (error.message || '请检查用户名和密码'))
        }
      } finally {
        loading.value = false
      }
    }
  })
}

// 显示忘记密码模态框
const showForgotPasswordModal = () => {
  showForgotModal.value = true
  forgotForm.email = ''
}

// 忘记密码处理
const handleForgotPassword = () => {
  forgotFormRef.value?.validate(async (errors) => {
    if (!errors) {
      forgotLoading.value = true
      try {
        const response = await auth.forgotPassword(forgotForm.email)

        message.success('密码重置链接已发送到您的邮箱')

        // 如果是测试环境，显示重置令牌并打开重置密码模态框
        if (response.reset_token) {
          resetForm.token = response.reset_token
          showForgotModal.value = false
          showResetModal.value = true
        } else {
          showForgotModal.value = false
        }
      } catch (error) {
        console.error('忘记密码处理失败:', error)

        if (error.response && error.response.data && error.response.data.error) {
          message.error(error.response.data.error)
        } else {
          message.error('处理失败: ' + (error.message || '请稍后再试'))
        }
      } finally {
        forgotLoading.value = false
      }
    }
  })
}

// 重置密码处理
const handleResetPassword = () => {
  resetFormRef.value?.validate(async (errors) => {
    if (!errors) {
      resetLoading.value = true
      try {
        await auth.resetPassword(resetForm.token, resetForm.newPassword)

        message.success('密码重置成功，请使用新密码登录')
        showResetModal.value = false

        // 清空表单
        resetForm.token = ''
        resetForm.newPassword = ''
        resetForm.confirmPassword = ''
      } catch (error) {
        console.error('重置密码失败:', error)

        if (error.response && error.response.data && error.response.data.error) {
          let errorMessage = error.response.data.error
          if (error.response.data.details) {
            errorMessage += ': ' + error.response.data.details
          }
          message.error(errorMessage)
        } else {
          message.error('重置密码失败: ' + (error.message || '请检查重置令牌是否有效'))
        }
      } finally {
        resetLoading.value = false
      }
    }
  })
}
</script>

<style scoped>
/* 主容器 */
.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
  background-color: #f8fafc;
  position: relative;
  overflow: hidden;
}

/* 背景装饰 */
.login-background {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 0;
}

.login-shape {
  position: absolute;
  border-radius: 50%;
  filter: blur(40px);
  opacity: 0.4;
  animation: float 8s ease-in-out infinite;
}

.shape-1 {
  width: 300px;
  height: 300px;
  background: linear-gradient(45deg, #4f46e5, #8b5cf6);
  top: -100px;
  left: -100px;
  animation-delay: 0s;
}

.shape-2 {
  width: 400px;
  height: 400px;
  background: linear-gradient(45deg, #0ea5e9, #06b6d4);
  bottom: -150px;
  right: -100px;
  animation-delay: 2s;
}

.shape-3 {
  width: 200px;
  height: 200px;
  background: linear-gradient(45deg, #f97316, #f43f5e);
  top: 60%;
  left: 10%;
  animation-delay: 4s;
}

.shape-4 {
  width: 250px;
  height: 250px;
  background: linear-gradient(45deg, #10b981, #14b8a6);
  top: 10%;
  right: 10%;
  animation-delay: 6s;
}

@keyframes float {
  0% {
    transform: translateY(0) scale(1);
  }
  50% {
    transform: translateY(-20px) scale(1.05);
  }
  100% {
    transform: translateY(0) scale(1);
  }
}

/* 登录卡片 */
.login-card {
  width: 420px;
  padding: 40px;
  background-color: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(10px);
  border-radius: 16px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.08);
  position: relative;
  z-index: 1;
  animation: fadeIn 0.6s ease-out;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* 登录头部 */
.login-header {
  text-align: center;
  margin-bottom: 36px;
}

.logo-container {
  display: flex;
  justify-content: center;
  margin-bottom: 16px;
}

.logo {
  width: 60px;
  height: 60px;
  background: linear-gradient(135deg, #4f46e5, #8b5cf6);
  color: white;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  font-weight: bold;
  box-shadow: 0 4px 12px rgba(79, 70, 229, 0.3);
}

.login-header h1 {
  font-size: 24px;
  color: #1e293b;
  margin-bottom: 8px;
  font-weight: 600;
}

.login-header p {
  font-size: 14px;
  color: #64748b;
}

/* 表单样式 */
.login-form {
  margin-top: 20px;
}

.form-label {
  display: flex;
  align-items: center;
  margin-bottom: 4px;
}

.label-icon {
  margin-right: 6px;
  color: #64748b;
}

.login-input {
  border-radius: 8px;
  transition: all 0.3s;
}

.login-input:hover, .login-input:focus {
  border-color: #4f46e5;
}

/* 登录选项 */
.login-options {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin: 16px 0;
  font-size: 14px;
}

.forgot-password {
  color: #4f46e5;
  text-decoration: none;
  transition: color 0.3s;
}

.forgot-password:hover {
  color: #6366f1;
  text-decoration: underline;
}

/* 登录按钮 */
.login-actions {
  margin-top: 24px;
}

.login-button {
  height: 44px;
  font-size: 16px;
  border-radius: 8px;
  background: linear-gradient(135deg, #4f46e5, #8b5cf6);
  border: none;
  box-shadow: 0 4px 12px rgba(79, 70, 229, 0.3);
  transition: all 0.3s;
}

.login-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(79, 70, 229, 0.4);
  background: linear-gradient(135deg, #4338ca, #7c3aed);
}

.login-button:active {
  transform: translateY(0);
  box-shadow: 0 2px 8px rgba(79, 70, 229, 0.3);
}

/* 模态框样式 */
.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  margin-top: 24px;
}

/* 页脚 */
.login-footer {
  margin-top: 32px;
  text-align: center;
  font-size: 12px;
  color: #64748b;
}

/* 响应式设计 */
@media (max-width: 480px) {
  .login-card {
    width: 90%;
    padding: 30px 20px;
  }

  .login-shape {
    opacity: 0.2;
  }
}
</style>
