/* 刷新串联包装：必须在 05-render.js 定义 runQuery 之后再安装，
   否则加载时捕获到的是 undefined（拆分成多文件后失去函数声明提升） */
var __runQueryRaw = runQuery;
runQuery = async function (forceRefresh) {
  // 只有用户主动点刷新（forceRefresh）才显示刷新反馈；进页面读缓存不算刷新
  if (!forceRefresh) return __runQueryRaw(forceRefresh);
  var t0 = Date.now();
  setRefreshBusy(true);
  scheduleTip('正在刷新…');
  var ok = true;
  try {
    return await __runQueryRaw(forceRefresh);
  } catch (e) {
    ok = false;
    scheduleTip('刷新失败');
    throw e;
  } finally {
    var wait = Math.max(0, 450 - (Date.now() - t0));
    setTimeout(function () {
      setRefreshBusy(false);
      if (ok && forceRefresh && typeof S !== 'undefined' && S.loggedIn) scheduleTip('已更新');
    }, wait);
  }
};

/* ===== 06-ui ===== 原 index.html 内联脚本第 3104-3580 行（顺序分片，逻辑未改） */
function copyCourseInfo(all) {
  var c = (S.lastCourses || [])[S.detailIdx];
  if (!c) return;
  var parts = [];
  if (c.name) parts.push(c.name);
  if (c.periodLabel) parts.push(c.periodLabel);
  if (c.teacher) parts.push('教师: ' + c.teacher);
  if (c.classroom) parts.push('教室: ' + c.classroom);
  if (c.classes) parts.push('班级: ' + c.classes);
  if (c.week) parts.push('周次: ' + c.week);
  var text = all ? parts.join('\n') : (c.classroom || (c.name || ''));
  var ok = doCopy(text);
  alert(ok ? ('已复制：' + text) : '复制失败');
}

function doCopy(text) {
  try {
    if (window.Android && typeof Android.copy === 'function') {
      Android.copy(text); return true;
    }
  } catch(e) {}
  try {
    var ta = document.createElement('textarea');
    ta.value = text;
    ta.style.position = 'fixed'; ta.style.top = '0'; ta.style.left = '0';
    ta.style.width = '1px'; ta.style.height = '1px'; ta.style.opacity = '0';
    document.body.appendChild(ta);
    ta.focus(); ta.select(); ta.setSelectionRange(0, text.length);
    var ok = document.execCommand('copy');
    document.body.removeChild(ta);
    return ok;
  } catch(e2) { return false; }
}

function closeDetail() {
  document.getElementById('detailOverlay').style.display = 'none';
  document.getElementById('detailSection').classList.add('hidden');
  document.getElementById('detailSection').style.display = 'none';
}

// ============ 浏览列表 ============
async function openPicker() {
  const map = {teacher: 'teacher', class: 'class', classroom: 'classroom', course: 'course'};
  const b = map[S.queryType];
  if (b) openBrowse(b);
}

