/* ===== 04-query ===== 原 index.html 内联脚本第 1624-2329 行（顺序分片，逻辑未改） */
function parseKcBlocks(html) {
  var out = [], re = /<div id='' class="kbcontent1">([\s\S]*?)<\/div>/g, m;
  html = html || '';
  while ((m = re.exec(html)) !== null) {
    var t = m[1].replace(/<br\s*\/?>/gi, '\n').replace(/<[^>]+>/g, '');
    var lines = t.split('\n').map(function (x) { return x.trim(); }).filter(function (x) { return x; });
    for (var i = 1; i < lines.length; i++) {
      var mm = /^[（(]([\d,\-，]+)周[）)]$/.exec(lines[i]);
      if (mm) {
        out.push({ cls: lines.slice(1, i - 1).join(' / '), teacher: lines[i - 1], weeks: mm[1], room: lines[i + 1] || '' });
        break;
      }
    }
  }
  return out;
}
function userClass() {
  try { var v = localStorage.getItem('jwxt_class'); if (v) return v; } catch (e) {}
  try {
    var h = httpGet('/jsxsd/grxx/xsxx');
    var m = String(h).match(/班级\s*[：:]\s*([^\s<|]{2,20})/);
    if (m) { try { localStorage.setItem('jwxt_class', m[1]); } catch (e) {} return m[1]; }
  } catch (e) {}
  return '';
}
function teacherCacheGet() {
  try { return JSON.parse(localStorage.getItem('jwxt_tfull3') || '{}') || {}; } catch (e) { return {}; }
}
function teacherCacheSet(m) {
  try { localStorage.setItem('jwxt_tfull3', JSON.stringify(m || {})); } catch (e) {}
}
// 补全「教师：杜丙立,..」这类被服务器截断的名字：最多 4 门，结果长期缓存
function completeTruncatedTeachers(res, html, sem) {
  try {
    var str = typeof html === 'string' ? html : '';
    var re = /<span[^>]*class='box'[^>]*>\s*<p>([^<]*)<\/p>\s*<p>教师[：:]([^<]*)<\/p>[\s\S]{0,900}?<div class='item-box'\s*>\s*<p>([^<]*)<\/p>/g;
    var m, need = [];
    while ((m = re.exec(str)) !== null) {
      var tch = (m[2] || '').trim();
      var full = (m[3] || '').trim();
      if (full && /[,，]|\.\./.test(tch) && need.indexOf(full) < 0) need.push(full);
    }
    if (!need.length) return;
    var cache = teacherCacheGet(), dirty = false, budget = 4, cls = '';
    need.forEach(function (nm) {
      var k = (sem || '') + '|' + nm;
      var old = cache[k];
      if (old && typeof old === 'object' && old.plan && old.plan.length) return;
      if (budget <= 0) return;
      budget--;
      try {
        if (!cls) cls = userClass();
        var body = 'xnxqh=' + sem + '&kbjcmsid=' + KBJCMSID + '&skyx=&zzdKcSX=&kcid=&kcmc=' + encodeURIComponent(nm) + '&zc1=1&zc2=20&jc1=&jc2=';
        var h2 = httpPost('/jsxsd/kbcx/kbxx_kc_ifr', body);
        var blocks = parseKcBlocks(typeof h2 === 'string' ? h2 : '');
        var mine = blocks.filter(function (b) { return cls && b.cls.indexOf(cls) >= 0; });
        var pick = mine.length ? mine : blocks;
        var names = [], plan = [];
        pick.forEach(function (b) {
          var t = normTeachers(b.teacher);
          if (!t) return;
          t.split('、').forEach(function (x) { if (x && names.indexOf(x) < 0) names.push(x); });
          plan.push({ weeks: b.weeks, teacher: t, room: b.room || '' });
        });
        if (names.length) { cache[k] = { all: names.join('、'), plan: plan }; dirty = true; }
      } catch (e) {}
    });
    if (dirty) teacherCacheSet(cache);
    (res && res.courses || []).forEach(function (c) {
      var rec = cache[(sem || '') + '|' + c.name];
      if (!rec) return;
      var allName = (typeof rec === 'string') ? rec : rec.all;
      c.teacherAll = unionTeachers(c.teacherAll, unionTeachers(c.teacher, allName));
      if (rec.plan && rec.plan.length) {
        c.teacherPlan = rec.plan;
        var wk = (String(c.week || '').match(/\d+/) || [])[0];
        if (wk) {
          var hit = rec.plan.filter(function (pl) {
            return weekInRange('第' + pl.weeks + '周', parseInt(wk, 10));
          });
          if (!hit.length) hit = rec.plan;
          if (hit.length === 1) c.teacher = hit[0].teacher;
          else if (hit.length > 1) {
            var myRoom = roomKey(c.classroom);
            var same = hit.filter(function (pl) { return myRoom && roomKey(pl.room) === myRoom; });
            c.teacher = (same.length ? same : hit).map(function (pl) { return pl.teacher; })
              .filter(function (v, i, a) { return a.indexOf(v) === i; }).join('、');
          }
        }
      }
    });
  } catch (e) {}
}

