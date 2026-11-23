from pathlib import Path
from playwright.sync_api import sync_playwright

CHROME = '/home/user/.cache/ms-playwright/chromium-1234/chrome-linux64/chrome'
APP = Path('/home/user/Doubao/chats/38443085814030338/jwxt-webapp/index.html').as_uri()
PROBE = Path('/tmp/probe2')
PAGES = {k: (PROBE / f).read_text(encoding='utf-8') for k, f in
         {'f': 'theory-2026f.html', 's': 'theory-2026s.html', 'cal': 'jxzl.html'}.items()}

BOOT = """(a)=>{
  window.__P = a.pages;
  window.Android = {
    httpRequest: function(m, url){
      var u = String(url);
      if (u.indexOf('xskb_list') >= 0) return u.indexOf('2025-2026-2') >= 0 ? window.__P.s : window.__P.f;
      if (u.indexOf('jxzl_query') >= 0) return window.__P.cal;
      return '';
    },
    getStatusBarHeight: function(){ return 84; },
    showNativeLogin: function(){ window.__NATIVE__ = 1; },
    showNotification: function(){}, openInApp: function(){}, clearSession: function(){},
    getSystemDarkMode: function(){ return 0; }, setStatusTheme: function(){}, openBrowser: function(){}
  };
  if (a.login) { localStorage.setItem('jwxt_login','1'); S.loggedIn = true; applyLoggedInUI(); }
  else { localStorage.removeItem('jwxt_login'); S.loggedIn = false; }
}"""


def run(shots, week=12, sem='2026-2027-1', outdir='/tmp/shots244', login=True):
    Path(outdir).mkdir(exist_ok=True)
    with sync_playwright() as p:
        b = p.chromium.launch(executable_path=CHROME, args=['--no-sandbox'])
        ctx = b.new_context(viewport={'width': 390, 'height': 844}, device_scale_factor=2)
        pg = ctx.new_page()
        errs = []
        pg.on('pageerror', lambda e: errs.append(str(e)[:160]))
        pg.goto(APP, wait_until='load')
        pg.wait_for_timeout(800)
        pg.evaluate(BOOT, {'pages': PAGES, 'login': login})
        if login:
            pg.evaluate("(a)=>{S.queryType='self';S.semester=a.sem;"
                        "document.getElementById('queryWeek').value=String(a.week);runQuery(true);}",
                        {'sem': sem, 'week': week})
            pg.wait_for_timeout(1500)
        else:
            pg.evaluate("()=>showLoginCard()")
            pg.wait_for_timeout(300)
        for name, action in shots:
            if action:
                pg.evaluate(action)
                pg.wait_for_timeout(500)
            pg.screenshot(path='%s/%s.png' % (outdir, name))
        print('状态:', pg.evaluate("""()=>({
          周: document.getElementById('tbWeekText').textContent,
          学期: document.getElementById('tbSemText').textContent,
          块: document.querySelectorAll('.demo-course').length,
          登录卡: getComputedStyle(document.getElementById('loginSection')).display,
          表单: document.querySelector('#loginSection .login-body') ?
                getComputedStyle(document.querySelector('#loginSection .login-body')).display : 'n/a'
        })"""))
        print('errors', errs)
        b.close()


if __name__ == '__main__':
    run([('01-schedule', None)])
