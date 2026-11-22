/* Shared appearance, panel docking and offline cache presentation. */
var themePreference = 'system';
var systemAppearance;
var floatingLayoutFrame = 0;

function experienceIcon(name) {
  var paths = {
    book:'<path d="M12 6c-3-2-6-2-9-1v14c3-1 6-1 9 1 3-2 6-2 9-1V5c-3-1-6-1-9 1Z"/><path d="M12 6v14M6 8h3M15 8h3M6 11h3M15 11h3"/>',
    self:'<rect x="3" y="5" width="18" height="16" rx="3"/><path d="M7 3v4M17 3v4M3 10h18"/><circle cx="12" cy="15" r="2"/>',
    teacher:'<path d="M10 4h11v12H10M14 8h4M14 11h3M15 16v5M12 21h6"/><circle cx="5" cy="7" r="2"/><path d="M2 20v-7a3 3 0 0 1 6 0v7M8 13l4-3"/>',
    classroom:'<path d="M4 21h16M6 21V4l12-2v19M14 12h.01M9 6v15"/>',
    class:'<circle cx="9" cy="8" r="3"/><path d="M3 21v-2a6 6 0 0 1 12 0v2M16 5a3 3 0 0 1 0 6M18 15a5 5 0 0 1 3 5"/>',
    course:'<path d="M6 3h13v18H6a3 3 0 0 1 0-6h13M6 3a3 3 0 0 0-3 3v12M8 7h7M8 10h4"/>',
    score:'<path d="m8 3 4 5 4-5M7 3h10M8 16l-2 6 6-3 6 3-2-6"/><circle cx="12" cy="12" r="5"/><path d="m10 12 1.5 1.5L14 11"/>',
    gpa:'<path d="M3 3v18h18M7 16v-4M12 16V8M17 16V5"/>',
    progress:'<path d="M12 3a9 9 0 1 1-6.4 2.6M12 3v9l-6.4-6.4"/><path d="m8 16 2 2 5-5"/>',
    exam:'<rect x="5" y="4" width="14" height="18" rx="2"/><path d="M9 2h6v4H9zM8 11h8M8 15h4M8 18h6"/>',
    electives:'<path d="m3 6 2 2 3-4M11 6h10M3 13h5M11 13h10M3 20h5M11 20h10"/>',
    empty:'<path d="M6 3h12v10H6zM4 13h16v4H4zM6 17v4M18 17v4M3 10v3M21 10v3"/>',
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
  /* 主题切换入口在设置页「外观模式」 */
  ['system','light','dark'].forEach(function(mode){var b=document.getElementById('theme-'+mode);if(b){b.classList.toggle('on',themePreference===mode);b.setAttribute('aria-pressed',String(themePreference===mode));}});
  try {if(window.Android && Android.setStatusTheme)Android.setStatusTheme(dark);}catch(e){}
  if(wasDark!==dark&&typeof S!=='undefined'&&S.view==='result'&&S.lastData&&typeof renderResult==='function')renderResult(S.queryType,S.lastData);
  return dark;
}
window.onSystemThemeChanged=function(){if(themePreference==='system')applyThemePreference();};

function syncFloatingPanels() {
  FLOAT_PANEL_IDS.forEach(function(id){
    var el=document.getElementById(id);if(!el)return;
    /* 面板永远保持磁贴态（panel-floating 是“窄条磁贴”的样式来源，去掉会让卡片铺满屏），
       open 时才展开；磁贴点开即弹出 */
    var floating=true;
    el.classList.toggle('panel-floating',floating);
    if(!floating){el.classList.remove('open');['top','height','maxHeight','transform','transition'].forEach(function(k){el.style[k]='';});}
    var tab=el.querySelector('.fd-tab');if(tab)tab.setAttribute('aria-expanded',String(el.classList.contains('open')));
  });
}
// 触摸双击识别（标题与收起标签都绑），双击时屏蔽单击
function bindPanelDoubleTap(node,id){
  var el=document.getElementById(id);if(!node||!el)return;
  var lastTap=0,sx=0,sy=0;
  node.addEventListener('pointerdown',function(e){sx=e.clientX;sy=e.clientY;});
  node.addEventListener('pointerup',function(e){
    if(e.pointerType!=='touch'||Math.hypot(e.clientX-sx,e.clientY-sy)>8)return;
    if(e.target&&e.target.closest&&e.target.closest('button,input,select,a'))return;
    var now=Date.now();
    if(now-lastTap<330){
      e.preventDefault();
      clearTimeout(el._headerClickTimer);clearTimeout(el._tabClickTimer);
      el._lastTouchDouble=now;window._dblGuard=now;
      el._justDragged=true;setTimeout(function(){el._justDragged=false;},420);
      doubleTapPanel(id);lastTap=0;
    }else lastTap=now;
  });
}
// 双击：展开 ↔ 收起（面板只存在于课表页）
function doubleTapPanel(id) {
  var el=document.getElementById(id);if(!el)return;
  if(!document.body.classList.contains('in-result'))return;
  if(el.classList.contains('open')){
    el.classList.remove('open');
  } else {
    el.classList.add('open');
    el.classList.remove('avoid-left','avoid-right','dock-left');
    el.style.transform='';el.style.top='';el.style.height='';el.style.maxHeight='';el.style.transition='';
  }
  layoutOpenFloats();
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
    /* 按查询类型各自独立分组：我的课表/教师/教室/班级/课程/成绩/绩点/进度/考试/选课/空教室/名录 */
    var category=labels[type]||(type==='browse'?'全校名录':'其他数据');
    if(!groups[category])groups[category]=[];
    var semester=name.match(/\d{4}-\d{4}-[12]/),week=name.match(/_w(\d+)/),weekday=name.match(/_d(\d)/);
    /* 整学期缓存（理论课表一次拉全学期）单独标注，否则会和按周缓存混成一堆“我的课表” */
    var isAll=/_all$/.test(name);
    var tags=[];if(semester&&!isAll)tags.push(semester[0]);
    if(isAll)tags.push('整学期 · 全部周次');else if(week)tags.push('第'+week[1]+'周');
    if(weekday)tags.push('星期'+['','一','二','三','四','五','六','日'][Number(weekday[1])]);
    var publicName=!account&&name.slice(type.length+1).split(/_\d{4}-|_w\d/)[0];
    if(publicName&&publicName!==name&&publicName.indexOf('browse')!==0)tags.unshift(publicName);
    var size=(key.length+raw.length)*2;
    var hasAll=false;
    if(type==='self'&&semester){ for(var ai=0;ai<storage.length;ai++){var ak=storage.key(ai);if(ak&&ak.indexOf('jwxt_cache_self_')===0&&ak.indexOf(semester[0])>0&&/_all$/.test(ak)){var au=storage.getItem(ak)||'';if(au.indexOf('"courses"')>0)hasAll=true;}} }
    var label=(labels[type]||'离线数据')+(isAll?'（整学期）':(type==='self'&&week&&hasAll?'（旧版按周副本）':''));
    if(type==='self'&&week&&hasAll)tags.push('可清空，不影响切周');
    groups[category].push({label:label,detail:tags.join(' · ')||'本地离线副本',bytes:size,time:obj&&Number(obj.t)||0,damaged:damaged,semester:semester?semester[0]:''});
    bytes+=size;total++;
  }
  return {groups:groups,total:total,bytes:bytes,hidden:hidden};
}
function cacheSize(bytes){return bytes<1024?'少于 1 KB':bytes<1048576?(bytes/1024).toFixed(1)+' KB':(bytes/1048576).toFixed(1)+' MB';}
function renderCacheInventory(info,opts) {
  opts=opts||{};
  var html='<div class="cache-stats"><div><strong>'+info.total+'</strong><span>离线副本</span></div><div><strong>'+cacheSize(info.bytes)+'</strong><span>估算占用</span></div></div>';
  if(!info.total)html+='<div class="cache-empty">还没有离线数据<br><small>查询成功后会自动保存，之后可离线查看。</small></div>';
  var CAT_ORDER=['我的课表','教师课表','教室课表','班级课表','课程课表','成绩查询','绩点计算','学习进度','考试安排','选课结果','空教室','教师名录','班级名录','教室名录','全校名录','其他数据'];
  Object.keys(info.groups).sort(function(a,b){var ia=CAT_ORDER.indexOf(a),ib=CAT_ORDER.indexOf(b);return (ia<0?99:ia)-(ib<0?99:ib);}).forEach(function(category,index){
    var items=info.groups[category];html+='<details class="cache-category"'+((!opts.collapsed&&index===0)?' open':'')+'><summary><span>'+esc(category)+'</span><span>'+items.length+' 份</span></summary><div class="cache-entries">';
    /* 类别内再按学期分堆：一个学期一堆，整学期缓存排在该学期第一条 */
    var bySem={};items.forEach(function(item){var k=item.semester||'其他';if(!bySem[k])bySem[k]=[];bySem[k].push(item);});
    Object.keys(bySem).sort().forEach(function(sem){
      var rows=bySem[sem];
      html+='<div class="cache-semester"><div class="cache-semester-head"><span>'+esc(sem==='其他'?'其他数据':sem)+'</span><span>'+rows.length+' 份</span></div>';
      rows.sort(function(a,b){var allSort=(/整学期/.test(a.label)?0:1)-(/整学期/.test(b.label)?0:1);return allSort||b.time-a.time;}).forEach(function(item){var time=item.time?new Date(item.time).toLocaleString('zh-CN',{month:'numeric',day:'numeric',hour:'2-digit',minute:'2-digit'}):'时间未知';html+='<div class="cache-entry"><div><b>'+esc(item.label)+'</b><small>'+esc(item.detail)+'</small></div><div class="cache-entry-meta"><span>'+cacheSize(item.bytes)+'</span><time>'+esc(item.damaged?'数据损坏，可重新查询':time)+'</time></div></div>';});
      html+='</div>';
    });
    html+='</div></details>';
  });
  if(info.total>4)html+='<div class="cache-scroll-hint">↕ 面板内可上下滑动查看全部</div>';
  return html+'<p class="cache-local-note">保存在当前设备 · 个人数据按账户隔离</p>';
}

