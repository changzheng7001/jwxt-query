#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""回归：从官网返回时，周/日课表是否还原到离开前那一屏"""
import json, time
from pathlib import Path
from playwright.sync_api import sync_playwright
ROOT = Path(__file__).resolve().parent.parent
APP = (ROOT/'jwxt-webapp'/'index.html').resolve().as_uri()
OUT = ROOT/'review'/'shots-return'; OUT.mkdir(parents=True, exist_ok=True)
FIX = {k:(ROOT/'tests'/'fixtures'/f).read_text(encoding='utf-8') for k,f in
       {'f':'theory-2026f.html','s':'theory-2026s.html','p25':'theory-2025spring.html','cal':'jxzl.html',
        'cls':'kbxx-class.html','tch':'kbxx-teacher.html','room':'kbxx-classroom.html','kc':'kbxx-course.html'}.items()}
CHROME='/home/user/.cache/ms-playwright/chromium-1234/chrome-linux64/chrome'
BOOT = """(a)=>{window.__P=a;window.__Android={httpRequest:function(m,url){var u=String(url);
  if(u.indexOf('2025-2026-2')>=0) return window.__P.s; if(u.indexOf('2024-2025-2')>=0) return window.__P.p25;
  if(u.indexOf('xskb_list')>=0) return window.__P.f; if(u.indexOf('jxzl_query')>=0) return window.__P.cal;
  if(u.indexOf('kbxx_xzb_ifr')>=0) return window.__P.cls; if(u.indexOf('kbxx_teacher_ifr')>=0) return window.__P.tch;
  if(u.indexOf('kbxx_classroom_ifr')>=0) return window.__P.room; if(u.indexOf('kbxx_kc_ifr')>=0) return window.__P.kc;
  return '';},getStatusBarHeight:function(){return 84;},showNativeLogin:function(){},showNotification:function(){},
  openInApp:function(){},clearSession:function(){},getSystemDarkMode:function(){return 0;},setStatusTheme:function(){},openBrowser:function(){}};
  window.Android=window.__Android; localStorage.setItem('jwxt_login','1'); S.loggedIn=true; applyLoggedInUI(); setThemeMode('light');}"""

