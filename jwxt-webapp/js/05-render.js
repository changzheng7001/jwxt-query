/* ===== 05-render ===== 原 index.html 内联脚本第 2330-3103 行（顺序分片，逻辑未改） */
function renderTodayCourses() {
  const el = document.getElementById('todayCourses');
  const sec = document.getElementById('todaySection');
  if (!el || !sec) return;
  const today = new Date().getDay(); const wd = today === 0 ? 7 : today;
  const list = [];
  try {
    for (let i = 0; i < localStorage.length; i++) {
      const k = localStorage.key(i);
      if (!isActivePersonalCacheKey(k)) continue;
      const obj = JSON.parse(localStorage.getItem(k) || 'null');
      const data = obj && obj.data;
      if (!data || !data.courses) continue;
      data.courses.forEach(c => {
        if (c.weekday !== wd) return;
        if (c.week && !weekInRange(c.week, currentWeek())) return;
        const key = c.name + '|' + (c.period || c.periodLabel || '') + '|' + (c.classroom || '');
        if (!list.some(x => x._k === key)) { c._k = key; list.push(c); }
      });
    }
  } catch (e) {}
  if (!list.length) {
    el.innerHTML = '<div class="today-course-empty">今日无课</div>';
    const cnt0 = document.getElementById('todayCount');
    if (cnt0) cnt0.textContent = '0门';
    sec.classList.remove('hidden');
    return;
  }
  list.sort((a, b) => todaySpan(a) - todaySpan(b));
  let h = '<div class="today-course-scroll">';
  list.forEach(c => {
    const sp = todaySpan(c);
    h += '<div class="today-course-chip' + (sp % 2 === 0 ? ' pink' : '') + '"><div class="tc-name">' + esc(c.name || '') + '</div><div class="tc-meta">第' + sp + '节 · ' + esc(c.classroom || '') + '</div></div>';
  });
  h += '</div>';
  el.innerHTML = h;
  const cnt = document.getElementById('todayCount');
  if (cnt) cnt.textContent = list.length + '门';
  sec.classList.remove('hidden');
}

function selectType(v) {
  S.queryType = v;
  var btns = document.querySelectorAll('.type-btn');
  for (var i = 0; i < btns.length; i++) {
    if (btns[i].dataset.v === v) btns[i].classList.add('active');
    else btns[i].classList.remove('active');
  }
  onTypeChange();
}

function checkCacheStatus() {
  refreshCacheList();
  const scope = activeAccountScope() || 'guest';
  const hasCache = hasCachePrefix(CK+'self_u'+scope+'_'+currentSemester()+'_') || hasCachePrefix(CK+'score_u'+scope+'_');
  var sdr = document.getElementById('statusDotResult');
  if (S.loggedIn) {
    if (sdr) sdr.style.background = 'var(--green)';
    return;
  }
  if (hasCache) {
    if (sdr) sdr.style.background = '#b5544f';
  }
}

function refreshCacheList() {
  var el=document.getElementById('cacheList');if(!el)return;
  var info=cacheInventory(localStorage,activeAccountScope());el.innerHTML=renderCacheInventory(info,{collapsed:true});
  var settings=document.getElementById('settingsCacheSummary');if(settings)settings.innerHTML=renderCacheInventory(info);
}

function clearAllCache() {
  if (!confirm('确定清空所有缓存数据吗？')) return;
  var keys = [];
  for (var i = 0; i < localStorage.length; i++) {
    var k = localStorage.key(i);
    if (k && k.indexOf(CK) === 0) keys.push(k);
  }
  keys.forEach(function(k) { localStorage.removeItem(k); });
  refreshCacheList();
  alert('已清空全部缓存');
}

function weekRowHidden() {
  var row = document.getElementById('weekRow');
  return !row || row.classList.contains('hidden') || getComputedStyle(row).display === 'none';
}
function onTypeChange() {
  var t = S.queryType;
  document.getElementById('nameRow').classList.toggle('hidden', !NEEDS_NAME.includes(t));
  document.getElementById('weekRow').classList.toggle('hidden', !NEEDS_WEEK.includes(t));
  document.getElementById('semesterRow').classList.toggle('hidden', !NEEDS_SEM.includes(t));
  /* 表单行显隐会改变浮层高度：重新分配一次，并把表单滚进可视区 */
  try {
    if (typeof queueFloatLayout === 'function') queueFloatLayout();
    setTimeout(function () {
      var panel = document.getElementById('querySection');
      if (!panel || !panel.classList.contains('open')) return;
      var card = panel.querySelector('.card');
      var row = document.getElementById('weekRow');
      var nameRow = document.getElementById('nameRow');
      var anchor = (!weekRowHidden() && row) ? row : nameRow;
      if (card && anchor) card.scrollTop = Math.max(0, anchor.offsetTop - 46);
    }, 220);
  } catch (e) {}
}

