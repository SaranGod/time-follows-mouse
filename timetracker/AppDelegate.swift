import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var label: NSTextField!
    var timer: Timer?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create transparent, floating, borderless window
        window = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: 120, height: 20),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .statusBar
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .canJoinAllApplications, .fullScreenAuxiliary, .auxiliary]

        // Add time label
        label = NSTextField(labelWithString: "")
        label.frame = window.contentView!.bounds
        label.alignment = .center
        label.font = NSFont.monospacedDigitSystemFont(ofSize: 16, weight: .regular)
        label.textColor = .white
        label.backgroundColor = NSColor.black.withAlphaComponent(0.7)
        label.isBezeled = false
        label.isBordered = false
        label.drawsBackground = true
        window.contentView?.addSubview(label)

        window.makeKeyAndOrderFront(nil)

        // Start timer to update position and time
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [self] _ in
            let mouseLoc = NSEvent.mouseLocation
            if let _ = NSScreen.screens.first(where: { NSMouseInRect(mouseLoc, $0.frame, false) }) {
                // Place window near the cursor, offset so it doesn't overlap
                let x = mouseLoc.x + 16
                let y = mouseLoc.y - window.frame.height - 16
                window.setFrameOrigin(NSPoint(x: x, y: y))
            }
            let formatter = DateFormatter()
            formatter.timeStyle = .medium
            label.stringValue = formatter.string(from: Date())
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        timer?.invalidate()
    }
}
