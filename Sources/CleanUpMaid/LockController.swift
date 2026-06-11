import Cocoa
import SwiftUI

/// Drives a lock session: blocks input, covers every screen with the maid
/// overlay, counts down, and watches for the M-A-I-D unlock sequence.
final class LockController: ObservableObject {
    static let shared = LockController()

    @Published var isLocked = false
    @Published var secondsRemaining = 0
    @Published var unlockProgress = 0 // how many letters of M-A-I-D typed so far

    // macOS virtual keycodes for M, A, I, D
    private let unlockSequence: [Int64] = [46, 0, 34, 2]

    private var overlayWindows: [NSWindow] = []
    private var countdownTimer: Timer?

    func startLock(duration: TimeInterval) {
        guard !isLocked else { return }
        guard InputLocker.hasAccessibilityPermission(promptIfNeeded: true) else {
            showPermissionAlert()
            return
        }
        guard InputLocker.shared.lock() else {
            showPermissionAlert()
            return
        }

        InputLocker.shared.onKeyDown = { [weak self] keyCode in
            self?.handleKey(keyCode)
        }

        isLocked = true
        unlockProgress = 0
        secondsRemaining = Int(duration)
        showOverlays()

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.secondsRemaining -= 1
            if self.secondsRemaining <= 0 {
                self.endLock()
            }
        }
    }

    func endLock() {
        guard isLocked else { return }
        countdownTimer?.invalidate()
        countdownTimer = nil
        InputLocker.shared.onKeyDown = nil
        InputLocker.shared.unlock()
        overlayWindows.forEach { $0.orderOut(nil) }
        overlayWindows = []
        isLocked = false
        NSApp.activate(ignoringOtherApps: true)
    }

    private func handleKey(_ keyCode: Int64) {
        guard isLocked else { return }
        if keyCode == unlockSequence[unlockProgress] {
            unlockProgress += 1
            if unlockProgress == unlockSequence.count {
                endLock()
            }
        } else {
            // Allow restarting with M even after a wrong key.
            unlockProgress = (keyCode == unlockSequence[0]) ? 1 : 0
        }
    }

    private func showOverlays() {
        overlayWindows = NSScreen.screens.map { screen in
            let window = NSWindow(
                contentRect: screen.frame,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            window.level = .screenSaver
            window.isOpaque = true
            window.backgroundColor = .black
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            window.contentView = NSHostingView(rootView: LockScreenView(controller: self))
            window.orderFrontRegardless()
            return window
        }
    }

    private func showPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility permission needed"
        alert.informativeText = """
        CleanUpMaid needs Accessibility access to lock your keyboard and trackpad.

        Open System Settings > Privacy & Security > Accessibility and enable CleanUpMaid, then try again.
        """
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Cancel")
        if alert.runModal() == .alertFirstButtonReturn,
           let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }
}
