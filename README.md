# CICP 教务查询 APP

中央司法警官学院教务系统查询工具，WebView 包装的 Android 应用。

## 功能

- 课表查询（本人 / 教师 / 教室 / 班级 / 课程）
- 成绩与绩点
- 学习进度
- 考试安排
- 选课结果
- 全校教师 / 班级 / 教室浏览
- 本地缓存，无网也能查看
- 沉浸式状态栏（与页面融为一体的透明状态栏，随明暗主题切换）
- 常驻"今日课程"通知（按教学周过滤，点击直达本人课表）
- 经典 / 玻璃双主题（含液态玻璃底部导航）

## 技术架构

```
┌──────────────────────────────────┐
│   Android WebView（沉浸式状态栏）  │
│  ┌────────────────────────────┐  │
│  │   index.html（前端 UI/逻辑） │  │
│  └────────────────────────────┘  │
│           ↓ window.Android 调用   │
│  ┌────────────────────────────┐  │
│  │  MainActivity（Java 原生层）│  │
│  │  httpRequest / 通知 / 沉浸  │  │
│  └────────────────────────────┘  │
│           ↓（CookieManager 会话） │
│          教务系统 HTTP API        │
└──────────────────────────────────┘
```

- **前端**：单文件 HTML + CSS + JS（`cicp-jwxt-android/app/src/main/assets/index.html`，源文件 `jwxt-webapp/index.html`）
- **Android 原生层**：`MainActivity.java`（WebView + JS 桥）
- **接口**：直接调用教务系统 HTTP 接口

### 会话与隐私（重要）

- **不存明文密码**：登录后本地只保存账号用于回填，密码从不写入存储
- **存会话**：登录后的教务会话由原生 `java.net.CookieManager` 全局管理（登录响应中的 Set-Cookie 自动存入、后续请求自动携带），实现"登录后存会话、不存明文密码"
- 退出登录会同时清除本地凭证与原生会话 Cookie

## 目录结构

```
├── cicp-jwxt-android/            # 标准 Android Studio 工程（推荐）
│   ├── settings.gradle / build.gradle / gradle.properties
│   └── app/
│       ├── build.gradle
│       └── src/main/
│           ├── AndroidManifest.xml
│           ├── java/com/cicp/jwxt/MainActivity.java   # 原生层
│           ├── assets/index.html                       # 前端（主要改这里）
│           └── res/                                    # 布局/样式/图标
├── jwxt-webapp/
│   └── index.html                # 前端源文件（与 assets/ 同步）
├── apk-source/                    # 旧反编译打包源（smali，兼容保留）
└── README.md
```

## 如何构建

### 方式一：标准 Android Studio 工程（推荐）

用 Android Studio（Giraffe / Hedgehog 或更新）打开 `cicp-jwxt-android/`，配置 Android SDK Platform 34 后直接 Build → Generate APK。

```bash
cd cicp-jwxt-android
./gradlew assembleRelease   # 或用 Android Studio 构建
```

### 方式二：apktool 快速打包（无需 Android SDK）

前端在 `jwxt-webapp/index.html` 修改后，同步到 `apk-source/assets/index.html`，然后：

```bash
java -jar apktool.jar b apk-source -o cicp-jwxt_new.apk
java -jar uber-apk-signer.jar -a cicp-jwxt_new.apk --out signed
```

签名后的 APK 可直接安装。

## 使用

1. 安装 APK
2. 打开 App，默认缓存模式，无网也能看之前查过的数据
3. 需要更新数据时点右上角"登录"，输入学号密码
4. 点"查询"看缓存，点"刷新"拉新数据

## 版本

当前版本：**v0.9.7**（测试版；1.0 为正式版，正式版前版本号均低于 1.0）

## 开发说明

本项目由 [豆包工作（Doubao Work）](https://www.doubao.com) 协助开发完成。豆包办公 Agent 参与了项目的需求梳理、前端界面与逻辑实现、接口对接、APK 打包签名、标准工程重构、调试迭代以及代码托管等环节。

- 前端代码、交互设计与调试：豆包办公 Agent 编写与维护
- APK 打包、签名与版本管理：豆包办公 Agent 完成
- 标准 Android 工程重构与会话安全改造：豆包办公 Agent 完成
- 功能迭代（深色主题、日视图、缓存、沉浸状态栏、液态玻璃、通知等）：与豆包办公 Agent 多轮协作打磨

## 说明

- 本项目仅供学习交流使用
- 数据来自学校教务系统，如有问题请联系学校
- 本项目遵循 MIT 许可证，详见 [LICENSE](LICENSE)
