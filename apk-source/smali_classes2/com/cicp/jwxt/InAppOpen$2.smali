.class Lcom/cicp/jwxt/InAppOpen$2;
.super Ljava/lang/Object;
.source "InAppOpen.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/cicp/jwxt/InAppOpen;->open(Landroid/app/Activity;Ljava/lang/String;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic val$act:Landroid/app/Activity;

.field final synthetic val$cookie:Ljava/lang/String;

.field final synthetic val$diag:Ljava/lang/StringBuilder;

.field final synthetic val$logged:Z

.field final synthetic val$url:Ljava/lang/String;

.field final synthetic val$userCss:Ljava/lang/String;

.field final synthetic val$userJs:Ljava/lang/String;

.field final synthetic val$w:Landroid/webkit/WebView;


# direct methods
.method constructor <init>(Landroid/webkit/WebView;Landroid/app/Activity;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ZLjava/lang/String;Ljava/lang/StringBuilder;)V
    .registers 9
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    .line 114
    iput-object p1, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$w:Landroid/webkit/WebView;

    iput-object p2, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$act:Landroid/app/Activity;

    iput-object p3, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$cookie:Ljava/lang/String;

    iput-object p4, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$userCss:Ljava/lang/String;

    iput-object p5, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$userJs:Ljava/lang/String;

    iput-boolean p6, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$logged:Z

    iput-object p7, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$url:Ljava/lang/String;

    iput-object p8, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$diag:Ljava/lang/StringBuilder;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .registers 9

    .line 118
    const-string v0, "android"

    const-string v1, "dimen"

    const-string v2, "status_bar_height"

    const/4 v3, 0x0

    const/4 v4, 0x1

    :try_start_8
    iget-object v5, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$w:Landroid/webkit/WebView;

    invoke-virtual {v5}, Landroid/webkit/WebView;->getSettings()Landroid/webkit/WebSettings;

    move-result-object v5

    .line 119
    invoke-virtual {v5, v4}, Landroid/webkit/WebSettings;->setJavaScriptEnabled(Z)V

    .line 120
    invoke-virtual {v5, v4}, Landroid/webkit/WebSettings;->setDomStorageEnabled(Z)V

    .line 121
    invoke-virtual {v5, v4}, Landroid/webkit/WebSettings;->setSupportZoom(Z)V

    .line 122
    invoke-virtual {v5, v4}, Landroid/webkit/WebSettings;->setBuiltInZoomControls(Z)V

    .line 123
    invoke-virtual {v5, v3}, Landroid/webkit/WebSettings;->setDisplayZoomControls(Z)V
    :try_end_1d
    .catchall {:try_start_8 .. :try_end_1d} :catchall_53

    .line 125
    nop

    .line 127
    :try_start_1e
    iget-object v6, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$act:Landroid/app/Activity;

    invoke-virtual {v6}, Landroid/app/Activity;->getResources()Landroid/content/res/Resources;

    move-result-object v6

    invoke-virtual {v6}, Landroid/content/res/Resources;->getConfiguration()Landroid/content/res/Configuration;

    move-result-object v6

    iget v6, v6, Landroid/content/res/Configuration;->fontScale:F

    const/high16 v7, 0x42c80000    # 100.0f

    mul-float/2addr v6, v7

    invoke-static {v6}, Ljava/lang/Math;->round(F)I

    move-result v6
    :try_end_31
    .catchall {:try_start_1e .. :try_end_31} :catchall_3c

    .line 128
    const/16 v7, 0x50

    if-ge v6, v7, :cond_36

    move v6, v7

    .line 129
    :cond_36
    const/16 v7, 0xc8

    if-le v6, v7, :cond_3b

    move v6, v7

    .line 131
    :cond_3b
    goto :goto_3f

    .line 130
    :catchall_3c
    move-exception v6

    const/16 v6, 0x64

    .line 132
    :goto_3f
    :try_start_3f
    invoke-virtual {v5, v6}, Landroid/webkit/WebSettings;->setTextZoom(I)V

    .line 133
    const-string v6, "Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36"

    invoke-virtual {v5, v6}, Landroid/webkit/WebSettings;->setUserAgentString(Ljava/lang/String;)V

    .line 134
    invoke-virtual {v5, v4}, Landroid/webkit/WebSettings;->setUseWideViewPort(Z)V

    .line 135
    invoke-virtual {v5, v4}, Landroid/webkit/WebSettings;->setLoadWithOverviewMode(Z)V

    .line 136
    const-string v6, "UTF-8"

    invoke-virtual {v5, v6}, Landroid/webkit/WebSettings;->setDefaultTextEncodingName(Ljava/lang/String;)V
    :try_end_52
    .catchall {:try_start_3f .. :try_end_52} :catchall_53

    .line 138
    goto :goto_54

    .line 137
    :catchall_53
    move-exception v5

    .line 140
    :goto_54
    :try_start_54
    iget-object v5, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$act:Landroid/app/Activity;

    invoke-virtual {v5}, Landroid/app/Activity;->getResources()Landroid/content/res/Resources;

    move-result-object v5

    invoke-virtual {v5}, Landroid/content/res/Resources;->getDisplayMetrics()Landroid/util/DisplayMetrics;

    move-result-object v5

    iget v5, v5, Landroid/util/DisplayMetrics;->density:F
    :try_end_60
    .catchall {:try_start_54 .. :try_end_60} :catchall_92

    .line 141
    nop

    .line 143
    :try_start_61
    iget-object v5, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$act:Landroid/app/Activity;

    invoke-virtual {v5}, Landroid/app/Activity;->getResources()Landroid/content/res/Resources;

    move-result-object v5

    invoke-virtual {v5, v2, v1, v0}, Landroid/content/res/Resources;->getIdentifier(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I

    move-result v5

    .line 144
    if-lez v5, :cond_76

    iget-object v6, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$act:Landroid/app/Activity;

    invoke-virtual {v6}, Landroid/app/Activity;->getResources()Landroid/content/res/Resources;

    move-result-object v6

    invoke-virtual {v6, v5}, Landroid/content/res/Resources;->getDimensionPixelSize(I)I
    :try_end_76
    .catchall {:try_start_61 .. :try_end_76} :catchall_77

    .line 146
    :cond_76
    goto :goto_78

    .line 145
    :catchall_77
    move-exception v5

    .line 147
    :goto_78
    nop

    .line 148
    nop

    .line 149
    :try_start_7a
    new-instance v5, Lcom/cicp/jwxt/CookieWebClient;

    const-string v6, "jwxt.cicp.edu.cn"

    iget-object v7, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$cookie:Ljava/lang/String;

    invoke-direct {v5, v6, v7, v3, v3}, Lcom/cicp/jwxt/CookieWebClient;-><init>(Ljava/lang/String;Ljava/lang/String;II)V
    :try_end_83
    .catchall {:try_start_7a .. :try_end_83} :catchall_92

    .line 150
    :try_start_83
    iget-object v6, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$userCss:Ljava/lang/String;

    iget-object v7, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$userJs:Ljava/lang/String;

    invoke-virtual {v5, v6, v7}, Lcom/cicp/jwxt/CookieWebClient;->setUserScript(Ljava/lang/String;Ljava/lang/String;)V
    :try_end_8a
    .catchall {:try_start_83 .. :try_end_8a} :catchall_8b

    .line 151
    goto :goto_8c

    .line 150
    :catchall_8b
    move-exception v6

    .line 152
    :goto_8c
    :try_start_8c
    iget-object v6, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$w:Landroid/webkit/WebView;

    invoke-virtual {v6, v5}, Landroid/webkit/WebView;->setWebViewClient(Landroid/webkit/WebViewClient;)V
    :try_end_91
    .catchall {:try_start_8c .. :try_end_91} :catchall_92

    .line 154
    goto :goto_93

    .line 153
    :catchall_92
    move-exception v5

    .line 156
    :goto_93
    :try_start_93
    iget-object v5, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$act:Landroid/app/Activity;

    invoke-virtual {v5}, Landroid/app/Activity;->getResources()Landroid/content/res/Resources;

    move-result-object v5

    invoke-virtual {v5}, Landroid/content/res/Resources;->getDisplayMetrics()Landroid/util/DisplayMetrics;

    move-result-object v5

    iget v5, v5, Landroid/util/DisplayMetrics;->density:F
    :try_end_9f
    .catchall {:try_start_93 .. :try_end_9f} :catchall_c8

    .line 157
    nop

    .line 159
    :try_start_a0
    iget-object v5, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$act:Landroid/app/Activity;

    invoke-virtual {v5}, Landroid/app/Activity;->getResources()Landroid/content/res/Resources;

    move-result-object v5

    invoke-virtual {v5, v2, v1, v0}, Landroid/content/res/Resources;->getIdentifier(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I

    move-result v0

    .line 160
    if-lez v0, :cond_b5

    iget-object v1, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$act:Landroid/app/Activity;

    invoke-virtual {v1}, Landroid/app/Activity;->getResources()Landroid/content/res/Resources;

    move-result-object v1

    invoke-virtual {v1, v0}, Landroid/content/res/Resources;->getDimensionPixelSize(I)I
    :try_end_b5
    .catchall {:try_start_a0 .. :try_end_b5} :catchall_b6

    .line 162
    :cond_b5
    goto :goto_b7

    .line 161
    :catchall_b6
    move-exception v0

    .line 163
    :goto_b7
    :try_start_b7
    iget-object v0, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$w:Landroid/webkit/WebView;

    invoke-virtual {v0, v3, v3, v3, v3}, Landroid/webkit/WebView;->setPadding(IIII)V

    .line 164
    iget-object v0, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$w:Landroid/webkit/WebView;

    const/4 v1, -0x1

    invoke-virtual {v0, v1}, Landroid/webkit/WebView;->setBackgroundColor(I)V

    .line 165
    iget-object v0, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$w:Landroid/webkit/WebView;

    invoke-virtual {v0, v4}, Landroid/webkit/WebView;->setClipToPadding(Z)V
    :try_end_c7
    .catchall {:try_start_b7 .. :try_end_c7} :catchall_c8

    .line 167
    goto :goto_c9

    .line 166
    :catchall_c8
    move-exception v0

    .line 169
    :goto_c9
    :try_start_c9
    iget-boolean v0, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$logged:Z

    if-eqz v0, :cond_d5

    .line 171
    iget-object v0, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$w:Landroid/webkit/WebView;

    iget-object v1, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$url:Ljava/lang/String;

    invoke-virtual {v0, v1}, Landroid/webkit/WebView;->loadUrl(Ljava/lang/String;)V

    goto :goto_f3

    .line 173
    :cond_d5
    iget-object v1, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$w:Landroid/webkit/WebView;

    const-string v2, "https://jwxt.cicp.edu.cn/"

    iget-object v0, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$url:Ljava/lang/String;

    iget-object v5, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$diag:Ljava/lang/StringBuilder;

    iget-object v6, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$cookie:Ljava/lang/String;

    invoke-virtual {v6}, Ljava/lang/String;->length()I

    move-result v6

    if-lez v6, :cond_e6

    move v3, v4

    :cond_e6
    # invokes: Lcom/cicp/jwxt/InAppOpen;->diagHtml(Ljava/lang/String;Ljava/lang/StringBuilder;Z)Ljava/lang/String;
    invoke-static {v0, v5, v3}, Lcom/cicp/jwxt/InAppOpen;->access$000(Ljava/lang/String;Ljava/lang/StringBuilder;Z)Ljava/lang/String;

    move-result-object v3

    const-string v4, "text/html"

    const-string v5, "UTF-8"

    iget-object v6, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$url:Ljava/lang/String;

    invoke-virtual/range {v1 .. v6}, Landroid/webkit/WebView;->loadDataWithBaseURL(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    :try_end_f3
    .catchall {:try_start_c9 .. :try_end_f3} :catchall_f4

    .line 176
    :goto_f3
    goto :goto_f5

    .line 175
    :catchall_f4
    move-exception v0

    .line 177
    :goto_f5
    return-void
.end method
