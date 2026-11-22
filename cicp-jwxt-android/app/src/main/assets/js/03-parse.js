/* ===== 03-parse ===== 原 index.html 内联脚本第 1122-1623 行（顺序分片，逻辑未改） */
function saveSemesterCalendar() {
  var date = document.getElementById('semesterStartInput').value;
  var weeks = parseInt(document.getElementById('semesterWeeksInput').value, 10);
  if (!/^\d{4}-\d{2}-\d{2}$/.test(date) || !isFinite(weeks) || weeks < 1 || weeks > 30) { alert('请填写有效的开学周一日期和 1–30 周的学期周数'); return; }
  localStorage.setItem('jwxt_semester_start', date);
  localStorage.setItem('jwxt_semester_weeks', String(weeks));
  SEMESTER_START = new Date(date + 'T00:00:00');
  renderTodayCourses(); refreshOngoing();
}

function weekMonday(week) {
  const w = parseInt(week) || 1;
  const d = new Date(semesterStartDate() + 'T00:00:00');
  d.setDate(d.getDate() + (w - 1) * 7);
  return d.getFullYear() + '-' + String(d.getMonth()+1).padStart(2,'0') + '-' + String(d.getDate()).padStart(2,'0');
}

function parseHTML(html) { return new DOMParser().parseFromString(html, 'text/html'); }

/* ============ 学期理论课表（/jsxsd/xskb/xskb_list.do）============
   表结构：#timetable 一行 = 一个大节，7 列 = 周一~周日；
   每格可含多个 div.kbcontent1，每个块内 font 依次是
   课程名(可能带班级) / 周次 / 教室 / 教师(name=wkxx)。
   这份数据是整学期全量，按周筛选交给渲染层（weekInRange）。 */
function parseTheorySchedule(html) {
  const doc = parseHTML(html);
  const table = doc.querySelector('#timetable') || firstTable(doc);
  if (!table) return { courses: [], error: '未找到学期理论课表' };
  const WD = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  const rows = table.querySelectorAll('tr');
  const raw = [];
  let rowIdx = -1;
  for (const row of rows) {
    const cells = row.querySelectorAll('td');
    if (!cells.length) continue;
    rowIdx++;
    if (rowIdx >= 6) break;
    const th = row.querySelector('th');
    const rowLabel = th ? th.textContent.replace(/\s+/g, ' ').trim() : '';
    for (let ci = 0; ci < cells.length && ci < 7; ci++) {
      /* 真实可见块是 div.kbcontent（含教师/节次），kbcontent1 是隐藏副本，只作兜底 */
      const primary = cells[ci].querySelectorAll('div.kbcontent');
      const blocks = primary.length ? primary : cells[ci].querySelectorAll('div.kbcontent1');
      for (const b of blocks) {
        const fonts = Array.from(b.querySelectorAll('font'));
        let cur = null;
        for (const f of fonts) {
          const title = (f.getAttribute('title') || '').trim();
          const val = f.textContent.replace(/\s+/g, ' ').trim();
          if (!title) {
            if (val) {
              if (cur) raw.push(cur);
              cur = { name: val, teacher: '', week: '', period: '', classroom: '', classes: '',
                      weekday: ci + 1, weekdayName: WD[ci], periodLabel: rowLabel };
            }
            continue;
          }
          if (!cur) continue;
          if (title === '教师') cur.teacher = cleanTeacherName(val);
          else if (title.indexOf('周次') >= 0) {
            const wm = val.match(/^([^\[\]]*?)\(\s*周\s*\)/);
            cur.week = wm ? wm[1].trim() : val;
            const pm = val.match(/\[([0-9\-]+)\s*节\]/);
            if (pm) {
              /* 只保留首末两节：单节 [01节] → 0101（否则会被当成“第1-2节”画成两节高） */
              var segs = pm[1].split('-').map(function (x) { return ('0' + parseInt(x, 10)).slice(-2); });
              cur.period = segs[0] + segs[segs.length - 1];
            }
          }
          else if (title === '教室') cur.classroom = val;
          else if (title === '班级') cur.classes = val.replace(/^班级[:：]\s*/, '');
        }
        if (cur) raw.push(cur);
      }
    }
  }
  /* 课程名尾部的括号是班级；同名同格的重复块去掉 */
  const seen = {}; let out = [];
  raw.forEach(c => {
    /* 学时/实验这类纯备注行不是课程（如“(讲课:51)”），丢掉 */
    if (/^(讲课|实验|上机|学时|周学时)/.test(c.name) || /^[(（].*[:：].*[)）]$/.test(c.name)) return;
    const m = c.name.match(/^(.*)[（(]([^()（）]*)[)）]$/);
    if (m && m[1].trim()) {
      var seg = m[2].trim();
      /* 括号里多数是上课班级/分组，但也可能是课名本身的序号：
         「形势与政策(三)」「警察防卫与控制(二)」里的 (三)(二) 属于课名，不能当班级剥掉。
         只有看起来像班级/分组的才剥离，纯序号（中文数字、单字母）保留在课名里。 */
      var isOrdinal = /^[一二三四五六七八九十百零〇0-9]{1,3}$/.test(seg) || /^[A-Za-z]$/.test(seg);
      var looksClass = /班|级|组|队|专业|系|学院|方向|教学班/.test(seg) || !isOrdinal;
      if (looksClass) { c.name = m[1].trim(); if (!c.classes) c.classes = seg; }
    }
    if (!c.name) return;
    const k = [c.name, c.weekday, c.period, c.week, c.classroom, c.teacher].join('|');
    if (seen[k]) return;
    seen[k] = 1; out.push(c);
  });
  /* 跨大节的课在表格里会被切成两格（例如 [05-06节] + [07节]），解析后是两条记录，
     这里把同一门课里“首尾相接”的两段并回一条，避免 3 小节连上的课显示成 2 段 + 1 段。 */
  const mergedCourses = mergeAdjacentPeriods(out);
  /* 同一门课不同周由不同老师上：把同格同名课的其它周次整理成“分段授课”，
     详情弹窗里原本就有这块展示，换到“学期理论课表”后要在这里补回来。 */
  var plans = {};
  out.forEach(function (c) {
    var gk = [c.name, c.weekday, c.period].join('|');
    (plans[gk] || (plans[gk] = [])).push({ weeks: c.week, teacher: c.teacher, room: c.classroom });
  });
  out.forEach(function (c) {
    var g = plans[[c.name, c.weekday, c.period].join('|')] || [];
    if (g.length > 1) c.teacherPlan = g;
  });
  return { courses: mergedCourses, count: mergedCourses.length, source: 'theory' };
}

