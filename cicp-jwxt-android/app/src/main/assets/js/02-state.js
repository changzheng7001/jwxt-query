/* ===== 02-state ===== 原 index.html 内联脚本第 808-1121 行（顺序分片，逻辑未改） */
function setStyleMode() {
  document.documentElement.removeAttribute('data-style');
  try {localStorage.removeItem('jwxt_style');}catch(e){}
}
function restoreTheme() {
  var preference='system';try {preference=localStorage.getItem('jwxt_theme')||'system';}catch(e){}
  setThemeMode(preference);setStyleMode('glass');
}

// ==== 底部导航 & 设置面板 ====
function showTab(which, skipHistory) {
  var settings=which==='settings';
  if (settings && !skipHistory) { try { if (!history.state || !history.state.jwxtSettings) history.pushState({ jwxtSettings: 1 }, '', '#settings'); } catch (e) {} }document.getElementById('settingsSection').classList.toggle('hidden',!settings);
  document.body.classList.toggle('show-settings',settings);
  document.getElementById('main').inert=settings;
  document.getElementById('mainTopbar').inert=settings;
  document.querySelectorAll('#bottomNav .nav-item').forEach(function(n){n.classList.toggle('active',n.dataset.tab===which);n.setAttribute('aria-current',n.dataset.tab===which?'page':'false');});
  if(settings)refreshSettingsCache();else layoutOpenFloats();
}
// 底部导航：手指拖动玻璃层滑动，划过图标时图标折射扭曲，松手落定
(function initNavDrag() {
  var nav = document.getElementById('bottomNav');
  if (!nav) return;
  var slide = nav.querySelector('.glass-slide');
  var items = Array.prototype.slice.call(nav.querySelectorAll('.nav-item'));
  if (!slide || !items.length) return;
  var W = 70;
  function positionSlideTo(el, instant) {
    var b = el.getBoundingClientRect();
    var r = nav.getBoundingClientRect();
    W = b.width;
    if (instant) slide.style.transition = 'none';
    slide.style.left = (b.left - r.left) + 'px';
    slide.style.width = W + 'px';
    if (instant) { void slide.offsetWidth; slide.style.transition = ''; }
  }
  function snapToActive() {
    var a = nav.querySelector('.nav-item.active') || items[0];
    positionSlideTo(a, false);
  }
  snapToActive();
  function hit(x) {
    for (var i = 0; i < items.length; i++) {
      var b = items[i].getBoundingClientRect();
      if (x >= b.left && x <= b.right) return items[i];
    }
    return null;
  }
  function refractAll(x) {
    var cur = hit(x);
    items.forEach(function(n){ n.classList.toggle('refract', n === cur); });
  }
  var dragging = false;
  nav.addEventListener('touchstart', function(){ dragging = true; }, {passive:true});
  nav.addEventListener('touchmove', function(e){
    if (!dragging || !e.touches[0]) return;
    var r = nav.getBoundingClientRect();
    var x = e.touches[0].clientX;
    var half = nav.querySelector('.nav-item').getBoundingClientRect().width / 2;
    slide.style.transition = 'none';
    slide.style.left = (x - r.left - half) + 'px';
    slide.style.width = W + 'px';
    refractAll(x);
  }, {passive:true});
  nav.addEventListener('touchend', function(e){
    if (!dragging) return; dragging = false;
    var x = e.changedTouches[0].clientX;
    var it = hit(x);
    if (!it) {
      // 超出导航栏时弹到最近的图标（而不是弹回原图标）
      var bestD = 1e9;
      for (var i = 0; i < items.length; i++) {
        var b = items[i].getBoundingClientRect();
        var cx = b.left + b.width / 2;
        var d = Math.abs(cx - x);
        if (d < bestD) { bestD = d; it = items[i]; }
      }
    }
    items.forEach(function(n){ n.classList.remove('refract'); });
    slide.style.transition = '';
    if (it) { showTab(it.dataset.tab); snapToActive(); }
    else snapToActive();
  }, {passive:true});
  nav.addEventListener('touchcancel', function(){
    dragging = false; items.forEach(function(n){ n.classList.remove('refract'); });
    slide.style.transition = ''; snapToActive();
  }, {passive:true});
})();
function positionBottomNavGlass(instant) {
  var nav = document.getElementById('bottomNav');
  if (!nav) return;
  var slide = nav.querySelector('.glass-slide'), active = nav.querySelector('.nav-item.active');
  if (!slide || !active) return;
  var button = active.getBoundingClientRect(), dock = nav.getBoundingClientRect();
  if (instant) slide.style.transition = 'none';
  slide.style.left = (button.left - dock.left) + 'px';
  slide.style.width = button.width + 'px';
  if (instant) { void slide.offsetWidth; slide.style.transition = ''; }
}
window.addEventListener('resize', function(){ positionBottomNavGlass(true); });
function toggleNotify() {
  const sw = document.getElementById('notifySwitch');
  if (!sw) return;
  const on = !sw.classList.contains('on');
  sw.classList.toggle('on', on);
  try { localStorage.setItem('jwxt_notify_on', on ? '1' : '0'); } catch(e) {}
}
function testNotify() {
  try {
    if (!(window.Android && Android.showNotification)) { alert('当前环境不支持系统通知（非WebView）'); return; }
    const ok = Android.showNotification('CICP教务提醒', '这是测试常驻通知。若能看到说明通知正常；若看不到，请在系统设置中手动开启通知。', true);
    if (ok) alert('已发送常驻通知，请看通知栏。若仍未显示，请在系统设置→通知→应用通知 手动开启。');
    else alert('通知未发出。请在 系统设置→通知→应用通知 手动开启后重试。');
  } catch(e) { alert('通知异常: ' + e.message); }
}
function openRepo() { try { if (window.Android && Android.openBrowser) Android.openBrowser('https://github.com/changzheng7001/jwxt-query'); } catch(e) {} }
function refreshSettingsCache() {
  const c = document.getElementById('cacheCount2');
  if (!c) return;
  var info=cacheInventory(localStorage,activeAccountScope());
  c.textContent = info.total + ' 份';
  var summary=document.getElementById('settingsCacheSummary');if(summary)summary.innerHTML=renderCacheInventory(info);
}

