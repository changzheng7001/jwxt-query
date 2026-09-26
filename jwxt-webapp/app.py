#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
中央司法警官学院教务系统 - 图形化查询面板 (WebUI)
基于 Python 标准库（无第三方依赖），启动本地网页服务，浏览器打开即用。
复用 jwxt_query.py 的全部查询逻辑（13 类查询 + 会话自动重登）。

用法:
    python webui.py            # 默认端口 8765，自动打开浏览器
    python webui.py --port 9000
    python webui.py --no-browser

依赖: 与 jwxt_query.py 相同（requests + beautifulsoup4）
"""
import argparse
import json
import os
import sys
import threading
import webbrowser
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

# 复用主脚本逻辑
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
if SCRIPT_DIR not in sys.path:
    sys.path.insert(0, SCRIPT_DIR)
from jwxt_query import (JwxtSession, CONFIG, SCHEDULE, WEEK_DAYS,
                        get_current_week, get_current_weekday, get_current_period,
                        find_duplicate_conflicts)

# ---------- 全局会话（登录一次复用） ----------
_session = None
_session_lock = threading.Lock()
_account_display = ''


def get_session(account='', password=''):
    """公网部署版：每次请求新建会话，账号密码必须从请求传入，不存任何凭证。"""
    if not account or not password:
        raise ValueError('请先输入学号和教务系统密码')
    s = JwxtSession()
    ok, msg = s.login(account, password)
    if not ok:
        raise ValueError(f'登录失败: {msg}')
    s.refresh_runtime_config()
    return s


def run_query(q):
    """执行一次查询，返回可序列化结果。"""
    qtype = q.get('type', '')
    name = str(q.get("name") or "").strip()
    week = str(q.get("week") or "").strip()
    weekday = str(q.get("weekday") or "").strip()
    semester = str(q.get("semester") or "").strip()
    batch = str(q.get("batch") or "").strip()
    current = bool(q.get('current'))

    s = get_session(q.get('account', ''), q.get('password', ''))

    # 当前时刻自动填周次/星期/节次
    jc1 = jc2 = ''
    if current:
        week = str(get_current_week())
        weekday = str(get_current_weekday())
        period = get_current_period()
        if period:
            jc1 = period[:2] if len(period) >= 2 else period
            jc2 = period[2:] if len(period) == 4 else jc1

    if qtype == 'teacher':
        if not name:
            raise ValueError('教师课表需要填写教师姓名')
        result = s.query_teacher_schedule(name, week, weekday, jc1, jc2)
        conflicts = find_duplicate_conflicts(result.get('courses', []))
        if conflicts:
            result['duplicate_name_warning'] = True
            result['conflict_slots'] = [
                {'weekday': k[0], 'weekday_name': WEEK_DAYS[k[0] - 1] if 1 <= k[0] <= 7 else '',
                 'period': k[1], 'courses': v}
                for k, v in sorted(conflicts.items())]
        result['_kind'] = 'schedule'
        return result

    if qtype == 'classroom':
        if not name:
            raise ValueError('教室课表需要填写教室名称（如 3-307）')
        result = s.query_classroom_schedule(room_name=name, week=week, weekday=weekday, jc1=jc1, jc2=jc2)
        result['_kind'] = 'schedule'
        return result

    if qtype == 'self':
        result = s.query_self_schedule(week, weekday, jc1, jc2)
        result['_kind'] = 'schedule'
        return result

    if qtype == 'class':
        if not name:
            raise ValueError('班级课表需要填写班级名称（如 心理矫治班24）')
        result = s.query_class_schedule(name, week, weekday, jc1, jc2)
        result['_kind'] = 'schedule'
        return result

    if qtype == 'course':
        if not name:
            raise ValueError('课程课表需要填写课程名称')
        result = s.query_course_schedule(name, week, weekday, jc1, jc2)
        result['_kind'] = 'schedule'
        return result

    if qtype == 'score':
        result = s.query_scores(semester=semester, kcmc=name)
        result['_kind'] = 'score'
        return result

    if qtype == 'gpa':
        scores = s.query_scores()
        result = s.compute_gpa(scores)
        result['_kind'] = 'gpa'
        return result

    if qtype == 'progress':
        result = s.query_progress()
        result['_kind'] = 'progress'
        return result

    if qtype == 'exam':
        is_quiz = batch in ('平时考察', '提前期末')
        result = s.query_quiz(batch) if is_quiz else s.query_exam(batch or '期末', semester)
        result['_kind'] = 'exam'
        return result

    if qtype == 'profile':
        result = s.query_profile()
        result['_kind'] = 'profile'
        return result

    if qtype == 'elective':
        result = s.query_elective_rounds()
        result['_kind'] = 'elective'
        return result

    if qtype == 'electives':
        result = s.query_elective_results(semester)
        result['_kind'] = 'electives'
        return result

    if qtype == 'calendar':
        result = s.query_calendar(semester)
        result['_kind'] = 'calendar'
        return result

    raise ValueError(f'未知查询类型: {qtype}')


# ---------- 前端页面（内嵌） ----------
PAGE_HTML = r'''<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>中警院教务查询面板</title>
<style>
:root{
  --bg:#0f172a; --panel:#1e293b; --panel2:#273449; --line:#334155;
  --text:#e2e8f0; --muted:#94a3b8; --accent:#38bdf8; --accent2:#0ea5e9;
  --ok:#34d399; --warn:#fbbf24; --err:#f87171;
}
*{box-sizing:border-box;margin:0;padding:0}
body{background:var(--bg);color:var(--text);font-family:"Segoe UI","Microsoft YaHei",system-ui,sans-serif;min-height:100vh}
.wrap{max-width:1100px;margin:0 auto;padding:20px}
header{display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:10px;padding-bottom:14px;border-bottom:1px solid var(--line);margin-bottom:18px}
h1{font-size:20px;font-weight:700;letter-spacing:.5px}
h1 span{color:var(--accent)}
.badge{font-size:12px;color:var(--muted);background:var(--panel2);padding:4px 10px;border-radius:20px;border:1px solid var(--line)}
.grid{display:grid;grid-template-columns:320px 1fr;gap:18px}
@media(max-width:900px){.grid{grid-template-columns:1fr}}
.panel{background:var(--panel);border:1px solid var(--line);border-radius:14px;padding:16px}
.panel h2{font-size:14px;color:var(--accent);margin-bottom:12px;font-weight:600}
label{display:block;font-size:12px;color:var(--muted);margin:10px 0 4px}
select,input[type=text],input[type=password]{width:100%;background:var(--panel2);border:1px solid var(--line);color:var(--text);border-radius:8px;padding:9px 12px;font-size:14px;outline:none}
select:focus,input:focus{border-color:var(--accent2)}
.row{display:flex;gap:10px}
.row>*{flex:1}
.checks{display:flex;gap:12px;margin-top:12px;align-items:center}
.checks label{display:flex;align-items:center;gap:5px;margin:0;font-size:13px;color:var(--text)}
.btn{width:100%;margin-top:14px;background:linear-gradient(135deg,var(--accent2),var(--accent));border:none;color:#083344;font-weight:700;font-size:15px;padding:11px;border-radius:9px;cursor:pointer}
.btn:hover{filter:brightness(1.1)}
.btn:disabled{opacity:.5;cursor:not-allowed}
.hint{font-size:11px;color:var(--muted);margin-top:8px;line-height:1.5}
.status{font-size:12px;margin-top:10px;min-height:18px}
.status.ok{color:var(--ok)} .status.err{color:var(--err)} .status.info{color:var(--muted)}
#result{min-height:200px}
.empty{color:var(--muted);text-align:center;padding:60px 0;font-size:14px}
.sec-title{font-size:14px;font-weight:700;margin:18px 0 10px;color:var(--text);display:flex;align-items:center;gap:8px}
.sec-title:first-child{margin-top:0}
.day-block{margin-bottom:16px}
.day-name{font-size:13px;font-weight:700;color:var(--accent);margin-bottom:8px;border-left:3px solid var(--accent);padding-left:8px}
.cards{display:grid;grid-template-columns:repeat(auto-fill,minmax(300px,1fr));gap:10px}
.course-card{background:var(--panel2);border:1px solid var(--line);border-radius:10px;padding:12px}
.course-card .nm{font-weight:700;font-size:14px}
.course-card .pd{display:inline-block;background:rgba(56,189,248,.15);color:var(--accent);font-size:11px;padding:2px 8px;border-radius:12px;margin:6px 4px 6px 0}
.course-card .meta{font-size:12px;color:var(--muted);line-height:1.7}
.course-card .meta b{color:var(--text);font-weight:600}
table{width:100%;border-collapse:collapse;font-size:13px;background:var(--panel2);border-radius:10px;overflow:hidden}
th,td{padding:9px 10px;text-align:left;border-bottom:1px solid var(--line)}
th{background:rgba(56,189,248,.08);color:var(--accent);font-weight:600;white-space:nowrap}
tr:hover td{background:rgba(255,255,255,.02)}
.gpa-cards{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:12px}
.gpa-card{background:var(--panel2);border:1px solid var(--line);border-radius:12px;padding:16px;text-align:center}
.gpa-card .v{font-size:26px;font-weight:800;color:var(--accent)}
.gpa-card .k{font-size:12px;color:var(--muted);margin-top:4px}
.warn-list{margin-top:12px}
.warn-item{background:rgba(251,191,36,.08);border:1px solid rgba(251,191,36,.3);color:var(--warn);padding:8px 12px;border-radius:8px;margin:6px 0;font-size:13px}
.profile-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:10px}
.profile-item{background:var(--panel2);border:1px solid var(--line);border-radius:10px;padding:10px 12px}
.profile-item .k{font-size:11px;color:var(--muted)}
.profile-item .v{font-size:14px;margin-top:3px;word-break:break-all}
.cal-week{display:flex;gap:6px;align-items:center;padding:6px 0;border-bottom:1px solid rgba(51,65,85,.5);font-size:12px}
.cal-week.cur{background:rgba(56,189,248,.1);border-radius:8px;padding:6px 8px}
.cal-week .wk{width:34px;font-weight:700;color:var(--accent)}
.cal-week .d{width:44px;text-align:center}
.cal-week .memo{color:var(--muted);flex:1}
.tag-now{background:var(--ok);color:#083344;font-size:11px;padding:1px 8px;border-radius:10px;font-weight:700}
.note{font-size:12px;color:var(--muted);margin-top:8px;line-height:1.6}
.warning-box{background:rgba(251,191,36,.08);border:1px solid rgba(251,191,36,.3);color:var(--warn);padding:8px 12px;border-radius:8px;margin-bottom:12px;font-size:13px}
</style>
</head>
<body>
<div class="wrap">
<header>
  <h1><span>中警院</span> 教务查询面板</h1>
  <div class="badge" id="sysBadge">加载中…</div>
</header>

<div class="grid">
  <!-- 左侧：参数区 -->
  <div class="panel">
    <h2>查询设置</h2>
    <label>学号</label>
    <input type="text" id="account" placeholder="请输入学号" autocomplete="username">
    <label>教务系统密码</label>
    <input type="password" id="password" placeholder="请输入教务系统密码" autocomplete="current-password">
    <label>查询类型</label>
    <select id="qtype">
      <option value="teacher">👨‍🏫 教师课表</option>
      <option value="classroom">🏫 教室课表</option>
      <option value="self">🧑‍🎓 我的课表</option>
      <option value="class">👥 班级课表</option>
      <option value="course">📚 课程课表</option>
      <option value="score">📊 成绩查询</option>
      <option value="gpa">🧮 绩点与预警</option>
      <option value="progress">📈 学习进度</option>
      <option value="exam">📝 考试安排</option>
      <option value="profile">🪪 学籍卡片</option>
      <option value="elective">🕐 选课轮次</option>
      <option value="electives">✅ 选课结果</option>
      <option value="calendar">🗓️ 教学周历</option>
    </select>

    <div id="nameBox"><label>名称（教师 / 教室 / 班级 / 课程）</label>
      <input type="text" id="qname" placeholder="如：代嘉幸 / 3-307 / 心理矫治班24" autocomplete="off"></div>

    <div id="semBox" style="display:none"><label>学年学期（留空=当前）</label>
      <input type="text" id="qsem" placeholder="如 2026-2027-1" autocomplete="off"></div>

    <div id="batchBox" style="display:none"><label>考试批次</label>
      <select id="qbatch">
        <option value="期末">期末考试</option>
        <option value="期初">期初考试</option>
        <option value="期中">期中考试</option>
        <option value="提前期末">随堂·提前期末</option>
        <option value="平时考察">随堂·平时考察</option>
      </select></div>

    <div id="wkBox">
      <div class="row" style="margin-top:10px">
        <div><label>周次（留空=全部）</label><input type="text" id="qweek" placeholder="如 3" autocomplete="off"></div>
        <div><label>星期（1-7）</label><input type="text" id="qweekday" placeholder="如 1" autocomplete="off"></div>
      </div>
    </div>

    <div class="checks">
      <label><input type="checkbox" id="qcurrent"> 查询当前时刻</label>
    </div>

    <button class="btn" id="runBtn">🔍 开始查询</button>
    <div class="hint" id="paramHint"></div>
    <div class="status" id="status"></div>
  </div>

  <!-- 右侧：结果区 -->
  <div class="panel" style="min-height:400px">
    <h2>查询结果</h2>
    <div id="result"><div class="empty">选择查询类型并设置参数，点击「开始查询」<br>结果将在这里展示</div></div>
  </div>
</div>
</div>

<script>
const TYPE_META = {
  teacher:{name:true, week:true, hint:'输入教师姓名，支持模糊；同名教师会提示冲突。教室名无需楼名前缀。'},
  classroom:{name:true, week:true, hint:'教室名称如 3-307、1-407、3C5、射击馆（不带"三教/一教"前缀）。'},
  self:{name:false, week:true, hint:'查询登录账号本人的课表。'},
  class:{name:true, week:true, hint:'班级名称如 心理矫治班24、涉外法治班24。'},
  course:{name:true, week:true, hint:'按课程名称查询全校所有开课班次。'},
  score:{name:true, sem:true, week:false, namePh:'课程名筛选（留空=全部）', hint:'成绩按学期汇总；如需全部学期留空学期。'},
  gpa:{name:false, week:false, hint:'基于全部成绩计算 GPA、加权均分与挂科预警。'},
  progress:{name:false, week:false, hint:'按培养方案查看各课程体系的学分完成进度。'},
  exam:{name:false, sem:true, batch:true, week:false, hint:'默认查期末考试；切换批次可查随堂考试。'},
  profile:{name:false, week:false, hint:'查看完整学籍卡片（基本信息 + 入学信息）。'},
  elective:{name:false, week:false, hint:'查看当前开放的选课轮次（无开放轮次时为空）。'},
  electives:{name:false, sem:true, week:false, hint:'查看当前学期的选课结果。'},
  calendar:{name:false, sem:true, week:false, hint:'学期教学周历，本周高亮显示。'},
};

const $=id=>document.getElementById(id);
let curType='teacher';

function updateUI(){
  const m=TYPE_META[curType]||{name:false,week:false};
  $('nameBox').style.display=m.name?'':'none';
  if(m.name)$('qname').placeholder=m.namePh||'如：代嘉幸 / 3-307 / 心理矫治班24';
  $('semBox').style.display=m.sem?'':'none';
  $('batchBox').style.display=m.batch?'':'none';
  $('wkBox').style.display=m.week?'':'none';
  if(!m.week){$('qcurrent').checked=false;}
  $('paramHint').textContent=m.hint||'';
}
$('qtype').addEventListener('change',e=>{curType=e.target.value;updateUI();});
updateUI();

function esc(s){return String(s==null?'':s).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));}

function setStatus(msg,cls){const s=$('status');s.textContent=msg;s.className='status '+(cls||'');}

async function runQuery(){
  const btn=$('runBtn');btn.disabled=true;setStatus('正在查询，请稍候…','info');
  const m=TYPE_META[curType]||{};
  const body={account:$('#account').value,password:$('#password').value,
              type:curType,name:$('qname').value,week:$('qweek').value,weekday:$('qweekday').value,
              semester:$('qsem').value,batch:$('qbatch').value,current:$('qcurrent').checked};
  try{
    const r=await fetch('/api/query',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(body)});
    const j=await r.json();
    if(!j.ok){setStatus(j.error||'查询失败','err');btn.disabled=false;return;}
    render(j.data);setStatus('查询完成','ok');
  }catch(e){setStatus('请求失败: '+e.message,'err');}
  btn.disabled=false;
}
$('runBtn').addEventListener('click',runQuery);
$('qcurrent').addEventListener('change',e=>{
  if(e.target.checked){$('qweek').value='';$('qweekday').value='';}
});

function render(d){
  const el=$('result');
  if(d.error&&!(d.courses&&d.courses.length)){el.innerHTML='<div class="empty">⚠ '+esc(d.error)+'</div>';return;}
  const kind=d._kind;
  if(kind==='schedule')renderSchedule(el,d);
  else if(kind==='score')renderScore(el,d);
  else if(kind==='gpa')renderGpa(el,d);
  else if(kind==='progress')renderProgress(el,d);
  else if(kind==='exam')renderExam(el,d);
  else if(kind==='profile')renderProfile(el,d);
  else if(kind==='elective')renderElective(el,d);
  else if(kind==='electives')renderElectives(el,d);
  else if(kind==='calendar')renderCalendar(el,d);
  else el.innerHTML='<div class="empty">未识别的返回类型</div>';
}

function renderSchedule(el,d){
  const courses=d.courses||[];
  if(!courses.length){el.innerHTML='<div class="empty">该条件下未查询到课程 🎉</div>';return;}
  let html='';
  if(d.duplicate_name_warning){
    html+='<div class="warning-box">⚠ 检测到同名冲突：同一时段出现多门不同课程，结果可能合并了同名教师。</div>';
  }
  html+='<div class="sec-title">共 '+courses.length+' 条课程记录</div>';
  const byDay={};
  courses.forEach(c=>{const k=c.weekday||0;(byDay[k]=byDay[k]||[]).push(c);});
  Object.keys(byDay).sort((a,b)=>a-b).forEach(k=>{
    const dayName=byDay[k][0].weekday_name||('周'+(+k));
    html+='<div class="day-block"><div class="day-name">'+esc(dayName)+'</div><div class="cards">';
    byDay[k].sort((a,b)=>(a.period||'').localeCompare(b.period||'')).forEach(c=>{
      const parts=[];
      if(c.teacher)parts.push('<b>教师:</b>'+esc(c.teacher));
      if(c.classroom)parts.push('<b>教室:</b>'+esc(c.classroom));
      if(c.classes)parts.push('<b>班级:</b>'+esc(c.classes));
      if(c.week)parts.push('<b>周次:</b>'+esc(c.week));
      html+='<div class="course-card"><div class="nm">'+esc(c.name)+'</div>'
        +'<span class="pd">'+esc(c.period_label||'')+'</span>'
        +'<div class="meta">'+parts.join('&nbsp;&nbsp;')+'</div></div>';
    });
    html+='</div></div>';
  });
  if(d.remarks&&d.remarks.length)html+='<div class="note">📌 备注：'+esc(d.remarks.join('；'))+'</div>';
  el.innerHTML=html;
}

function tableHtml(headers,rows){
  let h='<table><tr>'+headers.map(x=>'<th>'+esc(x)+'</th>').join('')+'</tr>';
  rows.forEach(r=>{h+='<tr>'+headers.map(k=>'<td>'+esc(r[k]??'')+'</td>').join('')+'</tr>';});
  return h+'</table>';
}

function renderScore(el,d){
  const c=d.courses||[];
  if(!c.length){el.innerHTML='<div class="empty">未查询到成绩</div>';return;}
  const keys=Object.keys(c[0]).filter(k=>k!=='序号');
  el.innerHTML='<div class="sec-title">共 '+c.length+' 门课程成绩</div>'+tableHtml(keys,c);
}

function renderGpa(el,d){
  let html='<div class="gpa-cards">'
    +'<div class="gpa-card"><div class="v">'+esc(d.gpa??'—')+'</div><div class="k">平均绩点 GPA</div></div>'
    +'<div class="gpa-card"><div class="v">'+esc(d.weighted_avg??'—')+'</div><div class="k">加权平均分</div></div>'
    +'<div class="gpa-card"><div class="v">'+esc(d.passed_credits??'—')+'/'+esc(d.total_credits??'—')+'</div><div class="k">已修学分/总学分</div></div>'
    +'<div class="gpa-card"><div class="v" style="color:'+(d.failed_count>0?'var(--warn)':'var(--ok)')+'">'+esc(d.failed_count??0)+'</div><div class="k">挂科/未通过</div></div>'
    +'</div>';
  const f=d.failed_courses||[];
  if(f.length){html+='<div class="warn-list">'+(Array.isArray(f)?f:Object.values(f)).map(x=>'<div class="warn-item">⚠ '+esc(typeof x==='string'?x:JSON.stringify(x))+'</div>').join('')+'</div>';}
  if(d.details&&d.details.length){html+='<div class="sec-title">明细（'+d.details.length+'）</div>'+tableHtml(Object.keys(d.details[0]),d.details);}
  el.innerHTML=html;
}

function renderProgress(el,d){
  const items=d.items||[];
  if(!items.length){el.innerHTML='<div class="empty">未查询到学习进度</div>';return;}
  const total=items.find(i=>i.system==='总计');
  let html='';
  if(total){html+='<div class="gpa-cards">'
    +'<div class="gpa-card"><div class="v">'+esc(total.required)+'</div><div class="k">要求学分</div></div>'
    +'<div class="gpa-card"><div class="v">'+esc(total.done)+'</div><div class="k">已修学分</div></div>'
    +'<div class="gpa-card"><div class="v">'+esc(total.studying)+'</div><div class="k">正修读</div></div>'
    +'<div class="gpa-card"><div class="v">'+esc(total.remaining)+'</div><div class="k">还需学分</div></div></div>';}
  html+='<div class="sec-title">各课程体系（'+items.length+'）</div>'
    +tableHtml(['课程体系','属性','要求学分','已修','正修读','还需'],items.map(i=>({system:i.system,attr:i.attr,required:i.required,done:i.done,studying:i.studying,remaining:i.remaining})));
  el.innerHTML=html;
}

function renderExam(el,d){
  const e=d.exams||[];
  if(!e.length){el.innerHTML='<div class="empty">'+esc(d.batch||'期末')+'考试：暂无安排 🎉</div>';return;}
  const keys=Object.keys(e[0]).filter(k=>k!=='序号');
  el.innerHTML='<div class="sec-title">'+esc(d.batch||'')+'考试安排（'+e.length+'）</div>'+tableHtml(keys,e);
}

function renderProfile(el,d){
  const info=d.info||{};
  const keys=Object.keys(info);
  let html='<div class="profile-grid">';
  keys.forEach(k=>{html+='<div class="profile-item"><div class="k">'+esc(k)+'</div><div class="v">'+esc(info[k])+'</div></div>';});
  html+='</div>';
  el.innerHTML=html;
}

function renderElective(el,d){
  const r=d.rounds||[];
  if(!r.length){el.innerHTML='<div class="empty">当前没有开放的选课轮次</div>';return;}
  const keys=Object.keys(r[0]);
  el.innerHTML='<div class="sec-title">选课轮次（'+r.length+'）</div>'+tableHtml(keys,r);
}

function renderElectives(el,d){
  const c=d.courses||[];
  if(!c.length){el.innerHTML='<div class="empty">未查询到选课结果</div>';return;}
  const keys=Object.keys(c[0]);
  el.innerHTML='<div class="sec-title">已选课程（'+c.length+'）</div>'+tableHtml(keys,c);
}

function renderCalendar(el,d){
  const w=d.weeks||[];
  if(!w.length){el.innerHTML='<div class="empty">未查询到教学周历</div>';return;}
  let html='<div class="sec-title">教学周历（'+w.length+' 周）</div>';
  w.forEach(week=>{
    const wk=week['周次']||week['']||'';
    const cur=String(wk)===String(d.current_week||'');
    html+='<div class="cal-week'+(cur?' cur':'')+'"><span class="wk">'+esc(wk)+'周</span>'
      +'<span class="d">'+esc(week['星期一']||'')+'</span><span class="d">'+esc(week['星期二']||'')+'</span>'
      +'<span class="d">'+esc(week['星期三']||'')+'</span><span class="d">'+esc(week['星期四']||'')+'</span>'
      +'<span class="d">'+esc(week['星期五']||'')+'</span><span class="d">'+esc(week['星期六']||'')+'</span>'
      +'<span class="d">'+esc(week['星期日']||'')+'</span>'
      +'<span class="memo">'+esc(week['备注']||'')+'</span>'
      +(cur?'<span class="tag-now">本周</span>':'')+'</div>';
  });
  el.innerHTML=html;
}

async function loadSysInfo(){
  try{
    const r=await fetch('/api/sysinfo');const j=await r.json();
    if(j.ok){
      $('sysBadge').textContent='学期 '+j.semester+' · 第'+j.current_week+'周 · 周'+j.current_weekday+' · 账号 '+j.account;
    }
  }catch(e){}
}
loadSysInfo();
</script>
</body>
</html>
'''


# ---------- HTTP 服务 ----------
class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        sys.stderr.write('[webui] %s\n' % (fmt % args))

    def _send_json(self, obj, code=200):
        body = json.dumps(obj, ensure_ascii=False).encode('utf-8')
        self.send_response(code)
        self.send_header('Content-Type', 'application/json; charset=utf-8')
        self.send_header('Content-Length', str(len(body)))
        self.send_header('Cache-Control', 'no-store')
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path in ('/', '/index.html'):
            body = PAGE_HTML.encode('utf-8')
            self.send_response(200)
            self.send_header('Content-Type', 'text/html; charset=utf-8')
            self.send_header('Content-Length', str(len(body)))
            self.end_headers()
            self.wfile.write(body)
            return
        if self.path == '/api/sysinfo':
            try:
                s = get_session()
                info = {
                    'ok': True,
                    'semester': CONFIG.get('xnxqh', ''),
                    'current_week': get_current_week(),
                    'current_weekday': get_current_weekday(),
                    'account': q.get('account',''),
                }
            except Exception as e:
                info = {'ok': False, 'error': str(e)}
            self._send_json(info)
            return
        self._send_json({'ok': False, 'error': 'Not Found'}, 404)

    def do_POST(self):
        if self.path != '/api/query':
            self._send_json({'ok': False, 'error': 'Not Found'}, 404)
            return
        try:
            length = int(self.headers.get('Content-Length', 0))
            q = json.loads(self.rfile.read(length).decode('utf-8'))
            data = run_query(q)
            self._send_json({'ok': True, 'data': data})
        except ValueError as e:
            self._send_json({'ok': False, 'error': str(e)})
        except Exception as e:
            self._send_json({'ok': False, 'error': f'{type(e).__name__}: {e}'})





# ---------- WSGI 入口（部署用） ----------
def application(environ, start_response):
    """供 PythonAnywhere / gunicorn 等 WSGI 服务器调用。"""
    from io import BytesIO
    import urllib.parse
    # 构造一个最小的 handler
    class WSGIAdapter:
        def __init__(self, environ, start_response):
            self.environ = environ
            self.start_response = start_response
            self.status = '200 OK'
            self.headers = []
            self._response_body = b''
        def start_response(self, status, headers):
            self.status = status
            self.headers = headers
        def finish(self, body):
            self._response_body = body if isinstance(body, bytes) else body.encode('utf-8')
    # 用 wsgiref 的简单方式：直接调用 Handler 逻辑不现实，改用另一种方式：
    # 简单粗暴：用 werkzeug 风格不现实。我们用 wsgiref.util 把 environ 喂给 BaseHTTPRequestHandler。
    # 实际做法：写个 WSGI 包装，把 environ 转成 HTTP 请求喂给 Handler。
    return _wsgi_app(environ, start_response)


def _wsgi_app(environ, start_response):
    import io
    method = environ['REQUEST_METHOD']
    path = environ.get('PATH_INFO', '/')
    length = int(environ.get('CONTENT_LENGTH', 0) or 0)
    body = environ['wsgi.input'].read(length) if length else b''
    # 构造响应
    resp_body = b''
    status = '200 OK'
    headers = [('Content-Type', 'text/html; charset=utf-8')]

    if method == 'GET' and path == '/':
        resp_body = PAGE_HTML.encode('utf-8')
    elif method == 'GET' and path == '/api/info':
        resp_body = '{"ok":false,"error":"请先输入学号密码"}'.encode('utf-8')
        headers = [('Content-Type', 'application/json; charset=utf-8')]
    elif method == 'POST' and path == '/api/query':
        try:
            q = json.loads(body.decode('utf-8'))
            data = run_query(q)
            resp_body = json.dumps({'ok': True, 'data': data}, ensure_ascii=False).encode('utf-8')
        except ValueError as e:
            resp_body = json.dumps({'ok': False, 'error': str(e)}, ensure_ascii=False).encode('utf-8')
        except Exception as e:
            resp_body = json.dumps({'ok': False, 'error': f'{type(e).__name__}: {e}'}, ensure_ascii=False).encode('utf-8')
        headers = [('Content-Type', 'application/json; charset=utf-8')]
    else:
        status = '404 Not Found'
        resp_body = b'{"ok":false,"error":"Not Found"}'
        headers = [('Content-Type', 'application/json; charset=utf-8')]

    start_response(status, headers)
    return [resp_body]

def main():
    parser = argparse.ArgumentParser(description='中警院教务查询面板')
    parser.add_argument('--port', type=int, default=8765, help='端口号（默认 8765）')
    parser.add_argument('--no-browser', action='store_true', help='不自动打开浏览器')
    args = parser.parse_args()

    server = ThreadingHTTPServer(('0.0.0.0', args.port), Handler)
    url = f'http://127.0.0.1:{args.port}/'
    print('=' * 52)
    print('  中警院教务查询面板已启动')
    print(f'  地址: {url}')
    print('  按 Ctrl+C 停止服务')
    print('=' * 52)
    if not args.no_browser:
        threading.Timer(0.8, lambda: webbrowser.open(url)).start()
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print('\n已停止')


if __name__ == '__main__':
    main()