// ============ 查询 ============
function cacheAgeText(t) {
  var d = Date.now() - (t || 0);
  if (!t || d < 0) return '时间未知';
  if (d < 5 * 60 * 1000) return '刚刚';
  if (d < 60 * 60 * 1000) return Math.round(d / 60000) + ' 分钟前';
  if (d < 24 * 60 * 60 * 1000) return Math.round(d / 3600000) + ' 小时前';
  return Math.round(d / 86400000) + ' 天前';
}
/* 旧缓存后台静默更新：只有“当前还停在这次查询上”才覆盖画面，避免抢掉用户新开的页面 */
function autoRefreshStale(type, params, ck, cached) {
  if (!S.loggedIn) return;
  var age = Date.now() - ((cached && cached.t) || 0);
  if (age < 3 * 60 * 1000) return;
  if (S._autoRefreshing) return;
  S._autoRefreshing = true;
  setTimeout(async function () {
    try {
      var data = await doQuery(type, params);
      if (!data || data.error) return;
      setCache(ck, data);
      if (S.view !== 'result' || S.queryType !== type) return;
      if (params.semester && selectedSemester() !== params.semester) return;
      renderResult(type, data);
      var cn = document.getElementById('cacheNotice');
      if (cn) { cn.textContent = '已自动更新 · 刚刚'; cn.classList.remove('hidden'); }
      try { checkCacheStatus(); renderTodayCourses(); } catch (e) {}
    } catch (e) {
    } finally {
      S._autoRefreshing = false;
    }
  }, 80);
}
async function runQuery(forceRefresh) {
  document.getElementById('cacheNotice').textContent='离线缓存 · 刷新可获取最新数据';
  var type = S.queryType;
  var params = {};
  if (NEEDS_NAME.indexOf(type) >= 0) params.name = document.getElementById('queryName').value.trim();
  if (NEEDS_WEEK.indexOf(type) >= 0) {
    const wkEl = document.getElementById('queryWeek');
    let wk = wkEl.value.trim();
    if (!wk) wk = String(currentWeek());   // 默认查询本周
    params.week = wk;
    params.weekday = document.getElementById('queryWeekday').value;
  }
  if (NEEDS_SEM.indexOf(type) >= 0 || type === 'self' || type === 'empty') params.semester = selectedSemester();

  // 记住本次查询条件，供「前往官网」把同样的条件带过去
  S.lastParams = params;
  S.lastPerformedType = type;

  var ck = cacheKey(type, params);
  /* 本人课表的数据源就是整学期理论课表：只存一份整学期缓存，
     不再同时写“按周缓存”（同一份数据存两遍，体积白白翻倍，还会互相打架）。 */
  if (type === 'self') ck = cacheKey('self', {semester: params.semester}) + '_all';
  var cached = getCache(ck);

  var debug = '';

  // 有缓存：直接显示缓存，不要后台拉新
  if (cached && !forceRefresh) {
    showView('result', true);
    document.getElementById('cacheNotice').classList.remove('hidden');
    document.getElementById('cacheNotice').textContent = '离线缓存 · ' + cacheAgeText(cached.t) + ' · 会自动更新';
    var typeName = '';
    for (var i = 0; i < TYPES.length; i++) { if (TYPES[i].v === type) { typeName = TYPES[i].l; break; } }
    document.getElementById('resultLabel').textContent = typeName + ' (缓存)';
    try {
      renderResult(type, cached.data);
    } catch(err) {
      document.getElementById('resultContent').innerHTML = '<div class="error-box">渲染出错，请点刷新重试<br><span style="font-size:12px;opacity:.7">'+esc(err.message)+'</span></div>';
    }
    /* 缓存已经旧了：先把缓存画出来，再静默拉一次最新数据，用户不用自己点刷新 */
    autoRefreshStale(type, params, ck, cached);
    return;
  }

  // 未登录：有缓存才进结果页展示缓存，没缓存就留在原地弹登录，不跳空页面
  if (!S.loggedIn) {
    if (cached) {
      showView('result', true);
      renderResult(type, cached.data);
      scheduleTip('请先登录后刷新，当前显示离线缓存');
    } else {
      /* 未登录且没有缓存：弹登录，并记住这次查询，登录成功后自动补上结果 */
      S.retryAfterLogin = { type: type, params: params, force: true };
      showLogin();
      scheduleTip('登录后即可查询' + (type === 'self' ? '你的课表' : '这一项'));
    }
    return;
  }

  // 需要拉新数据
  showView('result', true);
  document.getElementById('resultContent').innerHTML = '<div style="padding:20px; text-align:center;">查询中... 类型: '+type+'</div>';
  /* 原生 httpRequest 是同步阻塞的，先让出一帧，保证上面这句“查询中”真的被画出来 */
  await new Promise(function(r){ setTimeout(r, 0); });

  try {
    const data = await doQuery(type, params);
    if(data&&data.error)throw new Error(data.error);
    const saved=setCache(ck, data);
    document.getElementById('cacheNotice').classList.add('hidden');
    var typeName2 = '';
    for (var ti = 0; ti < TYPES.length; ti++) { if (TYPES[ti].v === type) { typeName2 = TYPES[ti].l; break; } }
    document.getElementById('resultLabel').textContent = typeName2;
    renderResult(type, data);
    if(!saved){document.getElementById('cacheNotice').textContent='本次查询未能保存离线缓存';document.getElementById('cacheNotice').classList.remove('hidden');}
    checkCacheStatus();renderTodayCourses();
  } catch(e) {
    var msg = String(e && e.message || '');
    /* 登录态失效时别再报“查不到”：直接拉起系统登录框，登录成功后自动重跑这次查询 */
    if (cached) {
      document.getElementById('cacheNotice').classList.remove('hidden');
      renderResult(type, cached.data);
      scheduleTip('刷新失败，已保留并显示离线缓存');
      return;
    }
    if (!S.loggedIn || /登录|会话|会话失效|未登|Logon|timeout|超时|课表为空|未查询到|无权|没有权限|课表矩阵|未找到课表/i.test(msg)) {
      S.loggedIn = false;
      S.retryAfterLogin = { type: type, params: params, force: true };
      showLogin();
      document.getElementById('resultContent').innerHTML = '<div class="empty-text" style="padding:28px 20px;text-align:center;">登录状态已失效，正在等待重新登录…<br><small>登录成功后会自动返回这次查询结果。</small>'+
        '<div style="margin-top:16px;display:flex;gap:10px;justify-content:center"><button onclick="showLogin()" style="padding:11px 18px;border-radius:10px;border:0;background:#7c4034;color:#fff;font-size:14px;">登录教务系统</button>'+
        '<button onclick="runQuery(true)" style="padding:11px 18px;border-radius:10px;border:1px solid currentColor;background:transparent;color:inherit;opacity:.85;font-size:14px;">重试</button></div></div>';
      scheduleTip('登录状态已失效，请先登录');
      return;
    }
    // 出错时，先显示错误信息，不管有没有缓存
    document.getElementById('cacheNotice').classList.remove('hidden');
    var authHint = (!S.loggedIn || /登录|会话|未登|Logon|课表为空|未查询到/i.test(msg))
      ? '<div style="margin-top:8px;font-size:13px;opacity:.9">可能是登录状态已失效。</div>'
      : '';
    document.getElementById('resultContent').innerHTML = '<div class="error-box" style="padding:20px;">查询出错: '+esc(e.message)+authHint+
      '<div style="margin-top:14px;display:flex;gap:10px">'+
      '<button onclick="showLogin()" style="flex:1;padding:11px;border-radius:10px;border:0;background:#7c4034;color:#fff;font-size:14px;">重新登录</button>'+
      '<button onclick="runQuery(true)" style="flex:1;padding:11px;border-radius:10px;border:1px solid rgba(0,0,0,.12);background:transparent;color:inherit;font-size:14px;">重试</button></div>'+
      '<div style="margin-top:10px;font-size:11px;opacity:.55">类型: '+esc(type)+' · 参数: '+esc(JSON.stringify(params))+'</div></div>';
  }
}

