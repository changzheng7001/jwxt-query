.class public Lcom/cicp/jwxt/WebActivity;
.super Landroid/app/Activity;
.source "WebActivity.java"

.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/cicp/jwxt/WebActivity$Bridge;,
        Lcom/cicp/jwxt/WebActivity$1;
    }
.end annotation


# instance fields
.field private webView:Landroid/webkit/WebView;


# direct methods
.method public constructor <init>()V
    .registers 1

    .line 20
    invoke-direct {p0}, Landroid/app/Activity;-><init>()V

    return-void
.end method


# virtual methods
.method public onBackPressed()V
    .registers 2

    .line 77
    :try_start_0
    iget-object v0, p0, Lcom/cicp/jwxt/WebActivity;->webView:Landroid/webkit/WebView;

    if-eqz v0, :cond_12

    iget-object v0, p0, Lcom/cicp/jwxt/WebActivity;->webView:Landroid/webkit/WebView;

    invoke-virtual {v0}, Landroid/webkit/WebView;->canGoBack()Z

    move-result v0

    if-eqz v0, :cond_12

    .line 78
    iget-object v0, p0, Lcom/cicp/jwxt/WebActivity;->webView:Landroid/webkit/WebView;

    invoke-virtual {v0}, Landroid/webkit/WebView;->goBack()V
    :try_end_11
    .catchall {:try_start_0 .. :try_end_11} :catchall_13

    .line 79
    return-void

    .line 82
    :cond_12
    goto :goto_14

    .line 81
    :catchall_13
    move-exception v0

    .line 83
    :goto_14
    invoke-super {p0}, Landroid/app/Activity;->onBackPressed()V

    .line 84
    return-void
.end method

