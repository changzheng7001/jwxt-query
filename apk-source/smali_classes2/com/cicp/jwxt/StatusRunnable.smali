.class Lcom/cicp/jwxt/StatusRunnable;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;
.source "StatusRunnable.java"

.field private final act:Landroid/app/Activity;
.field private final dark:Z

.method public constructor <init>(Landroid/app/Activity;Z)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/cicp/jwxt/StatusRunnable;->act:Landroid/app/Activity;

    iput-boolean p2, p0, Lcom/cicp/jwxt/StatusRunnable;->dark:Z

    return-void
.end method

.method public run()V
    .locals 5

    iget-object v0, p0, Lcom/cicp/jwxt/StatusRunnable;->act:Landroid/app/Activity;

    invoke-virtual {v0}, Landroid/app/Activity;->getWindow()Landroid/view/Window;

    move-result-object v1

    iget-boolean v2, p0, Lcom/cicp/jwxt/StatusRunnable;->dark:Z

    if-eqz v2, :cond_light

    const v3, 0xff161b17

    invoke-virtual {v1, v3}, Landroid/view/Window;->setStatusBarColor(I)V

    invoke-virtual {v1}, Landroid/view/Window;->getDecorView()Landroid/view/View;

    move-result-object v2

    invoke-virtual {v2}, Landroid/view/View;->getSystemUiVisibility()I

    move-result v3

    const/16 v4, 0x2000

    not-int v4, v4

    and-int/2addr v3, v4

    invoke-virtual {v2, v3}, Landroid/view/View;->setSystemUiVisibility(I)V

    goto :goto_done

    :cond_light

    const v3, 0xff2e4a2a

    invoke-virtual {v1, v3}, Landroid/view/Window;->setStatusBarColor(I)V

    invoke-virtual {v1}, Landroid/view/Window;->getDecorView()Landroid/view/View;

    move-result-object v2

    invoke-virtual {v2}, Landroid/view/View;->getSystemUiVisibility()I

    move-result v3

    const/16 v4, 0x2000

    or-int/2addr v3, v4

    invoke-virtual {v2, v3}, Landroid/view/View;->setSystemUiVisibility(I)V

    :goto_done
    return-void
.end method