/* 教师字段带职称（“朱晓杰讲师（高校）”“李娜副教授”），只留姓名 */
function mergeAdjacentPeriods(list) {
  var groups = {};
  list.forEach(function (c) {
    var k = [c.name, c.weekday, c.teacher, c.classroom, c.week, c.classes].join('|');
    (groups[k] || (groups[k] = [])).push(c);
  });
  var merged = [];
  Object.keys(groups).forEach(function (k) {
    var rows = groups[k].sort(function (a, b) { return parseInt(a.period, 10) - parseInt(b.period, 10); });
    var cur = null;
    rows.forEach(function (c) {
      var pm = String(c.period || '').match(/^(\d{2})(\d{2})$/);
      if (!pm) { merged.push(c); return; }
      var first = parseInt(pm[1], 10), last = parseInt(pm[2], 10);
      if (cur && first === cur.last + 1) {
        cur.last = last;
        /* 注意要写到课程对象上（写到 cur 上等于没改，第二段又被丢掉） */
        cur.row.period = ('0' + cur.first).slice(-2) + ('0' + cur.last).slice(-2);
        return;
      }
      cur = {row: c, first: first, last: last};
      merged.push(c);
    });
  });
  return merged;
}
function cleanTeacherName(v) {
  var t = String(v || '').replace(/\s+/g, '').replace(/[,，、;；]+$/, '');
  /* 先去掉尾部的“（高校）（外聘）”这类后缀，再剥职称 */
  t = t.replace(/[（(](高校|外聘|兼职|聘用|校内|校外)[)）]$/, '');
  t = t.replace(/(副教授|讲师|教授|助教|高级实验师|实验师|研究员|高级工程师|工程师)$/, '');
  t = t.replace(/(未知|待定|暂无)/g, '');
  return t;
}
function firstTable(doc) { return doc.querySelector('table'); }
function esc(s) { return String(s==null?'':s).replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c])); }

// ============ 全校教师名单（教师名精确解析依赖） ============
// 真实全校教师名单：优先用缓存，缓存缺失时由 ensureTeacherSet 自动空参预拉一次
var TEACHER_SET = null;
var _teacherSetLoading = false;

function loadTeacherSetFromCache() {
  try {
    var tc = getCache('browse_teacher_' + selectedSemester());
    if (tc && tc.data && Array.isArray(tc.data.teachers) && tc.data.teachers.length) {
      TEACHER_SET = new Set(tc.data.teachers);
    }
  } catch (e) {}
  return TEACHER_SET;
}

// 解析课表前调用：确保教师名单就绪。已就绪/未登录/正在拉取时直接返回，不阻塞已有流程
function ensureTeacherSet() {
  if (TEACHER_SET) return TEACHER_SET;
  if (loadTeacherSetFromCache()) return TEACHER_SET;
  if (!S.loggedIn || _teacherSetLoading) return null;
  _teacherSetLoading = true;
  try {
    // 空参枚举：教师名留空 + 周次 1~总周数，可一次拿到全校教师课表，表格首列即教师名
    var body = 'xnxqh=' + selectedSemester() + '&kbjcmsid=' + KBJCMSID +
      '&skyx=&jszc=&skjsid=&skjs=&zc1=1&zc2=' + semesterWeekCount() + '&jc1=&jc2=';
    var data = parseList(httpPost('/jsxsd/kbcx/kbxx_teacher_ifr', body), 'teacher');
    var list = data && data.teachers;
    if (list && list.length) {
      TEACHER_SET = new Set(list);
      try { setCache('browse_teacher_' + selectedSemester(), data); } catch (e) {}
    }
  } catch (e) {
  } finally {
    _teacherSetLoading = false;
  }
  return TEACHER_SET;
}

