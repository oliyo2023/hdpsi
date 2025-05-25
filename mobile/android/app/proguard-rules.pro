# 宏店移动应用 ProGuard Rules
# 这些规则用于代码混淆和优化

# 保留Flutter相关的类
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# 保留Google Play Core相关的类
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }

# 保留Flutter Play Store相关的类
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }

# 忽略缺失的Google Play Core类的警告
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
-dontwarn io.flutter.embedding.android.FlutterPlayStoreSplitApplication

# 如果类不存在，则忽略相关引用
-ignorewarnings

# 保留Dart相关的类
-keep class dartx.** { *; }

# 保留JSON序列化相关的类
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# 保留Gson相关的类（如果使用）
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# 保留网络请求相关的类
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-keep class retrofit2.** { *; }

# 保留数据模型类（根据您的实际模型调整）
-keep class com.hdpsi.mobile.models.** { *; }

# 保留安全存储相关的类
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# 保留相机和图片选择器相关的类
-keep class io.flutter.plugins.imagepicker.** { *; }
-keep class io.flutter.plugins.camera.** { *; }

# 保留扫码相关的类
-keep class dev.steenbakker.mobile_scanner.** { *; }

# 保留数据库相关的类
-keep class com.tekartik.sqflite.** { *; }

# 保留路径提供器相关的类
-keep class io.flutter.plugins.pathprovider.** { *; }

# 保留共享偏好相关的类
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# 保留生命周期相关的类
-keep class io.flutter.plugins.flutter_plugin_android_lifecycle.** { *; }

# 移除日志输出（生产环境）
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}

# 保留枚举类
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# 保留Parcelable实现
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# 保留Serializable实现
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# 保留native方法
-keepclasseswithmembernames class * {
    native <methods>;
}

# 保留反射相关的类和方法
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# 优化设置
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification
-dontpreverify

# 保留行号信息（用于调试崩溃日志）
-keepattributes SourceFile,LineNumberTable

# 如果您的应用使用WebView
-keepclassmembers class fqcn.of.javascript.interface.for.webview {
   public *;
}

# 保留R类
-keep class **.R$* {
    <fields>;
}

# 不混淆资源ID
-keep class **.R$* { *; }

# 保留BuildConfig
-keep class **.BuildConfig { *; }

# 保留Manifest中声明的组件
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.app.backup.BackupAgentHelper
-keep public class * extends android.preference.Preference

# 保留View的构造函数
-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet);
}

-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet, int);
}

# 保留onClick方法
-keepclassmembers class * extends android.app.Activity {
   public void *(android.view.View);
}
