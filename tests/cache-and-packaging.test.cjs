const {test}=require('node:test'),assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path'),vm=require('node:vm');
const root=path.join(__dirname,'..'),html=fs.readFileSync(path.join(root,'jwxt-webapp/index.html'),'utf8');
function storage(){const m=new Map();return {get length(){return m.size},key:i=>[...m.keys()][i],getItem:k=>m.get(k)||null,setItem:(k,v)=>m.set(k,v),removeItem:k=>m.delete(k)}}
function context(store=storage(),account='alice'){
 const ctx={localStorage:store,Date,JSON,Object,Array,Number,String,parseInt,currentSemester:()=>'2026-2027-1',activeAccountScope:()=>account,scheduleTip:m=>ctx.messages.push(m),messages:[]};vm.createContext(ctx);
 vm.runInContext(html.slice(html.indexOf("const CK = 'jwxt_cache_';"),html.indexOf('// ============ 页面切换')),ctx);return ctx;
}
test('my schedule is readable after restart regardless of caller supplying semester and padded week',()=>{
 const a=context(),data={courses:[{name:'cached course',weekday:1}]};const key=a.cacheKey('self',{week:'08',semester:'2026-2027-1'});assert.equal(a.setCache(key,data),true);
 const restarted=context(a.localStorage);assert.equal(restarted.cacheKey('self',{week:'8'}),key);assert.equal(restarted.getCache(key).data.courses[0].name,'cached course');assert.equal(context(a.localStorage,'bob').getCache(context(a.localStorage,'bob').cacheKey('self',{week:'8'})),null);
});
test('same-account whole-week cache satisfies a day query without including other days',()=>{
 const c=context();c.setCache(c.cacheKey('self',{week:'8'}),{courses:[{name:'Monday',weekday:1},{name:'Tuesday',weekday:2}]});const day=c.getCache(c.cacheKey('self',{week:'8',weekday:'1'}));assert.deepEqual(Array.from(day.data.courses,x=>x.name),['Monday']);
});
test('old account-scoped cache is accepted only for the matching semester and owner',()=>{
 const c=context();c.localStorage.setItem('jwxt_cache_self_ualice_w8',JSON.stringify({data:{courses:[]},t:new Date('2026-10-19T12:00:00').getTime()}));assert.ok(c.getCache(c.cacheKey('self',{week:'8'})));assert.equal(context(c.localStorage,'bob').getCache('self_ubob_2026-2027-1_w8'),null);assert.equal(c.getCache('self_ualice_2025-2026-1_w8'),null);
 c.localStorage.setItem('jwxt_cache_self_w9',JSON.stringify({data:{courses:[{name:'unowned'}]},t:Date.now()}));assert.equal(c.getCache(c.cacheKey('self',{week:'9'})),null);
 assert.equal(c.isActivePersonalCacheKey('jwxt_cache_self_ualice_w8'),true);assert.equal(c.isActivePersonalCacheKey('jwxt_cache_self_ubob_w8'),false);assert.equal(c.isActivePersonalCacheKey('jwxt_cache_self_w9'),false);
});
test('failed writes and parser errors preserve existing cached data and report storage failure',()=>{
 const c=context();const key=c.cacheKey('self',{week:'8'});c.setCache(key,{courses:[{name:'keep'}]});c.localStorage.setItem=()=>{throw Error('QuotaExceededError')};assert.equal(c.setCache(key,{courses:[]}),false);assert.equal(c.getCache(key).data.courses[0].name,'keep');assert.equal(c.messages.length,1);assert.equal(c.setCache(key,{error:'invalid response'}),false);
});
test('offline query uses persisted cache without authentication or a network request',async()=>{
 const c=context();c.setCache(c.cacheKey('self',{week:'8'}),{courses:[{name:'offline'}]});let calls=0;
 const els={queryWeek:{value:'8'},queryWeekday:{value:''},cacheNotice:{classList:{remove(){}}},resultLabel:{},resultContent:{}};
 Object.assign(c,{S:{queryType:'self',loggedIn:false},NEEDS_NAME:[],NEEDS_WEEK:['self'],NEEDS_SEM:[],TYPES:[{v:'self',l:'我的课表'}],document:{getElementById:id=>els[id]},showView(){},renderResult:(t,d)=>c.rendered=d,doQuery:()=>{calls++;throw Error('network should not be called')},currentWeek:()=>8});
 const source=html.match(/async function runQuery\([^]*?^}/m)[0];vm.runInContext(source,c);await c.runQuery(false);assert.equal(calls,0);assert.equal(c.rendered.courses[0].name,'offline');
});
test('both packaging paths have only the exact teaching-system HTTP exception',()=>{
 const files=['apk-source/res/xml/network_security_config.xml','cicp-jwxt-android/app/src/main/res/xml/network_security_config.xml'];const xml=fs.readFileSync(path.join(root,files[0]),'utf8');assert.equal(xml,fs.readFileSync(path.join(root,files[1]),'utf8'));assert.equal((xml.match(/<domain /g)||[]).length,1);assert.ok(xml.includes('<domain includeSubdomains="false">jwxt.cicp.edu.cn</domain>'));assert.ok(!xml.includes('<base-config'));
 for(const manifest of ['apk-source/AndroidManifest.xml','cicp-jwxt-android/app/src/main/AndroidManifest.xml'])assert.ok(fs.readFileSync(path.join(root,manifest),'utf8').includes('android:networkSecurityConfig="@xml/network_security_config"'));
});
test('query entry icons are all distinct and the result artwork has transparent content layers',()=>{
 const js=fs.readFileSync(path.join(root,'jwxt-webapp/ui/experience.js'),'utf8'),c={window:{}};vm.createContext(c);vm.runInContext(js,c);const icons=['self','teacher','classroom','class','course','score','gpa','progress','exam','electives','empty'].map(id=>c.experienceIcon(id));assert.equal(new Set(icons).size,11);assert.ok(js.includes('icon.innerHTML=experienceIcon(id)'));
 const css=fs.readFileSync(path.join(root,'jwxt-webapp/ui/app.css'),'utf8');assert.ok(css.includes('body.schedule-result #resultSection>.card{background:transparent!important}'));assert.ok(css.includes("url('../schedule-assets/tangyun-head.png')"));
});
test('release signing is pinned to the verified previous GitHub certificate',()=>{
 const reference=JSON.parse(fs.readFileSync(path.join(root,'docs/signing-reference.json'),'utf8'));assert.equal(reference.certificate_sha256,'18b6264d0d50c604fe70de23ff4a97e270d442ae6249819f2f092cfaedac69c6');for(const file of ['scripts/verify-apk-signature.ps1','cicp-jwxt-android/app/build.gradle'])assert.ok(fs.readFileSync(path.join(root,file),'utf8').includes(reference.certificate_sha256));
});