// ============ 课表解析 ============
function parseSchedule(html, type) {
  const doc = parseHTML(html);
  const table = firstTable(doc);
  if (!table) return {courses: [], error: '未找到课表'};
  const rows = table.querySelectorAll('tr');
  if (rows.length < 2) return {courses: [], error: '课表为空'};
  let start = 1;
  if (rows.length > 1) {
    const c2 = rows[1].querySelectorAll('td, th');
    let allP = true;
    for (let i = 1; i < c2.length; i++) { if (!/^\d{2,4}$/.test(c2[i].textContent.trim())) { allP = false; break; } }
    if (allP) start = 2;
  }
  const courses = [];
  // 百家姓（用于拆出误并入课程名的教师名；不用 SURNAMES，因其含大量非姓常用字会误拆）
  const SUR_ALL = '赵钱孙李周吴郑王冯陈褚卫蒋沈韩杨朱秦尤许何吕施张孔曹严华金魏陶姜戚谢邹喻柏水窦章云苏潘葛奚范彭郎鲁韦昌马苗凤花方俞任袁柳酆鲍史唐费廉岑薛雷贺倪汤滕殷罗毕郝邬安常乐于时傅皮卞齐康伍余元卜顾孟平黄和穆萧尹姚邵湛汪祁毛禹狄米贝明臧计伏成戴谈宋茅庞熊纪舒屈项祝董梁杜阮蓝闵席季麻强贾路娄危江童颜郭梅盛林刁钟徐邱骆高夏蔡田樊胡凌霍虞万支柯昝管卢莫经房裘缪干解应宗丁宣贲邓郁单杭洪包诸左石崔吉钮龚程嵇邢滑裴陆荣翁荀羊於惠甄曲家封芮羿储靳汲邴糜松井段富巫乌焦巴弓牧隗山谷车侯宓蓬全郗班仰秋仲伊宫宁仇栾暴甘厉戎祖武符刘景詹束龙叶幸司韶郜黎蓟薄印宿白怀蒲邰从鄂索咸籍赖卓蔺屠蒙池乔阴郁胥能苍双闻莘党翟谭贡劳逄姬申扶堵冉宰郦雍卻璩桑桂濮牛寿通边扈燕冀郏浦尚农温别庄晏柴瞿阎充慕连茹习宦艾鱼容向古易慎戈廖庾终暨居衡步都耿满弘匡国文寇广禄阙东欧殳沃利蔚越夔隆师巩厍聂晁勾敖融冷訾辛阚那简饶空曾毋沙乜养鞠须丰巢关蒯相查后荆红游竺权逯盖益桓';
  // 真实全校教师名单（有缓存时用于精确匹配教师名，比百家姓更准）
  if (!TEACHER_SET) loadTeacherSetFromCache();
  // 从课程名尾部匹配教师名：优先真实教师名单（最长优先），否则百家姓兜底
  function matchTeacherFromName(name) {
    if (TEACHER_SET) {
      for (var ln = Math.min(4, name.length); ln >= 2; ln--) {
        var tail = name.slice(-ln);
        if (TEACHER_SET.has(tail) && name.length - ln >= 2) return tail;
      }
    }
    for (var tn = 3; tn >= 2; tn--) {
      var tail2 = name.slice(-tn);
      if (/^[\u4e00-\u9fa5]{2,3}$/.test(tail2) && SUR_ALL.indexOf(tail2.charAt(0)) >= 0 && name.length - tn >= 2) return tail2;
    }
    return '';
  }
  /* 课表查询接口（kbxx_*_ifr）里每个课程是独立的 div.kbcontent1，
     块内用 <br> 分行。外层 <nobr> 会让 innerText 丢掉换行，把
     「课程名/班级/教师/周次/教室」粘成一串，所以必须按块 + 按 <br> 取行。 */
  function brLines(el) {
    var out = [], cur = '';
    (function walk(node) {
      var kids = node.childNodes || [];
      for (var i = 0; i < kids.length; i++) {
        var n = kids[i];
        if (n.nodeType === 3) { cur += n.nodeValue; continue; }
        if (n.nodeType !== 1) continue;
        var tag = n.tagName.toLowerCase();
        if (tag === 'br') { out.push(cur); cur = ''; continue; }
        if (tag === 'script' || tag === 'style') continue;
        walk(n);
      }
    })(el);
    out.push(cur);
    /* 源码文本节点里还夹杂真实换行（<br> 之外），一并当行分隔处理 */
    var flat = [];
    out.forEach(function (s) {
      String(s).split(/\r?\n/).forEach(function (x) {
        var v = String(x).replace(/\u00a0/g, ' ').replace(/[ \t]+/g, ' ').trim();
        if (v) flat.push(v);
      });
    });
    return flat;
  }
  function blocksOf(td) {
    var bs = td.querySelectorAll('div.kbcontent1, div.kbcontent');
    if (bs.length) return Array.prototype.map.call(bs, brLines);
    return [brLines(td)];
  }
  function looksWeek(L) {
    if (!/周/.test(L) || L.length > 26) return false;
    return /^[（(]?\s*[\d０-９,，、\-—~～至\/]+\s*[)）]?/.test(L);
  }
  function looksRoom(L) {
    if (/周/.test(L)) return false;
    /* 纯括号行是课程简称/分组（如 (26A法学一)），不是教室 */
    if (/^[（(].*[)）]$/.test(L) && !/楼|馆|教室|实验室|机房|操场|场地|基地/.test(L)) return false;
    if (/楼|馆|教室|实验室|机房|操场|场地|场馆|基地|中心|室|厅/.test(L)) return true;
    /* 「语五（4-310）」「语音三室(C4)」「多功能室（3C1）」这类语音室/多功能室 */
    if (/[（(][\dA-Z]+[\-－][\dA-Z]+[)）]/.test(L)) return true;
    /* 教室编码：2-301 / y-108 / 3C5 / 4-303（25信息安全班） */
    if (/^[（(]?[A-Za-z]{0,2}\d{1,2}(?:[-－]|[A-Za-z])\d*/.test(L)) return true;
    /* 「2026级法学班（一、二区队）」这类以年份开头的班级名，不能当成教室 */
    if (/班|级|队|专业|学院|系/.test(L)) return false;
    return /^[（(]?[\dA-Za-z一二三四五六七八九十]/.test(L);
  }
  function looksClass(L) {
    if (looksRoom(L)) return false;
    /* 纯括号行是课程分组标记（如 (改革开放史2班)），不是班级 */
    if (/^[（(].*[)）]$/.test(L)) return false;
    /* 班级行有明确形态：…班23 / …队 / 2026级… / …（一、二区队）；
       不能只因子串含「专业」就把「专业外语」这类课程名当班级 */
    if (/(?:班|队)\s*\d{0,6}$/.test(L)) return true;
    if (/^\d{4}级/.test(L)) return true;
    if (/（[一二三四五六七八九十、]+区队）$/.test(L)) return true;
    return false;
  }
  function looksTeacher(L) {
    var t = String(L).replace(/^教师\s*[:：]?\s*/, '').trim();
    if (!t || t.length > 24) return false;
    if (isTeacherLine(t)) return true;
    if (TEACHER_SET && TEACHER_SET.has(t)) return true;
    if (!/^[\u4e00-\u9fa5·]{2,4}$/.test(t)) return false;
    /* 2~4 字且首字是常见姓氏才当教师，避免把「刑法」「宪法」这类短课程名吃掉 */
    return SUR_ALL.indexOf(t.charAt(0)) >= 0;
  }

  for (let ri = start; ri < rows.length; ri++) {
    const cells = rows[ri].querySelectorAll('td');
    if (!cells.length) continue;
    const rowName = txtOf(cells[0]);
    if (!rowName || rowName === '\u00a0') continue;
    for (let ci = 1; ci < cells.length; ci++) {
      const dayIdx = Math.floor((ci - 1) / 7);
      const perIdx = (ci - 1) % 7;
      if (dayIdx >= 7) continue;
      var blocks = blocksOf(cells[ci]);
      for (var bi = 0; bi < blocks.length; bi++) {
        var lines = [];
        blocks[bi].forEach(function (L) {
          /* 有些块的课程名和班级挤在同一行（「改革开放史 涉外法治班24」），先拆开 */
          var m = String(L).match(/^(.{2,}?)\s+((?:\S{2,}?)(?:班|级|队)\s*\d{0,6})$/);
          if (m) { lines.push(m[1].trim()); lines.push(m[2].trim()); }
          else lines.push(L);
        });
        if (!lines.length) continue;
        var pd = PERIODS[perIdx] || {n: '', l: ''};
        var c = {name: '', teacher: '', classroom: '', classes: '', week: '',
                 weekday: dayIdx + 1, weekdayName: WEEKDAYS[dayIdx],
                 period: pd.n, periodLabel: pd.l};
        var nameParts = [];
        for (var li = 0; li < lines.length; li++) {
          var L = lines[li];
          if (!c.week && looksWeek(L)) { c.week = L.replace(/^[（(]|[)）]$/g, '').trim(); continue; }
          if (!c.classroom && looksRoom(L)) { c.classroom = L; continue; }
          if (!c.classes && looksClass(L)) { c.classes = L; continue; }
          if (!c.teacher && looksTeacher(L)) { c.teacher = normTeachers(L); continue; }
          /* 姓氏表覆盖不到的教师名（肖/闫/代…）靠位置判断：
             已取到课程名、且后面紧跟周次/教室/班级的行，短中文行就是教师 */
          if (!c.teacher && nameParts.length && /^[\u4e00-\u9fa5·]{2,4}$/.test(L)) {
            var nx = lines.slice(li + 1).find(function (x) { return !!x; });
            if (!nx || looksWeek(nx) || looksRoom(nx) || looksClass(nx)) {
              c.teacher = normTeachers(L); continue;
            }
          }
          /* 其余都算课程名（含被拆成多行的长课程名、括号简称） */
          nameParts.push(L);
        }
        if (nameParts.length) c.name = nameParts.join(' ');
        /* 课程名尾部还黏着班级（「刑事技术学 侦查学二班25」）时拆出来 */
        if (!c.classes && c.name) {
          var mc = c.name.match(/^(.{2,}?)\s+([\u4e00-\u9fa5]{2,}?(?:班|级|队)\s*\d{0,6})$/);
          if (mc) { c.name = mc[1].trim(); c.classes = mc[2].trim(); }
        }
        /* 有的块首行放的是班级（该格课程名缺失），别把它当课程名 */
        if (c.name && (/^\d{4}级/.test(c.name) || /（[一二三四五六七八九十、]+区队）$/.test(c.name)) && c.teacher) {
          if (!c.classes) c.classes = c.name;
          c.name = '';
        }
        /* 课程名里黏着教师名（如「马克思主义基本原理闫淑珊」）时拆出来 */
        if (!c.teacher && c.name && c.name.length >= 4) {
          var tn2 = matchTeacherFromName(c.name);
          if (tn2) { c.teacher = tn2; c.name = c.name.slice(0, c.name.length - tn2.length).trim(); }
        }
        if (type === 'teacher') c.teacher = rowName;
        else if (type === 'class') c.classes = rowName;
        else if (type === 'course') c.name = rowName;
        else if (type === 'classroom') c.classroom = rowName;
        if (c.name || c.teacher) courses.push(c);
      }
    }
  }
  // 过滤伪条目：课表格子偶发把"教室名"当作独立课程重复渲染（name===classroom），并按 星期+时段+课程 去重
  const uniq = [];
  const seenK = new Set();
  for (const c of courses) {
    if (c.name && c.classroom && c.name === c.classroom) continue;
    /* 去重键带上教师/班级/教室：同名课程同节次不同班级是合法并存条目 */
    const k = c.weekday + '|' + (c.period || c.periodLabel || '') + '|' + c.name + '|' + (c.teacher || '') + '|' + (c.classes || '') + '|' + (c.classroom || '');
    if (seenK.has(k)) continue;
    seenK.add(k); uniq.push(c);
  }
  // 修正：课程课表的班级列偶发把教师名塞进班级，或教师名没被识别
  uniq.forEach(function (c) {
    if (!c.teacher && c.classes) {
      var t = String(c.classes).trim();
      // 单元格里「班级」和「教师」粘成一行（如 矫正教育一班26闵奎元），拆出末尾的教师名
      var m = t.match(/^(.*?(?:班|级|队)\s*\d{0,6})\s*([\u4e00-\u9fa5·]{2,4})$/);
      if (m) { c.classes = m[1]; c.teacher = m[2]; return; }
      if (TEACHER_SET && TEACHER_SET.has(t)) { c.teacher = t; c.classes = ''; return; }
      if (/^[\u4e00-\u9fa5·]{2,4}$/.test(t)) { c.teacher = t; c.classes = ''; }
    }
  });
  /* 交叉补齐：同一门课/同一位教师只要在别的块里解析完整，就用来补缺失字段 */
  (function fillMissing(list) {
    var teacherByName = {}, nameByTeacherClass = {}, nameByTeacherRoom = {};
    list.forEach(function (c) {
      if (c.name && c.teacher) {
        var k1 = c.name + '|' + (c.classes || '');
        if (!teacherByName[k1]) teacherByName[k1] = c.teacher;
        var base1 = String(c.name).replace(/\s*[（(][^)）]*[)）]\s*$/g, '').trim();
        var k1b = base1 + '|' + (c.classes || '');
        if (!teacherByName[k1b]) teacherByName[k1b] = c.teacher;
        var k2 = c.teacher + '|' + (c.classes || '');
        if (!nameByTeacherClass[k2]) nameByTeacherClass[k2] = c.name;
        var k3 = c.teacher + '|' + (c.classroom || '');
        if (!nameByTeacherRoom[k3]) nameByTeacherRoom[k3] = c.name;
      }
    });
    list.forEach(function (c) {
      if (!c.teacher && c.name) {
        var k1 = c.name + '|' + (c.classes || '');
        if (teacherByName[k1]) c.teacher = teacherByName[k1];
        else {
          /* 同名课程的括号分组（大学英语(一) vs 大学英语(一) (26A法学一)）也参与补齐 */
          var base = String(c.name).replace(/\s*[（(][^)）]*[)）]\s*$/g, '').trim();
          var k1b = base + '|' + (c.classes || '');
          if (teacherByName[k1b]) c.teacher = teacherByName[k1b];
        }
      }
      if (!c.name && c.teacher) {
        var k2 = c.teacher + '|' + (c.classes || '');
        var k3 = c.teacher + '|' + (c.classroom || '');
        c.name = nameByTeacherClass[k2] || nameByTeacherRoom[k3] || '';
      }
      if (!c.name) c.name = '';
      if (!c.teacher) c.teacher = '';
    });
  })(uniq);
  var merged = mergeSameCourse(uniq, type);
  return {courses: merged, count: merged.length};
}