async function openBrowse(type, forceRefresh) {
  S.browseType = type;
  document.getElementById('browseSection').classList.remove('hidden');
  document.getElementById('browseOverlay').style.display = 'block';
  document.getElementById('browseTitle').textContent = {teacher:'全校教师', class:'全校班级', classroom:'全校教室', course:'全校课程'}[type];

  // 先读缓存（仅当缓存里确有内容才直接用，空/失败缓存不拦截刷新）
  const browseCacheKey = 'browse_'+type+'_'+selectedSemester();
  const cached = getCache(browseCacheKey);
  const cacheList = cached && (cached.data.teachers || cached.data.classes || cached.data.classrooms || cached.data.courses);
  if (cacheList && cacheList.length && !forceRefresh) {
    S.browseData = cached.data;
    S.browseFiltered = cached.data;
    renderBrowse();
    return;
  }

  if (!S.loggedIn) {
    document.getElementById('browseSection').classList.add('hidden');
    document.getElementById('browseOverlay').style.display = 'none';
    showLogin();
    scheduleTip('登录后即可查看全校列表');
    return;
  }

  document.getElementById('browseContent').innerHTML = '<div class="loading"><span class="spinner"></span></div>';

  try {
    let data;
    if (type === 'teacher') {
      const body = 'xnxqh='+selectedSemester()+'&kbjcmsid='+KBJCMSID+'&skyx=&jszc=&skjsid=&skjs=&zc1=1&zc2='+semesterWeekCount()+'&jc1=&jc2=';
      data = parseList(httpPost('/jsxsd/kbcx/kbxx_teacher_ifr', body), 'teacher');
    } else if (type === 'class') {
      const body = 'xnxqh='+selectedSemester()+'&kbjcmsid='+KBJCMSID+'&skyx=&sknj=&skzy=&skbjid=&skbj=&zc1=1&zc2='+semesterWeekCount()+'&jc1=&jc2=';
      data = parseList(httpPost('/jsxsd/kbcx/kbxx_xzb_ifr', body), 'class');
    } else if (type === 'course') {
      const body = 'xnxqh='+selectedSemester()+'&kbjcmsid='+KBJCMSID+'&skyx=&zzdKcSX=&kcid=&kcmc=&zc1=1&zc2='+semesterWeekCount()+'&jc1=&jc2=';
      data = parseList(httpPost('/jsxsd/kbcx/kbxx_kc_ifr', body), 'course');
    } else {
      const body = 'xnxqh='+selectedSemester()+'&kbjcmsid='+KBJCMSID+'&skyx=&xqid=1&jzwid=&jxlvalue=&skjsid=&skjs=&jsid=&zc1=1&zc2='+semesterWeekCount()+'&jc1=&jc2=';
      data = parseList(httpPost('/jsxsd/kbcx/kbxx_classroom_ifr', body), 'classroom');
    }
    // 只在实际解析到内容时才写入缓存，避免把空/失败结果污染缓存
    const list = data && (data.teachers || data.classes || data.classrooms || data.courses);
    if (list && list.length) {
      setCache(browseCacheKey, data);
      S.browseData = data;
      S.browseFiltered = data;
      renderBrowse();
    } else {
      // 查询失败或未解析到内容
      const msg = (data && data.error) ? esc(data.error) : '未解析到数据';
      document.getElementById('browseContent').innerHTML = '<div class="error-box">查询返回空或教务会话可能失效<br>' + msg + '<br><br>请先点顶栏「退出」再重新「登录」后，点本弹窗「刷新」重试</div>';
    }
  } catch(e) {
    if (cached && !forceRefresh) {
      S.browseData = cached.data;
      S.browseFiltered = cached.data;
      renderBrowse();
    } else {
      document.getElementById('browseContent').innerHTML = '<div class="error-box">'+esc(e.message)+'</div>';
    }
  }
}

