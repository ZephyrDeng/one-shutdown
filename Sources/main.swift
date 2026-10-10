// OneShutdown — 菜单栏一键关机:强制退出所有 App,跳过一切「确认退出/是否保存」弹窗
// 构建: ./build.sh

import AppKit

final class Actions: NSObject {
    @objc func shutdownNow() {
        // 普通关机会被 App 的确认弹窗拦住,所以先强退所有前台 App(Finder 强退会自动重启,跳过)
        for app in NSWorkspace.shared.runningApplications
        where app.activationPolicy == .regular && app.bundleIdentifier != "com.apple.finder" {
            app.forceTerminate()
        }
        // 给进程 1 秒退出,再走系统关机
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
            task.arguments = ["-e", "tell application \"System Events\" to shut down"]
            try? task.run()
        }
    }
}

let actions = Actions()

let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
item.button?.image = NSImage(systemSymbolName: "power", accessibilityDescription: "OneShutdown") // 模板图,自动适配深浅色

let zh = Locale.preferredLanguages.first?.hasPrefix("zh") ?? false
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