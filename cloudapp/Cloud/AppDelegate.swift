import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    let panelManager = PanelManager()
    private var statusItem: NSStatusItem?
    private var hotKeyMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        // Menu bar icon — single click toggles the panel
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "cloud.fill", accessibilityDescription: "Cloud")
            button.action = #selector(togglePanel)
            button.target = self
        }

        panelManager.setup()

        // Global hotkey: Cmd+Shift+C
        hotKeyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.modifierFlags.contains([.command, .shift]) && event.keyCode == 8 {
                DispatchQueue.main.async {
                    self?.panelManager.togglePanel()
                }
            }
        }
    }

    @objc private func togglePanel() {
        panelManager.togglePanel()
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let monitor = hotKeyMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
