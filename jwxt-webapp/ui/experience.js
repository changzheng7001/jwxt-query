/* Shared appearance, dashboard docking and offline cache presentation. */
var themePreference = 'system';
var systemAppearance;
var homeDockedPanels = new Set();
var floatingLayoutFrame = 0;

function experienceIcon(name) {
  var paths = {
    book:'<path d="M12 6c-3-2-6-2-9-1v14c3-1 6-1 9 1 3-2 6-2 9-1V5c-3-1-6-1-9 1Z"/><path d="M12 6v14M6 8h3M15 8h3M6 11h3M15 11h3"/>',
    light:'<circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M2 12h2M20 12h2M5 5l1.5 1.5M17.5 17.5 19 19M5 19l1.5-1.5M17.5 6.5 19 5"/>',
    dark:'<path d="M20.5 14A8.7 8.7 0 0 1 10 3.5 8.7 8.7 0 1 0 20.5 14Z"/>',
    system:'<rect x="3" y="4" width="18" height="13" rx="3"/><path d="M8 21h8M12 17v4M12 7v7"/><path d="M12 7a3.5 3.5 0 0 1 0 7" fill="currentColor" stroke="none"/>',
    login:'<path d="M14 4h4a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2h-4M3 12h12M10 7l5 5-5 5"/>',
    logout:'<path d="M10 4H6a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h4M9 12h12M16 7l5 5-5 5"/>',
    arrow:'<path d="M5 12h14M13 6l6 6-6 6"/>',
    restore:'<path d="M3 10a9 9 0 1 1 2 8M3 4v6h6"/>',
    close:'<path d="m6 6 12 12M18 6 6 18"/>'
  };
  return '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">'+(paths[name]||paths.book)+'</svg>';
}

function systemIsDark() {
  try { if(window.Android && typeof Android.getSystemDarkMode === 'function') return !!Android.getSystemDarkMode(); } catch(e) {}
  return !!(window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches);
}
function applyThemePreference() {
  var dark = themePreference === 'system' ? systemIsDark() : themePreference === 'dark';
  var wasDark=document.documentElement.getAttribute&&document.documentElement.getAttribute('data-theme')==='dark';
  document.documentElement.setAttribute('data-theme',dark?'dark':'');
  document.documentElement.style.colorScheme=dark?'dark':'light';
  var names={system:'跟随系统',light:'浅色模式',dark:'深色模式'};
  var button=document.getElementById('themeBtn');
  if(button){button.innerHTML=experienceIcon(themePreference);button.title=names[themePreference]+'（点击切换）';button.setAttribute('aria-label',button.title);}
  ['system','light','dark'].forEach(function(mode){var b=document.getElementById('theme-'+mode);if(b){b.classList.toggle('on',themePreference===mode);b.setAttribute('aria-pressed',String(themePreference===mode));}});
  try {if(window.Android && Android.setStatusTheme)Android.setStatusTheme(dark);}catch(e){}
  if(wasDark!==dark&&typeof S!=='undefined'&&S.view==='result'&&S.lastData&&typeof renderResult==='function')renderResult(S.queryType,S.lastData);
  return dark;
}
window.onSystemThemeChanged=function(){if(themePreference==='system')applyThemePreference();};

function saveHomePanels() {
  try{localStorage.setItem('jwxt_home_panels',JSON.stringify(Array.from(homeDockedPanels)));}catch(e){}
}
function syncFloatingPanels() {
  FLOAT_PANEL_IDS.forEach(function(id){
    var el=document.getElementById(id);if(!el)return;
    var floating=document.body.classList.contains('in-result')||homeDockedPanels.has(id);
    el.classList.toggle('panel-floating',floating);
    el.classList.toggle('home-docked',homeDockedPanels.has(id));
    if(!floating){el.classList.remove('open');['top','height','maxHeight','transform','transition'].forEach(function(k){el.style[k]='';});}
    var tab=el.querySelector('.fd-tab');if(tab)tab.setAttribute('aria-expanded',String(el.classList.contains('open')));
  });
  var restore=document.getElementById('restoreHomePanels');if(restore)restore.hidden=!homeDockedPanels.size;
}
function dockHomePanel(id) {
  var el=document.getElementById(id);if(!el||document.body.classList.contains('in-result'))return;
  if(homeDockedPanels.has(id)){homeDockedPanels.delete(id);el.classList.remove('open');}
  else{homeDockedPanels.add(id);el.classList.remove('open');}
  saveHomePanels();syncFloatingPanels();layoutOpenFloats();
}
function restoreHomePanels() {
  homeDockedPanels.clear();saveHomePanels();syncFloatingPanels();layoutOpenFloats();
}
function allocatePanelHeights(desired, available) {
  if(!desired.length)return [];
  var low=0,high=Math.max.apply(Math,desired);
  for(var i=0;i<36;i++){var cap=(low+high)/2;var total=desired.reduce(function(a,h){return a+Math.min(h,cap);},0);if(total>available)high=cap;else low=cap;}
  return desired.map(function(h){return Math.min(h,low);});
}
function queueFloatLayout(){if(floatingLayoutFrame)return;floatingLayoutFrame=requestAnimationFrame(function(){floatingLayoutFrame=0;layoutOpenFloats();});}

