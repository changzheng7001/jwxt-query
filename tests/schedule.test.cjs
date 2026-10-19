// Run with: node --test tests/schedule.test.cjs
const {test} = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const path = require('node:path');
const html = fs.readFileSync(path.join(__dirname,'../jwxt-webapp/index.html'),'utf8');
function fn(name) {
  const start = html.indexOf('function '+name+'(');
  assert.ok(start >= 0, name+' exists');
  let i=html.indexOf('{',start)+1,depth=1;
  for (;depth;i++) { if(html[i]==='{')depth++;if(html[i]==='}')depth--; }
  return html.slice(start,i);
}
function context() {
  const elements={queryWeek:{value:''},queryWeekday:{value:''},querySemester:{value:'2026-2027-1'},queryName:{value:''},weekPicker:{style:{}},weekPickerMask:{style:{}}};
  const handlers={}, windowHandlers={}, cache=new Map();
  const el={style:{},clientWidth:390,parentElement:{style:{},appendChild(){}},addEventListener:(name,handler)=>handlers[name]=handler};
  elements.resultContent=el;
  const ctx={console,Date,Number,Map,Array,String,parseInt,clearTimeout,setTimeout,S:{queryType:'self',scheduleForm:'grid'},NEEDS_NAME:[],NEEDS_SEM:[],currentWeek:()=>8,SEMESTER_START:new Date('2026-08-31T00:00:00'),getCache:k=>cache.get(k),document:{body:{classList:{contains:()=>true}},getElementById:id=>elements[id],createElement:()=>({style:{}})},window:{innerWidth:390,addEventListener:(name,handler)=>windowHandlers[name]=handler}};
  vm.createContext(ctx);
  const helpers=html.slice(html.indexOf('const SCHEDULE_COLORS'),html.lastIndexOf('\ninit();'));
  vm.runInContext(fn('cacheKey')+'\n'+fn('courseSpan')+'\n'+fn('esc')+'\n'+helpers+'\n'+fn('initWeekSwipe'),ctx);
  ctx.messages=[];ctx.scheduleTip=m=>ctx.messages.push(m);ctx.renderResult=(type,data)=>{ctx.rendered={type,data}};
  return {ctx,elements,handlers,cache};
}
test('uncached week leaves the displayed week and data unchanged',()=>{
  const {ctx,elements}=context();elements.queryWeek.value='8';
  assert.equal(ctx.switchScheduleWeek(9),false);
  assert.equal(elements.queryWeek.value,'8');assert.equal(ctx.rendered,undefined);assert.equal(ctx.messages.length,1);
});
test('a cached empty week is a valid destination; blank selection defaults to current week',()=>{
  const {ctx,elements,cache}=context();assert.equal(ctx.scheduleWeek(),8);
  cache.set('self_w9',{data:{courses:[]}});
  assert.equal(ctx.switchScheduleWeek(9),true);assert.equal(elements.queryWeek.value,'9');assert.equal(ctx.rendered.data.courses.length,0);
});
test('first week swipe and cancelled swipe reset safely',()=>{
  const {ctx,elements,handlers}=context();elements.queryWeek.value='1';ctx.initWeekSwipe();
  handlers.touchstart({touches:[{clientX:100,clientY:100}]});
  assert.doesNotThrow(()=>handlers.touchmove({touches:[{clientX:200,clientY:100}],cancelable:true,preventDefault(){}}));
  handlers.touchcancel();assert.equal(elements.resultContent.style.transform,'');assert.equal(elements.queryWeek.value,'1');
});
test('swipe preview resolves a blank week against current week and commits cached destination',()=>{
  const {ctx,elements,handlers,cache}=context();cache.set('self_w9',{data:{courses:[]}});ctx.initWeekSwipe();
  handlers.touchstart({touches:[{clientX:300,clientY:100}]});handlers.touchmove({touches:[{clientX:100,clientY:100}],cancelable:true,preventDefault(){}});handlers.touchend();
  assert.equal(elements.queryWeek.value,'9');assert.equal(ctx.rendered.type,'self');
});
test('other week has no today marker; unsafe course names are escaped',()=>{
  const {ctx}=context();
  const pane=ctx.buildSchedulePane({courses:[{name:'<img src=x onerror=alert(1)>',weekday:1,period:'0102',classroom:'A"B'}]},1,false,false);
  assert.ok(!pane.includes('demo-day today'));assert.ok(!pane.includes('<img src=x'));assert.ok(pane.includes('&lt;img'));
});
test('front-end, packaged HTML and all bundled assets stay identical',()=>{
  const root=path.join(__dirname,'..');assert.equal(html,fs.readFileSync(path.join(root,'apk-source/assets/index.html'),'utf8'));
  for(const name of fs.readdirSync(path.join(root,'jwxt-webapp/schedule-assets')))assert.deepEqual(fs.readFileSync(path.join(root,'jwxt-webapp/schedule-assets',name)),fs.readFileSync(path.join(root,'apk-source/assets/schedule-assets',name)));
});
