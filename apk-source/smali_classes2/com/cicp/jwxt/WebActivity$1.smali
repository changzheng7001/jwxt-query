.class Lcom/cicp/jwxt/WebActivity$1;
.super Ljava/lang/Object;
.source "WebActivity.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/cicp/jwxt/WebActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic val$act:Landroid/app/Activity;

.field final synthetic val$url:Ljava/lang/String;


# direct methods
.method constructor <init>(Landroid/app/Activity;Ljava/lang/String;)V
    .registers 3

    iput-object p1, p0, Lcom/cicp/jwxt/WebActivity$1;->val$act:Landroid/app/Activity;

    iput-object p2, p0, Lcom/cicp/jwxt/WebActivity$1;->val$url:Ljava/lang/String;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .registers 3

    :try_start_0
    iget-object v0, p0, Lcom/cicp/jwxt/WebActivity$1;->val$act:Landroid/app/Activity;

    iget-object v1, p0, Lcom/cicp/jwxt/WebActivity$1;->val$url:Ljava/lang/String;

    invoke-static {v0, v1}, Lcom/cicp/jwxt/InAppOpen;->open(Landroid/app/Activity;Ljava/lang/String;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto :goto_0

    :catchall_0
    move-exception v0

    :goto_0
    return-void
.end method