// ============ 查询执行 ============
async function doQuery(type, params) {
  const sem = params.semester || selectedSemester();
  // 解析课表前确保全校教师名单已就绪，教师名拆分才有精确依据
  if (type === 'self' || type === 'teacher' || type === 'classroom' || type === 'class' || type === 'course' || type === 'courselist') {
    try { ensureTeacherSet(); } catch (e) {}
  }
  switch(type) {
    case 'self': {
      /* 数据源统一改为「学期理论课表」：任意学期都能取到全量表，
         不再依赖上一份按周接口（它对非当前学期返回空表）。 */
      const html = httpGet('/jsxsd/xskb/xskb_list.do?xnxq01id=' + encodeURIComponent(sem));
      var res = parseTheorySchedule(html);
      if (res.error) {
        /* 兜底：理论课表取不到时退回按周的旧接口，至少当前学期还能看 */
        const rq = weekMonday(params.week || '1');
        const h2 = httpGet('/jsxsd/framework/mainV_index_loadkb.htmlx?rq=' + rq + '&sjmsValue=' + KBJCMSID + '&xnxqid=' + sem + '&xswk=false');
        var r2 = parseSelfSchedule(h2, params.weekday, params.week);
        try { completeTruncatedTeachers(r2, h2, sem); } catch (e) {}
        return r2;
      }
      res.semester = sem;
      res.week = params.week || currentWeek();
      return res;
    }
    case 'teacher': {
      const body = 'xnxqh='+sem+'&kbjcmsid='+KBJCMSID+'&skyx=&jszc=&skjsid=&skjs='+encodeURIComponent(params.name||'')+'&zc1='+(params.week||'1')+'&zc2='+(params.week||'20')+'&jc1=&jc2=';
      return parseSchedule(httpPost('/jsxsd/kbcx/kbxx_teacher_ifr', body), 'teacher');
    }
    case 'classroom': {
      const body = 'xnxqh='+sem+'&kbjcmsid='+KBJCMSID+'&skyx=&xqid=1&jzwid=&jxlvalue=&skjsid=&skjs='+encodeURIComponent(params.name||'')+'&jsid=&zc1='+(params.week||'1')+'&zc2='+(params.week||'20')+'&jc1=&jc2=';
      return parseSchedule(httpPost('/jsxsd/kbcx/kbxx_classroom_ifr', body), 'classroom');
    }
    case 'class': {
      const body = 'xnxqh='+sem+'&kbjcmsid='+KBJCMSID+'&skyx=&sknj=&skzy=&skbjid=&skbj='+encodeURIComponent(params.name||'')+'&zc1='+(params.week||'1')+'&zc2='+(params.week||'20')+'&jc1=&jc2=';
      const res = parseSchedule(httpPost('/jsxsd/kbcx/kbxx_xzb_ifr', body), 'class');
      /* skbj 是前缀匹配：输入「2026级」会返回多个班，同格会叠几十门课。
         这里按所选班级名再精筛一次，命中才替换，避免把真实数据过滤没 */
      const q = String(params.name || '').trim();
      if (q) {
        const before = (res.courses || []).length;
        const hit = (res.courses || []).filter(function (c) { return String(c.classes || '').indexOf(q) >= 0; });
        if (hit.length && hit.length < before) { res.courses = hit; res.count = hit.length; res.filteredFrom = before; }
      }
      return res;
    }
    case 'courselist': {
      const body = 'xnxqh='+sem+'&kbjcmsid='+KBJCMSID+'&skyx=&zzdKcSX=&kcid=&kcmc='+encodeURIComponent(params.name||'')+'&zc1=1&zc2=20&jc1=&jc2=';
      return parseSchedule(httpPost('/jsxsd/kbcx/kbxx_kc_ifr', body), 'course');
    }
    case 'course': {
      const body = 'xnxqh='+sem+'&kbjcmsid='+KBJCMSID+'&skyx=&zzdKcSX=&kcid=&kcmc='+encodeURIComponent(params.name||'')+'&zc1='+(params.week||'1')+'&zc2='+(params.week||'20')+'&jc1=&jc2=';
      return parseSchedule(httpPost('/jsxsd/kbcx/kbxx_kc_ifr', body), 'course');
    }
    case 'score': {
      const body = 'kksj='+(params.semester||'')+'&kcxz=&kcsx=&kcmc='+encodeURIComponent(params.name||'')+'&xsfs=max&zylx=0&pageIndex=1';
      return parseScore(httpPost('/jsxsd/kscj/cjcx_list', body));
    }
    case 'gpa': {
      const body = 'kksj=&kcxz=&kcsx=&kcmc=&xsfs=max&zylx=0&pageIndex=1';
      return calcGPA(parseScore(httpPost('/jsxsd/kscj/cjcx_list', body)));
    }
    case 'progress': {
      // 学习进度 - 两步查询（对齐 Python 脚本）
      // 第一步：获取 ndzydm
      var idxHtml = httpGet('/jsxsd/xxwcqk/xxwcqk_idxOntx.do');
      var idxDoc = parseHTML(idxHtml);
      var ndzydmInput = idxDoc.querySelector('input[name="ndzydm"]');
      var ndzydm = ndzydmInput ? ndzydmInput.getAttribute('value') : '';
      var debug = 'ndzydm: ' + ndzydm + '<br>';
      if (!ndzydm) return {error: '未找到培养方案ID', debug: debug + 'idx页长度: ' + idxHtml.length, raw: idxHtml.substring(0, 1000), rows: []};
      // 第二步：查询进度
      var html = httpGet('/jsxsd/xxwcqk/xxwcqkOnkctx.do?ndzydm=' + encodeURIComponent(ndzydm));
      var doc = parseHTML(html);
      debug += '返回长度: ' + html.length + ' 字符<br>表格数: ' + doc.querySelectorAll('table').length;
      // 找包含"课程体系"和"要求学分"的表格
      var tables = doc.querySelectorAll('table');
      var targetTable = null;
      for (var ti = 0; ti < tables.length; ti++) {
        var text = tables[ti].textContent;
        if (text.indexOf('课程体系') >= 0 && text.indexOf('要求学分') >= 0) {
          targetTable = tables[ti];
          break;
        }
      }
      if (!targetTable) return {error: '未找到进度表', debug: debug, raw: html.substring(0, 1000), rows: []};
      var rows = targetTable.querySelectorAll('tr');
      debug += '<br>表格行数: ' + rows.length;
      var data = [];
      rows.forEach(function(row) {
        var cells = row.querySelectorAll('td, th');
        if (cells.length >= 5 && cells[0].textContent.trim() && cells[0].textContent.trim() !== '课程体系') {
          var systemText = cells[0].textContent.trim();
          var system = systemText;
          var attr = '';
          var m = systemText.match(/^(.*?)\(([^)]*)\)$/);
          if (m) { system = m[1]; attr = m[2]; }
          data.push({
            system: system,
            attr: attr,
            required: cells[1].textContent.trim(),
            done: cells[2].textContent.trim(),
            studying: cells[3].textContent.trim(),
            remaining: cells[4].textContent.trim()
          });
        }
      });
      debug += '<br>有效数据行: ' + data.length;
      if (data.length === 0) return {error: '没有有效数据', debug: debug, raw: html.substring(0, 1000), rows: []};
      return {rows: data, count: data.length, debug: debug};
    }
    case 'exam': {
      const html = httpPost('/jsxsd/xsks/xsksap_list', 'kksj='+(params.semester||'')+'&pageIndex=1');
      const doc = parseHTML(html);
      const table = firstTable(doc);
      if (!table) return {exams: [], error: '未找到考试安排'};
      const rows = table.querySelectorAll('tr');
      const headers = [];
      if (rows[0]) rows[0].querySelectorAll('th,td').forEach(h => headers.push(h.textContent.trim()));
      const exams = [];
      for (let ri = 1; ri < rows.length; ri++) {
        const cells = rows[ri].querySelectorAll('td');
        if (!cells.length || !cells[0].textContent.trim()) continue;
        const row = {};
        headers.forEach((h,i) => { if (cells[i]) row[h] = cells[i].textContent.trim(); });
        exams.push(row);
      }
      return {exams, count: exams.length};
    }
    case 'profile': {
      // 学籍卡片 - 两种解析方式结合
      var html = httpGet('/jsxsd/grxx/xsxx');
      var doc = parseHTML(html);
      var info = {};
      var allTds = [];
      doc.querySelectorAll('td').forEach(function(td) {
        var txt = td.textContent.trim();
        if (txt && txt !== '\u00a0') allTds.push(txt);
      });
      // 方式1：匹配 "key：value" 格式的单个 td
      allTds.forEach(function(txt) {
        var m = txt.match(/^([^：:]{2,15})[：:]\s*(.+)$/);
        if (m) {
          var k = m[1].trim();
          var v = m[2].trim();
          if (v && v !== '\u00a0') {
            if (!info[k]) info[k] = v;
          }
        }
      });
      // 方式2：两两配对（跳过已经是 "key：value" 的）
      var pending = [];
      allTds.forEach(function(txt) {
        // 如果已经是 key：value 格式，跳过
        if (/^[^：:]{2,15}[：:]/.test(txt)) return;
        pending.push(txt);
      });
      for (var i = 0; i < pending.length - 1; i += 2) {
        var k = pending[i];
        var v = pending[i+1];
        // key 是短文本（2-6字），v 不是 key
        if (k.length >= 2 && k.length <= 6 && v.length > 0 && v !== k) {
          // 排除明显不是 key 的（纯数字太长、包含"信息"等）
          if (!/^\d{6,}$/.test(k) && k.indexOf('信息') < 0 && k.indexOf('情况') < 0) {
            if (!info[k]) info[k] = v;
          }
        }
      }
      return info;
    }
    case 'electives': {
      // 选课结果 - 带学期参数（对齐 Python 脚本）
      var semVal = params.semester || '';
      var postData = 'pageIndex=1&pageSize=50';
      if (semVal) postData += '&xnxqid=' + encodeURIComponent(semVal);
      var html = httpPost('/jsxsd/xkgl/loadXsxkjgList', postData);
      var doc = parseHTML(html);
      var debug = '返回长度: ' + html.length + ' 字符<br>表格数: ' + doc.querySelectorAll('table').length;
      // 找第一个表格
      var table = doc.querySelector('table');
      if (!table) return {electives: [], error: '未找到选课结果表格', debug: debug, raw: html.substring(0, 1000)};
      var rows = table.querySelectorAll('tr');
      debug += '<br>表格行数: ' + rows.length;
      if (rows.length < 2) return {electives: [], error: '未查询到选课结果', debug: debug, raw: html.substring(0, 1000)};
      var headers = [];
      rows[0].querySelectorAll('th,td').forEach(function(h) { headers.push(h.textContent.trim()); });
      debug += '<br>列名: ' + headers.join(', ');
      var list = [];
      for (var ri = 1; ri < rows.length; ri++) {
        var cells = rows[ri].querySelectorAll('td');
        if (!cells.length || !cells[0].textContent.trim()) continue;
        var row = {};
        headers.forEach(function(h, i) { if (cells[i]) row[h] = cells[i].textContent.trim(); });
        list.push(row);
      }
      debug += '<br>有效数据行: ' + list.length;
      return {electives: list, count: list.length, debug: debug};
    }
    case 'empty': {
      // 空教室：一次拉全校教室该周课表矩阵，直接读格子有无内容判断占用
      const sem = params.semester || currentSemester();
      const wk = params.week || currentWeek();
      const body = 'xnxqh='+sem+'&kbjcmsid='+KBJCMSID+'&skyx=&xqid=1&jzwid=&jxlvalue=&skjsid=&skjs=&jsid=&zc1='+wk+'&zc2='+wk+'&jc1=&jc2=';
      const html = httpPost('/jsxsd/kbcx/kbxx_classroom_ifr', body);
      const matrix = parseEmptyMatrix(html);
      if (matrix.error) return {error: matrix.error};
      // 教室全集：优先用缓存的全校教室名单
      let allRooms = [];
      try { const bc = getCache('browse_classroom'); if (bc && bc.data && bc.data.classrooms) allRooms = bc.data.classrooms.slice(); } catch(e) {}
      (matrix.rooms||[]).forEach(r => { if (allRooms.indexOf(r.name)<0) allRooms.push(r.name); });
      return buildEmptyRooms(matrix.rooms||[], allRooms, wk);
    }
    default: throw new Error('未知查询类型');
  }
}

