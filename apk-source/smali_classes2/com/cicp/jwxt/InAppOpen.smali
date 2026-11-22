.class public Lcom/cicp/jwxt/InAppOpen;
.super Ljava/lang/Object;
.source "InAppOpen.java"


# static fields
.field private static final BASE:Ljava/lang/String; = "https://jwxt.cicp.edu.cn/"

.field private static final CICP_HOST:Ljava/lang/String; = "jwxt.cicp.edu.cn"

.field private static final UA:Ljava/lang/String; = "Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36"

.field private static sOrigOverview:I

.field private static sOrigTextZoom:I

.field private static sOrigWideViewport:I


# direct methods
.method static constructor <clinit>()V
    .registers 1

    .line 26
    const/4 v0, -0x1

    sput v0, Lcom/cicp/jwxt/InAppOpen;->sOrigTextZoom:I

    .line 27
    sput v0, Lcom/cicp/jwxt/InAppOpen;->sOrigOverview:I

    .line 28
    sput v0, Lcom/cicp/jwxt/InAppOpen;->sOrigWideViewport:I

    return-void
.end method

.method public constructor <init>()V
    .registers 1

    .line 23
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method static synthetic access$000(Ljava/lang/String;Ljava/lang/StringBuilder;Z)Ljava/lang/String;
    .registers 3

    .line 23
    invoke-static {p0, p1, p2}, Lcom/cicp/jwxt/InAppOpen;->diagHtml(Ljava/lang/String;Ljava/lang/StringBuilder;Z)Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method static synthetic access$100(Landroid/app/Activity;)V
    .registers 1

    .line 23
    invoke-static {p0}, Lcom/cicp/jwxt/InAppOpen;->removeStatusStrip(Landroid/app/Activity;)V

    return-void
.end method

.method static synthetic access$200(Landroid/app/Activity;)V
    .registers 1

    .line 23
    invoke-static {p0}, Lcom/cicp/jwxt/InAppOpen;->removeDebugHud(Landroid/app/Activity;)V

    return-void
.end method

.method static synthetic access$300(Landroid/app/Activity;Landroid/webkit/WebView;)V
    .registers 2

    .line 23
    invoke-static {p0, p1}, Lcom/cicp/jwxt/InAppOpen;->restoreNativeState(Landroid/app/Activity;Landroid/webkit/WebView;)V

    return-void
.end method