function checkedHttpRequest(method, p, body) {
  if (!window.Android || !Android.httpRequest) throw new Error('当前环境不支持教务系统网络请求');
  var result = Android.httpRequest(method, BASE + p, body || '');
  if (typeof result !== 'string') throw new Error('教务系统返回了无效响应');
  if (result.indexOf('ERROR:') === 0) throw new Error(result.substring(6) || '网络请求失败');
  return result;
}
function httpGet(p) { return checkedHttpRequest('GET', p, ''); }
function httpPost(p, body) { return checkedHttpRequest('POST', p, body); }

function encodePwd(acc, pwd, scode, sxh) {
  const code = acc + '%%%' + pwd;
  let out = '', rem = scode;
  for (let i = 0; i < code.length; i++) {
    if (i < 20 && i < sxh.length) {
      let n = parseInt(sxh[i]) || 0;
      out += code[i] + rem.substring(0, n);
      rem = rem.substring(n);
    } else { out += code.substring(i); break; }
  }
  return out;
}

async function doLogin() {
  const acc = document.getElementById('account').value.trim();
  const pwd = document.getElementById('password').value;
  if (!acc || !pwd) throw new Error('请输入学号和密码');
  const data = httpGet('/Logon.do?method=logon&flag=sess');
  if (data.indexOf('#') < 0) throw new Error('获取密钥失败');
  const parts = data.trim().split('#');
  const enc = encodePwd(acc, pwd, parts[0], parts[1]);
  const html = httpPost('/Logon.do?method=logon',
    'userAccount=' + encodeURIComponent(acc) + '&userPassword=&encoded=' + encodeURIComponent(enc));
  if (typeof html === 'string' && html.indexOf('ERROR:') !== 0 && html.length > 0 && !looksLikeLoginPage(html)) {
    S.loggedIn = true;
    document.getElementById('loginHint').textContent = '已登录';
    document.getElementById('logoutBtn').style.display = 'flex';
    document.getElementById('logoutBtn').innerHTML = ICO_LOGOUT;
    document.getElementById('loginBtn').style.display = 'none';
    var sdr = document.getElementById('statusDotResult');
    if (sdr) sdr.style.background = 'var(--green)';
    var rlb = document.getElementById('resultLogoutBtn');
    if (rlb) { rlb.innerHTML = ICO_LOGOUT; rlb.onclick = doLogout; rlb.title = '退出'; }
    // 只存账号方便下次回填，绝不保存明文密码；会话由原生 CookieManager 保持
    localStorage.setItem('jwxt_creds', JSON.stringify({account: acc}));
    localStorage.setItem('jwxt_login', '1');
    localStorage.setItem('jwxt_active_account', accountScope(acc));
    /* 查询时因登录失效被弹登录：登录成功后自动重跑那次查询 */
    if (S.retryAfterLogin) {
      var retry = S.retryAfterLogin;
      S.retryAfterLogin = null;
      setTimeout(function () {
        try {
          S.queryType = retry.type;
          if (retry.params && retry.params.week) document.getElementById('queryWeek').value = String(retry.params.week);
          if (retry.params && retry.params.name) document.getElementById('queryName').value = retry.params.name;
          runQuery(true);
        } catch (e) {}
      }, 120);
    }
    // 登录前如果点过官网，登录成功后直接把那个页面打开
    if (window.__pendingOfficialUrl) {
      var pu = window.__pendingOfficialUrl;
      window.__pendingOfficialUrl = '';
      setTimeout(function () {
        try { if (typeof saveReturnState === 'function') saveReturnState(); } catch (e) {}
        try { if (window.Android && Android.openInApp) Android.openInApp(pu); } catch (e) {}
      }, 500);
    }
    return true;
  }
  throw new Error('登录失败');
}