// 直接读全校教室课表矩阵：行=教室名，列=星期×节次，格子有内容=有课
function parseEmptyMatrix(html) {
  const doc = parseHTML(html);
  const table = firstTable(doc);
  if (!table) return {rooms: [], error: '未找到课表矩阵'};
  const rows = table.querySelectorAll('tr');
  if (rows.length < 2) return {rooms: [], error: '课表为空'};
  // 检测表头行数：第二行全是节次编号(0102/0304...)则跳过
  let dataStart = 1;
  if (rows.length > 1) {
    const c2 = rows[1].querySelectorAll('td, th');
    let allNum = true;
    for (let i = 1; i < c2.length; i++) { if (!/^\d{2,4}$/.test(c2[i].textContent.trim())) { allNum = false; break; } }
    if (allNum) dataStart = 2;
  }
  const rooms = [];
  for (let ri = dataStart; ri < rows.length; ri++) {
    const cells = rows[ri].querySelectorAll('td');
    if (!cells.length) continue;
    const roomName = cells[0].textContent.trim();
    if (!roomName || roomName === '\u00a0') continue;
    const occupied = {}; // occupied[dayIdx0based][perIdx0based] = true
    for (let ci = 1; ci < cells.length; ci++) {
      const txt = cells[ci].textContent.trim();
      const dayIdx = Math.floor((ci-1)/7);
      const perIdx = (ci-1)%7;
      if (dayIdx >= 7) continue;
      if (txt && txt !== '\u00a0') {
        if (!occupied[dayIdx]) occupied[dayIdx] = {};
        occupied[dayIdx][perIdx] = true;
      }
    }
    rooms.push({name: roomName, occupied: occupied});
  }
  return {rooms: rooms};
}