.method private static addDebugHud(Landroid/app/Activity;Landroid/webkit/WebView;)V
    .registers 5

    .line 555
    const-string v0, "jwxt_hud"

    :try_start_2
    invoke-virtual {p0}, Landroid/app/Activity;->getWindow()Landroid/view/Window;

    move-result-object v1

    invoke-virtual {v1}, Landroid/view/Window;->getDecorView()Landroid/view/View;

    move-result-object v1

    instance-of v1, v1, Landroid/widget/FrameLayout;

    if-nez v1, :cond_f

    return-void

    .line 556
    :cond_f
    nop

    .line 557
    invoke-virtual {p0}, Landroid/app/Activity;->getWindow()Landroid/view/Window;

    move-result-object v1

    invoke-virtual {v1}, Landroid/view/Window;->getDecorView()Landroid/view/View;

    move-result-object v1

    check-cast v1, Landroid/widget/FrameLayout;

    .line 558
    invoke-virtual {v1, v0}, Landroid/widget/FrameLayout;->findViewWithTag(Ljava/lang/Object;)Landroid/view/View;

    move-result-object v2

    .line 559
    if-eqz v2, :cond_23

    invoke-virtual {v1, v2}, Landroid/widget/FrameLayout;->removeView(Landroid/view/View;)V

    .line 561
    :cond_23
    new-instance v2, Landroid/widget/TextView;

    invoke-direct {v2, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    .line 562
    invoke-virtual {v2, v0}, Landroid/widget/TextView;->setTag(Ljava/lang/Object;)V

    .line 563
    const/high16 p0, 0x41300000    # 11.0f

    invoke-virtual {v2, p0}, Landroid/widget/TextView;->setTextSize(F)V

    .line 564
    const/4 p0, -0x1

    invoke-virtual {v2, p0}, Landroid/widget/TextView;->setTextColor(I)V

    .line 565
    const/high16 p0, -0x34000000    # -3.3554432E7f

    invoke-virtual {v2, p0}, Landroid/widget/TextView;->setBackgroundColor(I)V

    .line 566
    const/16 p0, 0xa

    const/16 v0, 0x10

    invoke-virtual {v2, v0, p0, v0, p0}, Landroid/widget/TextView;->setPadding(IIII)V

    .line 567
    new-instance p0, Landroid/widget/FrameLayout$LayoutParams;

    const/4 v0, -0x2

    invoke-direct {p0, v0, v0}, Landroid/widget/FrameLayout$LayoutParams;-><init>(II)V

    .line 570
    const v0, 0x800053

    iput v0, p0, Landroid/widget/FrameLayout$LayoutParams;->gravity:I

    .line 571
    const/16 v0, 0x8c

    iput v0, p0, Landroid/widget/FrameLayout$LayoutParams;->bottomMargin:I

    .line 572
    const/16 v0, 0x18

    iput v0, p0, Landroid/widget/FrameLayout$LayoutParams;->leftMargin:I

    .line 573
    invoke-virtual {v1, v2, p0}, Landroid/widget/FrameLayout;->addView(Landroid/view/View;Landroid/view/ViewGroup$LayoutParams;)V

    .line 575
    new-instance p0, Lcom/cicp/jwxt/InAppOpen$3;

    invoke-direct {p0, p1, v1, v2}, Lcom/cicp/jwxt/InAppOpen$3;-><init>(Landroid/webkit/WebView;Landroid/widget/FrameLayout;Landroid/widget/TextView;)V

    .line 596
    const-wide/16 v0, 0x190

    invoke-virtual {p1, p0, v0, v1}, Landroid/webkit/WebView;->postDelayed(Ljava/lang/Runnable;J)Z
    :try_end_60
    .catchall {:try_start_2 .. :try_end_60} :catchall_61

    .line 598
    goto :goto_62

    .line 597
    :catchall_61
    move-exception p0

    .line 599
    :goto_62
    return-void
.end method

.method private static addStatusStrip(Landroid/app/Activity;Landroid/webkit/WebView;I)V
    .registers 7

    .line 647
    const-string v0, "jwxt_status_strip"

    :try_start_2
    invoke-virtual {p0}, Landroid/app/Activity;->getWindow()Landroid/view/Window;

    move-result-object v1

    invoke-virtual {v1}, Landroid/view/Window;->getDecorView()Landroid/view/View;

    move-result-object v1

    instance-of v1, v1, Landroid/widget/FrameLayout;

    if-nez v1, :cond_f

    return-void

    .line 648
    :cond_f
    invoke-virtual {p0}, Landroid/app/Activity;->getWindow()Landroid/view/Window;

    move-result-object v1

    invoke-virtual {v1}, Landroid/view/Window;->getDecorView()Landroid/view/View;

    move-result-object v1

    check-cast v1, Landroid/widget/FrameLayout;

    .line 649
    invoke-virtual {v1, v0}, Landroid/widget/FrameLayout;->findViewWithTag(Ljava/lang/Object;)Landroid/view/View;

    move-result-object v2

    .line 650
    if-eqz v2, :cond_22

    invoke-virtual {v1, v2}, Landroid/widget/FrameLayout;->removeView(Landroid/view/View;)V

    .line 652
    :cond_22
    new-instance v2, Landroid/view/View;

    invoke-direct {v2, p0}, Landroid/view/View;-><init>(Landroid/content/Context;)V

    .line 653
    invoke-virtual {v2, v0}, Landroid/view/View;->setTag(Ljava/lang/Object;)V

    .line 654
    const/high16 v0, -0x1000000

    invoke-virtual {v2, v0}, Landroid/view/View;->setBackgroundColor(I)V

    .line 655
    new-instance v0, Landroid/widget/FrameLayout$LayoutParams;

    const/4 v3, -0x1

    invoke-direct {v0, v3, p2}, Landroid/widget/FrameLayout$LayoutParams;-><init>(II)V

    .line 657
    const/16 p2, 0x30

    iput p2, v0, Landroid/widget/FrameLayout$LayoutParams;->gravity:I

    .line 658
    invoke-virtual {v1, v2, v0}, Landroid/widget/FrameLayout;->addView(Landroid/view/View;Landroid/view/ViewGroup$LayoutParams;)V

    .line 661
    new-instance p2, Lcom/cicp/jwxt/InAppOpen$4;

    invoke-direct {p2, p1, v1, p0}, Lcom/cicp/jwxt/InAppOpen$4;-><init>(Landroid/webkit/WebView;Landroid/widget/FrameLayout;Landroid/app/Activity;)V

    .line 684
    const-wide/16 v0, 0x320

    invoke-virtual {p1, p2, v0, v1}, Landroid/webkit/WebView;->postDelayed(Ljava/lang/Runnable;J)Z
    :try_end_46
    .catchall {:try_start_2 .. :try_end_46} :catchall_47

    .line 686
    goto :goto_48

    .line 685
    :catchall_47
    move-exception p0

    .line 687
    :goto_48
    return-void
.end method

.method private static diagHtml(Ljava/lang/String;Ljava/lang/StringBuilder;Z)Ljava/lang/String;
    .registers 6

    .line 227
    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    const-string v0, "&"

    const-string v1, "&amp;"

    invoke-virtual {p1, v0, v1}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;

    move-result-object p1

    const-string v0, "<"

    const-string v1, "&lt;"

    invoke-virtual {p1, v0, v1}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;

    move-result-object p1

    const-string v0, ">"

    const-string v1, "&gt;"

    invoke-virtual {p1, v0, v1}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;

    move-result-object p1

    .line 228
    if-eqz p2, :cond_21

    const-string v0, "\u767b\u5f55\u72b6\u6001\u5df2\u8fc7\u671f"

    goto :goto_23

    :cond_21
    const-string v0, "\u8fd8\u6ca1\u767b\u5f55"

    .line 229
    :goto_23
    if-eqz p2, :cond_28

    .line 230
    const-string p2, "\u6559\u52a1\u7cfb\u7edf\u5df2\u7ecf\u628a\u4f60\u767b\u51fa\u4e86\uff0c\u5148\u5728\u5e94\u7528\u91cc\u91cd\u65b0\u767b\u5f55\uff0c\u518d\u70b9\u300c\u524d\u5f80\u5b98\u7f51\u300d\u5c31\u80fd\u76f4\u63a5\u8fdb\u53bb\u3002"

    goto :goto_2a

    .line 231
    :cond_28
    const-string p2, "\u5148\u5728\u5e94\u7528\u91cc\u767b\u5f55\u6559\u52a1\u7cfb\u7edf\uff0c\u518d\u70b9\u300c\u524d\u5f80\u5b98\u7f51\u300d\u5c31\u80fd\u76f4\u63a5\u8fdb\u53bb\u3002"

    .line 232
    :goto_2a
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "<html><head><meta name=\'viewport\' content=\'width=device-width,initial-scale=1\'><style>body{font:15px/1.7 -apple-system,\'PingFang SC\',sans-serif;margin:0;padding:26px 20px;color:#1a1a17;background:#faf7ef}h3{font-size:19px;margin:0 0 10px}p{color:#6b6455;margin:0 0 22px}.btns{display:flex;gap:10px;flex-wrap:wrap}button{flex:1;min-width:120px;min-height:46px;border-radius:12px;border:1px solid #2e4a2a;background:#2e4a2a;color:#fff;font-size:15px}button.ghost{background:transparent;color:#2e4a2a}details{margin-top:26px;font-size:12px;color:#9a9484}pre{white-space:pre-wrap;word-break:break-all;background:#f0ece0;padding:10px;border-radius:8px;font-size:11px;color:#57503f}a{color:#2e4a2a}</style></head><body><h3>"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, "</h3><p>"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    const-string v0, "</p><div class=\'btns\'><button onclick=\"try{Android.showNativeLogin()}catch(e){}\">\u91cd\u65b0\u767b\u5f55</button><button class=\'ghost\' onclick=\"try{Android.backToApp()}catch(e){try{history.back()}catch(e2){}}\">\u8fd4\u56de\u5e94\u7528</button></div><details><summary>\u8bca\u65ad\u4fe1\u606f</summary><pre>"

    invoke-virtual {p2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    invoke-virtual {p2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    const-string p2, "</pre><p><a href=\'"

    invoke-virtual {p1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    const-string p1, "\'>\u76f4\u63a5\u6253\u5f00\u539f\u9875\u9762</a></p></details></body></html>"

    invoke-virtual {p0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method private static extractCookie(Ljava/lang/String;)Ljava/lang/String;
    .registers 5

    .line 447
    const-string v0, "JSESSIONID="

    invoke-virtual {p0, v0}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I

    move-result v0

    .line 448
    if-gez v0, :cond_e

    const-string v0, "bzb_jsxsd="

    invoke-virtual {p0, v0}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I

    move-result v0

    .line 449
    :cond_e
    if-gez v0, :cond_12

    const/4 p0, 0x0

    return-object p0

    .line 450
    :cond_12
    move v1, v0

    .line 451
    :goto_13
    if-lez v1, :cond_2f

    .line 452
    add-int/lit8 v2, v1, -0x1

    invoke-virtual {p0, v2}, Ljava/lang/String;->charAt(I)C

    move-result v2

    .line 453
    const/16 v3, 0x3e

    if-eq v2, v3, :cond_2f

    const/16 v3, 0x22

    if-eq v2, v3, :cond_2f

    const/16 v3, 0xa

    if-eq v2, v3, :cond_2f

    const/16 v3, 0xd

    if-ne v2, v3, :cond_2c

    goto :goto_2f

    .line 454
    :cond_2c
    add-int/lit8 v1, v1, -0x1

    .line 455
    goto :goto_13

    .line 456
    :cond_2f
    :goto_2f
    const/16 v2, 0x3c

    invoke-virtual {p0, v2, v0}, Ljava/lang/String;->indexOf(II)I

    move-result v0

    .line 457
    if-gez v0, :cond_3b

    invoke-virtual {p0}, Ljava/lang/String;->length()I

    move-result v0

    .line 458
    :cond_3b
    invoke-virtual {p0, v1, v0}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object p0

    .line 459
    const-string v0, "&amp;"

    const-string v1, "&"

    invoke-virtual {p0, v0, v1}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;

    move-result-object p0

    const-string v0, "&quot;"

    const-string v1, "\""

    invoke-virtual {p0, v0, v1}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;

    move-result-object p0

    const-string v0, "&lt;"

    const-string v1, "<"

    invoke-virtual {p0, v0, v1}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;

    move-result-object p0

    const-string v0, "&gt;"

    const-string v1, ">"

    invoke-virtual {p0, v0, v1}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;

    move-result-object p0

    .line 460
    return-object p0
.end method

.method private static fetch(Ljava/lang/String;Ljava/lang/String;Ljava/lang/StringBuilder;)Ljava/lang/String;
    .registers 9

    .line 286
    nop

    .line 288
    const/16 v0, 0xa

    const/4 v1, 0x0

    :try_start_4
    new-instance v2, Ljava/net/URL;

    invoke-direct {v2, p0}, Ljava/net/URL;-><init>(Ljava/lang/String;)V

    invoke-virtual {v2}, Ljava/net/URL;->openConnection()Ljava/net/URLConnection;

    move-result-object v2

    check-cast v2, Ljava/net/HttpURLConnection;
    :try_end_f
    .catchall {:try_start_4 .. :try_end_f} :catchall_f7

    .line 289
    :try_start_f
    const-string v3, "GET"

    invoke-virtual {v2, v3}, Ljava/net/HttpURLConnection;->setRequestMethod(Ljava/lang/String;)V

    .line 290
    const/16 v3, 0x3a98

    invoke-virtual {v2, v3}, Ljava/net/HttpURLConnection;->setConnectTimeout(I)V

    .line 291
    const/16 v3, 0x4e20

    invoke-virtual {v2, v3}, Ljava/net/HttpURLConnection;->setReadTimeout(I)V

    .line 292
    const/4 v3, 0x1

    invoke-virtual {v2, v3}, Ljava/net/HttpURLConnection;->setInstanceFollowRedirects(Z)V

    .line 293
    const-string v3, "User-Agent"

    const-string v4, "Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36"

    invoke-virtual {v2, v3, v4}, Ljava/net/HttpURLConnection;->setRequestProperty(Ljava/lang/String;Ljava/lang/String;)V

    .line 294
    invoke-virtual {p1}, Ljava/lang/String;->length()I

    move-result v3

    if-lez v3, :cond_34

    const-string v3, "Cookie"

    invoke-virtual {v2, v3, p1}, Ljava/net/HttpURLConnection;->setRequestProperty(Ljava/lang/String;Ljava/lang/String;)V

    .line 295
    :cond_34
    invoke-virtual {v2}, Ljava/net/HttpURLConnection;->getResponseCode()I

    move-result p1

    .line 296
    const-string v3, "url="

    invoke-virtual {p2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    const-string v3, " code="

    invoke-virtual {p0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p0

    const-string v3, " loc="

    .line 297
    invoke-virtual {p0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    const-string v3, "Location"

    invoke-virtual {v2, v3}, Ljava/net/HttpURLConnection;->getHeaderField(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {p0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0, v0}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    .line 298
    invoke-virtual {v2}, Ljava/net/HttpURLConnection;->getHeaderFields()Ljava/util/Map;

    move-result-object p0

    .line 299
    if-eqz p0, :cond_9f

    .line 300
    invoke-interface {p0}, Ljava/util/Map;->entrySet()Ljava/util/Set;

    move-result-object p0

    invoke-interface {p0}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object p0

    :goto_6d
    invoke-interface {p0}, Ljava/util/Iterator;->hasNext()Z

    move-result v3

    if-eqz v3, :cond_9f

    invoke-interface {p0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Ljava/util/Map$Entry;

    .line 301
    invoke-interface {v3}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v4

    if-eqz v4, :cond_9e

    invoke-interface {v3}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Ljava/lang/String;

    const-string v5, "Set-Cookie"

    invoke-virtual {v4, v5}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result v4

    if-eqz v4, :cond_9e

    .line 302
    const-string v4, "sc="

    invoke-virtual {p2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-interface {v3}, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;

    move-result-object v3

    invoke-virtual {v4, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, v0}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;
    :try_end_9e
    .catchall {:try_start_f .. :try_end_9e} :catchall_f5

    .line 304
    :cond_9e
    goto :goto_6d

    .line 306
    :cond_9f
    const/16 p0, 0x190

    if-lt p1, p0, :cond_a9

    .line 320
    if-eqz v2, :cond_a8

    invoke-virtual {v2}, Ljava/net/HttpURLConnection;->disconnect()V

    .line 306
    :cond_a8
    return-object v1

    .line 307
    :cond_a9
    :try_start_a9
    invoke-virtual {v2}, Ljava/net/HttpURLConnection;->getInputStream()Ljava/io/InputStream;

    move-result-object p0

    .line 308
    new-instance p1, Ljava/io/ByteArrayOutputStream;

    invoke-direct {p1}, Ljava/io/ByteArrayOutputStream;-><init>()V

    .line 309
    const/16 v3, 0x2000

    new-array v3, v3, [B

    .line 311
    :goto_b6
    invoke-virtual {p0, v3}, Ljava/io/InputStream;->read([B)I

    move-result v4

    if-lez v4, :cond_c1

    const/4 v5, 0x0

    invoke-virtual {p1, v3, v5, v4}, Ljava/io/ByteArrayOutputStream;->write([BII)V

    goto :goto_b6

    .line 312
    :cond_c1
    invoke-virtual {p0}, Ljava/io/InputStream;->close()V

    .line 313
    new-instance p0, Ljava/lang/String;

    invoke-virtual {p1}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    move-result-object p1

    const-string v3, "UTF-8"

    invoke-direct {p0, p1, v3}, Ljava/lang/String;-><init>([BLjava/lang/String;)V

    .line 314
    const-string p1, "len="

    invoke-virtual {p2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p0}, Ljava/lang/String;->length()I

    move-result v3

    invoke-virtual {p1, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p1

    const-string v3, " title="

    invoke-virtual {p1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-static {p0}, Lcom/cicp/jwxt/InAppOpen;->titleOf(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {p1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;
    :try_end_ee
    .catchall {:try_start_a9 .. :try_end_ee} :catchall_f5

    .line 315
    nop

    .line 320
    if-eqz v2, :cond_f4

    invoke-virtual {v2}, Ljava/net/HttpURLConnection;->disconnect()V

    .line 315
    :cond_f4
    return-object p0

    .line 316
    :catchall_f5
    move-exception p0

    goto :goto_f9

    :catchall_f7
    move-exception p0

    move-object v2, v1

    .line 317
    :goto_f9
    :try_start_f9
    const-string p1, "fetchErr="

    invoke-virtual {p2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0, v0}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;
    :try_end_106
    .catchall {:try_start_f9 .. :try_end_106} :catchall_10d

    .line 318
    nop

    .line 320
    if-eqz v2, :cond_10c

    invoke-virtual {v2}, Ljava/net/HttpURLConnection;->disconnect()V

    .line 318
    :cond_10c
    return-object v1

    .line 320
    :catchall_10d
    move-exception p0

    if-eqz v2, :cond_113

    invoke-virtual {v2}, Ljava/net/HttpURLConnection;->disconnect()V

    .line 321
    :cond_113
    throw p0
.end method

.method private static isLoginPage(Ljava/lang/String;)Z
    .registers 5

    .line 277
    invoke-static {p0}, Lcom/cicp/jwxt/InAppOpen;->titleOf(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 278
    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v1

    const/4 v2, 0x1

    const/4 v3, 0x0

    if-nez v1, :cond_1f

    .line 279
    const-string v0, "name=\"userKey\""

    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v0

    if-nez v0, :cond_1e

    const-string v0, "id=\"userKey\""

    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result p0

    if-eqz p0, :cond_1d

    goto :goto_1e

    :cond_1d
    move v2, v3

    :cond_1e
    :goto_1e
    return v2

    .line 281
    :cond_1f
    const-string p0, "\u4e2d\u8b66\u9662"

    invoke-virtual {v0, p0}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I

    move-result p0

    if-ltz p0, :cond_28

    return v3

    .line 282
    :cond_28
    const-string p0, "\u767b\u5f55"

    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-nez v1, :cond_40

    invoke-virtual {v0, p0}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I

    move-result p0

    if-ltz p0, :cond_3f

    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result p0

    const/16 v0, 0x8

    if-gt p0, v0, :cond_3f

    goto :goto_40

    :cond_3f
    move v2, v3

    :cond_40
    :goto_40
    return v2
.end method

.method private static jsStr(Ljava/lang/String;)Ljava/lang/String;
    .registers 6

    .line 384
    if-nez p0, :cond_5

    const-string p0, "\'\'"

    return-object p0

    .line 385
    :cond_5
    new-instance v0, Ljava/lang/StringBuilder;

    const-string v1, "\'"

    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    .line 386
    const/4 v1, 0x0

    :goto_d
    invoke-virtual {p0}, Ljava/lang/String;->length()I

    move-result v2

    const/16 v3, 0x27

    if-ge v1, v2, :cond_28

    .line 387
    invoke-virtual {p0, v1}, Ljava/lang/String;->charAt(I)C

    move-result v2

    .line 388
    const/16 v4, 0x5c

    if-eq v2, v4, :cond_1f

    if-ne v2, v3, :cond_22

    :cond_1f
    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    .line 389
    :cond_22
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    .line 386
    add-int/lit8 v1, v1, 0x1

    goto :goto_d

    .line 391
    :cond_28
    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method private static normalize(Ljava/lang/String;)Ljava/lang/String;
    .registers 3

    .line 265
    const-string v0, "https://jwxt.cicp.edu.cn/jsxsd/framework/xsMain.jsp"

    if-nez p0, :cond_5

    return-object v0

    .line 266
    :cond_5
    invoke-virtual {p0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object p0

    .line 267
    invoke-virtual {p0}, Ljava/lang/String;->length()I

    move-result v1

    if-nez v1, :cond_10

    return-object v0

    .line 268
    :cond_10
    const-string v1, "jwxt.cicp.edu.cn"

    invoke-virtual {p0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-nez v1, :cond_4a

    const-string v1, "http://jwxt.cicp.edu.cn"

    invoke-virtual {p0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-nez v1, :cond_4a

    const-string v1, "https://jwxt.cicp.edu.cn"

    invoke-virtual {p0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-nez v1, :cond_4a

    .line 269
    const-string v1, "http://jwxt.cicp.edu.cn/"

    invoke-virtual {p0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-nez v1, :cond_4a

    const-string v1, "https://jwxt.cicp.edu.cn/"

    invoke-virtual {p0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-nez v1, :cond_4a

    .line 270
    const-string v1, "/jsxsd"

    invoke-virtual {p0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v1

    if-nez v1, :cond_4a

    const-string v1, "/jsxsd/"

    invoke-virtual {p0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v1

    if-eqz v1, :cond_49

    goto :goto_4a

    .line 273
    :cond_49
    return-object p0

    .line 271
    :cond_4a
    :goto_4a
    return-object v0
.end method

.method public static open(Landroid/app/Activity;Ljava/lang/String;)V
    .registers 15

    .line 35
    if-nez p0, :cond_3

    return-void

    .line 40
    :cond_3
    if-eqz p1, :cond_20

    const-string v0, "native=1"

    invoke-virtual {p1, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v0

    if-eqz v0, :cond_20

    .line 42
    :try_start_d
    new-instance v0, Landroid/content/Intent;

    const-class v1, Lcom/cicp/jwxt/WebActivity;

    invoke-direct {v0, p0, v1}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V

    .line 43
    const-string v1, "url"

    const-string v2, "https://jwxt.cicp.edu.cn/jsxsd/framework/xsMainV.htmlx"

    invoke-virtual {v0, v1, v2}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 44
    invoke-virtual {p0, v0}, Landroid/app/Activity;->startActivity(Landroid/content/Intent;)V
    :try_end_1e
    .catchall {:try_start_d .. :try_end_1e} :catchall_1f

    .line 45
    return-void

    .line 46
    :catchall_1f
    move-exception v0

    .line 51
    :cond_20
    invoke-static {p0}, Lcom/cicp/jwxt/InAppOpen;->removeStatusStrip(Landroid/app/Activity;)V

    .line 52
    new-instance v9, Ljava/lang/StringBuilder;

    invoke-direct {v9}, Ljava/lang/StringBuilder;-><init>()V

    .line 53
    invoke-static {p0, v9}, Lcom/cicp/jwxt/InAppOpen;->readCookies(Landroid/content/Context;Ljava/lang/StringBuilder;)Ljava/lang/String;

    move-result-object v0

    .line 54
    const-string v1, "cookieLen="

    invoke-virtual {v9, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    const/16 v2, 0xa

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    .line 56
    invoke-static {p1}, Lcom/cicp/jwxt/InAppOpen;->normalize(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v7

    .line 58
    nop

    .line 59
    nop

    .line 60
    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result p1

    const-string v1, "https://jwxt.cicp.edu.cn/jsxsd/framework/xsMain.jsp"

    const/4 v3, 0x1

    const/4 v4, 0x0

    if-lez p1, :cond_72

    .line 61
    invoke-static {v1, v0, v9}, Lcom/cicp/jwxt/InAppOpen;->fetch(Ljava/lang/String;Ljava/lang/String;Ljava/lang/StringBuilder;)Ljava/lang/String;

    move-result-object p1

    .line 62
    if-eqz p1, :cond_63

    invoke-virtual {p1}, Ljava/lang/String;->length()I

    move-result v5

    if-lez v5, :cond_63

    invoke-static {p1}, Lcom/cicp/jwxt/InAppOpen;->isLoginPage(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_63

    move p1, v3

    goto :goto_64

    :cond_63
    move p1, v4

    .line 63
    :goto_64
    const-string v5, "warm="

    invoke-virtual {v9, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, p1}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, v2}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    goto :goto_73

    .line 60
    :cond_72
    move p1, v4

    .line 65
    :goto_73
    invoke-static {v7, v0, v9}, Lcom/cicp/jwxt/InAppOpen;->fetch(Ljava/lang/String;Ljava/lang/String;Ljava/lang/StringBuilder;)Ljava/lang/String;

    move-result-object v5

    .line 66
    if-nez p1, :cond_8b

    if-eqz v5, :cond_8b

    invoke-static {v5}, Lcom/cicp/jwxt/InAppOpen;->isLoginPage(Ljava/lang/String;)Z

    move-result p1

    if-eqz p1, :cond_8b

    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result p1

    if-lez p1, :cond_8b

    .line 68
    invoke-static {v7, v0, v9}, Lcom/cicp/jwxt/InAppOpen;->fetch(Ljava/lang/String;Ljava/lang/String;Ljava/lang/StringBuilder;)Ljava/lang/String;

    move-result-object v5

    .line 71
    :cond_8b
    if-eqz v5, :cond_b8

    invoke-static {v5}, Lcom/cicp/jwxt/InAppOpen;->isLoginPage(Ljava/lang/String;)Z

    move-result p1

    if-eqz p1, :cond_b8

    invoke-virtual {v1, v7}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p1

    if-nez p1, :cond_b8

    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result p1

    if-lez p1, :cond_b8

    .line 73
    invoke-static {v1, v0, v9}, Lcom/cicp/jwxt/InAppOpen;->fetch(Ljava/lang/String;Ljava/lang/String;Ljava/lang/StringBuilder;)Ljava/lang/String;

    move-result-object p1

    .line 74
    if-eqz p1, :cond_b8

    invoke-virtual {p1}, Ljava/lang/String;->length()I

    move-result v1

    if-lez v1, :cond_b8

    invoke-static {p1}, Lcom/cicp/jwxt/InAppOpen;->isLoginPage(Ljava/lang/String;)Z

    move-result v1

    if-nez v1, :cond_b8

    .line 75
    nop

    .line 76
    const-string v1, "fallbackHome=true\n"

    invoke-virtual {v9, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-object v5, p1

    .line 82
    :cond_b8
    :try_start_b8
    const-string p1, "jwxt-user.css"

    invoke-static {p0, p1}, Lcom/cicp/jwxt/InAppOpen;->readUserFile(Landroid/app/Activity;Ljava/lang/String;)Ljava/lang/String;

    move-result-object p1

    .line 83
    const-string v1, "jwxt-user.js"

    invoke-static {p0, v1}, Lcom/cicp/jwxt/InAppOpen;->readUserFile(Landroid/app/Activity;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v6
    :try_end_c4
    .catchall {:try_start_b8 .. :try_end_c4} :catchall_180

    .line 86
    nop

    .line 87
    if-eqz v5, :cond_d5

    invoke-virtual {v5}, Ljava/lang/String;->length()I

    move-result v1

    if-lez v1, :cond_d5

    invoke-static {v5}, Lcom/cicp/jwxt/InAppOpen;->isLoginPage(Ljava/lang/String;)Z

    move-result v1

    if-nez v1, :cond_d5

    move v8, v3

    goto :goto_d6

    :cond_d5
    move v8, v4

    .line 88
    :goto_d6
    const-string v1, "htmlLen="

    invoke-virtual {v9, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    if-nez v5, :cond_e0

    const/4 v5, -0x1

    goto :goto_e4

    :cond_e0
    invoke-virtual {v5}, Ljava/lang/String;->length()I

    move-result v5

    :goto_e4
    invoke-virtual {v1, v5}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v5, " logged="

    invoke-virtual {v1, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v8}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    .line 89
    invoke-virtual {v9}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {p0, v1}, Lcom/cicp/jwxt/InAppOpen;->writeDiag(Landroid/content/Context;Ljava/lang/String;)V

    .line 91
    invoke-static {p0}, Lcom/cicp/jwxt/InAppOpen;->webViewOf(Landroid/app/Activity;)Landroid/webkit/WebView;

    move-result-object v10

    .line 92
    if-nez v10, :cond_103

    return-void

    .line 95
    :cond_103
    :try_start_103
    invoke-static {}, Landroid/webkit/CookieManager;->getInstance()Landroid/webkit/CookieManager;

    move-result-object v1

    .line 96
    invoke-virtual {v1, v3}, Landroid/webkit/CookieManager;->setAcceptCookie(Z)V

    .line 97
    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v2

    if-lez v2, :cond_13d

    .line 98
    const-string v2, ";"

    invoke-virtual {v0, v2}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v2

    .line 99
    move v5, v4

    :goto_117
    array-length v11, v2

    if-ge v5, v11, :cond_13a

    .line 100
    aget-object v11, v2, v5

    invoke-virtual {v11}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v11

    .line 101
    invoke-virtual {v11}, Ljava/lang/String;->length()I

    move-result v12

    if-eqz v12, :cond_137

    const/16 v12, 0x3d

    invoke-virtual {v11, v12}, Ljava/lang/String;->indexOf(I)I

    move-result v12

    if-gtz v12, :cond_12f

    goto :goto_137

    .line 102
    :cond_12f
    const-string v12, "https://jwxt.cicp.edu.cn/"

    invoke-virtual {v1, v12, v11}, Landroid/webkit/CookieManager;->setCookie(Ljava/lang/String;Ljava/lang/String;)V

    .line 103
    invoke-virtual {v1, v7, v11}, Landroid/webkit/CookieManager;->setCookie(Ljava/lang/String;Ljava/lang/String;)V

    .line 99
    :cond_137
    :goto_137
    add-int/lit8 v5, v5, 0x1

    goto :goto_117

    .line 105
    :cond_13a
    invoke-virtual {v1}, Landroid/webkit/CookieManager;->flush()V
    :try_end_13d
    .catchall {:try_start_103 .. :try_end_13d} :catchall_13e

    .line 108
    :cond_13d
    goto :goto_13f

    .line 107
    :catchall_13e
    move-exception v1

    .line 110
    :goto_13f
    if-nez v8, :cond_172

    .line 112
    new-instance p0, Ljava/lang/StringBuilder;

    invoke-direct {p0}, Ljava/lang/StringBuilder;-><init>()V

    const-string p1, "(function(){window.__pendingOfficialUrl="

    invoke-virtual {p0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-static {v7}, Lcom/cicp/jwxt/InAppOpen;->jsStr(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p1

    invoke-virtual {p0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    const-string p1, ";try{if(window.scheduleTip)scheduleTip(\'\u767b\u5f55\u5df2\u8fc7\u671f\uff0c\u767b\u5f55\u540e\u4f1a\u76f4\u63a5\u6253\u5f00\u5b98\u7f51\');}catch(e){}try{if(window.showLogin)showLogin();}catch(e){}})();"

    invoke-virtual {p0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    .line 116
    new-array p1, v3, [Z

    aput-boolean v4, p1, v4

    .line 117
    new-instance v8, Lcom/cicp/jwxt/InAppOpen$1;

    move-object v1, v8

    move-object v2, v10

    move-object v3, p0

    move-object v4, p1

    move-object v5, v7

    move-object v6, v9

    move-object v7, v0

    invoke-direct/range {v1 .. v7}, Lcom/cicp/jwxt/InAppOpen$1;-><init>(Landroid/webkit/WebView;Ljava/lang/String;[ZLjava/lang/String;Ljava/lang/StringBuilder;Ljava/lang/String;)V

    invoke-virtual {v10, v8}, Landroid/webkit/WebView;->post(Ljava/lang/Runnable;)Z

    .line 133
    return-void

    .line 135
    :cond_172
    new-instance v11, Lcom/cicp/jwxt/InAppOpen$2;

    move-object v1, v11

    move-object v2, v10

    move-object v3, p0

    move-object v4, v0

    move-object v5, p1

    invoke-direct/range {v1 .. v9}, Lcom/cicp/jwxt/InAppOpen$2;-><init>(Landroid/webkit/WebView;Landroid/app/Activity;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ZLjava/lang/StringBuilder;)V

    invoke-virtual {v10, v11}, Landroid/webkit/WebView;->post(Ljava/lang/Runnable;)Z

    .line 224
    return-void

    .line 84
    :catchall_180
    move-exception p0

    .line 85
    new-instance p1, Ljava/lang/RuntimeException;

    invoke-direct {p1, p0}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/Throwable;)V

    throw p1
.end method

.method private static readAll(Ljava/io/File;)Ljava/lang/String;
    .registers 5

    .line 362
    :try_start_0
    new-instance v0, Ljava/io/FileInputStream;

    invoke-direct {v0, p0}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V

    .line 363
    new-instance p0, Ljava/io/ByteArrayOutputStream;

    invoke-direct {p0}, Ljava/io/ByteArrayOutputStream;-><init>()V

    .line 364
    const/16 v1, 0x2000

    new-array v1, v1, [B

    .line 366
    :goto_e
    invoke-virtual {v0, v1}, Ljava/io/FileInputStream;->read([B)I

    move-result v2

    if-lez v2, :cond_19

    const/4 v3, 0x0

    invoke-virtual {p0, v1, v3, v2}, Ljava/io/ByteArrayOutputStream;->write([BII)V

    goto :goto_e

    .line 367
    :cond_19
    invoke-virtual {v0}, Ljava/io/FileInputStream;->close()V

    .line 368
    new-instance v0, Ljava/lang/String;

    invoke-virtual {p0}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    move-result-object p0

    const-string v1, "UTF-8"

    invoke-direct {v0, p0, v1}, Ljava/lang/String;-><init>([BLjava/lang/String;)V
    :try_end_27
    .catchall {:try_start_0 .. :try_end_27} :catchall_28

    return-object v0

    .line 369
    :catchall_28
    move-exception p0

    .line 370
    const/4 p0, 0x0

    return-object p0
.end method

.method public static readCookies(Landroid/content/Context;Ljava/lang/StringBuilder;)Ljava/lang/String;
    .registers 10

    .line 405
    const-string v0, ""

    new-instance v1, Ljava/util/ArrayList;

    invoke-direct {v1}, Ljava/util/ArrayList;-><init>()V

    .line 407
    const/16 v2, 0xa

    :try_start_9
    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v3

    const-string v4, "cookieStore"

    invoke-virtual {v3, v4}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object v3

    .line 408
    const/4 v4, 0x1

    invoke-virtual {v3, v4}, Ljava/lang/reflect/Field;->setAccessible(Z)V

    .line 409
    invoke-virtual {v3, p0}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v3

    .line 410
    const-string v4, "field="

    invoke-virtual {p1, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    if-nez v3, :cond_26

    const-string v5, "null"

    goto :goto_2a

    :cond_26
    invoke-virtual {v3}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v5

    :goto_2a
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v2}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    .line 411
    if-eqz v3, :cond_4c

    invoke-virtual {v3}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/String;->length()I

    move-result v4

    if-lez v4, :cond_4c

    invoke-virtual {v3}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v1, v3}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z
    :try_end_4c
    .catchall {:try_start_9 .. :try_end_4c} :catchall_4d

    .line 414
    :cond_4c
    goto :goto_5b

    .line 412
    :catchall_4d
    move-exception v3

    .line 413
    const-string v4, "fieldErr="

    invoke-virtual {p1, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    .line 416
    :goto_5b
    const/4 v3, 0x0

    :try_start_5c
    const-string v4, "jwxt"

    invoke-virtual {p0, v4, v3}, Landroid/content/Context;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;

    move-result-object v4

    .line 417
    const-string v5, "cookies"

    invoke-interface {v4, v5, v0}, Landroid/content/SharedPreferences;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v4

    .line 418
    if-eqz v4, :cond_7b

    invoke-virtual {v4}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/String;->length()I

    move-result v5

    if-lez v5, :cond_7b

    invoke-virtual {v4}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v1, v4}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z
    :try_end_7b
    .catchall {:try_start_5c .. :try_end_7b} :catchall_7c

    .line 420
    :cond_7b
    goto :goto_7d

    .line 419
    :catchall_7c
    move-exception v4

    .line 423
    :goto_7d
    :try_start_7d
    new-instance v4, Ljava/io/File;

    invoke-virtual {p0}, Landroid/content/Context;->getApplicationInfo()Landroid/content/pm/ApplicationInfo;

    move-result-object p0

    iget-object p0, p0, Landroid/content/pm/ApplicationInfo;->dataDir:Ljava/lang/String;

    const-string v5, "shared_prefs"

    invoke-direct {v4, p0, v5}, Ljava/io/File;-><init>(Ljava/lang/String;Ljava/lang/String;)V

    .line 424
    invoke-virtual {v4}, Ljava/io/File;->listFiles()[Ljava/io/File;

    move-result-object p0

    .line 425
    if-eqz p0, :cond_e0

    .line 426
    move v4, v3

    :goto_91
    array-length v5, p0

    if-ge v4, v5, :cond_e0

    .line 427
    aget-object v5, p0, v4

    const/high16 v6, 0x10000

    invoke-static {v5, v6}, Lcom/cicp/jwxt/InAppOpen;->readText(Ljava/io/File;I)Ljava/lang/String;

    move-result-object v5

    .line 428
    if-nez v5, :cond_9f

    goto :goto_dd

    .line 429
    :cond_9f
    const-string v6, "JSESSIONID"

    invoke-virtual {v5, v6}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v6

    if-nez v6, :cond_af

    const-string v6, "bzb_jsxsd"

    invoke-virtual {v5, v6}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v6

    if-eqz v6, :cond_dd

    .line 430
    :cond_af
    const-string v6, "spFile="

    invoke-virtual {p1, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    aget-object v7, p0, v4

    invoke-virtual {v7}, Ljava/io/File;->getName()Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v2}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-static {v5}, Lcom/cicp/jwxt/InAppOpen;->shrink(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v2}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    .line 431
    invoke-static {v5}, Lcom/cicp/jwxt/InAppOpen;->extractCookie(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v5

    .line 432
    if-eqz v5, :cond_dd

    invoke-virtual {v5}, Ljava/lang/String;->length()I

    move-result v6

    if-lez v6, :cond_dd

    invoke-virtual {v1, v5}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z
    :try_end_dd
    .catchall {:try_start_7d .. :try_end_dd} :catchall_e1

    .line 426
    :cond_dd
    :goto_dd
    add-int/lit8 v4, v4, 0x1

    goto :goto_91

    .line 438
    :cond_e0
    goto :goto_ef

    .line 436
    :catchall_e1
    move-exception p0

    .line 437
    const-string v4, "spScanErr="

    invoke-virtual {p1, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0, v2}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    .line 439
    :goto_ef
    nop

    .line 440
    nop

    :goto_f1
    invoke-virtual {v1}, Ljava/util/ArrayList;->size()I

    move-result p0

    if-ge v3, p0, :cond_111

    .line 441
    invoke-virtual {v1, v3}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/String;

    invoke-virtual {p0}, Ljava/lang/String;->length()I

    move-result p0

    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result p1

    if-le p0, p1, :cond_10e

    invoke-virtual {v1, v3}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/String;

    move-object v0, p0

    .line 440
    :cond_10e
    add-int/lit8 v3, v3, 0x1

    goto :goto_f1

    .line 443
    :cond_111
    return-object v0
.end method

.method private static readText(Ljava/io/File;I)Ljava/lang/String;
    .registers 6

    .line 470
    :try_start_0
    new-instance v0, Ljava/io/FileInputStream;

    invoke-direct {v0, p0}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V

    .line 471
    new-instance p0, Ljava/io/ByteArrayOutputStream;

    invoke-direct {p0}, Ljava/io/ByteArrayOutputStream;-><init>()V

    .line 472
    const/16 v1, 0x2000

    new-array v1, v1, [B

    .line 474
    :cond_e
    invoke-virtual {v0, v1}, Ljava/io/FileInputStream;->read([B)I

    move-result v2

    if-lez v2, :cond_1e

    .line 475
    const/4 v3, 0x0

    invoke-virtual {p0, v1, v3, v2}, Ljava/io/ByteArrayOutputStream;->write([BII)V

    .line 476
    invoke-virtual {p0}, Ljava/io/ByteArrayOutputStream;->size()I

    move-result v2

    if-le v2, p1, :cond_e

    .line 478
    :cond_1e
    invoke-virtual {v0}, Ljava/io/FileInputStream;->close()V

    .line 479
    new-instance p1, Ljava/lang/String;

    invoke-virtual {p0}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    move-result-object p0

    const-string v0, "UTF-8"

    invoke-direct {p1, p0, v0}, Ljava/lang/String;-><init>([BLjava/lang/String;)V
    :try_end_2c
    .catchall {:try_start_0 .. :try_end_2c} :catchall_2d

    return-object p1

    .line 480
    :catchall_2d
    move-exception p0

    .line 481
    const/4 p0, 0x0

    return-object p0
.end method

.method private static readUserFile(Landroid/app/Activity;Ljava/lang/String;)Ljava/lang/String;
    .registers 4

    .line 327
    const/4 v0, 0x0

    :try_start_1
    invoke-virtual {p0, v0}, Landroid/app/Activity;->getExternalFilesDir(Ljava/lang/String;)Ljava/io/File;

    move-result-object p0

    .line 328
    if-eqz p0, :cond_3f

    .line 329
    invoke-virtual {p0}, Ljava/io/File;->exists()Z

    move-result v0

    if-nez v0, :cond_10

    invoke-virtual {p0}, Ljava/io/File;->mkdirs()Z

    .line 330
    :cond_10
    new-instance v0, Ljava/io/File;

    invoke-direct {v0, p0, p1}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 331
    invoke-virtual {v0}, Ljava/io/File;->exists()Z

    move-result p0

    if-nez p0, :cond_2e

    .line 332
    const-string p0, ".css"

    invoke-virtual {p1, p0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p0

    if-eqz p0, :cond_29

    .line 333
    const-string p0, "/* \u81ea\u5b9a\u4e49\u6837\u5f0f\uff1a\u6bcf\u6b21\u6253\u5f00\u5b98\u7f51\u90fd\u4f1a\u91cd\u65b0\u8bfb\u53d6\uff0c\u6539\u5b8c\u91cd\u5f00\u5c31\u751f\u6548 */\n/* \u4f8b\uff1a\u5b57\u53f7\u653e\u5927  body{font-size:15px!important} */\n/* \u4f8b\uff1a\u9690\u85cf\u9876\u90e8\u5bfc\u822a .header,.top{display:none!important} */\n"

    invoke-static {v0, p0}, Lcom/cicp/jwxt/InAppOpen;->writeText(Ljava/io/File;Ljava/lang/String;)V

    goto :goto_2e

    .line 337
    :cond_29
    const-string p0, "// \u81ea\u5b9a\u4e49\u811a\u672c\uff1a\u6bcf\u6b21\u6253\u5f00\u5b98\u7f51\u90fd\u4f1a\u91cd\u65b0\u8bfb\u53d6\n// \u4f8b\uff1adocument.body.style.fontSize=\'15px\';\n"

    invoke-static {v0, p0}, Lcom/cicp/jwxt/InAppOpen;->writeText(Ljava/io/File;Ljava/lang/String;)V

    .line 341
    :cond_2e
    :goto_2e
    invoke-static {v0}, Lcom/cicp/jwxt/InAppOpen;->readAll(Ljava/io/File;)Ljava/lang/String;

    move-result-object p0

    .line 342
    if-eqz p0, :cond_3f

    invoke-virtual {p0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v0
    :try_end_3c
    .catchall {:try_start_1 .. :try_end_3c} :catchall_40

    if-lez v0, :cond_3f

    return-object p0

    .line 345
    :cond_3f
    goto :goto_41

    .line 344
    :catchall_40
    move-exception p0

    .line 346
    :goto_41
    new-instance p0, Ljava/lang/StringBuilder;

    invoke-direct {p0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v0, "/sdcard/Download/"

    invoke-virtual {p0, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "/storage/emulated/0/Download/"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    filled-new-array {p0, p1}, [Ljava/lang/String;

    move-result-object p0

    .line 347
    const/4 p1, 0x0

    :goto_6c
    const/4 v0, 0x2

    if-ge p1, v0, :cond_92

    .line 349
    :try_start_6f
    new-instance v0, Ljava/io/File;

    aget-object v1, p0, p1

    invoke-direct {v0, v1}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 350
    invoke-virtual {v0}, Ljava/io/File;->exists()Z

    move-result v1

    if-eqz v1, :cond_8d

    .line 351
    invoke-static {v0}, Lcom/cicp/jwxt/InAppOpen;->readAll(Ljava/io/File;)Ljava/lang/String;

    move-result-object v0

    .line 352
    if-eqz v0, :cond_8d

    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/String;->length()I

    move-result v1
    :try_end_8a
    .catchall {:try_start_6f .. :try_end_8a} :catchall_8e

    if-lez v1, :cond_8d

    return-object v0

    .line 355
    :cond_8d
    goto :goto_8f

    .line 354
    :catchall_8e
    move-exception v0

    .line 347
    :goto_8f
    add-int/lit8 p1, p1, 0x1

    goto :goto_6c

    .line 357
    :cond_92
    const-string p0, ""

    return-object p0
.end method

.method private static removeDebugHud(Landroid/app/Activity;)V
    .registers 2

    .line 626
    :try_start_0
    invoke-virtual {p0}, Landroid/app/Activity;->getWindow()Landroid/view/Window;

    move-result-object v0

    invoke-virtual {v0}, Landroid/view/Window;->getDecorView()Landroid/view/View;

    move-result-object v0

    instance-of v0, v0, Landroid/widget/FrameLayout;

    if-nez v0, :cond_d

    return-void

    .line 627
    :cond_d
    invoke-virtual {p0}, Landroid/app/Activity;->getWindow()Landroid/view/Window;

    move-result-object p0

    invoke-virtual {p0}, Landroid/view/Window;->getDecorView()Landroid/view/View;

    move-result-object p0

    check-cast p0, Landroid/widget/FrameLayout;

    .line 628
    const-string v0, "jwxt_hud"

    invoke-virtual {p0, v0}, Landroid/widget/FrameLayout;->findViewWithTag(Ljava/lang/Object;)Landroid/view/View;

    move-result-object v0

    .line 629
    if-eqz v0, :cond_22

    invoke-virtual {p0, v0}, Landroid/widget/FrameLayout;->removeView(Landroid/view/View;)V
    :try_end_22
    .catchall {:try_start_0 .. :try_end_22} :catchall_23

    .line 631
    :cond_22
    goto :goto_24

    .line 630
    :catchall_23
    move-exception p0

    .line 632
    :goto_24
    return-void
.end method

.method private static removeStatusStrip(Landroid/app/Activity;)V
    .registers 2

    .line 637
    :try_start_0
    invoke-virtual {p0}, Landroid/app/Activity;->getWindow()Landroid/view/Window;

    move-result-object v0

    invoke-virtual {v0}, Landroid/view/Window;->getDecorView()Landroid/view/View;

    move-result-object v0

    instance-of v0, v0, Landroid/widget/FrameLayout;

    if-nez v0, :cond_d

    return-void

    .line 638
    :cond_d
    invoke-virtual {p0}, Landroid/app/Activity;->getWindow()Landroid/view/Window;

    move-result-object p0

    invoke-virtual {p0}, Landroid/view/Window;->getDecorView()Landroid/view/View;

    move-result-object p0

    check-cast p0, Landroid/widget/FrameLayout;

    .line 639
    const-string v0, "jwxt_status_strip"

    invoke-virtual {p0, v0}, Landroid/widget/FrameLayout;->findViewWithTag(Ljava/lang/Object;)Landroid/view/View;

    move-result-object v0

    .line 640
    if-eqz v0, :cond_22

    invoke-virtual {p0, v0}, Landroid/widget/FrameLayout;->removeView(Landroid/view/View;)V
    :try_end_22
    .catchall {:try_start_0 .. :try_end_22} :catchall_23

    .line 642
    :cond_22
    goto :goto_24

    .line 641
    :catchall_23
    move-exception p0

    .line 643
    :goto_24
    return-void
.end method

.method private static restoreNativeState(Landroid/app/Activity;Landroid/webkit/WebView;)V
    .registers 5

    .line 608
    :try_start_0
    invoke-static {p0}, Lcom/cicp/jwxt/InAppOpen;->removeStatusStrip(Landroid/app/Activity;)V
    :try_end_3
    .catchall {:try_start_0 .. :try_end_3} :catchall_4

    goto :goto_5

    :catchall_4
    move-exception v0

    .line 609
    :goto_5
    :try_start_5
    invoke-static {p0}, Lcom/cicp/jwxt/InAppOpen;->removeDebugHud(Landroid/app/Activity;)V
    :try_end_8
    .catchall {:try_start_5 .. :try_end_8} :catchall_9

    goto :goto_a

    :catchall_9
    move-exception p0

    .line 611
    :goto_a
    const/4 p0, 0x0

    :try_start_b
    invoke-virtual {p1}, Landroid/webkit/WebView;->getSettings()Landroid/webkit/WebSettings;

    move-result-object v0

    .line 612
    sget v1, Lcom/cicp/jwxt/InAppOpen;->sOrigTextZoom:I

    if-lez v1, :cond_18

    sget v1, Lcom/cicp/jwxt/InAppOpen;->sOrigTextZoom:I

    invoke-virtual {v0, v1}, Landroid/webkit/WebSettings;->setTextZoom(I)V

    .line 613
    :cond_18
    sget v1, Lcom/cicp/jwxt/InAppOpen;->sOrigOverview:I

    const/4 v2, 0x1

    if-ltz v1, :cond_27

    sget v1, Lcom/cicp/jwxt/InAppOpen;->sOrigOverview:I

    if-ne v1, v2, :cond_23

    move v1, v2

    goto :goto_24

    :cond_23
    move v1, p0

    :goto_24
    invoke-virtual {v0, v1}, Landroid/webkit/WebSettings;->setLoadWithOverviewMode(Z)V

    .line 614
    :cond_27
    sget v1, Lcom/cicp/jwxt/InAppOpen;->sOrigWideViewport:I

    if-ltz v1, :cond_36

    sget v1, Lcom/cicp/jwxt/InAppOpen;->sOrigWideViewport:I

    if-ne v1, v2, :cond_30

    goto :goto_31

    :cond_30
    move v2, p0

    :goto_31
    invoke-virtual {v0, v2}, Landroid/webkit/WebSettings;->setUseWideViewPort(Z)V
    :try_end_34
    .catchall {:try_start_b .. :try_end_34} :catchall_35

    goto :goto_36

    .line 615
    :catchall_35
    move-exception v0

    :cond_36
    :goto_36
    nop

    .line 617
    :try_start_37
    invoke-virtual {p1}, Landroid/webkit/WebView;->getParent()Landroid/view/ViewParent;

    move-result-object p1

    check-cast p1, Landroid/view/ViewGroup;

    .line 618
    if-eqz p1, :cond_44

    invoke-virtual {p1, p0, p0, p0, p0}, Landroid/view/ViewGroup;->setPadding(IIII)V
    :try_end_42
    .catchall {:try_start_37 .. :try_end_42} :catchall_43

    goto :goto_44

    .line 619
    :catchall_43
    move-exception p0

    :cond_44
    :goto_44
    nop

    .line 620
    return-void
.end method

.method private static shrink(Ljava/lang/String;)Ljava/lang/String;
    .registers 4

    .line 464
    invoke-virtual {p0}, Ljava/lang/String;->length()I

    move-result v0

    const/16 v1, 0x258

    if-gt v0, v1, :cond_9

    return-object p0

    .line 465
    :cond_9
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const/4 v2, 0x0

    invoke-virtual {p0, v2, v1}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object p0

    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    const-string v0, "..."

    invoke-virtual {p0, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method private static titleOf(Ljava/lang/String;)Ljava/lang/String;
    .registers 4

    .line 253
    const-string v0, ""

    :try_start_2
    const-string v1, "<title>"

    invoke-virtual {p0, v1}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I

    move-result v1

    .line 254
    if-gez v1, :cond_b

    return-object v0

    .line 255
    :cond_b
    const-string v2, "</title>"

    invoke-virtual {p0, v2, v1}, Ljava/lang/String;->indexOf(Ljava/lang/String;I)I

    move-result v2

    .line 256
    if-gez v2, :cond_14

    return-object v0

    .line 257
    :cond_14
    add-int/lit8 v1, v1, 0x7

    invoke-virtual {p0, v1, v2}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object p0
    :try_end_1e
    .catchall {:try_start_2 .. :try_end_1e} :catchall_1f

    return-object p0

    .line 258
    :catchall_1f
    move-exception p0

    .line 259
    return-object v0
.end method

.method private static webViewOf(Landroid/app/Activity;)Landroid/webkit/WebView;
    .registers 3

    .line 396
    :try_start_0
    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v0

    const-string v1, "webView"

    invoke-virtual {v0, v1}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object v0

    .line 397
    const/4 v1, 0x1

    invoke-virtual {v0, v1}, Ljava/lang/reflect/Field;->setAccessible(Z)V

    .line 398
    invoke-virtual {v0, p0}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Landroid/webkit/WebView;
    :try_end_14
    .catchall {:try_start_0 .. :try_end_14} :catchall_15

    return-object p0

    .line 399
    :catchall_15
    move-exception p0

    .line 400
    const/4 p0, 0x0

    return-object p0
.end method

.method private static writeDiag(Landroid/content/Context;Ljava/lang/String;)V
    .registers 6

    const-string v0, "JWXT"

    invoke-static {v0, p1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    :try_start_0
    new-instance v0, Ljava/io/File;

    invoke-virtual {p0}, Landroid/content/Context;->getCacheDir()Ljava/io/File;

    move-result-object v1

    const-string v2, "logs"

    invoke-direct {v0, v1, v2}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-virtual {v0}, Ljava/io/File;->exists()Z

    move-result v1

    if-nez v1, :cond_0

    invoke-virtual {v0}, Ljava/io/File;->mkdirs()Z

    :cond_0
    new-instance v1, Ljava/io/File;

    const-string v2, "jwxt_diag.txt"

    invoke-direct {v1, v0, v2}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    new-instance v0, Ljava/io/FileOutputStream;

    invoke-direct {v0, v1}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;)V

    const-string v1, "UTF-8"

    invoke-virtual {p1, v1}, Ljava/lang/String;->getBytes(Ljava/lang/String;)[B

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/io/OutputStream;->write([B)V

    invoke-virtual {v0}, Ljava/io/OutputStream;->close()V
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0

    return-void
.end method

.method private static writeText(Ljava/io/File;Ljava/lang/String;)V
    .registers 4

    .line 376
    :try_start_0
    new-instance v0, Ljava/io/FileOutputStream;

    const/4 v1, 0x0

    invoke-direct {v0, p0, v1}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;Z)V

    .line 377
    const-string p0, "UTF-8"

    invoke-virtual {p1, p0}, Ljava/lang/String;->getBytes(Ljava/lang/String;)[B

    move-result-object p0

    invoke-virtual {v0, p0}, Ljava/io/FileOutputStream;->write([B)V

    .line 378
    invoke-virtual {v0}, Ljava/io/FileOutputStream;->close()V
    :try_end_12
    .catchall {:try_start_0 .. :try_end_12} :catchall_13

    .line 380
    goto :goto_14

    .line 379
    :catchall_13
    move-exception p0

    .line 381
    :goto_14
    return-void
.end method
