import Cocoa

class ViewController: NSViewController {
    private let offsetXSlider = NSSlider(value: 16, minValue: 0, maxValue: 300, target: nil, action: nil)
    private let offsetYSlider = NSSlider(value: 16, minValue: 0, maxValue: 300, target: nil, action: nil)
    private let lerpSlider   = NSSlider(value: 0.25, minValue: 0.05, maxValue: 0.9, target: nil, action: nil)

    private let offXValueLabel = NSTextField(labelWithString: "16.0")
    private let offYValueLabel = NSTextField(labelWithString: "16.0")
    private let lerpValueLabel = NSTextField(labelWithString: "0.250")

    private lazy var resetButton: NSButton = {
        let b = NSButton(title: "Reset to Defaults", target: self, action: #selector(resetTapped))
        b.bezelStyle = .rounded
        return b
    }()

    private lazy var toggleButton: NSButton = {
        let b = NSButton(title: "Toggle Clock", target: self, action: #selector(toggleClockTapped))
        b.bezelStyle = .rounded
        return b
    }()

    private lazy var quitButton: NSButton = {
        let b = NSButton(title: "Quit", target: self, action: #selector(quitTapped))
        b.bezelStyle = .rounded
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor

        preferredContentSize = NSSize(width: 380, height: 220)

        // Load initial values from UserDefaults
        let d = UserDefaults.standard
        let offX = d.object(forKey: PrefKeys.offsetX) as? Double ?? DefaultValues.offsetX
        let offY = d.object(forKey: PrefKeys.offsetY) as? Double ?? DefaultValues.offsetY
        let lerp = d.object(forKey: PrefKeys.lerpFactor) as? Double ?? DefaultValues.lerpFactor

        offsetXSlider.doubleValue = offX
        offsetYSlider.doubleValue = offY
        lerpSlider.doubleValue = lerp

        offXValueLabel.stringValue = String(format: "%.1f", offX)
        offYValueLabel.stringValue = String(format: "%.1f", offY)
        lerpValueLabel.stringValue = String(format: "%.3f", lerp)

        configure(slider: offsetXSlider)
        configure(slider: offsetYSlider)
        configure(slider: lerpSlider)

        // Build UI
        let title = NSTextField(labelWithString: "Settings")
        title.font = NSFont.systemFont(ofSize: 16, weight: .semibold)

        let offXLabel = NSTextField(labelWithString: "Offset X")
        let offYLabel = NSTextField(labelWithString: "Offset Y")
        let lerpLabel = NSTextField(labelWithString: "Lerp Factor")

        let grid = NSGridView(views: [
            [offXLabel, offsetXSlider, offXValueLabel],
            [offYLabel, offsetYSlider, offYValueLabel],
            [lerpLabel, lerpSlider, lerpValueLabel]
        ])
        grid.column(at: 0).xPlacement = .trailing
        grid.column(at: 2).xPlacement = .leading
        grid.rowSpacing = 12
        grid.columnSpacing = 12

        let buttonRow = NSStackView(views: [resetButton, toggleButton, quitButton])
        buttonRow.orientation = .horizontal
        buttonRow.alignment = .centerY
        buttonRow.spacing = 12

        let stack = NSStackView(views: [title, grid, buttonRow])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),
        ])

        // Hook actions
        offsetXSlider.target = self
        offsetXSlider.action = #selector(sliderChanged(_:))
        offsetYSlider.target = self
        offsetYSlider.action = #selector(sliderChanged(_:))
        lerpSlider.target = self
        lerpSlider.action = #selector(sliderChanged(_:))
    }

    private func configure(slider: NSSlider) {
        slider.isContinuous = true
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.widthAnchor.constraint(equalToConstant: 220).isActive = true
    }

    @objc private func sliderChanged(_ sender: NSSlider) {
        let offX = offsetXSlider.doubleValue
        let offY = offsetYSlider.doubleValue
        let lerp = lerpSlider.doubleValue

        offXValueLabel.stringValue = String(format: "%.1f", offX)
        offYValueLabel.stringValue = String(format: "%.1f", offY)
        lerpValueLabel.stringValue = String(format: "%.3f", lerp)

        if let appDelegate = NSApp.delegate as? AppDelegate,
           let controller = appDelegate.floatingTimeController {
            controller.apply(offsetX: offX, offsetY: offY, lerp: lerp)
        } else {
            // Persist even if controller not found yet
            let d = UserDefaults.standard
            d.set(offX, forKey: PrefKeys.offsetX)
            d.set(offY, forKey: PrefKeys.offsetY)
            d.set(lerp, forKey: PrefKeys.lerpFactor)
        }
    }

    @objc private func resetTapped() {
        let d = UserDefaults.standard
        d.removeObject(forKey: PrefKeys.offsetX)
        d.removeObject(forKey: PrefKeys.offsetY)
        d.removeObject(forKey: PrefKeys.lerpFactor)

        offsetXSlider.doubleValue = DefaultValues.offsetX
        offsetYSlider.doubleValue = DefaultValues.offsetY
        lerpSlider.doubleValue    = DefaultValues.lerpFactor

        offXValueLabel.stringValue = String(format: "%.1f", DefaultValues.offsetX)
        offYValueLabel.stringValue = String(format: "%.1f", DefaultValues.offsetY)
        lerpValueLabel.stringValue = String(format: "%.3f", DefaultValues.lerpFactor)

        if let appDelegate = NSApp.delegate as? AppDelegate,
           let controller = appDelegate.floatingTimeController {
            controller.apply(offsetX: DefaultValues.offsetX, offsetY: DefaultValues.offsetY, lerp: DefaultValues.lerpFactor)
        }
    }

    @objc private func toggleClockTapped() {
        if let appDelegate = NSApp.delegate as? AppDelegate,
           let controller = appDelegate.floatingTimeController {
            controller.toggleVisibility()
        }
    }

    @objc private func quitTapped() {
        NSApp.terminate(nil)
    }
}

