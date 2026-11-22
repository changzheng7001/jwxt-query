package com.cicp.jwxt;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.Environment;
import android.webkit.CookieManager;
import android.webkit.WebView;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.lang.reflect.Field;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.Map;

/**
 * 在应用内 WebView 打开教务系统模块页，并带上 App 已登录的会话。
 */
public class InAppOpen {

    // 进入原站页之前的 WebView 原始设置（-1 表示还没记录过）
    private static int sOrigTextZoom = -1;
    private static int sOrigOverview = -1;
    private static int sOrigWideViewport = -1;

    private static final String CICP_HOST = "jwxt.cicp.edu.cn";
    private static final String BASE = "https://" + CICP_HOST + "/";
    private static final String UA = "Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36";

    public static void open(final Activity act, String rawUrl) {
        if (act == null) return;

        // 原站页：交给独立的浏览器窗口（独立 Activity + 独立 WebView）。
        // 不再和主界面共用 WebView，所以任何设置都污染不到改造页面，
        // 退出即销毁，浏览历史也不会留在手机浏览器里。
        if (rawUrl != null && rawUrl.contains("native=1")) {
            try {
                android.content.Intent it = new android.content.Intent(act, WebActivity.class);
                it.putExtra("url", "https://jwxt.cicp.edu.cn/jsxsd/framework/xsMainV.htmlx");
                act.startActivity(it);
                return;
            } catch (Throwable ignored) {
            }
        }

        // 每次打开页面先把上一次的黑边摘掉；只有原站页会在后面重新装一条
        removeStatusStrip(act);
        final StringBuilder diag = new StringBuilder();
        final String cookie = readCookies(act, diag);
        diag.append("cookieLen=").append(cookie.length()).append('\n');

        final String url = normalize(rawUrl);
        // 先访问一次个人主页把会话“预热”，再取目标页，避免个别模块因入口不对跳登录
        String html = null;
        boolean warm = false;
        if (cookie.length() > 0) {
            String w = fetch(BASE + "jsxsd/framework/xsMain.jsp", cookie, diag);
            warm = w != null && w.length() > 0 && !isLoginPage(w);
            diag.append("warm=").append(warm).append('\n');
        }
        html = fetch(url, cookie, diag);
        if (!warm && html != null && isLoginPage(html) && cookie.length() > 0) {
            // 再试一次
            html = fetch(url, cookie, diag);
        }
        final String HOME = BASE + "jsxsd/framework/xsMain.jsp";
        if (html != null && isLoginPage(html) && !HOME.equals(url) && cookie.length() > 0) {
            // 目标页仍要求登录时兜底回完整主页，避免直接落到登录页
            String home = fetch(HOME, cookie, diag);
            if (home != null && home.length() > 0 && !isLoginPage(home)) {
                html = home;
                diag.append("fallbackHome=true\n");
            }
        }
        final String userCss;
        final String userJs;
        try {
            userCss = readUserFile(act, "jwxt-user.css");
            userJs = readUserFile(act, "jwxt-user.js");
        } catch (Throwable t) {
            throw new RuntimeException(t);
        }
        final boolean logged = html != null && html.length() > 0 && !isLoginPage(html);
        diag.append("htmlLen=").append(html == null ? -1 : html.length()).append(" logged=").append(logged).append('\n');
        writeDiag(act, diag.toString());

        final WebView w = webViewOf(act);
        if (w == null) return;

        try {
            CookieManager cm = CookieManager.getInstance();
            cm.setAcceptCookie(true);
            if (cookie.length() > 0) {
                String[] parts = cookie.split(";");
                for (int i = 0; i < parts.length; i++) {
                    String kv = parts[i].trim();
                    if (kv.length() == 0 || kv.indexOf('=') <= 0) continue;
                    cm.setCookie(BASE, kv);
                    cm.setCookie(url, kv);
                }
                cm.flush();
            }
        } catch (Throwable ignored) {
        }

        if (!logged) {
            // 会话已失效：保持当前应用页面，直接弹应用内的登录框
            final String js = "(function(){window.__pendingOfficialUrl=" + jsStr(url) + ";"
                    + "try{if(window.scheduleTip)scheduleTip('\u767b\u5f55\u5df2\u8fc7\u671f\uff0c\u767b\u5f55\u540e\u4f1a\u76f4\u63a5\u6253\u5f00\u5b98\u7f51');}catch(e){}"
                    + "try{if(window.showLogin)showLogin();}catch(e){}"
                    + "})();";
            final boolean[] ok = {false};
            w.post(new Runnable() {
                @Override
                public void run() {
                    try {
                        w.evaluateJavascript(js, null);
                        ok[0] = true;
                    } catch (Throwable ignored) {
                    }
                    if (!ok[0]) {
                        try {
                            w.loadDataWithBaseURL(BASE, diagHtml(url, diag, cookie.length() > 0), "text/html", "UTF-8", url);
                        } catch (Throwable ignored) {
                        }
                    }
                }
            });
            return;
        }
        w.post(new Runnable() {
            @Override
            public void run() {
                try {
                    android.webkit.WebSettings ws = w.getSettings();
                    ws.setJavaScriptEnabled(true);
                    ws.setDomStorageEnabled(true);
                    ws.setSupportZoom(true);
                    ws.setBuiltInZoomControls(true);
                    ws.setDisplayZoomControls(false);
                    // 跟随系统字体缩放，页面字号与手机设置一致
                    int fz = 100;
                    try {
                        fz = Math.round(act.getResources().getConfiguration().fontScale * 100f);
                        if (fz < 80) fz = 80;
                        if (fz > 200) fz = 200;
                    } catch (Throwable ignored) {
                    }
                    ws.setTextZoom(fz);
                    ws.setUserAgentString(UA);
                    ws.setUseWideViewPort(true);
                    ws.setLoadWithOverviewMode(true);
                    ws.setDefaultTextEncodingName("UTF-8");
                } catch (Throwable ignored) {
                }
                try {
                    float d = act.getResources().getDisplayMetrics().density;
                    int sb = 0;
                    try {
                        int rid = act.getResources().getIdentifier("status_bar_height", "dimen", "android");
                        if (rid > 0) sb = act.getResources().getDimensionPixelSize(rid);
                    } catch (Throwable ignored) {
                    }
                    // 状态栏高度在这里取不到可靠值（Android 15 上 status_bar_height 常返回 0），
                    // 顶部留白改由页面自己的 safe 区处理，这里保持 0，避免和页面留白叠加
                    int top = 0;
                    int bottom = 0;
                    CookieWebClient client = new CookieWebClient(CICP_HOST, cookie, top, bottom);
                    try { client.setUserScript(userCss, userJs); } catch (Throwable ignored) {
                    }
                    w.setWebViewClient(client);
                } catch (Throwable ignored) {
                }
                try {
                    float d2 = act.getResources().getDisplayMetrics().density;
                    int sb2 = 0;
                    try {
                        int rid2 = act.getResources().getIdentifier("status_bar_height", "dimen", "android");
                        if (rid2 > 0) sb2 = act.getResources().getDimensionPixelSize(rid2);
                    } catch (Throwable ignored) {
                    }
                    if (url != null && url.contains("native=1")) {
                        // 原站页：不再动父容器留白、不加任何浮层 View、不改任何 WebSettings。
                        // 顶部黑条已经改成页面内的 CSS（html 顶部内边距 + 黑底），
                        // 随页面一起消失，退出时不会有任何痕迹留到改造页面。
                        w.setPadding(0, 0, 0, 0);
                        // 清掉旧版本可能残留在父容器上的留白
                        try {
                            android.view.ViewGroup pv = (android.view.ViewGroup) w.getParent();
                            if (pv != null) pv.setPadding(0, 0, 0, 0);
                        } catch (Throwable ignored) {
                        }
                        removeStatusStrip(act);
                        removeDebugHud(act);
                    } else {
                        // 非原站页：清掉留白，并且主动把黑边摘掉，保证它不会出现在别的页面
                        w.setPadding(0, 0, 0, 0);
                        try {
                            android.view.ViewGroup parent0 = (android.view.ViewGroup) w.getParent();
                            if (parent0 != null) parent0.setPadding(0, 0, 0, 0);
                        } catch (Throwable ignored) {
                        }
                        removeStatusStrip(act);
                    }
                    w.setBackgroundColor(0xFFFFFFFF);
                    w.setClipToPadding(true);
                } catch (Throwable ignored) {
                }
                try {
                    if (logged) {
                        // 走真实 URL 加载（拦截器负责带会话），页面上下文、样式、缩放都和正常浏览一致
                        w.loadUrl(url);
                    } else {
                        w.loadDataWithBaseURL(BASE, diagHtml(url, diag, cookie.length() > 0), "text/html", "UTF-8", url);
                    }
                } catch (Throwable ignored) {
                }
            }
        });
    }