// 合并同一时段同名课程（不同周由不同老师上）：教师取并集、周次拼接、教室去重
function unionTeachers(a, b) {
  var arr = [];
  [a, b].forEach(function(src){
    if (!src) return;
    String(src).split(/[、,，;；\/\s]+/).forEach(function(x){
      x = x.trim();
      if (x && arr.indexOf(x) < 0) arr.push(x);
    });
  });
  return arr.join('、');
}
/* 拼接两个同分隔符字段并去重（教室/周次重复堆叠会让字段看起来像解析错误） */
function joinUnique(a, b, sep) {
  var arr = [];
  [a, b].forEach(function (src) {
    if (!src) return;
    String(src).split(sep).forEach(function (x) {
      x = x.trim();
      if (x && arr.indexOf(x) < 0) arr.push(x);
    });
  });
  return arr.join(sep);
}
function mergeSameCourse(list, type) {
  var map = {}, out = [];
  /* 班级课表会把多个班的同名课混在一起；键里带上班级，才能一格多班各自可见 */
  var splitByClass = (type === 'class');
  (list || []).forEach(function(c){
    var k = c.weekday + '|' + (c.period || c.periodLabel || '') + '|' + c.name
          + (splitByClass ? '|' + (c.classes || '') : '');
    var e = map[k];
    if (!e) { map[k] = c; out.push(c); return; }
    e.teacherAll = unionTeachers(e.teacherAll, c.teacher);
    if (c.classes) e.classes = e.classes ? joinUnique(e.classes, c.classes, '，') : c.classes;
    if (c.week && e.week !== c.week) e.week = e.week ? joinUnique(e.week, c.week, '，') : c.week;
    if (!e.classroom && c.classroom) e.classroom = c.classroom;
    else if (c.classroom && e.classroom && c.classroom !== e.classroom) e.classroom = joinUnique(e.classroom, c.classroom, '，');
  });
  // 同一门课所有教师汇总到 teacherAll（只用于详情浮窗，格子仍显示当周教师）
  var byName = {};
  out.forEach(function(c){
    if (!c.name) return;
    byName[c.name] = unionTeachers(byName[c.name] || '', c.teacher);
    byName[c.name] = unionTeachers(byName[c.name], c.teacherAll);
  });
  out.forEach(function(c){
    if (!c.name) return;
    c.teacherAll = unionTeachers(c.teacherAll, byName[c.name]);
  });
  return out;
}

