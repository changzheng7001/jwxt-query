#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""固定角度截图：同一套视角反复用，便于版本间对比与视觉审查。

模拟「已登录 + 有真实课表数据」的状态，避免评审看到空登录卡片。
"""
import sys, pathlib

OUT = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else '/tmp/shots')
OUT.mkdir(parents=True, exist_ok=True)
URL = pathlib.Path('/home/user/Doubao/chats/38443085814030338/jwxt-webapp/index.html').resolve().as_uri()

from playwright.sync_api import sync_playwright

MOCK = {'courses': [
    {'name': '刑事诉讼法学', 'weekday': 1, 'period': '0102', 'teacher': '朱晓杰', 'classroom': '3-307', 'week': '1-20周'},
    {'name': '大学英语', 'weekday': 2, 'period': '0102', 'teacher': '李娜', 'classroom': '3C5', 'week': '1-18周'},
    {'name': '国外矫正制度', 'weekday': 3, 'period': '0102', 'teacher': '李亚西', 'classroom': '2-201', 'week': '1-17周'},
    {'name': '毛泽东思想和中国特色社会主义理论体系概论', 'weekday': 4, 'period': '0102', 'teacher': '白之一', 'classroom': '1-101', 'week': '1-18周'},
    {'name': '心理咨询与心理治疗', 'weekday': 2, 'period': '0304', 'teacher': '杜丙立', 'classroom': '3-105', 'week': '1-17周'},
    {'name': '形势与政策', 'weekday': 1, 'period': '0506', 'teacher': '郭艳波', 'classroom': '4-202', 'week': '1-8周'},
    {'name': '警务战术', 'weekday': 3, 'period': '0506', 'teacher': '田新明', 'classroom': '射击馆', 'week': '1-17周'},
    {'name': '警用射击', 'weekday': 1, 'period': '0708', 'teacher': '王强', 'classroom': '射击馆', 'week': '1-17周'},
    {'name': '犯罪学原理', 'weekday': 5, 'period': '0304', 'teacher': '孙丽', 'classroom': '2-305', 'week': '1-17周'},
]}

VIEWS = [
    ('01-launch', '启动页（已登录，课表）', 'schedule'),
    ('02-topbar', '顶栏特写', 'schedule_zoom'),
    ('03-panel-open', '点开「查询参数」磁贴', 'schedule_panel'),
    ('04-settings', '设置页', 'settings'),
    ('05-list', '课表列表视图', 'list'),
    ('06-result-panel', '点开面板（结果页态）', 'schedule_panel'),
]


def boot(pg):
    pg.goto(URL, wait_until='load')
    pg.wait_for_timeout(700)
    pg.evaluate("""(d) => {
        S.loggedIn = true; S.queryType = 'self'; S.scheduleForm = 'grid'; S.lastData = d;
        try { applyLoggedInUI(); hideLogin(); } catch(e) {}
        try { renderResult('self', d); showView('result', false); } catch(e) {}
        var t = document.getElementById('scheduleToast'); if (t) t.hidden = true;
    }""", MOCK)
    pg.wait_for_timeout(900)
    pg.evaluate("var t=document.getElementById('scheduleToast'); if(t) t.hidden=true;")


def run():
    with sync_playwright() as p:
        b = p.chromium.launch()
        for name, desc, act in VIEWS:
            pg = b.new_page(viewport={'width': 390, 'height': 844}, device_scale_factor=2)
            boot(pg)

            if act == 'schedule':
                pass
            elif act == 'schedule_zoom':
                # 只截顶栏区域
                pg.screenshot(path=str(OUT / f'{name}.png'), clip={'x': 0, 'y': 0, 'width': 390, 'height': 110})
            elif act == 'settings':
                pg.evaluate("try{ showTab('settings', true); }catch(e){}")
                pg.wait_for_timeout(600)
            elif act == 'list':
                pg.evaluate("try{ toggleScheduleForm && toggleScheduleForm(); }catch(e){}")
                pg.wait_for_timeout(600)
            elif act == 'schedule_panel':
                pg.evaluate("""() => {
                    var el = document.getElementById('querySection');
                    if (el) el.classList.add('open');
                    if (typeof layoutOpenFloats === 'function') layoutOpenFloats();
                }""")
                pg.wait_for_timeout(500)

            path = OUT / f'{name}.png'
            if act != 'schedule_zoom':
                pg.screenshot(path=str(path))
            print(f'{name}.png  {desc}')
            pg.close()
        b.close()


if __name__ == '__main__':
    run()