    private static String diagHtml(String url, StringBuilder diag, boolean hasCookie) {
        String d = diag.toString().replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
        String title = hasCookie ? "登录状态已过期" : "还没登录";
        String desc = hasCookie
                ? "教务系统已经把你登出了，先在应用里重新登录，再点「前往官网」就能直接进去。"
                : "先在应用里登录教务系统，再点「前往官网」就能直接进去。";
        return "<html><head><meta name='viewport' content='width=device-width,initial-scale=1'>"
                + "<style>body{font:15px/1.7 -apple-system,'PingFang SC',sans-serif;margin:0;padding:26px 20px;color:#1a1a17;background:#faf7ef}"
                + "h3{font-size:19px;margin:0 0 10px}p{color:#6b6455;margin:0 0 22px}"
                + ".btns{display:flex;gap:10px;flex-wrap:wrap}"
                + "button{flex:1;min-width:120px;min-height:46px;border-radius:12px;border:1px solid #2e4a2a;background:#2e4a2a;color:#fff;font-size:15px}"
                + "button.ghost{background:transparent;color:#2e4a2a}"
                + "details{margin-top:26px;font-size:12px;color:#9a9484}"
                + "pre{white-space:pre-wrap;word-break:break-all;background:#f0ece0;padding:10px;border-radius:8px;font-size:11px;color:#57503f}"
                + "a{color:#2e4a2a}</style></head><body>"
                + "<h3>" + title + "</h3><p>" + desc + "</p>"
                + "<div class='btns'>"
                + "<button onclick=\"try{Android.showNativeLogin()}catch(e){}\">重新登录</button>"
                + "<button class='ghost' onclick=\"try{Android.backToApp()}catch(e){try{history.back()}catch(e2){}}\">返回应用</button>"
                + "</div>"
                + "<details><summary>诊断信息</summary><pre>" + d + "</pre>"
                + "<p><a href='" + url + "'>直接打开原页面</a></p></details>"
                + "</body></html>";
    }

