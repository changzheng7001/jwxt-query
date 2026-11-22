# CICP 教务查询 APP

中央司法警官学院教务系统查询工具，WebView 包装的 Android 应用。

> 当前版本 **v0.9.96（构建序号 V278）** · 文档更新 2026-11-22 · [最新 Release](https://github.com/changzheng7001/jwxt-query/releases)

## 功能

- 课表查询（本人 / 教师 / 教室 / 班级 / 课程）
- 课表页「唐韵书声」皮肤：山水常驻背景、金色画框表头、底部古筝动图，浅色 / 深色共用一套结构只换变量
- 同一格多门课时只画首门并标 `+N`（N 为门数），顶部提示「列表可看全部」
- 成绩与绩点
- 学习进度
- 考试安排
- 选课结果
- 全校教师 / 班级 / 教室浏览
- 本地缓存，无网也能查看
- 沉浸式状态栏（与页面融为一体的透明状态栏，随明暗主题切换）
- 常驻"今日课程"通知（按教学周过滤，点击直达本人课表）
- 暖纸色界面配合亚克力面板，支持浅色 / 深色 / 跟随安卓系统
- 首页四面板双击标题收起贴边，再次双击浮窗标题可还原
- 单列课表仅展示今天，含时间、节次、教师、教室与班级
- 缓存按类别整理，显示份数、估算占用与更新时间
- 全校课程：与全校教师 / 班级 / 教室并排，聚合全校开课信息，可按课程名筛选并直接带出课表
- 官网直达：按「最近一次查询的类型」跳到教务系统对应结果页（个人主页 / 成绩 / 教师 / 教室 / 班级 / 课程），已登录时免二次登录
- 会话过期自动回到 App 登录弹窗，登录成功后回跳原目标页
- 启动直达课表：设置里可选「首页 / 课表」，选课表后冷启动直接进本周课表，不经过首页
- 设置入口为右侧磁贴，点击有跳动反馈后进入；设置页改用系统返回退出
- 刷新有明确反馈：仅在手动点刷新时转圈并提示「正在刷新…／已更新」，读缓存不触发
- 版本标识用 V 序号显示（如 V278），安装包 versionName 随构建递增（当前 0.9.96），versionCode 固定 1000，任意版本可互换覆盖安装

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
│           ├── java/com/cicp/jwxt/                     # 原生层
│           │   ├── MainActivity.java                  # WebView + JS 桥
│           │   ├── InAppOpen.java                     # 官网页内打开与会话注入
│           │   └── CookieWebClient.java               # 子资源请求补 Cookie
│           ├── assets/index.html                       # 前端（主要改这里）
│           └── res/                                    # 布局/样式/图标
├── jwxt-webapp/                  # 前端源（改这里，再同步到两份 assets）
│   ├── index.html                # 页面结构 + 主题变量 + 课表页样式
│   ├── js/                       # 01-foundation / 02-state / 03-parse / 04-query / 05-render / 06-ui
│   ├── ui/app.css                # 统一外观补充（改前先 grep !important 覆盖）
│   ├── ui/experience.js          # 系统主题、首页布局、面板与缓存
│   └── schedule-assets/          # 课表皮肤：山水 bg、表头 head、顶栏 top、古筝动图 bottom
├── apk-source/                    # 反编译打包源（smali + java，apktool 构建用）
├── tests/                         # node 逻辑回归（17 项）
├── .buildtools/                   # apktool.jar + uber-apk-signer.jar
└── README.md / CHANGELOG.md
```

## 维护与代码链说明

- **前端唯一源文件**：日常修改 `jwxt-webapp/index.html`、`js/*.js` 和 `schedule-assets/`。`ui/app.css` 维护统一外观，`ui/experience.js` 维护系统主题、首页布局、面板与缓存展示。
- **同步所有打包目标**：改完 `jwxt-webapp/` 后必须同步到 `apk-source/assets/` 与 `cicp-jwxt-android/app/src/main/assets/` 两份工程，否则打出来的包与网页预览不一致。Linux/macOS 下：

  ```bash
  cp jwxt-webapp/index.html apk-source/assets/index.html
  cp jwxt-webapp/js/*.js   apk-source/assets/js/
  cp jwxt-webapp/ui/*.js jwxt-webapp/ui/app.css apk-source/assets/ui/
  rsync -a --delete jwxt-webapp/schedule-assets/ apk-source/assets/schedule-assets/
  # cicp-jwxt-android/app/src/main/assets/ 同样复制一份
  ```

- **Android 原生改动**：标准工程改 `cicp-jwxt-android/`；反编译打包改 `apk-source/`，并保持 Java/Smali 行为一致。`apk-source/java/` 不参与打包，改完必须重跑 `javac → d8 → baksmali` 回填 `smali_classes2/`。
- **版本号约定**：设置页版本标识写 `V序号`，同时改 `index.html` 的 `vX.Y.Z · Vxxx` 与 `apk-source/apktool.yml` 的 `versionName`；`versionCode` 固定 `1000`，保证任意版本可互相覆盖安装、出问题能立刻回退。
- **视觉改前先 grep `ui/app.css`**：历史上多次「改了 `index.html` 却不生效」都是这里残留的 `!important` 覆盖造成的。

## 如何构建

### 方式一：apktool 快速打包（日常迭代，无需 Android SDK）

```bash
java -jar .buildtools/apktool.jar b apk-source -o /tmp/out.apk
java -jar .buildtools/uber-apk-signer.jar --apks /tmp/out.apk \
  --ks <你的 keystore>.jks --ksAlias <alias> --ksPass <pass> --ksKeyPass <pass> --out /tmp/signed
# 产物：/tmp/signed/out-aligned-signed.apk
```

校验：

```bash
aapt dump badging /tmp/signed/*-aligned-signed.apk | head -1   # 版本号是否与包内 appVNum 一致
apksigner verify --print-certs /tmp/signed/*-aligned-signed.apk   # 签名证书 SHA-256
```

`apktool.yml` 的 `versionCode` 固定 1000，不要改。

### 方式二：标准 Android Studio 工程

在装有 Android Studio 的机器上打开构建：

```bash
cd cicp-jwxt-android
./gradlew assembleRelease
```

## 使用

### 课表结果页

- 课表类查询采用参考 demo 的「唐韵书声」样式：分层背景、固定日期表头、节次与课程一体滚动、彩色描边课程块、底部周次选择器及「回到本周」。保留学校现有的 12 节时间表。
- 左右拖动可预览相邻周的真实缓存；没有缓存时直接切到该周的空课表并提示「暂无缓存」，不会把旧课表当作新周显示。空课表比停在上一周更直观，避免误把旧数据当成新周。查询新周数据仍使用「查询参数」浮窗。
- 顶栏提供“只看今天 / 周课表”切换、刷新与返回首页；单列模式仅展示当前学期今天的课程，切换时会回到本周。课程格的名称每行最多四个字符。课程详情、复制信息以及四个浮窗继续保留。
- 默认皮肤图片与动图来自用户提供的 `课表demo.html`，保存在 `jwxt-webapp/schedule-assets/`，随 APK 离线打包；未引入 demo 的演示课程、增删课程功能及完整皮肤商城。
- 学期周次可在设置中调整；缓存和今日课程提醒会按当前账户、当前学期过滤。
- 回归检查：`node --test tests/*.test.cjs`（需要 Node.js）。

### 外观与面板

- 设置中的外观分为“自动 / 浅色 / 深色”。自动模式优先读取安卓原生 `uiMode`，系统切换和应用回到前台时同步刷新；网页预览使用 `prefers-color-scheme`。
- 首页双击面板标题收起到边缘，点击边缘标签展开，双击展开后的标题可还原到首页；页尾也可一键还原全部面板。触屏支持双击标题。
- 四个浮窗统一按屏幕可用高度排布，较长内容在窗内滚动；返回首页清除结果页坐标，保留用户主动收起的面板。
- 首页 SVG 书页持续翻动，在结果页、设置页和应用后台暂停；系统开启“减少动态效果”时停止动画。
- 缓存界面只列出当前账户的个人数据与公共缓存，大小按 localStorage 字符串估算。旧缓存不会因界面升级而删除。

1. 安装 APK
2. 打开 App，默认缓存模式，无网也能看之前查过的数据
3. 需要更新数据时点右上角"登录"，输入学号密码
4. 点"查询"看缓存，点"刷新"拉新数据

## 待解决问题

以下为截至 V278 的状态，按影响排序。欢迎提 Issue 指认或补充。

### 1. 班级查询按前缀匹配，会一次命中多个班

教务系统的 `skbj` 参数是**前缀匹配**：传「2026级」会命中 3 个班，同格课程数暴涨到 52~76 门。

- 现状已做的兜底：查询结果按所选班名精筛；同格只画首门并标 `+N`；顶部提示「列表可看全部」
- 未做的根治：查询阶段就弹出班名列表让用户选班，而不是先拉回一大堆再筛

### 2. 底部动图体积 625KB

课表页古筝动图为保持肉眼清晰度，保留了原始 750×440 / 80 帧，重新编码后 625KB，使安装包从 416KB 涨到约 1MB。

- 若要压体积，可降到 6fps 省约 200KB，代价是动作不如现在顺
- 当前取舍：清晰度优先

### 3. 考试安排 / 选课结果没有真实数据可验

教务系统对该账号两个学期均返回「未查询到数据」，内容行渲染只能用合成样本验证，真实数据出现后需重抓复核。

### 4. 教师名解析仍是启发式

课程课表的格子会把「班级」和「教师」排成相邻行，个别课程还会粘成一行（如 `矫正教育一班26闵奎元`）。

- 已做：解析前若全校教师名单缺失，自动空参拉一次 `kbxx_teacher_ifr`，拿到全校教师集合后做最长优先精确匹配
- 仍可能出错：复姓、外聘标注、多教师混排；此时退回百家姓规则，识别不出的保留原文并标「待确认」

### 5. 用户自定义注入

读取 `Android/data/com.cicp.jwxt/files/jwxt-user.css` 与 `jwxt-user.js`，打开官网时注入，改完重开即生效。自定义 JS 用 `try/catch` 包一层，报错只在控制台告警。

### 6. versionCode 固定带来的取舍

为让任意版本可互相覆盖安装，`versionCode` 固定 `1000`，版本高低只能看设置页的 V 序号。副作用是系统里看不出升级顺序，也无法用版本号做灰度或强制更新判断。属于侧载分发场景下的有意取舍，暂不改。

### 7. 打包链路没有自动化（无 CI）

发版靠手动跑脚本：同步 assets → apktool 打包 → uber-apk-signer 签名 → aapt 校验版本 → apksigner 校验证书 → 解包核对 md5。仓库里只有源码和 `.buildtools/` 两个 jar，没有流水线，换台机器要重搭环境。

### 8. 回归样本不入库

`tests/fixtures/` 下的教务页面样本含真实师生姓名、学号与本人在读成绩，因此不提交到仓库（仓库是公开的）。本地跑 `node tests/*.test.cjs` 需要自行准备样本，逻辑测试本身含不依赖样本的用例。

## 时间线

最近一轮迭代集中在「官网免登录跳转」和「手机端适配」，主要节点：

| 时间 | 版本 | 内容 |
|---|---|---|
| 2026-11-10 | v145–v147 | 清理旧版页面死样式；新增 App 内打开官网并注入会话，前两版因取错 Cookie 来源失败 |
| 2026-11-11 | v150–v155 | 加诊断输出定位问题：Cookie 正常、登录页是根地址导致；改为按模块真实地址跳转，改用真实地址加载 + 拦截器带会话 |
| 2026-11-11 | v156–v160 | 打开方式可选「应用内 / 外部浏览器」；实测各模块后缀差异（`.jsp` 走模板、`.htmlx` 走完整框架、无后缀走 Action），最终定为 `.jsp` 内容页 |
| 2026-11-11 | v161–v166 | 启动直达课表并消除闪屏；版本显示改为 V 序号（内部 versionName 保持 0.9.8）；刷新按钮加转圈反馈；versionCode 固定 1000 便于自由回退 |
| 2026-11-11 | v167–v173 | 全校课程列表并入「全校列表」并改为一排四列；统一班级/教室/课程列表配色；课程课表「选择」弹窗；按格子顺序重写解析，修掉教师被并进班级 |
| 2026-11-11 | v174–v180 | 官网跳转对应关系整理成表；教务页上下留白改为注入页面内部生效；移除底部导航栏，设置改为右侧磁贴；设置页改用系统返回 |
| 2026-11-12 | v181–v185 | 刷新反馈只在手动刷新触发；预留用户自定义 CSS/JS 注入（暂未启用）；手机端适配放弃整页 zoom，改为主文档注入 + 资源透传，修掉页面点不动 |
| 2026-11-12 | v186–v187 | 会话过期不再弹自建提示页，直接复用「未登录即弹登录框」的流程，登录成功后回跳原目标页 |
| 2026-11-12 | v188 | 补齐构建链缺失的两个类；官网手机适配补 viewport 并覆盖 iframe 子页；官网跳转带查询条件回填；教师名解析改为自动预拉全校教师名单。**该版打包源与发布版漂移，点登录闪退、底部浮条露出透明区，已废弃** |
| 2026-11-12 | v189 | 打包源对齐 V187 发布版：补 `networkSecurityConfig` 与 `res/xml` 配置、`public.xml` 补全 5 条声明、`targetSdkVersion` 回到 35 恢复 edge-to-edge；反编译校验后与 V187 仅差本次有意修改的文件 |
| 2026-11-13 → 11-20 | v190–v272 | 课表「唐韵书声」皮肤落地与多轮打磨、班级/教室/教师/课程课表查询链路、深色主题、缓存按类别分组、磁贴与面板交互。这一段逐版细节未逐条留档 |
| 2026-11-20 | v273–v274 | 解析扩样本（班级 1691 / 教师 1721 / 教室 1689 条全部 0 空课程名、0 空教师名）；合并键并入 `classes`，同门课不同班不再被压成一条；班级查询按班名精筛 |
| 2026-11-20 | v275–v276 | 表头一度被误放到顶栏（用户指出后回退）；清掉 `app.css` 三处 `!important` 覆盖——历次「表头看不见」的真凶在这里；底部动图恢复 750×440 原尺寸并贴齐右边缘 |
| 2026-11-20 | v277 | 同格多课只画首门 + `+N` 角标与 28 字提示条；表头与顶栏统一为「同一套结构只换变量」；删除深色专用表头图 |
| 2026-11-22 | v278 | 表头恢复原始 `tangyun-head.png` 无损金框图；深色压暗改用 `--head-scrim` 变量（与顶栏同值 0.62）；修 `background-image: transparent` 非法值导致表头图不渲染的 bug |

## 版本

当前版本：**v0.9.96（构建序号 V278）**，2026-11-22 更新（测试版；1.0 为正式版）

- 对外展示用 `V序号`（设置页右上角），源码同步写 `vX.Y.Z · Vxxx`
- 安装包 `versionName` 随构建递增（当前 `0.9.96`），`versionCode` 固定 `1000`，新老构建可互相覆盖安装，方便回退验证
- 最新构建在 [Releases](https://github.com/changzheng7001/jwxt-query/releases) 页面，APK 作为 Release 附件分发，不进 git

## 开发说明

本项目主要由 AI 智能体协作开发完成，各阶段接手的工具如下：

| 阶段 | 时间 | 接手方 | 主要工作 |
|---|---|---|---|
| 早期 | — | [豆包工作](https://www.doubao.com) | 初版界面与打包链路 |
| v0.9.8 | 2026-10 | Codex | Claude 暖纸色风格界面 |
| v145–v189 | 2026-11-10 → 11-12 | Amoo（STEPX Neo 内置助手） | 官网免登录跳转、手机端适配、打包源对齐 |
| **v190 起** | **2026-11-13 至今** | **豆包搭子工作模式（Doubao Agent）** | 课表「唐韵书声」皮肤、多类型课表、解析重构、深浅主题统一、每轮出包交付 |

**v190 之后固定使用的工具链**（后续沿用）：

| 环节 | 工具 |
|---|---|
| 任务编排与代码修改 | 豆包搭子工作模式（Doubao Agent，读写工程源码） |
| 打包 / 签名 | `apktool`（`.buildtools/apktool.jar`）+ `uber-apk-signer`（zipalign + 自签名） |
| 包校验 | Android SDK build-tools 的 `aapt dump badging`、`apksigner verify --print-certs` |
| 视觉回归 | Playwright + 无头 Chromium，注入 mock `window.Android.httpRequest` 喂真实页面样本，深浅两套截图 |
| 像素级比对 | Python + Pillow，按 device px 采样，替代肉眼看缩略图 |
| 逻辑回归 | `node tests/schedule.test.cjs`、`node tests/experience.test.cjs`（共 17 项） |
| 发布 | 本机 `gh` CLI（clone → commit → push，Release 附件上传 APK） |

### 这套流程带来的便利

- **端到端闭环**：改源码 → 同步两份 assets → 打包 → 签名 → aapt/apksigner 校验 → 解包 md5 核对 → 交付，全在对话里完成
- **真机即测**：交付一张 APK 卡片，用户装完回一张截图就能继续定位，反馈链路很短
- **不依赖本地环境**：云侧完成打包与签名，无需本机装 Android Studio
- **能读回执自证**：无法直接看界面时，用无头浏览器截图和像素采样替代猜测；强断言不靠肉眼
- **逐版可回退**：versionCode 固定 1000，任何一版都能直接覆盖安装，出问题可立刻回到上一版
- **改动可追溯**：README 与 CHANGELOG 同步记录时间线，每轮出包都核对包内文件与源码逐字节一致

## 说明

- 本项目仅供学习交流使用
- 数据来自学校教务系统，如有问题请联系学校
- 本项目遵循 MIT 许可证，详见 [LICENSE](LICENSE)
