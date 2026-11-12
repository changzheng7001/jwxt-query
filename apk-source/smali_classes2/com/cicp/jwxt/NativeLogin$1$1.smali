.class Lcom/cicp/jwxt/NativeLogin$1$1;
.super Ljava/lang/Object;
.source "NativeLogin.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/cicp/jwxt/NativeLogin$1;->onClick(Landroid/content/DialogInterface;I)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/cicp/jwxt/NativeLogin$1;

.field final synthetic val$p:Ljava/lang/String;

.field final synthetic val$u:Ljava/lang/String;


# direct methods
.method constructor <init>(Lcom/cicp/jwxt/NativeLogin$1;Ljava/lang/String;Ljava/lang/String;)V
    .registers 4
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    .line 81
    iput-object p1, p0, Lcom/cicp/jwxt/NativeLogin$1$1;->this$0:Lcom/cicp/jwxt/NativeLogin$1;

    iput-object p2, p0, Lcom/cicp/jwxt/NativeLogin$1$1;->val$u:Ljava/lang/String;

    iput-object p3, p0, Lcom/cicp/jwxt/NativeLogin$1$1;->val$p:Ljava/lang/String;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .registers 4

    .line 83
    iget-object v0, p0, Lcom/cicp/jwxt/NativeLogin$1$1;->this$0:Lcom/cicp/jwxt/NativeLogin$1;

    iget-object v0, v0, Lcom/cicp/jwxt/NativeLogin$1;->val$wv:Landroid/webkit/WebView;

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "window.__nativeLogin&&window.__nativeLogin("

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget-object v2, p0, Lcom/cicp/jwxt/NativeLogin$1$1;->val$u:Ljava/lang/String;

    # invokes: Lcom/cicp/jwxt/NativeLogin;->js(Ljava/lang/String;)Ljava/lang/String;
    invoke-static {v2}, Lcom/cicp/jwxt/NativeLogin;->access$000(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, ","

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget-object v2, p0, Lcom/cicp/jwxt/NativeLogin$1$1;->val$p:Ljava/lang/String;

    # invokes: Lcom/cicp/jwxt/NativeLogin;->js(Ljava/lang/String;)Ljava/lang/String;
    invoke-static {v2}, Lcom/cicp/jwxt/NativeLogin;->access$000(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, ");"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    const/4 v2, 0x0

    invoke-virtual {v0, v1, v2}, Landroid/webkit/WebView;->evaluateJavascript(Ljava/lang/String;Landroid/webkit/ValueCallback;)V

    .line 84
    return-void
.end method
