#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import requests
from bs4 import BeautifulSoup
import re, json, sys, os
from datetime import datetime
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from jwxt_query import JwxtSession, CONFIG, load_credentials

creds = load_credentials()
if not creds.get('account') or not creds.get('password'):
    print(json.dumps({"error": "无凭证", "open": False}, ensure_ascii=False)); sys.exit(0)

s = JwxtSession()
ok, msg = s.login(creds['account'], creds['password'])
if not ok:
    print(json.dumps({"error": f"登录失败: {msg}", "open": False}, ensure_ascii=False)); sys.exit(0)
s.refresh_runtime_config()
session = s.session
base = CONFIG['base_url'] + '/jsxsd'
now = datetime.now()
result = {"open": False, "now": now.strftime("%Y-%m-%d %H:%M:%S"), "semester": CONFIG['xnxqh'], "signup_time": "", "courses": []}

try:
    r = session.get(base + '/kscj/cxbmxk_query', timeout=15)
    sp = BeautifulSoup(r.text, 'html.parser')
    text = sp.get_text(' ', strip=True)
    m = re.search(r'报名时间\s*([\d\-: ]+)\s*至\s*([\d\-: ]+)', text)
    if m:
        result["signup_time"] = f"{m.group(1).strip()} 至 {m.group(2).strip()}"
        try:
            ss = datetime.strptime(m.group(1).strip(), "%Y-%m-%d %H:%M:%S")
            se = datetime.strptime(m.group(2).strip(), "%Y-%m-%d %H:%M:%S")
            if ss <= now <= se:
                result["open"] = True
        except: pass
    for table in sp.find_all('table'):
        for row in table.find_all('tr'):
            cells = [c.get_text(strip=True) for c in row.find_all(['td','th'])]
            for i, ct in enumerate(cells):
                if re.match(r'202[56]-(春季|秋季)', ct) and i+1 < len(cells):
                    cn = cells[i+1]
                    if cn and len(cn)>1 and cn not in result["courses"]:
                        result["courses"].append(cn)
except Exception as e:
    result["error"] = str(e)

try:
    r2 = session.get(base + '/xsxk/xklc_list', timeout=15)
    sp2 = BeautifulSoup(r2.text, 'html.parser')
    rounds = []
    for table in sp2.find_all('table'):
        for row in table.find_all('tr')[1:]:
            cells = [c.get_text(strip=True) for c in row.find_all(['td','th'])]
            if cells and any(cells):
                rounds.append(' | '.join(cells))
    if rounds:
        result["xk_rounds"] = rounds
        if not result["open"]:
            result["open"] = True
except Exception as e:
    result["xk_error"] = str(e)

print(json.dumps(result, ensure_ascii=False, indent=2))
