package com.cicp.jwxt;

import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.List;
import java.util.Map;

/**
 * WebViewClient that replays the app's session cookie for every request to the
 * jwxt host, so pages (and their sub-resources) load as the logged-in user.
 */
public class CookieWebClient extends WebViewClient {

    private final String host;
    private final String cookie;
    private final int padTop;
    private final int padBottom;
    private String userCss = "";
    private String userJs = "";
    private static final String UA = "Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36";

    public CookieWebClient(String host, String cookie) {
        this(host, cookie, 0, 0);
    }

    public CookieWebClient(String host, String cookie, int padTop, int padBottom) {
        this.host = host;
        this.cookie = cookie == null ? "" : cookie;
        this.padTop = padTop;
        this.padBottom = padBottom;
    }

    /** 教务页面：上下留白，避免顶到状态栏；应用自己的页面：去掉留白 */
    private void applyInset(WebView view, String url) {
        try {
            boolean third = url != null && url.contains(host);
            view.setPadding(0, third ? padTop : 0, 0, third ? padBottom : 0);
            view.setBackgroundColor(third ? 0xFFFFFFFF : 0x00000000);
        } catch (Throwable ignored) {
        }
    }

    @Override
    public void onPageStarted(WebView view, String url, android.graphics.Bitmap favicon) {
        applyInset(view, url);
        super.onPageStarted(view, url, favicon);
    }

    private static final String MOBILE_JS =
        "(function(){try{"
        + "var id='jwxt-mobile-js',old=document.getElementById(id);if(old)old.parentNode.removeChild(old);"
        + "var s=document.createElement('style');s.id=id;"
        + "s.textContent='.sidebar,.new-main .main .sidebar{display:none!important}'"
        + "+'.main,.new-main .main{margin-left:0!important;padding-left:0!important;width:100%!important}'"
        + "+'.iframeClass,#iframeClass{margin-left:0!important;padding-left:0!important;width:100%!important;left:0!important}'"
        + "+'body{overflow-x:hidden!important}'"
        + "+'.top div{width:auto!important}';"
        + "document.documentElement.appendChild(s);"
        + "}catch(e){}})();";

    @Override
    public void onPageFinished(WebView view, String url) {
        applyInset(view, url);
        try {
            if (url != null && url.contains(host)) view.evaluateJavascript(MOBILE_JS, null);
        } catch (Throwable ignored) {
        }
        super.onPageFinished(view, url);
    }

    @Override
    public WebResourceResponse shouldInterceptRequest(WebView view, WebResourceRequest request) {
        try {
            String url = request.getUrl().toString();
            String h = request.getUrl().getHost();
            if (h == null || host == null || !h.equals(host)) return null;
            String method = request.getMethod();
            if (method != null && !"GET".equalsIgnoreCase(method)) return null;
            // HTML（含 iframe 子页）都注入适配样式；二进制资源在 fetch 里原样返回，不会损坏
            return fetch(url, insetStyle());
        } catch (Throwable t) {
            return null;
        }
    }

    private String guessMime(String url) {
        String u = url == null ? "" : url.toLowerCase();
        int q = u.indexOf('?');
        if (q > 0) u = u.substring(0, q);
        if (u.endsWith(".css")) return "text/css";
        if (u.endsWith(".js")) return "application/javascript";
        if (u.endsWith(".png")) return "image/png";
        if (u.endsWith(".jpg") || u.endsWith(".jpeg")) return "image/jpeg";
        if (u.endsWith(".gif")) return "image/gif";
        if (u.endsWith(".svg")) return "image/svg+xml";
        if (u.endsWith(".woff") || u.endsWith(".woff2") || u.endsWith(".ttf")) return "font/woff2";
        return "text/html";
    }

    public void setUserScript(String css, String js) {
        this.userCss = css == null ? "" : css;
        this.userJs = js == null ? "" : js;
    }

    /** 把 PC 版教务系统压成手机版：去掉固定宽度、隐藏侧栏、表格可横向滚动 */
    /** 上下留白 + 用户自定义样式/脚本，一起写进页面 */
    private static final String MOBILE_CSS =
        "html,body{width:auto!important;min-width:0!important;max-width:100%!important;}"
        + ".new-main .main .sidebar,.sidebar{display:none!important;}"
        + ".main,.new-main .main{margin-left:0!important;width:100%!important;}"
        + ".iframeClass,#iframeClass{padding-left:0!important;margin-left:0!important;width:100%!important;}"
        + ".new-main .main .sidebar.shrink + .iframeClass{padding-left:0!important;}"
        + ".top div{width:auto!important;}"
        + "body{overflow-x:hidden!important;}";

    private String insetStyle() {
        StringBuilder sb = new StringBuilder();
        if (padTop > 0 || padBottom > 0) {
            sb.append("<style id=\"jwxt-inset\">html{padding-top:").append(padTop)
              .append("px!important;padding-bottom:").append(padBottom)
              .append("px!important;box-sizing:border-box!important;background:#fff!important}")
              .append("body{background:#fff!important}</style>");
        }
        sb.append("<style id=\"jwxt-mobile\">").append(MOBILE_CSS).append("</style>");
        if (userCss.length() > 0) sb.append("<style id=\"jwxt-user\">").append(userCss).append("</style>");
        if (userJs.length() > 0) sb.append("<script id=\"jwxt-user-js\">")
                .append(userJs.replace("</script>", "<\\/script>")).append("</script>");
        return sb.length() == 0 ? null : sb.toString();
    }

    private WebResourceResponse fetch(String url, String injectCss) {
        HttpURLConnection c = null;
        try {
            c = (HttpURLConnection) new URL(url).openConnection();
            c.setRequestMethod("GET");
            c.setConnectTimeout(12000);
            c.setReadTimeout(18000);
            c.setInstanceFollowRedirects(true);
            c.setRequestProperty("User-Agent", UA);
            if (cookie.length() > 0) c.setRequestProperty("Cookie", cookie);
            int code = c.getResponseCode();
            if (code >= 400) return null;
            String mime = c.getContentType();
            String enc = "UTF-8";
            if (mime != null) {
                String[] bits = mime.split(";");
                mime = bits[0].trim();
                for (int i = 1; i < bits.length; i++) {
                    String b = bits[i].trim();
                    if (b.toLowerCase().startsWith("charset=")) {
                        enc = b.substring(8).trim();
                        break;
                    }
                }
            }
            if (mime == null || mime.length() == 0 || mime.indexOf('/') < 0) mime = guessMime(url);
            InputStream in = c.getInputStream();
            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            byte[] buf = new byte[8192];
            int n;
            while ((n = in.read(buf)) > 0) bos.write(buf, 0, n);
            in.close();
            byte[] raw = bos.toByteArray();
            boolean isHtml = mime != null && mime.toLowerCase().indexOf("html") >= 0;
            if (injectCss != null && isHtml && raw.length > 0) {
                String body = new String(raw, enc);
                int at = body.toLowerCase().indexOf("<head");
                int gt = at >= 0 ? body.indexOf('>', at) : -1;
                if (gt > 0) body = body.substring(0, gt + 1) + injectCss + body.substring(gt + 1);
                else body = injectCss + body;
                raw = body.getBytes(enc);
            }
            // 非 HTML（CSS/JS/图片）原样返回，不能解码再编码，否则二进制会被破坏
            return new WebResourceResponse(mime, enc, new ByteArrayInputStream(raw));
        } catch (Throwable t) {
            return null;
        } finally {
            if (c != null) c.disconnect();
        }
    }
}
