.class Lcom/cicp/jwxt/MainActivity$WebAppInterface;
.super Ljava/lang/Object;
.source "MainActivity.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/cicp/jwxt/MainActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = "WebAppInterface"
.end annotation


# instance fields
.field final synthetic this$0:Lcom/cicp/jwxt/MainActivity;


# direct methods
.method constructor <init>(Lcom/cicp/jwxt/MainActivity;)V
    .locals 0
    .param p1, "this$0"    # Lcom/cicp/jwxt/MainActivity;

    .line 24
    iput-object p1, p0, Lcom/cicp/jwxt/MainActivity$WebAppInterface;->this$0:Lcom/cicp/jwxt/MainActivity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method private addCookie(Ljava/lang/String;Ljava/lang/String;)V
    .locals 9
    .param p1, "name"    # Ljava/lang/String;
    .param p2, "value"    # Ljava/lang/String;

    .line 101
    iget-object v0, p0, Lcom/cicp/jwxt/MainActivity$WebAppInterface;->this$0:Lcom/cicp/jwxt/MainActivity;

    invoke-static {v0}, Lcom/cicp/jwxt/MainActivity;->-$$Nest$fgetcookieStore(Lcom/cicp/jwxt/MainActivity;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    const-string v1, "; "

    invoke-virtual {v0, v1}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v0

    .line 102
    .local v0, "parts":[Ljava/lang/String;
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    .line 103
    .local v2, "sb":Ljava/lang/StringBuilder;
    array-length v3, v0

    const/4 v4, 0x0

    move v5, v4

    :goto_0
    if-ge v5, v3, :cond_3

    aget-object v6, v0, v5

    .line 104
    .local v6, "p":Ljava/lang/String;
    invoke-virtual {v6}, Ljava/lang/String;->isEmpty()Z

    move-result v7

    if-eqz v7, :cond_0

    goto :goto_1

    .line 105
    :cond_0
    const/16 v7, 0x3d

    invoke-virtual {v6, v7}, Ljava/lang/String;->indexOf(I)I

    move-result v7

    .line 106
    .local v7, "eq":I
    if-lez v7, :cond_2

    invoke-virtual {v6, v4, v7}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v8

    invoke-virtual {v8, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v8

    if-nez v8, :cond_2

    .line 107
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->length()I

    move-result v8

    if-lez v8, :cond_1

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 108
    :cond_1
    invoke-virtual {v2, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 103
    .end local v6    # "p":Ljava/lang/String;
    .end local v7    # "eq":I
    :cond_2
    :goto_1
    add-int/lit8 v5, v5, 0x1

    goto :goto_0

    .line 111
    :cond_3
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->length()I

    move-result v3

    if-lez v3, :cond_4

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 112
    :cond_4
    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v3, "="

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 113
    iget-object v1, p0, Lcom/cicp/jwxt/MainActivity$WebAppInterface;->this$0:Lcom/cicp/jwxt/MainActivity;

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-direct {v3, v4}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-static {v1, v3}, Lcom/cicp/jwxt/MainActivity;->-$$Nest$fputcookieStore(Lcom/cicp/jwxt/MainActivity;Ljava/lang/StringBuilder;)V

    .line 114
    return-void
.end method

.method private followRequest(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)Ljava/lang/String;
    .locals 18
    .param p1, "method"    # Ljava/lang/String;
    .param p2, "urlStr"    # Ljava/lang/String;
    .param p3, "body"    # Ljava/lang/String;
    .param p4, "redirectCount"    # I
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 35
    move-object/from16 v0, p0

    move-object/from16 v1, p1

    move-object/from16 v2, p3

    move/from16 v3, p4

    const/4 v4, 0x5

    if-le v3, v4, :cond_0

    const-string v4, "ERROR: too many redirects"

    return-object v4

    .line 37
    :cond_0
    new-instance v4, Ljava/net/URL;

    move-object/from16 v5, p2

    invoke-direct {v4, v5}, Ljava/net/URL;-><init>(Ljava/lang/String;)V

    .line 38
    .local v4, "url":Ljava/net/URL;
    invoke-virtual {v4}, Ljava/net/URL;->openConnection()Ljava/net/URLConnection;

    move-result-object v6

    check-cast v6, Ljava/net/HttpURLConnection;

    .line 39
    .local v6, "conn":Ljava/net/HttpURLConnection;
    invoke-virtual {v6, v1}, Ljava/net/HttpURLConnection;->setRequestMethod(Ljava/lang/String;)V

    .line 40
    const-string v7, "User-Agent"

    const-string v8, "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"

    invoke-virtual {v6, v7, v8}, Ljava/net/HttpURLConnection;->setRequestProperty(Ljava/lang/String;Ljava/lang/String;)V

    .line 41
    const-string v7, "Referer"

    const-string v8, "https://jwxt.cicp.edu.cn/"

    invoke-virtual {v6, v7, v8}, Ljava/net/HttpURLConnection;->setRequestProperty(Ljava/lang/String;Ljava/lang/String;)V

    .line 42
    const-string v7, "Accept"

    const-string v8, "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"

    invoke-virtual {v6, v7, v8}, Ljava/net/HttpURLConnection;->setRequestProperty(Ljava/lang/String;Ljava/lang/String;)V

    .line 43
    const-string v7, "Accept-Language"

    const-string v8, "zh-CN,zh;q=0.9"

    invoke-virtual {v6, v7, v8}, Ljava/net/HttpURLConnection;->setRequestProperty(Ljava/lang/String;Ljava/lang/String;)V

    .line 44
    const-string v7, "Accept-Encoding"

    const-string v8, "identity"

    invoke-virtual {v6, v7, v8}, Ljava/net/HttpURLConnection;->setRequestProperty(Ljava/lang/String;Ljava/lang/String;)V

    .line 45
    const/4 v7, 0x0

    invoke-virtual {v6, v7}, Ljava/net/HttpURLConnection;->setInstanceFollowRedirects(Z)V

    .line 46
    const/16 v8, 0x3a98

    invoke-virtual {v6, v8}, Ljava/net/HttpURLConnection;->setConnectTimeout(I)V

    .line 47
    invoke-virtual {v6, v8}, Ljava/net/HttpURLConnection;->setReadTimeout(I)V

    .line 49
    iget-object v8, v0, Lcom/cicp/jwxt/MainActivity$WebAppInterface;->this$0:Lcom/cicp/jwxt/MainActivity;

    invoke-static {v8}, Lcom/cicp/jwxt/MainActivity;->-$$Nest$fgetcookieStore(Lcom/cicp/jwxt/MainActivity;)Ljava/lang/StringBuilder;

    move-result-object v8

    invoke-virtual {v8}, Ljava/lang/StringBuilder;->length()I

    move-result v8

    if-lez v8, :cond_1

    .line 50
    iget-object v8, v0, Lcom/cicp/jwxt/MainActivity$WebAppInterface;->this$0:Lcom/cicp/jwxt/MainActivity;

    invoke-static {v8}, Lcom/cicp/jwxt/MainActivity;->-$$Nest$fgetcookieStore(Lcom/cicp/jwxt/MainActivity;)Ljava/lang/StringBuilder;

    move-result-object v8

    invoke-virtual {v8}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v8

    const-string v9, "Cookie"

    invoke-virtual {v6, v9, v8}, Ljava/net/HttpURLConnection;->setRequestProperty(Ljava/lang/String;Ljava/lang/String;)V

    .line 53
    :cond_1
    const-string v8, "POST"

    invoke-virtual {v8, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v8

    const-string v9, "UTF-8"

    if-eqz v8, :cond_2

    .line 54
    const-string v8, "Content-Type"

    const-string v10, "application/x-www-form-urlencoded"

    invoke-virtual {v6, v8, v10}, Ljava/net/HttpURLConnection;->setRequestProperty(Ljava/lang/String;Ljava/lang/String;)V

    .line 55
    const/4 v8, 0x1

    invoke-virtual {v6, v8}, Ljava/net/HttpURLConnection;->setDoOutput(Z)V

    .line 56
    if-eqz v2, :cond_2

    invoke-virtual/range {p3 .. p3}, Ljava/lang/String;->isEmpty()Z

    move-result v8

    if-nez v8, :cond_2

    .line 57
    invoke-virtual {v6}, Ljava/net/HttpURLConnection;->getOutputStream()Ljava/io/OutputStream;

    move-result-object v8

    .line 58
    .local v8, "os":Ljava/io/OutputStream;
    invoke-virtual {v2, v9}, Ljava/lang/String;->getBytes(Ljava/lang/String;)[B

    move-result-object v10

    invoke-virtual {v8, v10}, Ljava/io/OutputStream;->write([B)V

    .line 59
    invoke-virtual {v8}, Ljava/io/OutputStream;->flush()V

    .line 60
    invoke-virtual {v8}, Ljava/io/OutputStream;->close()V

    .line 64
    .end local v8    # "os":Ljava/io/OutputStream;
    :cond_2
    invoke-virtual {v6}, Ljava/net/HttpURLConnection;->getResponseCode()I

    move-result v8

    .line 66
    .local v8, "code":I
    invoke-virtual {v6}, Ljava/net/HttpURLConnection;->getHeaderFields()Ljava/util/Map;

    move-result-object v10

    .line 67
    .local v10, "headers":Ljava/util/Map;, "Ljava/util/Map<Ljava/lang/String;Ljava/util/List<Ljava/lang/String;>;>;"
    if-eqz v10, :cond_6

    .line 68
    invoke-interface {v10}, Ljava/util/Map;->entrySet()Ljava/util/Set;

    move-result-object v11

    invoke-interface {v11}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v11

    :goto_0
    invoke-interface {v11}, Ljava/util/Iterator;->hasNext()Z

    move-result v12

    if-eqz v12, :cond_6

    invoke-interface {v11}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v12

    check-cast v12, Ljava/util/Map$Entry;

    .line 69
    .local v12, "entry":Ljava/util/Map$Entry;, "Ljava/util/Map$Entry<Ljava/lang/String;Ljava/util/List<Ljava/lang/String;>;>;"
    invoke-interface {v12}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v13

    check-cast v13, Ljava/lang/String;

    .line 70
    .local v13, "key":Ljava/lang/String;
    if-eqz v13, :cond_5

    const-string v14, "Set-Cookie"

    invoke-virtual {v13, v14}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result v14

    if-eqz v14, :cond_5

    .line 71
    invoke-interface {v12}, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;

    move-result-object v14

    check-cast v14, Ljava/util/List;

    invoke-interface {v14}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v14

    :goto_1
    invoke-interface {v14}, Ljava/util/Iterator;->hasNext()Z

    move-result v15

    if-eqz v15, :cond_5

    invoke-interface {v14}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v15

    check-cast v15, Ljava/lang/String;

    .line 72
    .local v15, "sc":Ljava/lang/String;
    const/16 v7, 0x3b

    invoke-virtual {v15, v7}, Ljava/lang/String;->indexOf(I)I

    move-result v7

    .line 73
    .local v7, "semi":I
    if-lez v7, :cond_3

    const/4 v1, 0x0

    invoke-virtual {v15, v1, v7}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v17

    goto :goto_2

    :cond_3
    move-object/from16 v17, v15

    :goto_2
    move-object/from16 v1, v17

    .line 74
    .local v1, "pair":Ljava/lang/String;
    const/16 v2, 0x3d

    invoke-virtual {v1, v2}, Ljava/lang/String;->indexOf(I)I

    move-result v2

    .line 75
    .local v2, "eq":I
    if-lez v2, :cond_4

    const/4 v5, 0x0

    invoke-virtual {v1, v5, v2}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v16

    invoke-virtual/range {v16 .. v16}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v5

    move/from16 v16, v7

    .end local v7    # "semi":I
    .local v16, "semi":I
    add-int/lit8 v7, v2, 0x1

    invoke-virtual {v1, v7}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v7}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v7

    invoke-direct {v0, v5, v7}, Lcom/cicp/jwxt/MainActivity$WebAppInterface;->addCookie(Ljava/lang/String;Ljava/lang/String;)V

    goto :goto_3

    .end local v16    # "semi":I
    .restart local v7    # "semi":I
    :cond_4
    move/from16 v16, v7

    .line 76
    .end local v1    # "pair":Ljava/lang/String;
    .end local v2    # "eq":I
    .end local v7    # "semi":I
    .end local v15    # "sc":Ljava/lang/String;
    :goto_3
    move-object/from16 v1, p1

    move-object/from16 v5, p2

    move-object/from16 v2, p3

    const/4 v7, 0x0

    goto :goto_1

    .line 78
    .end local v12    # "entry":Ljava/util/Map$Entry;, "Ljava/util/Map$Entry<Ljava/lang/String;Ljava/util/List<Ljava/lang/String;>;>;"
    .end local v13    # "key":Ljava/lang/String;
    :cond_5
    move-object/from16 v1, p1

    move-object/from16 v5, p2

    move-object/from16 v2, p3

    const/4 v7, 0x0

    goto :goto_0

    .line 81
    :cond_6
    const/16 v1, 0x12e

    if-eq v8, v1, :cond_7

    const/16 v1, 0x12d

    if-ne v8, v1, :cond_9

    .line 82
    :cond_7
    const-string v1, "Location"

    invoke-virtual {v6, v1}, Ljava/net/HttpURLConnection;->getHeaderField(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    .line 83
    .local v1, "location":Ljava/lang/String;
    invoke-virtual {v6}, Ljava/net/HttpURLConnection;->disconnect()V

    .line 84
    if-eqz v1, :cond_9

    .line 85
    const-string v2, "/"

    invoke-virtual {v1, v2}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v2

    if-eqz v2, :cond_8

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v4}, Ljava/net/URL;->getProtocol()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v2, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v5, "://"

    invoke-virtual {v2, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v4}, Ljava/net/URL;->getHost()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v2, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    .line 86
    :cond_8
    add-int/lit8 v2, v3, 0x1

    const-string v5, "GET"

    const/4 v7, 0x0

    invoke-direct {v0, v5, v1, v7, v2}, Lcom/cicp/jwxt/MainActivity$WebAppInterface;->followRequest(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)Ljava/lang/String;

    move-result-object v2

    return-object v2

    .line 90
    .end local v1    # "location":Ljava/lang/String;
    :cond_9
    new-instance v1, Ljava/io/BufferedReader;

    new-instance v2, Ljava/io/InputStreamReader;

    .line 91
    const/16 v5, 0x190

    if-lt v8, v5, :cond_a

    invoke-virtual {v6}, Ljava/net/HttpURLConnection;->getErrorStream()Ljava/io/InputStream;

    move-result-object v5

    goto :goto_4

    :cond_a
    invoke-virtual {v6}, Ljava/net/HttpURLConnection;->getInputStream()Ljava/io/InputStream;

    move-result-object v5

    :goto_4
    invoke-direct {v2, v5, v9}, Ljava/io/InputStreamReader;-><init>(Ljava/io/InputStream;Ljava/lang/String;)V

    invoke-direct {v1, v2}, Ljava/io/BufferedReader;-><init>(Ljava/io/Reader;)V

    .line 92
    .local v1, "reader":Ljava/io/BufferedReader;
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    .line 94
    .local v2, "sb":Ljava/lang/StringBuilder;
    :goto_5
    invoke-virtual {v1}, Ljava/io/BufferedReader;->readLine()Ljava/lang/String;

    move-result-object v5

    move-object v7, v5

    .local v7, "line":Ljava/lang/String;
    if-eqz v5, :cond_b

    invoke-virtual {v2, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    const-string v9, "\n"

    invoke-virtual {v5, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    goto :goto_5

    .line 95
    :cond_b
    invoke-virtual {v1}, Ljava/io/BufferedReader;->close()V

    .line 96
    invoke-virtual {v6}, Ljava/net/HttpURLConnection;->disconnect()V

    .line 97
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    return-object v5
.end method


# virtual methods
.method public httpRequest(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    .locals 3
    .param p1, "method"    # Ljava/lang/String;
    .param p2, "urlStr"    # Ljava/lang/String;
    .param p3, "body"    # Ljava/lang/String;
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation

    .line 28
    const/4 v0, 0x0

    :try_start_0
    invoke-direct {p0, p1, p2, p3, v0}, Lcom/cicp/jwxt/MainActivity$WebAppInterface;->followRequest(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)Ljava/lang/String;

    move-result-object v0
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    return-object v0

    .line 29
    :catch_0
    move-exception v0

    .line 30
    .local v0, "e":Ljava/lang/Exception;
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "ERROR:"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    return-object v1
.end method
.method public openBrowser(Ljava/lang/String;)V
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation

    .locals 4

    :try_start_0
    iget-object v0, p0, Lcom/cicp/jwxt/MainActivity$WebAppInterface;->this$0:Lcom/cicp/jwxt/MainActivity;

    new-instance v1, Landroid/content/Intent;

    const-string v2, "android.intent.action.VIEW"

    invoke-direct {v1, v2}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    invoke-static {p1}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v2

    invoke-virtual {v1, v2}, Landroid/content/Intent;->setData(Landroid/net/Uri;)Landroid/content/Intent;

    invoke-virtual {v0, v1}, Landroid/app/Activity;->startActivity(Landroid/content/Intent;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    :catch_0
    move-exception v3
    :goto_0
    return-void
.end method
.method public showNotification(Ljava/lang/String;Ljava/lang/String;Z)Z
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation

    .locals 11

    iget-object v0, p0, Lcom/cicp/jwxt/MainActivity$WebAppInterface;->this$0:Lcom/cicp/jwxt/MainActivity;

    # API33+ 无通知权限 -> 请求权限后返回（授权后由 JS 补发）
    :try_start_perm
    sget v8, Landroid/os/Build$VERSION;->SDK_INT:I
    const/16 v9, 0x21
    if-lt v8, v9, :cond_hasperm
    const-string v8, "android.permission.POST_NOTIFICATIONS"
    invoke-virtual {v0, v8}, Landroid/content/Context;->checkSelfPermission(Ljava/lang/String;)I
    move-result v8
    if-nez v8, :cond_hasperm
    const/4 v8, 0x1
    new-array v8, v8, [Ljava/lang/String;
    const/4 v9, 0x0
    const-string v10, "android.permission.POST_NOTIFICATIONS"
    aput-object v10, v8, v9
    const/16 v9, 0x7d1
    invoke-virtual {v0, v8, v9}, Landroid/app/Activity;->requestPermissions([Ljava/lang/String;I)V
    const/4 v0, 0x0
    return v0
    :cond_hasperm
    :try_end_perm
    .catch Ljava/lang/Exception; {:try_start_perm .. :try_end_perm} :catch_perm
    goto :goto_perm
    :catch_perm
    move-exception v8
    :goto_perm

    :try_start_0
    const-string v1, "notification"
    invoke-virtual {v0, v1}, Landroid/app/Activity;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v1
    check-cast v1, Landroid/app/NotificationManager;

    sget v2, Landroid/os/Build$VERSION;->SDK_INT:I
    const/16 v3, 0x1a
    if-lt v2, v3, :cond_nochan
    const-string v2, "jwxt_chan"
    const-string v3, "CICP\u6559\u52a1\u63d0\u9192"
    const/4 v4, 0x3
    new-instance v5, Landroid/app/NotificationChannel;
    invoke-direct {v5, v2, v3, v4}, Landroid/app/NotificationChannel;-><init>(Ljava/lang/String;Ljava/lang/CharSequence;I)V
    invoke-virtual {v1, v5}, Landroid/app/NotificationManager;->createNotificationChannel(Landroid/app/NotificationChannel;)V
    :cond_nochan

    const-class v2, Lcom/cicp/jwxt/MainActivity;
    new-instance v3, Landroid/content/Intent;
    invoke-direct {v3, v0, v2}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V
    const-string v2, "goto"
    const-string v4, "schedule"
    invoke-virtual {v3, v2, v4}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;
    const/4 v2, 0x0
    const/4 v4, 0x0
    invoke-static {v0, v2, v3, v4}, Landroid/app/PendingIntent;->getActivity(Landroid/content/Context;ILandroid/content/Intent;I)Landroid/app/PendingIntent;
    move-result-object v2

    sget v3, Landroid/os/Build$VERSION;->SDK_INT:I
    const/16 v4, 0x1a
    if-lt v3, v4, :cond_oldbuilder
    const-string v3, "jwxt_chan"
    new-instance v5, Landroid/app/Notification$Builder;
    invoke-direct {v5, v0, v3}, Landroid/app/Notification$Builder;-><init>(Landroid/content/Context;Ljava/lang/String;)V
    goto :goto_builder
    :cond_oldbuilder
    new-instance v5, Landroid/app/Notification$Builder;
    invoke-direct {v5, v0}, Landroid/app/Notification$Builder;-><init>(Landroid/content/Context;)V
    :goto_builder

    sget v3, Landroid/R$drawable;->ic_menu_agenda:I
    invoke-virtual {v5, v3}, Landroid/app/Notification$Builder;->setSmallIcon(I)Landroid/app/Notification$Builder;
    invoke-virtual {v5, p1}, Landroid/app/Notification$Builder;->setContentTitle(Ljava/lang/CharSequence;)Landroid/app/Notification$Builder;
    invoke-virtual {v5, p2}, Landroid/app/Notification$Builder;->setContentText(Ljava/lang/CharSequence;)Landroid/app/Notification$Builder;
    invoke-virtual {v5, v2}, Landroid/app/Notification$Builder;->setContentIntent(Landroid/app/PendingIntent;)Landroid/app/Notification$Builder;
    invoke-virtual {v5, p3}, Landroid/app/Notification$Builder;->setOngoing(Z)Landroid/app/Notification$Builder;
    new-instance v2, Landroid/app/Notification$BigTextStyle;
    invoke-direct {v2}, Landroid/app/Notification$BigTextStyle;-><init>()V
    invoke-virtual {v2, p2}, Landroid/app/Notification$BigTextStyle;->bigText(Ljava/lang/CharSequence;)Landroid/app/Notification$BigTextStyle;
    invoke-virtual {v5, v2}, Landroid/app/Notification$Builder;->setStyle(Landroid/app/Notification$Style;)Landroid/app/Notification$Builder;
    invoke-virtual {v5}, Landroid/app/Notification$Builder;->build()Landroid/app/Notification;
    move-result-object v3
    const/4 v4, 0x1
    invoke-virtual {v1, v4, v3}, Landroid/app/NotificationManager;->notify(ILandroid/app/Notification;)V
    const/4 v0, 0x1
    return v0
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0
    goto :goto_ret
    :catch_0
    move-exception v2
    const/4 v0, 0x0
    return v0
    :goto_ret
    return-void
.end method

# 状态栏配色跟随前端主题，使状态栏与 App 一致（不显示灰色）
# @JavascriptInterface 在 JS 线程执行，View 操作需切到 UI 线程（runOnUiThread）
.method public setStatusTheme(Z)V
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation

    .locals 2

    iget-object v0, p0, Lcom/cicp/jwxt/MainActivity$WebAppInterface;->this$0:Lcom/cicp/jwxt/MainActivity;

    new-instance v1, Lcom/cicp/jwxt/StatusRunnable;

    invoke-direct {v1, v0, p1}, Lcom/cicp/jwxt/StatusRunnable;-><init>(Landroid/app/Activity;Z)V

    invoke-virtual {v0, v1}, Landroid/app/Activity;->runOnUiThread(Ljava/lang/Runnable;)V

    return-void
.end method
