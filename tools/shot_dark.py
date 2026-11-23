#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""深色模式场景截图（结果落到项目 review/shots-v249，避免 /tmp 被清）"""
import os
from pathlib import Path
from playwright.sync_api import sync_playwright

ROOT = Path(__file__).resolve().parent.parent
APP = (ROOT / 'jwxt-webapp' / 'index.html').resolve().as_uri()
OUT = ROOT / 'review' / 'shots-v249'
FIX = {k: (ROOT / 'tests' / 'fixtures' / f).read_text(encoding='utf-8') for k, f in
       {'f': 'theory-2026f.html', 's': 'theory-2026s.html',
        'p25': 'theory-2025spring.html', 'cal': 'jxzl.html'}.items()}
CHROME = '/home/user/.cache/ms-playwright/chromium-1234/chrome-linux64/chrome'

BOOT = """(a)=>{window.__P=a;window.Android={httpRequest:function(m,url){var u=String(url);
  if(u.indexOf('2025-2026-2')>=0) return window.__P.s; if(u.indexOf('2024-2025-2')>=0) return window.__P.p25;
  if(u.indexOf('xskb_list')>=0) return window.__P.f; if(u.indexOf('jxzl_query')>=0) return window.__P.cal;
  if(u.indexOf('cjcx_list')>=0) return '<table><tr><th>学年学期</th><th>课程名称</th><th>性质</th><th>学分</th><th>成绩</th><th>绩点</th></tr>'
    +'<tr><td>2026-2027-1</td><td>大学英语(三)</td><td>必修</td><td>3</td><td>88</td><td>3.7</td></tr>'
    +'<tr><td>2025-2026-2</td><td>刑法学</td><td>必修</td><td>4</td><td>91</td><td>4.0</td></tr></table>';
  if(u.indexOf('kbxx_classroom')>=0) return '';
  return '';},getStatusBarHeight:function(){return 84;},showNativeLogin:function(){window.__asked=(window.__asked||0)+1;},
  showNotification:function(){},openInApp:function(){},clearSession:function(){},getSystemDarkMode:function(){return 1;},
  setStatusTheme:function(){},openBrowser:function(){}};
  localStorage.setItem('jwxt_login','1');S.loggedIn=true;applyLoggedInUI();setThemeMode('dark');}"""

def main():
    OUT.mkdir(parents=True, exist_ok=True)
    with sync_playwright() as pw:
        b = pw.chromium.launch(executable_path=CHROME, args=['--no-sandbox'])
        pg = b.new_context(viewport={'width': 390, 'height': 844},
                           device_scale_factor=2).new_page()
        errs = []
        logs = []
        pg.on('pageerror', lambda e: errs.append(str(e)[:120]))
        pg.on('console', lambda m: logs.append(m.type + ': ' + m.text[:160]))
        pg.goto(APP, wait_until='load'); pg.wait_for_timeout(700)
        pg.evaluate(BOOT, FIX); pg.wait_for_timeout(250)

        pg.evaluate("()=>{S.queryType='self';S.semester='2026-2027-1';document.getElementById('queryWeek').value='12';runQuery(true);}")
        pg.wait_for_timeout(1400); pg.screenshot(path=str(OUT/'01-grid.png'))

        pg.evaluate("()=>{showWeekPicker();}"); pg.wait_for_timeout(500)
        pg.screenshot(path=str(OUT/'02-weekpicker.png'))
        pg.evaluate("()=>{closeWeekPicker();showSemesterPicker();}"); pg.wait_for_timeout(500)
        pg.screenshot(path=str(OUT/'03-sempicker.png'))

        pg.evaluate("()=>{closeSemesterPicker();pickWeek(3);setScheduleForm('list');}")
        pg.wait_for_timeout(800); pg.screenshot(path=str(OUT/'04-list.png'))

        pg.evaluate("()=>{setScheduleForm('grid');selectType('score');document.getElementById('querySemester').value='2026-2027-1';runQuery(true);}")
        pg.wait_for_timeout(1200); pg.screenshot(path=str(OUT/'05-score.png'))

        pg.evaluate("()=>{showTab('settings');refreshCacheList();}"); pg.wait_for_timeout(700)
        pg.evaluate("()=>{var e=document.getElementById('settingsCacheSummary');if(e)e.scrollIntoView({block:'center'});}")
        pg.wait_for_timeout(300); pg.screenshot(path=str(OUT/'06-settings-cache.png'))

        pg.evaluate("()=>{showTab('main');selectType('self');document.getElementById('queryWeek').value='12';runQuery(true);}")
        pg.wait_for_timeout(1100)
        pg.evaluate("()=>{toggleResultFloat('cacheInfoSection');}"); pg.wait_for_timeout(600)
        pg.screenshot(path=str(OUT/'07-cache-panel.png'))

        pg.evaluate("()=>{toggleResultFloat('cacheInfoSection');}")
        pg.wait_for_timeout(300)
        pg.evaluate("()=>{if(!document.getElementById('querySection').classList.contains('open'))toggleResultFloat('querySection');}")
        pg.wait_for_timeout(600); pg.screenshot(path=str(OUT/'08-query-menu.png'))
        pg.evaluate("()=>{selectType('self');}"); pg.wait_for_timeout(700)
        pg.evaluate("()=>{var q=document.getElementById('querySection');q.scrollTop=0;}")
        pg.screenshot(path=str(OUT/'08b-query-form.png'))
        print('week input =', pg.evaluate("()=>document.getElementById('queryWeek').value"))

        pg.evaluate("()=>{toggleResultFloat('querySection');selectType('empty');document.getElementById('queryWeek').value=String(currentWeek());runQuery(true);}")
        pg.wait_for_timeout(1200); pg.screenshot(path=str(OUT/'09-empty-room.png'))

        pg.evaluate("()=>{doLogout();}"); pg.wait_for_timeout(800)
        pg.screenshot(path=str(OUT/'10-loggedout.png'))
        LOG = ROOT / 'review' / 'logs'
        LOG.mkdir(parents=True, exist_ok=True)
        jslog = pg.evaluate("()=>window.__dumpLog?window.__dumpLog():''")
        (LOG / 'webview.log').write_text('\n'.join(logs) + '\n--- page errors ---\n' + '\n'.join(errs) + '\n--- __JSLOG ---\n' + (jslog or ''), encoding='utf-8')
        print('errors:', errs)
        print('console lines:', len(logs), '| jslog lines:', len(jslog.splitlines()) if jslog else 0)
        # 未登录首屏：新开一个干净上下文，不写登录标记
        pg2 = b.new_context(viewport={'width': 390, 'height': 844}, device_scale_factor=2, color_scheme='dark').new_page()
        pg2.goto(APP, wait_until='load'); pg2.wait_for_timeout(800)
        pg2.screenshot(path=str(OUT/'11-login-first.png'))
        b.close()

if __name__ == '__main__':
    main()
