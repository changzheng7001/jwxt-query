.class public Lcom/cicp/jwxt/CookieWebClient;
.super Landroid/webkit/WebViewClient;
.source "CookieWebClient.java"


# static fields
.field private static final MOBILE_CSS:Ljava/lang/String; = "html,body{width:auto!important;min-width:0!important;max-width:100%!important;}.new-main .main .sidebar,.sidebar{display:none!important;}.main,.new-main .main{margin-left:0!important;padding-left:0!important;width:100%!important;}.iframeClass,#iframeClass{padding-left:0!important;margin-left:0!important;width:100%!important;left:0!important;}.new-main .main .sidebar.shrink + .iframeClass{padding-left:0!important;}.top div{width:auto!important;}.container,.content,.main-content,.main_content,.mainbody,.mainBody,.wrap,.wrapper,.box,.panel,.contentbox,.new-main,.index-main{width:auto!important;min-width:0!important;max-width:100%!important;margin-left:0!important;margin-right:0!important;}table{max-width:none!important;}.kbcontent1,.kbcontent,.kb,.td,.td1,.td2{white-space:normal!important;word-break:break-all!important;}input[type=text],input[type=password],input[type=search],select,textarea{max-width:100%!important;box-sizing:border-box!important;}img{max-width:100%!important;height:auto!important;}body{overflow-x:auto!important;-webkit-overflow-scrolling:touch;}"

.field private static final MOBILE_JS:Ljava/lang/String; = "(function(){try{var id=\'jwxt-mobile-js\',old=document.getElementById(id);if(old)old.parentNode.removeChild(old);var s=document.createElement(\'style\');s.id=id;s.textContent=\'.sidebar,.new-main .main .sidebar{display:none!important}\'+\'.main,.new-main .main{margin-left:0!important;padding-left:0!important;width:100%!important}\'+\'.iframeClass,#iframeClass{margin-left:0!important;padding-left:0!important;width:100%!important;left:0!important}\'+\'.container,.content,.main-content,.main_content,.mainbody,.mainBody,.wrap,.wrapper,.box,.panel,.contentbox,.new-main,.index-main{width:auto!important;min-width:0!important;max-width:100%!important;margin-left:0!important}\'+\'table{max-width:none!important}\'+\'.kbcontent1,.kbcontent,.kb{white-space:normal!important;word-break:break-all!important}\'+\'img{max-width:100%!important;height:auto!important}\'+\'body{overflow-x:auto!important}\'+\'.top div{width:auto!important}\';document.documentElement.appendChild(s);}catch(e){}})();"

.field private static final UA:Ljava/lang/String; = "Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36"

.field private static final VIEWPORT_META:Ljava/lang/String; = "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1,maximum-scale=3,user-scalable=yes\">"


# instance fields
.field private final cookie:Ljava/lang/String;

.field private final host:Ljava/lang/String;

.field private mobilePage:Ljava/lang/String;

.field private volatile nativeUntil:J

.field private final padBottom:I

.field private final padTop:I

.field private userCss:Ljava/lang/String;

.field private userJs:Ljava/lang/String;


# direct methods
.method public constructor <init>(Ljava/lang/String;Ljava/lang/String;)V
    .registers 4

    .line 37
    const/4 v0, 0x0

    invoke-direct {p0, p1, p2, v0, v0}, Lcom/cicp/jwxt/CookieWebClient;-><init>(Ljava/lang/String;Ljava/lang/String;II)V

    .line 38
    return-void
.end method

.method public constructor <init>(Ljava/lang/String;Ljava/lang/String;II)V
    .registers 7

    .line 40
    invoke-direct {p0}, Landroid/webkit/WebViewClient;-><init>()V

    .line 29
    const-wide/16 v0, 0x0

    iput-wide v0, p0, Lcom/cicp/jwxt/CookieWebClient;->nativeUntil:J

    .line 32
    const-string v0, ""

    iput-object v0, p0, Lcom/cicp/jwxt/CookieWebClient;->userCss:Ljava/lang/String;

    .line 33
    iput-object v0, p0, Lcom/cicp/jwxt/CookieWebClient;->userJs:Ljava/lang/String;

    .line 41
    iput-object p1, p0, Lcom/cicp/jwxt/CookieWebClient;->host:Ljava/lang/String;

    .line 42
    if-nez p2, :cond_12

    move-object p2, v0

    :cond_12
    iput-object p2, p0, Lcom/cicp/jwxt/CookieWebClient;->cookie:Ljava/lang/String;

    .line 43
    iput p3, p0, Lcom/cicp/jwxt/CookieWebClient;->padTop:I

    .line 44
    iput p4, p0, Lcom/cicp/jwxt/CookieWebClient;->padBottom:I

    .line 45
    return-void
.end method

.method public static UA()Ljava/lang/String;
    .registers 1

    .line 272
    const-string v0, "Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36"

    return-object v0
.end method