    private static String titleOf(String html) {
        try {
            int a = html.indexOf("<title>");
            if (a < 0) return "";
            int b = html.indexOf("</title>", a);
            if (b < 0) return "";
            return html.substring(a + 7, b).trim();
        } catch (Throwable t) {
            return "";
        }
    }

    /** 根路径直接是登录页，统一改到个人主页 */
    private static String normalize(String u) {
        if (u == null) return BASE + "jsxsd/framework/xsMain.jsp";
        String s = u.trim();
        if (s.length() == 0) return BASE + "jsxsd/framework/xsMain.jsp";
        if (s.equals(CICP_HOST) || s.equals("http://" + CICP_HOST) || s.equals("https://" + CICP_HOST)
                || s.equals("http://" + CICP_HOST + "/") || s.equals("https://" + CICP_HOST + "/")
                || s.endsWith("/jsxsd") || s.endsWith("/jsxsd/")) {
            return BASE + "jsxsd/framework/xsMain.jsp";
        }
        return s;
    }

    private static boolean isLoginPage(String html) {
        String t = titleOf(html);
        if (t.length() == 0) {
            return html.contains("name=\"userKey\"") || html.contains("id=\"userKey\"");
        }
        if (t.indexOf("中警院") >= 0) return false;
        return t.equals("登录") || (t.indexOf("登录") >= 0 && t.length() <= 8);
    }