// 取元素可见文本：innerText 会把 <br>/块级元素转成换行，textContent 会把它们粘在一起
function txtOf(el) {
  if (!el) return '';
  var t = '';
  try { t = el.innerText || ''; } catch(e) { t = ''; }
  if (!t) t = el.textContent || '';
  return t.replace(/\r/g, '\n').replace(/[ \t\u00a0]+/g, ' ').trim();
}

// 一行里可能是「张伟」「张伟、李娜」「张伟 李娜」这种多教师写法
function isTeacherLine(line) {
  if (!line) return false;
  var t = String(line).replace(/^教师\s*[:：]?\s*/, '').trim();
  if (!t || t.length > 24) return false;
  var parts = t.split(/[、,，;；\/\|\s]+/).filter(function(x){ return x; });
  if (parts.length < 2 || parts.length > 6) return false;
  for (var i = 0; i < parts.length; i++) {
    if (!/^[\u4e00-\u9fa5·]{2,4}$/.test(parts[i])) return false;
  }
  return true;
}

// 教师名归一：支持一格多教师（顿号/逗号/斜杠/空格分隔），去重后统一用「、」连接

// 教师名单缓存（全校教师）与「张伟李娜」这种粘在一起的拆分
var _TSET = null;
function teacherSet() {
  if (_TSET !== null) return _TSET;
  try {
    var tc = getCache('browse_teacher');
    if (tc && tc.data && Array.isArray(tc.data.teachers) && tc.data.teachers.length) _TSET = new Set(tc.data.teachers);
    else _TSET = false;
  } catch(e) { _TSET = false; }
  return _TSET;
}
var SUR2 = '赵钱孙李周吴郑王冯陈褚卫蒋沈韩杨朱秦尤许何吕施张孔曹严华金魏陶姜戚谢邹喻柏窦章云苏潘葛奚范彭郎鲁韦昌马苗凤花方俞任袁柳唐费廉岑薛雷贺倪汤滕殷罗毕郝邬安常乐于时傅皮卞齐康伍余元卜顾孟平黄和穆萧尹姚邵湛汪祁毛禹狄米贝明臧计伏成戴谈宋茅庞熊纪舒屈项祝董梁杜阮蓝闵席季麻强贾路娄危江童颜郭梅盛林刁钟徐邱骆高夏蔡田樊胡凌霍虞万支柯昝管卢莫经房裘缪干解应宗丁宣贲邓郁单杭洪包诸左石崔吉钮龚程嵇邢滑裴陆荣翁荀羊於惠甄曲家封芮羿储靳汲邴糜松井段富巫乌焦巴弓牧隗山谷车侯宓蓬全郗班仰秋仲伊宫宁仇栾暴甘厉戎祖武符刘景詹束龙叶幸司韶郜黎蓟薄印宿白怀蒲邰从鄂索咸籍赖卓蔺屠蒙池乔阴胥能苍双闻莘党翟谭贡劳逄姬申扶堵冉宰郦雍卻璩桑桂濮牛寿通边扈燕冀郏浦尚农温别庄晏柴瞿阎充慕连茹习宦艾鱼容向古易慎戈廖庾终暨居衡步都耿满弘匡国文寇广禄阙东欧殳沃利蔚越夔隆师巩厍聂晁勾敖融冷訾辛阚那简饶空曾毋沙乜养鞠须丰巢关蒯相查后荆红游竺权逯盖益桓';
function splitNameRun(run) {
  if (!run) return null;
  run = String(run).replace(/\s+/g, '');
  if (run.length < 4 || !/^[\u4e00-\u9fa5·]+$/.test(run)) return null;
  var set = teacherSet(), out = [], i = 0, j;
  if (set) {
    while (i < run.length) {
      var hit = '';
      for (var ln = Math.min(4, run.length - i); ln >= 2; ln--) {
        if (set.has(run.substr(i, ln))) { hit = run.substr(i, ln); break; }
      }
      if (!hit) return null;
      out.push(hit); i += hit.length;
    }
    return out.length > 1 ? out : null;
  }
  // 没有教师名单时的兜底：回溯切分，每段 2~3 字且以常见姓氏开头
  function cut(pos, acc) {
    if (pos === run.length) return acc.length > 1 ? acc : null;
    for (var ln = 3; ln >= 2; ln--) {
      if (pos + ln > run.length) continue;
      var seg = run.substr(pos, ln);
      if (SUR2.indexOf(seg.charAt(0)) < 0) continue;
      var r = cut(pos + ln, acc.concat([seg]));
      if (r) return r;
    }
    return null;
  }
  return cut(0, []);
}