// ============ 渲染结果 ============
function selectEmptyBuilding(b) {
  S.emptyBuilding = b;
  if (S.lastType && S.lastData) renderResult(S.lastType, S.lastData);
}
function showEmptyDetail(building, dayIdx, slotIdx) {
  if (!S.lastData || !S.lastData.buildings) return;
  var bd = S.lastData.buildings.find(function(b){return b.building===building;});
  if (!bd) return;
  var free = (bd.grid[slotIdx] && bd.grid[slotIdx][dayIdx]) || [];
  var DAY_LABELS = ['周一','周二','周三','周四','周五'];
  var SLOT_LABEL = ['第1-2节','第3-4节','第5-6节','第7-8节','第9-10节','第11-12节'];
  // 按楼层分组：教室名如 "2-101" → 短横线后第一个数字=楼层
  var byFloor = {};
  free.forEach(function(r) {
    var m = r.match(/-\s*(\d)/);
    var fl = m ? parseInt(m[1],10) : 0;
    if (!byFloor[fl]) byFloor[fl] = [];
    byFloor[fl].push(r);
  });
  var floors = Object.keys(byFloor).sort(function(a,b){return parseInt(a,10)-parseInt(b,10);});
  var body = '<div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;">'
    + '<b style="font-size:16px;">'+bd.label+' · '+DAY_LABELS[dayIdx]+' · '+SLOT_LABEL[slotIdx]+'</b>'
    + '<span style="cursor:pointer; font-size:18px; color:var(--ink-light);" onclick="document.getElementById(\'emptyModal\').style.display=\'none\';">✕</span></div>';
  body += '<div style="font-size:12px; color:var(--ink-light); margin-bottom:12px;">共 '+free.length+' 间空教室</div>';
  floors.forEach(function(fl) {
    body += '<div style="margin-bottom:12px;"><div style="font-weight:700; font-size:13px; color:var(--accent); margin-bottom:4px;">'+fl+'楼</div>';
    body += '<div style="font-size:14px; line-height:1.8; word-break:keep-all;">'+esc(byFloor[fl].join('、'))+'</div></div>';
  });
  var modal = document.getElementById('emptyModal');
  if (modal) { modal.firstElementChild.innerHTML = body; modal.style.display = 'block'; }
}
function renderResult(type, data) {
  const el = document.getElementById('resultContent');
  S.lastType = type;
  try { localStorage.setItem('jwxt_queryType', type); } catch (e) {} S.lastData = data;
  document.body.classList.add('in-result');
  const isSchedule = ['self','teacher','classroom','class','course'].indexOf(type) >= 0;
  document.body.classList.toggle('schedule-result', isSchedule);
  document.body.classList.toggle('empty-result', type === 'empty');
  document.body.classList.toggle('sched-list', isSchedule && S.scheduleForm === 'list');
  document.getElementById('resultLogoutBtn').style.display = '';
  document.getElementById('backCurrentWeek').hidden = !isSchedule;
  ['tbToggleForm','tbRefreshResult'].forEach(id => { const el = document.getElementById(id); if (el) el.style.display = isSchedule ? '' : 'none'; });
  collapseFloats();

  // 统一更新顶栏标题
  var TYPE_NAMES = {self:'我的课表', teacher:'教师课表', classroom:'教室课表', class:'班级课表', course:'课程课表', courselist:'课程列表',
    score:'成绩查询', gpa:'绩点计算', progress:'学习进度', exam:'考试安排', profile:'学籍卡片',
    elective:'选课轮次', electives:'选课结果', calendar:'教学周历', empty:'空教室'};
  var tbT = document.getElementById('tbResultTitle');
  /* 顶栏标题只认查询类型：列表视图左右滑动会换天，写死“今天的课程”会名不副实 */
  if (tbT) tbT.textContent = TYPE_NAMES[type] || '查询结果';

  /* 左上角两行只在“这个查询真的有这个参数”时才出现：
     - 周次：所有课表类 + 空教室
     - 学期：课表类 + 带 semester 参数的查询（成绩/考试/选课结果） */
  var hasWeek = isSchedule || type === 'empty';
  if (type === 'empty') {
    var ew = parseInt((typeof S !== 'undefined' && S.emptyWeek) || (data && data.week) || currentWeek(), 10) || currentWeek();
    var wt = document.getElementById('tbWeekText');
    if (wt) wt.textContent = '第 ' + ew + ' 周';
    var wr = document.getElementById('tbWeekRow');
    if (wr) wr.classList.toggle('other-week', ew !== currentWeek());
  }
  var hasSem = isSchedule || ['score', 'exam', 'electives', 'elective'].indexOf(type) >= 0;
  var weekRow = document.getElementById('tbWeekRow');
  var semRow = document.getElementById('tbSemRow');
  var block = weekRow && weekRow.parentElement;
  if (weekRow) weekRow.style.display = hasWeek ? '' : 'none';
  if (semRow) semRow.style.display = hasSem ? '' : 'none';
  if (block) block.style.display = (hasWeek || hasSem) ? '' : 'none';
  if (hasSem) updateSemesterText();

  if (type === 'score') {
    if (!data.courses || !data.courses.length) { el.innerHTML = '<div class="empty-text">无成绩</div>'; return; }
    let h = '<div class="table-wrap"><table><thead><tr><th>课程</th><th>成绩</th><th>学分</th><th>绩点</th><th>性质</th><th>学期</th></tr></thead><tbody>';
    data.courses.forEach(c => {
      const fail = !isPass(c.grade);
      h += '<tr><td style="'+(fail?'color:var(--pink-deep);':'')+'">'+esc(c.name)+'</td>';
      h += '<td class="'+(fail?'failed':'')+'">'+esc(c.grade)+'</td>';
      h += '<td>'+c.credit+'</td><td>'+(c.gpa||'—')+'</td>';
      h += '<td style="font-size:11px;">'+esc(c.courseNature||'')+'</td>';
      h += '<td style="font-size:11px; color:var(--ink-light);">'+esc(c.semester ? semesterLabel(c.semester) : '')+'</td></tr>';
    });
    el.innerHTML = h + '</tbody></table></div>';

  } else if (type === 'gpa') {
    const f = data.failedCourses || [];
    let h = '<div class="gpa-hero"><div class="label">GPA</div><div class="value">'+data.gpa.toFixed(2)+'</div><div class="sub">加权均分 '+(data.weightedAvg||'—')+'</div></div>';
    h += '<div class="stats-row">';
    h += '<div class="stat-box pink"><div class="label">已修学分</div><div class="value">'+data.passedCredits+'</div></div>';
    h += '<div class="stat-box green"><div class="label">总学分</div><div class="value">'+data.totalCredits+'</div></div>';
    h += '<div class="stat-box cream"><div class="label">挂科</div><div class="value" style="color:'+(data.failedCount?'var(--pink-deep)':'var(--green)')+'">'+data.failedCount+'</div></div>';
    h += '</div>';
    if (f.length) {
      h += '<div class="card card-pink" style="padding:10px;"><div class="card-header"><span class="mono">不及格</span></div>';
      f.forEach(c => { h += '<p style="color:var(--pink-deep); font-size:12px; padding:3px 0;">⚠ '+esc(c.name)+' ('+esc(c.grade)+')</p>'; });
      h += '</div>';
    }
    el.innerHTML = h;

  } else if (type === 'progress') {
    if (!data.rows || !data.rows.length) {
      var errMsg = data.error || '无进度数据';
      if (data.raw) errMsg += '<br><br>原始返回：<pre style="font-size:10px; text-align:left; white-space:pre-wrap;">' + esc(data.raw) + '</pre>';
      el.innerHTML = '<div class="empty-text">' + errMsg + '</div>';
      return;
    }
    // 先显示表格形式，确保能看到数据
    var headers = Object.keys(data.rows[0]);
    var h = '<div class="table-wrap"><table><thead><tr>';
    headers.forEach(function(hd) { h += '<th>'+esc(hd)+'</th>'; });
    h += '</tr></thead><tbody>';
    data.rows.forEach(function(r) {
      h += '<tr>';
      headers.forEach(function(hd) { h += '<td>'+esc(r[hd])+'</td>'; });
      h += '</tr>';
    });
    el.innerHTML = h + '</tbody></table></div>';

  } else if (type === 'exam') {
    if (!data.exams || !data.exams.length) { el.innerHTML = '<div class="empty-text">'+esc(data.error||'无考试安排')+'</div>'; return; }
    const headers = Object.keys(data.exams[0]);
    let h = '<div class="table-wrap"><table><thead><tr>';
    headers.forEach(hd => h += '<th>'+esc(hd)+'</th>');
    h += '</tr></thead><tbody>';
    data.exams.forEach(e => {
      h += '<tr>';
      headers.forEach(hd => h += '<td>'+esc(e[hd])+'</td>');
      h += '</tr>';
    });
    el.innerHTML = h + '</tbody></table></div>';

  } else if (type === 'profile') {
    var keys = Object.keys(data);
    if (!keys.length) { el.innerHTML = '<div class="empty-text">无学籍信息</div>'; return; }
    var highlightKeys = ['姓名', '学号', '班级'];
    var h = '<div style="display:grid; grid-template-columns:1fr 1fr; gap:8px;">';
    keys.forEach(function(k) {
      var isHighlight = false;
      for (var hi = 0; hi < highlightKeys.length; hi++) {
        if (k.indexOf(highlightKeys[hi]) >= 0 || highlightKeys[hi].indexOf(k) >= 0) {
          isHighlight = true; break;
        }
      }
      if (isHighlight) {
        h += '<div style="background:var(--green); border:2px solid var(--green); border-radius:6px; padding:12px;">';
        h += '<div style="font-size:11px; color:var(--pink); font-family:monospace;">' + esc(k) + '</div>';
        h += '<div style="font-size:15px; color:var(--cream); margin-top:4px;">' + esc(data[k] || '—') + '</div>';
        h += '</div>';
      } else {
        h += '<div style="background:var(--cream-2); border:2px solid var(--green); border-radius:6px; padding:12px;">';
        h += '<div style="font-size:11px; color:var(--green); font-family:monospace;">' + esc(k) + '</div>';
        h += '<div style="font-size:15px; color:var(--ink); margin-top:4px;">' + esc(data[k] || '—') + '</div>';
        h += '</div>';
      }
    });
    el.innerHTML = h + '</div>';

  } else if (type === 'electives') {
    if (!data.electives || !data.electives.length) {
      var errMsg = data.error || '无选课结果';
      if (data.raw) errMsg += '<br><br>原始返回：<pre style="font-size:10px; text-align:left; white-space:pre-wrap;">' + esc(data.raw) + '</pre>';
      el.innerHTML = '<div class="empty-text">' + errMsg + '</div>';
      return;
    }
    // 先显示表格形式，确保能看到数据
    var headers = Object.keys(data.electives[0]);
    var h = '<div class="table-wrap"><table><thead><tr>';
    headers.forEach(function(hd) { h += '<th>'+esc(hd)+'</th>'; });
    h += '</tr></thead><tbody>';
    data.electives.forEach(function(row) {
      h += '<tr>';
      headers.forEach(function(hd) { h += '<td>'+esc(row[hd])+'</td>'; });
      h += '</tr>';
    });
    el.innerHTML = h + '</tbody></table></div>';

  } else if (type === 'empty') {
    if (!data.buildings || !data.buildings.length) {
      el.innerHTML = '<div class="empty-text">无空教室数据<br><br>请先登录并查询一次「全校教室」，让 App 拿到教室名单后再看空教室</div>';
      return;
    }
    var SLOT_LABEL = ['第1-2节','第3-4节','第5-6节','第7-8节','第9-10节','第11-12节'];
    var DAY_LABELS = ['周一','周二','周三','周四','周五'];
    if (S.emptyBuilding === undefined || !data.buildings.find(function(b){return b.building===S.emptyBuilding;})) {
      S.emptyBuilding = data.buildings[0].building;
    }
    var h = '<div style="padding:4px 2px 8px; font-size:12px; color:var(--ink-light);">第'+data.week+'周 · 周一至周五 · 点击格子查看具体空教室</div>';
    // 教学楼选择器（横向标签）
    h += '<div style="display:flex; gap:6px; overflow-x:auto; padding:4px 0 12px; -webkit-overflow-scrolling:touch;">';
    data.buildings.forEach(function(bd) {
      var active = bd.building === S.emptyBuilding;
      h += '<button onclick="selectEmptyBuilding(\''+bd.building+'\')" style="flex-shrink:0; padding:6px 14px; border-radius:16px; border:1px solid '+(active?'var(--accent)':'var(--border)')+'; background:'+(active?'var(--accent)':'transparent')+'; color:'+(active?'#fff':'var(--ink)')+'; font-size:13px; font-weight:600;">'+esc(bd.label)+'</button>';
    });
    h += '</div>';
    // 只显示选中教学楼的矩阵：复刻易校园真实课表样式
    var bd = data.buildings.find(function(b){return b.building===S.emptyBuilding;});
    if (bd) {
      var todayDow = new Date().getDay(); todayDow = todayDow===0?7:todayDow;
      // 计算本周一~周五的日期
      var now = new Date();
      var dow = (now.getDay()+6)%7; // 周一=0
      var monday = new Date(now); monday.setDate(now.getDate()-dow);
      h += '<div style="margin:4px 0 16px;">';
      h += '<div style="font-weight:700; font-size:16px; margin:4px 0 2px;">'+esc(bd.label)+'</div>';
      h += '<div style="font-size:11px; color:var(--ink-light); margin-bottom:12px;">共 '+bd.rooms.length+' 间 · 点击格子查看</div>';
      // Grid 容器：1 节次列(40px) + 5 天列，格子间有间距
      h += '<div style="display:grid; grid-template-columns:40px repeat(5,1fr); gap:4px; padding:4px;">';
      // 左上角角格（月份）
      h += '<div style="display:flex; align-items:flex-end; justify-content:center; padding-bottom:8px; font-size:11px; color:var(--ink-light); font-weight:600;">'+(monday.getMonth()+1)+'月</div>';
      // 表头：星期几 + 日期，今天用胶囊高亮
      for (var di=0; di<5; di++) {
        var ddate = new Date(monday); ddate.setDate(monday.getDate()+di);
        var isToday = (di+1)===todayDow;
        var DAY_CH = ['一','二','三','四','五'];
        h += '<div style="text-align:center; padding:4px 0 8px;">';
        h += '<div style="font-size:12px; color:var(--ink-light); font-weight:600; margin-bottom:2px;">周'+DAY_CH[di]+'</div>';
        if (isToday) {
          h += '<div style="display:inline-block; width:26px; height:26px; line-height:26px; border-radius:50%; background:var(--accent); color:#fff; font-size:13px; font-weight:700;">'+ddate.getDate()+'</div>';
        } else {
          h += '<div style="font-size:13px; color:var(--ink); font-weight:600;">'+ddate.getDate()+'</div>';
        }
        h += '</div>';
      }
      // 6 大节 × 5 天
      var EMPTY_TIMES = [
        ['08:00','09:40'],['10:00','11:40'],['14:30','16:10'],
        ['16:20','18:00'],['19:00','20:40'],['21:00','22:40']
      ];
      bd.grid.forEach(function(row, si) {
        // 节次列：节次号 + 上下课时间
        h += '<div style="display:flex; flex-direction:column; align-items:center; justify-content:center; font-size:13px; font-weight:700; color:var(--ink-light); line-height:1.2;">';
        h += '<span>'+(si+1)+'</span>';
        h += '<span style="font-size:8px; font-weight:400; color:var(--ink-light); margin-top:2px;">'+EMPTY_TIMES[si][0]+'<br>'+EMPTY_TIMES[si][1]+'</span>';
        h += '</div>';
        row.forEach(function(free, di) {
          var n = free.length;
          var isToday = (di+1)===todayDow;
          if (n > 0) {
            h += '<div onclick="showEmptyDetail(\''+bd.building+'\','+di+','+si+')" style="border-radius:10px; padding:10px 4px; text-align:center; cursor:pointer; min-height:48px; display:flex; flex-direction:column; align-items:center; justify-content:center; background:'+(isToday?'color-mix(in srgb, var(--accent) 15%, transparent)':'color-mix(in srgb, var(--accent) 7%, transparent)')+';">';
            h += '<b style="font-size:17px; color:var(--accent); line-height:1.1;">'+n+'</b>';
            h += '<div style="font-size:9px; color:var(--ink-light); margin-top:2px;">间空</div>';
            h += '</div>';
          } else {
            h += '<div style="border-radius:10px; min-height:48px; background:transparent;"></div>';
          }
        });
      });
      h += '</div></div>';
    }
    el.innerHTML = h;
    // 弹窗容器
    if (!document.getElementById('emptyModal')) {
      var m = document.createElement('div');
      m.id = 'emptyModal';
      m.style.cssText = 'display:none; position:fixed; top:0; left:0; right:0; bottom:0; z-index:9999; background:rgba(0,0,0,.4);';
      m.onclick = function(e){ if(e.target===m) m.style.display='none'; };
      m.innerHTML = '<div style="position:absolute; bottom:0; left:0; right:0; max-height:70vh; overflow-y:auto; background:var(--sheet-bg); border-radius:16px 16px 0 0; padding:16px; box-sizing:border-box; border-top:1px solid var(--line);;"></div>';
      document.body.appendChild(m);
    }

  } else if (type === 'courselist') {
    renderCourseList(data);
  } else {
    renderScheduleResult(type, data);
  }
}

