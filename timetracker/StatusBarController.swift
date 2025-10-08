import Cocoa

final class StatusBarController: NSObject {
    private let statusItem: NSStatusItem
    private weak var floatingController: FloatingTimeController?
    private var windowController: NSWindowController?

    init(floatingTimeController: FloatingTimeController) {
        self.floatingController = floatingTimeController
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()

        if let button = statusItem.button {
            button.image = NSImage(named: "statusBarIcon")
            button.toolTip = "Open Settings"
            button.target = self
            button.action = #selector(toggleSettingsWindow)
        }
    }

    @objc func openSettingsWindow() {
        if let wc = windowController, let window = wc.window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        // Create settings window programmatically
        let vc = ViewController()
        let size = vc.preferredContentSize == .zero ? NSSize(width: 380, height: 220) : vc.preferredContentSize
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: size.width, height: size.height),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "Time Follows Mouse"
        window.isReleasedWhenClosed = false
        window.contentViewController = vc

        let wc = NSWindowController(window: window)
        windowController = wc
        wc.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    // Public entry to show settings on launch
    func showSettingsWindow() {
        openSettingsWindow()
    }

    @objc func toggleSettingsWindow() {
        // Prefer our managed window if available
        if let wc = windowController, let window = wc.window {
            if window.isVisible {
                window.orderOut(nil)
            } else {
                window.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
            }
            return
        }

        // Fallback: if a storyboard-created window exists, toggle it
        if let win = NSApp.windows.first(where: { $0.contentViewController is ViewController }) {
            if win.isVisible {
                win.orderOut(nil)
            } else {
                win.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
            }
            return
        }

        // If none exists, create and show one
        openSettingsWindow()
    }
}