function applyLoggedInUI() {
  try {
    var lo = document.getElementById('logoutBtn'); if (lo) { lo.style.display = 'flex'; lo.innerHTML = ICO_LOGOUT; }
    var lb = document.getElementById('loginBtn'); if (lb) lb.style.display = 'none';
    var hint = document.getElementById('loginHint'); if (hint) hint.textContent = '已登录';
    var sdr = document.getElementById('statusDotResult'); if (sdr) sdr.style.background = 'var(--green)';
    var rlb = document.getElementById('resultLogoutBtn'); if (rlb) { rlb.innerHTML = ICO_LOGOUT; rlb.onclick = doLogout; rlb.title = '退出'; }
    /* 已登录时登录卡必须收起，否则“登录卡 + 课表”会叠在一起 */
    var ls = document.getElementById('loginSection');
    if (ls && ls.style.display !== 'none') hideLogin();
    var lm = document.getElementById('loginMask'); if (lm) lm.style.display = 'none';
  } catch (e) {}
}

// 静默校验会话：Cookie 由原生保存，能直接复用就不用重新登录
function silentSessionCheck() {
  try {
    if (!window.Android || !Android.httpRequest) return false;
    if (localStorage.getItem('jwxt_login') !== '1') return false;
    var h = Android.httpRequest('GET', BASE + '/jsxsd/framework/mainV_index.jsp', '');
    if (typeof h !== 'string' || h.length < 500) return false;
    if (looksLikeLoginPage(h)) return false;
    S.loggedIn = true;
    applyLoggedInUI();
    return true;
  } catch (e) { return false; }
}

function looksLikeLoginPage(html) {
  var doc = parseHTML(html);
  var text = (doc.body && doc.body.textContent || '').replace(/\s+/g, '');
  var hasLoginFields = !!(doc.querySelector('input[name="userAccount"],input[name="userPassword"],input[type="password"]'));
  return hasLoginFields || /用户名或密码错误|密码错误|请登录|登录超时|重新登录/.test(text);
}

