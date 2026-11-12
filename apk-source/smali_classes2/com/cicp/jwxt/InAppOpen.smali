.class public Lcom/cicp/jwxt/InAppOpen;
.super Ljava/lang/Object;
.source "InAppOpen.java"


# static fields
.field private static final BASE:Ljava/lang/String; = "https://jwxt.cicp.edu.cn/"

.field private static final CICP_HOST:Ljava/lang/String; = "jwxt.cicp.edu.cn"

.field private static final UA:Ljava/lang/String; = "Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36"


# direct methods
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

.method private static diagHtml(Ljava/lang/String;Ljava/lang/StringBuilder;Z)Ljava/lang/String;
    .registers 6

    .line 182
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

    .line 183
    if-eqz p2, :cond_21

    const-string v0, "\u767b\u5f55\u72b6\u6001\u5df2\u8fc7\u671f"

    goto :goto_23

    :cond_21
    const-string v0, "\u8fd8\u6ca1\u767b\u5f55"

    .line 184
    :goto_23
    if-eqz p2, :cond_28

    .line 185
    const-string p2, "\u6559\u52a1\u7cfb\u7edf\u5df2\u7ecf\u628a\u4f60\u767b\u51fa\u4e86\uff0c\u5148\u5728\u5e94\u7528\u91cc\u91cd\u65b0\u767b\u5f55\uff0c\u518d\u70b9\u300c\u524d\u5f80\u5b98\u7f51\u300d\u5c31\u80fd\u76f4\u63a5\u8fdb\u53bb\u3002"

    goto :goto_2a

    .line 186
    :cond_28
    const-string p2, "\u5148\u5728\u5e94\u7528\u91cc\u767b\u5f55\u6559\u52a1\u7cfb\u7edf\uff0c\u518d\u70b9\u300c\u524d\u5f80\u5b98\u7f51\u300d\u5c31\u80fd\u76f4\u63a5\u8fdb\u53bb\u3002"

    .line 187
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

    const-string v0, "</p><div class=\'btns\'><button onclick=\"try{Android.showNativeLogin()}catch(e){}\">\u91cd\u65b0\u767b\u5f55</button><button class=\'ghost\' onclick=\"try{history.back()}catch(e){}\">\u8fd4\u56de\u5e94\u7528</button></div><details><summary>\u8bca\u65ad\u4fe1\u606f</summary><pre>"

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

    .line 402
    const-string v0, "JSESSIONID="

    invoke-virtual {p0, v0}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I

    move-result v0

    .line 403
    if-gez v0, :cond_e

    const-string v0, "bzb_jsxsd="

    invoke-virtual {p0, v0}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I

    move-result v0

    .line 404
    :cond_e
    if-gez v0, :cond_12

    const/4 p0, 0x0

    return-object p0

    .line 405
    :cond_12
    move v1, v0

    .line 406
    :goto_13
    if-lez v1, :cond_2f

    .line 407
    add-int/lit8 v2, v1, -0x1

    invoke-virtual {p0, v2}, Ljava/lang/String;->charAt(I)C

    move-result v2

    .line 408
    const/16 v3, 0x3e

    if-eq v2, v3, :cond_2f

    const/16 v3, 0x22

    if-eq v2, v3, :cond_2f

    const/16 v3, 0xa

    if-eq v2, v3, :cond_2f

    const/16 v3, 0xd

    if-ne v2, v3, :cond_2c

    goto :goto_2f

    .line 409
    :cond_2c
    add-int/lit8 v1, v1, -0x1

    .line 410
    goto :goto_13

    .line 411
    :cond_2f
    :goto_2f
    const/16 v2, 0x3c

    invoke-virtual {p0, v2, v0}, Ljava/lang/String;->indexOf(II)I

    move-result v0

    .line 412
    if-gez v0, :cond_3b

    invoke-virtual {p0}, Ljava/lang/String;->length()I

    move-result v0

    .line 413
    :cond_3b
    invoke-virtual {p0, v1, v0}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object p0

    .line 414
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

    .line 415
    return-object p0
.end method

