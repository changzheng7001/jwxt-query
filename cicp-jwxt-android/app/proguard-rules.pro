# 保留 WebView 相关与 JS 桥接
-keep class com.cicp.jwxt.MainActivity { *; }
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
