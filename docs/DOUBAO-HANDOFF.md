# 给豆包的构建交接

本次只提交源码至 `codex/demo-schedule`，没有构建新 APK、合并或发布新版本。

## 必须复用原签名

已下载并只读验证 GitHub 原版 `v0.9.7/cicp-jwxt-v0.9.7.apk`，签名证书 SHA-256 为：

```
18b6264d0d50c604fe70de23ff4a97e270d442ae6249819f2f092cfaedac69c6
```

完整来源和 APK 文件哈希见 `signing-reference.json`。此前 Codex 测试包使用的 `1e08a903...` 是另一张证书，不能作为本项目后续原版更新签名。证书名称里有 Android Debug 不代表所有 debug.keystore 都是同一密钥。

- 使用豆包之前构建原 GitHub APK 时保存的**原 keystore、原 alias 和密码**。不要生成新密钥，不要使用打包工具内置调试签名兜底。
- APK 只有公钥证书，无法据此恢复原私钥；本仓库没有原 keystore。缺少原密钥时应先找到原构建环境的签名材料，不应声称已经恢复原签名。
- Android Studio/Gradle 工程：复制 `cicp-jwxt-android/signing.properties.example` 为本地 `signing.properties`，填入原材料；也可使用示例对应的 `JWXT_RELEASE_*` 环境变量。发布任务在缺少材料或证书指纹不匹配时会停止。
- apktool 路径：先同步资源，仍然使用原 keystore 签名；签完运行 `scripts/verify-apk-signature.ps1 -Apk <APK路径> -SignerJar <签名工具JAR路径>`。脚本只验证，不签名、不构建。
- 正确的原签名才能覆盖安装原应用并保留其应用数据。此前若因签名不同卸载过应用，卸载删除的 localStorage 无法由此源码恢复。

## 资源与网络

1. 唯一前端源是 `jwxt-webapp/`；运行 `scripts/sync-web-assets.ps1` 同步到两份 Android 工程。必须包含 `ui/` 和 `schedule-assets/`，不能只拷贝 HTML。
2. 两份 Manifest 均引用 `@xml/network_security_config`。XML 只给**精确域名** `jwxt.cicp.edu.cn` 放行 HTTP，不包含子域名、不配置全局 HTTP 放行；其他域名继承 Android 默认规则。参考 [Android 官方配置说明](https://developer.android.com/privacy-and-security/security-config)。
3. 缓存读写通过同一个键规范补齐“我的课表”学期和周次，修复刷新、周切换与重新进入时找不到已存数据；只兼容同一账户且可确认属于当前学期的旧键，不自动认领没有账户标记的个人缓存。
4. 写缓存失败会明确提示；解析失败的响应不会覆盖已有缓存，网络刷新失败会显示原缓存。无需为了读取当前账户缓存重新登录。
5. 查询入口各用不同图标；课表内容层恢复透明，重新透出随包附带的背景和动图。

构建前可运行 `node --test tests/*.test.cjs`。本次不包含真机验证，需在保留原数据的原签名覆盖安装后检查离线重启、相邻周切换和网络重定向。