/* 未登录态的页面本身：登录卡常驻显示，避免出现“空白纸 + 磁贴”的首屏 */
/* 有没有原生登录框：有的话页面上就不该再出现账号/密码输入框 */
function hasNativeLogin() {
  return !!(window.Android && Android.showNativeLogin);
}
function showLoginCard() {
  var sec = document.getElementById('loginSection');
  if (!sec) return;
  sec.classList.remove('popup-login');
  sec.style.display = '';
  var mask = document.getElementById('loginMask');
  if (mask) mask.style.display = 'none';
  var lb = document.getElementById('loginBtn');
  if (lb) lb.style.display = 'none';
  /* 原生登录可用时，卡片只当“未登录提示”，网页表单整块收起来 */
  var body = sec.querySelector('.login-body');
  var nativeBtn = document.getElementById('nativeLoginBtn');
  var nativeMode = hasNativeLogin();
  if (body) body.classList.toggle('hidden', nativeMode);
  if (nativeBtn) nativeBtn.style.display = nativeMode ? '' : 'none';
  /* 有原生弹窗时不再叫“登录面板”，改成一张状态卡：只有一句话 + 一个按钮 */
  var head = sec.querySelector('.card-header .mono');
  if (head) head.textContent = nativeMode ? '尚未登录' : '登录 · 获取最新数据';
  var hint = document.getElementById('loginHint');
  if (hint) hint.textContent = nativeMode ? '点按钮由系统弹窗登录' : '离线缓存中';
}
function showLogin() {
  if (hasNativeLogin()) {
    try { Android.showNativeLogin(); return; } catch (e) {}
  }
  /* 没有原生登录（浏览器预览）才用网页表单 */
  showLoginCard();
  var sec = document.getElementById('loginSection');
  var mask = document.getElementById('loginMask');
  var inResult = document.body.classList.contains('in-result');
  sec.classList.toggle('popup-login', inResult);
  sec.style.display = '';
  if (mask) mask.style.display = inResult ? 'block' : 'none';
  document.getElementById('loginBtn').style.display = 'none';
  setTimeout(function(){ try{ document.getElementById('account').focus(); }catch(e){} }, 60);
}
function hideLogin() {
  var sec = document.getElementById('loginSection');
  var mask = document.getElementById('loginMask');
  /* 仍未登录：不把页面藏空，回落到常驻登录卡 */
  if (!S.loggedIn) { showLoginCard(); return; }
  sec.style.display = 'none'; sec.classList.remove('popup-login');
  if (mask) mask.style.display = 'none';
  if (!S.loggedIn) document.getElementById('loginBtn').style.display = '';
}

async function doLoginNow() {
  try {
    document.getElementById('loginHint').textContent = '登录中...';
    await doLogin();
    // 登录成功，隐藏登录面板
    hideLogin();
    document.getElementById('loginBtn').style.display = 'none';
    alert('登录成功，现在可以查询最新数据了');
  } catch(e) {
    document.getElementById('loginHint').textContent = '登录失败';
    alert(e.message);
  }
}


window.__nativeLogin = function(u, p) {
  try {
    document.getElementById('account').value = u || '';
    document.getElementById('password').value = p || '';
  } catch(e) {}
  doLoginNow();
};

var ICO_LOGIN = experienceIcon('login');
var ICO_LOGOUT = experienceIcon('logout');

function doLogout() {
  S.loggedIn = false;
  document.getElementById('logoutBtn').style.display = 'none';
  document.getElementById('loginBtn').style.display = 'flex';
  document.getElementById('loginBtn').innerHTML = ICO_LOGIN;
  document.getElementById('loginHint').textContent = '已退出登录';
  var sdr = document.getElementById('statusDotResult');
  if (sdr) sdr.style.background = '#b5544f';
  var rb = document.getElementById('resultLogoutBtn');
  if (rb) { rb.innerHTML = ICO_LOGIN; rb.onclick = showLogin; rb.title = '登录'; }
  document.getElementById('loginSection').style.display = 'none';
  // 退出登录：清除本地凭证（无明文密码）并通知原生清除会话 cookie
  try { localStorage.removeItem('jwxt_creds'); } catch(e) {}
  try { localStorage.removeItem('jwxt_login'); } catch(e) {}
  if (window.Android && Android.clearSession) { try { Android.clearSession(); } catch(e){} }
  /* 退出后回到首页登录态，不要停在结果页的旧错误卡上 */
  try { if (typeof showView === 'function') showView('main'); if (typeof showLoginCard === 'function') showLoginCard(); } catch (e) {}
}

function accountScope(account) {
  var h = 2166136261, s = String(account || '');
  for (var i = 0; i < s.length; i++) { h ^= s.charCodeAt(i); h = Math.imul(h, 16777619); }
  return (h >>> 0).toString(36);
}
function activeAccountScope() {
  try {
    var scope=localStorage.getItem('jwxt_active_account');if(scope)return scope;
    var saved=JSON.parse(localStorage.getItem('jwxt_creds')||'{}');
    if(saved.account){scope=accountScope(saved.account);localStorage.setItem('jwxt_active_account',scope);return scope;}
  }catch(e){}return '';
}
/* 当前选中的学期（可切换）。S.semester 才是查询真正使用的学期；
   currentSemester() 永远返回“真实当前学期”，用于判断今天/本周和缓存新鲜度。 */
function selectedSemester() {
  try {
    var s = (typeof S !== 'undefined' && S.semester) || localStorage.getItem('jwxt_sem_sel') || '';
    if (/^\d{4}-\d{4}-\d{1,2}$/.test(s)) return s;
  } catch (e) {}
  return currentSemester();
}
/* 没有抓过校历时的兜底：秋季取 9 月 1 日所在那一周的周一，春季取 3 月 1 日所在那一周的周一。
   比一个固定的 SEM_START 可靠：切到春季不会再显示秋季的日期行。 */
