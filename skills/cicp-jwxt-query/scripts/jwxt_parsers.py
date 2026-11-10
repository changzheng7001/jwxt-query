#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""中警院教务查询 —— HTML 解析器模块（纯函数）

从教务系统返回的 HTML 中解析结构化数据：
- parse_score_html: 成绩列表
- parse_schedule_html: 教师/教室/班级/课程课表（旧表格）
- parse_student_schedule_html / parse_student_course_cell: 学生个人课表（新界面）
- parse_course_cell: 旧表格单元格多行文本解析

依赖 bs4；解析结果与教务系统页面显示一致。
"""

import re
from bs4 import BeautifulSoup

from jwxt_config import SCHEDULE, WEEK_DAYS


def parse_score_html(html):
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


def parse_schedule_html(html, query_type):
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

            parsed_courses = parse_course_cell(cell_text)
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


def parse_student_schedule_html(html, weekday='', jc1='', jc2='', week=''):
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
                course = parse_student_course_cell(item, day_idx, label)
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


def parse_student_course_cell(item, day_idx, row_label):
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


def parse_course_cell(text):
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
