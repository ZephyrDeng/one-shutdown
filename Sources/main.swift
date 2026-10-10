// OneShutdown — 菜单栏一键关机,无二次确认
// 构建: ./build.sh

import AppKit

final class Actions: NSObject {
    @objc func shutdownNow() {
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["-e", "tell application \"System Events\" to shut down"]
        try? task.run()
    }
}

let actions = Actions()

let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
item.button?.title = "⏻"

let menu = NSMenu()
let shutdownItem = NSMenuItem(title: "立即关机", action: #selector(Actions.shutdownNow), keyEquivalent: "")
shutdownItem.target = actions
menu.addItem(shutdownItem)
menu.addItem(.separator())
menu.addItem(NSMenuItem(title: "退出", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
item.menu = menu

let app = NSApplication.shared
app.setActivationPolicy(.accessory) // 不占 Dock
app.run()