    private static String fetch(String url, String cookie, StringBuilder diag) {
        HttpURLConnection c = null;
        try {
            c = (HttpURLConnection) new URL(url).openConnection();
            c.setRequestMethod("GET");
            c.setConnectTimeout(15000);
            c.setReadTimeout(20000);
            c.setInstanceFollowRedirects(true);
            c.setRequestProperty("User-Agent", UA);
            if (cookie.length() > 0) c.setRequestProperty("Cookie", cookie);
            int code = c.getResponseCode();
            diag.append("url=").append(url).append(" code=").append(code)
                .append(" loc=").append(c.getHeaderField("Location")).append('\n');
            Map<String, java.util.List<String>> hs = c.getHeaderFields();
            if (hs != null) {
                for (Map.Entry<String, java.util.List<String>> e : hs.entrySet()) {
                    if (e.getKey() != null && e.getKey().equalsIgnoreCase("Set-Cookie")) {
                        diag.append("sc=").append(e.getValue()).append('\n');
                    }
                }
            }
            if (code >= 400) return null;
            InputStream in = c.getInputStream();
            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            byte[] buf = new byte[8192];
            int n;
            while ((n = in.read(buf)) > 0) bos.write(buf, 0, n);
            in.close();
            String body = new String(bos.toByteArray(), "UTF-8");
            diag.append("len=").append(body.length()).append(" title=").append(titleOf(body)).append('\n');
            return body;
        } catch (Throwable t) {
            diag.append("fetchErr=").append(t).append('\n');
            return null;
        } finally {
            if (c != null) c.disconnect();
        }
    }

    /** 读取用户自定义脚本：优先 App 外部私有目录，其次下载目录 */
    private static String readUserFile(Activity act, String name) {
        try {
            File d = act.getExternalFilesDir(null);
            if (d != null) {
                if (!d.exists()) d.mkdirs();
                File f = new File(d, name);
                if (!f.exists()) {
                    if (name.endsWith(".css")) {
                        writeText(f, "/* \u81ea\u5b9a\u4e49\u6837\u5f0f\uff1a\u6bcf\u6b21\u6253\u5f00\u5b98\u7f51\u90fd\u4f1a\u91cd\u65b0\u8bfb\u53d6\uff0c\u6539\u5b8c\u91cd\u5f00\u5c31\u751f\u6548 */\n"
                                + "/* \u4f8b\uff1a\u5b57\u53f7\u653e\u5927  body{font-size:15px!important} */\n"
                                + "/* \u4f8b\uff1a\u9690\u85cf\u9876\u90e8\u5bfc\u822a .header,.top{display:none!important} */\n");
                    } else {
                        writeText(f, "// \u81ea\u5b9a\u4e49\u811a\u672c\uff1a\u6bcf\u6b21\u6253\u5f00\u5b98\u7f51\u90fd\u4f1a\u91cd\u65b0\u8bfb\u53d6\n"
                                + "// \u4f8b\uff1adocument.body.style.fontSize='15px';\n");
                    }
                }
                String txt = readAll(f);
                if (txt != null && txt.trim().length() > 0) return txt;
            }
        } catch (Throwable ignored) {
        }
        String[] alt = {"/sdcard/Download/" + name, "/storage/emulated/0/Download/" + name};
        for (int i = 0; i < alt.length; i++) {
            try {
                File f = new File(alt[i]);
                if (f.exists()) {
                    String txt = readAll(f);
                    if (txt != null && txt.trim().length() > 0) return txt;
                }
            } catch (Throwable ignored) {
            }
        }
        return "";
    }

    private static String readAll(File f) {
        try {
            java.io.FileInputStream in = new java.io.FileInputStream(f);
            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            byte[] b = new byte[8192];
            int n;
            while ((n = in.read(b)) > 0) bos.write(b, 0, n);
            in.close();
            return new String(bos.toByteArray(), "UTF-8");
        } catch (Throwable t) {
            return null;
        }
    }

