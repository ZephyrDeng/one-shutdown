// OneShutdown — 菜单栏一键关机:强制退出所有 App,跳过一切「确认退出/是否保存」弹窗
// 构建: ./build.sh

import AppKit

final class Actions: NSObject {
    private var busy = false // 防止关机流程进行中重复点击

    private func targets() -> [NSRunningApplication] {
        NSWorkspace.shared.runningApplications.filter {
            $0.activationPolicy == .regular && $0.bundleIdentifier != "com.apple.finder"
        }
    }

    @objc func shutdownNow() {
        guard !busy else { return }

        // 二次确认:误点菜单时不该直接丢未保存数据
        let alert = NSAlert()
        alert.alertStyle = .critical
        alert.messageText = zh ? "确定要关机吗?" : "Shut Down Now?"
        alert.informativeText = zh
            ? "将强制退出所有 App,未保存的内容会丢失。"
            : "All apps will be force-quit. Unsaved changes will be lost."
        alert.addButton(withTitle: zh ? "关机" : "Shut Down")
        alert.addButton(withTitle: zh ? "取消" : "Cancel")
        NSApp.activate(ignoringOtherApps: true) // accessory 应用需主动抢焦点,否则弹窗可能藏在后面
        guard alert.runModal() == .alertFirstButtonReturn else { return }

        busy = true
        // 普通关机会被 App 的确认弹窗拦住,所以先强退所有前台 App(Finder 强退会自动重启,跳过)
        targets().forEach { $0.forceTerminate() }
        waitUntilAllExit(deadline: Date().addingTimeInterval(15))
    }

    // 轮询等所有 App 真正退出再关机;forceTerminate 是异步的,固定等 1 秒不够,残留进程会把关机拦下来(就是要点第二次的原因)
    private func waitUntilAllExit(deadline: Date) {
        if targets().allSatisfy({ $0.isTerminated }) || Date() >= deadline {
            busy = false
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
            task.arguments = ["-e", "tell application \"System Events\" to shut down"]
            try? task.run()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.waitUntilAllExit(deadline: deadline)
            }
        }
    }
}

let actions = Actions()
let zh = Locale.preferredLanguages.first?.hasPrefix("zh") ?? false

let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
item.button?.image = NSImage(systemSymbolName: "power", accessibilityDescription: "OneShutdown") // 模板图,自动适配深浅色

let menu = NSMenu()
let shutdownItem = NSMenuItem(title: zh ? "立即关机" : "Shut Down Now", action: #selector(Actions.shutdownNow), keyEquivalent: "")
shutdownItem.target = actions
menu.addItem(shutdownItem)
menu.addItem(.separator())
menu.addItem(NSMenuItem(title: zh ? "退出" : "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
item.menu = menu

let app = NSApplication.shared
app.setActivationPolicy(.accessory) // 不占 Dock
app.run()