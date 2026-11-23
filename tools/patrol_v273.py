#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""V273 体检：深色五页对比度 + 浅色多教师/缓存回归 + 溢出 + renderResult 耗时"""
import json
from pathlib import Path
from playwright.sync_api import sync_playwright
from PIL import Image
import statistics
ROOT=Path(__file__).resolve().parent.parent
APP=(ROOT/'jwxt-webapp'/'index.html').as_uri()
OUT=ROOT/'review'/'shots-v273'; OUT.mkdir(parents=True,exist_ok=True)
CHROME='/home/user/.cache/ms-playwright/chromium-1234/chrome-linux64/chrome'
F={k:(ROOT/'tests'/'fixtures'/f).read_text(encoding='utf-8',errors='ignore') for k,f in {
 'f':'theory-2026f.html','s':'theory-2026s.html','p25':'theory-2025spring.html','cal':'jxzl.html',
 'cls':'kbxx-class.html','tch':'kbxx-teacher.html','room':'kbxx-classroom.html','kc':'kbxx-course.html',
 'score':'score.html','pidx':'progress-idx.html','prog':'progress.html','exam':'exam.html','elec':'electives.html'}.items()}
BOOT="""(a)=>{window.__P=a;window.Android={httpRequest:function(m,url){var u=String(url);
 if(u.indexOf('2025-2026-2')>=0)return window.__P.s; if(u.indexOf('2024-2025-2')>=0)return window.__P.p25;
 if(u.indexOf('xskb_list')>=0)return window.__P.f; if(u.indexOf('jxzl_query')>=0)return window.__P.cal;
 if(u.indexOf('kbxx_xzb_ifr')>=0)return window.__P.cls; if(u.indexOf('kbxx_teacher_ifr')>=0)return window.__P.tch;
 if(u.indexOf('kbxx_classroom_ifr')>=0)return window.__P.room; if(u.indexOf('kbxx_kc_ifr')>=0)return window.__P.kc;
 if(u.indexOf('cjcx_list')>=0)return window.__P.score; if(u.indexOf('xxwcqk_idxOntx')>=0)return window.__P.pidx;
 if(u.indexOf('xxwcqkOnkctx')>=0)return window.__P.prog; if(u.indexOf('xsksap_list')>=0)return window.__P.exam;
 if(u.indexOf('loadXsxkjgList')>=0)return window.__P.elec;
 return '';},getStatusBarHeight:function(){return 84;},showNativeLogin:function(){},showNotification:function(){},
 openInApp:function(){},clearSession:function(){},getSystemDarkMode:function(){return 0;},setStatusTheme:function(){},openBrowser:function(){}};
 localStorage.setItem('jwxt_login','1');S.loggedIn=true;applyLoggedInUI();}"""
SAMPLE="""()=>{
 const out=[]; const els=document.querySelectorAll('#resultContent *');
 for(const el of els){
   if(out.length>=80)break;
   const own=Array.from(el.childNodes).some(n=>n.nodeType===3&&n.textContent.trim());
   if(!own)continue;
   const cs=getComputedStyle(el); const fs=parseFloat(cs.fontSize);
   if(fs<11||cs.visibility==='hidden'||cs.display==='none')continue;
   const r=el.getBoundingClientRect();
   if(r.width<4||r.height<4||r.top<0||r.bottom>innerHeight)continue;
   out.push({t:(el.textContent||'').trim().slice(0,18),c:cs.color,x:r.x,y:r.y,w:r.width,h:r.height,tag:el.tagName});
 }
 return out;}"""
OVERFLOW="""()=>{
 const bad=[];
 document.querySelectorAll('#resultContent *').forEach(el=>{
   if(el.scrollWidth>el.clientWidth+2&&el.clientWidth>0){
     const cs=getComputedStyle(el);
     if(cs.overflowX==='hidden'||cs.textOverflow==='ellipsis'||cs.whiteSpace==='nowrap')
       bad.push({t:(el.textContent||'').trim().slice(0,24),sw:el.scrollWidth,cw:el.clientWidth,cls:el.className});
   }});
 return bad.slice(0,10);}"""
def lum(rgb):
    def ch(v):
        v/=255.0
        return v/12.92 if v<=0.03928 else ((v+0.055)/1.055)**2.4
    r,g,b=[ch(x) for x in rgb[:3]]
    return 0.2126*r+0.7152*g+0.0722*b
def ratio(c1,c2):
    l1,l2=lum(c1),lum(c2)
    if l1<l2: l1,l2=l2,l1
    return (l1+0.05)/(l2+0.05)
def parse_color(s):
    import re
    m=re.findall(r'[\d.]+',s)
    return tuple(float(x) for x in m[:3])