function cacheInventory(storage,scope) {
  var labels={self:'我的课表',teacher:'教师课表',classroom:'教室课表',class:'班级课表',course:'课程课表',score:'成绩查询',gpa:'绩点计算',progress:'学习进度',exam:'考试安排',electives:'选课结果',empty:'空教室',teachers:'教师名录',classes:'班级名录',classrooms:'教室名录'};
  var groups={},total=0,bytes=0,hidden=0;
  for(var i=0;i<storage.length;i++){
    var key=storage.key(i);if(!key||key.indexOf('jwxt_cache_')!==0)continue;
    var name=key.slice(11),type=name.split('_')[0],account=name.match(/_u([^_]+)(?:_|$)/);
    if(account&&account[1]!==String(scope||'guest')){hidden++;continue;}
    var raw=storage.getItem(key)||'',obj,damaged=false;try{obj=JSON.parse(raw);}catch(e){damaged=true;}
    var category=account?(type==='self'?'我的课表':'成绩与学业'):/^(teacher|classroom|class|course|empty)$/.test(type)?'公共课表与教室':/^(teachers|classes|classrooms|browse)$/.test(type)?'全校名录':'其他数据';
    if(!groups[category])groups[category]=[];
    var semester=name.match(/\d{4}-\d{4}-[12]/),week=name.match(/_w(\d+)/),weekday=name.match(/_d(\d)/);
    var tags=[];if(semester)tags.push(semester[0]);if(week)tags.push('第'+week[1]+'周');if(weekday)tags.push('星期'+['','一','二','三','四','五','六','日'][Number(weekday[1])]);
    var publicName=!account&&name.slice(type.length+1).split(/_\d{4}-|_w\d/)[0];
    if(publicName&&publicName!==name&&publicName.indexOf('browse')!==0)tags.unshift(publicName);
    var size=(key.length+raw.length)*2;
    groups[category].push({label:labels[type]||'离线数据',detail:tags.join(' · ')||'本地离线副本',bytes:size,time:obj&&Number(obj.t)||0,damaged:damaged});
    bytes+=size;total++;
  }
  return {groups:groups,total:total,bytes:bytes,hidden:hidden};
}
function cacheSize(bytes){return bytes<1024?'少于 1 KB':bytes<1048576?(bytes/1024).toFixed(1)+' KB':(bytes/1048576).toFixed(1)+' MB';}
function renderCacheInventory(info) {
  var html='<div class="cache-stats"><div><strong>'+info.total+'</strong><span>离线副本</span></div><div><strong>'+cacheSize(info.bytes)+'</strong><span>估算占用</span></div></div>';
  if(!info.total)html+='<div class="cache-empty">还没有离线数据<br><small>查询成功后会自动保存，之后可离线查看。</small></div>';
  Object.keys(info.groups).forEach(function(category,index){
    var items=info.groups[category];html+='<details class="cache-category"'+(index===0?' open':'')+'><summary><span>'+esc(category)+'</span><span>'+items.length+' 份</span></summary><div class="cache-entries">';
    items.sort(function(a,b){return b.time-a.time;}).forEach(function(item){var time=item.time?new Date(item.time).toLocaleString('zh-CN',{month:'numeric',day:'numeric',hour:'2-digit',minute:'2-digit'}):'时间未知';html+='<div class="cache-entry"><div><b>'+esc(item.label)+'</b><small>'+esc(item.detail)+'</small></div><div class="cache-entry-meta"><span>'+cacheSize(item.bytes)+'</span><time>'+esc(item.damaged?'数据损坏，可重新查询':time)+'</time></div></div>';});
    html+='</div></details>';
  });
  return html+'<p class="cache-local-note">保存在当前设备 · 个人数据按账户隔离</p>';
}