.method private applyInset(Landroid/webkit/WebView;Ljava/lang/String;)V
    .registers 6

    .line 50
    const/4 v0, 0x0

    if-eqz p2, :cond_f

    :try_start_3
    iget-object v1, p0, Lcom/cicp/jwxt/CookieWebClient;->host:Ljava/lang/String;

    invoke-virtual {p2, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result p2

    if-eqz p2, :cond_f

    const/4 p2, 0x1

    goto :goto_10

    .line 53
    :catchall_d
    move-exception p1

    goto :goto_28

    .line 50
    :cond_f
    move p2, v0

    .line 51
    :goto_10
    if-eqz p2, :cond_15

    iget v1, p0, Lcom/cicp/jwxt/CookieWebClient;->padTop:I

    goto :goto_16

    :cond_15
    move v1, v0

    :goto_16
    if-eqz p2, :cond_1b

    iget v2, p0, Lcom/cicp/jwxt/CookieWebClient;->padBottom:I

    goto :goto_1c

    :cond_1b
    move v2, v0

    :goto_1c
    invoke-virtual {p1, v0, v1, v0, v2}, Landroid/webkit/WebView;->setPadding(IIII)V

    .line 52
    if-eqz p2, :cond_24

    const v0, -0x110f0c

    :cond_24
    invoke-virtual {p1, v0}, Landroid/webkit/WebView;->setBackgroundColor(I)V
    :try_end_27
    .catchall {:try_start_3 .. :try_end_27} :catchall_d

    .line 54
    nop

    .line 55
    :goto_28
    return-void
.end method

.method private static extractQuery(Ljava/lang/String;)Ljava/lang/String;
    .registers 6

    .line 167
    const/4 v0, 0x0

    if-nez p0, :cond_4

    return-object v0

    .line 168
    :cond_4
    const-string v1, "__q="

    invoke-virtual {p0, v1}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I

    move-result v1

    .line 169
    if-gez v1, :cond_d

    return-object v0

    .line 170
    :cond_d
    add-int/lit8 v1, v1, 0x4

    invoke-virtual {p0, v1}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object p0

    .line 171
    const/16 v1, 0x26

    invoke-virtual {p0, v1}, Ljava/lang/String;->indexOf(I)I

    move-result v1

    .line 172
    const/4 v2, 0x0

    if-ltz v1, :cond_20

    invoke-virtual {p0, v2, v1}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object p0

    .line 173
    :cond_20
    const/16 v1, 0x23

    invoke-virtual {p0, v1}, Ljava/lang/String;->indexOf(I)I

    move-result v1

    .line 174
    if-ltz v1, :cond_2c

    invoke-virtual {p0, v2, v1}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object p0

    .line 175
    :cond_2c
    invoke-virtual {p0}, Ljava/lang/String;->length()I

    move-result v1

    if-eqz v1, :cond_a1

    invoke-virtual {p0}, Ljava/lang/String;->length()I

    move-result v1

    const/16 v3, 0x800

    if-le v1, v3, :cond_3b

    goto :goto_a1

    .line 176
    :cond_3b
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-virtual {p0}, Ljava/lang/String;->length()I

    move-result v3

    invoke-direct {v1, v3}, Ljava/lang/StringBuilder;-><init>(I)V

    .line 177
    nop

    :goto_45
    invoke-virtual {p0}, Ljava/lang/String;->length()I

    move-result v3

    if-ge v2, v3, :cond_95

    .line 178
    invoke-virtual {p0, v2}, Ljava/lang/String;->charAt(I)C

    move-result v3

    .line 179
    const/16 v4, 0x41

    if-lt v3, v4, :cond_57

    const/16 v4, 0x5a

    if-le v3, v4, :cond_8f

    :cond_57
    const/16 v4, 0x61

    if-lt v3, v4, :cond_5f

    const/16 v4, 0x7a

    if-le v3, v4, :cond_8f

    :cond_5f
    const/16 v4, 0x30

    if-lt v3, v4, :cond_67

    const/16 v4, 0x39

    if-le v3, v4, :cond_8f

    :cond_67
    const/16 v4, 0x25

    if-eq v3, v4, :cond_8f

    const/16 v4, 0x2d

    if-eq v3, v4, :cond_8f

    const/16 v4, 0x5f

    if-eq v3, v4, :cond_8f

    const/16 v4, 0x2e

    if-eq v3, v4, :cond_8f

    const/16 v4, 0x7e

    if-eq v3, v4, :cond_8f

    const/16 v4, 0x21

    if-eq v3, v4, :cond_8f

    const/16 v4, 0x2a

    if-eq v3, v4, :cond_8f

    const/16 v4, 0x27

    if-eq v3, v4, :cond_8f

    const/16 v4, 0x28

    if-eq v3, v4, :cond_8f

    const/16 v4, 0x29

    if-ne v3, v4, :cond_92

    .line 182
    :cond_8f
    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    .line 177
    :cond_92
    add-int/lit8 v2, v2, 0x1

    goto :goto_45

    .line 185
    :cond_95
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->length()I

    move-result p0

    if-nez p0, :cond_9c

    goto :goto_a0

    :cond_9c
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    :goto_a0
    return-object v0

    .line 175
    :cond_a1
    :goto_a1
    return-object v0
.end method

.method private fetch(Ljava/lang/String;Ljava/lang/String;Z)Landroid/webkit/WebResourceResponse;
    .registers 15

    .line 322
    nop

    .line 324
    const/4 v0, 0x0

    :try_start_2
    new-instance v1, Ljava/net/URL;

    invoke-direct {v1, p1}, Ljava/net/URL;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1}, Ljava/net/URL;->openConnection()Ljava/net/URLConnection;

    move-result-object v1

    check-cast v1, Ljava/net/HttpURLConnection;
    :try_end_d
    .catchall {:try_start_2 .. :try_end_d} :catchall_134

    .line 325
    :try_start_d
    const-string v2, "GET"

    invoke-virtual {v1, v2}, Ljava/net/HttpURLConnection;->setRequestMethod(Ljava/lang/String;)V

    .line 326
    const/16 v2, 0x2ee0

    invoke-virtual {v1, v2}, Ljava/net/HttpURLConnection;->setConnectTimeout(I)V

    .line 327
    const/16 v2, 0x4650

    invoke-virtual {v1, v2}, Ljava/net/HttpURLConnection;->setReadTimeout(I)V

    .line 328
    const/4 v2, 0x1

    invoke-virtual {v1, v2}, Ljava/net/HttpURLConnection;->setInstanceFollowRedirects(Z)V

    .line 329
    const-string v3, "User-Agent"

    const-string v4, "Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36"

    invoke-virtual {v1, v3, v4}, Ljava/net/HttpURLConnection;->setRequestProperty(Ljava/lang/String;Ljava/lang/String;)V

    .line 330
    iget-object v3, p0, Lcom/cicp/jwxt/CookieWebClient;->cookie:Ljava/lang/String;

    invoke-virtual {v3}, Ljava/lang/String;->length()I

    move-result v3

    if-lez v3, :cond_36

    const-string v3, "Cookie"

    iget-object v4, p0, Lcom/cicp/jwxt/CookieWebClient;->cookie:Ljava/lang/String;

    invoke-virtual {v1, v3, v4}, Ljava/net/HttpURLConnection;->setRequestProperty(Ljava/lang/String;Ljava/lang/String;)V

    .line 331
    :cond_36
    invoke-virtual {v1}, Ljava/net/HttpURLConnection;->getResponseCode()I

    move-result v3
    :try_end_3a
    .catchall {:try_start_d .. :try_end_3a} :catchall_132

    .line 332
    const/16 v4, 0x190

    if-lt v3, v4, :cond_44

    .line 372
    if-eqz v1, :cond_43

    invoke-virtual {v1}, Ljava/net/HttpURLConnection;->disconnect()V

    .line 332
    :cond_43
    return-object v0

    .line 333
    :cond_44
    :try_start_44
    invoke-virtual {v1}, Ljava/net/HttpURLConnection;->getContentType()Ljava/lang/String;

    move-result-object v3

    .line 334
    const-string v4, "UTF-8"

    .line 335
    const/4 v5, 0x0

    if-eqz v3, :cond_7f

    .line 336
    const-string v6, ";"

    invoke-virtual {v3, v6}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v3

    .line 337
    aget-object v6, v3, v5

    invoke-virtual {v6}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v6

    .line 338
    move v7, v2

    :goto_5a
    array-length v8, v3

    if-ge v7, v8, :cond_7e

    .line 339
    aget-object v8, v3, v7

    invoke-virtual {v8}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v8

    .line 340
    invoke-virtual {v8}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;

    move-result-object v9

    const-string v10, "charset="

    invoke-virtual {v9, v10}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v9

    if-eqz v9, :cond_7b

    .line 341
    const/16 v3, 0x8

    invoke-virtual {v8, v3}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v4

    .line 342
    move-object v3, v6

    goto :goto_7f

    .line 338
    :cond_7b
    add-int/lit8 v7, v7, 0x1

    goto :goto_5a

    :cond_7e
    move-object v3, v6

    .line 346
    :cond_7f
    :goto_7f
    if-eqz v3, :cond_8f

    invoke-virtual {v3}, Ljava/lang/String;->length()I

    move-result v6

    if-eqz v6, :cond_8f

    const/16 v6, 0x2f

    invoke-virtual {v3, v6}, Ljava/lang/String;->indexOf(I)I

    move-result v6

    if-gez v6, :cond_93

    :cond_8f
    invoke-direct {p0, p1}, Lcom/cicp/jwxt/CookieWebClient;->guessMime(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    .line 347
    :cond_93
    invoke-virtual {v1}, Ljava/net/HttpURLConnection;->getInputStream()Ljava/io/InputStream;

    move-result-object p1

    .line 348
    new-instance v6, Ljava/io/ByteArrayOutputStream;

    invoke-direct {v6}, Ljava/io/ByteArrayOutputStream;-><init>()V

    .line 349
    const/16 v7, 0x2000

    new-array v7, v7, [B

    .line 351
    :goto_a0
    invoke-virtual {p1, v7}, Ljava/io/InputStream;->read([B)I

    move-result v8

    if-lez v8, :cond_aa

    invoke-virtual {v6, v7, v5, v8}, Ljava/io/ByteArrayOutputStream;->write([BII)V

    goto :goto_a0

    .line 352
    :cond_aa
    invoke-virtual {p1}, Ljava/io/InputStream;->close()V

    .line 353
    invoke-virtual {v6}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    move-result-object p1

    .line 354
    if-eqz v3, :cond_c1

    invoke-virtual {v3}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;

    move-result-object v6

    const-string v7, "html"

    invoke-virtual {v6, v7}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I

    move-result v6

    if-ltz v6, :cond_c1

    move v6, v2

    goto :goto_c2

    :cond_c1
    move v6, v5

    .line 355
    :goto_c2
    if-eqz p2, :cond_122

    if-eqz v6, :cond_122

    array-length v6, p1

    if-lez v6, :cond_122

    .line 356
    new-instance v6, Ljava/lang/String;

    invoke-direct {v6, p1, v4}, Ljava/lang/String;-><init>([BLjava/lang/String;)V

    .line 357
    if-eqz p3, :cond_d8

    .line 359
    const-string p1, "(?is)<meta[^>]+name\\s*=\\s*[\\\"\']viewport[\\\"\'][^>]*>"

    const-string p3, ""

    invoke-virtual {v6, p1, p3}, Ljava/lang/String;->replaceAll(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v6

    .line 361
    :cond_d8
    invoke-virtual {v6}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;

    move-result-object p1

    const-string p3, "<head"

    invoke-virtual {p1, p3}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I

    move-result p1

    .line 362
    if-ltz p1, :cond_eb

    const/16 p3, 0x3e

    invoke-virtual {v6, p3, p1}, Ljava/lang/String;->indexOf(II)I

    move-result p1

    goto :goto_ec

    :cond_eb
    const/4 p1, -0x1

    .line 363
    :goto_ec
    if-lez p1, :cond_10d

    new-instance p3, Ljava/lang/StringBuilder;

    invoke-direct {p3}, Ljava/lang/StringBuilder;-><init>()V

    add-int/2addr p1, v2

    invoke-virtual {v6, v5, p1}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {p3, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p3

    invoke-virtual {p3, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    invoke-virtual {v6, p1}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object p1

    invoke-virtual {p2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    goto :goto_11e

    .line 364
    :cond_10d
    new-instance p1, Ljava/lang/StringBuilder;

    invoke-direct {p1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {p1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    .line 365
    :goto_11e
    invoke-virtual {p1, v4}, Ljava/lang/String;->getBytes(Ljava/lang/String;)[B

    move-result-object p1

    .line 368
    :cond_122
    new-instance p2, Landroid/webkit/WebResourceResponse;

    new-instance p3, Ljava/io/ByteArrayInputStream;

    invoke-direct {p3, p1}, Ljava/io/ByteArrayInputStream;-><init>([B)V

    invoke-direct {p2, v3, v4, p3}, Landroid/webkit/WebResourceResponse;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/io/InputStream;)V
    :try_end_12c
    .catchall {:try_start_44 .. :try_end_12c} :catchall_132

    .line 372
    if-eqz v1, :cond_131

    invoke-virtual {v1}, Ljava/net/HttpURLConnection;->disconnect()V

    .line 368
    :cond_131
    return-object p2

    .line 369
    :catchall_132
    move-exception p1

    goto :goto_136

    :catchall_134
    move-exception p1

    move-object v1, v0

    .line 370
    :goto_136
    nop

    .line 372
    if-eqz v1, :cond_13c

    invoke-virtual {v1}, Ljava/net/HttpURLConnection;->disconnect()V

    .line 370
    :cond_13c
    return-object v0
.end method

.method private guessMime(Ljava/lang/String;)Ljava/lang/String;
    .registers 4

    .line 225
    if-nez p1, :cond_5

    const-string p1, ""

    goto :goto_9

    :cond_5
    invoke-virtual {p1}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;

    move-result-object p1

    .line 226
    :goto_9
    const/16 v0, 0x3f

    invoke-virtual {p1, v0}, Ljava/lang/String;->indexOf(I)I

    move-result v0

    .line 227
    if-lez v0, :cond_16

    const/4 v1, 0x0

    invoke-virtual {p1, v1, v0}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object p1

    .line 228
    :cond_16
    const-string v0, ".css"

    invoke-virtual {p1, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_21

    const-string p1, "text/css"

    return-object p1

    .line 229
    :cond_21
    const-string v0, ".js"

    invoke-virtual {p1, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_2c

    const-string p1, "application/javascript"

    return-object p1

    .line 230
    :cond_2c
    const-string v0, ".png"

    invoke-virtual {p1, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_37

    const-string p1, "image/png"

    return-object p1

    .line 231
    :cond_37
    const-string v0, ".jpg"

    invoke-virtual {p1, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v0

    if-nez v0, :cond_7d

    const-string v0, ".jpeg"

    invoke-virtual {p1, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_48

    goto :goto_7d

    .line 232
    :cond_48
    const-string v0, ".gif"

    invoke-virtual {p1, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_53

    const-string p1, "image/gif"

    return-object p1

    .line 233
    :cond_53
    const-string v0, ".svg"

    invoke-virtual {p1, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_5e

    const-string p1, "image/svg+xml"

    return-object p1

    .line 234
    :cond_5e
    const-string v0, ".woff"

    invoke-virtual {p1, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v0

    if-nez v0, :cond_7a

    const-string v0, ".woff2"

    invoke-virtual {p1, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v0

    if-nez v0, :cond_7a

    const-string v0, ".ttf"

    invoke-virtual {p1, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-eqz p1, :cond_77

    goto :goto_7a

    .line 235
    :cond_77
    const-string p1, "text/html"

    return-object p1

    .line 234
    :cond_7a
    :goto_7a
    const-string p1, "font/woff2"

    return-object p1

    .line 231
    :cond_7d
    :goto_7d
    const-string p1, "image/jpeg"

    return-object p1
.end method

.method private insetStyle(Ljava/lang/String;)Ljava/lang/String;
    .registers 6

    .line 297
    new-instance p1, Ljava/lang/StringBuilder;

    invoke-direct {p1}, Ljava/lang/StringBuilder;-><init>()V

    .line 299
    const-string v0, "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1,maximum-scale=3,user-scalable=yes\">"

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 302
    const-string v0, "<style id=\"jwxt-inset\">"

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    .line 303
    const-string v1, "html{padding-top:32px!important;box-sizing:border-box!important;background:#EEF0F4!important}"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    .line 304
    const-string v1, "body{padding-bottom:26px!important;box-sizing:border-box!important;background:#fff!important}"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    .line 305
    const-string v1, "</style>"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 306
    iget v0, p0, Lcom/cicp/jwxt/CookieWebClient;->padBottom:I

    if-lez v0, :cond_36

    .line 307
    const-string v0, "<style id=\"jwxt-inset-b\">html{padding-bottom:"

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget v2, p0, Lcom/cicp/jwxt/CookieWebClient;->padBottom:I

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    .line 308
    const-string v2, "px!important;box-sizing:border-box!important}</style>"

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 310
    :cond_36
    const-string v0, "<style id=\"jwxt-mobile\">"

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v2, "html,body{width:auto!important;min-width:0!important;max-width:100%!important;}.new-main .main .sidebar,.sidebar{display:none!important;}.main,.new-main .main{margin-left:0!important;padding-left:0!important;width:100%!important;}.iframeClass,#iframeClass{padding-left:0!important;margin-left:0!important;width:100%!important;left:0!important;}.new-main .main .sidebar.shrink + .iframeClass{padding-left:0!important;}.top div{width:auto!important;}.container,.content,.main-content,.main_content,.mainbody,.mainBody,.wrap,.wrapper,.box,.panel,.contentbox,.new-main,.index-main{width:auto!important;min-width:0!important;max-width:100%!important;margin-left:0!important;margin-right:0!important;}table{max-width:none!important;}.kbcontent1,.kbcontent,.kb,.td,.td1,.td2{white-space:normal!important;word-break:break-all!important;}input[type=text],input[type=password],input[type=search],select,textarea{max-width:100%!important;box-sizing:border-box!important;}img{max-width:100%!important;height:auto!important;}body{overflow-x:auto!important;-webkit-overflow-scrolling:touch;}"

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 311
    iget-object v0, p0, Lcom/cicp/jwxt/CookieWebClient;->userCss:Ljava/lang/String;

    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v0

    if-lez v0, :cond_5c

    const-string v0, "<style id=\"jwxt-user\">"

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-object v2, p0, Lcom/cicp/jwxt/CookieWebClient;->userCss:Ljava/lang/String;

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 312
    :cond_5c
    iget-object v0, p0, Lcom/cicp/jwxt/CookieWebClient;->userJs:Ljava/lang/String;

    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v0

    if-lez v0, :cond_7d

    .line 314
    const-string v0, "<script id=\"jwxt-user-js\">try{"

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-object v1, p0, Lcom/cicp/jwxt/CookieWebClient;->userJs:Ljava/lang/String;

    .line 315
    const-string v2, "</script>"

    const-string v3, "<\\/script>"

    invoke-virtual {v1, v2, v3}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    .line 316
    const-string v1, "}catch(e){(function(){try{console.warn(\'[jwxt-user-js]\',e);}catch(_){}})();}</script>"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 318
    :cond_7d
    invoke-virtual {p1}, Ljava/lang/StringBuilder;->length()I

    move-result v0

    if-nez v0, :cond_85

    const/4 p1, 0x0

    goto :goto_89

    :cond_85
    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    :goto_89
    return-object p1
.end method

.method private static isFrameworkPage(Ljava/lang/String;)Z
    .registers 3

    .line 112
    const/4 v0, 0x0

    if-nez p0, :cond_4

    return v0

    .line 114
    :cond_4
    const-string v1, "mobile=0"

    invoke-virtual {p0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v1

    if-nez v1, :cond_27

    const-string v1, "native=1"

    invoke-virtual {p0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v1

    if-eqz v1, :cond_15

    goto :goto_27

    .line 115
    :cond_15
    const-string v1, "/framework/xsMainV.htmlx"

    invoke-virtual {p0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v1

    if-nez v1, :cond_25

    const-string v1, "/framework/xsMain.jsp"

    invoke-virtual {p0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result p0

    if-eqz p0, :cond_26

    :cond_25
    const/4 v0, 0x1

    :cond_26
    return v0

    .line 114
    :cond_27
    :goto_27
    return v0
.end method

.method private loadMobilePage(Landroid/webkit/WebView;)Ljava/lang/String;
    .registers 7

    .line 93
    iget-object v0, p0, Lcom/cicp/jwxt/CookieWebClient;->mobilePage:Ljava/lang/String;

    if-eqz v0, :cond_7

    iget-object p1, p0, Lcom/cicp/jwxt/CookieWebClient;->mobilePage:Ljava/lang/String;

    return-object p1

    .line 94
    :cond_7
    nop

    .line 96
    const/4 v0, 0x0

    :try_start_9
    invoke-virtual {p1}, Landroid/webkit/WebView;->getContext()Landroid/content/Context;

    move-result-object p1

    invoke-virtual {p1}, Landroid/content/Context;->getAssets()Landroid/content/res/AssetManager;

    move-result-object p1

    const-string v1, "jwxt-mobile.html"

    invoke-virtual {p1, v1}, Landroid/content/res/AssetManager;->open(Ljava/lang/String;)Ljava/io/InputStream;

    move-result-object p1
    :try_end_17
    .catchall {:try_start_9 .. :try_end_17} :catchall_40

    .line 97
    :try_start_17
    new-instance v1, Ljava/io/ByteArrayOutputStream;

    invoke-direct {v1}, Ljava/io/ByteArrayOutputStream;-><init>()V

    .line 98
    const/16 v2, 0x2000

    new-array v2, v2, [B

    .line 100
    :goto_20
    invoke-virtual {p1, v2}, Ljava/io/InputStream;->read([B)I

    move-result v3

    if-lez v3, :cond_2b

    const/4 v4, 0x0

    invoke-virtual {v1, v2, v4, v3}, Ljava/io/ByteArrayOutputStream;->write([BII)V

    goto :goto_20

    .line 101
    :cond_2b
    new-instance v2, Ljava/lang/String;

    invoke-virtual {v1}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    move-result-object v1

    const-string v3, "UTF-8"

    invoke-direct {v2, v1, v3}, Ljava/lang/String;-><init>([BLjava/lang/String;)V

    iput-object v2, p0, Lcom/cicp/jwxt/CookieWebClient;->mobilePage:Ljava/lang/String;
    :try_end_38
    .catchall {:try_start_17 .. :try_end_38} :catchall_3e

    .line 105
    if-eqz p1, :cond_4c

    :try_start_3a
    invoke-virtual {p1}, Ljava/io/InputStream;->close()V
    :try_end_3d
    .catchall {:try_start_3a .. :try_end_3d} :catchall_4a

    goto :goto_4c

    .line 102
    :catchall_3e
    move-exception v1

    goto :goto_42

    :catchall_40
    move-exception p1

    move-object p1, v0

    .line 103
    :goto_42
    :try_start_42
    iput-object v0, p0, Lcom/cicp/jwxt/CookieWebClient;->mobilePage:Ljava/lang/String;
    :try_end_44
    .catchall {:try_start_42 .. :try_end_44} :catchall_4f

    .line 105
    if-eqz p1, :cond_4c

    :try_start_46
    invoke-virtual {p1}, Ljava/io/InputStream;->close()V
    :try_end_49
    .catchall {:try_start_46 .. :try_end_49} :catchall_4a

    goto :goto_4c

    :catchall_4a
    move-exception p1

    .line 106
    nop

    .line 107
    :cond_4c
    :goto_4c
    iget-object p1, p0, Lcom/cicp/jwxt/CookieWebClient;->mobilePage:Ljava/lang/String;

    return-object p1

    .line 105
    :catchall_4f
    move-exception v0

    if-eqz p1, :cond_57

    :try_start_52
    invoke-virtual {p1}, Ljava/io/InputStream;->close()V
    :try_end_55
    .catchall {:try_start_52 .. :try_end_55} :catchall_56

    goto :goto_57

    :catchall_56
    move-exception p1

    .line 106
    :cond_57
    :goto_57
    throw v0
.end method

.method private nativeInsetStyle()Ljava/lang/String;
    .registers 2

    .line 278
    const-string v0, "<meta name=\"viewport\" content=\"width=1042,initial-scale=0.374,maximum-scale=3,user-scalable=yes\"><style id=\"jwxt-native\">html::before{content:\'\';position:fixed;top:0;left:0;width:100%;height:40px;background:#000;z-index:2147483647;pointer-events:none;}html{background:#fff!important;}body{padding-top:40px!important;box-sizing:border-box!important;}.sidebar{display:block!important;visibility:visible!important;opacity:1!important;transform:none!important;width:275px!important;max-width:none!important;position:relative!important;}</style>"

    return-object v0
.end method

.method private static prefillScript(Ljava/lang/String;)Ljava/lang/String;
    .registers 3

    .line 190
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "(function(){var raw=\""

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    const-string v0, "\";var q=null;try{q=JSON.parse(decodeURIComponent(raw));}catch(e){return;}if(!q||!q.t)return;function setv(n,v){if(v==null||v===\'\')return;var el=document.querySelector(\'[name=\"\'+n+\'\"]\');if(!el)return;if(el.tagName===\'SELECT\'){var hit=-1,i;for(i=0;i<el.options.length;i++){if(el.options[i].value===v){hit=i;break;}}if(hit<0&&/^\\d+$/.test(v)){var pad=(\'0\'+v).slice(-2);for(i=0;i<el.options.length;i++){if(el.options[i].value===pad){hit=i;break;}}}if(hit<0){for(i=0;i<el.options.length;i++){if((el.options[i].text||\'\').replace(/\\s+/g,\'\')===v){hit=i;break;}}}if(hit>=0)el.selectedIndex=hit;}else{el.value=v;}try{el.dispatchEvent(new Event(\'change\',{bubbles:true}));}catch(e){}try{if(window.jQuery)jQuery(el).trigger(\'change\');}catch(e){}}function run(){try{setv(\'xnxqh\',q.sem);}catch(e){}try{if(q.t===\'teacher\'||q.t===\'classroom\')setv(\'skjs\',q.name);else if(q.t===\'class\')setv(\'skbj\',q.name);else if(q.t===\'course\')setv(\'kcmc\',q.name);}catch(e){}if(q.week){try{setv(\'zc1\',q.week);setv(\'zc2\',q.week);}catch(e){}}var f=document.getElementById(\'Form1\');if(f){try{f.submit();}catch(e){}}}setTimeout(run,350);})();"

    invoke-virtual {p0, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    .line 221
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "<script id=\"jwxt-prefill\">"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    const-string v0, "</script>"

    invoke-virtual {p0, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method


# virtual methods
.method public onPageFinished(Landroid/webkit/WebView;Ljava/lang/String;)V
    .registers 5

    .line 81
    invoke-direct {p0, p1, p2}, Lcom/cicp/jwxt/CookieWebClient;->applyInset(Landroid/webkit/WebView;Ljava/lang/String;)V

    .line 83
    if-eqz p2, :cond_16

    :try_start_5
    iget-object v0, p0, Lcom/cicp/jwxt/CookieWebClient;->host:Ljava/lang/String;

    invoke-virtual {p2, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v0

    if-eqz v0, :cond_16

    const-string v0, "(function(){try{var id=\'jwxt-mobile-js\',old=document.getElementById(id);if(old)old.parentNode.removeChild(old);var s=document.createElement(\'style\');s.id=id;s.textContent=\'.sidebar,.new-main .main .sidebar{display:none!important}\'+\'.main,.new-main .main{margin-left:0!important;padding-left:0!important;width:100%!important}\'+\'.iframeClass,#iframeClass{margin-left:0!important;padding-left:0!important;width:100%!important;left:0!important}\'+\'.container,.content,.main-content,.main_content,.mainbody,.mainBody,.wrap,.wrapper,.box,.panel,.contentbox,.new-main,.index-main{width:auto!important;min-width:0!important;max-width:100%!important;margin-left:0!important}\'+\'table{max-width:none!important}\'+\'.kbcontent1,.kbcontent,.kb{white-space:normal!important;word-break:break-all!important}\'+\'img{max-width:100%!important;height:auto!important}\'+\'body{overflow-x:auto!important}\'+\'.top div{width:auto!important}\';document.documentElement.appendChild(s);}catch(e){}})();"

    const/4 v1, 0x0

    invoke-virtual {p1, v0, v1}, Landroid/webkit/WebView;->evaluateJavascript(Ljava/lang/String;Landroid/webkit/ValueCallback;)V
    :try_end_13
    .catchall {:try_start_5 .. :try_end_13} :catchall_14

    goto :goto_16

    .line 84
    :catchall_14
    move-exception v0

    goto :goto_17

    .line 85
    :cond_16
    :goto_16
    nop

    .line 86
    :goto_17
    invoke-super {p0, p1, p2}, Landroid/webkit/WebViewClient;->onPageFinished(Landroid/webkit/WebView;Ljava/lang/String;)V

    .line 87
    return-void
.end method

.method public onPageStarted(Landroid/webkit/WebView;Ljava/lang/String;Landroid/graphics/Bitmap;)V
    .registers 4

    .line 59
    invoke-direct {p0, p1, p2}, Lcom/cicp/jwxt/CookieWebClient;->applyInset(Landroid/webkit/WebView;Ljava/lang/String;)V

    .line 60
    invoke-super {p0, p1, p2, p3}, Landroid/webkit/WebViewClient;->onPageStarted(Landroid/webkit/WebView;Ljava/lang/String;Landroid/graphics/Bitmap;)V

    .line 61
    return-void
.end method

.method public setUserScript(Ljava/lang/String;Ljava/lang/String;)V
    .registers 4

    .line 239
    const-string v0, ""

    if-nez p1, :cond_5

    move-object p1, v0

    :cond_5
    iput-object p1, p0, Lcom/cicp/jwxt/CookieWebClient;->userCss:Ljava/lang/String;

    .line 240
    if-nez p2, :cond_a

    move-object p2, v0

    :cond_a
    iput-object p2, p0, Lcom/cicp/jwxt/CookieWebClient;->userJs:Ljava/lang/String;

    .line 241
    return-void
.end method

.method public shouldInterceptRequest(Landroid/webkit/WebView;Landroid/webkit/WebResourceRequest;)Landroid/webkit/WebResourceResponse;
    .registers 11

    .line 121
    const-string v0, "UTF-8"

    const-string v1, "native=1"

    const/4 v2, 0x0

    :try_start_5
    invoke-interface {p2}, Landroid/webkit/WebResourceRequest;->getUrl()Landroid/net/Uri;

    move-result-object v3

    invoke-virtual {v3}, Landroid/net/Uri;->toString()Ljava/lang/String;

    move-result-object v3

    .line 122
    invoke-interface {p2}, Landroid/webkit/WebResourceRequest;->getUrl()Landroid/net/Uri;

    move-result-object v4

    invoke-virtual {v4}, Landroid/net/Uri;->getHost()Ljava/lang/String;

    move-result-object v4

    .line 123
    if-eqz v4, :cond_ba

    iget-object v5, p0, Lcom/cicp/jwxt/CookieWebClient;->host:Ljava/lang/String;

    if-eqz v5, :cond_ba

    iget-object v5, p0, Lcom/cicp/jwxt/CookieWebClient;->host:Ljava/lang/String;

    invoke-virtual {v4, v5}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v4

    if-nez v4, :cond_25

    goto/16 :goto_ba

    .line 124
    :cond_25
    invoke-interface {p2}, Landroid/webkit/WebResourceRequest;->getMethod()Ljava/lang/String;

    move-result-object p2

    .line 125
    if-eqz p2, :cond_34

    const-string v4, "GET"

    invoke-virtual {v4, p2}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result p2

    if-nez p2, :cond_34

    return-object v2

    .line 127
    :cond_34
    invoke-static {v3}, Lcom/cicp/jwxt/CookieWebClient;->isFrameworkPage(Ljava/lang/String;)Z

    move-result p2

    if-eqz p2, :cond_52

    .line 128
    invoke-direct {p0, p1}, Lcom/cicp/jwxt/CookieWebClient;->loadMobilePage(Landroid/webkit/WebView;)Ljava/lang/String;

    move-result-object p1
    :try_end_3e
    .catchall {:try_start_5 .. :try_end_3e} :catchall_bb

    .line 129
    if-eqz p1, :cond_52

    .line 131
    :try_start_40
    new-instance p2, Landroid/webkit/WebResourceResponse;

    const-string v4, "text/html"

    new-instance v5, Ljava/io/ByteArrayInputStream;

    .line 132
    invoke-virtual {p1, v0}, Ljava/lang/String;->getBytes(Ljava/lang/String;)[B

    move-result-object p1

    invoke-direct {v5, p1}, Ljava/io/ByteArrayInputStream;-><init>([B)V

    invoke-direct {p2, v4, v0, v5}, Landroid/webkit/WebResourceResponse;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/io/InputStream;)V
    :try_end_50
    .catchall {:try_start_40 .. :try_end_50} :catchall_51

    .line 131
    return-object p2

    .line 133
    :catchall_51
    move-exception p1

    .line 140
    :cond_52
    :try_start_52
    invoke-virtual {v3, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result p1

    const/4 p2, 0x1

    if-eqz p1, :cond_6c

    .line 141
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v0

    const-wide/32 v4, 0x1d4c0

    add-long/2addr v0, v4

    iput-wide v0, p0, Lcom/cicp/jwxt/CookieWebClient;->nativeUntil:J

    .line 145
    invoke-direct {p0}, Lcom/cicp/jwxt/CookieWebClient;->nativeInsetStyle()Ljava/lang/String;

    move-result-object p1

    invoke-direct {p0, v3, p1, p2}, Lcom/cicp/jwxt/CookieWebClient;->fetch(Ljava/lang/String;Ljava/lang/String;Z)Landroid/webkit/WebResourceResponse;

    move-result-object p1

    return-object p1

    .line 150
    :cond_6c
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v4

    iget-wide v6, p0, Lcom/cicp/jwxt/CookieWebClient;->nativeUntil:J

    cmp-long p1, v4, v6

    if-gez p1, :cond_87

    const-string p1, "/jsxsd/framework/"

    invoke-virtual {v3, p1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result p1

    if-eqz p1, :cond_87

    .line 151
    invoke-direct {p0}, Lcom/cicp/jwxt/CookieWebClient;->nativeInsetStyle()Ljava/lang/String;

    move-result-object p1

    invoke-direct {p0, v3, p1, p2}, Lcom/cicp/jwxt/CookieWebClient;->fetch(Ljava/lang/String;Ljava/lang/String;Z)Landroid/webkit/WebResourceResponse;

    move-result-object p1

    return-object p1

    .line 154
    :cond_87
    invoke-virtual {v3, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result p1

    .line 155
    if-eqz p1, :cond_92

    invoke-direct {p0}, Lcom/cicp/jwxt/CookieWebClient;->nativeInsetStyle()Ljava/lang/String;

    move-result-object v0

    goto :goto_96

    :cond_92
    invoke-direct {p0, v3}, Lcom/cicp/jwxt/CookieWebClient;->insetStyle(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 157
    :goto_96
    if-eqz p1, :cond_9a

    move-object p1, v2

    goto :goto_9e

    :cond_9a
    invoke-static {v3}, Lcom/cicp/jwxt/CookieWebClient;->extractQuery(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p1

    .line 158
    :goto_9e
    if-eqz p1, :cond_b5

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-static {p1}, Lcom/cicp/jwxt/CookieWebClient;->prefillScript(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p1

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 159
    :cond_b5
    invoke-direct {p0, v3, v0, p2}, Lcom/cicp/jwxt/CookieWebClient;->fetch(Ljava/lang/String;Ljava/lang/String;Z)Landroid/webkit/WebResourceResponse;

    move-result-object p1
    :try_end_b9
    .catchall {:try_start_52 .. :try_end_b9} :catchall_bb

    return-object p1

    .line 123
    :cond_ba
    :goto_ba
    return-object v2

    .line 160
    :catchall_bb
    move-exception p1

    .line 161
    return-object v2
.end method
