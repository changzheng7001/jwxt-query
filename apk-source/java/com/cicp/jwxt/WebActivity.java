package com.cicp.jwxt;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.view.ViewGroup;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.FrameLayout;

/**
 * App 内的独立浏览器窗口。
 *
 * 和主界面用的那个 WebView 完全分开：独立的 Activity、独立的 WebView、独立的浏览历史
 * （退出即销毁，不会和手机浏览器共享记录）。配置一律用系统默认，
 * 页面自带的 viewport 原样生效 —— 这正是系统浏览器里"完美显示"的同一套机制。
 */
public class WebActivity extends Activity {

    private WebView webView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        String url = null;
        try {
            Intent it = getIntent();
            if (it != null) url = it.getStringExtra("url");
        } catch (Throwable ignored) {
        }
        if (url == null || url.length() == 0) {
            url = "https://jwxt.cicp.edu.cn/jsxsd/framework/xsMainV.htmlx";
        }

        float d = getResources().getDisplayMetrics().density;
        int top = (int) (40 * d);      // 顶部黑条高度
        int bottom = (int) (26 * d);   // 底部手势条高度

        FrameLayout root = new FrameLayout(this);
        root.setBackgroundColor(Color.BLACK);   // 让出来的那条就是固定黑边

        webView = new WebView(this);
        WebSettings ws = webView.getSettings();
        // 全部用默认值，不做任何页面级干预
        ws.setJavaScriptEnabled(true);
        ws.setDomStorageEnabled(true);
        ws.setSupportZoom(true);
        ws.setBuiltInZoomControls(true);
        ws.setDisplayZoomControls(false);
        ws.setUserAgentString(CookieWebClient.UA());
        ws.setUseWideViewPort(true);         // 尊重页面自带 viewport（与浏览器一致）
        ws.setLoadWithOverviewMode(true);    // 按页面声明的宽度适配屏幕（与浏览器一致）
        try {
            int fz = Math.round(getResources().getConfiguration().fontScale * 100f);
            if (fz < 80) fz = 80;
            if (fz > 200) fz = 200;
            ws.setTextZoom(fz);
        } catch (Throwable ignored) {
        }
        webView.setWebViewClient(new WebViewClient());

        FrameLayout.LayoutParams lp = new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        lp.topMargin = top;
        lp.bottomMargin = bottom;
        root.addView(webView, lp);

        setContentView(root);
        boolean inapp = false;
        try { inapp = getIntent() != null && getIntent().getBooleanExtra("inapp", false); } catch (Throwable ignored) {}
        if (inapp) {
            // 应用内官网：独立 Activity 承载，MainActivity 的页面原封不动，返回即回到上一页
            lp.topMargin = 0; lp.bottomMargin = 0; webView.requestLayout();
            webView.addJavascriptInterface(new Bridge(), "Android");
            // 直接加载：登录 Cookie 由主界面通过 Intent 传入，缺失时才回退本地存储读取。
            // 不再走 InAppOpen.open（它会在主线程同步抓页面，独立 Activity 冷启动时会长时间黑屏）。
            String cookie = null;
            try {
                Intent it = getIntent();
                if (it != null) cookie = it.getStringExtra("cookie");
            } catch (Throwable ignored) {
            }
            if (cookie == null || cookie.length() == 0) {
                try {
                    cookie = InAppOpen.readCookies(this, new StringBuilder());
                } catch (Throwable ignored) {
                }
            }
            try {
                CookieWebClient client = new CookieWebClient("jwxt.cicp.edu.cn", cookie, 0, 0);
                webView.setWebViewClient(client);
            } catch (Throwable ignored) {
            }
            webView.loadUrl(url);
            // 旧打开管线（会话预热 + 手机适配 + 自定义注入 + 登录兜底诊断页）放后台线程跑，
            // 避免主线程同步抓页导致冷启动黑屏；完成后 post 回主线程重载适配页。
            try {
                final Activity a = this;
                final String u = url;
                new Thread(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            InAppOpen.open(a, u);
                        } catch (Throwable ignored) {
                        }
                    }
                }).start();
            } catch (Throwable ignored) {
            }
        } else {
            webView.loadUrl(url);   // CookieManager 是全局的，登录态自动带上
        }
    }

    @Override
    public void onBackPressed() {
        try {
            if (webView != null && webView.canGoBack()) {
                webView.goBack();
                return;
            }
        } catch (Throwable ignored) {
        }
        super.onBackPressed();
    }

    @Override
    protected void onDestroy() {
        try {
            if (webView != null) {
                webView.stopLoading();
                webView.setWebViewClient(new WebViewClient());
                ((ViewGroup) webView.getParent()).removeView(webView);
                webView.destroy();
                webView = null;
            }
        } catch (Throwable ignored) {
        }
        super.onDestroy();
    }

    /** 官网诊断页按钮桥：返回应用=关掉本页；重新登录=原生登录弹窗 */
    public class Bridge {
        @android.webkit.JavascriptInterface
        public void backToApp() { finish(); }
        @android.webkit.JavascriptInterface
        public void showNativeLogin() { NativeLogin.show(WebActivity.this); }
    }
}