function normTeachers(raw) {
  if (!raw) return '';
  var arr = String(raw).split(/[、,，;；\/\|]+|\s{1,}/).map(function(x){ return x.trim(); }).filter(function(x){
    return x && x.length <= 6 && /^[\u4e00-\u9fa5·]+$/.test(x);
  });
  var out = [];
  for (var i = 0; i < arr.length; i++) {
    var tokens = splitNameRun(arr[i]) || [arr[i]];
    for (var t = 0; t < tokens.length; t++) { if (out.indexOf(tokens[t]) < 0) out.push(tokens[t]); }
  }
  return out.length ? out.join('、') : String(raw).trim();
}

// 跨周教师并集：同一门课不同周可能换老师，把其它周缓存里的教师也并进来
function teacherUnionAcrossWeeks(name, baseTeacher) {
  var out = [];
  function add(src) {
    if (!src) return;
    String(src).split(/[、,，;；\/\s.。]+/).forEach(function (x) {
      x = x.trim();
      if (x && /^[\u4e00-\u9fa5·]{2,4}$/.test(x) && out.indexOf(x) < 0) out.push(x);
    });
  }
  add(baseTeacher);
  try {
    for (var i = 0; i < localStorage.length; i++) {
      var k = localStorage.key(i);
      if (!k || k.indexOf(CK + 'self_') !== 0) continue;
      var obj = JSON.parse(localStorage.getItem(k) || 'null');
      var list = obj && obj.data && obj.data.courses;
      if (!Array.isArray(list)) continue;
      for (var j = 0; j < list.length; j++) {
        if (list[j] && list[j].name === name) add(list[j].teacher);
      }
    }
  } catch (e) {}
  return out.join('、');
}