.method private static fetch(Ljava/lang/String;Ljava/lang/String;Ljava/lang/StringBuilder;)Ljava/lang/String;
    .registers 9

    .line 241
    nop

    .line 243
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

    .line 244
    :try_start_f
    const-string v3, "GET"

    invoke-virtual {v2, v3}, Ljava/net/HttpURLConnection;->setRequestMethod(Ljava/lang/String;)V

    .line 245
    const/16 v3, 0x3a98

    invoke-virtual {v2, v3}, Ljava/net/HttpURLConnection;->setConnectTimeout(I)V

    .line 246
    const/16 v3, 0x4e20

    invoke-virtual {v2, v3}, Ljava/net/HttpURLConnection;->setReadTimeout(I)V

    .line 247
    const/4 v3, 0x1

    invoke-virtual {v2, v3}, Ljava/net/HttpURLConnection;->setInstanceFollowRedirects(Z)V

    .line 248
    const-string v3, "User-Agent"

    const-string v4, "Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36"

    invoke-virtual {v2, v3, v4}, Ljava/net/HttpURLConnection;->setRequestProperty(Ljava/lang/String;Ljava/lang/String;)V

    .line 249
    invoke-virtual {p1}, Ljava/lang/String;->length()I

    move-result v3

    if-lez v3, :cond_34

    const-string v3, "Cookie"

    invoke-virtual {v2, v3, p1}, Ljava/net/HttpURLConnection;->setRequestProperty(Ljava/lang/String;Ljava/lang/String;)V

    .line 250
    :cond_34
    invoke-virtual {v2}, Ljava/net/HttpURLConnection;->getResponseCode()I

    move-result p1

    .line 251
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

    .line 252
    invoke-virtual {p0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    const-string v3, "Location"

    invoke-virtual {v2, v3}, Ljava/net/HttpURLConnection;->getHeaderField(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {p0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0, v0}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    .line 253
    invoke-virtual {v2}, Ljava/net/HttpURLConnection;->getHeaderFields()Ljava/util/Map;

    move-result-object p0

    .line 254
    if-eqz p0, :cond_9f

    .line 255
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

    .line 256
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

    .line 257
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

    .line 259
    :cond_9e
    goto :goto_6d

    .line 261
    :cond_9f
    const/16 p0, 0x190

    if-lt p1, p0, :cond_a9

    .line 275
    if-eqz v2, :cond_a8

    invoke-virtual {v2}, Ljava/net/HttpURLConnection;->disconnect()V

    .line 261
    :cond_a8
    return-object v1

    .line 262
    :cond_a9
    :try_start_a9
    invoke-virtual {v2}, Ljava/net/HttpURLConnection;->getInputStream()Ljava/io/InputStream;

    move-result-object p0

    .line 263
    new-instance p1, Ljava/io/ByteArrayOutputStream;

    invoke-direct {p1}, Ljava/io/ByteArrayOutputStream;-><init>()V

    .line 264
    const/16 v3, 0x2000

    new-array v3, v3, [B

    .line 266
    :goto_b6
    invoke-virtual {p0, v3}, Ljava/io/InputStream;->read([B)I

    move-result v4

    if-lez v4, :cond_c1

    const/4 v5, 0x0

    invoke-virtual {p1, v3, v5, v4}, Ljava/io/ByteArrayOutputStream;->write([BII)V

    goto :goto_b6

    .line 267
    :cond_c1
    invoke-virtual {p0}, Ljava/io/InputStream;->close()V

    .line 268
    new-instance p0, Ljava/lang/String;

    invoke-virtual {p1}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    move-result-object p1

    const-string v3, "UTF-8"

    invoke-direct {p0, p1, v3}, Ljava/lang/String;-><init>([BLjava/lang/String;)V

    .line 269
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

    .line 270
    nop

    .line 275
    if-eqz v2, :cond_f4

    invoke-virtual {v2}, Ljava/net/HttpURLConnection;->disconnect()V

    .line 270
    :cond_f4
    return-object p0

    .line 271
    :catchall_f5
    move-exception p0

    goto :goto_f9

    :catchall_f7
    move-exception p0

    move-object v2, v1

    .line 272
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

    .line 273
    nop

    .line 275
    if-eqz v2, :cond_10c

    invoke-virtual {v2}, Ljava/net/HttpURLConnection;->disconnect()V

    .line 273
    :cond_10c
    return-object v1

    .line 275
    :catchall_10d
    move-exception p0

    if-eqz v2, :cond_113

    invoke-virtual {v2}, Ljava/net/HttpURLConnection;->disconnect()V

    .line 276
    :cond_113
    throw p0
.end method

.method private static isLoginPage(Ljava/lang/String;)Z
    .registers 5

    .line 232
    invoke-static {p0}, Lcom/cicp/jwxt/InAppOpen;->titleOf(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 233
    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v1

    const/4 v2, 0x1

    const/4 v3, 0x0

    if-nez v1, :cond_1f

    .line 234
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

    .line 236
    :cond_1f
    const-string p0, "\u4e2d\u8b66\u9662"

    invoke-virtual {v0, p0}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I

    move-result p0

    if-ltz p0, :cond_28

    return v3

    .line 237
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

    .line 339
    if-nez p0, :cond_5

    const-string p0, "\'\'"

    return-object p0

    .line 340
    :cond_5
    new-instance v0, Ljava/lang/StringBuilder;

    const-string v1, "\'"

    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    .line 341
    const/4 v1, 0x0

    :goto_d
    invoke-virtual {p0}, Ljava/lang/String;->length()I

    move-result v2

    const/16 v3, 0x27

    if-ge v1, v2, :cond_28

    .line 342
    invoke-virtual {p0, v1}, Ljava/lang/String;->charAt(I)C

    move-result v2

    .line 343
    const/16 v4, 0x5c

    if-eq v2, v4, :cond_1f

    if-ne v2, v3, :cond_22

    :cond_1f
    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    .line 344
    :cond_22
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    .line 341
    add-int/lit8 v1, v1, 0x1

    goto :goto_d

    .line 346
    :cond_28
    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method private static normalize(Ljava/lang/String;)Ljava/lang/String;
    .registers 3

    .line 220
    const-string v0, "https://jwxt.cicp.edu.cn/jsxsd/framework/xsMain.jsp"

    if-nez p0, :cond_5

    return-object v0

    .line 221
    :cond_5
    invoke-virtual {p0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object p0

    .line 222
    invoke-virtual {p0}, Ljava/lang/String;->length()I

    move-result v1

    if-nez v1, :cond_10

    return-object v0

    .line 223
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

    .line 224
    const-string v1, "http://jwxt.cicp.edu.cn/"

    invoke-virtual {p0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-nez v1, :cond_4a

    const-string v1, "https://jwxt.cicp.edu.cn/"

    invoke-virtual {p0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-nez v1, :cond_4a

    .line 225
    const-string v1, "/jsxsd"

    invoke-virtual {p0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v1

    if-nez v1, :cond_4a

    const-string v1, "/jsxsd/"

    invoke-virtual {p0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v1

    if-eqz v1, :cond_49

    goto :goto_4a

    .line 228
    :cond_49
    return-object p0

    .line 226
    :cond_4a
    :goto_4a
    return-object v0
.end method

.method public static open(Landroid/app/Activity;Ljava/lang/String;)V
    .registers 15

    .line 30
    if-nez p0, :cond_3

    return-void

    .line 31
    :cond_3
    new-instance v8, Ljava/lang/StringBuilder;

    invoke-direct {v8}, Ljava/lang/StringBuilder;-><init>()V

    .line 32
    invoke-static {p0, v8}, Lcom/cicp/jwxt/InAppOpen;->readCookies(Landroid/content/Context;Ljava/lang/StringBuilder;)Ljava/lang/String;

    move-result-object v6

    .line 33
    const-string v0, "cookieLen="

    invoke-virtual {v8, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v6}, Ljava/lang/String;->length()I

    move-result v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const/16 v1, 0xa

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    .line 35
    invoke-static {p1}, Lcom/cicp/jwxt/InAppOpen;->normalize(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v7

    .line 37
    nop

    .line 38
    nop

    .line 39
    invoke-virtual {v6}, Ljava/lang/String;->length()I

    move-result p1

    const-string v0, "https://jwxt.cicp.edu.cn/jsxsd/framework/xsMain.jsp"

    const/4 v2, 0x1

    const/4 v3, 0x0

    if-lez p1, :cond_52

    .line 40
    invoke-static {v0, v6, v8}, Lcom/cicp/jwxt/InAppOpen;->fetch(Ljava/lang/String;Ljava/lang/String;Ljava/lang/StringBuilder;)Ljava/lang/String;

    move-result-object p1

    .line 41
    if-eqz p1, :cond_43

    invoke-virtual {p1}, Ljava/lang/String;->length()I

    move-result v4

    if-lez v4, :cond_43

    invoke-static {p1}, Lcom/cicp/jwxt/InAppOpen;->isLoginPage(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_43

    move p1, v2

    goto :goto_44

    :cond_43
    move p1, v3

    .line 42
    :goto_44
    const-string v4, "warm="

    invoke-virtual {v8, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, p1}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v1}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    goto :goto_53

    .line 39
    :cond_52
    move p1, v3

    .line 44
    :goto_53
    invoke-static {v7, v6, v8}, Lcom/cicp/jwxt/InAppOpen;->fetch(Ljava/lang/String;Ljava/lang/String;Ljava/lang/StringBuilder;)Ljava/lang/String;

    move-result-object v4

    .line 45
    if-nez p1, :cond_6b

    if-eqz v4, :cond_6b

    invoke-static {v4}, Lcom/cicp/jwxt/InAppOpen;->isLoginPage(Ljava/lang/String;)Z

    move-result p1

    if-eqz p1, :cond_6b

    invoke-virtual {v6}, Ljava/lang/String;->length()I

    move-result p1

    if-lez p1, :cond_6b

    .line 47
    invoke-static {v7, v6, v8}, Lcom/cicp/jwxt/InAppOpen;->fetch(Ljava/lang/String;Ljava/lang/String;Ljava/lang/StringBuilder;)Ljava/lang/String;

    move-result-object v4

    .line 50
    :cond_6b
    if-eqz v4, :cond_98

    invoke-static {v4}, Lcom/cicp/jwxt/InAppOpen;->isLoginPage(Ljava/lang/String;)Z

    move-result p1

    if-eqz p1, :cond_98

    invoke-virtual {v0, v7}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p1

    if-nez p1, :cond_98

    invoke-virtual {v6}, Ljava/lang/String;->length()I

    move-result p1

    if-lez p1, :cond_98

    .line 52
    invoke-static {v0, v6, v8}, Lcom/cicp/jwxt/InAppOpen;->fetch(Ljava/lang/String;Ljava/lang/String;Ljava/lang/StringBuilder;)Ljava/lang/String;

    move-result-object p1

    .line 53
    if-eqz p1, :cond_98

    invoke-virtual {p1}, Ljava/lang/String;->length()I

    move-result v0

    if-lez v0, :cond_98

    invoke-static {p1}, Lcom/cicp/jwxt/InAppOpen;->isLoginPage(Ljava/lang/String;)Z

    move-result v0

    if-nez v0, :cond_98

    .line 54
    nop

    .line 55
    const-string v0, "fallbackHome=true\n"

    invoke-virtual {v8, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-object v4, p1

    .line 61
    :cond_98
    :try_start_98
    const-string p1, "jwxt-user.css"

    invoke-static {p0, p1}, Lcom/cicp/jwxt/InAppOpen;->readUserFile(Landroid/app/Activity;Ljava/lang/String;)Ljava/lang/String;

    move-result-object p1

    .line 62
    const-string v0, "jwxt-user.js"

    invoke-static {p0, v0}, Lcom/cicp/jwxt/InAppOpen;->readUserFile(Landroid/app/Activity;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v5
    :try_end_a4
    .catchall {:try_start_98 .. :try_end_a4} :catchall_160

    .line 65
    nop

    .line 66
    if-eqz v4, :cond_b5

    invoke-virtual {v4}, Ljava/lang/String;->length()I

    move-result v0

    if-lez v0, :cond_b5

    invoke-static {v4}, Lcom/cicp/jwxt/InAppOpen;->isLoginPage(Ljava/lang/String;)Z

    move-result v0

    if-nez v0, :cond_b5

    move v9, v2

    goto :goto_b6

    :cond_b5
    move v9, v3

    .line 67
    :goto_b6
    const-string v0, "htmlLen="

    invoke-virtual {v8, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    if-nez v4, :cond_c0

    const/4 v4, -0x1

    goto :goto_c4

    :cond_c0
    invoke-virtual {v4}, Ljava/lang/String;->length()I

    move-result v4

    :goto_c4
    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v4, " logged="

    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v9}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    .line 68
    invoke-virtual {v8}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {p0, v0}, Lcom/cicp/jwxt/InAppOpen;->writeDiag(Landroid/content/Context;Ljava/lang/String;)V

    .line 70
    invoke-static {p0}, Lcom/cicp/jwxt/InAppOpen;->webViewOf(Landroid/app/Activity;)Landroid/webkit/WebView;

    move-result-object v10

    .line 71
    if-nez v10, :cond_e3

    return-void

    .line 74
    :cond_e3
    :try_start_e3
    invoke-static {}, Landroid/webkit/CookieManager;->getInstance()Landroid/webkit/CookieManager;

    move-result-object v0

    .line 75
    invoke-virtual {v0, v2}, Landroid/webkit/CookieManager;->setAcceptCookie(Z)V

    .line 76
    invoke-virtual {v6}, Ljava/lang/String;->length()I

    move-result v1

    if-lez v1, :cond_11d

    .line 77
    const-string v1, ";"

    invoke-virtual {v6, v1}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v1

    .line 78
    move v4, v3

    :goto_f7
    array-length v11, v1

    if-ge v4, v11, :cond_11a

    .line 79
    aget-object v11, v1, v4

    invoke-virtual {v11}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v11

    .line 80
    invoke-virtual {v11}, Ljava/lang/String;->length()I

    move-result v12

    if-eqz v12, :cond_117

    const/16 v12, 0x3d

    invoke-virtual {v11, v12}, Ljava/lang/String;->indexOf(I)I

    move-result v12

    if-gtz v12, :cond_10f

    goto :goto_117

    .line 81
    :cond_10f
    const-string v12, "https://jwxt.cicp.edu.cn/"

    invoke-virtual {v0, v12, v11}, Landroid/webkit/CookieManager;->setCookie(Ljava/lang/String;Ljava/lang/String;)V

    .line 82
    invoke-virtual {v0, v7, v11}, Landroid/webkit/CookieManager;->setCookie(Ljava/lang/String;Ljava/lang/String;)V

    .line 78
    :cond_117
    :goto_117
    add-int/lit8 v4, v4, 0x1

    goto :goto_f7

    .line 84
    :cond_11a
    invoke-virtual {v0}, Landroid/webkit/CookieManager;->flush()V
    :try_end_11d
    .catchall {:try_start_e3 .. :try_end_11d} :catchall_11e

    .line 87
    :cond_11d
    goto :goto_11f

    .line 86
    :catchall_11e
    move-exception v0

    .line 89
    :goto_11f
    if-nez v9, :cond_151

    .line 91
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

    .line 95
    new-array p1, v2, [Z

    aput-boolean v3, p1, v3

    .line 96
    new-instance v9, Lcom/cicp/jwxt/InAppOpen$1;

    move-object v0, v9

    move-object v1, v10

    move-object v2, p0

    move-object v3, p1

    move-object v4, v7

    move-object v5, v8

    invoke-direct/range {v0 .. v6}, Lcom/cicp/jwxt/InAppOpen$1;-><init>(Landroid/webkit/WebView;Ljava/lang/String;[ZLjava/lang/String;Ljava/lang/StringBuilder;Ljava/lang/String;)V

    invoke-virtual {v10, v9}, Landroid/webkit/WebView;->post(Ljava/lang/Runnable;)Z

    .line 112
    return-void

    .line 114
    :cond_151
    new-instance v11, Lcom/cicp/jwxt/InAppOpen$2;

    move-object v0, v11

    move-object v1, v10

    move-object v2, p0

    move-object v3, v6

    move-object v4, p1

    move v6, v9

    invoke-direct/range {v0 .. v8}, Lcom/cicp/jwxt/InAppOpen$2;-><init>(Landroid/webkit/WebView;Landroid/app/Activity;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ZLjava/lang/String;Ljava/lang/StringBuilder;)V

    invoke-virtual {v10, v11}, Landroid/webkit/WebView;->post(Ljava/lang/Runnable;)Z

    .line 179
    return-void

    .line 63
    :catchall_160
    move-exception p0

    .line 64
    new-instance p1, Ljava/lang/RuntimeException;

    invoke-direct {p1, p0}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/Throwable;)V

    throw p1
.end method

.method private static readAll(Ljava/io/File;)Ljava/lang/String;
    .registers 5

    .line 317
    :try_start_0
    new-instance v0, Ljava/io/FileInputStream;

    invoke-direct {v0, p0}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V

    .line 318
    new-instance p0, Ljava/io/ByteArrayOutputStream;

    invoke-direct {p0}, Ljava/io/ByteArrayOutputStream;-><init>()V

    .line 319
    const/16 v1, 0x2000

    new-array v1, v1, [B

    .line 321
    :goto_e
    invoke-virtual {v0, v1}, Ljava/io/FileInputStream;->read([B)I

    move-result v2

    if-lez v2, :cond_19

    const/4 v3, 0x0

    invoke-virtual {p0, v1, v3, v2}, Ljava/io/ByteArrayOutputStream;->write([BII)V

    goto :goto_e

    .line 322
    :cond_19
    invoke-virtual {v0}, Ljava/io/FileInputStream;->close()V

    .line 323
    new-instance v0, Ljava/lang/String;

    invoke-virtual {p0}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    move-result-object p0

    const-string v1, "UTF-8"

    invoke-direct {v0, p0, v1}, Ljava/lang/String;-><init>([BLjava/lang/String;)V
    :try_end_27
    .catchall {:try_start_0 .. :try_end_27} :catchall_28

    return-object v0

    .line 324
    :catchall_28
    move-exception p0

    .line 325
    const/4 p0, 0x0

    return-object p0
.end method

.method private static readCookies(Landroid/content/Context;Ljava/lang/StringBuilder;)Ljava/lang/String;
    .registers 10

    .line 360
    const-string v0, ""

    new-instance v1, Ljava/util/ArrayList;

    invoke-direct {v1}, Ljava/util/ArrayList;-><init>()V

    .line 362
    const/16 v2, 0xa

    :try_start_9
    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v3

    const-string v4, "cookieStore"

    invoke-virtual {v3, v4}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object v3

    .line 363
    const/4 v4, 0x1

    invoke-virtual {v3, v4}, Ljava/lang/reflect/Field;->setAccessible(Z)V

    .line 364
    invoke-virtual {v3, p0}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v3

    .line 365
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

    .line 366
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

    .line 369
    :cond_4c
    goto :goto_5b

    .line 367
    :catchall_4d
    move-exception v3

    .line 368
    const-string v4, "fieldErr="

    invoke-virtual {p1, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    .line 371
    :goto_5b
    const/4 v3, 0x0

    :try_start_5c
    const-string v4, "jwxt"

    invoke-virtual {p0, v4, v3}, Landroid/content/Context;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;

    move-result-object v4

    .line 372
    const-string v5, "cookies"

    invoke-interface {v4, v5, v0}, Landroid/content/SharedPreferences;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v4

    .line 373
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

    .line 375
    :cond_7b
    goto :goto_7d

    .line 374
    :catchall_7c
    move-exception v4

    .line 378
    :goto_7d
    :try_start_7d
    new-instance v4, Ljava/io/File;

    invoke-virtual {p0}, Landroid/content/Context;->getApplicationInfo()Landroid/content/pm/ApplicationInfo;

    move-result-object p0

    iget-object p0, p0, Landroid/content/pm/ApplicationInfo;->dataDir:Ljava/lang/String;

    const-string v5, "shared_prefs"

    invoke-direct {v4, p0, v5}, Ljava/io/File;-><init>(Ljava/lang/String;Ljava/lang/String;)V

    .line 379
    invoke-virtual {v4}, Ljava/io/File;->listFiles()[Ljava/io/File;

    move-result-object p0

    .line 380
    if-eqz p0, :cond_e0

    .line 381
    move v4, v3

    :goto_91
    array-length v5, p0

    if-ge v4, v5, :cond_e0

    .line 382
    aget-object v5, p0, v4

    const/high16 v6, 0x10000

    invoke-static {v5, v6}, Lcom/cicp/jwxt/InAppOpen;->readText(Ljava/io/File;I)Ljava/lang/String;

    move-result-object v5

    .line 383
    if-nez v5, :cond_9f

    goto :goto_dd

    .line 384
    :cond_9f
    const-string v6, "JSESSIONID"

    invoke-virtual {v5, v6}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v6

    if-nez v6, :cond_af

    const-string v6, "bzb_jsxsd"

    invoke-virtual {v5, v6}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v6

    if-eqz v6, :cond_dd

    .line 385
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

    .line 386
    invoke-static {v5}, Lcom/cicp/jwxt/InAppOpen;->extractCookie(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v5

    .line 387
    if-eqz v5, :cond_dd

    invoke-virtual {v5}, Ljava/lang/String;->length()I

    move-result v6

    if-lez v6, :cond_dd

    invoke-virtual {v1, v5}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z
    :try_end_dd
    .catchall {:try_start_7d .. :try_end_dd} :catchall_e1

    .line 381
    :cond_dd
    :goto_dd
    add-int/lit8 v4, v4, 0x1

    goto :goto_91

    .line 393
    :cond_e0
    goto :goto_ef

    .line 391
    :catchall_e1
    move-exception p0

    .line 392
    const-string v4, "spScanErr="

    invoke-virtual {p1, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0, v2}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    .line 394
    :goto_ef
    nop

    .line 395
    nop

    :goto_f1
    invoke-virtual {v1}, Ljava/util/ArrayList;->size()I

    move-result p0

    if-ge v3, p0, :cond_111

    .line 396
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

    .line 395
    :cond_10e
    add-int/lit8 v3, v3, 0x1

    goto :goto_f1

    .line 398
    :cond_111
    return-object v0
.end method

.method private static readText(Ljava/io/File;I)Ljava/lang/String;
    .registers 6

    .line 425
    :try_start_0
    new-instance v0, Ljava/io/FileInputStream;

    invoke-direct {v0, p0}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V

    .line 426
    new-instance p0, Ljava/io/ByteArrayOutputStream;

    invoke-direct {p0}, Ljava/io/ByteArrayOutputStream;-><init>()V

    .line 427
    const/16 v1, 0x2000

    new-array v1, v1, [B

    .line 429
    :cond_e
    invoke-virtual {v0, v1}, Ljava/io/FileInputStream;->read([B)I

    move-result v2

    if-lez v2, :cond_1e

    .line 430
    const/4 v3, 0x0

    invoke-virtual {p0, v1, v3, v2}, Ljava/io/ByteArrayOutputStream;->write([BII)V

    .line 431
    invoke-virtual {p0}, Ljava/io/ByteArrayOutputStream;->size()I

    move-result v2

    if-le v2, p1, :cond_e

    .line 433
    :cond_1e
    invoke-virtual {v0}, Ljava/io/FileInputStream;->close()V

    .line 434
    new-instance p1, Ljava/lang/String;

    invoke-virtual {p0}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    move-result-object p0

    const-string v0, "UTF-8"

    invoke-direct {p1, p0, v0}, Ljava/lang/String;-><init>([BLjava/lang/String;)V
    :try_end_2c
    .catchall {:try_start_0 .. :try_end_2c} :catchall_2d

    return-object p1

    .line 435
    :catchall_2d
    move-exception p0

    .line 436
    const/4 p0, 0x0

    return-object p0
.end method

.method private static readUserFile(Landroid/app/Activity;Ljava/lang/String;)Ljava/lang/String;
    .registers 4

    .line 282
    const/4 v0, 0x0

    :try_start_1
    invoke-virtual {p0, v0}, Landroid/app/Activity;->getExternalFilesDir(Ljava/lang/String;)Ljava/io/File;

    move-result-object p0

    .line 283
    if-eqz p0, :cond_3f

    .line 284
    invoke-virtual {p0}, Ljava/io/File;->exists()Z

    move-result v0

    if-nez v0, :cond_10

    invoke-virtual {p0}, Ljava/io/File;->mkdirs()Z

    .line 285
    :cond_10
    new-instance v0, Ljava/io/File;

    invoke-direct {v0, p0, p1}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 286
    invoke-virtual {v0}, Ljava/io/File;->exists()Z

    move-result p0

    if-nez p0, :cond_2e

    .line 287
    const-string p0, ".css"

    invoke-virtual {p1, p0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p0

    if-eqz p0, :cond_29

    .line 288
    const-string p0, "/* \u81ea\u5b9a\u4e49\u6837\u5f0f\uff1a\u6bcf\u6b21\u6253\u5f00\u5b98\u7f51\u90fd\u4f1a\u91cd\u65b0\u8bfb\u53d6\uff0c\u6539\u5b8c\u91cd\u5f00\u5c31\u751f\u6548 */\n/* \u4f8b\uff1a\u5b57\u53f7\u653e\u5927  body{font-size:15px!important} */\n/* \u4f8b\uff1a\u9690\u85cf\u9876\u90e8\u5bfc\u822a .header,.top{display:none!important} */\n"

    invoke-static {v0, p0}, Lcom/cicp/jwxt/InAppOpen;->writeText(Ljava/io/File;Ljava/lang/String;)V

    goto :goto_2e

    .line 292
    :cond_29
    const-string p0, "// \u81ea\u5b9a\u4e49\u811a\u672c\uff1a\u6bcf\u6b21\u6253\u5f00\u5b98\u7f51\u90fd\u4f1a\u91cd\u65b0\u8bfb\u53d6\n// \u4f8b\uff1adocument.body.style.fontSize=\'15px\';\n"

    invoke-static {v0, p0}, Lcom/cicp/jwxt/InAppOpen;->writeText(Ljava/io/File;Ljava/lang/String;)V

    .line 296
    :cond_2e
    :goto_2e
    invoke-static {v0}, Lcom/cicp/jwxt/InAppOpen;->readAll(Ljava/io/File;)Ljava/lang/String;

    move-result-object p0

    .line 297
    if-eqz p0, :cond_3f

    invoke-virtual {p0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v0
    :try_end_3c
    .catchall {:try_start_1 .. :try_end_3c} :catchall_40

    if-lez v0, :cond_3f

    return-object p0

    .line 300
    :cond_3f
    goto :goto_41

    .line 299
    :catchall_40
    move-exception p0

    .line 301
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

    .line 302
    const/4 p1, 0x0

    :goto_6c
    const/4 v0, 0x2

    if-ge p1, v0, :cond_92

    .line 304
    :try_start_6f
    new-instance v0, Ljava/io/File;

    aget-object v1, p0, p1

    invoke-direct {v0, v1}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 305
    invoke-virtual {v0}, Ljava/io/File;->exists()Z

    move-result v1

    if-eqz v1, :cond_8d

    .line 306
    invoke-static {v0}, Lcom/cicp/jwxt/InAppOpen;->readAll(Ljava/io/File;)Ljava/lang/String;

    move-result-object v0

    .line 307
    if-eqz v0, :cond_8d

    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/String;->length()I

    move-result v1
    :try_end_8a
    .catchall {:try_start_6f .. :try_end_8a} :catchall_8e

    if-lez v1, :cond_8d

    return-object v0

    .line 310
    :cond_8d
    goto :goto_8f

    .line 309
    :catchall_8e
    move-exception v0

    .line 302
    :goto_8f
    add-int/lit8 p1, p1, 0x1

    goto :goto_6c

    .line 312
    :cond_92
    const-string p0, ""

    return-object p0
.end method

.method private static shrink(Ljava/lang/String;)Ljava/lang/String;
    .registers 4

    .line 419
    invoke-virtual {p0}, Ljava/lang/String;->length()I

    move-result v0

    const/16 v1, 0x258

    if-gt v0, v1, :cond_9

    return-object p0

    .line 420
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

    .line 208
    const-string v0, ""

    :try_start_2
    const-string v1, "<title>"

    invoke-virtual {p0, v1}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I

    move-result v1

    .line 209
    if-gez v1, :cond_b

    return-object v0

    .line 210
    :cond_b
    const-string v2, "</title>"

    invoke-virtual {p0, v2, v1}, Ljava/lang/String;->indexOf(Ljava/lang/String;I)I

    move-result v2

    .line 211
    if-gez v2, :cond_14

    return-object v0

    .line 212
    :cond_14
    add-int/lit8 v1, v1, 0x7

    invoke-virtual {p0, v1, v2}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object p0
    :try_end_1e
    .catchall {:try_start_2 .. :try_end_1e} :catchall_1f

    return-object p0

    .line 213
    :catchall_1f
    move-exception p0

    .line 214
    return-object v0
.end method

.method private static webViewOf(Landroid/app/Activity;)Landroid/webkit/WebView;
    .registers 3

    .line 351
    :try_start_0
    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v0

    const-string v1, "webView"

    invoke-virtual {v0, v1}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object v0

    .line 352
    const/4 v1, 0x1

    invoke-virtual {v0, v1}, Ljava/lang/reflect/Field;->setAccessible(Z)V

    .line 353
    invoke-virtual {v0, p0}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Landroid/webkit/WebView;
    :try_end_14
    .catchall {:try_start_0 .. :try_end_14} :catchall_15

    return-object p0

    .line 354
    :catchall_15
    move-exception p0

    .line 355
    const/4 p0, 0x0

    return-object p0
.end method

.method private static writeDiag(Landroid/content/Context;Ljava/lang/String;)V
    .registers 6

    .line 443
    const-string v0, "jwxt_debug.txt"

    :try_start_2
    const-string v1, "UTF-8"

    invoke-virtual {p1, v1}, Ljava/lang/String;->getBytes(Ljava/lang/String;)[B

    move-result-object p1
    :try_end_8
    .catchall {:try_start_2 .. :try_end_8} :catchall_9d

    .line 446
    nop

    .line 449
    :try_start_9
    new-instance v1, Landroid/content/ContentValues;

    invoke-direct {v1}, Landroid/content/ContentValues;-><init>()V

    .line 450
    const-string v2, "_display_name"

    invoke-virtual {v1, v2, v0}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 451
    const-string v2, "mime_type"

    const-string v3, "text/plain"

    invoke-virtual {v1, v2, v3}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 452
    const-string v2, "relative_path"

    sget-object v3, Landroid/os/Environment;->DIRECTORY_DOWNLOADS:Ljava/lang/String;

    invoke-virtual {v1, v2, v3}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 453
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v2

    sget-object v3, Landroid/provider/MediaStore$Downloads;->EXTERNAL_CONTENT_URI:Landroid/net/Uri;

    invoke-virtual {v2, v3, v1}, Landroid/content/ContentResolver;->insert(Landroid/net/Uri;Landroid/content/ContentValues;)Landroid/net/Uri;

    move-result-object v1

    .line 455
    if-eqz v1, :cond_43

    .line 456
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v2

    const-string v3, "wt"

    invoke-virtual {v2, v1, v3}, Landroid/content/ContentResolver;->openOutputStream(Landroid/net/Uri;Ljava/lang/String;)Ljava/io/OutputStream;

    move-result-object v1

    .line 457
    if-eqz v1, :cond_43

    .line 458
    invoke-virtual {v1, p1}, Ljava/io/OutputStream;->write([B)V

    .line 459
    invoke-virtual {v1}, Ljava/io/OutputStream;->flush()V

    .line 460
    invoke-virtual {v1}, Ljava/io/OutputStream;->close()V
    :try_end_42
    .catchall {:try_start_9 .. :try_end_42} :catchall_44

    .line 461
    return-void

    .line 465
    :cond_43
    goto :goto_45

    .line 464
    :catchall_44
    move-exception v1

    .line 468
    :goto_45
    const/4 v1, 0x0

    const/4 v2, 0x0

    :try_start_47
    invoke-virtual {p0, v1}, Landroid/content/Context;->getExternalFilesDir(Ljava/lang/String;)Ljava/io/File;

    move-result-object p0

    .line 469
    if-eqz p0, :cond_67

    .line 470
    invoke-virtual {p0}, Ljava/io/File;->exists()Z

    move-result v1

    if-nez v1, :cond_56

    invoke-virtual {p0}, Ljava/io/File;->mkdirs()Z

    .line 471
    :cond_56
    new-instance v1, Ljava/io/FileOutputStream;

    new-instance v3, Ljava/io/File;

    invoke-direct {v3, p0, v0}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-direct {v1, v3, v2}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;Z)V

    .line 472
    invoke-virtual {v1, p1}, Ljava/io/FileOutputStream;->write([B)V

    .line 473
    invoke-virtual {v1}, Ljava/io/FileOutputStream;->close()V
    :try_end_66
    .catchall {:try_start_47 .. :try_end_66} :catchall_68

    .line 474
    return-void

    .line 477
    :cond_67
    goto :goto_69

    .line 476
    :catchall_68
    move-exception p0

    .line 479
    :goto_69
    new-instance p0, Ljava/lang/StringBuilder;

    invoke-direct {p0}, Ljava/lang/StringBuilder;-><init>()V

    .line 480
    invoke-static {}, Landroid/os/Environment;->getExternalStorageDirectory()Ljava/io/File;

    move-result-object v0

    invoke-virtual {p0, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object p0

    const-string v0, "/Download/jwxt_debug.txt"

    invoke-virtual {p0, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    const-string v0, "/sdcard/Download/jwxt_debug.txt"

    filled-new-array {p0, v0}, [Ljava/lang/String;

    move-result-object p0

    .line 483
    move v0, v2

    :goto_87
    const/4 v1, 0x2

    if-ge v0, v1, :cond_9c

    .line 485
    :try_start_8a
    new-instance v1, Ljava/io/FileOutputStream;

    aget-object v3, p0, v0

    invoke-direct {v1, v3, v2}, Ljava/io/FileOutputStream;-><init>(Ljava/lang/String;Z)V

    .line 486
    invoke-virtual {v1, p1}, Ljava/io/FileOutputStream;->write([B)V

    .line 487
    invoke-virtual {v1}, Ljava/io/FileOutputStream;->close()V
    :try_end_97
    .catchall {:try_start_8a .. :try_end_97} :catchall_98

    .line 488
    return-void

    .line 489
    :catchall_98
    move-exception v1

    .line 483
    add-int/lit8 v0, v0, 0x1

    goto :goto_87

    .line 492
    :cond_9c
    return-void

    .line 444
    :catchall_9d
    move-exception p0

    .line 445
    return-void
.end method

.method private static writeText(Ljava/io/File;Ljava/lang/String;)V
    .registers 4

    .line 331
    :try_start_0
    new-instance v0, Ljava/io/FileOutputStream;

    const/4 v1, 0x0

    invoke-direct {v0, p0, v1}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;Z)V

    .line 332
    const-string p0, "UTF-8"

    invoke-virtual {p1, p0}, Ljava/lang/String;->getBytes(Ljava/lang/String;)[B

    move-result-object p0

    invoke-virtual {v0, p0}, Ljava/io/FileOutputStream;->write([B)V

    .line 333
    invoke-virtual {v0}, Ljava/io/FileOutputStream;->close()V
    :try_end_12
    .catchall {:try_start_0 .. :try_end_12} :catchall_13

    .line 335
    goto :goto_14

    .line 334
    :catchall_13
    move-exception p0

    .line 336
    :goto_14
    return-void
.end method
