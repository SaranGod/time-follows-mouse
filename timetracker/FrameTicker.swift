import Cocoa
import CoreVideo

final class FrameTicker {
    private var displayLink: CVDisplayLink?
    private let callback: () -> Void

    init?(callback: @escaping () -> Void) {
        self.callback = callback

        var link: CVDisplayLink?
        let result = CVDisplayLinkCreateWithActiveCGDisplays(&link)
        guard result == kCVReturnSuccess, let link else { return nil }
        displayLink = link

        CVDisplayLinkSetOutputHandler(link) { [weak self] _, _, _, _, _ in
            guard let self = self else { return kCVReturnSuccess }
            DispatchQueue.main.async {
                self.callback()
            }
            return kCVReturnSuccess
        }
    }

    func start() {
        if let link = displayLink { CVDisplayLinkStart(link) }
    }

    func stop() {
        if let link = displayLink { CVDisplayLinkStop(link) }
    }

    deinit {
        stop()
    }
}

