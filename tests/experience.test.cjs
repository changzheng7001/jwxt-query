const {test}=require('node:test');
const assert=require('node:assert/strict');
const fs=require('node:fs'),vm=require('node:vm'),path=require('node:path');
const root=path.join(__dirname,'..');
const html=fs.readFileSync(path.join(root,'jwxt-webapp/index.html'),'utf8');
const experience=fs.readFileSync(path.join(root,'jwxt-webapp/ui/experience.js'),'utf8');
function fn(name){const m=html.match(new RegExp('function '+name+'\\([^]*?^}', 'm'));assert.ok(m,name);return m[0];}
function classes(initial=[]){const set=new Set(initial);return {contains:k=>set.has(k),add:(...v)=>v.forEach(x=>set.add(x)),remove:(...v)=>v.forEach(x=>set.delete(x)),toggle(k,force){const next=force===undefined?!set.has(k):force;next?set.add(k):set.delete(k);return next;}};}
function storage(entries={}){const map=new Map(Object.entries(entries));return {get length(){return map.size},key:i=>[...map.keys()][i],getItem:k=>map.get(k)||null,setItem:(k,v)=>map.set(k,v),removeItem:k=>map.delete(k)};}
function context(){
 const elements={},attrs={},body={classList:classes()},bridge={dark:false};
 const ctx={console,Set,Array,Math,Date,Number,String,JSON,parseInt,setTimeout,clearTimeout,requestAnimationFrame:()=>1,localStorage:storage(),getComputedStyle:e=>({display:e.display||'block'}),FLOAT_PANEL_IDS:['todaySection','browseNav','querySection','cacheInfoSection'],window:{innerHeight:640,Android:{getSystemDarkMode:()=>bridge.dark,setStatusTheme:d=>bridge.applied=d},matchMedia:()=>({matches:false})},document:{body,documentElement:{style:{},setAttribute:(k,v)=>attrs[k]=v},getElementById:id=>elements[id]}};
 ctx.Android=ctx.window.Android;vm.createContext(ctx);vm.runInContext(experience,ctx);vm.runInContext(fn('setThemeMode')+'\n'+fn('toggleTheme')+'\n'+fn('esc'),ctx);return {ctx,elements,attrs,body,bridge};
}
test('system appearance follows Android and manual selection survives system changes',()=>{
 const {ctx,attrs,bridge}=context();ctx.setThemeMode('system');assert.equal(attrs['data-theme'],'');bridge.dark=true;ctx.window.onSystemThemeChanged();assert.equal(attrs['data-theme'],'dark');assert.equal(bridge.applied,true);
 ctx.setThemeMode('light');ctx.window.onSystemThemeChanged();assert.equal(attrs['data-theme'],'');assert.equal(ctx.localStorage.getItem('jwxt_theme'),'light');ctx.setThemeMode('system');assert.equal(attrs['data-theme'],'dark');
});
test('web preview can follow media query without a native Android bridge',()=>{
 const {ctx,attrs}=context();delete ctx.window.Android;ctx.window.matchMedia=()=>({matches:true});ctx.setThemeMode('system');assert.equal(attrs['data-theme'],'dark');
});
test('all four panels stay on screen and nonoverlapping through expand/collapse cycles',()=>{
 const {ctx,elements,body}=context();body.classList.add('in-result');
 ctx.FLOAT_PANEL_IDS.forEach((id,i)=>{elements[id]={classList:classes(['open']),style:{},querySelector:s=>s==='.card'?{scrollHeight:[120,200,600,450][i]}:{setAttribute(){}}};});
 elements.mainTopbar={getBoundingClientRect:()=>({bottom:80})};elements.bottomNav={getBoundingClientRect:()=>({top:570,height:70})};
 vm.runInContext(fn('layoutOpenFloats')+'\n'+fn('resetFloatLayout'),ctx);
 for(let cycle=0;cycle<4;cycle++){
  if(cycle)elements[ctx.FLOAT_PANEL_IDS[cycle-1]].classList.remove('open');ctx.layoutOpenFloats();let edge=88;
  ctx.FLOAT_PANEL_IDS.forEach(id=>{const p=elements[id],top=parseFloat(p.style.top),height=parseFloat(p.style.height);assert.ok(top>=edge-.01);assert.ok(height>0);assert.ok(top+height<=562.01);edge=top+height+7;});
 }
 body.classList.remove('in-result');ctx.resetFloatLayout();ctx.FLOAT_PANEL_IDS.forEach(id=>{assert.equal(elements[id].style.top,'');assert.equal(elements[id].style.height,'');assert.equal(elements[id].classList.contains('panel-floating'),false);});
});
test('home docked state is restored to regular layout without stale height',()=>{
 const {ctx,elements}=context();ctx.FLOAT_PANEL_IDS.forEach(id=>elements[id]={classList:classes(),style:{top:'100px',height:'80px'},querySelector:()=>({setAttribute(){}})});ctx.homeDockedPanels.add('querySection');ctx.syncFloatingPanels();assert.equal(elements.querySection.classList.contains('panel-floating'),true);ctx.homeDockedPanels.clear();ctx.syncFloatingPanels();assert.equal(elements.querySection.style.top,'');assert.equal(elements.querySection.style.height,'');
});
test('cache grouping isolates accounts, survives damaged data and escapes cache labels',()=>{
 const {ctx}=context();const data=storage({'jwxt_cache_self_u123_2026-2027-1_w8':JSON.stringify({t:100,data:{courses:[]}}),'jwxt_cache_score_u456_2026-2027-1':'{}','jwxt_cache_teacher_<img src=x>_2026-2027-1_w8':'invalid','jwxt_cache_teachers':'{}'});
 const info=ctx.cacheInventory(data,'123');assert.equal(info.total,3);assert.equal(info.hidden,1);assert.equal(info.groups['我的课表'].length,1);assert.equal(info.groups['公共课表与教室'][0].damaged,true);const rendered=ctx.renderCacheInventory(info);assert.ok(!rendered.includes('<img'));assert.ok(!rendered.includes('456'));assert.ok(rendered.includes('&lt;img'));
});
test('today list excludes other weekdays, other weeks and week-range mismatches',()=>{
 const {ctx}=context();ctx.currentWeek=()=>8;ctx.weekInRange=(range,w)=>range==='1-20周';vm.runInContext(fn('courseSpan')+'\n'+fn('todayScheduleEntries')+'\n'+fn('formatGridCourseName'),ctx);
 const data={courses:[{name:'late',weekday:1,period:'0304',week:'1-20周'},{name:'Tuesday',weekday:2,period:'0102'},{name:'wrong week',weekday:1,period:'0102',week:'9-10周'},{name:'early',weekday:1,period:'0102'}]};
 const list=ctx.todayScheduleEntries(data,8,new Date('2026-10-19T12:00:00'));assert.deepEqual(Array.from(list,x=>x.c.name),['early','late']);assert.equal(ctx.todayScheduleEntries(data,9,new Date('2026-10-19T12:00:00')).length,0);
 assert.equal(ctx.formatGridCourseName('刑事诉讼法学'),'<span>刑事诉</span><span>讼法学</span>');assert.ok(!ctx.formatGridCourseName('<img>').includes('<img>'));
});
test('today cards show time, room, teacher and class without exposing another day',()=>{
 const {ctx}=context();ctx.currentWeek=()=>8;ctx.weekInRange=()=>true;ctx.scheduleColor=()=>'#336644';ctx.SCHEDULE_TIMES=[['08:00','08:45'],['08:55','09:40']];ctx.Date=class extends Date{constructor(...args){super(...(args.length?args:['2026-10-19T12:00:00']));}};
 vm.runInContext(fn('courseSpan')+'\n'+fn('todayScheduleEntries')+'\n'+fn('renderTodayScheduleList'),ctx);
 const view=ctx.renderTodayScheduleList({courses:[{name:'刑事诉讼法',weekday:1,period:'0102',classroom:'一教101',teacher:'测试教师',classes:'测试班级',week:'1-20周'},{name:'不应显示的周二课程',weekday:2,period:'0102'}]},8);
 for(const value of ['08:00','09:40','一教101','测试教师','测试班级','第1–2节'])assert.ok(view.includes(value));assert.ok(!view.includes('不应显示的周二课程'));
});
test('every bundled UI resource matches the source in both Android targets',()=>{
 for(const target of ['apk-source/assets','cicp-jwxt-android/app/src/main/assets']){assert.equal(html,fs.readFileSync(path.join(root,target,'index.html'),'utf8'));for(const file of fs.readdirSync(path.join(root,'jwxt-webapp/ui')))assert.deepEqual(fs.readFileSync(path.join(root,'jwxt-webapp/ui',file)),fs.readFileSync(path.join(root,target,'ui',file)));}
});
test('inline and external scripts parse before release',()=>{
 for(const script of html.matchAll(/<script\b[^>]*>([\s\S]*?)<\/script>/g))new vm.Script(script[1]);new vm.Script(experience);
});