// 个人课表
function parseSelfSchedule(html, weekday, week) {
  const doc = parseHTML(html);
  const table = firstTable(doc);
  if (!table) return {courses: [], error: '未找到课表'};
  const rows = table.querySelectorAll('tr');
  const courses = [];
  for (const row of rows) {
    const cells = row.querySelectorAll('td');
    if (!cells.length) continue;
    const label = cells[0].textContent.trim();
    if (label.includes('备注') || label.includes('说明')) continue;
    for (let ci = 1; ci < cells.length && ci <= 7; ci++) {
      const items = cells[ci].querySelectorAll('div.item-box');
      for (const item of items) {
        const p = item.querySelector('p');
        if (!p) continue;
        const c = {
          name: txtOf(p), weekday: ci, weekdayName: WEEKDAYS[ci-1],
          teacher: '', classroom: '', week: week ? '第'+week+'周' : '', periodLabel: label,
        };
        (function(){
          var ts = [];
          item.querySelectorAll('p').forEach(function(pp){
            var t = txtOf(pp);
            if (t.indexOf('教师') === 0) {
              var v = t.replace(/^教师\s*[:：]\s*/,'').replace(/[.,，。]$/,'').trim();
              if (v) ts.push(v);
            }
          });
          c.teacher = normTeachers(ts.join('、'));
        })();
        // 节次提取：优先 .tch-name span（含"节"文本，如 "01~02~03节"）；其次 span.text；否则回退行label
        let nums = [];
        item.querySelectorAll('.tch-name span').forEach(s => {
          const t = s.textContent.trim();
          if (t.indexOf('节') >= 0) nums = t.match(/\d{2}/g) || [];
        });
        if (!nums.length) {
          const sp = item.querySelector('span.text');
          if (sp) nums = sp.textContent.trim().match(/\d{2}/g) || [];
        }
        if (nums.length >= 2) {
          const s = parseInt(nums[0], 10), e = parseInt(nums[nums.length - 1], 10);
          c.period = (s < 10 ? '0' + s : '' + s) + (e < 10 ? '0' + e : '' + e);
          c.periodLabel = '第' + s + '-' + e + '节';
        }
        const img1 = item.querySelector('img[src*="item1"]');
        if (img1 && img1.parentElement) c.classroom = img1.parentElement.textContent.trim();
        // 周次：详情中 img[item3] 所在 span 的 "第X周"（课程实际授课周次，非查询参数）
        const img3 = item.querySelector('img[src*="item3"]');
        if (img3 && img3.parentElement) {
          const m = img3.parentElement.textContent.match(/第\s*(\d+)\s*周/);
          if (m) c.week = '第' + m[1] + '周';
        }
        // 教师：item-box 未取到时，从前置 span.box 短名视图取
        if (!c.teacher) {
          const box = item.previousElementSibling;
          if (box) {
            var ts2 = [];
            box.querySelectorAll('p').forEach(function(pp){
              var t = txtOf(pp);
              if (t.indexOf('教师') >= 0) {
                var v = t.replace(/^教师\s*[:：]\s*/, '').replace(/[.,，。]+$/, '').trim();
                if (v) ts2.push(v);
              }
            });
            c.teacher = normTeachers(ts2.join('、'));
          }
        }
        courses.push(c);
      }
    }
  }
  const seen = new Set();
  const uniq = courses.filter(c => {
    const k = c.weekday + '|' + c.name + '|' + c.teacher + '|' + c.classroom + '|' + (c.period || c.periodLabel || '');
    if (seen.has(k)) return false; seen.add(k); return true;
  });
  const mergedSelf = mergeSameCourse(uniq);
  mergedSelf.forEach(function (c) { if (c.name) c.teacherAll = teacherUnionAcrossWeeks(c.name, unionTeachers(c.teacher, c.teacherAll)); });
  const wd = parseInt(weekday);
  const outSelf = wd ? mergedSelf.filter(c => c.weekday === wd) : mergedSelf;
  return {courses: outSelf, count: outSelf.length};
}

