# OneShutdown ⏻

macOS 菜单栏一键关机小工具。点菜单栏 `⏻` 图标 → 立即关机,**无二次确认弹窗**。

## 使用

```bash
./build.sh
open build/OneShutdown.app
```

菜单栏出现 `⏻` 图标:
- **立即关机** — 马上关机
- **退出** — 退出程序

## 分享给别人

把 `build/OneShutdown.app` 压缩发给对方即可(未签名,接收方首次打开如被 Gatekeeper 拦截,右键 → 打开,或执行):

```bash
xattr -cr OneShutdown.app
```

## 已知限制

- 有未保存文档的 App 仍可能被系统拦截(无 sudo 无法强制关机),保存好工作再点。

## 构建

仅依赖系统自带的 `swiftc`,无需 Xcode 工程。