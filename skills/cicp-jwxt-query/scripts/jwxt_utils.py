#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""中警院教务查询 —— 工具函数模块（纯函数）

集中存放密码加密、成绩绩点换算、当前周/星期/节次计算、
周次→日期换算、同名教师冲突检测、本地凭证加载等工具函数。
"""

import os
import json
import re
from datetime import datetime, timedelta

from jwxt_config import CONFIG, SCHEDULE, WEEK_DATES, GRADE_POINTS


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


# ========== 成绩与绩点 ==========
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
