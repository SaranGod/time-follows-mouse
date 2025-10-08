import Cocoa

final class FloatingTimeController {
    private let window: NSWindow
    private let label: NSTextField
    private var ticker: FrameTicker?

    // Appearance & behavior
    var offset: CGPoint
    var lerpFactor: CGFloat

    // Time formatting
    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .medium
        return f
    }()

    // State
    private var lastTimeUpdate = Date()
    private var lastWindowOrigin: NSPoint

    init() {
        // Load saved preferences or defaults
        let defaults = UserDefaults.standard
        let offX = defaults.object(forKey: PrefKeys.offsetX) as? Double ?? DefaultValues.offsetX
        let offY = defaults.object(forKey: PrefKeys.offsetY) as? Double ?? DefaultValues.offsetY
        let lerp = defaults.object(forKey: PrefKeys.lerpFactor) as? Double ?? DefaultValues.lerpFactor
        offset = CGPoint(x: offX, y: offY)
        lerpFactor = CGFloat(lerp)

        // Configure window
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

        // Configure label
        label = NSTextField(labelWithString: formatter.string(from: Date()))
        label.frame = window.contentView!.bounds
        label.autoresizingMask = [.width, .height]
        label.alignment = .center
        label.font = NSFont.monospacedDigitSystemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.backgroundColor = NSColor.black.withAlphaComponent(0.6)
        label.drawsBackground = true
        label.isBezeled = false
        label.isBordered = false
        window.contentView?.addSubview(label)
        window.orderFrontRegardless()

        lastWindowOrigin = window.frame.origin
    }

    func start() {
        ticker = FrameTicker { [weak self] in
            self?.tick()
        }
        ticker?.start()
    }

    func stop() {
        ticker?.stop()
    }

    func show() {
        window.orderFrontRegardless()
    }

    func hide() {
        window.orderOut(nil)
    }

    func toggleVisibility() {
        if window.isVisible {
            hide()
        } else {
            show()
        }
    }

    func apply(offsetX: Double, offsetY: Double, lerp: Double) {
        offset = CGPoint(x: offsetX, y: offsetY)
        lerpFactor = CGFloat(lerp)
        // Persist
        let d = UserDefaults.standard
        d.set(offsetX, forKey: PrefKeys.offsetX)
        d.set(offsetY, forKey: PrefKeys.offsetY)
        d.set(lerp, forKey: PrefKeys.lerpFactor)
    }

    private func tick() {
        let mouseLoc = NSEvent.mouseLocation
        guard let _ = NSScreen.screens.first(where: { NSMouseInRect(mouseLoc, $0.frame, false) }) else { return }

        // Target position (offset near cursor)
        let targetX = mouseLoc.x + offset.x
        let targetY = mouseLoc.y - window.frame.height - offset.y

        // Smooth easing (lerp)
        let newX = lastWindowOrigin.x + (targetX - lastWindowOrigin.x) * lerpFactor
        let newY = lastWindowOrigin.y + (targetY - lastWindowOrigin.y) * lerpFactor
        let newPoint = NSPoint(x: newX, y: newY)

        window.setFrameOrigin(newPoint)
        lastWindowOrigin = newPoint

        // Update time once per second
        if abs(lastTimeUpdate.timeIntervalSinceNow) > 1 {
            label.stringValue = formatter.string(from: Date())
            lastTimeUpdate = Date()
        }
    }
}
