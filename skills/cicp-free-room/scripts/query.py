#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
中警院「空教室」极速查询（自包含，新对话即用）
- 无缓存：自动登录 + 拉全量课表 → 本地缓存（约2~4s，仅首次/跨周）
- 有缓存：直接本地解析，零网络（约0.2s）
用法：
  python3 query.py                    # 今天当前时段的空教室
  python3 query.py --weekday 2 --period 下午   # 周二下午
  python3 query.py --weekday 1 --period 上午   # 周一上午
  python3 query.py --period 晚上               # 今天晚上
  python3 query.py --cold             # 强制重建缓存（课表变了用）
时段: 上午=1-2+3-4节  下午=5-6+7-8节  晚上=9-10+11节
"""
import re, os, sys, time, argparse
import requests

BASE = os.path.dirname(os.path.abspath(__file__))
JWXT = "https://jwxt.cicp.edu.cn"
# 教务系统凭证（本机私有 skill，可在此修改）
ACCOUNT = "202415121048"
PASSWORD = "Lzq,4892305278"
# 已稳定配置，无需每次探测
SEMESTER = "2026-2027-1"
JCMSID = "65C2A7B09C5742189505942AA120C0D7"
SEMESTER_START = "2026-08-31"   # 校历第1周周一

CACHE = os.path.join(BASE, ".rooms_cache.html")
PERIODS = {"上午": ["0102", "0304"], "下午": ["0506", "0708"], "晚上": ["0910", "11"]}


def encode_password(account, password, scode, sxh):
    code = account + "%%%" + password
    encoded = ""
    rem = scode
    for i in range(len(code)):
        if i < 20 and i < len(sxh):
            try:
                n = int(sxh[i])
            except (ValueError, IndexError):
                n = 0
            encoded += code[i] + rem[:n]
            rem = rem[n:]
        else:
            encoded += code[i:]
            break
    return encoded


def current_week():
    from datetime import date
    return (date.today() - date(2026, 8, 31)).days // 7 + 1


def fetch_and_cache():
    """登录 + 拉全量课表 + 写缓存，返回耗时"""
    t = time.time()
    sess = requests.Session()
    sess.headers.update({"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
                         "Referer": JWXT + "/"})
    key = sess.post(JWXT + "/Logon.do?method=logon&flag=sess", timeout=10).text.strip()
    if "#" not in key:
        sys.exit(f"获取加密密钥失败: {key[:100]}")
    scode, sxh = key.split("#", 1)
    enc = encode_password(ACCOUNT, PASSWORD, scode, sxh)
    r = sess.post(JWXT + "/Logon.do?method=logon",
                  data={"userAccount": ACCOUNT, "userPassword": "", "encoded": enc},
                  timeout=10, allow_redirects=True)
    data = {"xnxqh": SEMESTER, "kbjcmsid": JCMSID, "skyx": "", "xqid": "1", "jzwid": "",
            "jxlvalue": "", "skjsid": "", "skjs": "", "jsid": "",
            "zc1": "", "zc2": "", "skxq1": "", "skxq2": "", "jc1": "", "jc2": ""}
    html = sess.post(JWXT + "/jsxsd/kbcx/kbxx_classroom_ifr", data=data, timeout=20).text
    open(CACHE, "w").write(html)
    return time.time() - t


def weeks_cover(cell, w):
    for x in re.findall(r"([0-9][0-9,\-，]*?)\s*周", cell):
        for p in re.split(r"[,，]", x):
            p = p.strip()
            if not p:
                continue
            if "-" in p:
                lo, hi = p.split("-", 1)
                if int(lo) <= w <= int(hi):
                    return True
            elif int(p) == w:
                return True
    return False


def parse(html, weekday, per_list, week):
    tbl = re.search(r"<table[^>]*>(.*?)</table>", html, re.S).group(1)
    rows = re.findall(r"<tr[^>]*>(.*?)</tr>", tbl, re.S)
    def cells(r):
        return [re.sub(r"<[^>]+>", "", c).strip().replace("&nbsp;", "")
                for c in re.findall(r"<t[dh][^>]*>(.*?)</t[dh]>", r, re.S)]
    periods = cells(rows[1])[1:]
    cols = [1 + (weekday - 1) * 7 + periods.index(p) for p in per_list]
    free = []
    for r in rows[2:]:
        c = cells(r)
        if len(c) < 2 or not c[0].strip():
            continue
        if all((not c[co]) or (not weeks_cover(c[co], week)) for co in cols):
            free.append(c[0].strip())
    return free


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--weekday", type=int, default=None, help="星期1-7，缺省=今天")
    ap.add_argument("--period", default=None, choices=list(PERIODS), help="时段，缺省=当前时段")
    ap.add_argument("--cold", action="store_true", help="强制重建缓存")
    args = ap.parse_args()

    week = current_week()
    today = int(time.strftime("%w")) or 7          # 0=周日→7
    weekday = args.weekday or today
    if args.period:
        period = args.period
    else:                                          # 按当前时间猜时段
        hhmm = int(time.strftime("%H%M"))
        period = "上午" if 800 <= hhmm < 1430 else ("下午" if 1430 <= hhmm < 1900 else "晚上")

    wall = time.time()
    if args.cold or not os.path.exists(CACHE):
        dl = fetch_and_cache()
        src = f"网络拉取({dl:.2f}s,已建缓存)"
    else:
        src = "本地缓存(0网络)"
    html = open(CACHE).read()
    free = parse(html, weekday, PERIODS[period], week)
    print(f"【第{week}周 周{weekday} {period}】空教室 {len(free)} 间 | {src} | 耗时{time.time()-wall:.2f}s")
    for r in sorted(free):
        print("  ", r)


if __name__ == "__main__":
    main()
