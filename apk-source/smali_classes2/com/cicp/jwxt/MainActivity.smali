.class public Lcom/cicp/jwxt/MainActivity;
.super Landroid/app/Activity;
.source "MainActivity.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/cicp/jwxt/MainActivity$WebAppInterface;
    }
.end annotation


# instance fields
.field private cookieStore:Ljava/lang/StringBuilder;

.field private webView:Landroid/webkit/WebView;

.field private notifReceiver:Lcom/cicp/jwxt/MainActivity$NotifReceiver;


# direct methods
.method static bridge synthetic -$$Nest$fgetcookieStore(Lcom/cicp/jwxt/MainActivity;)Ljava/lang/StringBuilder;
    .locals 0

    iget-object p0, p0, Lcom/cicp/jwxt/MainActivity;->cookieStore:Ljava/lang/StringBuilder;

    return-object p0
.end method

.method static bridge synthetic -$$Nest$fputcookieStore(Lcom/cicp/jwxt/MainActivity;Ljava/lang/StringBuilder;)V
    .locals 0

    iput-object p1, p0, Lcom/cicp/jwxt/MainActivity;->cookieStore:Ljava/lang/StringBuilder;

    return-void
.end method

.method public constructor <init>()V
    .locals 1

    .line 20
    invoke-direct {p0}, Landroid/app/Activity;-><init>()V

    .line 22
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    iput-object v0, p0, Lcom/cicp/jwxt/MainActivity;->cookieStore:Ljava/lang/StringBuilder;

    return-void
.end method


# virtual methods
.method public onBackPressed()V
    .locals 1

    .line 139
    iget-object v0, p0, Lcom/cicp/jwxt/MainActivity;->webView:Landroid/webkit/WebView;

    invoke-virtual {v0}, Landroid/webkit/WebView;->canGoBack()Z

    move-result v0

    if-eqz v0, :cond_0

    iget-object v0, p0, Lcom/cicp/jwxt/MainActivity;->webView:Landroid/webkit/WebView;

    invoke-virtual {v0}, Landroid/webkit/WebView;->goBack()V

    goto :goto_0

    .line 140
    :cond_0
    invoke-super {p0}, Landroid/app/Activity;->onBackPressed()V

    .line 141
    :goto_0
    return-void
.end method

