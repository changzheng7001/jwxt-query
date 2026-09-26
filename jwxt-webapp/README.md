# 中警院教务查询面板 · 部署说明

## 这是什么
一个手机浏览器打开就能用的教务系统查询面板：课表、成绩、绩点、考试安排、学籍信息等 13 类查询。
打开网页后自己输入学号密码查询，服务端**不存任何账号密码**。

## 部署到 PythonAnywhere（免费，约 10 分钟）

### 第 1 步：注册账号
打开 https://www.pythonanywhere.com/ 点 "Pricing & signup" → 选 **Beginner (免费)** → 注册。
注册后记住你的用户名（比如 `yourname`），你的网站会是 `yourname.pythonanywhere.com`。

### 第 2 步：上传文件
登录后点顶部 "Files" 标签：
1. 进入 `mysite/` 目录
2. 把这三个文件传上去：
   - `app.py`
   - `jwxt_query.py`
   - `wsgi.py`

### 第 3 步：改 WSGI 配置
点顶部 "Web" 标签 → "Add a new web app" → 选 "Manual configuration" → Python 3.10。
然后点 "WSGI configuration file" 链接（类似 `/var/www/yourname_pythonanywhere_com_wsgi.py`），把内容改成：

```python
import sys
path = '/home/你的用户名/mysite'
if path not in sys.path:
    sys.path.insert(0, path)
from app import application
```
（把"你的用户名"改成你自己的 PythonAnywhere 用户名）

### 第 4 步：安装依赖
点顶部 "Consoles" → "Bash"，执行：
```bash
pip3 install --user requests beautifulsoup4
```

### 第 5 步：重启
回到 "Web" 标签，点绿色的 "Reload" 按钮。

然后手机浏览器打开 `https://你的用户名.pythonanywhere.com` 就能用了。

## 注意事项
- 免费版每天有 CPU 时间限制，查一两次课表/成绩完全够用；
- 免费版第一次访问可能要等 5-10 秒唤醒，正常；
- 你的学号密码只在你查询时通过 HTTPS 发到服务器、用完即弃，不存盘；
- 别把网址随便发给陌生人——虽然每人输自己密码，但滥用会被学校封 IP。