function renderBrowse() {
  try {
  var data = S.browseFiltered;
  if (!data) return;
  // 清空字母导航栏
  document.getElementById('letterNavContainer').innerHTML = '';
  // 兼容旧版本缓存：如果是数组，根据类型转成对象格式
  if (Array.isArray(data)) {
    if (S.browseType === 'teacher') data = {teachers: data};
    else if (S.browseType === 'class') data = {classes: data};
    else if (S.browseType === 'course') data = {courses: data};
    else data = {classrooms: data};
  }
  S.browseFiltered = data;
  var el = document.getElementById('browseContent');

  if (S.browseType === 'teacher') {
    const teachers = data.teachers || [];
    document.getElementById('browseCount').textContent = teachers.length + ' 人';
    const groups = {};
    teachers.forEach(t => {
      const py = pinyinFirst(t);
      (groups[py] = groups[py] || []).push(t);
    });
    const ALPHABET = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
    // 字母导航栏放到固定位置
    var navH = '';
    ALPHABET.forEach(l => {
      const has = groups[l] !== undefined;
      if (has) {
        navH += '<span class="active" onclick="scrollToGroup(\''+l+'\')">'+l+'</span>';
      } else {
        navH += '<span class="inactive">'+l+'</span>';
      }
    });
    document.getElementById('letterNavContainer').innerHTML = '<div class="letter-nav">' + navH + '</div>';
    // 内容区只放分组
    let h = '';
    ALPHABET.forEach(l => {
      if (!groups[l]) return;
      h += '<div class="teacher-group" id="group_'+l+'"><div class="teacher-group-title">'+l+' <span style="font-size:11px; color:var(--pink-deep); margin-left:8px;">'+groups[l].length+' 人</span></div><div class="teacher-grid">';
      groups[l].forEach(t => {
        h += '<div class="teacher-item" onclick="pickValue(\''+esc(t)+'\')">'+esc(t)+'</div>';
      });
      h += '</div></div>';
    });
    el.innerHTML = h;

  } else if (S.browseType === 'class') {
    const classes = data.classes || [];
    document.getElementById('browseCount').textContent = classes.length + ' 个';
    const grades = {};
    classes.forEach(c => { (grades[c.grade || '其他'] = grades[c.grade || '其他'] || []).push(c); });
    const keys = Object.keys(grades).sort((a,b) => b.localeCompare(a));
    let h = '';
    keys.forEach(g => {
      h += '<div class="grade-group"><div class="grade-title" onclick="this.classList.toggle(\'open\'); this.nextElementSibling.classList.toggle(\'hidden\')"><span>'+(g==='其他'?'其他':g+'级')+'</span><span class="caret"></span></div><div class="class-chips">';
      grades[g].forEach(c => {
        h += '<div class="class-chip" onclick="pickValue(\''+esc(c.name)+'\')">'+esc(c.name)+'</div>';
      });
      h += '</div></div>';
    });
    el.innerHTML = h;

  } else if (S.browseType === 'course') {
    const courses = data.courses || [];
    document.getElementById('browseCount').textContent = courses.length + ' 门';
    let h = '<div class="class-chips" style="padding:4px 0;">';
    courses.forEach(function (n) {
      h += '<div class="class-chip" onclick="pickValue(\'' + esc(n) + '\')">' + esc(n) + '</div>';
    });
    el.innerHTML = h + '</div>';

  } else {
    const rooms = data.classrooms || [];
    document.getElementById('browseCount').textContent = rooms.length + ' 间';
    const buildings = {};
    rooms.forEach(r => { const b = getBuilding(r); (buildings[b] = buildings[b] || []).push(r); });
    const order = ['一教','二教','三教','四教','五教','警体馆','射击馆','图书馆','实验楼','其他'];
    const keys = Object.keys(buildings).sort((a,b) => {
      const ai = order.indexOf(a), bi = order.indexOf(b);
      if (ai === -1 && bi === -1) return a.localeCompare(b);
      if (ai === -1) return 1; if (bi === -1) return -1;
      return ai - bi;
    });
    let h = '';
    keys.forEach((b, i) => {
      h += '<div class="building-item"><button class="building-head'+(i===0?' open':'')+'" onclick="this.classList.toggle(\'open\'); this.nextElementSibling.classList.toggle(\'open\')">';
      h += '<span>'+b+'</span><span style="display:flex; align-items:center; gap:6px;"><span class="caret"></span>'+buildings[b].length+' 间</span></button>';
      h += '<div class="building-body'+(i===0?' open':'')+'"><div class="room-grid">';
      buildings[b].forEach(r => {
        h += '<div class="room-item" onclick="pickValue(\''+esc(r)+'\')">'+esc(r)+'</div>';
      });
      h += '</div></div></div>';
    });
    el.innerHTML = h;
  }
  } catch(e) {
    try { document.getElementById('browseContent').innerHTML = '<div class="error-box">列表渲染出错：'+esc(e.message||'未知错误')+'</div>'; } catch(e2) {}
  }
}

function filterBrowse() {
  const kw = document.getElementById('browseSearch').value.trim().toLowerCase();
  var data = S.browseData || {};
  if (!kw) { S.browseFiltered = data; renderBrowse(); return; }
  if (S.browseType === 'teacher') {
    var teachers = data.teachers || (Array.isArray(data) ? data : []);
    S.browseFiltered = {teachers: teachers.filter(function(t) { return t.toLowerCase().includes(kw); })};
  } else if (S.browseType === 'class') {
    var classes = data.classes || [];
    S.browseFiltered = {classes: classes.filter(function(c) { return c.name.toLowerCase().includes(kw); })};
  } else if (S.browseType === 'course') {
    var courses = data.courses || [];
    S.browseFiltered = {courses: courses.filter(function(n) { return String(n).toLowerCase().includes(kw); })};
  } else {
    var classrooms = data.classrooms || (Array.isArray(data) ? data : []);
    S.browseFiltered = {classrooms: classrooms.filter(function(r) { return r.toLowerCase().includes(kw); })};
  }
  renderBrowse();
}

