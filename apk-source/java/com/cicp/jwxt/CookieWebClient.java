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
        + "+'.container,.content,.main-content,.main_content,.mainbody,.mainBody,.wrap,.wrapper,.box,.panel,.contentbox,.new-main,.index-main{width:auto!important;min-width:0!important;max-width:100%!important;margin-left:0!important}'"
        + "+'table{max-width:none!important}'"
        + "+'.kbcontent1,.kbcontent,.kb{white-space:normal!important;word-break:break-all!important}'"
        + "+'img{max-width:100%!important;height:auto!important}'"
        + "+'body{overflow-x:auto!important}'"
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
            String inject = insetStyle();
            // 目标查询页带回填条件：注入脚本把条件填进表单并提交，实现带参数跳转
            String q = extractQuery(url);
            if (q != null) inject = inject + prefillScript(q);
            return fetch(url, inject);
        } catch (Throwable t) {
            return null;
        }
    }

    /** 从 URL 里取出 __q 参数（已 URL 编码的 JSON），做白名单过滤后返回 */
    private static String extractQuery(String url) {
        if (url == null) return null;
        int i = url.indexOf("__q=");
        if (i < 0) return null;
        String s = url.substring(i + 4);
        int amp = s.indexOf('&');
        if (amp >= 0) s = s.substring(0, amp);
        int hash = s.indexOf('#');
        if (hash >= 0) s = s.substring(0, hash);
        if (s.length() == 0 || s.length() > 2048) return null;
        StringBuilder ok = new StringBuilder(s.length());
        for (int k = 0; k < s.length(); k++) {
            char c = s.charAt(k);
            if ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9')
                    || c == '%' || c == '-' || c == '_' || c == '.' || c == '~'
                    || c == '!' || c == '*' || c == '\'' || c == '(' || c == ')') {
                ok.append(c);
            }
        }
        return ok.length() == 0 ? null : ok.toString();
    }

    /** 把查询条件回填到官网表单并自动提交，让「前往官网」带着当前条件进去 */
    private static String prefillScript(String encodedJson) {
        String js =
            "(function(){"
            + "var raw=\"" + encodedJson + "\";"
            + "var q=null;try{q=JSON.parse(decodeURIComponent(raw));}catch(e){return;}"
            + "if(!q||!q.t)return;"
            + "function setv(n,v){"
            + "if(v==null||v==='')return;"
            + "var el=document.querySelector('[name=\"'+n+'\"]');if(!el)return;"
            + "if(el.tagName==='SELECT'){"
            + "var hit=-1,i;"
            + "for(i=0;i<el.options.length;i++){if(el.options[i].value===v){hit=i;break;}}"
            + "if(hit<0&&/^\\d+$/.test(v)){var pad=('0'+v).slice(-2);for(i=0;i<el.options.length;i++){if(el.options[i].value===pad){hit=i;break;}}}"
            + "if(hit<0){for(i=0;i<el.options.length;i++){if((el.options[i].text||'').replace(/\\s+/g,'')===v){hit=i;break;}}}"
            + "if(hit>=0)el.selectedIndex=hit;"
            + "}else{el.value=v;}"
            + "try{el.dispatchEvent(new Event('change',{bubbles:true}));}catch(e){}"
            + "try{if(window.jQuery)jQuery(el).trigger('change');}catch(e){}"
            + "}"
            + "function run(){"
            + "try{setv('xnxqh',q.sem);}catch(e){}"
            + "try{"
            + "if(q.t==='teacher'||q.t==='classroom')setv('skjs',q.name);"
            + "else if(q.t==='class')setv('skbj',q.name);"
            + "else if(q.t==='course')setv('kcmc',q.name);"
            + "}catch(e){}"
            + "if(q.week){try{setv('zc1',q.week);setv('zc2',q.week);}catch(e){}}"
            + "var f=document.getElementById('Form1');"
            + "if(f){try{f.submit();}catch(e){}}"
            + "}"
            + "setTimeout(run,350);"
            + "})();";
        return "<script id=\"jwxt-prefill\">" + js + "</script>";
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

    /** 把 PC 版教务系统压成手机版：主文档和 iframe 子页都要适配 */
    /** 上下留白 + 用户自定义样式/脚本，一起写进页面 */
    private static final String MOBILE_CSS =
        // 基础：文档宽度跟随屏幕，禁止出现横向溢出
        "html,body{width:auto!important;min-width:0!important;max-width:100%!important;}"
        // 主文档：隐藏侧栏，主区去掉 left 偏移
        + ".new-main .main .sidebar,.sidebar{display:none!important;}"
        + ".main,.new-main .main{margin-left:0!important;padding-left:0!important;width:100%!important;}"
        + ".iframeClass,#iframeClass{padding-left:0!important;margin-left:0!important;width:100%!important;left:0!important;}"
        + ".new-main .main .sidebar.shrink + .iframeClass{padding-left:0!important;}"
        + ".top div{width:auto!important;}"
        // iframe 子页：常见固定宽度容器改为铺满
        + ".container,.content,.main-content,.main_content,.mainbody,.mainBody,.wrap,.wrapper,.box,.panel,.contentbox,.new-main,.index-main{"
        + "width:auto!important;min-width:0!important;max-width:100%!important;margin-left:0!important;margin-right:0!important;}"
        // 表格：保持自然宽度，宽表（如 49 列课表）交给外层横向滚动，避免压缩后无法阅读
        + "table{max-width:none!important;}"
        // 课表/格子内容允许换行，避免单格文字把列宽撑开
        + ".kbcontent1,.kbcontent,.kb,.td,.td1,.td2{white-space:normal!important;word-break:break-all!important;}"
        // 表单控件自适应，不再按固定 px 宽
        + "input[type=text],input[type=password],input[type=search],select,textarea{max-width:100%!important;box-sizing:border-box!important;}"
        // 图片不溢出
        + "img{max-width:100%!important;height:auto!important;}"
        // 横向滚动兜底：子页宽表可在页面内左右拖动
        + "body{overflow-x:auto!important;-webkit-overflow-scrolling:touch;}";

    /** PC 页面普遍没有 viewport，必须补一个，否则 WebView 仍按 980px 逻辑宽度渲染 */
    private static final String VIEWPORT_META =
        "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1,maximum-scale=3,user-scalable=yes\">";

    private String insetStyle() {
        StringBuilder sb = new StringBuilder();
        // viewport 必须放在最前面，先于任何样式生效
        sb.append(VIEWPORT_META);
        if (padTop > 0 || padBottom > 0) {
            sb.append("<style id=\"jwxt-inset\">html{padding-top:").append(padTop)
              .append("px!important;padding-bottom:").append(padBottom)
              .append("px!important;box-sizing:border-box!important;background:#fff!important}")
              .append("body{background:#fff!important}</style>");
        }
        sb.append("<style id=\"jwxt-mobile\">").append(MOBILE_CSS).append("</style>");
        if (userCss.length() > 0) sb.append("<style id=\"jwxt-user\">").append(userCss).append("</style>");
        if (userJs.length() > 0) {
            // 自定义脚本用 try/catch 包一层：脚本报错不能影响页面本身可用
            sb.append("<script id=\"jwxt-user-js\">try{")
              .append(userJs.replace("</script>", "<\\/script>"))
              .append("}catch(e){(function(){try{console.warn('[jwxt-user-js]',e);}catch(_){}})();}</script>");
        }
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
