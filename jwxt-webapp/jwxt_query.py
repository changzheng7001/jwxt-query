#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
中央司法警官学院教务系统查询工具 v3.0
通过HTTP请求直接调用教务系统接口，无需浏览器操作。

v3.0 新增（基于教务系统功能全景研究）：
1. 成绩查询（--type score）：按学期查成绩，含绩点
2. 绩点计算与学业预警（--type gpa）：GPA/加权均分/挂科标注
3. 学习完成情况（--type progress）：按培养方案看学分进度
4. 考试安排查询（--type exam）：期末/随堂考试，含考场座位
5. 学籍卡片查询（--type profile）：一键获取完整学籍信息
6. 班级课表查询（--type class）：按班级名查课表
7. 课程课表查询（--type course）：按课程名查全校开课
8. 选课轮次查询（--type elective）：选课开放时间
9. 选课结果查询（--type electives）：当前学期选课结果
10. 教学周历查询（--type calendar）：学期周历/假期
11. 统一查询入口（--type 一个参数选全部功能）
12. 会话保持与自动重登（登录失效自动重新登录）

v2.0 已有：
- 教师课表（--type teacher）
- 教室课表（--type classroom）
- 学生本人课表（--type self）
- 当前时刻查询（--current）
- 运行时自动探测学期/节次模式/校历
"""

import requests
from bs4 import BeautifulSoup
import re
import json
import sys
import os
import argparse
from datetime import datetime, timedelta

# ========== 配置 ==========
# 以下为兜底默认值；登录后会从教务系统个人主页自动探测并覆盖（见 refresh_runtime_config）。
CONFIG = {
    'base_url': 'https://jwxt.cicp.edu.cn',
    'xnxqh': '2026-2027-1',            # 学年学期ID
    'kbjcmsid': '65C2A7B09C5742189505942AA120C0D7',  # 节次模式ID
    'semester_start': '2026-08-31',    # 校历第1周周一（用于周次计算与周→日期换算）
}

# 作息时间表
SCHEDULE = [
    {'name': '0102', 'label': '第1-2节', 'start': '08:00', 'end': '09:40'},
    {'name': '0304', 'label': '第3-4节', 'start': '10:00', 'end': '11:40'},
    {'name': '0506', 'label': '第5-6节', 'start': '14:30', 'end': '16:10'},
    {'name': '0708', 'label': '第7-8节', 'start': '16:20', 'end': '18:00'},
    {'name': '0910', 'label': '第9-10节', 'start': '19:00', 'end': '20:40'},
    {'name': '11', 'label': '第11节', 'start': '21:00', 'end': '21:35'},
    {'name': '12', 'label': '第12节', 'start': '21:55', 'end': '22:40'},
]

WEEK_DAYS = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日']

# 从校历下拉框自动探测到的周→周一日期映射，如 {1: '2026-08-31', 2: '2026-09-07', ...}
WEEK_DATES = {}

_CN_NUM = {'一': 1, '二': 2, '三': 3, '四': 4, '五': 5, '六': 6, '七': 7, '八': 8, '九': 9,
           '十': 10, '十一': 11, '十二': 12, '十三': 13, '十四': 14, '十五': 15, '十六': 16,
           '十七': 17, '十八': 18, '十九': 19, '二十': 20}

# 学分绩点对应表（教务系统标准）
GRADE_POINTS = {
    '优秀': 4.5, '优': 4.5,
    '良好': 3.5, '良': 3.5,
    '中等': 2.5, '中': 2.5,
    '及格': 1.5, '合格': 1.5, '通过': 1.5,
    '不及格': 0, '不合格': 0, '未通过': 0,
}


def grade_to_point(grade):
    """成绩文本/数字 → 绩点"""
    if grade is None:
        return 0.0
    grade = str(grade).strip()
    if not grade:
        return 0.0
    if grade in GRADE_POINTS:
        return GRADE_POINTS[grade]
    try:
        score = float(grade)
    except ValueError:
        return 0.0
    if score >= 90:
        return 4.0
    elif score >= 85:
        return 3.7
    elif score >= 82:
        return 3.3
    elif score >= 78:
        return 3.0
    elif score >= 75:
        return 2.7
    elif score >= 72:
        return 2.3
    elif score >= 68:
        return 2.0
    elif score >= 64:
        return 1.5
    elif score >= 60:
        return 1.0
    else:
        return 0.0


def is_pass(grade):
    """判断是否及格"""
    if grade is None:
        return False
    grade = str(grade).strip()
    if grade in ('不及格', '不合格', '未通过'):
        return False
    if grade in ('优秀', '优', '良好', '良', '中等', '中', '及格', '合格', '通过'):
        return True
    try:
        return float(grade) >= 60
    except ValueError:
        return False


# ========== 密码加密 ==========
def encode_password(account, password, scode, sxh):
    """
    强智教务系统密码加密算法
    code = account + "%%%" + password
    对前20个字符，每个字符后插入 scode 的前 sxh[i] 个字符
    """
    code = account + "%%%" + password
    encoded = ""
    scode_remaining = scode
    for i in range(len(code)):
        if i < 20 and i < len(sxh):
            try:
                n = int(sxh[i])
            except (ValueError, IndexError):
                n = 0
            encoded += code[i] + scode_remaining[:n]
            scode_remaining = scode_remaining[n:]
        else:
            encoded += code[i:]
            break
    return encoded


# ========== 登录 ==========
class JwxtSession:
    def __init__(self, account='', password=''):
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            'Referer': CONFIG['base_url'] + '/',
        })
        self.logged_in = False
        self.account = account
        self.password = password

    def login(self, account, password):
        """登录教务系统"""
        self.account = account
        self.password = password
        # 1. 获取加密密钥
        try:
            resp = self.session.post(
                CONFIG['base_url'] + '/Logon.do?method=logon&flag=sess',
                timeout=10
            )
            data = resp.text.strip()
            if '#' not in data:
                return False, f"获取加密密钥失败: {data[:100]}"
            scode, sxh = data.split('#', 1)
        except Exception as e:
            return False, f"获取加密密钥异常: {e}"

        # 2. 加密密码
        encoded = encode_password(account, password, scode, sxh)

        # 3. 提交登录
        try:
            resp = self.session.post(
                CONFIG['base_url'] + '/Logon.do?method=logon',
                data={
                    'userAccount': account,
                    'userPassword': '',
                    'encoded': encoded,
                },
                timeout=10,
                allow_redirects=True
            )
            # 检查是否登录成功（跳转到主页）
            if 'xsMainV' in resp.url or '个人中心' in resp.text or '欢迎' in resp.text:
                self.logged_in = True
                return True, "登录成功"
            # 检查是否有错误信息
            if '密码' in resp.text and '错误' in resp.text:
                return False, "账号或密码错误"
            if '验证码' in resp.text:
                return False, "需要验证码"
            # 可能登录成功但页面不同
            if resp.status_code == 200 and len(resp.text) > 1000:
                self.logged_in = True
                return True, "登录成功（已进入系统）"
            return False, f"登录失败，状态码: {resp.status_code}"
        except Exception as e:
            return False, f"登录异常: {e}"

    def _check_login(self):
        if not self.logged_in:
            raise Exception("未登录，请先调用 login()")

    # ========== 会话保持与自动重登（H3） ==========
    def request(self, method, url, **kwargs):
        """
        带自动重登的请求。若会话失效（跳转登录页/权限不足），自动重新登录后重试一次。
        :param method: 'GET' / 'POST'
        :param url: 完整URL或相对路径
        """
        self._check_login()
        if not url.startswith('http'):
            url = CONFIG['base_url'] + url
        kwargs.setdefault('timeout', 15)
        resp = self.session.request(method, url, **kwargs)

        # 检测会话失效：跳转登录页或提示登录
        if self._is_session_expired(resp):
            # 自动重新登录
            if self.account and self.password:
                self.login(self.account, self.password)
                resp = self.session.request(method, url, **kwargs)
        return resp

    def _is_session_expired(self, resp):
        """判断响应是否表示会话失效"""
        if resp.status_code in (401, 403):
            return True
        # 跳转到登录页（URL特征）或页面提示登录
        if 'Logon.do' in resp.url or 'login' in resp.url.lower():
            return True
        text = resp.text[:3000]
        if ('错误提示页面' in text and ('重新登录' in text or '登录' in text
                                        or '会话' in text or '超时' in text)):
            return True
        if '系统登录' in text and '用户名' in text:
            return True
        # 登录页特征（title=登录 + 用户名/密码框 + Logon.do 表单/脚本）
        if '<title>登录</title>' in text or '<title> 登录</title>' in text:
            return True
        if 'Logon.do' in text and '用户名' in text and '密码' in text:
            return True
        return False

    # ========== 运行时配置自动探测 ==========
    def refresh_runtime_config(self):
        """
        登录后从个人主页自动探测：
        - xnxqh（学年学期ID）
        - kbjcmsid（节次模式ID）
        - 校历周历（第1~N周的周一日期，写入 WEEK_DATES）
        探测失败时静默保留 CONFIG 默认值。
        """
        global WEEK_DATES
        try:
            resp = self.session.get(
                CONFIG['base_url'] + '/jsxsd/framework/xsMainV_new.htmlx?t1=1',
                timeout=10
            )
            page = resp.text

            # 学年学期ID：se() 中 &xnxqid="+"2026-2027-1&xswk=...
            m = re.search(r'xnxqid="\+"([^"&]+)', page)
            if m and m.group(1):
                CONFIG['xnxqh'] = m.group(1)

            # 节次模式ID：<li data-value="..." name="kbjcmsid">（属性顺序两种都兼容）
            m = re.search(r'name="kbjcmsid"[^>]*data-value="([^"]+)"|data-value="([^"]+)"[^>]*name="kbjcmsid"', page)
            if m:
                v = m.group(1) or m.group(2)
                if v:
                    CONFIG['kbjcmsid'] = v

            # 周历：<select name="week"> 下的 <option value="2026-08-31">第一周</option>
            dates = {}
            for m in re.finditer(r'<option\s+value="(\d{4}-\d{2}-\d{2})"[^>]*>\s*第([^<\s]+)周', page):
                try:
                    w = _CN_NUM.get(m.group(2))
                    if w:
                        dates[w] = m.group(1)
                except Exception:
                    continue
            if dates:
                WEEK_DATES.clear()
                WEEK_DATES.update(dates)
                first_monday = WEEK_DATES.get(1)
                if first_monday:
                    CONFIG['semester_start'] = first_monday
        except Exception:
            pass  # 探测失败回退默认配置

    # ========== 教师课表查询 ==========
    def query_teacher_schedule(self, teacher_name, week='', weekday='', jc1='', jc2=''):
        """
        查询教师课表
        :param teacher_name: 教师姓名
        :param week: 周次（数字字符串，如'3'）
        :param weekday: 星期（1-7）
        :param jc1: 起始节次（01-12）
        :param jc2: 结束节次（01-12）
        :return: 课程列表
        """
        self._check_login()
        data = {
            'xnxqh': CONFIG['xnxqh'],
            'kbjcmsid': CONFIG['kbjcmsid'],
            'skyx': '',
            'jszc': '',
            'skjsid': '',
            'skjs': teacher_name,
            'zc1': week,
            'zc2': week,
            'skxq1': weekday,
            'skxq2': weekday,
            'jc1': jc1,
            'jc2': jc2,
        }
        try:
            resp = self.request(
                'POST', '/jsxsd/kbcx/kbxx_teacher_ifr', data=data
            )
            return self._parse_schedule_html(resp.text, 'teacher')
        except Exception as e:
            return {'error': str(e), 'courses': []}

    # ========== 教室课表查询 ==========
    def query_classroom_schedule(self, campus='1', building='', room_name='',
                                   week='', weekday='', jc1='', jc2=''):
        """
        查询教室课表
        :param campus: 校区ID（1=本部，2=二校区）
        :param building: 建筑物ID
        :param room_name: 教室名称
        :param week: 周次
        :param weekday: 星期（1-7）
        :param jc1: 起始节次
        :param jc2: 结束节次
        :return: 课程列表
        """
        self._check_login()
        data = {
            'xnxqh': CONFIG['xnxqh'],
            'kbjcmsid': CONFIG['kbjcmsid'],
            'skyx': '',
            'xqid': campus,
            'jzwid': building,
            'jxlvalue': '',
            'skjsid': '',
            'skjs': room_name,
            'jsid': '',
            'zc1': week,
            'zc2': week,
            'skxq1': weekday,
            'skxq2': weekday,
            'jc1': jc1,
            'jc2': jc2,
        }
        try:
            resp = self.request(
                'POST', '/jsxsd/kbcx/kbxx_classroom_ifr', data=data
            )
            return self._parse_schedule_html(resp.text, 'classroom')
        except Exception as e:
            return {'error': str(e), 'courses': []}

    # ========== 学生本人课表查询 ==========
    def query_self_schedule(self, week='', weekday='', jc1='', jc2=''):
        """
        查询登录学生本人的课表（按周加载，取自个人主页"课表"模块）。
        :param week: 周次（数字，如'3'），不填则取当前周
        :param weekday: 星期（1-7），不填为全部
        :param jc1: 起始节次（01-12）
        :param jc2: 结束节次（01-12）
        :return: {'courses': [...], 'count': n, 'remarks': [...]}
        """
        self._check_login()
        if not week:
            week = str(get_current_week())
        rq = week_monday(week)  # 周次 → 该周周一日期
        params = {
            'rq': rq,
            'sjmsValue': CONFIG['kbjcmsid'],
            'xnxqid': CONFIG['xnxqh'],
            'xswk': 'false',
        }
        try:
            resp = self.request(
                'GET', '/jsxsd/framework/mainV_index_loadkb.htmlx', params=params
            )
            return self._parse_student_schedule_html(resp.text, weekday=weekday,
                                                     jc1=jc1, jc2=jc2, week=week)
        except Exception as e:
            return {'error': str(e), 'courses': [], 'remarks': []}

    # ========== 班级课表查询（D1） ==========
    def query_class_schedule(self, class_name, week='', weekday='', jc1='', jc2=''):
        """
        查询班级课表（按班级名，如"心理矫治班24"）。
        :param class_name: 班级名称
        :param week: 周次
        :param weekday: 星期（1-7）
        :return: 课程列表
        """
        self._check_login()
        data = {
            'xnxqh': CONFIG['xnxqh'],
            'kbjcmsid': CONFIG['kbjcmsid'],
            'skyx': '',
            'sknj': '',
            'skzy': '',
            'skbjid': '',
            'skbj': class_name,
            'zc1': week,
            'zc2': week,
            'skxq1': weekday,
            'skxq2': weekday,
            'jc1': jc1,
            'jc2': jc2,
        }
        try:
            resp = self.request(
                'POST', '/jsxsd/kbcx/kbxx_xzb_ifr', data=data
            )
            return self._parse_schedule_html(resp.text, 'class')
        except Exception as e:
            return {'error': str(e), 'courses': []}

    # ========== 课程课表查询（D2） ==========
    def query_course_schedule(self, course_name, week='', weekday='', jc1='', jc2=''):
        """
        查询课程课表（按课程名，如"罪犯改造心理学"），返回所有开课班次。
        :param course_name: 课程名称
        :param week: 周次
        :param weekday: 星期（1-7）
        :return: 课程列表
        """
        self._check_login()
        data = {
            'xnxqh': CONFIG['xnxqh'],
            'kbjcmsid': CONFIG['kbjcmsid'],
            'skyx': '',
            'kkyx': '',
            'zzdKcSX': '',
            'kcid': '',
            'kcmc': course_name,
            'zc1': week,
            'zc2': week,
            'skxq1': weekday,
            'skxq2': weekday,
            'jc1': jc1,
            'jc2': jc2,
        }
        try:
            resp = self.request(
                'POST', '/jsxsd/kbcx/kbxx_kc_ifr', data=data
            )
            return self._parse_schedule_html(resp.text, 'course')
        except Exception as e:
            return {'error': str(e), 'courses': []}

    # ========== 成绩查询（A1） ==========
    def query_scores(self, semester='', kcxz='', kcmc='', page=1):
        """
        查询成绩列表。
        :param semester: 学年学期ID（如'2026-2027-1'），空=全部学期
        :param kcxz: 课程性质（01必修/02限选/03任选/04公选），空=全部
        :param kcmc: 课程名称筛选，空=全部
        :param page: 页码
        :return: {'courses': [...], 'count': n, 'semester': semester}
        """
        self._check_login()
        data = {
            'kksj': semester or '',
            'kcxz': kcxz or '',
            'kcsx': '',
            'kcmc': kcmc or '',
            'xsfs': 'max',
            'zylx': '0',
            'pageIndex': str(page),
        }
        try:
            resp = self.request('POST', '/jsxsd/kscj/cjcx_list', data=data)
            return self._parse_score_html(resp.text)
        except Exception as e:
            return {'error': str(e), 'courses': [], 'count': 0}

    def _parse_score_html(self, html):
        """解析成绩列表"""
        soup = BeautifulSoup(html, 'html.parser')
        table = soup.find('table')
        if not table:
            return {'error': '未找到成绩表格', 'courses': [], 'count': 0}

        rows = table.find_all('tr')
        if len(rows) < 2:
            return {'error': '未查询到成绩数据', 'courses': [], 'count': 0}

        # 表头
        headers = [h.get_text(strip=True) for h in rows[0].find_all(['th', 'td'])]
        courses = []
        for row in rows[1:]:
            cells = [c.get_text(strip=True) for c in row.find_all('td')]
            if not cells or not cells[0]:
                continue
            course = {}
            for i, h in enumerate(headers):
                if i < len(cells):
                    course[h] = cells[i]
            if '序号' in course and course['序号'] == '未查询到数据':
                continue
            courses.append(course)
        return {'courses': courses, 'count': len(courses)}

    # ========== 绩点计算与学业预警（A2） ==========
    def compute_gpa(self, score_result):
        """
        基于成绩列表计算GPA、加权均分、挂科列表。
        :param score_result: query_scores 的返回结果
        :return: dict，包含 gpa、weighted_avg、passed_credits、failed_courses 等
        """
        courses = score_result.get('courses', [])
        total_credits = 0.0      # 总学分
        total_points = 0.0       # 绩点×学分
        total_scores = 0.0       # 分数×学分（数字成绩）
        scored_credits = 0.0     # 有数字分数的学分
        passed_credits = 0.0     # 已通过学分
        failed = []
        details = []

        for c in courses:
            try:
                credit = float(c.get('学分', 0) or 0)
            except (ValueError, TypeError):
                credit = 0.0
            grade = c.get('成绩', '')
            gpa = grade_to_point(grade)
            passed = is_pass(grade)

            total_credits += credit
            total_points += gpa * credit
            if passed:
                passed_credits += credit

            # 数字分数参与加权均分
            try:
                score = float(grade)
                total_scores += score * credit
                scored_credits += credit
            except (ValueError, TypeError):
                pass

            details.append({
                'semester': c.get('开课学期', ''),
                'code': c.get('课程编号', ''),
                'name': c.get('课程名称', ''),
                'grade': grade,
                'credit': credit,
                'gpa': gpa,
                'passed': passed,
            })
            if not passed:
                failed.append({
                    'semester': c.get('开课学期', ''),
                    'name': c.get('课程名称', ''),
                    'grade': grade,
                    'credit': credit,
                })

        gpa = round(total_points / total_credits, 2) if total_credits else 0
        weighted_avg = round(total_scores / scored_credits, 1) if scored_credits else None

        return {
            'gpa': gpa,
            'weighted_avg': weighted_avg,
            'total_credits': round(total_credits, 1),
            'passed_credits': round(passed_credits, 1),
            'failed_count': len(failed),
            'failed_courses': failed,
            'details': details,
        }

    # ========== 学习完成情况（A3） ==========
    def query_progress(self):
        """
        查询学习完成情况（按培养方案课程体系，显示要求学分/已修/正修读/还需学分）。
        :return: {'items': [...], 'total': n}
        """
        self._check_login()
        try:
            # 先获取默认方案ID
            resp = self.request('GET', '/jsxsd/xxwcqk/xxwcqk_idxOntx.do')
            page = resp.text
            # ndzydm 为隐藏字段，属性顺序不固定
            m = re.search(r'name="ndzydm"[^>]*value="([^"]+)"', page)
            ndzydm = m.group(1) if m else ''
            if not ndzydm:
                return {'error': '未找到培养方案ID', 'items': [], 'total': 0}

            resp = self.request('GET', '/jsxsd/xxwcqk/xxwcqkOnkctx.do',
                                params={'ndzydm': ndzydm})
            soup = BeautifulSoup(resp.text, 'html.parser')

            # 数据在包含"课程体系"表头的表格中（页面可能有多个表格）
            target_table = None
            for table in soup.find_all('table'):
                text = table.get_text()
                if '课程体系' in text and '要求学分' in text:
                    target_table = table
                    break
            if target_table is None:
                return {'error': '未找到完成情况表格', 'items': [], 'total': 0}

            rows = target_table.find_all('tr')
            items = []
            for row in rows:
                cells = [c.get_text(strip=True) for c in row.find_all(['td', 'th'])]
                # 5列结构：课程体系(属性) | 要求学分 | 已修学分 | 正修读学分 | 还需学分
                if len(cells) >= 5 and '课程体系' not in cells[0] and cells[0]:
                    # 拆出体系名和属性（如"专业选修体系(必修)" → system=专业选修体系, attr=必修）
                    m_sys = re.match(r'^(.*?)\(([^)]*)\)$', cells[0])
                    items.append({
                        'system': m_sys.group(1) if m_sys else cells[0],
                        'attr': m_sys.group(2) if m_sys else '',
                        'required': cells[1],
                        'done': cells[2],
                        'studying': cells[3],
                        'remaining': cells[4],
                    })
            return {'items': items, 'total': len(items), 'ndzydm': ndzydm}
        except Exception as e:
            return {'error': str(e), 'items': [], 'total': 0}

    # ========== 考试安排查询（B1） ==========
    def query_exam(self, batch='期末', semester=''):
        """
        查询考试安排。
        :param batch: 考试批次（期末/期初/期中/提前期末/平时考察）
        :param semester: 学年学期，空=当前学期
        :return: {'exams': [...], 'count': n}
        """
        self._check_login()
        sem = semester or CONFIG['xnxqh']
        data = {
            'xqlbmc': batch,
            'xnxqid': sem,
            'xs0101id': '',
            'pageIndex': '1',
        }
        try:
            resp = self.request('POST', '/jsxsd/xsks/xsksap_list', data=data)
            soup = BeautifulSoup(resp.text, 'html.parser')
            table = soup.find('table')
            if not table:
                return {'error': '未找到考试安排表格', 'exams': [], 'count': 0}
            rows = table.find_all('tr')
            if len(rows) < 2:
                return {'error': '未查询到考试安排', 'exams': [], 'count': 0}
            headers = [h.get_text(strip=True) for h in rows[0].find_all(['th', 'td'])]
            exams = []
            for row in rows[1:]:
                cells = [c.get_text(strip=True) for c in row.find_all('td')]
                if not cells or not cells[0]:
                    continue
                exam = {}
                for i, h in enumerate(headers):
                    if i < len(cells):
                        exam[h] = cells[i]
                if '序号' in exam and exam['序号'] == '未查询到数据':
                    continue
                if '未查询到数据' in ' '.join(cells) or '未查询到' in ' '.join(cells):
                    continue
                exams.append(exam)
            return {'exams': exams, 'count': len(exams), 'batch': batch, 'semester': sem}
        except Exception as e:
            return {'error': str(e), 'exams': [], 'count': 0}

    # ========== 随堂考试查询（B1延伸） ==========
    def query_quiz(self, batch='平时考察', semester=''):
        """
        查询随堂考试安排。
        :param batch: 批次（提前期末/平时考察）
        :param semester: 学年学期，空=当前学期
        :return: {'exams': [...], 'count': n}
        """
        self._check_login()
        sem = semester or CONFIG['xnxqh']
        data = {
            'xqlbmc': batch,
            'xnxqid': sem,
            'pageIndex': '1',
        }
        try:
            resp = self.request('POST', '/jsxsd/xsks/xsstk_list', data=data)
            soup = BeautifulSoup(resp.text, 'html.parser')
            table = soup.find('table')
            if not table:
                return {'error': '未找到随堂考试表格', 'exams': [], 'count': 0}
            rows = table.find_all('tr')
            if len(rows) < 2:
                return {'error': '未查询到随堂考试', 'exams': [], 'count': 0}
            headers = [h.get_text(strip=True) for h in rows[0].find_all(['th', 'td'])]
            exams = []
            for row in rows[1:]:
                cells = [c.get_text(strip=True) for c in row.find_all('td')]
                if not cells or not cells[0]:
                    continue
                exam = {}
                for i, h in enumerate(headers):
                    if i < len(cells):
                        exam[h] = cells[i]
                if '序号' in exam and exam['序号'] == '未查询到数据':
                    continue
                if '未查询到数据' in ' '.join(cells) or '未查询到' in ' '.join(cells):
                    continue
                exams.append(exam)
            return {'exams': exams, 'count': len(exams), 'batch': batch, 'semester': sem}
        except Exception as e:
            return {'error': str(e), 'exams': [], 'count': 0}

    # ========== 学籍卡片查询（C1） ==========
    def query_profile(self):
        """
        查询学籍卡片，返回完整学籍信息（主表基本信息+入学信息）。
        :return: {'info': {...}, 'count': n}
        """
        self._check_login()
        try:
            resp = self.request('GET', '/jsxsd/grxx/xsxx')
            soup = BeautifulSoup(resp.text, 'html.parser')

            # 只解析第一个表格（学籍卡片主表）
            table = soup.find('table')
            if not table:
                return {'error': '未找到学籍卡片表格', 'info': {}, 'count': 0}
            rows = table.find_all('tr')
            info = {}

            # 头部行（行2）：院系/专业/学制/班级/学号
            if len(rows) > 2:
                header = [c.get_text(strip=True) for c in rows[2].find_all('td')]
                for cell in header:
                    m = re.match(r'^(院系|专业|学制|班级|学号)：(.+)$', cell)
                    if m:
                        info[m.group(1)] = m.group(2)

            # 基本信息区（行3~10，键值成对：姓名|李泽祺|性别|男）
            for row in rows[3:11]:
                cells = [c.get_text(strip=True) for c in row.find_all('td')]
                for i in range(0, len(cells) - 1, 2):
                    k, v = cells[i], cells[i + 1]
                    if k and k != '\u00a0' and v and v != '\u00a0':
                        info[k] = v

            # 入学信息区（行46~49：入学日期/入学考号/身份证编号/毕结业证书号等）
            for row in rows[46:50]:
                cells = [c.get_text(strip=True) for c in row.find_all('td')]
                for i in range(0, len(cells) - 1, 2):
                    k, v = cells[i], cells[i + 1]
                    if k and k != '\u00a0' and v and v != '\u00a0':
                        info[k] = v

            return {'info': info, 'count': len(info)}
        except Exception as e:
            return {'error': str(e), 'info': {}, 'count': 0}

    # ========== 选课轮次查询（E1） ==========
    def query_elective_rounds(self):
        """
        查询选课轮次（学年学期、选课名称、选课时间、操作）。
        :return: {'rounds': [...], 'count': n}
        """
        self._check_login()
        try:
            resp = self.request('GET', '/jsxsd/xsxk/xklc_list')
            soup = BeautifulSoup(resp.text, 'html.parser')
            table = soup.find('table')
            if not table:
                return {'error': '未找到选课轮次表格', 'rounds': [], 'count': 0}
            rows = table.find_all('tr')
            if len(rows) < 2:
                return {'error': '当前没有开放的选课轮次', 'rounds': [], 'count': 0}
            headers = [h.get_text(strip=True) for h in rows[0].find_all(['th', 'td'])]
            rounds = []
            for row in rows[1:]:
                cells = [c.get_text(strip=True) for c in row.find_all('td')]
                if not cells or not cells[0]:
                    continue
                rnd = {}
                for i, h in enumerate(headers):
                    if i < len(cells):
                        rnd[h] = cells[i]
                rounds.append(rnd)
            return {'rounds': rounds, 'count': len(rounds)}
        except Exception as e:
            return {'error': str(e), 'rounds': [], 'count': 0}

    # ========== 选课结果查询（E2） ==========
    def query_elective_results(self, semester=''):
        """
        查询选课结果。
        :param semester: 学年学期，空=当前学期
        :return: {'courses': [...], 'count': n}
        """
        self._check_login()
        sem = semester or CONFIG['xnxqh']
        data = {
            'xnxqid': sem,
            'pageIndex': '1',
            'pageSize': '50',
        }
        try:
            resp = self.request('POST', '/jsxsd/xkgl/loadXsxkjgList', data=data)
            soup = BeautifulSoup(resp.text, 'html.parser')
            table = soup.find('table')
            if not table:
                return {'error': '未找到选课结果表格', 'courses': [], 'count': 0}
            rows = table.find_all('tr')
            if len(rows) < 2:
                return {'error': '未查询到选课结果', 'courses': [], 'count': 0}
            headers = [h.get_text(strip=True) for h in rows[0].find_all(['th', 'td'])]
            courses = []
            for row in rows[1:]:
                cells = [c.get_text(strip=True) for c in row.find_all('td')]
                if not cells or not cells[0]:
                    continue
                c = {}
                for i, h in enumerate(headers):
                    if i < len(cells):
                        c[h] = cells[i]
                if '序号' in c and c['序号'] == '未查询到数据':
                    continue
                courses.append(c)
            return {'courses': courses, 'count': len(courses), 'semester': sem}
        except Exception as e:
            return {'error': str(e), 'courses': [], 'count': 0}

    # ========== 教学周历查询（G1） ==========
    def query_calendar(self, semester=''):
        """
        查询教学周历。
        :param semester: 学年学期，空=当前学期
        :return: {'weeks': [...], 'count': n}
        """
        self._check_login()
        try:
            resp = self.request('GET', '/jsxsd/jxzl/jxzl_query')
            soup = BeautifulSoup(resp.text, 'html.parser')
            table = soup.find('table')
            if not table:
                return {'error': '未找到周历表格', 'weeks': [], 'count': 0}
            rows = table.find_all('tr')
            if len(rows) < 2:
                return {'error': '未查询到周历数据', 'weeks': [], 'count': 0}
            headers = [h.get_text(strip=True) for h in rows[0].find_all(['th', 'td'])]
            weeks = []
            for row in rows[1:]:
                cells = [c.get_text(strip=True) for c in row.find_all('td')]
                if not cells or not cells[0]:
                    continue
                # 只取周次为纯数字的行（跳过"周历编制"等说明行）
                if not re.fullmatch(r'\d+', cells[0]):
                    continue
                w = {}
                for i, h in enumerate(headers):
                    if i < len(cells):
                        w[h] = cells[i]
                # 若表头第一列为空，用"周次"命名
                if not w.get(headers[0]) and headers[0] == '':
                    w['周次'] = cells[0]
                    del w['']
                weeks.append(w)
            return {'weeks': weeks, 'count': len(weeks)}
        except Exception as e:
            return {'error': str(e), 'weeks': [], 'count': 0}

    # ========== 教师/教室/班级/课程课表HTML解析（旧表格） ==========
    def _parse_schedule_html(self, html, query_type):
        """解析课表表格（行=节次，列=星期），兼容教师/教室/班级/课程"""
        soup = BeautifulSoup(html, 'html.parser')
        table = soup.find('table')
        if not table:
            return {'error': '未找到课表表格', 'courses': []}

        rows = table.find_all('tr')
        if len(rows) < 2:
            return {'error': '课表数据为空', 'courses': []}

        # 判定表头结构：第一列是"教师\节次"/"教室\节次"/"班级\节次"/"课程\节次"
        # 第二行可能是节次编号行（0102 0304 ...），也可能直接是数据行
        header_row = rows[0]
        header_first = header_row.find('td') or header_row.find('th')
        header_text = header_first.get_text(strip=True) if header_first else ''

        # 第二行若全是节次编号（0102/0304/...）则为节次表头
        data_start = 1
        if len(rows) > 1:
            cells2 = rows[1].find_all(['td', 'th'])
            texts2 = [c.get_text(strip=True) for c in cells2]
            if all(re.fullmatch(r'\d{2,4}', t) for t in texts2[1:] if t):
                data_start = 2

        periods_per_day = 7
        days = 7

        courses = []
        for row_idx in range(data_start, len(rows)):
            cells = rows[row_idx].find_all('td')
            if not cells:
                continue
            name = cells[0].get_text(strip=True)
            if not name or name == '\u00a0':
                continue

            for cell_idx in range(1, len(cells)):
                cell_text = cells[cell_idx].get_text('\n', strip=True)
                if not cell_text or cell_text == '\u00a0':
                    continue

                day_idx = (cell_idx - 1) // periods_per_day
                period_idx = (cell_idx - 1) % periods_per_day
                if day_idx >= days:
                    continue

                parsed_courses = self._parse_course_cell(cell_text)
                for course in parsed_courses:
                    course['weekday'] = day_idx + 1
                    course['weekday_name'] = WEEK_DAYS[day_idx]
                    course['period'] = SCHEDULE[period_idx]['name'] if period_idx < len(SCHEDULE) else ''
                    course['period_label'] = SCHEDULE[period_idx]['label'] if period_idx < len(SCHEDULE) else ''
                    if query_type == 'teacher':
                        course['teacher'] = name
                    elif query_type == 'class':
                        course['classes'] = name
                    elif query_type == 'course':
                        course['course_name'] = name
                    else:
                        course['classroom'] = name
                    courses.append(course)

        return {'courses': courses, 'count': len(courses)}

    # ========== 学生课表HTML解析（新界面） ==========
    def _parse_student_schedule_html(self, html, weekday='', jc1='', jc2='', week=''):
        """
        解析学生个人课表（新界面）：
        行=大节（第一大节(01,02小节)08:00-09:40 …），列=星期。
        每个课程单元格 = span.box（短视图）+ div.item-box（详情视图）成对出现。
        """
        soup = BeautifulSoup(html, 'html.parser')
        table = soup.find('table')
        if not table:
            return {'error': '未找到课表表格', 'courses': [], 'remarks': []}

        rows = table.find_all('tr')
        courses = []
        remarks = []

        for row in rows:
            cells = row.find_all('td')
            if not cells:
                continue
            label = cells[0].get_text(' ', strip=True)
            # 备注行：<td>备注</td><td colspan=7>学年论文 1-17周;...</td>
            if '备注' in label or '说明' in label:
                for c in cells[1:]:
                    txt = c.get_text(' ', strip=True)
                    if txt and txt != '\u00a0':
                        remarks.append(txt)
                continue

            # 大节行的各星期列
            for col_idx in range(1, len(cells)):
                cell = cells[col_idx]
                day_idx = col_idx  # 1=星期一 ... 7=星期日
                if day_idx > 7:
                    continue
                items = cell.select('div.item-box')
                if not items:
                    # 无详情时尝试 box 本身
                    boxes = cell.select('span.box')
                    if boxes:
                        items = boxes
                for item in items:
                    course = self._parse_student_course_cell(item, day_idx, label)
                    if course:
                        courses.append(course)

        # 跨大节课程去重（同一课程会同时渲染在相邻大节行）
        seen = set()
        unique = []
        for c in courses:
            key = (c.get('weekday'), c.get('name'), c.get('teacher'),
                   c.get('classroom'), c.get('period'))
            if key in seen:
                continue
            seen.add(key)
            unique.append(c)
        courses = unique

        # 按星期/节次过滤
        if weekday:
            try:
                wd = int(weekday)
                courses = [c for c in courses if c.get('weekday') == wd]
            except (ValueError, TypeError):
                pass
        if jc1 and jc2:
            try:
                s, e = int(jc1), int(jc2)
                courses = [c for c in courses
                           if c.get('_jc_start', 0) <= e and c.get('_jc_end', 99) >= s]
            except (ValueError, TypeError):
                pass

        # 统一周次显示（该周加载的课程均为本周）
        for c in courses:
            c['week'] = f'第{week}周' if week else c.get('week', '')
            c.pop('_jc_start', None)
            c.pop('_jc_end', None)

        return {'courses': courses, 'count': len(courses), 'remarks': remarks}

    def _parse_student_course_cell(self, item, day_idx, row_label):
        """解析学生课表单元格中的一个课程块（box + item-box）"""
        # 详情视图 item-box
        is_box = 'item-box' not in (item.get('class') or [])
        if is_box:
            # 输入是 span.box 时，尝试找其后跟随的 div.item-box
            nxt = item.find_next_sibling('div')
            if nxt and 'item-box' in (nxt.get('class') or []):
                box, detail = item, nxt
            else:
                box, detail = item, None
        else:
            box = item.find_previous_sibling('span')
            if box is None or 'box' not in (box.get('class') or []):
                box = None
            detail = item

        course = {
            'name': '',
            'classes': '',
            'teacher': '',
            'week': '',
            'classroom': '',
            'remark': '',
        }

        # 课程名：详情视图第一个 p（完整名）；缺失时用 box 短名
        if detail is not None:
            p = detail.find('p')
            if p:
                course['name'] = p.get_text(strip=True)
        if not course['name'] and box is not None:
            p = box.find('p')
            if p:
                course['name'] = p.get_text(strip=True)

        # 教师：box 中 "教师：XXX" 行
        if box is not None:
            for p in box.find_all('p'):
                t = p.get_text(strip=True)
                if t.startswith('教师'):
                    teacher = re.sub(r'^教师\s*[:：]\s*', '', t)
                    # 清理界面截断符（如 "李亚西,.."）
                    teacher = re.sub(r'[.,，。]{1,}$', '', teacher).strip()
                    course['teacher'] = teacher
                    break
        if not course['teacher'] and detail is not None:
            for p in detail.find_all('p'):
                t = p.get_text(strip=True)
                if t.startswith('教师'):
                    course['teacher'] = re.sub(r'^教师\s*[:：]\s*', '', t).strip()
                    break

        # 节次：详情 .tch-name 中 "01~02~03节"；缺失时用 box 中 "01~02~03小节"
        period_nums = []
        if detail is not None:
            for s in detail.select('.tch-name span'):
                txt = s.get_text(strip=True)
                if '节' in txt:
                    period_nums = re.findall(r'\d{2}', txt)
                    break
        if not period_nums and box is not None:
            sp = box.select_one('span.text')
            if sp:
                period_nums = re.findall(r'\d{2}', sp.get_text(strip=True))
        if period_nums:
            try:
                jc_start, jc_end = int(period_nums[0]), int(period_nums[-1])
                course['_jc_start'] = jc_start
                course['_jc_end'] = jc_end
                course['period'] = f'{jc_start:02d}{jc_end:02d}'
                course['period_label'] = f'第{jc_start}-{jc_end}节'
            except (ValueError, IndexError):
                course['period'] = ''
                course['period_label'] = row_label
        else:
            course['period'] = ''
            course['period_label'] = row_label

        # 教室：详情中 img[src*=item1] 所在 span
        if detail is not None:
            img1 = detail.select_one('img[src*="item1.png"]')
            if img1 and img1.parent:
                course['classroom'] = img1.parent.get_text(strip=True)
        # 周次：详情中 img[src*=item3] 所在 span（"第3周 星期二"）
        if detail is not None:
            img3 = detail.select_one('img[src*="item3.png"]')
            if img3 and img3.parent:
                wk = re.search(r'第(\d+)周', img3.parent.get_text())
                if wk:
                    course['week'] = f'第{wk.group(1)}周'

        course['weekday'] = day_idx
        course['weekday_name'] = WEEK_DAYS[day_idx - 1]

        if not course['name']:
            return None
        return course

    # ========== 旧表格单元格解析（多行文本） ==========
    def _parse_course_cell(self, text):
        """
        解析教师/教室/班级/课程表格单元格（多行文本，可能含多门课程）。
        兼容两种行序：
        - 教师课表：课程名 → 班级 → 教师 → 周次 → 教室
        - 教室/班级课表：课程名 → 教师 → 周次 → 班级 → 教室
        """
        lines = [l.strip() for l in text.split('\n') if l.strip()]
        if not lines:
            return []

        def is_week_line(line):
            return line.startswith('(') and '周' in line

        def is_remark_line(line):
            return line.startswith('(') and '周' not in line

        def is_classroom_line(line):
            if is_remark_line(line):
                return False
            # 无数字的汉字教室（如 射击馆、警体馆、教学楼）
            if re.match(r'^[\u4e00-\u9fa5]{2,5}(馆|楼)$', line):
                return True
            # 汉字开头：仅当含括号+含数字时判定为教室（如 思政教育及语音教学多功能室（3C1））
            if re.match(r'^[\u4e00-\u9fa5]', line):
                return ('(' in line or '（' in line) and bool(re.search(r'\d', line))
            # 非汉字开头：含数字+教室特征（如 3-307（25心理矫治班）、3C5(公共教室）、y-104）
            if re.search(r'\d', line) and ('教' in line or '室' in line or '馆' in line
                                           or '(' in line or '）' in line or '-' in line):
                return True
            # 纯字母数字短串（如 3C5）
            if re.match(r'^[A-Za-z0-9]+$', line) and len(line) <= 6:
                return True
            return False

        def is_teacher_line(line):
            return bool(re.match(r'^[\u4e00-\u9fa5]{2,4}$', line))

        courses = []
        i = 0
        while i < len(lines):
            course = {
                'name': '',
                'classes': '',
                'teacher': '',
                'week': '',
                'classroom': '',
                'remark': '',
            }
            course['name'] = lines[i]
            i += 1

            # 备注行（(分组01) 等，紧跟课程名后）
            if i < len(lines) and is_remark_line(lines[i]):
                course['remark'] = lines[i].strip('()')
                course['name'] += f"({course['remark']})"
                i += 1

            # 教师课表顺序：班级在教师前
            if i < len(lines) and not is_teacher_line(lines[i]) and not is_week_line(lines[i]) \
                    and not is_classroom_line(lines[i]) and not is_remark_line(lines[i]):
                course['classes'] = lines[i]
                i += 1

            # 教师
            if i < len(lines) and is_teacher_line(lines[i]):
                course['teacher'] = lines[i]
                i += 1

            # 周次（教师课表：周次在教师后；也可能教师与周次同行已被拆开）
            if i < len(lines) and is_week_line(lines[i]):
                course['week'] = lines[i].strip('()')
                i += 1

            # 周次后的行：教室课表顺序中这里是"班级→教室"
            if i < len(lines):
                nxt = lines[i + 1] if i + 1 < len(lines) else ''
                if is_classroom_line(lines[i]):
                    course['classroom'] = lines[i]
                    i += 1
                elif is_classroom_line(nxt) and not is_teacher_line(lines[i]):
                    # 当前行非教室且后一行是教室 → 当前行是班级（教室课表顺序）
                    course['classes'] = lines[i]
                    i += 1
                    if i < len(lines) and is_classroom_line(lines[i]):
                        course['classroom'] = lines[i]
                        i += 1

            if course['name']:
                courses.append(course)

        return courses


# ========== 时间工具 ==========
def get_current_week():
    """获取当前教学周次（基于校历第1周周一）"""
    start = datetime.strptime(CONFIG['semester_start'], '%Y-%m-%d')
    now = datetime.now()
    diff = (now - start).days
    return max(1, diff // 7 + 1)


def get_current_weekday():
    """获取当前星期（1-7，1=周一）"""
    d = datetime.now().weekday()  # 0=周一
    return d + 1


def get_current_period():
    """获取当前节次"""
    now = datetime.now()
    cur = now.strftime('%H:%M')
    for p in SCHEDULE:
        if p['start'] <= cur <= p['end']:
            return p['name']
    return ''


def week_monday(week):
    """周次(数字/字符串) → 该周周一日期 'YYYY-MM-DD'。优先使用校历映射，缺失时按开学日期推算。"""
    try:
        w = int(week)
    except (ValueError, TypeError):
        w = get_current_week()
    if w in WEEK_DATES:
        return WEEK_DATES[w]
    start = datetime.strptime(CONFIG['semester_start'], '%Y-%m-%d')
    return (start + timedelta(weeks=w - 1)).strftime('%Y-%m-%d')


def is_course_in_week(week_str, week):
    """检查课程是否在指定周次上课"""
    if not week_str:
        return True
    try:
        w = int(week)
    except (ValueError, TypeError):
        return True
    ranges = re.findall(r'\d+(?:-\d+)?', week_str)
    for r in ranges:
        if '-' in r:
            s, e = map(int, r.split('-'))
            if s <= w <= e:
                return True
        else:
            if int(r) == w:
                return True
    return False


# ========== 重名教师冲突检测 ==========
def find_duplicate_conflicts(courses):
    """
    检测同一星期同一节次出现多门不同课程的情况（一名教师不可能同时上两门课）。
    返回冲突字典 {(weekday, period): [课程名...]}，用于提示可能存在同名教师。
    """
    slots = {}
    for c in courses:
        key = (c.get('weekday'), c.get('period'))
        slots.setdefault(key, set()).add(c.get('name', ''))
    return {k: sorted(v) for k, v in slots.items() if len(v) > 1}


# ========== 格式化输出 ==========
def format_courses(courses, filter_current_week=None):
    """格式化课程列表为可读文本"""
    if filter_current_week:
        courses = [c for c in courses if is_course_in_week(c.get('week', ''), filter_current_week)]

    if not courses:
        return "未查询到课程信息"

    def sort_key(c):
        p = c.get('period', '') or ''
        try:
            start = int(p[:2]) if p[:2].isdigit() else 99
        except (ValueError, IndexError):
            start = 99
        return (c.get('weekday', 99), start)

    courses = sorted(courses, key=sort_key)

    lines = []
    current_day = None
    for c in courses:
        if c.get('weekday') != current_day:
            current_day = c.get('weekday')
            lines.append(f"\n【{c.get('weekday_name', '')}】")
        line = f"  {c.get('period_label', '')} | {c.get('name', '')}"
        details = []
        if c.get('teacher'):
            details.append(f"教师:{c['teacher']}")
        if c.get('classroom'):
            details.append(f"教室:{c['classroom']}")
        if c.get('classes'):
            details.append(f"班级:{c['classes']}")
        if c.get('week'):
            details.append(f"周次:{c['week']}")
        if details:
            line += f" ({', '.join(details)})"
        lines.append(line)
    return '\n'.join(lines)


def format_scores(result):
    """格式化成绩列表"""
    courses = result.get('courses', [])
    if not courses:
        return "未查询到成绩数据"
    lines = []
    for c in courses:
        lines.append(
            f"  {c.get('开课学期', '')} | {c.get('课程名称', '')} | "
            f"成绩:{c.get('成绩', '')} | 学分:{c.get('学分', '')} | "
            f"绩点:{c.get('绩点', '')} | {c.get('考核方式', '')} | {c.get('课程性质', '')}"
        )
    return '\n'.join(lines)


def format_gpa(gpa_result):
    """格式化绩点计算结果"""
    lines = [
        f"  平均绩点(GPA): {gpa_result['gpa']}",
        f"  已修学分: {gpa_result['passed_credits']} / {gpa_result['total_credits']}",
    ]
    if gpa_result['weighted_avg'] is not None:
        lines.append(f"  加权平均分: {gpa_result['weighted_avg']}")
    if gpa_result['failed_count']:
        lines.append(f"  ⚠ 挂科/未通过课程: {gpa_result['failed_count']} 门")
        for f in gpa_result['failed_courses']:
            lines.append(f"    - {f['semester']} {f['name']} 成绩:{f['grade']} 学分:{f['credit']}")
    else:
        lines.append("  无挂科记录 ✅")
    return '\n'.join(lines)


def format_progress(result):
    """格式化学习完成情况"""
    items = result.get('items', [])
    if not items:
        return "未查询到学习完成情况"
    lines = ["  课程体系 | 属性 | 要求学分 | 已修 | 正修读 | 还需"]
    for it in items:
        lines.append(
            f"  {it['system']} | {it['attr']} | {it['required']} | "
            f"{it['done']} | {it['studying']} | {it['remaining']}"
        )
    return '\n'.join(lines)


def format_exam(result, is_quiz=False):
    """格式化考试安排"""
    exams = result.get('exams', [])
    if not exams:
        return f"未查询到{result.get('batch', '')}考试安排"
    lines = []
    for e in exams:
        if is_quiz:
            lines.append(
                f"  {e.get('课程名称', '')} | 第{e.get('考试周次', '')}周 星期{e.get('考试星期', '')} "
                f"第{e.get('考试节次', '')}节 | 监考:{e.get('监考教师', '')} | 教室:{e.get('考试教室', '')}"
            )
        else:
            lines.append(
                f"  {e.get('课程名称', '')} | {e.get('授课教师', '')} | "
                f"{e.get('考试时间', '')} | 考场:{e.get('考场', '')} | 座位:{e.get('座位号', '')}"
            )
    return '\n'.join(lines)


def format_profile(result):
    """格式化学籍卡片"""
    info = result.get('info', {})
    if not info:
        return "未查询到学籍信息"
    order = ['学号', '姓名', '性别', '出生日期', '民族', '政治面貌', '籍贯', '院系',
             '专业', '学制', '班级', '学习层次', '外语种类', '婚否']
    lines = []
    for k in order:
        if k in info:
            lines.append(f"  {k}: {info[k]}")
    for k, v in info.items():
        if k not in order:
            lines.append(f"  {k}: {v}")
    return '\n'.join(lines)


def format_elective_rounds(result):
    """格式化选课轮次"""
    rounds = result.get('rounds', [])
    if not rounds:
        return "当前没有开放的选课轮次"
    lines = []
    for r in rounds:
        lines.append(
            f"  {r.get('学年学期', '')} | {r.get('选课名称', '')} | {r.get('选课时间', '')}"
        )
    return '\n'.join(lines)


def format_elective_results(result):
    """格式化选课结果"""
    courses = result.get('courses', [])
    if not courses:
        return "未查询到选课结果"
    lines = []
    for c in courses:
        lines.append(
            f"  {c.get('课程名称', '')} | {c.get('课程编号', '')} | "
            f"教师:{c.get('上课教师', '')} | 学分:{c.get('学分', '')} | "
            f"{c.get('课程性质', '')} | {c.get('考核方式', '')}"
        )
    return '\n'.join(lines)


def format_calendar(result):
    """格式化教学周历"""
    weeks = result.get('weeks', [])
    if not weeks:
        return "未查询到教学周历"
    current_week = get_current_week()
    lines = ["  周次 | 周一 | 周二 | 周三 | 周四 | 周五 | 周六 | 周日 | 备注"]
    for w in weeks:
        wk = w.get('周次', w.get('', ''))
        cells = [w.get('星期一', ''), w.get('星期二', ''), w.get('星期三', ''),
                 w.get('星期四', ''), w.get('星期五', ''), w.get('星期六', ''),
                 w.get('星期日', ''), w.get('备注', '')]
        marker = ' ← 本周' if str(wk) == str(current_week) else ''
        lines.append(f"  {wk} | {' | '.join(cells)}{marker}")
    lines.append(f"\n当前教学周: 第{current_week}周")
    return '\n'.join(lines)


# ========== 本地凭证 ==========
def load_credentials():
    """从本地配置文件加载账号密码（若存在）。文件权限应为600。"""
    cfg_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'credentials.json')
    if os.path.exists(cfg_path):
        try:
            with open(cfg_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception:
            return {}
    return {}


# ========== 命令行接口 ==========
def main():
    parser = argparse.ArgumentParser(
        description='中央司法警官学院教务系统全能查询工具',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''查询类型(--type)：
  teacher   教师课表      --name 教师姓名
  classroom 教室课表      --name 教室名称(如 3-307)
  self      本人课表      （无需 --name）
  class     班级课表      --name 班级名称(如 心理矫治班24)
  course    课程课表      --name 课程名称(如 罪犯改造心理学)
  score     成绩查询      [--semester 学期] [--name 课程名筛选]
  gpa       绩点计算与学业预警（基于全部成绩）
  progress  学习完成情况
  exam      考试安排      [--batch 期末/期初/期中/提前期末/平时考察]
  profile   学籍卡片
  elective  选课轮次
  electives 选课结果
  calendar  教学周历

通用选项：
  --week 周次  --weekday 星期  --current 当前时刻  --json JSON输出
  --semester 学年学期(如2026-2027-1)  --batch 考试批次
''')
    parser.add_argument('--account', required=False, help='教务系统账号（不填则读取本地凭证配置）')
    parser.add_argument('--password', required=False, help='教务系统密码（不填则读取本地凭证配置）')
    parser.add_argument('--type', choices=[
        'teacher', 'classroom', 'self', 'class', 'course',
        'score', 'gpa', 'progress', 'exam', 'profile',
        'elective', 'electives', 'calendar',
    ], default='teacher', help='查询类型（H1统一入口）')
    parser.add_argument('--name', required=False, help='教师/教室/班级/课程名称（按类型）')
    parser.add_argument('--week', default='', help='周次（如3），不填为全部/当前周')
    parser.add_argument('--weekday', default='', help='星期（1-7），不填为全部')
    parser.add_argument('--current', action='store_true', help='查询当前时刻')
    parser.add_argument('--json', action='store_true', help='以JSON格式输出')
    parser.add_argument('--semester', default='', help='学年学期ID（如2026-2027-1），空=当前学期/全部')
    parser.add_argument('--batch', default='期末', help='考试批次（期末/期初/期中/提前期末/平时考察）')

    args = parser.parse_args()

    # 账号密码：命令行优先，其次读取本地凭证配置
    creds = load_credentials()
    account = args.account or creds.get('account', '')
    password = args.password or creds.get('password', '')
    if not account or not password:
        print("未提供账号密码，且本地凭证配置（scripts/credentials.json）不存在或为空", file=sys.stderr)
        sys.exit(1)

    # 参数校验
    if args.type in ('teacher', 'classroom', 'class', 'course') and not args.name:
        print(f"查询类型 {args.type} 必须提供 --name", file=sys.stderr)
        sys.exit(1)

    # 登录
    session = JwxtSession()
    success, msg = session.login(account, password)
    if not success:
        print(f"登录失败: {msg}", file=sys.stderr)
        sys.exit(1)
    print(f"登录成功: {msg}", file=sys.stderr)

    # 自动探测学期/节次模式/校历
    session.refresh_runtime_config()
    print(f"已自动探测: 学期={CONFIG['xnxqh']}, 节次模式={CONFIG['kbjcmsid']}, "
          f"校历第1周周一={CONFIG['semester_start']}", file=sys.stderr)

    # 处理当前时刻
    week = args.week
    weekday = args.weekday
    jc1 = jc2 = ''
    if args.current:
        week = str(get_current_week())
        weekday = str(get_current_weekday())
        period = get_current_period()
        if period:
            if len(period) == 4:
                jc1 = period[:2]
                jc2 = period[2:]
            else:
                jc1 = jc2 = period

    result = None
    query_type = args.type

    # ===== 课表类查询（共用 format_courses） =====
    if query_type == 'teacher':
        result = session.query_teacher_schedule(args.name, week, weekday, jc1, jc2)
    elif query_type == 'classroom':
        result = session.query_classroom_schedule(room_name=args.name, week=week, weekday=weekday, jc1=jc1, jc2=jc2)
    elif query_type == 'self':
        result = session.query_self_schedule(week, weekday, jc1, jc2)
    elif query_type == 'class':
        result = session.query_class_schedule(args.name, week, weekday, jc1, jc2)
    elif query_type == 'course':
        result = session.query_course_schedule(args.name, week, weekday, jc1, jc2)

    # ===== 成绩/绩点 =====
    elif query_type == 'score':
        result = session.query_scores(semester=args.semester, kcmc=args.name or '')
    elif query_type == 'gpa':
        score_result = session.query_scores()
        if 'error' in score_result:
            result = score_result
        else:
            result = session.compute_gpa(score_result)

    # ===== 学习/考试/学籍 =====
    elif query_type == 'progress':
        result = session.query_progress()
    elif query_type == 'exam':
        # 平时考察/提前期末 → 随堂考试接口；其余 → 考试安排接口
        if args.batch in ('平时考察', '提前期末'):
            result = session.query_quiz(batch=args.batch, semester=args.semester)
        else:
            result = session.query_exam(batch=args.batch, semester=args.semester)
    elif query_type == 'profile':
        result = session.query_profile()

    # ===== 选课/周历 =====
    elif query_type == 'elective':
        result = session.query_elective_rounds()
    elif query_type == 'electives':
        result = session.query_elective_results(semester=args.semester)
    elif query_type == 'calendar':
        result = session.query_calendar(semester=args.semester)

    # ===== 输出 =====
    if result is None:
        print(f"未知查询类型: {query_type}", file=sys.stderr)
        sys.exit(1)

    if args.json:
        print(json.dumps(result, ensure_ascii=False, indent=2))
        return

    # 文本输出
    if 'error' in result:
        # 课表类查询 error 且无课程数据 → 按无数据提示
        if not any(k in result for k in ('courses', 'exams', 'items', 'info', 'rounds', 'weeks')):
            print(f"查询失败: {result['error']}", file=sys.stderr)
            sys.exit(1)

    if query_type in ('teacher', 'classroom', 'self', 'class', 'course'):
        courses = result.get('courses', [])
        filter_week = week if week else None
        print(format_courses(courses, filter_current_week=filter_week))
        # 重名教师冲突提示（仅教师查询有意义）
        if query_type == 'teacher':
            conflicts = find_duplicate_conflicts(courses)
            if conflicts:
                print("\n⚠ 检测到同名冲突：同一时段出现多门不同课程，可能查询结果合并了同名教师。")
                for (wd, period), names in sorted(conflicts.items()):
                    day_name = WEEK_DAYS[wd - 1] if 1 <= wd <= 7 else f'周{wd}'
                    print(f"  {day_name} 节次{period}: {' / '.join(names)}")
        remarks = result.get('remarks') or []
        if remarks:
            print(f"\n备注: {'; '.join(remarks)}")
        print(f"\n共查询到 {len(courses)} 条课程记录")
    elif query_type == 'score':
        print(format_scores(result))
        print(f"\n共查询到 {result.get('count', 0)} 条成绩记录")
    elif query_type == 'gpa':
        if 'error' in result:
            print(f"查询失败: {result['error']}", file=sys.stderr)
            sys.exit(1)
        print(format_gpa(result))
    elif query_type == 'progress':
        if 'error' in result:
            print(f"查询失败: {result['error']}", file=sys.stderr)
            sys.exit(1)
        print(format_progress(result))
        print(f"\n共 {result.get('total', 0)} 个课程体系")
    elif query_type == 'exam':
        print(format_exam(result, is_quiz=args.batch in ('平时考察', '提前期末')))
        print(f"\n共查询到 {result.get('count', 0)} 条考试安排")
    elif query_type == 'profile':
        if 'error' in result:
            print(f"查询失败: {result['error']}", file=sys.stderr)
            sys.exit(1)
        print(format_profile(result))
    elif query_type == 'elective':
        print(format_elective_rounds(result))
    elif query_type == 'electives':
        print(format_elective_results(result))
        print(f"\n共查询到 {result.get('count', 0)} 门课程")
    elif query_type == 'calendar':
        if 'error' in result:
            print(f"查询失败: {result['error']}", file=sys.stderr)
            sys.exit(1)
        print(format_calendar(result))


if __name__ == '__main__':
    main()