function renderCourseList(data) {
  const el = document.getElementById('resultContent');
  const list = (data && data.courses) || [];
  if (!list.length) { el.innerHTML = '<div class="empty-text">没有查到课程</div>'; return; }
  const map = {};
  list.forEach(function (c) {
    const k = c.name || '';
    if (!k) return;
    if (!map[k]) map[k] = {name:k, teachers:[], rooms:[], weeks:[], times:[], classes:[]};
    const it = map[k];
    const add = function (arr, v) { if (v && arr.indexOf(v) < 0) arr.push(v); };
    add(it.teachers, c.teacher);
    add(it.rooms, c.classroom);
    add(it.weeks, c.week);
    add(it.classes, c.classes);
    add(it.times, (c.weekdayName || '') + (c.periodLabel || ''));
  });
  const arr = Object.keys(map).map(function (k) { return map[k]; }).sort(function (a, b) { return a.name.localeCompare(b.name, 'zh'); });
  let h = '<div class="cl-head">共 ' + arr.length + ' 门课程</div><div class="cl-list">';
  arr.forEach(function (it) {
    h += '<div class="cl-item"><div class="cl-name">' + esc(it.name) + '</div>';
    const meta = [];
    if (it.teachers.length) meta.push('教师　' + it.teachers.join('、'));
    if (it.classes.length) meta.push('班级　' + it.classes.slice(0, 3).join('、') + (it.classes.length > 3 ? ' 等' : ''));
    if (it.rooms.length) meta.push('地点　' + it.rooms.slice(0, 3).join('、'));
    if (it.times.length) meta.push('时间　' + it.times.slice(0, 5).join('、') + (it.times.length > 5 ? ' 等' : ''));
    if (it.weeks.length) meta.push('周次　' + it.weeks.slice(0, 2).join('、'));
    meta.forEach(function (m) { h += '<div class="cl-meta">' + esc(m) + '</div>'; });
    h += '</div>';
  });
  el.innerHTML = h + '</div>';
}

