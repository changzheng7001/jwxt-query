.class Lcom/cicp/jwxt/MainActivity$1;
.super Ljava/lang/Object;
.source "MainActivity.java"

# interfaces
.implements Ljava/lang/Runnable;

# instance fields
.field final synthetic this$0:Lcom/cicp/jwxt/MainActivity;

# direct methods
.method public constructor <init>(Lcom/cicp/jwxt/MainActivity;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/cicp/jwxt/MainActivity$1;->this$0:Lcom/cicp/jwxt/MainActivity;

    return-void
.end method

# virtual methods
.method public run()V
    .locals 1

    iget-object v0, p0, Lcom/cicp/jwxt/MainActivity$1;->this$0:Lcom/cicp/jwxt/MainActivity;

    invoke-virtual {v0}, Lcom/cicp/jwxt/MainActivity;->gotoSchedule()V

    return-void
.end method
