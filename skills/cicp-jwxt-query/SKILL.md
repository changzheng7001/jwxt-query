---
name: cicp-jwxt-query
description: 中央司法警官学院教务系统全能查询工具。用户提供教务系统账号密码后，通过Python脚本直接调用教务系统HTTP接口，快速查询课表（教师/教室/班级/课程/本人）、成绩与绩点、学业进度、考试安排、学籍信息、选课轮次与结果、教学周历等。当用户询问"某老师现在有课吗"、"某教室什么时间空闲"、"查一下我的成绩/绩点"、"我这周有什么课"、"查一下考试安排"、"我的学分进度"、"查班级/课程课表"、"选课什么时候开始"、"教学周历"等教务系统相关问题时使用本Skill。
---

# 中警院教务系统全能查询

通过 Python 脚本直接调用教务系统 HTTP 接口（无需浏览器），支持 13 类查询。
**注：查"空教室/自习室"请走 `cicp-free-room`（极速缓存版），不要用本 skill 的 classroom。**

## 前置条件

- 凭证已配置在 `scripts/credentials.json`，命令**无需带账号密码**。
- 若未配置，命令后加 `--account 学号 --password 密码`。

## 脚本位置

- `scripts/jwxt_query.py` —— 命令行主脚本（已模块化：`jwxt_config`/`jwxt_utils`/`jwxt_parsers`/`jwxt_format`）
- `scripts/webui.py` —— 图形化面板（可选，详情见 [usage.md](references/usage.md)）
- 依赖：`pip install requests beautifulsoup4`

## 查询类型（--type）

| 类型 | 说明 | 参数 |
|------|------|------|
| `teacher` | 教师课表 | `--name 教师姓名` |
| `classroom` | 教室课表 | `--name 教室名称`（如 3-307） |
| `self` | 本人课表 | 无需 `--name` |
| `class` | 班级课表 | `--name 班级名称`（如 心理矫治班24） |
| `course` | 课程课表（全校开课） | `--name 课程名称` |
| `score` | 成绩查询 | `[--semester 学期] [--name 课程筛选]` |
| `gpa` | 绩点与学业预警 | 无 |
| `progress` | 学分进度 | 无 |
| `exam` | 考试安排 | `[--batch 期末/期初/期中/提前期末/平时考察]` |
| `profile` | 学籍卡片 | 无 |
| `elective` | 选课轮次 | 无 |
| `electives` | 选课结果 | 无 |
| `calendar` | 教学周历 | 无 |

## 通用选项

| 选项 | 说明 |
|------|------|
| `--week N` | 周次（如 3），缺省=全部/当前周 |
| `--weekday N` | 星期（1-7，1=周一） |
| `--current` | 查询当前时刻（自动算周/星期/节次） |
| `--json` | JSON 输出 |
| `--semester 2026-2027-1` | 学年学期 |
| `--batch 平时考察` | 考试批次 |

## 高频用法

```bash
python3 scripts/jwxt_query.py --type self              # 我本周课表
python3 scripts/jwxt_query.py --type self --week 3     # 第3周课表
python3 scripts/jwxt_query.py --type score             # 全部成绩
python3 scripts/jwxt_query.py --type gpa               # 绩点/挂科清单
python3 scripts/jwxt_query.py --type exam              # 期末考试安排
python3 scripts/jwxt_query.py --type exam --batch 平时考察
python3 scripts/jwxt_query.py --type profile           # 学籍卡片
python3 scripts/jwxt_query.py --type calendar          # 教学周历
python3 scripts/jwxt_query.py --type teacher --name "代嘉幸" --current   # 老师现在有课吗
```

## 工作流程

1. 判断查询意图 → 选 `--type`（教师/教室/班级/课程/本人课表、成绩、绩点、进度、考试、学籍、选课、周历）。
2. 按需加 `--week`/`--weekday`/`--current`/`--semester` 筛选。
3. 执行脚本，优先 `--json` 便于结构化解析，或直接文本输出。
4. 把结果清晰呈现给用户。

## 注意事项

1. **多教师课程截断**：个人中心课表卡片（`mainV_index_loadkb.htmlx`）的 box 视图会把多教师课程截断为"姓名,.."，导致某周实际教师名显示错误。例如第11周"心理咨询与心理治疗"卡片显示"杜丙立"，实际应为"王晨旭"（杜丙立1-9,16-17周，王晨旭10-15周）。需交叉引用网格课表或首页"我的课程"组件获取正确教师名。
2. **教师搜索联想接口被禁用**：`/jsxsd/kbcx/queryJs` 对学生端返回"系统功能暂未开放"。要获取全校教师列表，需用空参查询 `/jsxsd/kbcx/kbxx_teacher_ifr`（`skjs=`留空、全周），从返回大表第一列提取教师名。详见 api.md。
3. 教室名不带楼名前缀（用 `3-307` 而非 `三教-3-307`）。
4. 同名教师冲突时脚本会提示，需结合课程名/班级人工确认。

## 更多细节（需要时再读）

- 输出格式示例、作息时间表、图形面板、常见问题 → [usage.md](references/usage.md)
- 接口与请求参数详情 → [api.md](references/api.md)