// 成绩
function parseScore(html) {
  const doc = parseHTML(html);
  const table = firstTable(doc);
  if (!table) return {courses: [], error: '未找到成绩'};
  const rows = table.querySelectorAll('tr');
  if (rows.length < 2) return {courses: [], error: '无成绩数据'};
  const headers = [];
  rows[0].querySelectorAll('th, td').forEach(h => headers.push(h.textContent.trim()));
  const courses = [];
  for (let ri = 1; ri < rows.length; ri++) {
    const cells = rows[ri].querySelectorAll('td');
    if (!cells.length || !cells[0].textContent.trim()) continue;
    const row = {};
    headers.forEach((h, i) => { if (cells[i]) row[h] = cells[i].textContent.trim(); });
    if (row['序号'] === '未查询到数据') continue;
    courses.push({
      semester: row['开课学期']||'', name: row['课程名称']||'', grade: row['成绩']||'',
      credit: parseFloat(row['学分'])||0, gpa: row['绩点']?parseFloat(row['绩点']):null,
      examType: row['考核方式']||'', courseNature: row['课程性质']||'',
    });
  }
  return {courses, count: courses.length};
}

// GPA
const GP = {'优秀':4.5,'优':4.5,'良好':3.5,'良':3.5,'中等':2.5,'中':2.5,'及格':1.5,'合格':1.5,'通过':1.5,'不及格':0,'不合格':0,'未通过':0};
function grade2pt(g) {
  if (!g) return 0; g = String(g).trim();
  if (g in GP) return GP[g];
  const s = parseFloat(g); if (isNaN(s)) return 0;
  if (s>=90) return 4.0; if (s>=85) return 3.7; if (s>=82) return 3.3;
  if (s>=78) return 3.0; if (s>=75) return 2.7; if (s>=72) return 2.3;
  if (s>=68) return 2.0; if (s>=64) return 1.5; if (s>=60) return 1.0;
  return 0;
}
function isPass(g) {
  g = String(g).trim();
  if (g in {'不及格':1,'不合格':1,'未通过':1}) return false;
  const s = parseFloat(g); return isNaN(s) ? true : s >= 60;
}
function calcGPA(scoreData) {
  let tc=0, tp=0, ts=0, sc=0, pc=0, failed=[];
  for (const c of scoreData.courses) {
    const cr = c.credit||0, pt = grade2pt(c.grade);
    tc += cr; tp += pt*cr;
    if (isPass(c.grade)) pc += cr;
    const s = parseFloat(c.grade);
    if (!isNaN(s)) { ts += s*cr; sc += cr; }
    if (!isPass(c.grade)) failed.push(c);
  }
  return {
    gpa: tc ? Math.round(tp/tc*100)/100 : 0,
    weightedAvg: sc ? Math.round(ts/sc*10)/10 : null,
    totalCredits: Math.round(tc*10)/10, passedCredits: Math.round(pc*10)/10,
    failedCount: failed.length, failedCourses: failed,
  };
}

// 列表
function parseList(html, type) {
  const doc = parseHTML(html);
  const table = firstTable(doc);
  if (!table) return {error: '未找到表格'};
  const rows = table.querySelectorAll('tr');
  if (rows.length < 2) return {error: '数据为空'};
  let start = 1;
  if (rows.length > 1) {
    const c2 = rows[1].querySelectorAll('td, th');
    let allP = true;
    for (let i = 1; i < c2.length; i++) { if (!/^\d{2,4}$/.test(c2[i].textContent.trim())) { allP = false; break; } }
    if (allP) start = 2;
  }
  const names = new Set();
  for (let ri = start; ri < rows.length; ri++) {
    const cell = rows[ri].querySelector('td');
    if (!cell) continue;
    const n = cell.textContent.trim();
    if (!n || n === '\u00a0') continue;
    if (type === 'teacher') {
      if (n.length>=2 && n.length<=15 && /^[\u4e00-\u9fa5·\s]+$/.test(n)) names.add(n);
    } else if (type === 'class') {
      if (n.length>=2 && n.length<=40 && n.includes('班')) names.add(n);
    } else if (type === 'course') {
      if (n.length>=2 && n.length<=40 && !/^\d+$/.test(n)) names.add(n);
    } else {
      if (n.length>=2 && n.length<=30 && /[\d楼馆室教\-]/.test(n)) names.add(n);
    }
  }
  const arr = Array.from(names).sort((a,b) => a.localeCompare(b,'zh-CN'));
  if (type === 'teacher') return {teachers: arr};
  if (type === 'class') return {classes: arr.map(n => ({name: n, grade: (n.match(/(\d{2})/)||['',''])[1]}))};
  if (type === 'course') return {courses: arr};
  return {classrooms: arr};
}

// 教室名归一：「一教-1-107(矫正教育系机动教室1）」与「1-107(矫正教育系机动教室1）」视为同一间
function roomKey(s) {
  if (!s) return '';
  var t = String(s).replace(/\s+/g, '');
  var m = t.match(/(\d+-\d+[^（(]*)/);
  return m ? m[1] : t;
}

// 「课程课表」接口能列出某门课所有班级/教师/周次；用它补全被服务器截断的教师名