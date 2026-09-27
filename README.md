# CICP 教务查询 APP

CICP 教务系统查询工具，WebView 包装的 Android APK。

## 功能

- 课表查询（教师/教室/班级/本人）
- 成绩与绩点
- 学习进度
- 考试安排
- 选课结果
- 全校教师/班级/教室浏览
- 本地缓存，无网也能查看

## 技术架构

```
┌─────────────────────────┐
│   Android WebView       │
│  ┌───────────────────┐  │
│  │   index.html      │  │
│  │   (前端 UI/逻辑)   │  │
│  └───────────────────┘  │
│           ↓ 调用         │
│  ┌───────────────────┐  │
│  │ Android.httpRequest│ │
│  │ (Java 原生发请求)   │  │
│  └───────────────────┘  │
│           ↓             │
│    教务系统 HTTP API     │
└─────────────────────────┘
```

- **前端**：单文件 HTML + CSS + JS（`apk-source/assets/index.html`）
- **Android 壳**：反编译的 smali 代码（`apk-source/smali/`）
- **接口**：直接调用教务系统 HTTP 接口

## 目录结构

```
├── apk-source/           # 完整反编译源码
│   ├── AndroidManifest.xml
│   ├── apktool.yml
│   ├── assets/
│   │   └── index.html    # 前端代码（主要改这里）
│   ├── smali/            # Android 原生代码
│   ├── res/              # 资源文件
│   └── original/
├── jwxt-webapp/
│   └── index.html        # 前端源文件（和 apk-source/assets/ 同步）
└── README.md
```

## 如何修改和打包

### 1. 修改前端代码

编辑 `jwxt-webapp/index.html`，改完后复制到 `apk-source/assets/index.html`。

### 2. 打包 APK

需要安装 apktool：
```bash
# 下载 apktool
wget https://github.com/iBotPeaches/Apktool/releases/download/v2.9.3/apktool_2.9.3.jar -O apktool.jar

# 打包
java -jar apktool.jar b apk-source -o cicp-jwxt_new.apk
```

### 3. 签名

需要安装 uber-apk-signer：
```bash
wget https://github.com/patrickfav/uber-apk-signer/releases/download/v1.3.0/uber-apk-signer-1.3.0.jar -O uber-apk-signer.jar

# 用 debug keystore 签名
java -jar uber-apk-signer.jar -a cicp-jwxt_new.apk --out signed
```

签名后的 APK 可以直接安装。

## 使用

1. 安装 APK
2. 打开 App，默认缓存模式，无网也能看之前查过的数据
3. 需要更新数据时点右上角"登录"，输入学号密码
4. 点"查询"看缓存，点"刷新"拉新数据

## 版本

当前版本：v0.9（测试版）

## 开发说明

本项目由 [豆包工作（Doubao Work）](https://www.doubao.com) 协助开发完成。豆包办公 Agent 参与了项目的需求梳理、前端界面与逻辑实现、接口对接、APK 打包签名、调试迭代以及代码托管等环节。

- 前端代码、交互设计与调试：豆包办公 Agent 编写与维护
- APK 打包、签名与版本管理：豆包办公 Agent 完成
- 功能迭代（深色主题、日视图、缓存、弹窗等）：与豆包办公 Agent 多轮协作打磨

## 说明

- 本项目仅供学习交流使用
- 数据来自学校教务系统，如有问题请联系学校
- 本项目遵循 MIT 许可证，详见 [LICENSE](LICENSE)
