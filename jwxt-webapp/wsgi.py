"""
PythonAnywhere WSGI 入口
在 PythonAnywhere 的 Web 标签页里，把 WSGI 配置文件指向这个文件。
"""
import sys
import os

# 你的项目目录（在 PythonAnywhere 上通常是 /home/你的用户名/mysite）
path = '/home/你的用户名/mysite'
if path not in sys.path:
    sys.path.insert(0, path)

from app import application