function initExperience() {
  if(!document.getElementById('bookBackdrop'))document.body.insertAdjacentHTML('afterbegin','<svg id="bookBackdrop" viewBox="0 0 620 430" aria-hidden="true" focusable="false"><ellipse cx="312" cy="354" rx="230" ry="17" fill="currentColor" opacity=".07"/><path class="book-page" d="M77 157Q190 115 310 166Q429 115 543 157L530 326Q415 298 310 347Q205 298 91 326Z"/><path class="book-lines" d="M310 166v181M104 176Q201 149 286 179M102 194Q200 167 286 197M100 212Q199 185 286 215M98 230Q198 203 286 233M96 248Q197 221 286 251M335 180Q425 149 514 176M335 198Q425 167 516 194M335 216Q425 185 518 212M335 234Q425 203 520 230M335 252Q425 221 522 248"/><g transform="translate(310 166)"><g class="book-turn page-one"><path class="book-page" d="M0 0Q115-70 230-35L218 143Q106 112 0 181Z"/><path class="book-lines" d="M23 14Q110-38 203-20M23 35Q110-17 201 1M23 56Q110 4 199 22M23 77Q110 25 197 43"/></g><g class="book-turn page-two"><path class="book-page" d="M0 0Q115-70 230-35L218 143Q106 112 0 181Z"/><path class="book-lines" d="M23 14Q110-38 203-20M23 35Q110-17 201 1M23 56Q110 4 199 22"/></g><g class="book-turn page-three"><path class="book-page" d="M0 0Q115-70 230-35L218 143Q106 112 0 181Z"/><path class="book-lines" d="M23 14Q110-38 203-20M23 35Q110-17 201 1M23 56Q110 4 199 22"/></g></g></svg>');
  var main=document.getElementById('main');
  if(!document.getElementById('appleDashboard')){
    var dashboard=document.createElement('div');dashboard.id='appleDashboard';dashboard.className='apple-dashboard';
    var hero=document.createElement('section');hero.className='apple-welcome';
    hero.innerHTML='<div class="welcome-copy"><div class="eyebrow">JWXT · CAMPUS DESK</div><h2>教务事务，<br>一眼就绪。</h2><p>把今天与本学期的安排，整理得清清楚楚。</p></div><button type="button" class="welcome-action"><span>查看我的课表</span>'+experienceIcon('arrow')+'</button>';
    hero.querySelector('button').onclick=function(){selectType('self');runQuery();};
    var grid=document.createElement('div');grid.className='apple-dashboard-grid';
    var primary=document.createElement('div');primary.className='apple-primary-column';var support=document.createElement('div');support.className='apple-support-column';
    ['todaySection','querySection','browseNav','cacheInfoSection'].forEach(function(id){var el=document.getElementById(id);if(el)(id==='querySection'||id==='browseNav'?primary:support).appendChild(el);});
    grid.append(primary,support);dashboard.append(hero,grid);var login=document.getElementById('loginSection');main.insertBefore(dashboard,login.nextSibling);
    var hint=document.createElement('div');hint.className='panel-hint';hint.innerHTML='<span>双击面板标题可收起贴边，展开后再次双击可还原。</span><button type="button" id="restoreHomePanels" hidden>还原全部面板</button>';hint.querySelector('button').onclick=restoreHomePanels;dashboard.appendChild(hint);
  }
  var grid=document.getElementById('typeGrid'),buttons={};grid.querySelectorAll('.type-btn').forEach(function(b){buttons[b.dataset.v]=b;});grid.replaceChildren();
  [['常用课表',['self','teacher','classroom']],['其他课表',['class','course']],['成绩与教务工具',['score','gpa','progress','exam','electives','empty']]].forEach(function(group){var title=document.createElement('div');title.className='apple-entry-heading';title.textContent=group[0];grid.appendChild(title);group[1].forEach(function(id){if(buttons[id])grid.appendChild(buttons[id]);});});
  try{JSON.parse(localStorage.getItem('jwxt_home_panels')||'[]').forEach(function(id){if(FLOAT_PANEL_IDS.indexOf(id)>=0)homeDockedPanels.add(id);});}catch(e){}
  FLOAT_PANEL_IDS.forEach(function(id){
    var el=document.getElementById(id),header=el.querySelector('.card-header'),tab=el.querySelector('.fd-tab');
    header.title='双击收起贴边；浮窗展开后双击还原';
    // Pointer double-tap is used on touch screens where native dblclick is inconsistent.
    var lastTap=0,sx=0,sy=0;
    header.addEventListener('pointerdown',function(e){sx=e.clientX;sy=e.clientY;});
    header.addEventListener('pointerup',function(e){if(e.pointerType!=='touch'||Math.hypot(e.clientX-sx,e.clientY-sy)>8||e.target.closest('button,input,select,a'))return;var now=Date.now();if(now-lastTap<330){e.preventDefault();clearTimeout(el._headerClickTimer);el._lastTouchDouble=now;if(document.body.classList.contains('in-result')){el.classList.remove('open');layoutOpenFloats();}else dockHomePanel(id);lastTap=0;}else lastTap=now;});
    if(tab){tab.setAttribute('role','button');tab.setAttribute('tabindex','0');tab.setAttribute('aria-label','展开'+header.textContent.trim());tab.onkeydown=function(e){if(e.key==='Enter'||e.key===' '){e.preventDefault();toggleDockFloat(id);}};}
  });
  var media=window.matchMedia&&window.matchMedia('(prefers-color-scheme: dark)');if(media){var change=function(){if(themePreference==='system')applyThemePreference();};if(media.addEventListener)media.addEventListener('change',change);else media.addListener(change);}
  window.addEventListener('focus',window.onSystemThemeChanged);document.addEventListener('visibilitychange',function(){document.body.classList.toggle('app-hidden',document.hidden);if(!document.hidden)window.onSystemThemeChanged();});
  document.querySelectorAll('#bottomNav .nav-item').forEach(function(button){button.type='button';button.setAttribute('aria-current',button.classList.contains('active')?'page':'false');});
  applyThemePreference();syncFloatingPanels();layoutOpenFloats();
}
