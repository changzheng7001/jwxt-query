# 教务系统接口详细文档

> 本文档基于对中央司法警官学院教务系统（强智科技）的实际抓包与实测整理，覆盖脚本 v3.0 全部查询类型。
> 所有请求需携带登录后的 Cookie（JSESSIONID）。

## 登录接口

### 1. 获取加密密钥

- URL: `POST https://jwxt.cicp.edu.cn/Logon.do?method=logon&flag=sess`
- 响应：`scode#sxh`（scode=随机串，sxh=数字序列）

### 2. 加密算法

```
code = 账号 + "%%%" + 密码
对 code 前20个字符，每个字符后插入 scode 的前 sxh[i] 个字符，scode 逐段消耗
```

### 3. 提交登录

- URL: `POST https://jwxt.cicp.edu.cn/Logon.do?method=logon`
- 参数：`userAccount=账号`、`userPassword=`（空）、`encoded=加密串`
- 成功：跳转 `/jsxsd/framework/xsMainV.htmlx`

### 会话保持与自动重登

脚本统一通过 `JwxtSession.request(method, url)` 发请求。检测到会话失效（状态码401/403、URL含Logon.do、页面title=登录、含"系统登录+用户名"等）时，自动用已保存的账号密码重新登录并重试一次。

## 课表查询（共用参数结构）

四类课表共用以下参数（POST form）：

| 参数名 | 说明 | 示例值 |
|--------|------|--------|
| xnxqh | 学年学期 | 2026-2027-1 |
| kbjcmsid | 时间模式ID | 65C2A7B09C5742189505942AA120C0D7 |
| zc1 / zc2 | 起始/结束周次（留空=全部） | 3 |
| skxq1 / skxq2 | 起始/结束星期（1-7） | 3 |
| jc1 / jc2 | 起始/结束节次（01-12） | 05 |

### 教师课表

- URL: `POST /jsxsd/kbcx/kbxx_teacher_ifr`
- 专属参数：`skyx`（院系，留空）、`jszc`（职称，留空）、`skjsid`（隐藏，留空）、`skjs`（教师姓名，模糊）
- 注意：按姓名模糊匹配，同名教师结果合并；脚本会提示"同名冲突"

### 教室课表

- URL: `POST /jsxsd/kbcx/kbxx_classroom_ifr`
- 专属参数：`xqid`（校区，1=本部）、`jzwid`（建筑物ID）、`skjs`（教室名称）
- 注意：教室名不带楼名前缀，用 `3-307` 而非 `三教-3-307`

### 班级课表

- URL: `POST /jsxsd/kbcx/kbxx_xzb_ifr`
- 专属参数：`skbj`（班级名称，如 `心理矫治班24`）
- 无需先查班级ID，直接传班级名即可

### 课程课表（全校开课班次）

- URL: `POST /jsxsd/kbcx/kbxx_kc_ifr`
- 专属参数：`kcmc`（课程名称，如 `罪犯改造心理学`）
- 返回该校所有开课班次（含不同班级/教师/教室/周次）

### 课表表格结构（旧表格）

- 第一行表头：第1列=名称，之后每7列一组（0102/0304/0506/0708/0910/11/12），共7天×7节次=49列
- 单元格 = `div.kbcontent1`，多行文本，两种行序：
  - 教师课表：课程名 → 班级 → 教师 → (周次) → 教室
  - 教室/班级课表：课程名 → 教师 → (周次) → 班级 → 教室
- 课程名可能带备注如 `(分组01)`；周次行形如 `(1-17周)`、`(1-9,16-17周)`
- 教室行：`3-307（25心理矫治班）`、`3C5(公共教室）`、`射击馆`、`思政教育及语音教学多功能室（3C1）`
- 一个单元格可能含多门课（每门课5行一组）

### 本人课表（新界面）

- URL: `GET /jsxsd/framework/mainV_index_loadkb.htmlx`
- 参数：`rq`（当周周一日期，非周次）、`sjmsValue`（kbjcmsid）、`xnxqid`、`xswk=false`
- 行=大节（第一大节(01,02小节)08:00-09:40 …），列=星期一~星期日，底部有备注行
- 单元格 = `span.box`（短视图）+ `div.item-box`（详情视图）成对出现
- 课程名取 item-box 内第一个 `<p>`；教师取 box 中"教师：XXX"；节次取 `.tch-name` 中"01~02~03节"；教室取 `img[src*=item1.png]` 所在 span；周次取 `img[src*=item3.png]` 所在 span
- **跨大节课程重复渲染**，需按（星期、课程、教师、教室、节次）去重

