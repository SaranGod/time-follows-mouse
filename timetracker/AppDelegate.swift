import Cocoa
import CoreVideo

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var label: NSTextField!
    var displayLink: CVDisplayLink?
    
    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .medium
        return f
    }()
    
    private var lastTimeUpdate = Date()
    private var lastMouseLoc = NSPoint.zero
    private var lastWindowOrigin = NSPoint.zero

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Transparent floating window
        window = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: 120, height: 24),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .statusBar
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.hasShadow = false

        // Time label
        label = NSTextField(labelWithString: formatter.string(from: Date()))
        label.frame = window.contentView!.bounds
        label.alignment = .center
        label.font = NSFont.monospacedDigitSystemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.backgroundColor = NSColor.black.withAlphaComponent(0.6)
        label.drawsBackground = true
        label.isBezeled = false
        label.isBordered = false
        window.contentView?.addSubview(label)
        window.makeKeyAndOrderFront(nil)

        // Create display link synced to screen refresh
        CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)
        guard let displayLink = displayLink else { return }
        
        CVDisplayLinkSetOutputHandler(displayLink) { [weak self] _, _, _, _, _ in
            DispatchQueue.main.async {
                self?.updateFrame()
            }
            return kCVReturnSuccess
        }
        
        CVDisplayLinkStart(displayLink)
    }
    
    private func updateFrame() {
        let mouseLoc = NSEvent.mouseLocation
        guard let _ = NSScreen.screens.first(where: { NSMouseInRect(mouseLoc, $0.frame, false) }) else { return }
        
        // Target position (offset near cursor)
        let targetX = mouseLoc.x + 16
        let targetY = mouseLoc.y - window.frame.height - 16
        
        // Smooth easing (lerp)
        let lerpFactor: CGFloat = 0.25
        let newX = lastWindowOrigin.x + (targetX - lastWindowOrigin.x) * lerpFactor
        let newY = lastWindowOrigin.y + (targetY - lastWindowOrigin.y) * lerpFactor
        let newPoint = NSPoint(x: newX, y: newY)
        
        window.setFrameOrigin(newPoint)
        lastWindowOrigin = newPoint
        lastMouseLoc = mouseLoc
        
        // Update time once per second
        if abs(lastTimeUpdate.timeIntervalSinceNow) > 1 {
            label.stringValue = formatter.string(from: Date())
            lastTimeUpdate = Date()
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        if let displayLink = displayLink {
            CVDisplayLinkStop(displayLink)
        }
    }
}
