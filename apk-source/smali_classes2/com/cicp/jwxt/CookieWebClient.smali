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

.field private final padBottom:I

.field private final padTop:I

.field private userCss:Ljava/lang/String;

.field private userJs:Ljava/lang/String;


# direct methods
.method public constructor <init>(Ljava/lang/String;Ljava/lang/String;)V
    .registers 4

    .line 31
    const/4 v0, 0x0

    invoke-direct {p0, p1, p2, v0, v0}, Lcom/cicp/jwxt/CookieWebClient;-><init>(Ljava/lang/String;Ljava/lang/String;II)V

    .line 32
    return-void
.end method

.method public constructor <init>(Ljava/lang/String;Ljava/lang/String;II)V
    .registers 6

    .line 34
    invoke-direct {p0}, Landroid/webkit/WebViewClient;-><init>()V

    .line 26
    const-string v0, ""

    iput-object v0, p0, Lcom/cicp/jwxt/CookieWebClient;->userCss:Ljava/lang/String;

    .line 27
    iput-object v0, p0, Lcom/cicp/jwxt/CookieWebClient;->userJs:Ljava/lang/String;

    .line 35
    iput-object p1, p0, Lcom/cicp/jwxt/CookieWebClient;->host:Ljava/lang/String;

    .line 36
    if-nez p2, :cond_e

    move-object p2, v0

    :cond_e
    iput-object p2, p0, Lcom/cicp/jwxt/CookieWebClient;->cookie:Ljava/lang/String;

    .line 37
    iput p3, p0, Lcom/cicp/jwxt/CookieWebClient;->padTop:I

    .line 38
    iput p4, p0, Lcom/cicp/jwxt/CookieWebClient;->padBottom:I

    .line 39
    return-void
.end method