def run():
    with sync_playwright() as pw:
        b=pw.chromium.launch(executable_path=CHROME,args=['--no-sandbox'])
        pg=b.new_context(viewport={'width':390,'height':844},device_scale_factor=2).new_page()
        errs=[]; pg.on('pageerror',lambda e:errs.append(str(e)[:100]))
        pg.goto(APP,wait_until='load'); pg.wait_for_timeout(600)
        pg.evaluate(BOOT,FIX); pg.wait_for_timeout(200)
        # 建缓存：整学期课表
        pg.evaluate("()=>{S.queryType='self';document.getElementById('queryWeek').value='12';runQuery(true);}")
        pg.wait_for_timeout(1500)
        keys=pg.evaluate("()=>Object.keys(localStorage).filter(k=>k.indexOf('_self')>=0)")
        # A. 周课表 + 第 3 周
        pg.evaluate("()=>{try{saveReturnState=function(){};}catch(e){}}")
        pg.evaluate("""(st)=>localStorage.setItem('jwxt_return_state',JSON.stringify(st))""",
                    {"page":"result","type":"self","week":"3","form":"grid","view":"week","ts":int(__import__("time").time()*1000)})
        pg.reload(wait_until='load'); pg.wait_for_timeout(1200)
        a=pg.evaluate("()=>({week:document.getElementById('queryWeek').value,body:document.body.className,label:document.getElementById('resultLabel').textContent,logged:S.loggedIn,qtype:S.queryType,form:S.scheduleForm,android:typeof window.Android,raw:localStorage.getItem('jwxt_return_state')})")
        pg.screenshot(path=str(OUT/'A-week-grid.png'))
        # B. 日课表 + 第 5 周
        pg.evaluate("()=>{try{saveReturnState=function(){};}catch(e){}}")
        pg.evaluate("""(st)=>localStorage.setItem('jwxt_return_state',JSON.stringify(st))""",
                    {"page":"result","type":"self","week":"5","form":"list","view":"today","ts":int(__import__("time").time()*1000)})
        pg.reload(wait_until='load'); pg.wait_for_timeout(1200)
        bstate=pg.evaluate("()=>({week:document.getElementById('queryWeek').value,body:document.body.className,label:document.getElementById('resultLabel').textContent})")
        pg.screenshot(path=str(OUT/'B-week-list.png'))
        # C. 主页面（未进结果页）
        pg.evaluate("()=>{try{saveReturnState=function(){};}catch(e){}}")
        pg.evaluate("""(st)=>localStorage.setItem('jwxt_return_state',JSON.stringify(st))""",
                    {"page":"main","type":"self","week":"9","form":"grid","ts":int(__import__("time").time()*1000)})
        pg.reload(wait_until='load'); pg.wait_for_timeout(1000)
        c=pg.evaluate("()=>({body:document.body.className})")
        pg.screenshot(path=str(OUT/'C-main.png'))
        # D. 非 self：教师课表网格 第 9 周（先建缓存，reload 后走 runQuery 缓存还原）
        pg.evaluate(BOOT,FIX); pg.wait_for_timeout(200)
        pg.evaluate("()=>{S.queryType='teacher';document.getElementById('queryName').value='示例教师';document.getElementById('queryWeek').value='9';runQuery(true);}")
        pg.wait_for_timeout(1500)
        pg.evaluate("()=>{try{saveReturnState=function(){};}catch(e){}}")
        pg.evaluate("""(st)=>localStorage.setItem('jwxt_return_state',JSON.stringify(st))""",
                    {"page":"result","type":"teacher","week":"9","name":"示例教师","form":"grid","view":"week","ts":int(__import__("time").time()*1000)})
        pg.reload(wait_until='load'); pg.wait_for_timeout(1500)
        d=pg.evaluate("()=>({qtype:S.queryType,name:document.getElementById('queryName').value,week:document.getElementById('queryWeek').value,body:document.body.className,label:document.getElementById('resultLabel').textContent,cells:document.querySelectorAll('#resultContent td, #resultContent .cell').length})")
        pg.screenshot(path=str(OUT/'D-teacher-grid.png'))
        # E. 非 self：班级课表列表 第 9 周
        pg.evaluate(BOOT,FIX); pg.wait_for_timeout(200)
        pg.evaluate("()=>{S.queryType='class';document.getElementById('queryName').value='2026级示例二班';document.getElementById('queryWeek').value='9';runQuery(true);}")
        pg.wait_for_timeout(1500)
        pg.evaluate("()=>{try{saveReturnState=function(){};}catch(e){}}")
        pg.evaluate("""(st)=>localStorage.setItem('jwxt_return_state',JSON.stringify(st))""",
                    {"page":"result","type":"class","week":"9","name":"2026级示例二班","form":"list","view":"week","ts":int(__import__("time").time()*1000)})
        pg.reload(wait_until='load'); pg.wait_for_timeout(1500)
        e=pg.evaluate("()=>({qtype:S.queryType,name:document.getElementById('queryName').value,week:document.getElementById('queryWeek').value,body:document.body.className,label:document.getElementById('resultLabel').textContent,rows:document.querySelectorAll('#resultContent .today-item, #resultContent li, #resultContent tr').length})")
        pg.screenshot(path=str(OUT/'E-class-list.png'))
        # F. 深色：本人周课表网格 第 3 周返回
        pg.evaluate(BOOT,FIX); pg.wait_for_timeout(200)
        pg.evaluate("()=>{setThemeMode('dark');S.queryType='self';document.getElementById('queryWeek').value='3';runQuery(true);}")
        pg.wait_for_timeout(1500)
        pg.evaluate("()=>{try{saveReturnState=function(){};}catch(e){}}")
        pg.evaluate("""(st)=>localStorage.setItem('jwxt_return_state',JSON.stringify(st))""",
                    {"page":"result","type":"self","week":"3","form":"grid","view":"week","ts":int(__import__("time").time()*1000)})
        pg.reload(wait_until='load'); pg.wait_for_timeout(1500)
        f=pg.evaluate("()=>({theme:document.documentElement.getAttribute('data-theme'),week:document.getElementById('queryWeek').value,body:document.body.className,label:document.getElementById('resultLabel').textContent})")
        pg.screenshot(path=str(OUT/'F-dark-week-grid.png'))
        print('keys:',keys)
        print('A:',json.dumps(a,ensure_ascii=False))
        print('B:',json.dumps(bstate,ensure_ascii=False))
        print('C:',json.dumps(c,ensure_ascii=False))
        print('D:',json.dumps(d,ensure_ascii=False))
        print('E:',json.dumps(e,ensure_ascii=False))
        print('F:',json.dumps(f,ensure_ascii=False))
        print('errors:',errs)
        b.close()
run()