function pickValue(v) {
  document.getElementById('queryName').value = v;
  goBack();
}
function scrollToGroup(l) {
  var el = document.getElementById('group_'+l);
  if (!el) return;
  var content = document.getElementById('browseContent');
  // 计算元素相对于 content 的位置
  var contentRect = content.getBoundingClientRect();
  var elRect = el.getBoundingClientRect();
  var y = content.scrollTop + (elRect.top - contentRect.top);
  content.scrollTo({top: y, behavior: 'smooth'});
}

function getBuilding(name) {
  if (!name) return '其他';
  var n = name.trim();
  // 先看括号里的内容
  var parenMatch = n.match(/[（(]([^)）]*)[)）]/);
  if (parenMatch) {
    var paren = parenMatch[1];
    // 括号里有 "一教/二教..." 关键词
    if (paren.indexOf('一教') >= 0 || paren.indexOf('1教') >= 0) return '一教';
    if (paren.indexOf('二教') >= 0 || paren.indexOf('2教') >= 0) return '二教';
    if (paren.indexOf('三教') >= 0 || paren.indexOf('3教') >= 0) return '三教';
    if (paren.indexOf('四教') >= 0 || paren.indexOf('4教') >= 0) return '四教';
    if (paren.indexOf('五教') >= 0 || paren.indexOf('5教') >= 0) return '五教';
    if (paren.indexOf('警体') >= 0 || paren.indexOf('体育馆') >= 0) return '警体馆';
    if (paren.indexOf('射击') >= 0 || paren.indexOf('靶场') >= 0) return '射击馆';
    if (paren.indexOf('图书') >= 0) return '图书馆';
    if (paren.indexOf('实验') >= 0 || paren.indexOf('实训') >= 0) return '实验楼';
    // 括号里是 "4-503"、"3C1"、"1-106" 这种格式
    var pm = paren.match(/^([1-9])[\-\－]/);
    if (pm) {
      var pnames = {1:'一教',2:'二教',3:'三教',4:'四教',5:'五教'};
      if (pnames[parseInt(pm[1])]) return pnames[parseInt(pm[1])];
    }
    var pm2 = paren.match(/^([1-9])[A-Za-z]/);
    if (pm2) {
      var pnames2 = {1:'一教',2:'二教',3:'三教',4:'四教',5:'五教'};
      if (pnames2[parseInt(pm2[1])]) return pnames2[parseInt(pm2[1])];
    }
  }
  if (n.indexOf('警体') >= 0 || n.indexOf('体育馆') >= 0) return '警体馆';
  if (n.indexOf('射击') >= 0 || n.indexOf('靶场') >= 0) return '射击馆';
  if (n.indexOf('图书') >= 0) return '图书馆';
  if (n.indexOf('实验') >= 0 || n.indexOf('实训') >= 0) return '实验楼';
  if (n.indexOf('一教') >= 0 || n.indexOf('1教') >= 0) return '一教';
  if (n.indexOf('二教') >= 0 || n.indexOf('2教') >= 0) return '二教';
  if (n.indexOf('三教') >= 0 || n.indexOf('3教') >= 0) return '三教';
  if (n.indexOf('四教') >= 0 || n.indexOf('4教') >= 0) return '四教';
  if (n.indexOf('五教') >= 0 || n.indexOf('5教') >= 0) return '五教';
  // 匹配 1-xxx, 2-xxx, 3-xxx, 3Cx, 4-xxx 等格式
  var m = n.match(/^([1-9])[\-\－]/);
  if (m) {
    var names = {1:'一教',2:'二教',3:'三教',4:'四教',5:'五教'};
    if (names[parseInt(m[1])]) return names[parseInt(m[1])];
  }
  var m2 = n.match(/^([1-9])[A-Za-z]/);
  if (m2) {
    var names2 = {1:'一教',2:'二教',3:'三教',4:'四教',5:'五教'};
    if (names2[parseInt(m2[1])]) return names2[parseInt(m2[1])];
  }
  // 匹配 "教学楼X" 格式
  var m3 = n.match(/^教学楼([一二三四五12345])/);
  if (m3) {
    var cn = m3[1];
    if (cn === '一' || cn === '1') return '一教';
    if (cn === '二' || cn === '2') return '二教';
    if (cn === '三' || cn === '3') return '三教';
    if (cn === '四' || cn === '4') return '四教';
    if (cn === '五' || cn === '5') return '五教';
  }
  return '其他';
}