function setScheduleForm(v) {
  S.scheduleForm=v;
  document.body.classList.toggle('sched-list', v === 'list');
  /* 单列沿用当前周次与学期：切形态不再把页面拽回本周 */
  var button=document.getElementById('tbToggleForm');if(button){button.title=v==='list'?'切换周课表':'只看今天';button.setAttribute('aria-label',button.title);}
  renderResult(S.queryType,S.lastData);
}

// 切换网格/列表（图标按钮）
function toggleScheduleForm() {
  setScheduleForm(S.scheduleForm === 'grid' ? 'list' : 'grid');
}

// 查询/浏览浮窗点击展开收起
function fitFloatPanel(el) {
  /* 浮层高度由 layoutOpenFloats 统一分配；这里只保证内容区可滚动，
     底部按钮不会再被屏幕下沿裁掉 */
  if (!el || !el.classList.contains('open')) return;
  try {
    var card = el.querySelector('.card');
    if (card && card.style) { card.style.overflowY = 'auto'; card.style.webkitOverflowScrolling = 'touch'; }
    if (el.style) { el.style.overflowY = 'auto'; el.style.webkitOverflowScrolling = 'touch'; }
  } catch (e) {}
}
function toggleResultFloat(id) {
  toggleDockFloat(id);
}

// 水平滑动切周（带相邻周预览）
function initWeekSwipe() {
  const el = document.getElementById('resultContent');
  if (!el || el._swipeInited) return;
  el._swipeInited = true;
  const ghost = document.createElement('div'); ghost.id = 'weekGhost';
  ghost.style.cssText = 'position:absolute;inset:0;display:none;pointer-events:none;overflow:hidden;z-index:2';
  el.parentElement.style.position = 'relative'; el.parentElement.appendChild(ghost);
  let sx = 0, sy = 0, dx = 0, axis = null, active = false, adjacent = null, moved = false;
  function reset() { el.style.transform = ''; ghost.style.display = 'none'; ghost.innerHTML = ''; active = false; axis = null; adjacent = null; }
  function start(x, y) {
    if (!document.body.classList.contains('schedule-result')) return;
    sx = x; sy = y; dx = 0; axis = null; active = true; moved = false;
  }
  function move(x, y, e) {
    if (!active) return;
    dx = x - sx; const dy = y - sy;
    if (!axis && Math.max(Math.abs(dx), Math.abs(dy)) < 8) return;
    if (!axis) axis = Math.abs(dx) > Math.abs(dy) ? 'h' : 'v';
    if (axis !== 'h') return;
    if (S.scheduleForm === 'list') { // 单列：跟手位移
      moved = true;
      el.style.transition = 'none';
      el.style.transform = 'translateX('+dx*0.55+'px)';
      if (e.cancelable) e.preventDefault();
      return;
    }
    moved = true; const w = scheduleWeek() + (dx < 0 ? 1 : -1);
    const width = el.clientWidth || window.innerWidth;
    if (!adjacent || adjacent.week !== w) {
      adjacent = { week:w, cached:w >= 1 ? scheduleCache(w) : null };
      ghost.innerHTML = w < 1 ? '<div class="demo-empty">已经是第1周</div>' : buildSchedulePane(adjacent.cached ? adjacent.cached.data : {courses:[]}, w, true, !adjacent.cached);
      ghost.style.display = 'block';
    }
    const drag = w < 1 ? dx * .2 : dx;
    el.style.transform = 'translateX('+drag+'px)';
    ghost.style.transform = 'translateX('+(drag + (dx < 0 ? width : -width))+'px)';
    if (e.cancelable) e.preventDefault();
  }
  function end() {
    if (!active) return;
    if (S.scheduleForm === 'list') { // 单列：左右切天
      const width2 = el.clientWidth || window.innerWidth;
      const sw = axis === 'h' && Math.abs(dx) > width2 * .18;
      if (!sw) { el.style.transition='transform .22s cubic-bezier(.22,.61,.36,1)'; el.style.transform=''; active=false; axis=null; setTimeout(function(){el.style.transition='';},240); return; }
      const dir = dx < 0 ? 1 : -1;   // 左滑=下一天，右滑=前一天
      el.style.transition = 'transform .24s cubic-bezier(.22,.61,.36,1)';
      el.style.transform = 'translateX(' + (-dir * width2) + 'px)';
      active = false; axis = null;
      setTimeout(function(){
        el.style.transition='none'; el.style.transform='';
        setListDay(listDay() + dir);
        requestAnimationFrame(function(){ el.style.transition=''; });
      }, 250);
      return;
    }
    const w = adjacent && adjacent.week;
    const width = el.clientWidth || window.innerWidth;
    const shouldSwitch = axis === 'h' && Math.abs(dx) > width * .18 && w >= 1;
    if (!shouldSwitch) {
      if (moved) {
        // 未达阈值：顺滑回弹
        el.style.transition = 'transform .22s cubic-bezier(.22,.61,.36,1)';
        el.style.transform = '';
        ghost.style.transition = 'transform .22s cubic-bezier(.22,.61,.36,1)';
        ghost.style.transform = 'translateX(' + (dx < 0 ? width : -width) + 'px)';
        const g = ghost;
        setTimeout(function(){ g.style.display='none'; g.innerHTML=''; g.style.transition=''; g.style.transform=''; }, 230);
      } else { reset(); }
      active = false; axis = null; adjacent = null;
      return;
    }
    // 达阈值：整屏顺滑滑过去，动画结束后再换数据
    const dir = dx < 0 ? -1 : 1;
    el.style.transition = 'transform .24s cubic-bezier(.22,.61,.36,1)';
    el.style.transform = 'translateX(' + (dir * width) + 'px)';
    ghost.style.transition = 'transform .24s cubic-bezier(.22,.61,.36,1)';
    ghost.style.transform = 'translateX(0px)';
    active = false; axis = null; adjacent = null;
    setTimeout(function(){
      el.style.transition = 'none'; el.style.transform = '';
      ghost.style.display = 'none'; ghost.innerHTML = ''; ghost.style.transition = ''; ghost.style.transform = '';
      switchScheduleWeek(w);
      requestAnimationFrame(function(){ el.style.transition = ''; });
    }, 250);
  }
  el.addEventListener('touchstart', e => start(e.touches[0].clientX, e.touches[0].clientY), {passive:true});
  el.addEventListener('touchmove', e => move(e.touches[0].clientX, e.touches[0].clientY, e), {passive:false});
  el.addEventListener('touchend', end, {passive:true});
  el.addEventListener('touchcancel', reset, {passive:true});
  el.addEventListener('mousedown', e => { if (e.button === 0) start(e.clientX, e.clientY); });
  window.addEventListener('mousemove', e => move(e.clientX, e.clientY, e));
  window.addEventListener('mouseup', end);
  el.addEventListener('click', e => { if (moved) { e.preventDefault(); e.stopPropagation(); moved = false; } }, true);
}