    private static void writeText(File f, String s) {
        try {
            FileOutputStream out = new FileOutputStream(f, false);
            out.write(s.getBytes("UTF-8"));
            out.close();
        } catch (Throwable ignored) {
        }
    }

    private static String jsStr(String s) {
        if (s == null) return "''";
        StringBuilder sb = new StringBuilder("'");
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            if (c == '\\' || c == '\'') sb.append('\\');
            sb.append(c);
        }
        return sb.append('\'').toString();
    }

    private static WebView webViewOf(Activity act) {
        try {
            Field f = act.getClass().getDeclaredField("webView");
            f.setAccessible(true);
            return (WebView) f.get(act);
        } catch (Throwable t) {
            return null;
        }
    }

    public static String readCookies(Context ctx, StringBuilder diag) {
        ArrayList<String> cand = new ArrayList<String>();
        try {
            Field f = ctx.getClass().getDeclaredField("cookieStore");
            f.setAccessible(true);
            Object v = f.get(ctx);
            diag.append("field=").append(v == null ? "null" : v.toString()).append('\n');
            if (v != null && v.toString().trim().length() > 0) cand.add(v.toString().trim());
        } catch (Throwable t) {
            diag.append("fieldErr=").append(t).append('\n');
        }
        try {
            SharedPreferences sp = ctx.getSharedPreferences("jwxt", Context.MODE_PRIVATE);
            String s = sp.getString("cookies", "");
            if (s != null && s.trim().length() > 0) cand.add(s.trim());
        } catch (Throwable ignored) {
        }
        // 扫描应用自己的 shared_prefs，任何含 JSESSIONID / bzb_jsxsd 的值都收进来
        try {
            File dir = new File(ctx.getApplicationInfo().dataDir, "shared_prefs");
            File[] fs = dir.listFiles();
            if (fs != null) {
                for (int i = 0; i < fs.length; i++) {
                    String txt = readText(fs[i], 65536);
                    if (txt == null) continue;
                    if (txt.contains("JSESSIONID") || txt.contains("bzb_jsxsd")) {
                        diag.append("spFile=").append(fs[i].getName()).append('\n').append(shrink(txt)).append('\n');
                        String ck = extractCookie(txt);
                        if (ck != null && ck.length() > 0) cand.add(ck);
                    }
                }
            }
        } catch (Throwable t) {
            diag.append("spScanErr=").append(t).append('\n');
        }
        String best = "";
        for (int i = 0; i < cand.size(); i++) {
            if (cand.get(i).length() > best.length()) best = cand.get(i);
        }
        return best;
    }

    private static String extractCookie(String xml) {
        int i = xml.indexOf("JSESSIONID=");
        if (i < 0) i = xml.indexOf("bzb_jsxsd=");
        if (i < 0) return null;
        int start = i;
        while (start > 0) {
            char ch = xml.charAt(start - 1);
            if (ch == '>' || ch == '"' || ch == '\n' || ch == '\r') break;
            start--;
        }
        int end = xml.indexOf('<', i);
        if (end < 0) end = xml.length();
        String s = xml.substring(start, end).trim();
        s = s.replace("&amp;", "&").replace("&quot;", "\"").replace("&lt;", "<").replace("&gt;", ">");
        return s;
    }

    private static String shrink(String s) {
        if (s.length() <= 600) return s;
        return s.substring(0, 600) + "...";
    }

    private static String readText(File f, int max) {
        try {
            java.io.FileInputStream in = new java.io.FileInputStream(f);
            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            byte[] b = new byte[8192];
            int n;
            while ((n = in.read(b)) > 0) {
                bos.write(b, 0, n);
                if (bos.size() > max) break;
            }
            in.close();
            return new String(bos.toByteArray(), "UTF-8");
        } catch (Throwable t) {
            return null;
        }
    }

    /** 诊断信息：写 logcat；仅在应用私有缓存留一份，不写公共 Download */
    private static void writeDiag(Context ctx, String s) {
        android.util.Log.w("JWXT", "official-page diag (" + (s == null ? 0 : s.length()) + " chars)");
        try {
            java.io.File dir = new java.io.File(ctx.getCacheDir(), "logs");
            if (!dir.exists()) dir.mkdirs();
            java.io.FileOutputStream out = new java.io.FileOutputStream(new java.io.File(dir, "jwxt_diag.txt"), false);
            out.write(s == null ? new byte[0] : s.getBytes("UTF-8"));
            out.close();
        } catch (Throwable ignored) {
        }
    }

    /**
     * 给原站页面加一条浏览器式顶栏：返回箭头 + 网址胶囊 + 关闭按钮，底部一条 1px 分隔线。
     * 顶栏加在 decorView 上（WebView 已让出对应高度，不会遮挡网页内容）。
     * 用 800ms 轮询 URL 的方式在离开原站页时自动移除，避免回到 App 主页后残留挡住顶栏。
     */
    /**
     * 在状态栏位置放一条固定黑条：不随网页滚动或缩放变化，只作为「网页从哪开始」的边界。
     * 高度即让出的状态栏高度，整宽铺满，WebView 的 padding 已经让开了这块，不会遮挡内容。
     */

    /**
     * 诊断角标（临时）：屏幕左下角实时显示 WebView 的缩放比例、控件尺寸、可见性、当前地址。
     * 用于判断「页面跳一下 / logo 变大」到底是 WebView 改了比例，还是页面自己改了布局。
     */
    private static void addDebugHud(final Activity act, final WebView w) {
        try {
            if (!(act.getWindow().getDecorView() instanceof android.widget.FrameLayout)) return;
            final android.widget.FrameLayout root =
                    (android.widget.FrameLayout) act.getWindow().getDecorView();
            android.view.View old = root.findViewWithTag("jwxt_hud");
            if (old != null) root.removeView(old);

            final android.widget.TextView tv = new android.widget.TextView(act);
            tv.setTag("jwxt_hud");
            tv.setTextSize(11f);
            tv.setTextColor(0xFFFFFFFF);
            tv.setBackgroundColor(0xCC000000);
            tv.setPadding(16, 10, 16, 10);
            android.widget.FrameLayout.LayoutParams lp = new android.widget.FrameLayout.LayoutParams(
                    android.view.ViewGroup.LayoutParams.WRAP_CONTENT,
                    android.view.ViewGroup.LayoutParams.WRAP_CONTENT);
            lp.gravity = android.view.Gravity.BOTTOM | android.view.Gravity.START;
            lp.bottomMargin = 140;
            lp.leftMargin = 24;
            root.addView(tv, lp);

            final Runnable r = new Runnable() {
                public void run() {
                    try {
                        if (w.getVisibility() != android.view.View.VISIBLE) {
                            android.view.View alive = root.findViewWithTag("jwxt_hud");
                            if (alive != null) root.removeView(alive);
                            return;
                        }
                        String u = w.getUrl();
                        if (u != null) u = u.replace("https://jwxt.cicp.edu.cn", "");
                        if (u != null && u.length() > 46) u = u.substring(0, 46);
                        String txt = "scale=" + String.format(java.util.Locale.US, "%.3f", w.getScale())
                                + "  size=" + w.getWidth() + "x" + w.getHeight()
                                + "  vis=" + (w.getVisibility() == android.view.View.VISIBLE ? "Y" : "N")
                                + "\n" + u;
                        tv.setText(txt);
                        w.postDelayed(this, 400);
                    } catch (Throwable ignored) {
                    }
                }
            };
            w.postDelayed(r, 400);
        } catch (Throwable ignored) {
        }
    }


    /**
     * 离开原站页时把 WebView 恢复成进入前的样子。
     * 之前所有 native 设置（黑边、角标、overview、textZoom、留白）都只设不清，
     * 而"返回"根本不经过 open()，所以 else 里的清理从来没执行过 —— 这些痕迹就全被带回改造页面了。
     */
    private static void restoreNativeState(final Activity act, final WebView w) {
        try { removeStatusStrip(act); } catch (Throwable ignored) { }
        try { removeDebugHud(act); } catch (Throwable ignored) { }
        try {
            android.webkit.WebSettings ws = w.getSettings();
            if (sOrigTextZoom > 0) ws.setTextZoom(sOrigTextZoom);
            if (sOrigOverview >= 0) ws.setLoadWithOverviewMode(sOrigOverview == 1);
            if (sOrigWideViewport >= 0) ws.setUseWideViewPort(sOrigWideViewport == 1);
        } catch (Throwable ignored) { }
        try {
            android.view.ViewGroup p = (android.view.ViewGroup) w.getParent();
            if (p != null) p.setPadding(0, 0, 0, 0);
        } catch (Throwable ignored) { }
    }


    /** 摘掉诊断角标 */
    private static void removeDebugHud(final Activity act) {
        try {
            if (!(act.getWindow().getDecorView() instanceof android.widget.FrameLayout)) return;
            android.widget.FrameLayout root = (android.widget.FrameLayout) act.getWindow().getDecorView();
            android.view.View v = root.findViewWithTag("jwxt_hud");
            if (v != null) root.removeView(v);
        } catch (Throwable ignored) {
        }
    }

    /** 主动摘掉顶部黑边（离开原站页时调用，避免残留到其他页面） */
    private static void removeStatusStrip(final Activity act) {
        try {
            if (!(act.getWindow().getDecorView() instanceof android.widget.FrameLayout)) return;
            android.widget.FrameLayout root = (android.widget.FrameLayout) act.getWindow().getDecorView();
            android.view.View v = root.findViewWithTag("jwxt_status_strip");
            if (v != null) root.removeView(v);
        } catch (Throwable ignored) {
        }
    }

    private static void addStatusStrip(final Activity act, final WebView w, final int heightPx) {
        try {
            if (!(act.getWindow().getDecorView() instanceof android.widget.FrameLayout)) return;
            final android.widget.FrameLayout root = (android.widget.FrameLayout) act.getWindow().getDecorView();
            android.view.View oldStrip = root.findViewWithTag("jwxt_status_strip");
            if (oldStrip != null) root.removeView(oldStrip);

            android.view.View strip = new android.view.View(act);
            strip.setTag("jwxt_status_strip");
            strip.setBackgroundColor(0xFF000000);
            android.widget.FrameLayout.LayoutParams lp =
                    new android.widget.FrameLayout.LayoutParams(android.view.ViewGroup.LayoutParams.MATCH_PARENT, heightPx);
            lp.gravity = android.view.Gravity.TOP;
            root.addView(strip, lp);

            // 离开原站页时自动移除，避免回到 App 首页还留一条黑边
            final Runnable watch = new Runnable() {
                public void run() {
                    try {
                        String cur = w.getUrl();
                        // 关键：WebView 是 Activity 里复用的同一个（webViewOf 反射取字段），
                        // 从来不会「退役」，也不会自动变成 file://。回到改造页面时它是被
                        // setVisibility(GONE) 隐藏的，但 getUrl() 还停在原站页地址上，
                        // 所以之前只看 URL 永远摘不掉这条黑边。真正的信号是「WebView 不可见」。
                        if (w.getVisibility() != android.view.View.VISIBLE || cur == null
                                || cur.startsWith("file://") || !cur.contains("/jsxsd/")) {
                            // 现查现摘：不依赖闭包里的旧引用，避免 View 已被替换后 removeView 空转
                            android.view.View alive = root.findViewWithTag("jwxt_status_strip");
                            if (alive != null) root.removeView(alive);
                            // 黑边摘掉的同时，把 native 期间改过的 WebView 设置一并还原，
                            // 否则 overview / textZoom / 留白 会跟着带回改造页面
                            restoreNativeState(act, w);
                            return;
                        }
                        w.postDelayed(this, 300);
                    } catch (Throwable ignored) {
                    }
                }
            };
            w.postDelayed(watch, 800);
        } catch (Throwable ignored) {
        }
    }

}
