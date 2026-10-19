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
- **会话状态**：登录后的教务 Cookie 由原生网络层管理；页面不把本地登录标记当成有效会话，重新打开 App 后需要重新登录验证
- **个人缓存隔离**：课表、成绩、进度、考试和选课缓存按账户隔离；退出后保留该账户离线缓存，切换账户不会混用
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

## 维护与代码链说明

- **前端唯一源文件**：日常修改 `jwxt-webapp/index.html` 和其中的 `schedule-assets/`。
- **同步所有打包目标**：运行 `powershell -ExecutionPolicy Bypass -File scripts/sync-web-assets.ps1`，将页面与离线图片同步到 apktool 和 Android Studio 两份工程，避免 APK 与网页预览不一致。
- **Android 原生改动**：标准工程改 `cicp-jwxt-android/`；反编译打包改 `apk-source/`，并保持 Java/Smali 行为一致。

## 如何构建

### 方式一：apktool 快速打包（日常迭代，无需 Android SDK）

前端修改后先同步页面和图片，然后：

```bash
powershell -ExecutionPolicy Bypass -File scripts/sync-web-assets.ps1
java -jar apktool.jar b apk-source -o cicp-jwxt_new.apk
java -jar uber-apk-signer.jar -a cicp-jwxt_new.apk --out signed
```

签名后的 APK 可直接安装。

### 方式二：标准 Android Studio 工程

在装有 Android Studio 的机器上打开构建：

```bash
cd cicp-jwxt-android
./gradlew assembleRelease
```

## 使用

### 课表结果页

- 课表类查询采用参考 demo 的「唐韵书声」样式：分层背景、固定日期表头、节次与课程一体滚动、彩色描边课程块、底部周次选择器及「回到本周」。保留学校现有的 12 节时间表。
- 左右拖动可预览相邻周的真实缓存；没有缓存时保留当前课表并提示，不会把旧课表当作新周显示。查询新周数据仍使用「查询参数」浮窗。
- 顶栏提供列表切换、刷新与返回首页；课程详情、复制信息以及四个浮窗继续保留。成绩等非课表查询沿用原有显示方式。
- 默认皮肤图片与动图来自用户提供的 `课表demo.html`，保存在 `jwxt-webapp/schedule-assets/`，随 APK 离线打包；未引入 demo 的演示课程、增删课程功能及完整皮肤商城。
- 学期周次可在设置中调整；缓存和今日课程提醒会按当前账户、当前学期过滤。
- 回归检查：`node --test tests/schedule.test.cjs`（需要 Node.js）。

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
