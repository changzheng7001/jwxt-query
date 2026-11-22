.class Lcom/cicp/jwxt/InAppOpen$5;
.super Ljava/lang/Object;
.source "InAppOpen.java"

# interfaces
.implements Landroid/view/View$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/cicp/jwxt/InAppOpen;->addBrowserBar(Landroid/app/Activity;Landroid/webkit/WebView;Ljava/lang/String;II)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic val$act:Landroid/app/Activity;

.field final synthetic val$bar:Landroid/widget/LinearLayout;

.field final synthetic val$root:Landroid/widget/FrameLayout;


# direct methods
.method constructor <init>(Landroid/widget/FrameLayout;Landroid/widget/LinearLayout;Landroid/app/Activity;)V
    .registers 4
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    .line 602
    iput-object p1, p0, Lcom/cicp/jwxt/InAppOpen$5;->val$root:Landroid/widget/FrameLayout;

    iput-object p2, p0, Lcom/cicp/jwxt/InAppOpen$5;->val$bar:Landroid/widget/LinearLayout;

    iput-object p3, p0, Lcom/cicp/jwxt/InAppOpen$5;->val$act:Landroid/app/Activity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/view/View;)V
    .registers 3

    .line 605
    :try_start_0
    iget-object p1, p0, Lcom/cicp/jwxt/InAppOpen$5;->val$root:Landroid/widget/FrameLayout;

    iget-object v0, p0, Lcom/cicp/jwxt/InAppOpen$5;->val$bar:Landroid/widget/LinearLayout;

    invoke-virtual {p1, v0}, Landroid/widget/FrameLayout;->removeView(Landroid/view/View;)V

    .line 606
    iget-object p1, p0, Lcom/cicp/jwxt/InAppOpen$5;->val$act:Landroid/app/Activity;

    invoke-virtual {p1}, Landroid/app/Activity;->finish()V
    :try_end_c
    .catchall {:try_start_0 .. :try_end_c} :catchall_d

    .line 608
    goto :goto_e

    .line 607
    :catchall_d
    move-exception p1

    .line 609
    :goto_e
    return-void
.end method