// 常见姓氏首字母映射
function pinyinFirst(name) {
  if (name === null || name === undefined) return '#';
  if (typeof name !== 'string') name = String(name);
  name = name.trim();
  if (!name) return '#';
  var first = name.charAt(0);
  // 查映射表
  for (var letter in SURNAMES) {
    if (SURNAMES[letter].indexOf(first) >= 0) return letter;
  }
  return '#';
}

// Shared by the visible week and its swipe preview; no demo courses enter query storage.
const SCHEDULE_COLORS = ['#D65642','#67CC29','#D17743','#36D6C3','#D6426A','#705ED6','#7DB51D','#AD7E2D','#25B0CC','#BD31BD'];
const SCHEDULE_TIMES = [
  ['08:00','08:45'],['08:55','09:40'],['10:00','10:45'],['10:55','11:40'],
  ['14:30','15:15'],['15:25','16:10'],['16:20','17:05'],['17:15','18:00'],
  ['19:00','19:45'],['19:55','20:40'],['21:00','21:35'],['21:55','22:40']
];
function scheduleWeek() {
  const w = parseInt(document.getElementById('queryWeek').value, 10);
  return w >= 1 ? w : currentWeek();
}
function scheduleCache(w) {
  const params = {week:String(w), weekday:document.getElementById('queryWeekday').value};
  if (NEEDS_NAME.indexOf(S.queryType) >= 0) params.name = document.getElementById('queryName').value.trim();
  if (NEEDS_SEM.indexOf(S.queryType) >= 0) params.semester = document.getElementById('querySemester').value;
  /* 本人课表也必须显式带学期：cacheKey 缺省时会回落到 currentSemester()，
     在过去学期切周就会读到本学期的缓存（切哪个周都显示本学期课表）。 */
  if (S.queryType === 'self') params.semester = (typeof selectedSemester === 'function' ? selectedSemester() : (typeof currentSemester === 'function' ? currentSemester() : ''));
  var selfSem = (typeof selectedSemester === 'function' ? selectedSemester() : (typeof currentSemester === 'function' ? currentSemester() : ''));
  if (S.queryType === 'self') {
    /* 本人课表：整学期缓存是唯一数据源，切周只在本地按周过滤 */
    var allKey = cacheKey('self', {semester: selfSem}) + '_all';
    var whole = getCache(allKey);
    if (whole && whole.data && Array.isArray(whole.data.courses)) {
      return {t: whole.t, data: Object.assign({}, whole.data, {week: w, allWeeks: true})};
    }
    return getCache(cacheKey('self', params)); /* 兼容旧的按周缓存 */
  }
  var key = cacheKey(S.queryType, params);
  var hit = getCache(key);
  if (hit) return hit;
  var all = getCache(key.replace(/_w\d+$/, '') + '_all');
  if (all && all.data && Array.isArray(all.data.courses)) {
    return {t: all.t, data: Object.assign({}, all.data, {week: w, allWeeks: true})};
  }
  return null;
}
function switchScheduleWeek(w) {
  if (!Number.isInteger(w) || w < 1) return false;
  document.getElementById('queryWeek').value = String(w);
  const cached = scheduleCache(w);
  if (!cached || !cached.data || !Array.isArray(cached.data.courses) || cached.data.error) {
    // 没有缓存也切过去，显示空的课表
    scheduleTip('第'+w+'周暂无缓存，可点查询拉取本周数据');
    renderResult(S.queryType, {courses:[], week:w, emptyWeek:true});
    return true;
  }
  renderResult(S.queryType, cached.data);
  return true;
}
function closeWeekPicker() {
  document.getElementById('weekPicker').style.display = 'none';
  document.getElementById('weekPickerMask').style.display = 'none';
}
function scheduleTip(message) {
  let el = document.getElementById('scheduleToast');
  if (!el) { el = document.createElement('div'); el.id = 'scheduleToast'; el.setAttribute('role','status'); document.body.appendChild(el); }
  el.textContent = message; el.hidden = false;
  clearTimeout(scheduleTip.timer); scheduleTip.timer = setTimeout(() => { el.hidden = true; }, 3000);
}
function scheduleColor(name) {
  let h = 0; for (const c of (name || '')) h = (h * 31 + c.charCodeAt(0)) % 997;
  var color=SCHEDULE_COLORS[h % SCHEDULE_COLORS.length];
  if(document.documentElement&&document.documentElement.getAttribute('data-theme')==='dark'){
    var n=parseInt(color.slice(1),16);return '#'+[n>>16&255,n>>8&255,n&255].map(function(v){return Math.round(v+(255-v)*.38).toString(16).padStart(2,'0');}).join('');
  }return color;
}
function scheduleFill(hex) {
  const n = parseInt(hex.slice(1),16);
  if(document.documentElement&&document.documentElement.getAttribute('data-theme')==='dark')return 'rgb('+[n>>16&255,n>>8&255,n&255].map(function(v){return Math.round(24+(v-24)*.15);}).join(',')+')';
  return 'rgb('+[n >> 16 & 255,n >> 8 & 255,n & 255].map(v => Math.round(v+(255-v)*.86)).join(',')+')';
}
function gridTeacher(c) {
  var t = (c && (c.teacher || c.teacherAll || '')) + '';
  t = t.replace(/[,，]\s*\.{2,}/g, '').replace(/,\s*$/,'').trim();
  if (!t || t === '..') return '';
  var parts = t.split(/[,，、\s]+/).filter(Boolean);
  if (!parts.length) return '';
  /* 同一周两名教师时直接标出两人；三人及以上才用「等」收尾 */
  if (parts.length <= 2) return parts.join('、');
  return parts.slice(0, 2).join('、') + '等';
}
function formatGridCourseName(name) {
  var chars=Array.from(name||''),rows=[];for(var i=0;i<chars.length;i+=4)rows.push('<span>'+esc(chars.slice(i,i+4).join(''))+'</span>');return rows.join('');
}
// 单列模式当前查看的星期（1-7），默认今天
function listDay() {
  if (!S.listDay) { S.listDay = new Date().getDay() || 7; }
  return S.listDay;
}
function setListDay(d) {
  S.listDay = ((d - 1 + 7) % 7) + 1;
  renderResult(S.queryType, S.lastData);
}
function todayScheduleEntries(data,w,now) {
  var wd = listDay();
  /* 单列也要能看别的周：只按“这一天＋这一周”过滤，不再因为不是本周就清空 */
  return (data.courses||[]).map(function(c,i){return {c:c,i:i};}).filter(function(x){return Number(x.c.weekday)===wd&&(!x.c.week||weekInRange(x.c.week,w));}).sort(function(a,b){return (courseSpan(a.c)||{s:99}).s-(courseSpan(b.c)||{s:99}).s;});
}
function renderTodayScheduleList(data,w) {
  var now=new Date(), base=new Date(SEMESTER_START);
  base.setDate(base.getDate()+(w-1)*7+(listDay()-1));
  var isToday = listDay()===(new Date().getDay()||7)&&w===currentWeek();
  var entries=todayScheduleEntries(data,w,now),date=base.toLocaleDateString('zh-CN',{month:'long',day:'numeric',weekday:'long'});
  var html='<div class="today-schedule-list"><header class="today-list-head"><div><span class="eyebrow">'+(isToday?'TODAY':'DAY')+'</span><h2>'+(isToday?'今天的课程':'周'+['一','二','三','四','五','六','日'][listDay()-1]+'的课程')+'</h2><p>'+esc(date)+' · 第'+w+'周</p></div><span class="today-list-count">'+entries.length+' 门</span></header>';
  if(!entries.length)html+='<div class="today-list-empty">'+esc(data.error||'这一天没有课程安排')+'<p>左右滑动可切换相邻日期。</p></div>';
  entries.forEach(function(item){var c=item.c,span=courseSpan(c),color=scheduleColor(c.name),start=span&&SCHEDULE_TIMES[span.s-1],end=span&&SCHEDULE_TIMES[span.e-1];
    html+='<button type="button" class="today-list-course" onclick="showCourseByIndex('+item.i+')" style="--course-accent:'+color+'"><div class="today-list-time"><strong>'+esc(start?start[0]:'待定')+'</strong><span>'+esc(end?end[1]:'')+'</span><small>'+esc(span?'第'+span.s+'–'+span.e+'节':c.periodLabel||'节次待确认')+'</small></div><div class="today-list-detail"><h3>'+esc(c.name||'未命名课程')+'</h3><dl><div><dt>教室</dt><dd>'+esc(c.classroom||'待确认')+'</dd></div><div><dt>教师</dt><dd>'+esc(c.teacherAll||c.teacher||'待确认')+'</dd></div><div><dt>班级</dt><dd>'+esc(c.classes||'待确认')+'</dd></div></dl><span class="today-list-week">'+esc(c.week||'本周')+'</span></div></button>';
  });return html+'</div>';
}
function buildSchedulePane(data, w, preview, missing) {
  /* 只画这一周真正要上的课，否则 16-17 周、13-14 周的课会叠到别的周上 */
  const courses = (data.courses || []).filter(function (c) {
    return !c.week || weekInRange(c.week, w);
  });
  /* 网格点击的序号必须回指这份过滤后的数组，否则会串到别的课程 */
  S.gridCourses = courses;
  const monday = new Date(SEMESTER_START); monday.setDate(monday.getDate() + (w-1)*7);
  const now = new Date();
  let h = '<div class="demo-pane"><div class="demo-head"><div class="demo-month">'+(monday.getMonth()+1)+'月</div><div class="demo-days">';
  for (let d=1; d<=7; d++) {
    const date = new Date(monday); date.setDate(date.getDate()+d-1);
    const today = date.getFullYear()===now.getFullYear() && date.getMonth()===now.getMonth() && date.getDate()===now.getDate();
    h += '<div class="demo-day'+(today?' today':'')+'"><div class="wd">'+['一','二','三','四','五','六','日'][d-1]+'</div><div class="dt">'+date.getDate()+'</div></div>';
  }
  h += '</div></div><div class="demo-scroll"><div class="demo-periods">';
  SCHEDULE_TIMES.forEach((t,i) => { h += '<div class="demo-period"><div class="no">'+(i+1)+'</div><div class="tm">'+t[0]+'<br>'+t[1]+'</div></div>'; });
  h += '</div><div class="demo-grid" style="height:'+SCHEDULE_TIMES.length*78+'px">';
  for (let i=1;i<SCHEDULE_TIMES.length;i++) h += '<div class="demo-line" style="top:'+i*78+'px"></div>';
  if (missing || !courses.length) h += '<div class="demo-empty">'+(missing?'第'+w+'周暂无缓存':esc(data.error || '本周暂无课程'))+'</div>';
  /* 同格多课：先统计每个「星期+起始节次」的课程数，绘制时只画首门，其余计数后用角标提示 */
  const cellCount = {}, drawnCell = {};
  let overflow = 0;
  courses.forEach(c => {
    const sp = courseSpan(c); if (!sp) return;
    const k = c.weekday + '|' + sp.s;
    cellCount[k] = (cellCount[k] || 0) + 1;
  });
  S.gridOverflow = 0;
  courses.forEach((c,i) => {
    const sp = courseSpan(c); if (!sp || sp.s < 1 || sp.e < sp.s || sp.e > SCHEDULE_TIMES.length || c.weekday < 1 || c.weekday > 7 || !c.weekday) return;
    const cellKey = c.weekday + '|' + sp.s;
    if (drawnCell[cellKey]) { overflow++; return; }
    drawnCell[cellKey] = 1;
    const extra = (cellCount[cellKey] || 1) - 1;
    const color = scheduleColor(c.name);
    h += '<button class="demo-course" '+(preview?'tabindex="-1"':'onclick="showCourseByIndex('+i+',\'grid\')"')+' aria-label="'+esc((c.name||'')+' 第'+sp.s+'-'+sp.e+'节'+(c.teacher?' '+c.teacher:''))+'" style="top:'+(sp.s-1)*78+'px;height:'+((sp.e-sp.s+1)*78-4)+'px;left:calc('+((c.weekday-1)*100/7)+'% + 1px);width:calc('+(100/7)+'% - 2px);background:'+scheduleFill(color)+';border-color:'+color+';color:'+color+'"><div class="cn">'+formatGridCourseName(c.name||'')+'</div>';
    var ctName = gridTeacher(c);
    if (ctName) h += '<div class="ct">'+esc(ctName)+'</div>';
    if (c.classroom) h += '<div class="cs">@'+esc(c.classroom).replace(/([（(]\d+-\d+[）)])/g,'<span class="nw">$1</span>')+'</div>';
    if (extra > 0) h += '<span class="demo-more" aria-hidden="true">+' + extra + '</span>';
    h += '</button>';
  });
  S.gridOverflow = overflow;
  return h + '</div></div></div>';
}
function renderScheduleResult(type, data) {
  const courses = data.courses || []; S.lastCourses = courses;
  const w = scheduleWeek();
  document.getElementById('tbWeekText').textContent = '第 '+w+' 周';
  /* 非当前学期没有“本周”概念：不做红字提示，也不给“回到本周” */
  var _isCurSem = selectedSemester() === currentSemester();
  document.getElementById('tbWeekText').parentElement.classList.toggle('other-week', _isCurSem && w !== currentWeek());
  document.getElementById('backCurrentWeek').hidden = !_isCurSem || w === currentWeek();
  /* 学期文案用“2026-秋季”这种，和学期面板里的选项一致 */
  updateSemesterText();
  document.getElementById('tbIconGrid').style.display = S.scheduleForm === 'list' ? 'none' : '';
  document.getElementById('tbIconList').style.display = S.scheduleForm === 'list' ? '' : 'none';
  const el = document.getElementById('resultContent');
  if (S.scheduleForm !== 'list') {
    el.innerHTML = buildSchedulePane(data,w,false,!!data.emptyWeek);
    const unplaced = courses.filter(c => !courseSpan(c));
    if (S.gridOverflow > 0) {
      const tip = document.createElement('div'); tip.className = 'demo-unplaced demo-overflow-tip';
      tip.textContent = '同时段多门课，格内显示首门（+N 为门数），列表可看全部';
      el.querySelector('.demo-head').after(tip);
    }
    if (unplaced.length) {
      const notice = document.createElement('div'); notice.className = 'demo-unplaced';
      notice.textContent = unplaced.length+'门课程缺少节次信息，可切换列表查看';
      el.querySelector('.demo-head').after(notice);
    }
    return;
  }
  el.innerHTML = renderTodayScheduleList(data,w);
}

try { init(); } finally { /* 原来固定等 400ms 才揭开遮罩，等于每次启动硬加 400ms；改成下一帧就揭 */
  requestAnimationFrame(function(){ requestAnimationFrame(function(){ document.body.classList.remove('booting'); }); });
  setTimeout(function(){ document.body.classList.remove('booting'); }, 400); /* 兜底：首帧异常时也能揭开 */ }
/* 首帧之后才挂底部那张 1.75MB / 80 帧的动图，避免和首屏渲染抢 CPU */
setTimeout(function(){ document.body.classList.add('deco-ready'); }, 300);
onTypeChange();
document.getElementById('loginBtn').innerHTML=ICO_LOGIN;document.getElementById('logoutBtn').innerHTML=ICO_LOGOUT;
initExperience();
(function () {
  var tile = document.getElementById('settingsTile');
  if (!tile) return;
  var tab = tile.querySelector('.fd-tab');
  if (tab) tab.onclick = function (e) {
    e.stopPropagation();
    if (tile._justDragged) return;
    openSettingsTile();
  };
})();