// 空教室计算：rooms=矩阵直接读取的占用信息；allRooms=全校教室全集；week=当前周次
function buildEmptyRooms(rooms, allRooms, week) {
  var w = parseInt(week, 10) || currentWeek();
  function buildingOf(room) { var m = (room||'').match(/^\s*(\d+)/); return m ? m[1] : '其他'; }
  function shortName(room) { return (room||'').split(/[(（]/)[0].trim(); }
  // perIdx(0-6) → 大节(1-6)：0102→1, 0304→2, 0506→3, 0708→4, 0910→5, 11/12→6
  function perToSlot(perIdx) { return perIdx < 5 ? perIdx+1 : 6; }
  // 全集按楼分组（只保留数字开头的教学楼，过滤"其他"）
  var byBuilding = {};
  allRooms.forEach(function(r) {
    var b = buildingOf(r), sn = shortName(r);
    if (b === '其他') return;
    if (!byBuilding[b]) byBuilding[b] = {};
    byBuilding[b][sn] = true;
  });
  // 从矩阵占用构建 occ[building][day1based][slot1based] = {shortRoom:true}
  var occ = {};
  rooms.forEach(function(rm) {
    var b = buildingOf(rm.name), sn = shortName(rm.name);
    if (b === '其他') return;
    Object.keys(rm.occupied).forEach(function(dayIdx) {
      Object.keys(rm.occupied[dayIdx]).forEach(function(perIdx) {
        var day = parseInt(dayIdx,10)+1;
        var slot = perToSlot(parseInt(perIdx,10));
        if (!occ[b]) occ[b] = {};
        if (!occ[b][day]) occ[b][day] = {};
        if (!occ[b][day][slot]) occ[b][day][slot] = {};
        occ[b][day][slot][sn] = true;
      });
    });
  });
  var buildings = [];
  Object.keys(byBuilding).sort(function(a,b){
    return parseInt(a,10)-parseInt(b,10);
  }).forEach(function(b) {
    var all = Object.keys(byBuilding[b]).sort();
    var grid = [];
    for (var sl=1; sl<=6; sl++) {
      var row = [];
      for (var day=1; day<=5; day++) {
        var busy = (occ[b] && occ[b][day] && occ[b][day][sl]) ? occ[b][day][sl] : {};
        row.push(all.filter(function(sn){ return !busy[sn]; }).sort());
      }
      grid.push(row);
    }
    buildings.push({building: b, label: b+'教', rooms: all, grid: grid});
  });
  return {buildings: buildings, week: w};
}

// ============ 缓存 ============
const CK = 'jwxt_cache_';
function activePersonalCachePrefix() { return CK + 'self_u' + (activeAccountScope() || 'guest') + '_' + selectedSemester() + '_'; }
function isActivePersonalCacheKey(key) {
  if(!key)return false;if(key.indexOf(activePersonalCachePrefix())===0)return true;
  var prefix=CK+'self_u'+(activeAccountScope()||'guest')+'_';
  if(key.indexOf(prefix)!==0||!/^w\d+(?:_d[1-7])?$/.test(key.slice(prefix.length)))return false;
  try{var item=JSON.parse(localStorage.getItem(key)||'null');
    if(!item||!item.t)return false;
    /* 缓存里已经显式带了学期，不必再用“写入日期落在哪个学期”去卡它，
       否则查看过去学期时每一份缓存都会被判成过期；
       但必须确认缓存本身属于当前所选学期，不能拿别的学期的课表来充数。 */
    var sem = selectedSemester();
    var d = item.data || null;
    if (d && d.semester && String(d.semester) !== sem) return false;
    if (!d && !item.t) return false;
    if (d && !d.semester && String(key).indexOf(sem) < 0) return false;
    return true;}catch(e){return false;}
}
function hasCachePrefix(prefix) {
  for (var i = 0; i < localStorage.length; i++) { var k = localStorage.key(i); if (k && k.indexOf(prefix) === 0) return true; }
  return false;
}
function cacheKey(type, params) {
  params=Object.assign({},params||{});
  // The same normalization applies to query, reload, week swipe and day view.
  if(type==='self'&&!params.semester&&typeof currentSemester==='function')params.semester=currentSemester();
  if(params.week)params.week=String(parseInt(params.week,10)||params.week);
  var k = type;
  if (['self','score','gpa','progress','exam','electives'].indexOf(type) >= 0 && typeof activeAccountScope === 'function') k += '_u' + (activeAccountScope() || 'guest');
  if (params && params.name) k += '_' + params.name;
  if (params && params.semester) k += '_' + params.semester;
  if (params && params.week) k += '_w' + params.week;
  if (params && params.weekday) k += '_d' + params.weekday;
  return k;
}
function getCache(k) {
  function read(key){try{var item=JSON.parse(localStorage.getItem(CK+key)||'null');return item&&item.data!=null&&!item.data.error?item:null;}catch(e){return null;}}
  var cached=read(k);if(cached)return cached;
  // Whole-week caches can satisfy a day filter without a new network request.
  var day=k.match(/_d([1-7])$/);
  if(day){cached=getCache(k.replace(/_d[1-7]$/,''));if(cached&&Array.isArray(cached.data.courses))return Object.assign({},cached,{data:Object.assign({},cached.data,{courses:cached.data.courses.filter(function(c){return Number(c.weekday)===Number(day[1]);})})});}
  // Recover only account-scoped, current-semester caches from the old key format.
  var old=k.match(/^self_u([^_]+)_(\d{4}-\d{4}-[12])(_w\d+(?:_d\d)?)$/);
  if(old&&old[1]===(activeAccountScope()||'guest')&&old[2]===selectedSemester()){
    cached=read('self_u'+old[1]+old[3]);
    if(cached&&cached.t)return cached;
  }
  return null;
}
function semesterForDate(date){var y=date.getMonth()>=7?date.getFullYear():date.getFullYear()-1;return y+'-'+(y+1)+'-'+(date.getMonth()>=7?'1':'2');}
function setCache(k, v) {
  if(v==null||v.error)return false;
  try {localStorage.setItem(CK+k,JSON.stringify({data:v,t:Date.now()}));return true;}
  catch(e){scheduleTip('查询成功，但离线缓存保存失败。请检查存储空间或清理不需要的缓存。');return false;}
}

// ============ 页面切换 ============
function showView(v, pushHistory) {
  if (v === 'main') v = 'result'; /* 主视图即课表 */
  var prevView = S.view;
  S.view = v;
  // 结果页时查询/浏览面板变成浮窗，不隐藏
  document.getElementById('querySection').style.display = v === 'result' ? '' : (v === 'main' ? '' : 'none');
  document.getElementById('browseNav').style.display = v === 'result' ? '' : (v === 'main' ? '' : 'none');
  document.getElementById('resultSection').classList.toggle('hidden', v !== 'result');
  var bb = document.getElementById('backBtn');
  if (bb) bb.classList.toggle('show', v !== 'main');
  document.body.classList.toggle('in-result', v === 'result');
  if (v !== 'result') { document.body.classList.remove('schedule-result'); document.getElementById('backCurrentWeek').hidden = true; }
  // 结果页计算过的内联高度与坐标必须返回课表时清除。
  if (v !== 'result' && prevView === 'result') resetFloatLayout();
  // 进结果页时收起所有浮窗
  if (v === 'result') {
    collapseFloats();
    // 强制隐藏查询/浏览的卡片内容
    var qs = document.getElementById('querySection');
    var bn = document.getElementById('browseNav');
    if (qs) { qs.classList.remove('open'); }
    if (bn) { bn.classList.remove('open'); }
  }
  window.scrollTo(0, 0);
  // 记录历史：从主页面进入结果页时 push
  if (pushHistory !== false && v !== prevView && v === 'result') {
    try {
      if (prevView === 'main') {
        history.pushState({view: v}, '');
      } else {
        history.replaceState({view: v}, '');
      }
    } catch(e) {}
  }
}
function closeBrowse() {
  document.getElementById('browseSection').classList.add('hidden');
  document.getElementById('browseOverlay').style.display = 'none';
}
function goBack() {
  // 如果弹窗开着，先关弹窗
  if (!document.getElementById('browseSection').classList.contains('hidden')) {
    closeBrowse();
    return;
  }
  if (S.view !== 'main') {
    history.back();
  }
}
// 监听返回键
window.addEventListener('popstate', function(e) {
  if (document.body.classList.contains('show-settings')) {
    try { history.replaceState({ view: S.view || 'main' }, '', location.pathname); } catch (err) {}
    showTab('main', true);
    return;
  }
  if (e.state && e.state.view) {
    showView(e.state.view, false);
  } else {
    showView('main', false);
  }
});

// ============ 初始化 ============
function init() {
  try {
    // 沉浸式状态栏：读取状态栏高度(物理px)，除以density换算为CSS px(dp)，给顶部topbar预留padding
    if (window.Android && Android.getStatusBarHeight) {
      const sbPx = parseInt(Android.getStatusBarHeight(), 10) || 0;
      const dpr = window.devicePixelRatio || 1;
      let sbDp = Math.round(sbPx / dpr);
      // 安卓 15 上 getStatusBarHeight 可能取到 0，取不到时按常见状态栏高度兜底，避免顶部被压
      if (!(sbDp > 0)) sbDp = 28;
      document.documentElement.style.setProperty('--sb', sbDp + 'px');
    }
  } catch (e) {}

  try {
    // 底部手势条：WebView 里 env(safe-area-inset-bottom) 常为 0，用视口差值兜底
    var sab = parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--sab')) || 0;
    if (!sab && window.Android) {
      var gap = (window.screen.height || 0) - (window.innerHeight || 0) - (parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--sb')) || 0);
      sab = gap > 0 && gap < 80 ? gap : 24;
      document.documentElement.style.setProperty('--sab', sab + 'px');
    }
  } catch (e) {}
  try {
    const c = JSON.parse(localStorage.getItem('jwxt_creds') || '{}');
    // 只回填账号；密码从不落盘，需重新登录时手动输入
    if (c.account) document.getElementById('account').value = c.account;
  } catch {}

  // 启动时不再做网络校验：只读本地会话标记，首屏不等任何 HTTPS 往返
  // （原来的 silentSessionCheck() 走原生同步请求，会把首帧卡住数秒；会话失效由查询路径兜底提示）
  try { if (localStorage.getItem('jwxt_login') === '1') S.loggedIn = true; } catch (e) {}

  // 根据登录状态设置结果页按钮
  var initRlb = document.getElementById('resultLogoutBtn');
  var initSdr = document.getElementById('statusDotResult');
  if (S.loggedIn) {
    if (initRlb) { initRlb.innerHTML = ICO_LOGOUT; initRlb.onclick = doLogout; initRlb.title='退出'; }
    if (initSdr) initSdr.style.background = 'var(--green)';
  } else {
    if (initRlb) { initRlb.innerHTML = ICO_LOGIN; initRlb.onclick = showLogin; initRlb.title='登录'; }
    if (initSdr) initSdr.style.background = '#b5544f';
  }

  restoreTheme();

  // 查询类型：卡片式按钮组
  const typeGrid = document.getElementById('typeGrid');
  TYPES.forEach(t => {
    const btn = document.createElement('button');
    btn.type='button';
    btn.className = 'type-btn' + (t.v === 'self' ? ' active' : '');
    btn.dataset.v = t.v;
    btn.textContent = t.l;
    if (t.v === 'self') {
      /* 「我的课表」右侧的 ↗：点它直接打开本周课表，不用再点“查询” */
      var go = document.createElement('span');
      go.className = 'type-go';
      go.textContent = '↗';
      go.title = '直接打开本周课表';
      go.onclick = function (e) {
        e.stopPropagation();
        selectType('self');
        /* 直接落到「表格课表」而不是列表：用户点 ↗ 的预期就是看到这一周的格子课表 */
        S.scheduleForm = 'grid';
        /* ↗ 的语义永远是“本学期、本周”：正看着过去学期时也要先切回当前学期，
           否则 currentWeek() 会返回 1（非当前学期按第 1 周算），跳到别的学年去 */
        var curSem = currentSemester();
        if (selectedSemester() !== curSem) {
          S.semester = curSem;
          try { localStorage.setItem('jwxt_sem_sel', curSem); } catch (err) {}
          var semSel = document.getElementById('querySemester');
          if (semSel) semSel.value = curSem;
          try { SEMESTER_START = new Date(semesterStartDate() + 'T00:00:00'); } catch (err) {}
        }
        var w = currentWeek();
        var wk = document.getElementById('queryWeek');
        if (wk) wk.value = String(w);
        /* 点击反馈：按钮闪一下描边 + 顶部提示，和随后的页面跳转连起来 */
        btn.classList.remove('jump');
        void btn.offsetWidth;
        btn.classList.add('jump');
        setTimeout(function () { btn.classList.remove('jump'); }, 600);
        /* 跳转前把查询参数浮层收回去，否则跳完还挡在课表上 */
        var qs = document.getElementById('querySection');
        if (qs) {
          qs.classList.remove('open');
          var qcard = qs.querySelector('.card'); if (qcard) qcard.style.display = '';
          var qtab = qs.querySelector('.fd-tab'); if (qtab) qtab.style.display = '';
        }
        scheduleTip('正在打开第 ' + w + ' 周课表');
        runQuery(false);
      };
      btn.appendChild(go);
    }
    btn.onclick = function() { selectType(t.v); };
    typeGrid.appendChild(btn);
  });

  /* 查询面板不填周次时默认当前周：输入框直接显示当前周，语义更明确 */
  try {
    var wkDefault = document.getElementById('queryWeek');
    if (wkDefault && !wkDefault.value) wkDefault.value = String(currentWeek());
  } catch (e) {}
  /* 恢复上次选中的学期 */
  try { S.semester = selectedSemester(); } catch (e) {}
  var _semEl = document.getElementById('tbSemText');
  if (_semEl) _semEl.textContent = semesterLabel(selectedSemester());

  const semSel = document.getElementById('querySemester');
  /* 与「选择学期」面板共用同一份官网学期列表（jxzl 页下拉），
     不再按学年自己拼出官网没有的“未来学期”，两处口径保持一致。 */
  function fillSemesterSelect(list) {
    if (!semSel) return;
    var items = (list && list.length) ? list.slice() : [];
    var cur = selectedSemester();
    if (!items.some(function (it) { return it.v === cur; }) && /^\d{4}-\d{4}-\d{1,2}$/.test(cur)) {
      items.unshift({ v: cur, label: semesterLabel(cur) });
    }
    semSel.innerHTML = '';
    items.forEach(function (it) {
      var o = document.createElement('option');
      o.value = it.v;
      o.textContent = it.label + '（' + it.v + '）';
      semSel.appendChild(o);
    });
    semSel.value = cur;
  }
  fillSemesterSelect(null);
  try { fetchSemesterList(fillSemesterSelect); } catch (e) {}

  // 检查缓存
  checkCacheStatus();

  // 设置面板初始化
  document.getElementById('semesterStartInput').value = semesterStartDate();
  document.getElementById('semesterWeeksInput').value = semesterWeekCount();
  syncOpenModeUI();
  const nsw = document.getElementById('notifySwitch');
  if (nsw) nsw.classList.toggle('on', (localStorage.getItem('jwxt_notify_on') || '1') !== '0');
  /* 设置页的缓存清单改为“打开设置时才算”（showTab('settings') 已经会算），
     否则每次开机都要把全部离线缓存 JSON 解析一遍，缓存越多启动越慢 */
  showTab('main');

  // 今日课程：延后到空闲时段算，别和首屏抢时间
  var _deferBoot = function(){
    try { renderTodayCourses(); refreshOngoing(); } catch (e) {}
  };
  if (window.requestIdleCallback) requestIdleCallback(_deferBoot, {timeout: 900});
  else setTimeout(_deferBoot, 200);
  initFloatDrag();
  initWeekSwipe();
  try {
    /* 启动落点只有两种，不再依赖“8 秒冷启动”判定：
       - 已登录（Cookie 仍有效）→ 直接进课表
       - 未登录 → 页面常驻登录卡（不再是空白纸）
       原来的 _cold 判定一旦不成立就没人开登录卡，首屏就是一张空纸。 */
    if (S.loggedIn) {
      /* 从官网返回：恢复到离开前的页面与周次；冷启动才落本周课表 */
      var _st = takeReturnState();
      if (!(_st && restoreReturnState(_st)) && window.__gotoSchedule) window.__gotoSchedule();
    } else {
      showLoginCard();
      /* 登录统一走系统弹窗：冷启动未登录时直接拉起原生登录框，
         页面只留一张状态卡兜底（不再出现网页账号密码面板）。 */
      if (hasNativeLogin()) { try { Android.showNativeLogin(); } catch (e) {} }
    }
  } catch (e) {}
  document.body.classList.remove('booting');
}

// 每次打开 App 刷新"今日课程"常驻通知（ongoing，一直显示在通知栏，点击跳本周课表）
// 校历第1周周一（用于计算当前教学周）；新学期开学需更新此日期
var SEMESTER_START = new Date(semesterStartDate() + 'T00:00:00');
function currentWeek() {
  /* 非当前学期：“本周”没有意义，统一从第 1 周看起 */
  try { if (selectedSemester() !== currentSemester()) return 1; } catch (e) {}
  var diff = Math.floor((new Date() - SEMESTER_START) / 86400000);
  return Math.min(semesterWeekCount(), Math.max(1, Math.floor(diff / 7) + 1));
}
// 支持范围、列表、多段范围以及单/双周标记。
function weekInRange(expr, cw) {
  if (!expr) return true;
  var s = String(expr).replace(/[，、；;]/g, ',').replace(/第/g, '');
  var both = /单双/.test(s), odd = !both && /单周?|奇数周?/.test(s), even = !both && /双周?|偶数周?/.test(s);
  if (odd && cw % 2 === 0 || even && cw % 2 === 1) return false;
  var ranges = [], re = /(\d+)\s*(?:-|~|至|到)\s*(\d+)/g, m;
  while ((m = re.exec(s))) ranges.push([parseInt(m[1],10), parseInt(m[2],10)]);
  var remainder = s.replace(re, ' ').replace(/单周?|双周?|奇数周?|偶数周?|周/g, ' ');
  var nums = (remainder.match(/\d+/g) || []).map(function(n){return parseInt(n,10);});
  if (ranges.length) return ranges.some(function(r){return cw >= Math.min(r[0],r[1]) && cw <= Math.max(r[0],r[1]);}) || nums.indexOf(cw) >= 0;
  if (nums.length) return nums.indexOf(cw) >= 0;
  return true;
}
function refreshOngoing() {
  try {
    if (!(window.Android && Android.showNotification)) return;
    if ((localStorage.getItem('jwxt_notify_on') || '1') === '0') return;
    const today = new Date().getDay(); const wd = today === 0 ? 7 : today;
    const cw = currentWeek();
    const items = [];
    const seen = new Set();
    for (let i = 0; i < localStorage.length; i++) {
      const k = localStorage.key(i);
      if (!isActivePersonalCacheKey(k)) continue;
      const obj = JSON.parse(localStorage.getItem(k) || 'null');
      const data = obj && obj.data;
      if (!data || !data.courses) continue;
      data.courses.forEach(c => {
        if (c.weekday !== wd || !c.name) return;
        // 周过滤：课程实际周次应含当前周（支持范围"1-15周"/列表/单周）；无周次信息则视为本周课
        if (c.week && !weekInRange(c.week, cw)) return;
        const key = c.name + '|' + (c.period || c.periodLabel || '') + '|' + (c.teacher || '') + '|' + (c.classroom || '');
        if (seen.has(key)) return; seen.add(key);
        const label = c.name + (c.teacher ? ' ' + c.teacher : '') + (c.classroom ? '·' + c.classroom : '');
        items.push(label);
      });
    }
    const uniq = items.slice(0, 3);
    let text;
    if (items.length) text = '今日(第' + cw + '周) ' + items.length + '门课：' + uniq.join('、');
    else text = '今日(第' + cw + '周)无课';
    Android.showNotification('今日课程', text, true);
  } catch (e) {}
}

// 通知权限授予后补发常驻通知
window.__retryNotif = function() { refreshOngoing(); };

// 通知点击跳转：进入本人课表本周表格
/* 去官网/系统页面前记住“当前在哪个页面、什么条件、滚到哪”，回来原样恢复 */
function saveReturnState(){
  try{
    var inRes = document.body.classList.contains('schedule-result') || document.body.classList.contains('in-result');
    var qwEl = document.getElementById('queryWeek');
    var qwdEl = document.getElementById('queryWeekday');
    var nmEl = document.getElementById('queryName');
    localStorage.setItem('jwxt_return_state', JSON.stringify({
      page: document.body.classList.contains('show-settings') ? 'settings' : (inRes ? 'result' : 'main'),
      type: (S.lastPerformedType || S.queryType || ''),
      semester: (typeof selectedSemester === 'function' ? selectedSemester() : ''),
      /* 空值代表“本周”，必须固化成具体周次，否则返回时无法判断回哪一周 */
      week: (qwEl && qwEl.value) || (S.emptyWeek ? String(S.emptyWeek) : '') || String(currentWeek()),
      weekday: (qwdEl && qwdEl.value) || '',
      name: (nmEl && nmEl.value) || (S.lastParams && S.lastParams.name) || '',
      form: S.scheduleForm || 'grid',
      view: S.scheduleView || 'week',
      scroll: window.pageYOffset || document.documentElement.scrollTop || 0,
      ts: Date.now()
    }));
  }catch(e){}
}
/* 页面隐藏/被回收前也记录一次：不只“打开官网”这一条路径，任何重载都能回到原位 */
try{
  if (typeof window !== 'undefined' && !window.__retStateHook){
    window.__retStateHook = true;
    var _saveOnHide = function(){ try{ if (typeof saveReturnState === 'function') saveReturnState(); }catch(e){} };
    window.addEventListener('pagehide', _saveOnHide);
    document.addEventListener('visibilitychange', function(){ if (document.visibilityState === 'hidden') _saveOnHide(); });
  }
}catch(e){}

function takeReturnState(){
  try{
    var raw = localStorage.getItem('jwxt_return_state'); if(!raw) return null;
    localStorage.removeItem('jwxt_return_state');
    var st = JSON.parse(raw);
    if(!st || !st.ts || Date.now() - st.ts > 4*3600*1000) return null;  // 超过 4 小时当冷启动
    return st;
  }catch(e){ return null; }
}
function restoreReturnState(st){
  try{
    if(st.semester){
      S.semester = st.semester;
      localStorage.setItem('jwxt_sem_sel', st.semester);
      try{
        var semSel = document.getElementById('querySemester'); if(semSel) semSel.value = st.semester;
        var tb = document.getElementById('tbSemText');
        if(tb && typeof semesterLabel === 'function') tb.textContent = semesterLabel(st.semester);
      }catch(e){}
    }
    if(st.form) S.scheduleForm = st.form;
    if(st.type) S.queryType = st.type;
    var qw = document.getElementById('queryWeek'); if(qw && st.week) qw.value = st.week;
    var qwd = document.getElementById('queryWeekday'); if(qwd && st.weekday) qwd.value = st.weekday;
    var nm = document.getElementById('queryName'); if(nm && st.name) nm.value = st.name;

    /* 设置页：原样回到设置 */
    if(st.page === 'settings'){ showTab('settings', true); return true; }
    /* 主页面：停在这一页，不再强跳课表 */
    if(st.page === 'main' && !st.type){ showTab('main', true); return true; }

    var SCHEDULE_TYPES = ['self','teacher','classroom','class','course'];
    if(st.page === 'result' && st.type){
      if(SCHEDULE_TYPES.indexOf(st.type) >= 0){
        var wk = st.week ? parseInt(st.week,10) : 0;
        if(st.type === 'self' && window.__gotoSchedule){
          window.__gotoSchedule({week: wk, type: 'self', form: st.form || 'grid', view: st.view || 'week'});
          return document.body.classList.contains('schedule-result');
        }
        /* 教师/教室/班级/课程课表：按离开时的类型和条件重跑，命中缓存即还原，
           不能像以前那样一律塞进“我的课表”，否则会跳到默认课表界面 */
        if(typeof runQuery === 'function'){
          S.queryType = st.type;
          if(st.form) S.scheduleForm = st.form;
          var qw2 = document.getElementById('queryWeek'); if(qw2 && wk) qw2.value = String(wk);
          var qwd2 = document.getElementById('queryWeekday'); if(qwd2) qwd2.value = st.weekday || '';
          var nm2 = document.getElementById('queryName'); if(nm2 && st.name) nm2.value = st.name;
          document.body.classList.toggle('sched-list', (st.form || 'grid') === 'list');
          showTab('main', true);
          setTimeout(function(){ try{ runQuery(false); }catch(e){} }, 0);
          return true;
        }
      } else if(typeof runQuery === 'function'){
        /* 成绩/空教室/考试等结果页：按离开前的条件重跑，命中缓存会瞬间还原 */
        if(st.type === 'empty' && st.week) S.emptyWeek = parseInt(st.week,10) || 0;
        showTab('main', true);
        setTimeout(function(){ try{ runQuery(false); }catch(e){} }, 0);
        return true;
      }
    }
    /* 离开时在主页面/设置：就停在主页面，不再因为“上次查过课表”把人拽进课表页 */
    if(st.page === 'main'){ showTab('main', true); return true; }
  }catch(e){}
  return false;
}

window.__gotoSchedule = function(opt) {
  if (!S.loggedIn) { showLoginCard(); return; }
  try {
    var wantWeek = (opt && opt.week) ? opt.week : 0;
    let best = null, bestT = -1, bestWeek = 0;
    for (let i = 0; i < localStorage.length; i++) {
      const k = localStorage.key(i);
      if (!isActivePersonalCacheKey(k)) continue;
      const raw = localStorage.getItem(k);
      const obj = raw ? JSON.parse(raw) : null;
      /* 指定周次时优先命中该周的缓存（从官网返回要回到原周，而不是拿最新周充数） */
      if (obj && obj.data) {
        const km = String(k).match(/_w(\d+)(?:_d[1-7])?$/);
        if (wantWeek && km && parseInt(km[1], 10) === wantWeek && !(best && bestWeek === wantWeek)) {
          best = obj.data; bestT = obj.t; bestWeek = wantWeek; continue;
        }
      }
      if (obj && obj.data && obj.t > bestT) {
        bestT = obj.t; best = obj.data;
        const m = String(k).match(/_w(\d+)(?:_d[1-7])?$/);
        bestWeek = m ? parseInt(m[1], 10) : 0;
      }
    }
    if (!best) { S.queryType = 'self'; const qw0 = document.getElementById('queryWeek'); if (qw0) qw0.value = wantWeek ? String(wantWeek) : ''; const qwd = document.getElementById('queryWeekday'); if (qwd) qwd.value = ''; runQuery(); return; }
    S.queryType = 'self'; S.scheduleForm = (opt && opt.form) ? opt.form : 'grid';
    S.scheduleView = (opt && opt.view) ? opt.view : 'week';
    /* 形态（周/日）要跟着离开时的那一屏走，不能一律按周课表重画 */
    document.body.classList.toggle('sched-list', S.scheduleForm === 'list');
    /* 缓存是哪一周的就落到哪一周，否则会拿“第1周”去筛第12周的缓存，看着就像没加载 */
    const qw = document.getElementById('queryWeek');
    /* 启动一律落在“当前周”；只有缓存本身是某一周的旧格式时才跟着那一周 */
    if (qw) qw.value = String(wantWeek || bestWeek || currentWeek());
    const qwd = document.getElementById('queryWeekday'); if (qwd) qwd.value = '';
    document.getElementById('cacheNotice').classList.remove('hidden');
    showView('result', true);
    document.getElementById('resultLabel').textContent = '我的课表' + ((wantWeek || bestWeek) ? '' : ' (本周)');
    renderResult('self', best);
  } catch (e) {}
};

function setRefreshBusy(on) {
  document.querySelectorAll('.js-refresh').forEach(function (b) {
    b.classList.toggle('busy', on);
    if (b.tagName === 'BUTTON') b.disabled = on;
  });
}

// 今日课程横向滚动（读本人课表各周缓存中今天(weekday)的课）
function todaySpan(c) {
  let n = (c.period || '').match(/\d{2}/g); if (!n) n = (c.periodLabel || '').match(/\d+/g);
  if (n && n.length) return parseInt(n[0], 10); return 99;
}