#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""中警院教务查询 —— 输出格式化模块（纯函数）

把各查询返回的结构化结果格式化为可读文本，供命令行/WebUI 直接展示。
"""

from jwxt_config import WEEK_DAYS
from jwxt_utils import get_current_week, is_course_in_week


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
