.class Lcom/cicp/jwxt/MainActivity$NotifReceiver;
.super Landroid/content/BroadcastReceiver;
.source "MainActivity.java"

.field final synthetic this$0:Lcom/cicp/jwxt/MainActivity;

.method public constructor <init>(Lcom/cicp/jwxt/MainActivity;)V
    .locals 0

    invoke-direct {p0}, Landroid/content/BroadcastReceiver;-><init>()V

    iput-object p1, p0, Lcom/cicp/jwxt/MainActivity$NotifReceiver;->this$0:Lcom/cicp/jwxt/MainActivity;

    return-void
.end method

.method public onReceive(Landroid/content/Context;Landroid/content/Intent;)V
    .locals 8

    const-string v1, "t"

    invoke-virtual {p2, v1}, Landroid/content/Intent;->getStringExtra(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    const-string v2, "c"

    invoke-virtual {p2, v2}, Landroid/content/Intent;->getStringExtra(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    const-string v3, "x"

    const/4 v4, 0x0

    invoke-virtual {p2, v3, v4}, Landroid/content/Intent;->getBooleanExtra(Ljava/lang/String;Z)Z

    move-result v3

    if-eqz v1, :cond_skip

    if-eqz v2, :cond_skip

    new-instance v5, Lcom/cicp/jwxt/MainActivity$WebAppInterface;

    iget-object v6, p0, Lcom/cicp/jwxt/MainActivity$NotifReceiver;->this$0:Lcom/cicp/jwxt/MainActivity;

    invoke-direct {v5, v6}, Lcom/cicp/jwxt/MainActivity$WebAppInterface;-><init>(Lcom/cicp/jwxt/MainActivity;)V

    if-eqz v3, :cond_collapse

    invoke-virtual {v5, v1, v2}, Lcom/cicp/jwxt/MainActivity$WebAppInterface;->showNotifExpanded(Ljava/lang/String;Ljava/lang/String;)Z

    goto :cond_skip

    :cond_collapse

    const/4 v7, 0x1

    invoke-virtual {v5, v1, v2, v7}, Lcom/cicp/jwxt/MainActivity$WebAppInterface;->showNotification(Ljava/lang/String;Ljava/lang/String;Z)Z

    :cond_skip

    return-void
.end method
