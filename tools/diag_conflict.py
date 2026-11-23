#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""诊断：同一 (weekday,period) 格内多门课、字段缺失分布"""
import json, re, shutil, sys, tempfile
from pathlib import Path
from playwright.sync_api import sync_playwright

ROOT = Path(__file__).resolve().parent.parent
WEB = ROOT / 'jwxt-webapp'
CHROME = '/home/user/.cache/ms-playwright/chromium-1234/chrome-linux64/chrome'

def run(sample, typ='class'):
    tmp = Path(tempfile.mkdtemp())
    for f in ['index.html']:
        shutil.copy(WEB / f, tmp / f)
    for d in ['js', 'ui']:
        shutil.copytree(WEB / d, tmp / d)
    html = (ROOT / 'tests' / 'fixtures' / sample).read_text(encoding='utf-8')
    with sync_playwright() as pw:
        b = pw.chromium.launch(executable_path=CHROME)
        pg = b.new_page()
        pg.goto((tmp / 'index.html').as_uri())
        pg.wait_for_timeout(400)
        res = pg.evaluate("""([html,typ])=>{
          const out=parseSchedule(html,typ);
          const list=out.courses||[];
          const cells={};
          list.forEach(c=>{
            const k=String(c.weekday)+'|'+String(c.period);
            (cells[k]=cells[k]||[]).push({name:c.name,teacher:c.teacher,teacherAll:c.teacherAll,classroom:c.classroom,classes:c.classes});
          });
          const multi=Object.entries(cells).filter(([k,v])=>v.length>1).map(([k,v])=>({cell:k,n:v.length,items:v.slice(0,6)}));
          return {count:list.length, cells:Object.keys(cells).length, multiCount:multi.length, multi:multi.slice(0,12),
                  emptyName:list.filter(c=>!c.name).length, emptyTeacher:list.filter(c=>!c.teacher&&!c.teacherAll).length};
        }""", [html, typ])
        b.close()
    shutil.rmtree(tmp, ignore_errors=True)
    return res

if __name__ == '__main__':
    sample = sys.argv[1] if len(sys.argv) > 1 else 'kbxx-class.html'
    typ = sys.argv[2] if len(sys.argv) > 2 else 'class'
    r = run(sample, typ)
    print(json.dumps({k: r[k] for k in ('count', 'cells', 'multiCount', 'emptyName', 'emptyTeacher')}, ensure_ascii=False))
    for m in r['multi'][:8]:
        print('格', m['cell'], '共', m['n'], '门')
        for it in m['items']:
            print('   ', it['name'], '| 师:', it['teacher'], '| 全部师:', it['teacherAll'], '| 室:', it['classroom'])
