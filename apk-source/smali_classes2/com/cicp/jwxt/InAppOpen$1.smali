.class Lcom/cicp/jwxt/InAppOpen$1;
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
.field final synthetic val$cookie:Ljava/lang/String;

.field final synthetic val$diag:Ljava/lang/StringBuilder;

.field final synthetic val$js:Ljava/lang/String;

.field final synthetic val$ok:[Z

.field final synthetic val$url:Ljava/lang/String;

.field final synthetic val$w:Landroid/webkit/WebView;


# direct methods
.method constructor <init>(Landroid/webkit/WebView;Ljava/lang/String;[ZLjava/lang/String;Ljava/lang/StringBuilder;Ljava/lang/String;)V
    .registers 7
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    .line 96
    iput-object p1, p0, Lcom/cicp/jwxt/InAppOpen$1;->val$w:Landroid/webkit/WebView;

    iput-object p2, p0, Lcom/cicp/jwxt/InAppOpen$1;->val$js:Ljava/lang/String;

    iput-object p3, p0, Lcom/cicp/jwxt/InAppOpen$1;->val$ok:[Z

    iput-object p4, p0, Lcom/cicp/jwxt/InAppOpen$1;->val$url:Ljava/lang/String;

    iput-object p5, p0, Lcom/cicp/jwxt/InAppOpen$1;->val$diag:Ljava/lang/StringBuilder;

    iput-object p6, p0, Lcom/cicp/jwxt/InAppOpen$1;->val$cookie:Ljava/lang/String;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .registers 10

    .line 100
    const/4 v0, 0x1

    const/4 v1, 0x0

    :try_start_2
    iget-object v2, p0, Lcom/cicp/jwxt/InAppOpen$1;->val$w:Landroid/webkit/WebView;

    iget-object v3, p0, Lcom/cicp/jwxt/InAppOpen$1;->val$js:Ljava/lang/String;

    const/4 v4, 0x0

    invoke-virtual {v2, v3, v4}, Landroid/webkit/WebView;->evaluateJavascript(Ljava/lang/String;Landroid/webkit/ValueCallback;)V

    .line 101
    iget-object v2, p0, Lcom/cicp/jwxt/InAppOpen$1;->val$ok:[Z

    aput-boolean v0, v2, v1
    :try_end_e
    .catchall {:try_start_2 .. :try_end_e} :catchall_f

    .line 103
    goto :goto_10

    .line 102
    :catchall_f
    move-exception v2

    .line 104
    :goto_10
    iget-object v2, p0, Lcom/cicp/jwxt/InAppOpen$1;->val$ok:[Z

    aget-boolean v2, v2, v1

    if-nez v2, :cond_37

    .line 106
    :try_start_16
    iget-object v3, p0, Lcom/cicp/jwxt/InAppOpen$1;->val$w:Landroid/webkit/WebView;

    const-string v4, "https://jwxt.cicp.edu.cn/"

    iget-object v2, p0, Lcom/cicp/jwxt/InAppOpen$1;->val$url:Ljava/lang/String;

    iget-object v5, p0, Lcom/cicp/jwxt/InAppOpen$1;->val$diag:Ljava/lang/StringBuilder;

    iget-object v6, p0, Lcom/cicp/jwxt/InAppOpen$1;->val$cookie:Ljava/lang/String;

    invoke-virtual {v6}, Ljava/lang/String;->length()I

    move-result v6

    if-lez v6, :cond_27

    goto :goto_28

    :cond_27
    move v0, v1

    :goto_28
    # invokes: Lcom/cicp/jwxt/InAppOpen;->diagHtml(Ljava/lang/String;Ljava/lang/StringBuilder;Z)Ljava/lang/String;
    invoke-static {v2, v5, v0}, Lcom/cicp/jwxt/InAppOpen;->access$000(Ljava/lang/String;Ljava/lang/StringBuilder;Z)Ljava/lang/String;

    move-result-object v5

    const-string v6, "text/html"

    const-string v7, "UTF-8"

    iget-object v8, p0, Lcom/cicp/jwxt/InAppOpen$1;->val$url:Ljava/lang/String;

    invoke-virtual/range {v3 .. v8}, Landroid/webkit/WebView;->loadDataWithBaseURL(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    :try_end_35
    .catchall {:try_start_16 .. :try_end_35} :catchall_36

    .line 108
    goto :goto_37

    .line 107
    :catchall_36
    move-exception v0

    .line 110
    :cond_37
    :goto_37
    return-void
.end method