// 周次选择弹窗
function showWeekPicker() {
  var t = (typeof S !== 'undefined' && (S.lastType || S.queryType)) || '';
  var isSchedule = ['self','teacher','classroom','class','course'].indexOf(t) >= 0;
  if (!isSchedule && t !== 'empty') return;
  if (!isSchedule && t === 'empty') { showEmptyWeekPicker(); return; }
  const pop = document.getElementById('weekPicker');
  const selected = scheduleWeek(), now = currentWeek();
  let h = '<div class="demo-week-head"><strong>查看周课表</strong><button class="demo-week-close" onclick="closeWeekPicker()">关闭</button></div><div class="demo-weeks">';
  for (let w = 1; w <= Math.max(20, selected, now); w++) {
    const cls = w === selected ? ' selected' : (w === now ? ' current' : '');
    h += '<button class="demo-week'+cls+'" onclick="pickWeek('+w+')" aria-pressed="'+(w === selected)+'">'+(w === now && w !== selected ? '本周' : w)+'</button>';
  }
  pop.innerHTML = h + '</div>';
  pop.style.display = 'block'; document.getElementById('weekPickerMask').style.display = 'block';
  document.getElementById('weekPickerMask').onclick = closeWeekPicker;
}
function pickWeek(w) {
  closeWeekPicker();
  var t = (typeof S !== 'undefined' && (S.lastType || S.queryType)) || '';
  if (t === 'empty') {
    /* 空教室按周重新拉取，交互与课表一致 */
    S.emptyWeek = w;
    try { document.getElementById('queryWeek').value = String(w); } catch (e) {}
    scheduleTip('正在查询第 ' + w + ' 周空教室');
    runQuery(true);
    return true;
  }
  return switchScheduleWeek(w);
}