.method private applyInset(Landroid/webkit/WebView;Ljava/lang/String;)V
    .registers 6

    .line 44
    const/4 v0, 0x0

    if-eqz p2, :cond_f

    :try_start_3
    iget-object v1, p0, Lcom/cicp/jwxt/CookieWebClient;->host:Ljava/lang/String;

    invoke-virtual {p2, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result p2

    if-eqz p2, :cond_f

    const/4 p2, 0x1

    goto :goto_10

    .line 47
    :catchall_d
    move-exception p1

    goto :goto_26

    .line 44
    :cond_f
    move p2, v0

    .line 45
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

    .line 46
    if-eqz p2, :cond_22

    const/4 v0, -0x1

    :cond_22
    invoke-virtual {p1, v0}, Landroid/webkit/WebView;->setBackgroundColor(I)V
    :try_end_25
    .catchall {:try_start_3 .. :try_end_25} :catchall_d

    .line 48
    nop

    .line 49
    :goto_26
    return-void
.end method

.method private static extractQuery(Ljava/lang/String;)Ljava/lang/String;
    .registers 6

    .line 104
    const/4 v0, 0x0

    if-nez p0, :cond_4

    return-object v0

    .line 105
    :cond_4
    const-string v1, "__q="

    invoke-virtual {p0, v1}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I

    move-result v1

    .line 106
    if-gez v1, :cond_d

    return-object v0

    .line 107
    :cond_d
    add-int/lit8 v1, v1, 0x4

    invoke-virtual {p0, v1}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object p0

    .line 108
    const/16 v1, 0x26

    invoke-virtual {p0, v1}, Ljava/lang/String;->indexOf(I)I

    move-result v1

    .line 109
    const/4 v2, 0x0

    if-ltz v1, :cond_20

    invoke-virtual {p0, v2, v1}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object p0

    .line 110
    :cond_20
    const/16 v1, 0x23

    invoke-virtual {p0, v1}, Ljava/lang/String;->indexOf(I)I

    move-result v1

    .line 111
    if-ltz v1, :cond_2c

    invoke-virtual {p0, v2, v1}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object p0

    .line 112
    :cond_2c
    invoke-virtual {p0}, Ljava/lang/String;->length()I

    move-result v1

    if-eqz v1, :cond_a1

    invoke-virtual {p0}, Ljava/lang/String;->length()I

    move-result v1

    const/16 v3, 0x800

    if-le v1, v3, :cond_3b

    goto :goto_a1

    .line 113
    :cond_3b
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-virtual {p0}, Ljava/lang/String;->length()I

    move-result v3

    invoke-direct {v1, v3}, Ljava/lang/StringBuilder;-><init>(I)V

    .line 114
    nop

    :goto_45
    invoke-virtual {p0}, Ljava/lang/String;->length()I

    move-result v3

    if-ge v2, v3, :cond_95

    .line 115
    invoke-virtual {p0, v2}, Ljava/lang/String;->charAt(I)C

    move-result v3

    .line 116
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

    .line 119
    :cond_8f
    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    .line 114
    :cond_92
    add-int/lit8 v2, v2, 0x1

    goto :goto_45

    .line 122
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

    .line 112
    :cond_a1
    :goto_a1
    return-object v0
.end method

.method private fetch(Ljava/lang/String;Ljava/lang/String;)Landroid/webkit/WebResourceResponse;
    .registers 14

    .line 231
    nop

    .line 233
    const/4 v0, 0x0

    :try_start_2
    new-instance v1, Ljava/net/URL;

    invoke-direct {v1, p1}, Ljava/net/URL;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1}, Ljava/net/URL;->openConnection()Ljava/net/URLConnection;

    move-result-object v1

    check-cast v1, Ljava/net/HttpURLConnection;
    :try_end_d
    .catchall {:try_start_2 .. :try_end_d} :catchall_12a

    .line 234
    :try_start_d
    const-string v2, "GET"

    invoke-virtual {v1, v2}, Ljava/net/HttpURLConnection;->setRequestMethod(Ljava/lang/String;)V

    .line 235
    const/16 v2, 0x2ee0

    invoke-virtual {v1, v2}, Ljava/net/HttpURLConnection;->setConnectTimeout(I)V

    .line 236
    const/16 v2, 0x4650

    invoke-virtual {v1, v2}, Ljava/net/HttpURLConnection;->setReadTimeout(I)V

    .line 237
    const/4 v2, 0x1

    invoke-virtual {v1, v2}, Ljava/net/HttpURLConnection;->setInstanceFollowRedirects(Z)V

    .line 238
    const-string v3, "User-Agent"

    const-string v4, "Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36"

    invoke-virtual {v1, v3, v4}, Ljava/net/HttpURLConnection;->setRequestProperty(Ljava/lang/String;Ljava/lang/String;)V

    .line 239
    iget-object v3, p0, Lcom/cicp/jwxt/CookieWebClient;->cookie:Ljava/lang/String;

    invoke-virtual {v3}, Ljava/lang/String;->length()I

    move-result v3

    if-lez v3, :cond_36

    const-string v3, "Cookie"

    iget-object v4, p0, Lcom/cicp/jwxt/CookieWebClient;->cookie:Ljava/lang/String;

    invoke-virtual {v1, v3, v4}, Ljava/net/HttpURLConnection;->setRequestProperty(Ljava/lang/String;Ljava/lang/String;)V

    .line 240
    :cond_36
    invoke-virtual {v1}, Ljava/net/HttpURLConnection;->getResponseCode()I

    move-result v3
    :try_end_3a
    .catchall {:try_start_d .. :try_end_3a} :catchall_128

    .line 241
    const/16 v4, 0x190

    if-lt v3, v4, :cond_44

    .line 277
    if-eqz v1, :cond_43

    invoke-virtual {v1}, Ljava/net/HttpURLConnection;->disconnect()V

    .line 241
    :cond_43
    return-object v0

    .line 242
    :cond_44
    :try_start_44
    invoke-virtual {v1}, Ljava/net/HttpURLConnection;->getContentType()Ljava/lang/String;

    move-result-object v3

    .line 243
    const-string v4, "UTF-8"

    .line 244
    const/4 v5, 0x0

    if-eqz v3, :cond_7f

    .line 245
    const-string v6, ";"

    invoke-virtual {v3, v6}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v3

    .line 246
    aget-object v6, v3, v5

    invoke-virtual {v6}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v6

    .line 247
    move v7, v2

    :goto_5a
    array-length v8, v3

    if-ge v7, v8, :cond_7e

    .line 248
    aget-object v8, v3, v7

    invoke-virtual {v8}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v8

    .line 249
    invoke-virtual {v8}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;

    move-result-object v9

    const-string v10, "charset="

    invoke-virtual {v9, v10}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v9

    if-eqz v9, :cond_7b

    .line 250
    const/16 v3, 0x8

    invoke-virtual {v8, v3}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v4

    .line 251
    move-object v3, v6

    goto :goto_7f

    .line 247
    :cond_7b
    add-int/lit8 v7, v7, 0x1

    goto :goto_5a

    :cond_7e
    move-object v3, v6

    .line 255
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

    .line 256
    :cond_93
    invoke-virtual {v1}, Ljava/net/HttpURLConnection;->getInputStream()Ljava/io/InputStream;

    move-result-object p1

    .line 257
    new-instance v6, Ljava/io/ByteArrayOutputStream;

    invoke-direct {v6}, Ljava/io/ByteArrayOutputStream;-><init>()V

    .line 258
    const/16 v7, 0x2000

    new-array v7, v7, [B

    .line 260
    :goto_a0
    invoke-virtual {p1, v7}, Ljava/io/InputStream;->read([B)I

    move-result v8

    if-lez v8, :cond_aa

    invoke-virtual {v6, v7, v5, v8}, Ljava/io/ByteArrayOutputStream;->write([BII)V

    goto :goto_a0

    .line 261
    :cond_aa
    invoke-virtual {p1}, Ljava/io/InputStream;->close()V

    .line 262
    invoke-virtual {v6}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    move-result-object p1

    .line 263
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

    .line 264
    :goto_c2
    if-eqz p2, :cond_118

    if-eqz v6, :cond_118

    array-length v6, p1

    if-lez v6, :cond_118

    .line 265
    new-instance v6, Ljava/lang/String;

    invoke-direct {v6, p1, v4}, Ljava/lang/String;-><init>([BLjava/lang/String;)V

    .line 266
    invoke-virtual {v6}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;

    move-result-object p1

    const-string v7, "<head"

    invoke-virtual {p1, v7}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I

    move-result p1

    .line 267
    if-ltz p1, :cond_e1

    const/16 v7, 0x3e

    invoke-virtual {v6, v7, p1}, Ljava/lang/String;->indexOf(II)I

    move-result p1

    goto :goto_e2

    :cond_e1
    const/4 p1, -0x1

    .line 268
    :goto_e2
    if-lez p1, :cond_103

    new-instance v7, Ljava/lang/StringBuilder;

    invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V

    add-int/2addr p1, v2

    invoke-virtual {v6, v5, p1}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v7, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    invoke-virtual {v6, p1}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object p1

    invoke-virtual {p2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    goto :goto_114

    .line 269
    :cond_103
    new-instance p1, Ljava/lang/StringBuilder;

    invoke-direct {p1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {p1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    .line 270
    :goto_114
    invoke-virtual {p1, v4}, Ljava/lang/String;->getBytes(Ljava/lang/String;)[B

    move-result-object p1

    .line 273
    :cond_118
    new-instance p2, Landroid/webkit/WebResourceResponse;

    new-instance v2, Ljava/io/ByteArrayInputStream;

    invoke-direct {v2, p1}, Ljava/io/ByteArrayInputStream;-><init>([B)V

    invoke-direct {p2, v3, v4, v2}, Landroid/webkit/WebResourceResponse;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/io/InputStream;)V
    :try_end_122
    .catchall {:try_start_44 .. :try_end_122} :catchall_128

    .line 277
    if-eqz v1, :cond_127

    invoke-virtual {v1}, Ljava/net/HttpURLConnection;->disconnect()V

    .line 273
    :cond_127
    return-object p2

    .line 274
    :catchall_128
    move-exception p1

    goto :goto_12c

    :catchall_12a
    move-exception p1

    move-object v1, v0

    .line 275
    :goto_12c
    nop

    .line 277
    if-eqz v1, :cond_132

    invoke-virtual {v1}, Ljava/net/HttpURLConnection;->disconnect()V

    .line 275
    :cond_132
    return-object v0
.end method

.method private guessMime(Ljava/lang/String;)Ljava/lang/String;
    .registers 4

    .line 162
    if-nez p1, :cond_5

    const-string p1, ""

    goto :goto_9

    :cond_5
    invoke-virtual {p1}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;

    move-result-object p1

    .line 163
    :goto_9
    const/16 v0, 0x3f

    invoke-virtual {p1, v0}, Ljava/lang/String;->indexOf(I)I

    move-result v0

    .line 164
    if-lez v0, :cond_16

    const/4 v1, 0x0

    invoke-virtual {p1, v1, v0}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object p1

    .line 165
    :cond_16
    const-string v0, ".css"

    invoke-virtual {p1, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_21

    const-string p1, "text/css"

    return-object p1

    .line 166
    :cond_21
    const-string v0, ".js"

    invoke-virtual {p1, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_2c

    const-string p1, "application/javascript"

    return-object p1

    .line 167
    :cond_2c
    const-string v0, ".png"

    invoke-virtual {p1, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_37

    const-string p1, "image/png"

    return-object p1

    .line 168
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

    .line 169
    :cond_48
    const-string v0, ".gif"

    invoke-virtual {p1, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_53

    const-string p1, "image/gif"

    return-object p1

    .line 170
    :cond_53
    const-string v0, ".svg"

    invoke-virtual {p1, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_5e

    const-string p1, "image/svg+xml"

    return-object p1

    .line 171
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

    .line 172
    :cond_77
    const-string p1, "text/html"

    return-object p1

    .line 171
    :cond_7a
    :goto_7a
    const-string p1, "font/woff2"

    return-object p1

    .line 168
    :cond_7d
    :goto_7d
    const-string p1, "image/jpeg"

    return-object p1
.end method

.method private insetStyle()Ljava/lang/String;
    .registers 6

    .line 210
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    .line 212
    const-string v1, "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1,maximum-scale=3,user-scalable=yes\">"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 213
    iget v1, p0, Lcom/cicp/jwxt/CookieWebClient;->padTop:I

    if-gtz v1, :cond_12

    iget v1, p0, Lcom/cicp/jwxt/CookieWebClient;->padBottom:I

    if-lez v1, :cond_35

    .line 214
    :cond_12
    const-string v1, "<style id=\"jwxt-inset\">html{padding-top:"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget v2, p0, Lcom/cicp/jwxt/CookieWebClient;->padTop:I

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    .line 215
    const-string v2, "px!important;padding-bottom:"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget v2, p0, Lcom/cicp/jwxt/CookieWebClient;->padBottom:I

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    .line 216
    const-string v2, "px!important;box-sizing:border-box!important;background:#fff!important}"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    .line 217
    const-string v2, "body{background:#fff!important}</style>"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 219
    :cond_35
    const-string v1, "<style id=\"jwxt-mobile\">"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "html,body{width:auto!important;min-width:0!important;max-width:100%!important;}.new-main .main .sidebar,.sidebar{display:none!important;}.main,.new-main .main{margin-left:0!important;padding-left:0!important;width:100%!important;}.iframeClass,#iframeClass{padding-left:0!important;margin-left:0!important;width:100%!important;left:0!important;}.new-main .main .sidebar.shrink + .iframeClass{padding-left:0!important;}.top div{width:auto!important;}.container,.content,.main-content,.main_content,.mainbody,.mainBody,.wrap,.wrapper,.box,.panel,.contentbox,.new-main,.index-main{width:auto!important;min-width:0!important;max-width:100%!important;margin-left:0!important;margin-right:0!important;}table{max-width:none!important;}.kbcontent1,.kbcontent,.kb,.td,.td1,.td2{white-space:normal!important;word-break:break-all!important;}input[type=text],input[type=password],input[type=search],select,textarea{max-width:100%!important;box-sizing:border-box!important;}img{max-width:100%!important;height:auto!important;}body{overflow-x:auto!important;-webkit-overflow-scrolling:touch;}"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "</style>"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 220
    iget-object v1, p0, Lcom/cicp/jwxt/CookieWebClient;->userCss:Ljava/lang/String;

    invoke-virtual {v1}, Ljava/lang/String;->length()I

    move-result v1

    if-lez v1, :cond_5d

    const-string v1, "<style id=\"jwxt-user\">"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget-object v3, p0, Lcom/cicp/jwxt/CookieWebClient;->userCss:Ljava/lang/String;

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 221
    :cond_5d
    iget-object v1, p0, Lcom/cicp/jwxt/CookieWebClient;->userJs:Ljava/lang/String;

    invoke-virtual {v1}, Ljava/lang/String;->length()I

    move-result v1

    if-lez v1, :cond_7e

    .line 223
    const-string v1, "<script id=\"jwxt-user-js\">try{"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget-object v2, p0, Lcom/cicp/jwxt/CookieWebClient;->userJs:Ljava/lang/String;

    .line 224
    const-string v3, "</script>"

    const-string v4, "<\\/script>"

    invoke-virtual {v2, v3, v4}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    .line 225
    const-string v2, "}catch(e){(function(){try{console.warn(\'[jwxt-user-js]\',e);}catch(_){}})();}</script>"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 227
    :cond_7e
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->length()I

    move-result v1

    if-nez v1, :cond_86

    const/4 v0, 0x0

    goto :goto_8a

    :cond_86
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    :goto_8a
    return-object v0
.end method

.method private static prefillScript(Ljava/lang/String;)Ljava/lang/String;
    .registers 3

    .line 127
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

    .line 158
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

    .line 75
    invoke-direct {p0, p1, p2}, Lcom/cicp/jwxt/CookieWebClient;->applyInset(Landroid/webkit/WebView;Ljava/lang/String;)V

    .line 77
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

    .line 78
    :catchall_14
    move-exception v0

    goto :goto_17

    .line 79
    :cond_16
    :goto_16
    nop

    .line 80
    :goto_17
    invoke-super {p0, p1, p2}, Landroid/webkit/WebViewClient;->onPageFinished(Landroid/webkit/WebView;Ljava/lang/String;)V

    .line 81
    return-void
.end method

.method public onPageStarted(Landroid/webkit/WebView;Ljava/lang/String;Landroid/graphics/Bitmap;)V
    .registers 4

    .line 53
    invoke-direct {p0, p1, p2}, Lcom/cicp/jwxt/CookieWebClient;->applyInset(Landroid/webkit/WebView;Ljava/lang/String;)V

    .line 54
    invoke-super {p0, p1, p2, p3}, Landroid/webkit/WebViewClient;->onPageStarted(Landroid/webkit/WebView;Ljava/lang/String;Landroid/graphics/Bitmap;)V

    .line 55
    return-void
.end method

.method public setUserScript(Ljava/lang/String;Ljava/lang/String;)V
    .registers 4

    .line 176
    const-string v0, ""

    if-nez p1, :cond_5

    move-object p1, v0

    :cond_5
    iput-object p1, p0, Lcom/cicp/jwxt/CookieWebClient;->userCss:Ljava/lang/String;

    .line 177
    if-nez p2, :cond_a

    move-object p2, v0

    :cond_a
    iput-object p2, p0, Lcom/cicp/jwxt/CookieWebClient;->userJs:Ljava/lang/String;

    .line 178
    return-void
.end method

.method public shouldInterceptRequest(Landroid/webkit/WebView;Landroid/webkit/WebResourceRequest;)Landroid/webkit/WebResourceResponse;
    .registers 6

    .line 86
    const/4 p1, 0x0

    :try_start_1
    invoke-interface {p2}, Landroid/webkit/WebResourceRequest;->getUrl()Landroid/net/Uri;

    move-result-object v0

    invoke-virtual {v0}, Landroid/net/Uri;->toString()Ljava/lang/String;

    move-result-object v0

    .line 87
    invoke-interface {p2}, Landroid/webkit/WebResourceRequest;->getUrl()Landroid/net/Uri;

    move-result-object v1

    invoke-virtual {v1}, Landroid/net/Uri;->getHost()Ljava/lang/String;

    move-result-object v1

    .line 88
    if-eqz v1, :cond_53

    iget-object v2, p0, Lcom/cicp/jwxt/CookieWebClient;->host:Ljava/lang/String;

    if-eqz v2, :cond_53

    iget-object v2, p0, Lcom/cicp/jwxt/CookieWebClient;->host:Ljava/lang/String;

    invoke-virtual {v1, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-nez v1, :cond_20

    goto :goto_53

    .line 89
    :cond_20
    invoke-interface {p2}, Landroid/webkit/WebResourceRequest;->getMethod()Ljava/lang/String;

    move-result-object p2

    .line 90
    if-eqz p2, :cond_2f

    const-string v1, "GET"

    invoke-virtual {v1, p2}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result p2

    if-nez p2, :cond_2f

    return-object p1

    .line 92
    :cond_2f
    invoke-direct {p0}, Lcom/cicp/jwxt/CookieWebClient;->insetStyle()Ljava/lang/String;

    move-result-object p2

    .line 94
    invoke-static {v0}, Lcom/cicp/jwxt/CookieWebClient;->extractQuery(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    .line 95
    if-eqz v1, :cond_4e

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v2, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    invoke-static {v1}, Lcom/cicp/jwxt/CookieWebClient;->prefillScript(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    invoke-virtual {p2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p2

    .line 96
    :cond_4e
    invoke-direct {p0, v0, p2}, Lcom/cicp/jwxt/CookieWebClient;->fetch(Ljava/lang/String;Ljava/lang/String;)Landroid/webkit/WebResourceResponse;

    move-result-object p1
    :try_end_52
    .catchall {:try_start_1 .. :try_end_52} :catchall_54

    return-object p1

    .line 88
    :cond_53
    :goto_53
    return-object p1

    .line 97
    :catchall_54
    move-exception p2

    .line 98
    return-object p1
.end method
