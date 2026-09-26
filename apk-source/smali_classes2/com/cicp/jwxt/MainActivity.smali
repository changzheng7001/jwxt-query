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
    .locals 4
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
    return-void
.end method