/* ============ 空教室的周次面板（复用同一套样式）============ */
function showEmptyWeekPicker() {
  var pop = document.getElementById('weekPicker');
  var selected = parseInt((typeof S !== 'undefined' && S.emptyWeek) || currentWeek(), 10) || currentWeek();
  var now = currentWeek(), total = semesterWeekCount();
  var h = '<div class="demo-week-head"><strong>查看第几周</strong><button class="demo-week-close" onclick="closeWeekPicker()">关闭</button></div><div class="demo-weeks">';
  for (var w = 1; w <= Math.max(total, selected, now); w++) {
    var cls = w === selected ? ' selected' : (w === now ? ' current' : '');
    h += '<button class="demo-week' + cls + '" onclick="pickWeek(' + w + ')">' + (w === now && w !== selected ? '本周' : w) + '</button>';
  }
  pop.innerHTML = h + '</div>';
  pop.style.display = 'block';
  document.getElementById('weekPickerMask').style.display = 'block';
  document.getElementById('weekPickerMask').onclick = closeWeekPicker;
}

/* ============ 学期面板 ============ */
function showSemesterPicker() {
  var pop = document.getElementById('semesterPicker');
  var mask = document.getElementById('semesterPickerMask');
  var sel = selectedSemester();
  pop.innerHTML = '<div class="demo-week-head"><strong>选择学期</strong><button class="demo-week-close" onclick="closeSemesterPicker()">关闭</button></div>'
    + '<div class="demo-sems" id="semList"><div style="grid-column:1/-1; text-align:center; padding:18px 0; color:#888; font-size:13px;">正在读取学期列表…</div></div>';
  pop.style.display = 'block'; mask.style.display = 'block';
  mask.onclick = closeSemesterPicker;
  fetchSemesterList(function (list) {
    var box = document.getElementById('semList');
    if (!box) return;
    var h = '';
    list.forEach(function (it) {
      var on = it.v === sel;
      h += '<button class="demo-sem' + (on ? ' selected' : '') + '" data-sem="' + it.v + '" onclick="pickSemester(\'' + it.v + '\')">'
        + '<span>' + it.label + '</span>'
        + '<span class="sub">' + it.v + '</span></button>';
    });
    box.innerHTML = h;
  });
}
function closeSemesterPicker() {
  var pop = document.getElementById('semesterPicker');
  var mask = document.getElementById('semesterPickerMask');
  if (pop) pop.style.display = 'none';
  if (mask) mask.style.display = 'none';
}
function pickSemester(v) {
  if (!/^\d{4}-\d{4}-\d{1,2}$/.test(v)) return;
  closeSemesterPicker();
  S.semester = v;
  try { localStorage.setItem('jwxt_sem_sel', v); } catch (e) {}
  var sel = document.getElementById('querySemester');
  if (sel) {
    var has = false;
    for (var i = 0; i < sel.options.length; i++) if (sel.options[i].value === v) has = true;
    if (!has) { var o = document.createElement('option'); o.value = v; o.textContent = v; sel.appendChild(o); }
    sel.value = v;
  }
  /* 切到别的学期先补齐该学期的校历（第1周周一 / 总周数），周次才有意义 */
  ensureSemesterCal(v, function () {
    updateSemesterText();
    /* 校历全局要跟着换，否则 weekMonday()/周次文案仍按原学期算 */
    try { SEMESTER_START = new Date(semesterStartDate() + 'T00:00:00'); } catch (e) {}
    if (S.loggedIn) {
      var firstWeek = (v === currentSemester()) ? currentWeek() : 1;
      document.getElementById('queryWeek').value = String(firstWeek);
      scheduleTip('已切换到 ' + semesterLabel(v));
      runQuery(true);
    } else {
      scheduleTip('已切换到 ' + semesterLabel(v) + '，登录后可查询');
    }
  });
}
function updateSemesterText() {
  var el = document.getElementById('tbSemText');
  if (el) el.textContent = semesterLabel(selectedSemester());
}

// 结果区"查询"按钮：读 resWeek/resWeekday，写回主表单，读缓存重渲染
// 周导航：±1 周（不依赖结果区输入框，直接读写主查询表单）
// 官网对应页面：按当前结果类型映射到教务系统对应模块
function officialUrl() {
  var t = (typeof S !== 'undefined' && (S.lastType || S.queryType)) || '';
  if (!t) { try { t = localStorage.getItem('jwxt_queryType') || ''; } catch (e) {} }
  var base = BASE + '/jsxsd/framework/xsMain.jsp';
  var meta = null;
  var p = (typeof S !== 'undefined' && S.lastParams) || {};
  var nm = p.name || '';
  if (!nm) { try { var el = document.getElementById('queryName'); if (el) nm = el.value.trim(); } catch (e) {} }
  var sem = p.semester || '';
  if (!sem) { try { sem = currentSemester(); } catch (e) {} }
  var wk = p.week || '';
  switch (t) {
    case 'self': base = BASE + '/jsxsd/framework/xsMain.jsp'; break;
    case 'score':
    case 'gpa': base = BASE + '/jsxsd/kscj/cjcx_list'; break;
    case 'teacher':
      base = BASE + '/jsxsd/kbcx/kbxx_teacher';
      meta = { t: 'teacher', name: nm, week: wk, sem: sem };
      break;
    case 'classroom':
      base = BASE + '/jsxsd/kbcx/kbxx_classroom';
      meta = { t: 'classroom', name: nm, week: wk, sem: sem };
      break;
    case 'empty':
      base = BASE + '/jsxsd/kbcx/kbxx_classroom';
      meta = { t: 'classroom', name: nm, week: wk, sem: sem };
      break;
    case 'class':
      base = BASE + '/jsxsd/kbcx/kbxx_xzb';
      meta = { t: 'class', name: nm, week: wk, sem: sem };
      break;
    case 'course':
      base = BASE + '/jsxsd/kbcx/kbxx_kc';
      meta = { t: 'course', name: nm, week: wk, sem: sem };
      break;
 
  }
  // 把查询条件编进 URL，由原生侧在目标页注入脚本回填表单并提交
  if (meta) {
    try {
      var qs = encodeURIComponent(JSON.stringify(meta));
      return base + (base.indexOf('?') >= 0 ? '&' : '?') + '__q=' + qs;
    } catch (e) {}
  }
  return base;
}
function openMode() {
  try { return localStorage.getItem('jwxt_open_mode') === 'browser' ? 'browser' : 'inapp'; } catch (e) { return 'inapp'; }
}
function setOpenMode(m) {
  try { localStorage.setItem('jwxt_open_mode', m === 'browser' ? 'browser' : 'inapp'); } catch (e) {}
  syncOpenModeUI();
}
function syncOpenModeUI() {
  var m = openMode();
  var a = document.getElementById('openmode-inapp'), b = document.getElementById('openmode-browser');
  if (a) a.classList.toggle('on', m === 'inapp');
  if (b) b.classList.toggle('on', m === 'browser');
}
function openOfficialPage() {
  var url = officialUrl();
  var mode = openMode();
  if (mode === 'browser') {
    try { if (window.Android && Android.openBrowser) { Android.openBrowser(url); return; } } catch (e) {}
    try { window.open(url, '_blank'); } catch (e) {}
    return;
  }
  var logged = !!(typeof S !== 'undefined' && S.loggedIn);
  try { if (!logged) logged = localStorage.getItem('jwxt_login') === '1'; } catch (e) {}
  // 本地记录的登录态可能已经过期，先用真会话探一下目标页
  if (logged) {
    try {
      if (window.Android && Android.httpRequest) {
        var probe = Android.httpRequest('GET', url, '');
        if (typeof probe === 'string' && probe.length > 0 && looksLikeLoginPage(probe)) {
          logged = false;
          S.loggedIn = false;
          try { localStorage.removeItem('jwxt_login'); } catch (e) {}
        }
      }
    } catch (e) {}
  }
  if (!logged) {
    window.__pendingOfficialUrl = url;
    scheduleTip('登录已过期，重新登录后会直接打开官网');
    showLogin();
    return;
  }
  try { if (typeof saveReturnState === 'function') saveReturnState(); } catch (e) {}
  try {
    if (window.Android && Android.openInApp) { Android.openInApp(url); return; }
  } catch (e) {}
  try {
    if (window.Android && Android.openBrowser) { Android.openBrowser(url); return; }
  } catch (e) {}
  try { window.open(url, '_blank'); } catch (e) {}
}

