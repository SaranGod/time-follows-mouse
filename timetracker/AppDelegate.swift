import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var floatingTimeController: FloatingTimeController?
    private var statusBarController: StatusBarController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Ensure app activates so windows can appear
        NSApp.activate(ignoringOtherApps: true)

        // Wire up the floating time UI and start ticking
        let controller = FloatingTimeController()
        controller.start()
        floatingTimeController = controller

        // Create status bar controller (click to open settings window)
        statusBarController = StatusBarController(floatingTimeController: controller)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        floatingTimeController?.stop()
    }
}
