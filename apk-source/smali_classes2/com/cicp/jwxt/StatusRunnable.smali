.class Lcom/cicp/jwxt/StatusRunnable;
.super Ljava/lang/Object;
.source "StatusRunnable.java"

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field private final act:Landroid/app/Activity;

.field private final dark:Z


# direct methods
.method public constructor <init>(Landroid/app/Activity;Z)V
    .registers 3

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/cicp/jwxt/StatusRunnable;->act:Landroid/app/Activity;

    iput-boolean p2, p0, Lcom/cicp/jwxt/StatusRunnable;->dark:Z

    return-void
.end method


# virtual methods
.method public run()V
    .registers 6

    iget-object v0, p0, Lcom/cicp/jwxt/StatusRunnable;->act:Landroid/app/Activity;

    invoke-virtual {v0}, Landroid/app/Activity;->getWindow()Landroid/view/Window;

    move-result-object v1

    const v3, 0x4000000

    invoke-virtual {v1, v3}, Landroid/view/Window;->clearFlags(I)V

    const/high16 v3, -0x80000000

    invoke-virtual {v1, v3}, Landroid/view/Window;->addFlags(I)V

    iget-boolean v2, p0, Lcom/cicp/jwxt/StatusRunnable;->dark:Z

    if-eqz v2, :cond_2e

    const v3, 0x0

    invoke-virtual {v1, v3}, Landroid/view/Window;->setStatusBarColor(I)V

    invoke-virtual {v1}, Landroid/view/Window;->getDecorView()Landroid/view/View;

    move-result-object v2

    invoke-virtual {v2}, Landroid/view/View;->getSystemUiVisibility()I

    move-result v3

    const/16 v4, 0x500

    or-int/2addr v3, v4

    const/16 v4, 0x2000

    not-int v4, v4

    and-int/2addr v3, v4

    invoke-virtual {v2, v3}, Landroid/view/View;->setSystemUiVisibility(I)V

    goto :goto_45

    :cond_2e
    const v3, 0x0

    invoke-virtual {v1, v3}, Landroid/view/Window;->setStatusBarColor(I)V

    invoke-virtual {v1}, Landroid/view/Window;->getDecorView()Landroid/view/View;

    move-result-object v2

    invoke-virtual {v2}, Landroid/view/View;->getSystemUiVisibility()I

    move-result v3

    const/16 v4, 0x500

    or-int/2addr v3, v4

    const/16 v4, 0x2000

    or-int/2addr v3, v4

    invoke-virtual {v2, v3}, Landroid/view/View;->setSystemUiVisibility(I)V

    :goto_45
    return-void
.end method
