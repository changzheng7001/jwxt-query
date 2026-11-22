.class Lcom/cicp/jwxt/InAppOpen$4;
.super Ljava/lang/Object;
.source "InAppOpen.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/cicp/jwxt/InAppOpen;->addStatusStrip(Landroid/app/Activity;Landroid/webkit/WebView;I)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic val$act:Landroid/app/Activity;

.field final synthetic val$root:Landroid/widget/FrameLayout;

.field final synthetic val$w:Landroid/webkit/WebView;


# direct methods
.method constructor <init>(Landroid/webkit/WebView;Landroid/widget/FrameLayout;Landroid/app/Activity;)V
    .registers 4
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    .line 661
    iput-object p1, p0, Lcom/cicp/jwxt/InAppOpen$4;->val$w:Landroid/webkit/WebView;

    iput-object p2, p0, Lcom/cicp/jwxt/InAppOpen$4;->val$root:Landroid/widget/FrameLayout;

    iput-object p3, p0, Lcom/cicp/jwxt/InAppOpen$4;->val$act:Landroid/app/Activity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .registers 4

    .line 664
    :try_start_0
    iget-object v0, p0, Lcom/cicp/jwxt/InAppOpen$4;->val$w:Landroid/webkit/WebView;

    invoke-virtual {v0}, Landroid/webkit/WebView;->getUrl()Ljava/lang/String;

    move-result-object v0

    .line 669
    iget-object v1, p0, Lcom/cicp/jwxt/InAppOpen$4;->val$w:Landroid/webkit/WebView;

    invoke-virtual {v1}, Landroid/webkit/WebView;->getVisibility()I

    move-result v1

    if-nez v1, :cond_29

    if-eqz v0, :cond_29

    const-string v1, "file://"

    .line 670
    invoke-virtual {v0, v1}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v1

    if-nez v1, :cond_29

    const-string v1, "/jsxsd/"

    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v0

    if-nez v0, :cond_21

    goto :goto_29

    .line 679
    :cond_21
    iget-object v0, p0, Lcom/cicp/jwxt/InAppOpen$4;->val$w:Landroid/webkit/WebView;

    const-wide/16 v1, 0x12c

    invoke-virtual {v0, p0, v1, v2}, Landroid/webkit/WebView;->postDelayed(Ljava/lang/Runnable;J)Z

    .line 681
    goto :goto_41

    .line 672
    :cond_29
    :goto_29
    iget-object v0, p0, Lcom/cicp/jwxt/InAppOpen$4;->val$root:Landroid/widget/FrameLayout;

    const-string v1, "jwxt_status_strip"

    invoke-virtual {v0, v1}, Landroid/widget/FrameLayout;->findViewWithTag(Ljava/lang/Object;)Landroid/view/View;

    move-result-object v0

    .line 673
    if-eqz v0, :cond_38

    iget-object v1, p0, Lcom/cicp/jwxt/InAppOpen$4;->val$root:Landroid/widget/FrameLayout;

    invoke-virtual {v1, v0}, Landroid/widget/FrameLayout;->removeView(Landroid/view/View;)V

    .line 676
    :cond_38
    iget-object v0, p0, Lcom/cicp/jwxt/InAppOpen$4;->val$act:Landroid/app/Activity;

    iget-object v1, p0, Lcom/cicp/jwxt/InAppOpen$4;->val$w:Landroid/webkit/WebView;

    # invokes: Lcom/cicp/jwxt/InAppOpen;->restoreNativeState(Landroid/app/Activity;Landroid/webkit/WebView;)V
    invoke-static {v0, v1}, Lcom/cicp/jwxt/InAppOpen;->access$300(Landroid/app/Activity;Landroid/webkit/WebView;)V
    :try_end_3f
    .catchall {:try_start_0 .. :try_end_3f} :catchall_40

    .line 677
    return-void

    .line 680
    :catchall_40
    move-exception v0

    .line 682
    :goto_41
    return-void
.end method
