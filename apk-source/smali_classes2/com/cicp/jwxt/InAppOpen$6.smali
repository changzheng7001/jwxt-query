.class Lcom/cicp/jwxt/InAppOpen$6;
.super Ljava/lang/Object;
.source "InAppOpen.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/cicp/jwxt/InAppOpen;->addBrowserBar(Landroid/app/Activity;Landroid/webkit/WebView;Ljava/lang/String;II)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic val$bar:Landroid/widget/LinearLayout;

.field final synthetic val$root:Landroid/widget/FrameLayout;

.field final synthetic val$w:Landroid/webkit/WebView;


# direct methods
.method constructor <init>(Landroid/webkit/WebView;Landroid/widget/FrameLayout;Landroid/widget/LinearLayout;)V
    .registers 4
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    .line 620
    iput-object p1, p0, Lcom/cicp/jwxt/InAppOpen$6;->val$w:Landroid/webkit/WebView;

    iput-object p2, p0, Lcom/cicp/jwxt/InAppOpen$6;->val$root:Landroid/widget/FrameLayout;

    iput-object p3, p0, Lcom/cicp/jwxt/InAppOpen$6;->val$bar:Landroid/widget/LinearLayout;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .registers 4

    .line 623
    :try_start_0
    iget-object v0, p0, Lcom/cicp/jwxt/InAppOpen$6;->val$w:Landroid/webkit/WebView;

    invoke-virtual {v0}, Landroid/webkit/WebView;->getUrl()Ljava/lang/String;

    move-result-object v0

    .line 624
    if-eqz v0, :cond_19

    const-string v1, "native=1"

    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v0

    if-nez v0, :cond_11

    goto :goto_19

    .line 628
    :cond_11
    iget-object v0, p0, Lcom/cicp/jwxt/InAppOpen$6;->val$w:Landroid/webkit/WebView;

    const-wide/16 v1, 0x320

    invoke-virtual {v0, p0, v1, v2}, Landroid/webkit/WebView;->postDelayed(Ljava/lang/Runnable;J)Z

    .line 630
    goto :goto_22

    .line 625
    :cond_19
    :goto_19
    iget-object v0, p0, Lcom/cicp/jwxt/InAppOpen$6;->val$root:Landroid/widget/FrameLayout;

    iget-object v1, p0, Lcom/cicp/jwxt/InAppOpen$6;->val$bar:Landroid/widget/LinearLayout;

    invoke-virtual {v0, v1}, Landroid/widget/FrameLayout;->removeView(Landroid/view/View;)V
    :try_end_20
    .catchall {:try_start_0 .. :try_end_20} :catchall_21

    .line 626
    return-void

    .line 629
    :catchall_21
    move-exception v0

    .line 631
    :goto_22
    return-void
.end method
