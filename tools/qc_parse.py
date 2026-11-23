#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""V273 解析质检：全部 kbxx 样本 + theory 样本，0 空名/0 空教师/0 污染"""
import json, re
from pathlib import Path
from playwright.sync_api import sync_playwright
ROOT=Path(__file__).resolve().parent.parent
APP=(ROOT/'jwxt-webapp'/'index.html').as_uri()
CHROME='/home/user/.cache/ms-playwright/chromium-1234/chrome-linux64/chrome'
FX={}
for k in ['class','class2','teacher','classroom','course','course2']:
    p=ROOT/'tests'/'fixtures'/f'kbxx-{k}.html'
    if p.exists(): FX[k]=p.read_text(encoding='utf-8',errors='ignore')
TH={}
for k in ['2026f','2026s','2025spring']:
    p=ROOT/'tests'/'fixtures'/f'theory-{k}.html'
    if p.exists(): TH[k]=p.read_text(encoding='utf-8',errors='ignore')
BOOT="""()=>{window.Android={httpRequest:function(){return '';},getStatusBarHeight:function(){return 84;},showNativeLogin:function(){},showNotification:function(){},openInApp:function(){},clearSession:function(){},getSystemDarkMode:function(){return 0;},setStatusTheme:function(){},openBrowser:function(){}};localStorage.setItem('jwxt_login','1');S.loggedIn=true;applyLoggedInUI();}"""
QC="""([fx,th])=>{
  const out={};
  const badName=L=>/^(?:第?[0-9一二三四五六七八九十]+周|[0-9]{1,2}-[0-9]{1,2}节)/.test(L)||/(?:班|队)\\s*\\d{0,6}$/.test(L)||/^\\d{4}级/.test(L)||/^[A-Z]?\\d{3,4}$/.test(L);
  const badTeacher=t=>/(?:班|队)\\s*\\d{0,6}$/.test(t)||/^\\d{4}级/.test(t)||/第.{0,3}周|周次|节次|楼|教室/.test(t);
  for(const [k,h] of Object.entries(fx)){
    const list=(parseSchedule(h,k.replace(/2$/,''))||{}).courses||[];
    const empty=list.filter(c=>!c.name||!String(c.name).trim());
    const noT=list.filter(c=>!c.teacher||!String(c.teacher).trim());
    const pollT=list.filter(c=>c.teacher&&badTeacher(String(c.teacher)));
    const pollN=list.filter(c=>c.name&&badName(String(c.name)));
    out[k]={n:list.length,emptyName:empty.length,noTeacher:noT.length,pollTeacher:pollT.length,pollName:pollN.length,
      samples:{empty:empty.slice(0,3).map(c=>({w:c.weekday,p:c.period,t:c.teacher,cl:c.classes})),
               noT:noT.slice(0,3).map(c=>({name:c.name,w:c.weekday,p:c.period})),
               pollT:pollT.slice(0,3).map(c=>({name:c.name,t:c.teacher})),
               pollN:pollN.slice(0,3).map(c=>({name:c.name}))}};
  }
  for(const [k,h] of Object.entries(th)){
    const list=(parseTheorySchedule(h)||{}).courses||parseTheorySchedule(h)||[];
    const empty=list.filter(c=>!c.name||!String(c.name).trim());
    const noT=list.filter(c=>!c.teacher||!String(c.teacher).trim());
    out['theory-'+k]={n:list.length,emptyName:empty.length,noTeacher:noT.length};
  }
  return out;}"""
with sync_playwright() as pw:
    b=pw.chromium.launch(executable_path=CHROME,args=['--no-sandbox'])
    pg=b.new_context(viewport={'width':390,'height':844}).new_page()
    errs=[]; pg.on('pageerror',lambda e:errs.append(str(e)[:120]))
    pg.goto(APP,wait_until='load'); pg.wait_for_timeout(400)
    pg.evaluate(BOOT)
    res=pg.evaluate(QC,[FX,TH])
    print(json.dumps(res,ensure_ascii=False,indent=1))
    print('pageerrors:',errs)
    b.close()