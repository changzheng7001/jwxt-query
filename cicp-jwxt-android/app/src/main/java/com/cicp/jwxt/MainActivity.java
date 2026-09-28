package com.cicp.jwxt;

import android.app.Activity;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.webkit.JavascriptInterface;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.CookieManager;
import java.net.CookieHandler;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

/**
 * 司警教务查询（CICP 教务查询）主界面。
 * 纯 WebView 包装：前端单文件 assets/index.html 负责 UI 与查询，
 * 本类提供 JS 桥（网络请求 / 通知 / 沉浸状态栏 / 状态栏高度 / 外链）。
 *
 * 会话说明：登录后凭证不落本地（不存明文密码）。教务会话由
 * java.net.CookieManager 全局管理，登录响应中的 Set-Cookie 自动存入，
 * 后续请求自动携带，实现"登录后存会话"；App 重启会话失效则需重新登录。
 */
public class MainActivity extends Activity {

    private static final String CHANNEL_ID = "jwxt_chan";
    private static final int NOTIF_ID = 1;

    private WebView webView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // 全局 Cookie 会话管理（登录后自动保持教务会话，不落明文密码）
        if (CookieHandler.getDefault() == null) {
            CookieHandler.setDefault(new CookieManager());
        }

        setContentView(R.layout.activity_main);
        applyImmersive(false); // 默认浅色主题：沉浸状态栏 + 深色图标

        webView = findViewById(R.id.webview);
        WebSettings s = webView.getSettings();
        s.setJavaScriptEnabled(true);
        s.setDomStorageEnabled(true);
        s.setDatabaseEnabled(true);
        s.setAllowFileAccess(true);
        s.setAllowFileAccessFromFileURLs(true);
        s.setAllowUniversalAccessFromFileURLs(true);
        s.setCacheMode(WebSettings.LOAD_DEFAULT);
        webView.setWebViewClient(new WebViewClient());
        webView.addJavascriptInterface(new WebAppInterface(), "Android");
        webView.loadUrl("file:///android_asset/index.html");

        handleGotoSchedule(getIntent());
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        handleGotoSchedule(intent);
    }

    @Override
    public void onBackPressed() {
        // 优先回退 WebView 历史，否则退出
        if (webView != null && webView.canGoBack()) {
            webView.goBack();
        } else {
            super.onBackPressed();
        }
    }

    /** 通知点击/入口跳转到"我的课表（本周）" */
    private void handleGotoSchedule(Intent intent) {
        if (intent != null && "schedule".equals(intent.getStringExtra("goto"))) {
            if (webView != null) {
                webView.postDelayed(() ->
                        webView.evaluateJavascript(
                                "window.__gotoSchedule&&window.__gotoSchedule()", null), 800);
            }
            if (intent != null) intent.removeExtra("goto");
        }
    }

    /** 沉浸式状态栏：透明 + 内容上延，图标随明暗主题切换 */
    private void applyImmersive(final boolean dark) {
        runOnUiThread(() -> {
            Window w = getWindow();
            w.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            w.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            w.setStatusBarColor(android.graphics.Color.TRANSPARENT);
            View dec = w.getDecorView();
            int vis = dec.getSystemUiVisibility();
            vis |= View.SYSTEM_UI_FLAG_LAYOUT_STABLE | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN;
            if (dark) {
                vis &= ~View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR; // 浅色图标
            } else {
                vis |= View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR;   // 深色图标
            }
            dec.setSystemUiVisibility(vis);
        });
    }

    /** JS 桥：前端通过 window.Android.xxx() 调用 */
    private class WebAppInterface {

        /** 通用 HTTP 请求（自动携带 CookieManager 会话） */
        @JavascriptInterface
        public String httpRequest(String method, String urlStr, String body) {
            HttpURLConnection c = null;
            try {
                URL url = new URL(urlStr);
                c = (HttpURLConnection) url.openConnection();
                c.setRequestMethod(method == null || method.isEmpty() ? "GET" : method);
                c.setInstanceFollowRedirects(true);
                c.setConnectTimeout(15000);
                c.setReadTimeout(15000);
                if (body != null && !body.isEmpty()) {
                    c.setDoOutput(true);
                    byte[] bytes = body.getBytes(StandardCharsets.UTF_8);
                    c.setFixedLengthStreamingMode(bytes.length);
                    c.getOutputStream().write(bytes);
                }
                BufferedReader in = new BufferedReader(
                        new InputStreamReader(c.getInputStream(), StandardCharsets.UTF_8));
                StringBuilder sb = new StringBuilder();
                char[] buf = new char[8192];
                int n;
                while ((n = in.read(buf)) > 0) {
                    sb.append(buf, 0, n);
                }
                return sb.toString();
            } catch (Exception e) {
                return "ERROR:" + (e.getMessage() == null ? e.toString() : e.getMessage());
            } finally {
                if (c != null) c.disconnect();
            }
        }

        /** 常驻"今日课程"通知，点击跳本人课表 */
        @JavascriptInterface
        public void showNotification(String title, String text, boolean ongoing) {
            NotificationManager nm = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
            if (Build.VERSION.SDK_INT >= 26) {
                NotificationChannel ch = new NotificationChannel(
                        CHANNEL_ID, "CICP教务提醒", NotificationManager.IMPORTANCE_DEFAULT);
                nm.createNotificationChannel(ch);
            }
            Intent i = new Intent(MainActivity.this, MainActivity.class);
            i.putExtra("goto", "schedule");
            int flags = PendingIntent.FLAG_UPDATE_CURRENT;
            if (Build.VERSION.SDK_INT >= 23) flags |= PendingIntent.FLAG_IMMUTABLE;
            PendingIntent pi = PendingIntent.getActivity(MainActivity.this, 0, i, flags);

            Notification.Builder b;
            if (Build.VERSION.SDK_INT >= 26) {
                b = new Notification.Builder(MainActivity.this, CHANNEL_ID);
            } else {
                b = new Notification.Builder(MainActivity.this);
            }
            b.setSmallIcon(android.R.drawable.ic_menu_agenda)
                    .setContentTitle(title)
                    .setContentText(text)
                    .setContentIntent(pi)
                    .setOngoing(ongoing)
                    .setStyle(new Notification.BigTextStyle().bigText(text));
            nm.notify(NOTIF_ID, b.build());
        }

        /** 状态栏配色跟随前端明暗主题（沉浸透明，图标变色） */
        @JavascriptInterface
        public void setStatusTheme(boolean dark) {
            applyImmersive(dark);
        }

        /** 返回状态栏高度（物理像素），前端除以 devicePixelRatio 得到 CSS px */
        @JavascriptInterface
        public int getStatusBarHeight() {
            int id = getResources().getIdentifier("status_bar_height", "dimen", "android");
            return id > 0 ? getResources().getDimensionPixelSize(id) : 0;
        }

        /** 用系统浏览器打开外链 */
        @JavascriptInterface
        public void openBrowser(String url) {
            try {
                startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(url)));
            } catch (Exception ignored) {
            }
        }

        /** 退出登录：清除原生 CookieManager 中的教务会话 */
        @JavascriptInterface
        public void clearSession() {
            CookieHandler ch = CookieHandler.getDefault();
            if (ch instanceof CookieManager) {
                try {
                    ((CookieManager) ch).getCookieStore().removeAll();
                } catch (Exception ignored) {
                }
            }
        }
    }
}