def contrast_report(png, samples, scale=2):
    im=Image.open(png).convert('RGB'); W,H=im.size; px=im.load()
    bad=[]; mins=[]
    for s in samples:
        x0,y0=int(s['x']*scale),int(s['y']*scale); x1,y1=int((s['x']+s['w'])*scale),int((s['y']+s['h'])*scale)
        ring=[]
        for xx in range(max(0,x0-4),min(W,x1+4)):
            for yy in (max(0,y0-4),min(H-1,y1+3)):
                ring.append(px[min(W-1,max(0,xx)),min(H-1,max(0,yy))])
        for yy in range(max(0,y0-4),min(H,y1+4)):
            for xx in (max(0,x0-4),min(W-1,x1+3)):
                ring.append(px[min(W-1,max(0,xx)),min(H-1,max(0,yy))])
        if not ring: continue
        bg=tuple(statistics.median(c[i] for c in ring) for i in range(3))
        r=ratio(parse_color(s['c']),bg)
        mins.append(r)
        if r<4.5: bad.append({'t':s['t'],'ratio':round(r,2),'color':s['c'],'bg':[round(v) for v in bg]})
    return {'min':round(min(mins),2) if mins else None,'n':len(mins),'bad':bad[:12]}
with sync_playwright() as pw:
    b=pw.chromium.launch(executable_path=CHROME,args=['--no-sandbox'])
    pg=b.new_context(viewport={'width':390,'height':844},device_scale_factor=2).new_page()
    errs=[]; pg.on('pageerror',lambda e:errs.append(str(e)[:120]))
    pg.goto(APP,wait_until='load'); pg.wait_for_timeout(400)
    pg.evaluate(BOOT,F)
    report={}
    # 深色五页
    pg.evaluate("()=>setThemeMode('dark')")
    for typ,sem in [('score','2026-2027-1'),('gpa',''),('progress',''),('exam','2026-2027-1'),('electives','2026-2027-1')]:
        pg.evaluate("""([t,sm])=>{S.queryType=t;if(sm)document.getElementById('querySemester').value=sm;runQuery(true);}""",[typ,sem])
        pg.wait_for_timeout(1200)
        pg.evaluate("()=>window.scrollTo(0,0)")
        pg.wait_for_timeout(200)
        p=OUT/f'dark-{typ}.png'; pg.screenshot(path=str(p))
        samples=pg.evaluate(SAMPLE)
        report['dark-'+typ]=contrast_report(p,samples)
    # 浅色：班级网格/列表（多教师）
    pg.evaluate("()=>setThemeMode('light')")
    pg.evaluate("()=>{S.queryType='class';document.getElementById('queryName').value='2026级';document.getElementById('queryWeek').value='9';runQuery(true);}")
    pg.wait_for_timeout(1500)
    pg.screenshot(path=str(OUT/'light-class-grid.png'))
    report['light-class-grid-overflow']=pg.evaluate(OVERFLOW)
    pg.evaluate("()=>setScheduleForm('list')"); pg.wait_for_timeout(800)
    pg.screenshot(path=str(OUT/'light-class-list.png'))
    report['light-class-list-overflow']=pg.evaluate(OVERFLOW)
    # 多教师条目是否存在
    report['multi-teacher']=pg.evaluate("()=>{const l=S.lastCourses||[];return l.filter(c=>(c.teacherAll||c.teacher||'').split(/[,，、]/).length>=2).slice(0,4).map(c=>({n:c.name,t:c.teacherAll||c.teacher}));}")
    # 浅色缓存：设置页 + 浮层
    pg.evaluate("()=>{showTab('settings');refreshCacheList();}")
    pg.wait_for_timeout(600)
    pg.evaluate("()=>{var e=document.getElementById('settingsCacheSummary');if(e)e.scrollIntoView({block:'center'});}")
    pg.wait_for_timeout(300)
    pg.screenshot(path=str(OUT/'light-settings-cache.png'))
    pg.evaluate("()=>{showTab('main');selectType('self');document.getElementById('queryWeek').value='12';runQuery(true);}")
    pg.wait_for_timeout(1200)
    pg.evaluate("()=>{if(!document.getElementById('cacheInfoSection').classList.contains('open'))toggleResultFloat('cacheInfoSection');}")
    pg.wait_for_timeout(600)
    pg.screenshot(path=str(OUT/'light-cache-panel.png'))
    report['cache-panel']=pg.evaluate("()=>{var e=document.getElementById('cacheInfoSection');return {ch:e.clientHeight,sh:e.scrollHeight,open:e.classList.contains('open'),scrollable:e.scrollHeight>e.clientHeight};}")
    # renderResult 构建耗时（1691 条班级数据）
    report['render-ms']=pg.evaluate("()=>{const d=parseSchedule(window.__P.cls,'class');const t0=performance.now();renderResult('class',d);const t1=performance.now();return {n:d.courses.length,ms:Math.round(t1-t0)};}")
    print(json.dumps(report,ensure_ascii=False,indent=1))
    print('pageerrors:',errs)
    b.close()