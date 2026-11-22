.class public Lcom/cicp/jwxt/WebActivity$Bridge;
.super Ljava/lang/Object;
.source "WebActivity.java"

.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/cicp/jwxt/WebActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x1
    name = "Bridge"
.end annotation

.field final synthetic this$0:Lcom/cicp/jwxt/WebActivity;

.method public constructor <init>(Lcom/cicp/jwxt/WebActivity;)V
    .registers 2

    iput-object p1, p0, Lcom/cicp/jwxt/WebActivity$Bridge;->this$0:Lcom/cicp/jwxt/WebActivity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public backToApp()V
    .registers 2

    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation

    iget-object v0, p0, Lcom/cicp/jwxt/WebActivity$Bridge;->this$0:Lcom/cicp/jwxt/WebActivity;

    invoke-virtual {v0}, Lcom/cicp/jwxt/WebActivity;->finish()V

    return-void
.end method

.method public showNativeLogin()V
    .registers 2

    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation

    iget-object v0, p0, Lcom/cicp/jwxt/WebActivity$Bridge;->this$0:Lcom/cicp/jwxt/WebActivity;

    invoke-static {v0}, Lcom/cicp/jwxt/NativeLogin;->show(Landroid/app/Activity;)V

    return-void
.end method
