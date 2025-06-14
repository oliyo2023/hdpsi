import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// 加载密钥配置
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.example.hd_psi_mobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"  // Required for multiple Flutter plugins

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.hdpsi.mobile"  // 更改为正式的应用ID
        minSdk = 23  // Required for flutter_secure_storage plugin
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // 启用混淆
        proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
    }

    // 签名配置
    signingConfigs {
        create("release") {
            val keyAlias = keystoreProperties["MYAPP_RELEASE_KEY_ALIAS"] as String? ?: System.getenv("MYAPP_RELEASE_KEY_ALIAS")
            val keyPassword = keystoreProperties["MYAPP_RELEASE_KEY_PASSWORD"] as String? ?: System.getenv("MYAPP_RELEASE_KEY_PASSWORD")
            val storeFile = keystoreProperties["MYAPP_RELEASE_STORE_FILE"] as String? ?: System.getenv("MYAPP_RELEASE_STORE_FILE")
            val storePassword = keystoreProperties["MYAPP_RELEASE_STORE_PASSWORD"] as String? ?: System.getenv("MYAPP_RELEASE_STORE_PASSWORD")

            // 只有在所有必需属性都存在时才配置签名
            if (keyAlias != null && keyPassword != null && storeFile != null && storePassword != null) {
                this.keyAlias = keyAlias
                this.keyPassword = keyPassword
                this.storeFile = rootProject.file(storeFile)
                this.storePassword = storePassword
            } else {
                // 如果缺少签名配置，输出警告信息
                println("警告: 签名配置不完整，将使用调试签名")
                println("keyAlias: $keyAlias")
                println("keyPassword: ${if (keyPassword != null) "已设置" else "未设置"}")
                println("storeFile: $storeFile")
                println("storePassword: ${if (storePassword != null) "已设置" else "未设置"}")
            }
        }
    }

    buildTypes {
        debug {
            applicationIdSuffix = ".debug"
            isDebuggable = true
            isMinifyEnabled = false
            isShrinkResources = false
        }

        release {
            isMinifyEnabled = true  // 启用代码混淆
            isShrinkResources = true  // 启用资源压缩
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")

            // 尝试使用发布签名配置，如果不可用则使用调试签名
            try {
                val releaseSigningConfig = signingConfigs.getByName("release")
                if (releaseSigningConfig.storeFile != null && releaseSigningConfig.storePassword != null) {
                    signingConfig = releaseSigningConfig
                } else {
                    println("警告: 发布签名配置不完整，使用调试签名")
                    signingConfig = signingConfigs.getByName("debug")
                }
            } catch (e: Exception) {
                println("警告: 无法获取发布签名配置，使用调试签名: ${e.message}")
                signingConfig = signingConfigs.getByName("debug")
            }

            // 启用R8全模式以获得更好的优化
            isDebuggable = false

            // 启用 ZIP 对齐
            isZipAlignEnabled = true

            // 启用 Crunch PNG 优化
            isCrunchPngs = true
        }
    }

    // 添加 APK 分包配置
    bundle {
        language {
            enableSplit = true
        }
        density {
            enableSplit = true
        }
        abi {
            enableSplit = true
        }
    }
}

dependencies {
    // Google Play Core 库，用于支持动态功能模块
    implementation("com.google.android.play:core:1.10.3")
    implementation("com.google.android.play:core-ktx:1.8.1")
}

flutter {
    source = "../.."
}
