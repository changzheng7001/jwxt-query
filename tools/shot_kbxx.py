#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""用真实班级/教师/教室课表页面渲染结果页，核对课程名与教师名"""
from pathlib import Path
from playwright.sync_api import sync_playwright
ROOT=Path(__file__).resolve().parent.parent
APP=(ROOT/'jwxt-webapp'/'index.html').as_uri()
OUT=ROOT/'review'/'shots-kbxx'; OUT.mkdir(parents=True,exist_ok=True)
CHROME='/home/user/.cache/ms-playwright/chromium-1234/chrome-linux64/chrome'
PAGES={k:(ROOT/'tests'/'fixtures'/f'kbxx-{k}.html').read_text(encoding='utf-8') for k in ['class','teacher','classroom']}
BOOT="""(pages)=>{window.__P=pages;window.Android={httpRequest:function(m,url){var u=String(url);
  if(u.indexOf('kbxx_xzb_ifr')>=0) return window.__P.class;
  if(u.indexOf('kbxx_teacher_ifr')>=0) return window.__P.teacher;
  if(u.indexOf('kbxx_classroom_ifr')>=0) return window.__P.classroom;
  if(u.indexOf('xskb_list')>=0) return '';
  return '';},getStatusBarHeight:function(){return 84;},showNativeLogin:function(){},showNotification:function(){},
  openInApp:function(){},clearSession:function(){},getSystemDarkMode:function(){return 0;},setStatusTheme:function(){},openBrowser:function(){}};
  localStorage.setItem('jwxt_login','1');S.loggedIn=true;applyLoggedInUI();setThemeMode('light');}"""
with sync_playwright() as pw:
    b=pw.chromium.launch(executable_path=CHROME,args=['--no-sandbox'])
    for typ,name in [('class','示例班级23'),('teacher','示例教师')]:
        pg=b.new_context(viewport={'width':390,'height':844},device_scale_factor=2).new_page()
        errs=[]; pg.on('pageerror',lambda e:errs.append(str(e)[:100]))
        pg.goto(APP,wait_until='load'); pg.wait_for_timeout(500)
        pg.evaluate(BOOT,PAGES); pg.wait_for_timeout(200)
        pg.evaluate("""([t,n])=>{S.queryType=t;document.getElementById('queryName').value=n;document.getElementById('queryWeek').value='9';runQuery(false);}""",[typ,name])
        pg.wait_for_timeout(1500)
        pg.screenshot(path=str(OUT/f'{typ}.png'))
        print(typ,'errors',errs[:2])
        pg.close()
    b.close()
