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
.method constructor <init>(Landroid/webkit/WebView;Landroid/app/Activity;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ZLjava/lang/StringBuilder;)V
    .registers 9
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    .line 135
    iput-object p1, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$w:Landroid/webkit/WebView;

    iput-object p2, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$act:Landroid/app/Activity;

    iput-object p3, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$cookie:Ljava/lang/String;

    iput-object p4, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$userCss:Ljava/lang/String;

    iput-object p5, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$userJs:Ljava/lang/String;

    iput-object p6, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$url:Ljava/lang/String;

    iput-boolean p7, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$logged:Z

    iput-object p8, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$diag:Ljava/lang/StringBuilder;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .registers 9

    .line 139
    const-string v0, "android"

    const-string v1, "dimen"

    const-string v2, "status_bar_height"

    const/4 v3, 0x1

    const/4 v4, 0x0

    :try_start_8
    iget-object v5, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$w:Landroid/webkit/WebView;

    invoke-virtual {v5}, Landroid/webkit/WebView;->getSettings()Landroid/webkit/WebSettings;

    move-result-object v5

    .line 140
    invoke-virtual {v5, v3}, Landroid/webkit/WebSettings;->setJavaScriptEnabled(Z)V

    .line 141
    invoke-virtual {v5, v3}, Landroid/webkit/WebSettings;->setDomStorageEnabled(Z)V

    .line 142
    invoke-virtual {v5, v3}, Landroid/webkit/WebSettings;->setSupportZoom(Z)V

    .line 143
    invoke-virtual {v5, v3}, Landroid/webkit/WebSettings;->setBuiltInZoomControls(Z)V

    .line 144
    invoke-virtual {v5, v4}, Landroid/webkit/WebSettings;->setDisplayZoomControls(Z)V
    :try_end_1d
    .catchall {:try_start_8 .. :try_end_1d} :catchall_53

    .line 146
    nop

    .line 148
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

    .line 149
    const/16 v7, 0x50

    if-ge v6, v7, :cond_36

    move v6, v7

    .line 150
    :cond_36
    const/16 v7, 0xc8

    if-le v6, v7, :cond_3b

    move v6, v7

    .line 152
    :cond_3b
    goto :goto_3f

    .line 151
    :catchall_3c
    move-exception v6

    const/16 v6, 0x64

    .line 153
    :goto_3f
    :try_start_3f
    invoke-virtual {v5, v6}, Landroid/webkit/WebSettings;->setTextZoom(I)V

    .line 154
    const-string v6, "Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36"

    invoke-virtual {v5, v6}, Landroid/webkit/WebSettings;->setUserAgentString(Ljava/lang/String;)V

    .line 155
    invoke-virtual {v5, v3}, Landroid/webkit/WebSettings;->setUseWideViewPort(Z)V

    .line 156
    invoke-virtual {v5, v3}, Landroid/webkit/WebSettings;->setLoadWithOverviewMode(Z)V

    .line 157
    const-string v6, "UTF-8"

    invoke-virtual {v5, v6}, Landroid/webkit/WebSettings;->setDefaultTextEncodingName(Ljava/lang/String;)V
    :try_end_52
    .catchall {:try_start_3f .. :try_end_52} :catchall_53

    .line 159
    goto :goto_54

    .line 158
    :catchall_53
    move-exception v5

    .line 161
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

    .line 162
    nop

    .line 164
    :try_start_61
    iget-object v5, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$act:Landroid/app/Activity;

    invoke-virtual {v5}, Landroid/app/Activity;->getResources()Landroid/content/res/Resources;

    move-result-object v5

    invoke-virtual {v5, v2, v1, v0}, Landroid/content/res/Resources;->getIdentifier(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I

    move-result v5

    .line 165
    if-lez v5, :cond_76

    iget-object v6, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$act:Landroid/app/Activity;

    invoke-virtual {v6}, Landroid/app/Activity;->getResources()Landroid/content/res/Resources;

    move-result-object v6

    invoke-virtual {v6, v5}, Landroid/content/res/Resources;->getDimensionPixelSize(I)I
    :try_end_76
    .catchall {:try_start_61 .. :try_end_76} :catchall_77

    .line 167
    :cond_76
    goto :goto_78

    .line 166
    :catchall_77
    move-exception v5

    .line 170
    :goto_78
    nop

    .line 171
    nop

    .line 172
    :try_start_7a
    new-instance v5, Lcom/cicp/jwxt/CookieWebClient;

    const-string v6, "jwxt.cicp.edu.cn"

    iget-object v7, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$cookie:Ljava/lang/String;

    invoke-direct {v5, v6, v7, v4, v4}, Lcom/cicp/jwxt/CookieWebClient;-><init>(Ljava/lang/String;Ljava/lang/String;II)V
    :try_end_83
    .catchall {:try_start_7a .. :try_end_83} :catchall_92

    .line 173
    :try_start_83
    iget-object v6, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$userCss:Ljava/lang/String;

    iget-object v7, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$userJs:Ljava/lang/String;

    invoke-virtual {v5, v6, v7}, Lcom/cicp/jwxt/CookieWebClient;->setUserScript(Ljava/lang/String;Ljava/lang/String;)V
    :try_end_8a
    .catchall {:try_start_83 .. :try_end_8a} :catchall_8b

    .line 174
    goto :goto_8c

    .line 173
    :catchall_8b
    move-exception v6

    .line 175
    :goto_8c
    :try_start_8c
    iget-object v6, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$w:Landroid/webkit/WebView;

    invoke-virtual {v6, v5}, Landroid/webkit/WebView;->setWebViewClient(Landroid/webkit/WebViewClient;)V
    :try_end_91
    .catchall {:try_start_8c .. :try_end_91} :catchall_92

    .line 177
    goto :goto_93

    .line 176
    :catchall_92
    move-exception v5

    .line 179
    :goto_93
    :try_start_93
    iget-object v5, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$act:Landroid/app/Activity;

    invoke-virtual {v5}, Landroid/app/Activity;->getResources()Landroid/content/res/Resources;

    move-result-object v5

    invoke-virtual {v5}, Landroid/content/res/Resources;->getDisplayMetrics()Landroid/util/DisplayMetrics;

    move-result-object v5

    iget v5, v5, Landroid/util/DisplayMetrics;->density:F
    :try_end_9f
    .catchall {:try_start_93 .. :try_end_9f} :catchall_109

    .line 180
    nop

    .line 182
    :try_start_a0
    iget-object v5, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$act:Landroid/app/Activity;

    invoke-virtual {v5}, Landroid/app/Activity;->getResources()Landroid/content/res/Resources;

    move-result-object v5

    invoke-virtual {v5, v2, v1, v0}, Landroid/content/res/Resources;->getIdentifier(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I

    move-result v0

    .line 183
    if-lez v0, :cond_b5

    iget-object v1, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$act:Landroid/app/Activity;

    invoke-virtual {v1}, Landroid/app/Activity;->getResources()Landroid/content/res/Resources;

    move-result-object v1

    invoke-virtual {v1, v0}, Landroid/content/res/Resources;->getDimensionPixelSize(I)I
    :try_end_b5
    .catchall {:try_start_a0 .. :try_end_b5} :catchall_b6

    .line 185
    :cond_b5
    goto :goto_b7

    .line 184
    :catchall_b6
    move-exception v0

    .line 186
    :goto_b7
    :try_start_b7
    iget-object v0, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$url:Ljava/lang/String;

    if-eqz v0, :cond_e4

    iget-object v0, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$url:Ljava/lang/String;

    const-string v1, "native=1"

    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v0

    if-eqz v0, :cond_e4

    .line 190
    iget-object v0, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$w:Landroid/webkit/WebView;

    invoke-virtual {v0, v4, v4, v4, v4}, Landroid/webkit/WebView;->setPadding(IIII)V
    :try_end_ca
    .catchall {:try_start_b7 .. :try_end_ca} :catchall_109

    .line 193
    :try_start_ca
    iget-object v0, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$w:Landroid/webkit/WebView;

    invoke-virtual {v0}, Landroid/webkit/WebView;->getParent()Landroid/view/ViewParent;

    move-result-object v0

    check-cast v0, Landroid/view/ViewGroup;

    .line 194
    if-eqz v0, :cond_d7

    invoke-virtual {v0, v4, v4, v4, v4}, Landroid/view/ViewGroup;->setPadding(IIII)V
    :try_end_d7
    .catchall {:try_start_ca .. :try_end_d7} :catchall_d8

    .line 196
    :cond_d7
    goto :goto_d9

    .line 195
    :catchall_d8
    move-exception v0

    .line 197
    :goto_d9
    :try_start_d9
    iget-object v0, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$act:Landroid/app/Activity;

    # invokes: Lcom/cicp/jwxt/InAppOpen;->removeStatusStrip(Landroid/app/Activity;)V
    invoke-static {v0}, Lcom/cicp/jwxt/InAppOpen;->access$100(Landroid/app/Activity;)V

    .line 198
    iget-object v0, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$act:Landroid/app/Activity;

    # invokes: Lcom/cicp/jwxt/InAppOpen;->removeDebugHud(Landroid/app/Activity;)V
    invoke-static {v0}, Lcom/cicp/jwxt/InAppOpen;->access$200(Landroid/app/Activity;)V

    goto :goto_fd

    .line 201
    :cond_e4
    iget-object v0, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$w:Landroid/webkit/WebView;

    invoke-virtual {v0, v4, v4, v4, v4}, Landroid/webkit/WebView;->setPadding(IIII)V
    :try_end_e9
    .catchall {:try_start_d9 .. :try_end_e9} :catchall_109

    .line 203
    :try_start_e9
    iget-object v0, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$w:Landroid/webkit/WebView;

    invoke-virtual {v0}, Landroid/webkit/WebView;->getParent()Landroid/view/ViewParent;

    move-result-object v0

    check-cast v0, Landroid/view/ViewGroup;

    .line 204
    if-eqz v0, :cond_f6

    invoke-virtual {v0, v4, v4, v4, v4}, Landroid/view/ViewGroup;->setPadding(IIII)V
    :try_end_f6
    .catchall {:try_start_e9 .. :try_end_f6} :catchall_f7

    .line 206
    :cond_f6
    goto :goto_f8

    .line 205
    :catchall_f7
    move-exception v0

    .line 207
    :goto_f8
    :try_start_f8
    iget-object v0, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$act:Landroid/app/Activity;

    # invokes: Lcom/cicp/jwxt/InAppOpen;->removeStatusStrip(Landroid/app/Activity;)V
    invoke-static {v0}, Lcom/cicp/jwxt/InAppOpen;->access$100(Landroid/app/Activity;)V

    .line 209
    :goto_fd
    iget-object v0, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$w:Landroid/webkit/WebView;

    const/4 v1, -0x1

    invoke-virtual {v0, v1}, Landroid/webkit/WebView;->setBackgroundColor(I)V

    .line 210
    iget-object v0, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$w:Landroid/webkit/WebView;

    invoke-virtual {v0, v3}, Landroid/webkit/WebView;->setClipToPadding(Z)V
    :try_end_108
    .catchall {:try_start_f8 .. :try_end_108} :catchall_109

    .line 212
    goto :goto_10a

    .line 211
    :catchall_109
    move-exception v0

    .line 214
    :goto_10a
    :try_start_10a
    iget-boolean v0, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$logged:Z

    if-eqz v0, :cond_116

    .line 216
    iget-object v0, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$w:Landroid/webkit/WebView;

    iget-object v1, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$url:Ljava/lang/String;

    invoke-virtual {v0, v1}, Landroid/webkit/WebView;->loadUrl(Ljava/lang/String;)V

    goto :goto_135

    .line 218
    :cond_116
    iget-object v1, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$w:Landroid/webkit/WebView;

    const-string v2, "https://jwxt.cicp.edu.cn/"

    iget-object v0, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$url:Ljava/lang/String;

    iget-object v5, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$diag:Ljava/lang/StringBuilder;

    iget-object v6, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$cookie:Ljava/lang/String;

    invoke-virtual {v6}, Ljava/lang/String;->length()I

    move-result v6

    if-lez v6, :cond_127

    goto :goto_128

    :cond_127
    move v3, v4

    :goto_128
    # invokes: Lcom/cicp/jwxt/InAppOpen;->diagHtml(Ljava/lang/String;Ljava/lang/StringBuilder;Z)Ljava/lang/String;
    invoke-static {v0, v5, v3}, Lcom/cicp/jwxt/InAppOpen;->access$000(Ljava/lang/String;Ljava/lang/StringBuilder;Z)Ljava/lang/String;

    move-result-object v3

    const-string v4, "text/html"

    const-string v5, "UTF-8"

    iget-object v6, p0, Lcom/cicp/jwxt/InAppOpen$2;->val$url:Ljava/lang/String;

    invoke-virtual/range {v1 .. v6}, Landroid/webkit/WebView;->loadDataWithBaseURL(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    :try_end_135
    .catchall {:try_start_10a .. :try_end_135} :catchall_136

    .line 221
    :goto_135
    goto :goto_137

    .line 220
    :catchall_136
    move-exception v0

    .line 222
    :goto_137
    return-void
.end method