function defaultSemesterStart(sem) {
  var m = String(sem || '').match(/^(\d{4})-(\d{4})-(\d)/);
  if (!m) return SEM_START;
  var year = m[3] === '1' ? parseInt(m[1], 10) : parseInt(m[2], 10);
  var month = m[3] === '1' ? 9 : 3;
  var d = new Date(year, month - 1, 1);
  var wd = d.getDay();                       /* 0=周日 */
  d.setDate(d.getDate() - (wd === 0 ? 6 : wd - 1));  /* 回退到本周周一 */
  return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0');
}
function savedSemesterStart(sem) {
  var saved = '';
  try { saved = localStorage.getItem('jwxt_sem_start_' + sem) || ''; } catch (e) {}
  if (!saved) return '';
  if (!/^\d{4}-\d{2}-\d{2}$/.test(saved)) return '';
  /* 校验：学期码前半/后半决定开学年份；秋季不可能在 1-7 月开学，春季不可能在 8-12 月开学。
     以前把“默认秋季校历”写进春季 key 的脏数据会在这里被丢弃。 */
  var m = String(sem || '').match(/^(\d{4})-(\d{4})-(\d)/);
  var wantYear = m ? parseInt(m[3] === '1' ? m[1] : m[2], 10) : 0;
  var gotYear = parseInt(saved.slice(0, 4), 10), gotMonth = parseInt(saved.slice(5, 7), 10);
  if (wantYear && gotYear !== wantYear) return '';
  if (m && m[3] === '1' && gotMonth < 7) return '';
  if (m && m[3] === '2' && gotMonth > 7) return '';
  return saved;
}
function semesterStartDate() {
  var sem = selectedSemester(), saved = savedSemesterStart(sem);
  try {
    /* 兼容旧键名：只有当前学期才认这份手工配置 */
    if (!saved && sem === currentSemester()) {
      var legacy = localStorage.getItem('jwxt_semester_start') || '';
      if (/^\d{4}-\d{2}-\d{2}$/.test(legacy)) saved = legacy;
    }
  } catch (e) {}
  return saved || defaultSemesterStart(sem);
}
function semesterWeekCount() {
  var sem = selectedSemester(), n = NaN;
  try {
    n = parseInt(localStorage.getItem('jwxt_sem_weeks_' + sem) || '', 10);
    if (!isFinite(n) && sem === currentSemester()) n = parseInt(localStorage.getItem('jwxt_semester_weeks') || '', 10);
  } catch (e) {}
  return Math.max(1, Math.min(30, isFinite(n) && n ? n : 20));
}

