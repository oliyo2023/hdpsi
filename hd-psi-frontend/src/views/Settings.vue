<template>
  <div class="settings-container">
    <div class="page-header">
      <h1 class="page-title">系统设置</h1>
    </div>

    <n-card class="settings-card">
      <n-tabs type="line" animated>
        <!-- 基本设置标签页 -->
        <n-tab-pane name="basic" tab="基本设置">
          <div class="settings-content">
            <n-form
              ref="basicFormRef"
              :model="basicForm"
              label-placement="left"
              label-width="120px"
              require-mark-placement="right-hanging"
              size="medium"
            >
              <n-form-item label="系统名称">
                <n-input v-model:value="basicForm.systemName" placeholder="请输入系统名称" />
              </n-form-item>

              <n-form-item label="公司名称">
                <n-input v-model:value="basicForm.companyName" placeholder="请输入公司名称" />
              </n-form-item>

              <n-form-item label="系统主题">
                <n-select v-model:value="basicForm.theme" :options="themeOptions" />
              </n-form-item>

              <n-form-item label="默认语言">
                <n-select v-model:value="basicForm.language" :options="languageOptions" />
              </n-form-item>

              <div class="form-actions">
                <n-button type="primary" @click="handleSaveBasicSettings" :loading="basicLoading">
                  保存设置
                </n-button>
              </div>
            </n-form>
          </div>
        </n-tab-pane>

        <!-- 通知设置标签页 -->
        <n-tab-pane name="notification" tab="通知设置">
          <div class="settings-content">
            <n-form
              ref="notificationFormRef"
              :model="notificationForm"
              label-placement="left"
              label-width="120px"
              require-mark-placement="right-hanging"
              size="medium"
            >
              <n-form-item label="库存预警通知">
                <n-switch v-model:value="notificationForm.inventoryAlert" />
              </n-form-item>

              <n-form-item label="订单通知">
                <n-switch v-model:value="notificationForm.orderNotification" />
              </n-form-item>

              <n-form-item label="系统消息">
                <n-switch v-model:value="notificationForm.systemMessage" />
              </n-form-item>

              <n-form-item label="邮件通知">
                <n-switch v-model:value="notificationForm.emailNotification" />
              </n-form-item>

              <div class="form-actions">
                <n-button type="primary" @click="handleSaveNotificationSettings" :loading="notificationLoading">
                  保存设置
                </n-button>
              </div>
            </n-form>
          </div>
        </n-tab-pane>

        <!-- 打印设置标签页 -->
        <n-tab-pane name="printing" tab="打印设置">
          <div class="settings-content">
            <n-form
              ref="printingFormRef"
              :model="printingForm"
              label-placement="left"
              label-width="120px"
              require-mark-placement="right-hanging"
              size="medium"
            >
              <n-form-item label="默认打印机">
                <n-select v-model:value="printingForm.defaultPrinter" :options="printerOptions" />
              </n-form-item>

              <n-form-item label="纸张大小">
                <n-select v-model:value="printingForm.paperSize" :options="paperSizeOptions" />
              </n-form-item>

              <n-form-item label="打印页眉">
                <n-input v-model:value="printingForm.header" placeholder="请输入打印页眉" />
              </n-form-item>

              <n-form-item label="打印页脚">
                <n-input v-model:value="printingForm.footer" placeholder="请输入打印页脚" />
              </n-form-item>

              <div class="form-actions">
                <n-button type="primary" @click="handleSavePrintingSettings" :loading="printingLoading">
                  保存设置
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
  NCard, NTabs, NTabPane, NForm, NFormItem,
  NInput, NButton, NSelect, NSwitch, useMessage
} from 'naive-ui'
import settingsService from '@/services/settings'

// 消息提示
const message = useMessage()

// 表单引用
const basicFormRef = ref(null)
const notificationFormRef = ref(null)
const printingFormRef = ref(null)

// 加载状态
const basicLoading = ref(false)
const notificationLoading = ref(false)
const printingLoading = ref(false)

// 基本设置表单数据
const basicForm = reactive({
  systemName: '服装进销存系统',
  companyName: '海达服饰有限公司',
  theme: 'light',
  language: 'zh-CN'
})

// 通知设置表单数据
const notificationForm = reactive({
  inventoryAlert: true,
  orderNotification: true,
  systemMessage: true,
  emailNotification: false
})

// 打印设置表单数据
const printingForm = reactive({
  defaultPrinter: 'default',
  paperSize: 'a4',
  header: '海达服饰有限公司',
  footer: '感谢您的惠顾'
})

