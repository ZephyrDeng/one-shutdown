// OneShutdown — 菜单栏一键关机:强制退出所有 App,跳过一切「确认退出/是否保存」弹窗
// 构建: ./build.sh

import AppKit

final class Actions: NSObject {
    private var busy = false // 防止关机流程进行中重复点击
    private var killedBundles: [String] = [] // 刚强退的 App 的 bundle 路径,用于追杀其残留子进程

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
        killedBundles = targets().compactMap { $0.bundleURL?.path }
        targets().forEach { $0.forceTerminate() }
        waitUntilAllExit(deadline: Date().addingTimeInterval(30))
    }

    // 每 0.2s 一轮:清掉 bundle 里的残留子进程,再查还有没有活着的 App——有就再强退一次
    // (有 CLI 会自动把浏览器拉活,比如 ego-browser;只要关机开始时还有 App 活着,它就能弹一个框拦下整个关机)。
    // 看到「干净」的空窗才发起关机;deadline 只是防止工具自己永远转下去的最后兜底。
    private func waitUntilAllExit(deadline: Date) {
        killLeftovers(in: killedBundles)
        let live = targets().filter { !$0.isTerminated }
        if live.isEmpty || Date() >= deadline {
            busy = false
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
            task.arguments = ["-e", "tell application \"System Events\" to shut down"]
            try? task.run()
        } else {
            live.forEach { $0.forceTerminate() }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.waitUntilAllExit(deadline: deadline)
            }
        }
    }

    // forceTerminate 只杀 App 主进程;Chromium 系会留下一堆 helper/crashpad 子进程,
    // 可能占着外置盘拖慢卸载。按「可执行文件在 bundle 内」批量补刀。
    private func killLeftovers(in bundles: [String]) {
        guard !bundles.isEmpty else { return }
        let ps = Process()
        ps.executableURL = URL(fileURLWithPath: "/bin/ps")
        ps.arguments = ["-axo", "pid=,comm="]
        let out = Pipe()
        ps.standardOutput = out
        ps.standardError = Pipe()
        do {
            try ps.run()
        } catch { return }
        // 必须先读完管道再 wait:进程表输出可能超过 64KB 管道缓冲区,反过来写会死锁
        let text = String(data: out.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        ps.waitUntilExit()
        for line in text.split(separator: "\n") {
            let parts = line.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
            guard parts.count == 2, let pid = Int32(parts[0]),
                  bundles.contains(where: { parts[1].hasPrefix($0) }) else { continue }
            kill(pid, SIGKILL)
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