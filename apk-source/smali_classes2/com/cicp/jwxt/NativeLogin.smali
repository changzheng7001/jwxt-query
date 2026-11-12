.class public Lcom/cicp/jwxt/NativeLogin;
.super Ljava/lang/Object;
.source "NativeLogin.java"


# direct methods
.method public constructor <init>()V
    .registers 1

    .line 15
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method static synthetic access$000(Ljava/lang/String;)Ljava/lang/String;
    .registers 1

    .line 15
    invoke-static {p0}, Lcom/cicp/jwxt/NativeLogin;->js(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method private static findWebView(Landroid/app/Activity;)Landroid/webkit/WebView;
    .registers 9

    .line 19
    const/4 v0, 0x0

    :try_start_1
    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v1

    .line 20
    :goto_5
    if-eqz v1, :cond_38

    const-class v2, Ljava/lang/Object;

    if-eq v1, v2, :cond_38

    .line 21
    invoke-virtual {v1}, Ljava/lang/Class;->getDeclaredFields()[Ljava/lang/reflect/Field;

    move-result-object v2

    array-length v3, v2

    move v4, v0

    :goto_11
    if-ge v4, v3, :cond_33

    aget-object v5, v2, v4

    .line 22
    const-class v6, Landroid/webkit/WebView;

    invoke-virtual {v5}, Ljava/lang/reflect/Field;->getType()Ljava/lang/Class;

    move-result-object v7

    invoke-virtual {v6, v7}, Ljava/lang/Class;->isAssignableFrom(Ljava/lang/Class;)Z

    move-result v6

    if-eqz v6, :cond_30

    .line 23
    const/4 v6, 0x1

    invoke-virtual {v5, v6}, Ljava/lang/reflect/Field;->setAccessible(Z)V

    .line 24
    invoke-virtual {v5, p0}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v5

    .line 25
    instance-of v6, v5, Landroid/webkit/WebView;

    if-eqz v6, :cond_30

    check-cast v5, Landroid/webkit/WebView;

    return-object v5

    .line 21
    :cond_30
    add-int/lit8 v4, v4, 0x1

    goto :goto_11

    .line 28
    :cond_33
    invoke-virtual {v1}, Ljava/lang/Class;->getSuperclass()Ljava/lang/Class;

    move-result-object v1
    :try_end_37
    .catchall {:try_start_1 .. :try_end_37} :catchall_39

    goto :goto_5

    .line 31
    :cond_38
    goto :goto_3a

    .line 30
    :catchall_39
    move-exception v1

    .line 32
    :goto_3a
    const-string v1, "webView"

    const-string v2, "wv"

    const-string v3, "webview"

    filled-new-array {v3, v1, v2}, [Ljava/lang/String;

    move-result-object v1

    .line 33
    nop

    :goto_45
    const/4 v2, 0x3

    if-ge v0, v2, :cond_6a

    aget-object v2, v1, v0

    .line 35
    :try_start_4a
    invoke-virtual {p0}, Landroid/app/Activity;->getResources()Landroid/content/res/Resources;

    move-result-object v3

    const-string v4, "id"

    invoke-virtual {p0}, Landroid/app/Activity;->getPackageName()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v3, v2, v4, v5}, Landroid/content/res/Resources;->getIdentifier(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I

    move-result v2

    .line 36
    if-eqz v2, :cond_65

    .line 37
    invoke-virtual {p0, v2}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;

    move-result-object v2

    .line 38
    instance-of v3, v2, Landroid/webkit/WebView;

    if-eqz v3, :cond_65

    check-cast v2, Landroid/webkit/WebView;
    :try_end_64
    .catchall {:try_start_4a .. :try_end_64} :catchall_66

    return-object v2

    .line 41
    :cond_65
    goto :goto_67

    .line 40
    :catchall_66
    move-exception v2

    .line 33
    :goto_67
    add-int/lit8 v0, v0, 0x1

    goto :goto_45

    .line 43
    :cond_6a
    const/4 p0, 0x0

    return-object p0
.end method

.method private static js(Ljava/lang/String;)Ljava/lang/String;
    .registers 7

    .line 94
    if-nez p0, :cond_5

    const-string p0, "\'\'"

    return-object p0

    .line 95
    :cond_5
    new-instance v0, Ljava/lang/StringBuilder;

    const-string v1, "\'"

    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    .line 96
    const/4 v2, 0x0

    :goto_d
    invoke-virtual {p0}, Ljava/lang/String;->length()I

    move-result v3

    if-ge v2, v3, :cond_4c

    .line 97
    invoke-virtual {p0, v2}, Ljava/lang/String;->charAt(I)C

    move-result v3

    .line 98
    const/16 v4, 0x5c

    if-eq v3, v4, :cond_42

    const/16 v5, 0x27

    if-ne v3, v5, :cond_20

    goto :goto_42

    .line 99
    :cond_20
    const/16 v4, 0xa

    if-ne v3, v4, :cond_2a

    const-string v3, "\\n"

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    goto :goto_49

    .line 100
    :cond_2a
    const/16 v4, 0xd

    if-ne v3, v4, :cond_34

    const-string v3, "\\r"

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    goto :goto_49

    .line 101
    :cond_34
    const/16 v4, 0x3c

    if-ne v3, v4, :cond_3e

    const-string v3, "\\u003c"

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    goto :goto_49

    .line 102
    :cond_3e
    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    goto :goto_49

    .line 98
    :cond_42
    :goto_42
    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v3}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    .line 96
    :goto_49
    add-int/lit8 v2, v2, 0x1

    goto :goto_d

    .line 104
    :cond_4c
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method public static show(Landroid/app/Activity;)V
    .registers 10

    .line 47
    invoke-static {p0}, Lcom/cicp/jwxt/NativeLogin;->findWebView(Landroid/app/Activity;)Landroid/webkit/WebView;

    move-result-object v0

    .line 48
    new-instance v1, Landroid/widget/LinearLayout;

    invoke-direct {v1, p0}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V

    .line 49
    const/4 v2, 0x1

    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->setOrientation(I)V

    .line 50
    invoke-virtual {p0}, Landroid/app/Activity;->getResources()Landroid/content/res/Resources;

    move-result-object v3

    invoke-virtual {v3}, Landroid/content/res/Resources;->getDisplayMetrics()Landroid/util/DisplayMetrics;

    move-result-object v3

    iget v3, v3, Landroid/util/DisplayMetrics;->density:F

    const/high16 v4, 0x41900000    # 18.0f

    mul-float/2addr v3, v4

    float-to-int v3, v3

    .line 51
    div-int/lit8 v4, v3, 0x2

    const/4 v5, 0x0

    invoke-virtual {v1, v3, v4, v3, v5}, Landroid/widget/LinearLayout;->setPadding(IIII)V

    .line 53
    new-instance v3, Landroid/widget/EditText;

    invoke-direct {v3, p0}, Landroid/widget/EditText;-><init>(Landroid/content/Context;)V

    .line 54
    const-string v4, "\u5b66\u53f7"

    invoke-virtual {v3, v4}, Landroid/widget/EditText;->setHint(Ljava/lang/CharSequence;)V

    .line 55
    invoke-virtual {v3, v2}, Landroid/widget/EditText;->setSingleLine(Z)V

    .line 56
    invoke-virtual {v3, v2}, Landroid/widget/EditText;->setInputType(I)V

    .line 57
    sget v4, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v5, 0x1a

    if-lt v4, v5, :cond_43

    .line 58
    const-string v4, "username"

    filled-new-array {v4}, [Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Landroid/widget/EditText;->setAutofillHints([Ljava/lang/String;)V

    .line 59
    invoke-virtual {v3, v2}, Landroid/widget/EditText;->setImportantForAutofill(I)V

    .line 61
    :cond_43
    new-instance v4, Landroid/widget/LinearLayout$LayoutParams;

    const/4 v6, -0x1

    const/4 v7, -0x2

    invoke-direct {v4, v6, v7}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V

    invoke-virtual {v1, v3, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;Landroid/view/ViewGroup$LayoutParams;)V

    .line 63
    new-instance v4, Landroid/widget/EditText;

    invoke-direct {v4, p0}, Landroid/widget/EditText;-><init>(Landroid/content/Context;)V

    .line 64
    const-string v8, "\u5bc6\u7801"

    invoke-virtual {v4, v8}, Landroid/widget/EditText;->setHint(Ljava/lang/CharSequence;)V

    .line 65
    invoke-virtual {v4, v2}, Landroid/widget/EditText;->setSingleLine(Z)V

    .line 66
    const/16 v8, 0x81

    invoke-virtual {v4, v8}, Landroid/widget/EditText;->setInputType(I)V

    .line 67
    sget v8, Landroid/os/Build$VERSION;->SDK_INT:I

    if-lt v8, v5, :cond_6f

    .line 68
    const-string v5, "password"

    filled-new-array {v5}, [Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v4, v5}, Landroid/widget/EditText;->setAutofillHints([Ljava/lang/String;)V

    .line 69
    invoke-virtual {v4, v2}, Landroid/widget/EditText;->setImportantForAutofill(I)V

    .line 71
    :cond_6f
    new-instance v2, Landroid/widget/LinearLayout$LayoutParams;

    invoke-direct {v2, v6, v7}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V

    invoke-virtual {v1, v4, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;Landroid/view/ViewGroup$LayoutParams;)V

    .line 73
    new-instance v2, Landroid/app/AlertDialog$Builder;

    invoke-direct {v2, p0}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    .line 74
    const-string p0, "\u767b\u5f55\u6559\u52a1\u7cfb\u7edf"

    invoke-virtual {v2, p0}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object p0

    .line 75
    invoke-virtual {p0, v1}, Landroid/app/AlertDialog$Builder;->setView(Landroid/view/View;)Landroid/app/AlertDialog$Builder;

    move-result-object p0

    new-instance v1, Lcom/cicp/jwxt/NativeLogin$1;

    invoke-direct {v1, v3, v4, v0}, Lcom/cicp/jwxt/NativeLogin$1;-><init>(Landroid/widget/EditText;Landroid/widget/EditText;Landroid/webkit/WebView;)V

    .line 76
    const-string v0, "\u767b\u5f55"

    invoke-virtual {p0, v0, v1}, Landroid/app/AlertDialog$Builder;->setPositiveButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object p0

    .line 89
    const-string v0, "\u53d6\u6d88"

    const/4 v1, 0x0

    invoke-virtual {p0, v0, v1}, Landroid/app/AlertDialog$Builder;->setNegativeButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object p0

    .line 90
    invoke-virtual {p0}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    .line 91
    return-void
.end method