// 用外部浏览器打开教务系统课表官网
// 全局：解析课程节次范围
function courseSpan(c) {
  var p = (c.period || '').toString();
  if (p) {
    var nums = p.match(/\d{2}/g);
    if (nums && nums.length >= 2) {
      var v = nums.map(function(x){return parseInt(x,10);});
      return {s:v[0], e:v[v.length-1]};
    }
    var single = parseInt(p, 10);
    /* 11、12 是单节（不是 0102 那种双节编码） */
    if (single === 11 || single === 12) return {s: single, e: single};
    if (single >= 1 && single <= 6) {
      return {s: (single-1)*2+1, e: single*2};
    }
  }
  if (c.periodLabel) {
    var m = c.periodLabel.match(/[（(]\s*(\d{1,2})\s*[,，]\s*(\d{1,2})\s*小节/);
    if (m) return {s: parseInt(m[1],10), e: parseInt(m[2],10)};
    var m2 = c.periodLabel.match(/第\s*(\d+)\s*[-–]\s*(\d+)\s*节/);
    if (m2) return {s: parseInt(m2[1],10), e: parseInt(m2[2],10)};
  }
  return null;
}

function showCourseByIndex(idx, scope) {
  /* 网格视图的序号来自“按周过滤后”的数组，列表视图来自全量数组；
     共用 lastCourses 会串位（点国外矫正制度弹出习概就是这里）。 */
  var list = (scope === 'grid') ? (S.gridCourses || []) : (S.lastCourses || []);
  var c = list[idx];
  if (!c) return;
  S.detailIdx = idx;
  var h = '<div style="text-align:center; margin-bottom:14px;"><div style="font-size:20px; font-weight:700; color:var(--green); line-height:1.3;">'+esc(c.name||'')+'</div>';
  if (c.periodLabel) h += '<div class="mono" style="color:var(--pink-deep); margin-top:6px; font-size:12px; white-space:pre-line;">'+esc(c.periodLabel)+'</div>';
  h += '</div>';
  h += '<div style="display:flex; gap:8px; margin-bottom:14px;">';
  h += '<button class="small" style="flex:1;" onclick="copyCourseInfo(false)">复制教室</button>';
  h += '<button class="small outline" style="flex:1;" onclick="copyCourseInfo(true)">复制全部</button>';
  h += '</div>';
  h += '<div style="display:grid; grid-template-columns:1fr 1fr; gap:8px;">';
  // 解析节次信息
  var sp = courseSpan(c);
  var fields = [
    ['教师', c.teacherAll || c.teacher],
    ['教室', c.classroom],
    ['班级', c.classes],
    ['周次', c.week],
    ['星期', c.weekdayName || c.weekday_name],
    ['节次', sp ? ('第'+sp.s+'-'+sp.e+'节') : (c.period||'')],
  ];
  fields.forEach(function(f) {
    var v = f[1];
    if (v) {
      h += '<div style="background:var(--cream-2); border-left:3px solid var(--green); padding:8px 10px; border-radius:0 6px 6px 0;">';
      h += '<div style="font-size:10px; color:var(--ink-light); font-family:var(--mono); letter-spacing:0.1em;">'+esc(f[0])+'</div>';
      h += '<div style="font-size:14px; font-weight:500; margin-top:2px;">'+esc(v)+'</div></div>';
    }
  });
  h += '</div>';
  // 分段授课：不同周由不同教师授课时，逐段列出教师与教室
  if (c.teacherPlan && c.teacherPlan.length) {
    c.teacherPlan = c.teacherPlan.slice().sort(function (a, b) {
      var pa = parseInt(String(a.weeks || '').split(/[,\-，]/)[0], 10) || 99;
      var pb = parseInt(String(b.weeks || '').split(/[,\-，]/)[0], 10) || 99;
      return pa - pb;
    });
    h += '<div style="margin-top:14px;">';
    h += '<div style="font-size:10px; color:var(--ink-light); font-family:var(--mono); letter-spacing:0.1em; margin-bottom:6px;">分段授课</div>';
    c.teacherPlan.forEach(function (pl) {
      h += '<div style="background:var(--cream-2); border-left:3px solid var(--pink-deep); padding:8px 10px; border-radius:0 6px 6px 0; margin-bottom:6px;">';
      h += '<div style="font-size:14px; font-weight:500;">' + esc(pl.teacher || '') + '</div>';
      h += '<div style="font-size:11px; color:var(--ink-light); margin-top:2px;">' + esc('第' + (pl.weeks || '') + '周' + (pl.room ? ' · ' + pl.room : '')) + '</div>';
      h += '</div>';
    });
    h += '</div>';
  }
  document.getElementById('detailBody').innerHTML = h;
  document.getElementById('detailOverlay').style.display = 'block';
  document.getElementById('detailSection').classList.remove('hidden');
  document.getElementById('detailSection').style.display = 'flex';
}
