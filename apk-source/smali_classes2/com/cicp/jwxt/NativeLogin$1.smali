.class Lcom/cicp/jwxt/NativeLogin$1;
.super Ljava/lang/Object;
.source "NativeLogin.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/cicp/jwxt/NativeLogin;->show(Landroid/app/Activity;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic val$pass:Landroid/widget/EditText;

.field final synthetic val$user:Landroid/widget/EditText;

.field final synthetic val$wv:Landroid/webkit/WebView;


# direct methods
.method constructor <init>(Landroid/widget/EditText;Landroid/widget/EditText;Landroid/webkit/WebView;)V
    .registers 4
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    .line 76
    iput-object p1, p0, Lcom/cicp/jwxt/NativeLogin$1;->val$user:Landroid/widget/EditText;

    iput-object p2, p0, Lcom/cicp/jwxt/NativeLogin$1;->val$pass:Landroid/widget/EditText;

    iput-object p3, p0, Lcom/cicp/jwxt/NativeLogin$1;->val$wv:Landroid/webkit/WebView;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .registers 5

    .line 78
    iget-object p1, p0, Lcom/cicp/jwxt/NativeLogin$1;->val$user:Landroid/widget/EditText;

    invoke-virtual {p1}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object p1

    .line 79
    iget-object p2, p0, Lcom/cicp/jwxt/NativeLogin$1;->val$pass:Landroid/widget/EditText;

    invoke-virtual {p2}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object p2

    invoke-virtual {p2}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object p2

    .line 80
    iget-object v0, p0, Lcom/cicp/jwxt/NativeLogin$1;->val$wv:Landroid/webkit/WebView;

    if-eqz v0, :cond_24

    .line 81
    new-instance v1, Lcom/cicp/jwxt/NativeLogin$1$1;

    invoke-direct {v1, p0, p1, p2}, Lcom/cicp/jwxt/NativeLogin$1$1;-><init>(Lcom/cicp/jwxt/NativeLogin$1;Ljava/lang/String;Ljava/lang/String;)V

    invoke-virtual {v0, v1}, Landroid/webkit/WebView;->post(Ljava/lang/Runnable;)Z

    .line 87
    :cond_24
    return-void
.end method