// 主题选项
const themeOptions = [
  { label: '浅色主题', value: 'light' },
  { label: '深色主题', value: 'dark' }
]

// 语言选项
const languageOptions = [
  { label: '简体中文', value: 'zh-CN' },
  { label: '繁体中文', value: 'zh-TW' },
  { label: '英文', value: 'en-US' }
]

// 打印机选项
const printerOptions = [
  { label: '默认打印机', value: 'default' },
  { label: 'HP LaserJet Pro', value: 'hp-laser' },
  { label: 'Epson L3150', value: 'epson-l3150' },
  { label: 'Canon PIXMA', value: 'canon-pixma' }
]

// 纸张大小选项
const paperSizeOptions = [
  { label: 'A4', value: 'a4' },
  { label: 'A5', value: 'a5' },
  { label: 'B5', value: 'b5' },
  { label: '信纸', value: 'letter' }
]

// 保存基本设置
const handleSaveBasicSettings = async () => {
  basicLoading.value = true

  try {
    // 保存基本设置
    await settingsService.updateSettings('basic', {
      system_name: basicForm.systemName,
      company_name: basicForm.companyName,
      language: basicForm.language
    })

    // 保存主题设置
    await settingsService.updateSettings('theme', {
      theme: basicForm.theme
    })

    message.success('基本设置保存成功')
  } catch (error) {
    message.error('保存设置失败')
    console.error('保存设置失败:', error)
  } finally {
    basicLoading.value = false
  }
}

// 保存通知设置
const handleSaveNotificationSettings = async () => {
  notificationLoading.value = true

  try {
    await settingsService.updateSettings('notification', {
      inventory_alert: notificationForm.inventoryAlert.toString(),
      order_notification: notificationForm.orderNotification.toString(),
      system_message: notificationForm.systemMessage.toString(),
      email_notification: notificationForm.emailNotification.toString()
    })

    message.success('通知设置保存成功')
  } catch (error) {
    message.error('保存设置失败')
    console.error('保存设置失败:', error)
  } finally {
    notificationLoading.value = false
  }
}

// 保存打印设置
const handleSavePrintingSettings = async () => {
  printingLoading.value = true

  try {
    await settingsService.updateSettings('printing', {
      default_printer: printingForm.defaultPrinter,
      paper_size: printingForm.paperSize,
      print_header: printingForm.header,
      print_footer: printingForm.footer
    })

    message.success('打印设置保存成功')
  } catch (error) {
    message.error('保存设置失败')
    console.error('保存设置失败:', error)
  } finally {
    printingLoading.value = false
  }
}

// 加载设置
const loadSettings = async () => {
  try {
    // 加载基本设置
    const basicSettings = await settingsService.getSettings('basic')
    if (basicSettings) {
      basicForm.systemName = basicSettings.system_name || basicForm.systemName
      basicForm.companyName = basicSettings.company_name || basicForm.companyName
      basicForm.language = basicSettings.language || basicForm.language
    }

    // 加载主题设置
    const themeSettings = await settingsService.getSettings('theme')
    if (themeSettings) {
      basicForm.theme = themeSettings.theme || basicForm.theme
    }

    // 加载通知设置
    const notificationSettings = await settingsService.getSettings('notification')
    if (notificationSettings) {
      notificationForm.inventoryAlert = notificationSettings.inventory_alert === 'true'
      notificationForm.orderNotification = notificationSettings.order_notification === 'true'
      notificationForm.systemMessage = notificationSettings.system_message === 'true'
      notificationForm.emailNotification = notificationSettings.email_notification === 'true'
    }

    // 加载打印设置
    const printingSettings = await settingsService.getSettings('printing')
    if (printingSettings) {
      printingForm.defaultPrinter = printingSettings.default_printer || printingForm.defaultPrinter
      printingForm.paperSize = printingSettings.paper_size || printingForm.paperSize
      printingForm.header = printingSettings.print_header || printingForm.header
      printingForm.footer = printingSettings.print_footer || printingForm.footer
    }
  } catch (error) {
    message.error('加载设置失败')
    console.error('加载设置失败:', error)
  }
}

// 生命周期钩子
onMounted(() => {
  loadSettings()
})
</script>

<style scoped>
.settings-container {
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

.settings-card {
  background-color: #fff;
  border-radius: 8px;
}

.settings-content {
  padding: 16px 0;
  max-width: 800px;
}

.form-actions {
  margin-top: 24px;
  display: flex;
  justify-content: flex-end;
}
</style>