/* ============ 学期列表与校历 ============ */
/* 学期列表来自教务系统「教学周历」页的下拉（xnxq01id），带“2026-秋季”这种友好标签 */
function semesterLabel(sem) {
  var t = String(sem || ''), m = t.match(/^(\d{4})-(\d{4})-(\d)/);
  if (!m) return t;
  /* 教务系统的叫法：秋季算学年开头那年，春季算后一年。2025-2026-2 就是“2026-春季” */
  return (m[3] === '1' ? m[1] : m[2]) + (m[3] === '1' ? '-秋季' : '-春季');
}
function fetchSemesterList(cb) {
  var cached = null;
  try { cached = JSON.parse(localStorage.getItem('jwxt_semesters_v2') || 'null'); } catch (e) {}
  var fresh = cached && Array.isArray(cached.list) && cached.list.length && (Date.now() - (cached.t || 0) < 30 * 86400000);
  if (fresh) { cb(cached.list); return; }
  var fallback = function () {
    var out = [], y0 = parseInt(currentSemester().slice(0, 4), 10);
    /* 纯离线兜底也不能造出官网没有的“未来学期”：从当前学年往回推 3 年 */
    for (var y = y0; y >= y0 - 3; y--) {
      out.push({ v: y + '-' + (y + 1) + '-1', label: semesterLabel(y + '-' + (y + 1) + '-1') });
      out.push({ v: y + '-' + (y + 1) + '-2', label: semesterLabel(y + '-' + (y + 1) + '-2') });
    }
    cb(out);
  };
  if (!window.Android || !Android.httpRequest) { fallback(); return; }
  try {
    var html = Android.httpRequest('GET', BASE + '/jsxsd/jxzl/jxzl_query', '');
    var list = parseSemesterOptions(html);
    /* 只保留真实存在的学期：去掉比当前学年还晚的“未来学期” */
    var curYear = parseInt(currentSemester().slice(0, 4), 10);
    list = list.filter(function (x) { return parseInt(x.v.slice(0, 4), 10) <= curYear; });
    if (!list.length) { fallback(); return; }
    try { localStorage.setItem('jwxt_semesters_v2', JSON.stringify({ t: Date.now(), list: list })); } catch (e) {}
    cb(list);
  } catch (e) { fallback(); }
}
function parseSemesterOptions(html) {
  var out = [];
  try {
    var doc = new DOMParser().parseFromString(html, 'text/html');
    var sel = doc.querySelector('select[name="xnxq01id"]') || doc.querySelector('select[name="xnxq02id"]');
    if (!sel) return out;
    sel.querySelectorAll('option').forEach(function (o) {
      var v = (o.getAttribute('value') || '').trim();
      if (/^\d{4}-\d{4}-\d{1,2}$/.test(v) && !out.some(function (x) { return x.v === v; })) {
        out.push({ v: v, label: (o.textContent || '').trim() || semesterLabel(v) });
      }
    });
  } catch (e) {}
  return out;
}
/* 某个学期的校历（第 1 周周一是哪天、共几周）：周历页每行第一格就是周次，后面跟 7 个日期 */
function ensureSemesterCal(sem, cb) {
  var done = function () { cb && cb(); };
  try {
    if (savedSemesterStart(sem)) { done(); return; }
  } catch (e) {}
  if (!window.Android || !Android.httpRequest) { done(); return; }
  var html;
  try { html = Android.httpRequest('GET', BASE + '/jsxsd/jxzl/jxzl_query?xnxq01id=' + encodeURIComponent(sem), ''); }
  catch (e) { done(); return; }
  try {
    var doc = new DOMParser().parseFromString(html, 'text/html');
    /* 服务端可能无视 xnxq01id 直接回当前学期的周历：先核对页面上的“已选学期”，
       不匹配就当没抓到，免得把秋季日期写进春季的 key 里长期生效。 */
    var sel = doc.querySelector('select[name="xnxq01id"] option[selected]');
    var pageSem = sel ? (sel.getAttribute('value') || '') : '';
    if (pageSem && pageSem !== sem) { done(); return; }
    var table = doc.querySelector('#kbtable') || doc.querySelector('table');
    if (table) {
      var rows = table.querySelectorAll('tr'), first = '', count = 0;
      for (var i = 0; i < rows.length; i++) {
        var td = rows[i].querySelector('td');
        if (!td || !/^\d{1,2}$/.test(td.textContent.trim())) continue;
        var cells = rows[i].querySelectorAll('td');
        if (!first && cells.length >= 2) {
          var t = cells[1].getAttribute('title') || '';
          var m = t.match(/(\d{4})年(\d{2})月(\d{2})/);
          if (m) first = m[1] + '-' + m[2] + '-' + m[3];
        }
        count++;
      }
      if (first) {
        /* 第 1 周第一天必须是周一，否则说明不是周历首页/解析错位 */
        var d = new Date(first + 'T00:00:00');
        if (d.getDay() === 1) {
          var m2 = String(sem || '').match(/^(\d{4})-(\d{4})-(\d)/);
          var wantYear = m2 ? parseInt(m2[3] === '1' ? m2[1] : m2[2], 10) : 0;
          var okYear = !wantYear || parseInt(first.slice(0, 4), 10) === wantYear;
          var okMonth = !m2 || (m2[3] === '1' ? parseInt(first.slice(5, 7), 10) >= 7
                                                  : parseInt(first.slice(5, 7), 10) <= 7);
          if (okYear && okMonth) { try { localStorage.setItem('jwxt_sem_start_' + sem, first); } catch (e) {} }
        }
      }
      if (count) { try { localStorage.setItem('jwxt_sem_weeks_' + sem, String(count)); } catch (e) {} }
    }
  } catch (e) {}
  done();
}
function currentSemester() {
  var now = new Date(), y = now.getMonth() >= 7 ? now.getFullYear() : now.getFullYear() - 1;
  return y + '-' + (y + 1) + '-' + (now.getMonth() >= 7 && now.getMonth() <= 11 ? '1' : '2');
}