.method protected onCreate(Landroid/os/Bundle;)V
    .locals 5
    .param p1, "savedInstanceState"    # Landroid/os/Bundle;

    .line 119
    invoke-super {p0, p1}, Landroid/app/Activity;->onCreate(Landroid/os/Bundle;)V

    .line 120
    sget v0, Lcom/cicp/jwxt/R$layout;->activity_main:I

    invoke-virtual {p0, v0}, Lcom/cicp/jwxt/MainActivity;->setContentView(I)V

    .line 122
    sget v0, Lcom/cicp/jwxt/R$id;->webview:I

    invoke-virtual {p0, v0}, Lcom/cicp/jwxt/MainActivity;->findViewById(I)Landroid/view/View;

    move-result-object v0

    check-cast v0, Landroid/webkit/WebView;

    iput-object v0, p0, Lcom/cicp/jwxt/MainActivity;->webView:Landroid/webkit/WebView;

    .line 123
    iget-object v0, p0, Lcom/cicp/jwxt/MainActivity;->webView:Landroid/webkit/WebView;

    invoke-virtual {v0}, Landroid/webkit/WebView;->getSettings()Landroid/webkit/WebSettings;

    move-result-object v0

    .line 124
    .local v0, "settings":Landroid/webkit/WebSettings;
    const/4 v1, 0x1

    invoke-virtual {v0, v1}, Landroid/webkit/WebSettings;->setJavaScriptEnabled(Z)V

    .line 125
    invoke-virtual {v0, v1}, Landroid/webkit/WebSettings;->setDomStorageEnabled(Z)V

    .line 126
    invoke-virtual {v0, v1}, Landroid/webkit/WebSettings;->setDatabaseEnabled(Z)V

    .line 127
    invoke-virtual {v0, v1}, Landroid/webkit/WebSettings;->setAllowFileAccess(Z)V

    .line 128
    invoke-virtual {v0, v1}, Landroid/webkit/WebSettings;->setAllowUniversalAccessFromFileURLs(Z)V

    .line 129
    invoke-virtual {v0, v1}, Landroid/webkit/WebSettings;->setAllowFileAccessFromFileURLs(Z)V

    .line 131
    iget-object v1, p0, Lcom/cicp/jwxt/MainActivity;->webView:Landroid/webkit/WebView;

    new-instance v2, Lcom/cicp/jwxt/MainActivity$WebAppInterface;

    invoke-direct {v2, p0}, Lcom/cicp/jwxt/MainActivity$WebAppInterface;-><init>(Lcom/cicp/jwxt/MainActivity;)V

    const-string v3, "Android"

    invoke-virtual {v1, v2, v3}, Landroid/webkit/WebView;->addJavascriptInterface(Ljava/lang/Object;Ljava/lang/String;)V

    .line 132
    iget-object v1, p0, Lcom/cicp/jwxt/MainActivity;->webView:Landroid/webkit/WebView;

    new-instance v2, Landroid/webkit/WebViewClient;

    invoke-direct {v2}, Landroid/webkit/WebViewClient;-><init>()V

    invoke-virtual {v1, v2}, Landroid/webkit/WebView;->setWebViewClient(Landroid/webkit/WebViewClient;)V

    .line 133
    iget-object v1, p0, Lcom/cicp/jwxt/MainActivity;->webView:Landroid/webkit/WebView;

    new-instance v2, Landroid/webkit/WebChromeClient;

    invoke-direct {v2}, Landroid/webkit/WebChromeClient;-><init>()V

    invoke-virtual {v1, v2}, Landroid/webkit/WebView;->setWebChromeClient(Landroid/webkit/WebChromeClient;)V

    .line 134
    iget-object v1, p0, Lcom/cicp/jwxt/MainActivity;->webView:Landroid/webkit/WebView;

    const-string v2, "file:///android_asset/index.html"

    invoke-virtual {v1, v2}, Landroid/webkit/WebView;->loadUrl(Ljava/lang/String;)V

    .line 135
    # 请求通知权限(Android 13+/API33+)
    sget v2, Landroid/os/Build$VERSION;->SDK_INT:I
    const/16 v3, 0x21
    if-lt v2, v3, :perm_done
    const/4 v2, 0x1
    new-array v2, v2, [Ljava/lang/String;
    const/4 v3, 0x0
    const-string v4, "android.permission.POST_NOTIFICATIONS"
    aput-object v4, v2, v3
    const/16 v3, 0x7d1
    invoke-virtual {p0, v2, v3}, Landroid/app/Activity;->requestPermissions([Ljava/lang/String;I)V
    :perm_done

    return-void
.end method

.method protected onResume()V
    .locals 6

    invoke-super {p0}, Landroid/app/Activity;->onResume()V

    invoke-virtual {p0}, Landroid/app/Activity;->getIntent()Landroid/content/Intent;

    move-result-object v0

    const-string v1, "goto"

    invoke-virtual {v0, v1}, Landroid/content/Intent;->getStringExtra(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    if-eqz v1, :cond_done

    const-string v2, "schedule"

    invoke-virtual {v1, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_done

    # 延迟到网页加载完成后跳转到我的课表结果（避免冷启动时 JS 未就绪导致跳转落空）
    new-instance v2, Landroid/os/Handler;

    invoke-direct {v2}, Landroid/os/Handler;-><init>()V

    new-instance v3, Lcom/cicp/jwxt/MainActivity$1;

    invoke-direct {v3, p0}, Lcom/cicp/jwxt/MainActivity$1;-><init>(Lcom/cicp/jwxt/MainActivity;)V

    const-wide/16 v4, 0x320

    invoke-virtual {v2, v3, v4, v5}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    invoke-virtual {p0}, Landroid/app/Activity;->getIntent()Landroid/content/Intent;

    move-result-object v1

    const-string v2, "goto"

    invoke-virtual {v1, v2}, Landroid/content/Intent;->removeExtra(Ljava/lang/String;)V

    :cond_done
    # 注册通知展开/收起广播接收器（先注销旧的，避免重复注册）
    iget-object v3, p0, Lcom/cicp/jwxt/MainActivity;->notifReceiver:Lcom/cicp/jwxt/MainActivity$NotifReceiver;
    if-eqz v3, :cond_reg
    invoke-virtual {p0, v3}, Landroid/app/Activity;->unregisterReceiver(Landroid/content/BroadcastReceiver;)V
    :cond_reg
    new-instance v3, Landroid/content/IntentFilter;
    const-string v4, "cicp.jwxt.NOTIF_TOGGLE"
    invoke-direct {v3, v4}, Landroid/content/IntentFilter;-><init>(Ljava/lang/String;)V
    new-instance v4, Lcom/cicp/jwxt/MainActivity$NotifReceiver;
    invoke-direct {v4, p0}, Lcom/cicp/jwxt/MainActivity$NotifReceiver;-><init>(Lcom/cicp/jwxt/MainActivity;)V
    iput-object v4, p0, Lcom/cicp/jwxt/MainActivity;->notifReceiver:Lcom/cicp/jwxt/MainActivity$NotifReceiver;
    invoke-virtual {p0, v4, v3}, Landroid/app/Activity;->registerReceiver(Landroid/content/BroadcastReceiver;Landroid/content/IntentFilter;)Landroid/content/Intent;
    return-void
.end method

.method protected onPause()V
    .locals 1

    invoke-super {p0}, Landroid/app/Activity;->onPause()V

    iget-object v0, p0, Lcom/cicp/jwxt/MainActivity;->notifReceiver:Lcom/cicp/jwxt/MainActivity$NotifReceiver;

    if-eqz v0, :cond_done

    invoke-virtual {p0, v0}, Landroid/app/Activity;->unregisterReceiver(Landroid/content/BroadcastReceiver;)V

    const/4 v0, 0x0

    iput-object v0, p0, Lcom/cicp/jwxt/MainActivity;->notifReceiver:Lcom/cicp/jwxt/MainActivity$NotifReceiver;

    :cond_done
    return-void
.end method

.method public gotoSchedule()V
    .locals 3

    iget-object v1, p0, Lcom/cicp/jwxt/MainActivity;->webView:Landroid/webkit/WebView;

    const-string v2, "window.__gotoSchedule&&window.__gotoSchedule()"

    const/4 v0, 0x0

    invoke-virtual {v1, v2, v0}, Landroid/webkit/WebView;->evaluateJavascript(Ljava/lang/String;Landroid/webkit/ValueCallback;)V

    return-void
.end method
.method public onRequestPermissionsResult(I[Ljava/lang/String;[I)V
    .locals 4

    invoke-super {p0, p1, p2, p3}, Landroid/app/Activity;->onRequestPermissionsResult(I[Ljava/lang/String;[I)V

    const/16 v0, 0x7d1
    if-ne p1, v0, :cond_done

    array-length v1, p3
    if-lez v1, :cond_done

    const/4 v1, 0x0
    aget v1, p3, v1
    if-eqz v1, :cond_done

    iget-object v1, p0, Lcom/cicp/jwxt/MainActivity;->webView:Landroid/webkit/WebView;

    const-string v2, "window.__retryNotif&&window.__retryNotif()"

    const/4 v3, 0x0

    invoke-virtual {v1, v2, v3}, Landroid/webkit/WebView;->evaluateJavascript(Ljava/lang/String;Landroid/webkit/ValueCallback;)V

    :cond_done
    return-void
.end method
