#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
中央司法警官学院教务系统查询工具 v3.0（模块化精简版）

单文件入口，职责仅保留：JwxtSession（会话 + 13 类查询）+ 命令行接口。
解析、格式化、工具逻辑已拆分为独立模块：
  jwxt_config   —— 常量/配置
  jwxt_utils    —— 加密/绩点/时间/凭证等工具
  jwxt_parsers  —— HTML 解析器
  jwxt_format   —— 输出格式化

对外兼容：仍从本模块导出 JwxtSession / CONFIG / SCHEDULE / WEEK_DAYS /
get_current_week / get_current_weekday / get_current_period / load_credentials /
find_duplicate_conflicts，webui.py、monitor_cxbmxk.py 无需改动。
"""

import re
import json
import sys
import argparse
import requests

from jwxt_config import CONFIG, SCHEDULE, WEEK_DAYS, WEEK_DATES, _CN_NUM
from jwxt_utils import (encode_password, grade_to_point, is_pass,
                        get_current_week, get_current_weekday, get_current_period,
                        week_monday, is_course_in_week, find_duplicate_conflicts,
                        load_credentials)
import jwxt_parsers
import jwxt_format


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

    # ========== 会话保持与自动重登 ==========
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
            return jwxt_parsers.parse_schedule_html(resp.text, 'teacher')
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
            return jwxt_parsers.parse_schedule_html(resp.text, 'classroom')
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
            return jwxt_parsers.parse_student_schedule_html(resp.text, weekday=weekday,
                                                            jc1=jc1, jc2=jc2, week=week)
        except Exception as e:
            return {'error': str(e), 'courses': [], 'remarks': []}

    # ========== 班级课表查询 ==========
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
            return jwxt_parsers.parse_schedule_html(resp.text, 'class')
        except Exception as e:
            return {'error': str(e), 'courses': []}

    # ========== 课程课表查询 ==========
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
            return jwxt_parsers.parse_schedule_html(resp.text, 'course')
        except Exception as e:
            return {'error': str(e), 'courses': []}

    # ========== 成绩查询 ==========
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
            return jwxt_parsers.parse_score_html(resp.text)
        except Exception as e:
            return {'error': str(e), 'courses': [], 'count': 0}

    # ========== 绩点计算与学业预警 ==========
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

    # ========== 学习完成情况 ==========
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
            from bs4 import BeautifulSoup
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

    # ========== 考试安排查询 ==========
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
            soup = __import__('bs4').BeautifulSoup(resp.text, 'html.parser')
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

    # ========== 随堂考试查询 ==========
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
            soup = __import__('bs4').BeautifulSoup(resp.text, 'html.parser')
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

    # ========== 学籍卡片查询 ==========
    def query_profile(self):
        """
        查询学籍卡片，返回完整学籍信息（主表基本信息+入学信息）。
        :return: {'info': {...}, 'count': n}
        """
        self._check_login()
        try:
            resp = self.request('GET', '/jsxsd/grxx/xsxx')
            soup = __import__('bs4').BeautifulSoup(resp.text, 'html.parser')

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

    # ========== 选课轮次查询 ==========
    def query_elective_rounds(self):
        """
        查询选课轮次（学年学期、选课名称、选课时间、操作）。
        :return: {'rounds': [...], 'count': n}
        """
        self._check_login()
        try:
            resp = self.request('GET', '/jsxsd/xsxk/xklc_list')
            soup = __import__('bs4').BeautifulSoup(resp.text, 'html.parser')
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

    # ========== 选课结果查询 ==========
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
            soup = __import__('bs4').BeautifulSoup(resp.text, 'html.parser')
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

    # ========== 教学周历查询 ==========
    def query_calendar(self, semester=''):
        """
        查询教学周历。
        :param semester: 学年学期，空=当前学期
        :return: {'weeks': [...], 'count': n}
        """
        self._check_login()
        try:
            resp = self.request('GET', '/jsxsd/jxzl/jxzl_query')
            soup = __import__('bs4').BeautifulSoup(resp.text, 'html.parser')
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
        print(jwxt_format.format_courses(courses, filter_current_week=filter_week))
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
        print(jwxt_format.format_scores(result))
        print(f"\n共查询到 {result.get('count', 0)} 条成绩记录")
    elif query_type == 'gpa':
        if 'error' in result:
            print(f"查询失败: {result['error']}", file=sys.stderr)
            sys.exit(1)
        print(jwxt_format.format_gpa(result))
    elif query_type == 'progress':
        if 'error' in result:
            print(f"查询失败: {result['error']}", file=sys.stderr)
            sys.exit(1)
        print(jwxt_format.format_progress(result))
        print(f"\n共 {result.get('total', 0)} 个课程体系")
    elif query_type == 'exam':
        print(jwxt_format.format_exam(result, is_quiz=args.batch in ('平时考察', '提前期末')))
        print(f"\n共查询到 {result.get('count', 0)} 条考试安排")
    elif query_type == 'profile':
        if 'error' in result:
            print(f"查询失败: {result['error']}", file=sys.stderr)
            sys.exit(1)
        print(jwxt_format.format_profile(result))
    elif query_type == 'elective':
        print(jwxt_format.format_elective_rounds(result))
    elif query_type == 'electives':
        print(jwxt_format.format_elective_results(result))
        print(f"\n共查询到 {result.get('count', 0)} 门课程")
    elif query_type == 'calendar':
        if 'error' in result:
            print(f"查询失败: {result['error']}", file=sys.stderr)
            sys.exit(1)
        print(jwxt_format.format_calendar(result))


if __name__ == '__main__':
    main()