function initExperience() {
  var grid=document.getElementById('typeGrid'),buttons={};grid.querySelectorAll('.type-btn').forEach(function(b){buttons[b.dataset.v]=b;});grid.replaceChildren();
  [['常用课表',['self','teacher','classroom','class','course']],['学习与教务',['score','gpa','progress','exam','electives','empty']]].forEach(function(group){var title=document.createElement('div');title.className='entry-heading';title.textContent=group[0];grid.appendChild(title);group[1].forEach(function(id){if(buttons[id]){var icon=document.createElement('span');icon.className='entry-icon';icon.setAttribute('aria-hidden','true');icon.innerHTML=experienceIcon(id);buttons[id].prepend(icon);grid.appendChild(buttons[id]);}});});
  FLOAT_PANEL_IDS.forEach(function(id){
    var el=document.getElementById(id),header=el.querySelector('.card-header'),tab=el.querySelector('.fd-tab');
    header.title='双击收起贴边；再次双击展开并还原默认位置';
    bindPanelDoubleTap(header,id);
    if(tab){
      tab.setAttribute('role','button');tab.setAttribute('tabindex','0');
      tab.setAttribute('aria-label','展开'+header.textContent.trim());
      tab.onkeydown=function(e){if(e.key==='Enter'||e.key===' '){e.preventDefault();toggleDockFloat(id);}};
      tab.onclick=function(e){e.stopPropagation();clearTimeout(el._tabClickTimer);el._tabClickTimer=setTimeout(function(){if(Date.now()-(window._dblGuard||0)<800)return;toggleDockFloat(id);},360);};
      bindPanelDoubleTap(tab,id);
    }
  });
  var media=window.matchMedia&&window.matchMedia('(prefers-color-scheme: dark)');if(media){var change=function(){if(themePreference==='system')applyThemePreference();};if(media.addEventListener)media.addEventListener('change',change);else media.addListener(change);}
  window.addEventListener('focus',window.onSystemThemeChanged);document.addEventListener('visibilitychange',function(){document.body.classList.toggle('app-hidden',document.hidden);if(!document.hidden)window.onSystemThemeChanged();});
  document.querySelectorAll('#bottomNav .nav-item').forEach(function(button){button.type='button';button.setAttribute('aria-current',button.classList.contains('active')?'page':'false');});
  applyThemePreference();syncFloatingPanels();layoutOpenFloats();
}