.method protected onCreate(Landroid/os/Bundle;)V
    .registers 8

    .line 26
    invoke-super {p0, p1}, Landroid/app/Activity;->onCreate(Landroid/os/Bundle;)V

    .line 27
    nop

    .line 29
    const/4 p1, 0x0

    :try_start_5
    invoke-virtual {p0}, Lcom/cicp/jwxt/WebActivity;->getIntent()Landroid/content/Intent;

    move-result-object v0

    .line 30
    if-eqz v0, :cond_11

    const-string v1, "url"

    invoke-virtual {v0, v1}, Landroid/content/Intent;->getStringExtra(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p1
    :try_end_11
    .catchall {:try_start_5 .. :try_end_11} :catchall_12

    .line 32
    :cond_11
    goto :goto_13

    .line 31
    :catchall_12
    move-exception v0

    .line 33
    :goto_13
    if-eqz p1, :cond_1b

    invoke-virtual {p1}, Ljava/lang/String;->length()I

    move-result v0

    if-nez v0, :cond_1d

    .line 34
    :cond_1b
    const-string p1, "https://jwxt.cicp.edu.cn/jsxsd/framework/xsMainV.htmlx"

    .line 37
    :cond_1d
    invoke-virtual {p0}, Lcom/cicp/jwxt/WebActivity;->getResources()Landroid/content/res/Resources;

    move-result-object v0

    invoke-virtual {v0}, Landroid/content/res/Resources;->getDisplayMetrics()Landroid/util/DisplayMetrics;

    move-result-object v0

    iget v0, v0, Landroid/util/DisplayMetrics;->density:F

    .line 38
    const/high16 v1, 0x42200000    # 40.0f

    mul-float/2addr v1, v0

    float-to-int v1, v1

    .line 39
    const/high16 v2, 0x41d00000    # 26.0f

    mul-float/2addr v0, v2

    float-to-int v0, v0

    .line 41
    new-instance v2, Landroid/widget/FrameLayout;

    invoke-direct {v2, p0}, Landroid/widget/FrameLayout;-><init>(Landroid/content/Context;)V

    .line 42
    const/high16 v3, -0x1000000

    invoke-virtual {v2, v3}, Landroid/widget/FrameLayout;->setBackgroundColor(I)V

    .line 44
    new-instance v3, Landroid/webkit/WebView;

    invoke-direct {v3, p0}, Landroid/webkit/WebView;-><init>(Landroid/content/Context;)V

    iput-object v3, p0, Lcom/cicp/jwxt/WebActivity;->webView:Landroid/webkit/WebView;

    .line 45
    iget-object v3, p0, Lcom/cicp/jwxt/WebActivity;->webView:Landroid/webkit/WebView;

    invoke-virtual {v3}, Landroid/webkit/WebView;->getSettings()Landroid/webkit/WebSettings;

    move-result-object v3

    .line 47
    const/4 v4, 0x1

    invoke-virtual {v3, v4}, Landroid/webkit/WebSettings;->setJavaScriptEnabled(Z)V

    .line 48
    invoke-virtual {v3, v4}, Landroid/webkit/WebSettings;->setDomStorageEnabled(Z)V

    .line 49
    invoke-virtual {v3, v4}, Landroid/webkit/WebSettings;->setSupportZoom(Z)V

    .line 50
    invoke-virtual {v3, v4}, Landroid/webkit/WebSettings;->setBuiltInZoomControls(Z)V

    .line 51
    const/4 v5, 0x0

    invoke-virtual {v3, v5}, Landroid/webkit/WebSettings;->setDisplayZoomControls(Z)V

    .line 52
    invoke-static {}, Lcom/cicp/jwxt/CookieWebClient;->UA()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v3, v5}, Landroid/webkit/WebSettings;->setUserAgentString(Ljava/lang/String;)V

    .line 53
    invoke-virtual {v3, v4}, Landroid/webkit/WebSettings;->setUseWideViewPort(Z)V

    .line 54
    invoke-virtual {v3, v4}, Landroid/webkit/WebSettings;->setLoadWithOverviewMode(Z)V

    .line 56
    :try_start_64
    invoke-virtual {p0}, Lcom/cicp/jwxt/WebActivity;->getResources()Landroid/content/res/Resources;

    move-result-object v4

    invoke-virtual {v4}, Landroid/content/res/Resources;->getConfiguration()Landroid/content/res/Configuration;

    move-result-object v4

    iget v4, v4, Landroid/content/res/Configuration;->fontScale:F

    const/high16 v5, 0x42c80000    # 100.0f

    mul-float/2addr v4, v5

    invoke-static {v4}, Ljava/lang/Math;->round(F)I

    move-result v4

    .line 57
    const/16 v5, 0x50

    if-ge v4, v5, :cond_7a

    move v4, v5

    .line 58
    :cond_7a
    const/16 v5, 0xc8

    if-le v4, v5, :cond_7f

    move v4, v5

    .line 59
    :cond_7f
    invoke-virtual {v3, v4}, Landroid/webkit/WebSettings;->setTextZoom(I)V
    :try_end_82
    .catchall {:try_start_64 .. :try_end_82} :catchall_83

    .line 61
    goto :goto_84

    .line 60
    :catchall_83
    move-exception v3

    .line 62
    :goto_84
    iget-object v3, p0, Lcom/cicp/jwxt/WebActivity;->webView:Landroid/webkit/WebView;

    new-instance v4, Landroid/webkit/WebViewClient;

    invoke-direct {v4}, Landroid/webkit/WebViewClient;-><init>()V

    invoke-virtual {v3, v4}, Landroid/webkit/WebView;->setWebViewClient(Landroid/webkit/WebViewClient;)V

    .line 64
    new-instance v3, Landroid/widget/FrameLayout$LayoutParams;

    const/4 v4, -0x1

    invoke-direct {v3, v4, v4}, Landroid/widget/FrameLayout$LayoutParams;-><init>(II)V

    .line 66
    iput v1, v3, Landroid/widget/FrameLayout$LayoutParams;->topMargin:I

    .line 67
    iput v0, v3, Landroid/widget/FrameLayout$LayoutParams;->bottomMargin:I

    .line 68
    iget-object v0, p0, Lcom/cicp/jwxt/WebActivity;->webView:Landroid/webkit/WebView;

    invoke-virtual {v2, v0, v3}, Landroid/widget/FrameLayout;->addView(Landroid/view/View;Landroid/view/ViewGroup$LayoutParams;)V

    .line 70
    invoke-virtual {p0, v2}, Lcom/cicp/jwxt/WebActivity;->setContentView(Landroid/view/View;)V

    invoke-virtual {p0}, Lcom/cicp/jwxt/WebActivity;->getIntent()Landroid/content/Intent;

    move-result-object v0

    const-string v1, "inapp"

    const/4 v2, 0x0

    invoke-virtual {v0, v1, v2}, Landroid/content/Intent;->getBooleanExtra(Ljava/lang/String;Z)Z

    move-result v0

    if-eqz v0, :cond_plain

    const/4 v0, 0x0

    iput v0, v3, Landroid/widget/FrameLayout$LayoutParams;->topMargin:I

    iput v0, v3, Landroid/widget/FrameLayout$LayoutParams;->bottomMargin:I

    invoke-virtual {p0}, Lcom/cicp/jwxt/WebActivity;->getWindow()Landroid/view/Window;

    move-result-object v1

    invoke-virtual {v1}, Landroid/view/Window;->getDecorView()Landroid/view/View;

    move-result-object v1

    const/4 v2, -0x1

    invoke-virtual {v1, v2}, Landroid/view/View;->setBackgroundColor(I)V

    iget-object v0, p0, Lcom/cicp/jwxt/WebActivity;->webView:Landroid/webkit/WebView;

    invoke-virtual {v0}, Landroid/webkit/WebView;->requestLayout()V

    new-instance v1, Lcom/cicp/jwxt/WebActivity$Bridge;

    invoke-direct {v1, p0}, Lcom/cicp/jwxt/WebActivity$Bridge;-><init>(Lcom/cicp/jwxt/WebActivity;)V

    const-string v2, "Android"

    invoke-virtual {v0, v1, v2}, Landroid/webkit/WebView;->addJavascriptInterface(Ljava/lang/Object;Ljava/lang/String;)V

    :try_start_ck
    invoke-virtual {p0}, Lcom/cicp/jwxt/WebActivity;->getIntent()Landroid/content/Intent;

    move-result-object v1

    const-string v2, "cookie"

    invoke-virtual {v1, v2}, Landroid/content/Intent;->getStringExtra(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    if-eqz v2, :cond_ck_direct

    invoke-virtual {v2}, Ljava/lang/String;->length()I

    move-result v3

    if-lez v3, :cond_ck_direct

    move-object v5, v2

    goto :goto_ck_build

    :cond_ck_direct
    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    invoke-static {p0, v3}, Lcom/cicp/jwxt/InAppOpen;->readCookies(Landroid/content/Context;Ljava/lang/StringBuilder;)Ljava/lang/String;

    move-result-object v5

    :goto_ck_build
    new-instance v2, Lcom/cicp/jwxt/CookieWebClient;

    const-string v3, "jwxt.cicp.edu.cn"

    const/4 v4, 0x0

    invoke-direct {v2, v3, v5, v4, v4}, Lcom/cicp/jwxt/CookieWebClient;-><init>(Ljava/lang/String;Ljava/lang/String;II)V

    iget-object v3, p0, Lcom/cicp/jwxt/WebActivity;->webView:Landroid/webkit/WebView;

    invoke-virtual {v3, v2}, Landroid/webkit/WebView;->setWebViewClient(Landroid/webkit/WebViewClient;)V

    iget-object v3, p0, Lcom/cicp/jwxt/WebActivity;->webView:Landroid/webkit/WebView;

    invoke-virtual {v3, p1}, Landroid/webkit/WebView;->loadUrl(Ljava/lang/String;)V
    :try_end_ck
    .catchall {:try_start_ck .. :try_end_ck} :catchall_ck

    goto :goto_ck_done

    :catchall_ck
    move-exception v1

    iget-object v3, p0, Lcom/cicp/jwxt/WebActivity;->webView:Landroid/webkit/WebView;

    invoke-virtual {v3, p1}, Landroid/webkit/WebView;->loadUrl(Ljava/lang/String;)V

    :goto_ck_done
    :try_start_warm
    new-instance v1, Lcom/cicp/jwxt/WebActivity$1;

    invoke-direct {v1, p0, p1}, Lcom/cicp/jwxt/WebActivity$1;-><init>(Landroid/app/Activity;Ljava/lang/String;)V

    new-instance v2, Ljava/lang/Thread;

    invoke-direct {v2, v1}, Ljava/lang/Thread;-><init>(Ljava/lang/Runnable;)V

    invoke-virtual {v2}, Ljava/lang/Thread;->start()V
    :try_end_warm
    .catchall {:try_start_warm .. :try_end_warm} :catchall_warm

    goto :goto_warm

    :catchall_warm
    move-exception v1

    :goto_warm
    return-void

    :cond_plain
    iget-object v0, p0, Lcom/cicp/jwxt/WebActivity;->webView:Landroid/webkit/WebView;

    invoke-virtual {v0, p1}, Landroid/webkit/WebView;->loadUrl(Ljava/lang/String;)V

    return-void
.end method

.method protected onDestroy()V
    .registers 3

    .line 89
    :try_start_0
    iget-object v0, p0, Lcom/cicp/jwxt/WebActivity;->webView:Landroid/webkit/WebView;

    if-eqz v0, :cond_28

    .line 90
    iget-object v0, p0, Lcom/cicp/jwxt/WebActivity;->webView:Landroid/webkit/WebView;

    invoke-virtual {v0}, Landroid/webkit/WebView;->stopLoading()V

    .line 91
    iget-object v0, p0, Lcom/cicp/jwxt/WebActivity;->webView:Landroid/webkit/WebView;

    new-instance v1, Landroid/webkit/WebViewClient;

    invoke-direct {v1}, Landroid/webkit/WebViewClient;-><init>()V

    invoke-virtual {v0, v1}, Landroid/webkit/WebView;->setWebViewClient(Landroid/webkit/WebViewClient;)V

    .line 92
    iget-object v0, p0, Lcom/cicp/jwxt/WebActivity;->webView:Landroid/webkit/WebView;

    invoke-virtual {v0}, Landroid/webkit/WebView;->getParent()Landroid/view/ViewParent;

    move-result-object v0

    check-cast v0, Landroid/view/ViewGroup;

    iget-object v1, p0, Lcom/cicp/jwxt/WebActivity;->webView:Landroid/webkit/WebView;

    invoke-virtual {v0, v1}, Landroid/view/ViewGroup;->removeView(Landroid/view/View;)V

    .line 93
    iget-object v0, p0, Lcom/cicp/jwxt/WebActivity;->webView:Landroid/webkit/WebView;

    invoke-virtual {v0}, Landroid/webkit/WebView;->destroy()V

    .line 94
    const/4 v0, 0x0

    iput-object v0, p0, Lcom/cicp/jwxt/WebActivity;->webView:Landroid/webkit/WebView;
    :try_end_28
    .catchall {:try_start_0 .. :try_end_28} :catchall_29

    .line 97
    :cond_28
    goto :goto_2a

    .line 96
    :catchall_29
    move-exception v0

    .line 98
    :goto_2a
    invoke-super {p0}, Landroid/app/Activity;->onDestroy()V

    .line 99
    return-void
.end method