## 成绩查询（A1）

- URL: `POST /jsxsd/kscj/cjcx_list`
- 参数：`kksj`（学期，留空=全部）、`kcxz`（课程性质）、`kcsx`、`kcmc`（课程名筛选）、`xsfs=max`、`zylx=0`、`pageIndex`
- 响应：表格（学年学期/课程名称/课程性质/学分/成绩/绩点/补考重考标记等）

## 绩点计算与学业预警（A2）

- 基于全部成绩计算（脚本内实现，无独立接口）：
  - 数字分数→绩点：90+=4.0、85+=3.7、82+=3.3、78+=3.0、75+=2.7、72+=2.3、68+=2.0、64+=1.5、60+=1.0、<60=0
  - 等级制→绩点：优=4.5、良=3.5、中=2.5、及格=1.5、不及格=0
  - 输出：GPA（学分加权）、加权平均分、已修/总学分、挂科清单

## 学习完成情况（A3）

- 首页：`GET /jsxsd/xxwcqk/xxwcqk_idxOntx.do`，取 hidden 字段 `ndzydm`（属性顺序为 `name="ndzydm" id="ndzydm" value="..."`，正则用 `name="ndzydm"[^>]*value=`）
- 数据页：`GET /jsxsd/xxwcqk/xxwcqkOnkctx.do?ndzydm=<值>`
- 目标表格：**第2个 table**（5列结构：课程体系(属性) | 要求学分 | 已修学分 | 正修读学分 | 还需学分）
- 体系名与属性在同一格（如 `专业选修体系(必修)`），解析时拆分

## 考试安排（B1）

- 期末考试：`POST /jsxsd/xsks/xsksap_list`，参数 `xqlbmc=期末`、`xnxqid`
- 随堂考试：`POST /jsxsd/xsks/xsstk_list`，参数 `xqlbmc=平时考察|提前期末`、`xnxqid`、`pageIndex`
- 无数据时表格显示"未查询到数据"，解析需过滤

## 学籍卡片（C1）

- URL: `GET /jsxsd/grxx/xsxx`
- 主表结构：行2头部含院系/专业/学制/班级/学号，行3~10 键值对基本信息（姓名/性别/出生日期/民族/身份证号等），行46~49 入学信息（入学日期/入学考号/学习层次等）
- 解析用白名单区段提取（姓名、学号、出生日期、身份证号等关键字段）

## 选课（E1/E2）

- 选课轮次：`GET /jsxsd/xsxk/xklc_list`，返回当前开放轮次表格（无开放轮次时为空表）
- 选课结果：`POST /jsxsd/xkgl/loadXsxkjgList`，参数 `xnxqid`、`pageIndex`、`pageSize`，返回已选课程列表（课程名/编号/教师/学分/性质/考核方式）
- 说明：E3（选课开放监控提醒）依赖豆包定时任务配合周期性调用 `--type elective`，脚本不内嵌

## 教学周历（G1）

- URL: `GET /jsxsd/jxzl/jxzl_query`
- 表格：每行=一周（周次纯数字行 + 周一~周日日期 + 备注），含"周历编制"等说明行需跳过
- 脚本标注当前周

## 运行时配置自动探测

登录后访问 `https://jwxt.cicp.edu.cn/jsxsd/framework/xsMainV_new.htmlx?t1=1`（个人主页），从中解析：

| 配置项 | 来源 |
|--------|------|
| xnxqh | 页面 JS 中 `xnxqid="+"2026-2027-1&xswk=` |
| kbjcmsid | `<li data-value="..." name="kbjcmsid">` 的 data-value |
| 校历周历 | `<select name="week">` 下 `<option value="2026-08-31">第一周</option>` |

## 其他说明

以下旧版路径在本系统**不存在**（访问返回"错误提示页面"），不要使用：
- `/jsxsd/kbcx/kbxx_xszc`
- `/jsxsd/kbcx/kbxx_xs.jsp`
- `/jsxsd/kbcx/kbxx_teacher.htmlx`
- `/jsxsd/xskbcx/xskbcx_cxXsKb.html`

## 注意事项

1. 节次参数为两位数字符串："01"~"12"
2. 星期参数：1=周一 … 7=周日
3. kbjcmsid 每学期通常不变，脚本会自动探测
4. 教学周次按"校历第1周周一"起算（如2026秋季第1周周一=2026-08-31）
5. 教室课表按周查询时 `skxq1/skxq2` 传星期、`zc1/zc2` 传周次，`jc1/jc2` 传节次
