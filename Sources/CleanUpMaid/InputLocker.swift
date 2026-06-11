import Cocoa

/// Blocks all keyboard and pointer input using a CGEvent tap.
/// Requires Accessibility permission (System Settings > Privacy & Security > Accessibility).
final class InputLocker {
    static let shared = InputLocker()

    /// Called on the main thread with the keycode of every swallowed keyDown,
    /// so the UI can watch for the M-A-I-D unlock sequence.
    var onKeyDown: ((Int64) -> Void)?

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    var isLocked: Bool { eventTap != nil }

    static func hasAccessibilityPermission(promptIfNeeded: Bool) -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: promptIfNeeded] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    @discardableResult
    func lock() -> Bool {
        guard eventTap == nil else { return true }

        let types: [CGEventType] = [
            .keyDown, .keyUp, .flagsChanged,
            .leftMouseDown, .leftMouseUp, .leftMouseDragged,
            .rightMouseDown, .rightMouseUp, .rightMouseDragged,
            .otherMouseDown, .otherMouseUp, .otherMouseDragged,
            .mouseMoved, .scrollWheel,
        ]
        var mask: CGEventMask = types.reduce(0) { $0 | (CGEventMask(1) << $1.rawValue) }
        // Some input arrives as event types CGEventType has no case for:
        // 14 NX_SYSDEFINED (media/function keys), 18 rotate,
        // 19/20 begin/end gesture, 29 gesture, 30 magnify, 31 swipe,
        // 32 smart-magnify, 33 quick look, 34 pressure (force click).
        for raw: UInt64 in [14, 18, 19, 20, 29, 30, 31, 32, 33, 34] {
            mask |= CGEventMask(1) << raw
        }

        let callback: CGEventTapCallBack = { _, type, event, refcon in
            let locker = Unmanaged<InputLocker>.fromOpaque(refcon!).takeUnretainedValue()

            // The system disables a tap that it thinks is unresponsive; re-arm it.
            if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
                locker.reenable()
                return nil
            }

            if type == .keyDown {
                let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
                DispatchQueue.main.async { locker.onKeyDown?(keyCode) }
            }

            return nil // swallow everything
        }

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: callback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            return false
        }

        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        return true
    }

    func unlock() {
        guard let tap = eventTap else { return }
        CGEvent.tapEnable(tap: tap, enable: false)
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        }
        eventTap = nil
        runLoopSource = nil
    }

    private func reenable() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: true)
        }
    }
}
