#if APP_STORE
import AppKit
import CoreGraphics

// The Mac App Store version runs in the App Sandbox, where macOS doesn't let an app use the
// Accessibility API on other apps. This version reads where windows are from the system's window
// list, and moves them through the "Quadra" shortcut in the Shortcuts app, which Quadra runs in the
// background through Shortcuts Events. The GitHub version uses WindowMover.swift instead.

/// The window that had focus when Quadra was called: the front window of an app.
struct TargetWindow {
    let app: NSRunningApplication
    let windowID: CGWindowID

    /// Current position and size (AppKit coordinates).
    var frame: CGRect? { StoreWindowList.bounds(of: windowID).map { Geometry.flip($0) } }

    /// Window titles need the Screen Recording permission, which Quadra doesn't ask for.
    var title: String? { nil }

    var isFullScreen: Bool { false }
}

/// Front-to-back windows from the system's window list (no permission needed for their frames).
enum StoreWindowList {
    struct Entry {
        let windowID: CGWindowID
        let pid: pid_t
        /// Origin at the top left of the primary display, like the Accessibility API.
        let bounds: CGRect
    }

    /// Ordinary on-screen windows, front to back.
    static func windows() -> [Entry] {
        let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
        let list = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] ?? []
        return list.compactMap { info in
            guard (info[kCGWindowLayer as String] as? Int) == 0,
                  let id = info[kCGWindowNumber as String] as? CGWindowID,
                  let pid = info[kCGWindowOwnerPID as String] as? pid_t,
                  let dict = info[kCGWindowBounds as String] as? NSDictionary,
                  let bounds = CGRect(dictionaryRepresentation: dict),
                  bounds.width > 40, bounds.height > 40,
                  (info[kCGWindowAlpha as String] as? Double ?? 1) > 0 else { return nil }
            return Entry(windowID: id, pid: pid, bounds: bounds)
        }
    }

    static func bounds(of windowID: CGWindowID) -> CGRect? {
        let list = CGWindowListCopyWindowInfo([.optionIncludingWindow], windowID) as? [[String: Any]] ?? []
        guard let dict = list.first?[kCGWindowBounds as String] as? NSDictionary else { return nil }
        return CGRect(dictionaryRepresentation: dict)
    }
}

/// Runs the "Quadra" shortcut through Shortcuts Events, which works in the background.
enum ShortcutsBridge {
    static let shortcutName = "Quadra"
    private static let eventsID = "com.apple.shortcuts.events"
    /// Set once the shortcut has run, so the check isn't repeated before every move.
    private static var confirmedReady = false

    /// Whether Quadra may send Apple events to Shortcuts Events. With `ask`, macOS shows its
    /// consent alert if the user hasn't answered yet (and waits for the answer).
    static func automationStatus(ask: Bool) -> OSStatus {
        if NSRunningApplication.runningApplications(withBundleIdentifier: eventsID).isEmpty {
            // It starts on demand; give it up to 2 seconds.
            launchShortcutsEvents()
            for _ in 0..<20 where NSRunningApplication.runningApplications(withBundleIdentifier: eventsID).isEmpty {
                Thread.sleep(forTimeInterval: 0.1)
            }
        }
        let target = NSAppleEventDescriptor(bundleIdentifier: eventsID)
        guard let desc = target.aeDesc else { return OSStatus(procNotFound) }
        return AEDeterminePermissionToAutomateTarget(desc, AEEventClass(typeWildCard), AEEventID(typeWildCard), ask)
    }

    private static func launchShortcutsEvents() {
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: eventsID) else { return }
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = false
        configuration.addsToRecentItems = false
        NSWorkspace.shared.openApplication(at: url, configuration: configuration)
    }

    /// Ready means: allowed to use Shortcuts Events, and the Quadra shortcut is installed.
    static func isReady(ask: Bool = false) -> Bool {
        if confirmedReady { return true }
        guard automationStatus(ask: ask) == noErr else { return false }
        let ready = run("exists shortcut \"\(shortcutName)\"")?.booleanValue == true
        confirmedReady = ready
        return ready
    }

    /// Moves and resizes the front window of `app` to `frame` (origin at the top left).
    @discardableResult
    static func moveFrontWindow(of app: NSRunningApplication, to frame: CGRect) -> Bool {
        guard let name = app.localizedName else { return false }
        let input: [String: Any] = [
            "app": name,
            "x": Int(frame.minX.rounded()), "y": Int(frame.minY.rounded()),
            "w": Int(frame.width.rounded()), "h": Int(frame.height.rounded()),
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: input),
              let json = String(data: data, encoding: .utf8) else { return false }
        let escaped = json.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"")
        let ok = run("run shortcut \"\(shortcutName)\" with input \"\(escaped)\"") != nil
        if !ok { confirmedReady = false }
        return ok
    }

    /// Opens the shortcut that comes inside Quadra, so the Shortcuts app offers to add it.
    static func installShortcut() {
        guard let url = Bundle.main.url(forResource: shortcutName, withExtension: "shortcut") else { return }
        NSWorkspace.shared.open(url)
    }

    private static func run(_ command: String) -> NSAppleEventDescriptor? {
        let source = "tell application id \"\(eventsID)\" to \(command)"
        var error: NSDictionary?
        let result = NSAppleScript(source: source)?.executeAndReturnError(&error)
        return error == nil ? result : nil
    }
}

/// The same interface as the GitHub version's WindowMover, backed by the window list and Shortcuts.
enum WindowMover {
    /// In this version "trusted" means the Quadra shortcut is installed and may be run.
    static func isTrusted(prompt: Bool = false) -> Bool {
        ShortcutsBridge.isReady(ask: prompt)
    }

    static func focusedWindow() -> TargetWindow? {
        guard let app = NSWorkspace.shared.frontmostApplication,
              app.processIdentifier != ProcessInfo.processInfo.processIdentifier,
              let window = StoreWindowList.windows().first(where: { $0.pid == app.processIdentifier })
        else { return nil }
        return TargetWindow(app: app, windowID: window.windowID)
    }

    /// Moves and resizes the window to `frame` (AppKit coordinates) within `area`.
    static func move(_ target: TargetWindow, to frame: CGRect, within area: CGRect) {
        guard ShortcutsBridge.moveFrontWindow(of: target.app, to: Geometry.flip(frame)) else { return }
        // Apps with a minimum or fixed size: center the window on the chosen area.
        if let actual = target.frame,
           abs(actual.width - frame.width) > 2 || abs(actual.height - frame.height) > 2 {
            let centered = Geometry.centered(actual.size, on: frame, within: area)
            ShortcutsBridge.moveFrontWindow(of: target.app, to: Geometry.flip(centered))
        }
    }

    static func focus(_ target: TargetWindow) {
        target.app.activate()
    }
}

/// Workspaces in this version: the front window of each app, put back through the shortcut.
enum WorkspaceArranger {
    /// Where the front window of each visible app is now.
    static func capture() -> [WindowPlacement] {
        let me = ProcessInfo.processInfo.processIdentifier
        let screens = Geometry.orderedScreens
        var seen = Set<pid_t>()
        var placements: [WindowPlacement] = []
        for entry in StoreWindowList.windows() where entry.pid != me && seen.insert(entry.pid).inserted {
            guard let app = NSRunningApplication(processIdentifier: entry.pid), app.activationPolicy == .regular,
                  !app.isHidden, let bundleID = app.bundleIdentifier else { continue }
            let frame = Geometry.flip(entry.bounds)
            guard let screen = Geometry.screen(containing: frame) else { continue }
            placements.append(WindowPlacement(bundleID: bundleID, appName: app.localizedName ?? bundleID,
                                              title: "", display: screen.localizedName,
                                              displayIndex: screens.firstIndex(of: screen) ?? 0,
                                              unitRect: Geometry.unit(of: frame, in: screen.visibleFrame)))
        }
        return placements
    }

    /// Opens the apps that aren't running and shows the hidden ones, then moves each app's front
    /// window into place. Apps that were just opened take a moment, so it tries again a few times.
    static func restore(_ workspace: Workspace, completion: @escaping (Int) -> Void) {
        var waiting = false
        for bundleID in Set(workspace.windows.map(\.bundleID)) {
            let running = NSRunningApplication.runningApplications(withBundleIdentifier: bundleID)
            if running.isEmpty, let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) {
                let configuration = NSWorkspace.OpenConfiguration()
                configuration.activates = false
                NSWorkspace.shared.openApplication(at: url, configuration: configuration)
                waiting = true
            }
            for app in running where app.isHidden {
                app.unhide()
                waiting = true
            }
        }

        // One window per app: the first saved placement of each.
        var seen = Set<String>()
        var pending = workspace.windows.filter { seen.insert($0.bundleID).inserted }
        var placed: [NSRunningApplication] = []
        func attempt() {
            let screens = Geometry.orderedScreens
            guard !screens.isEmpty else { return }
            let names = screens.map(\.localizedName)
            let visible = Set(StoreWindowList.windows().map(\.pid))
            pending.removeAll { placement in
                guard let app = NSRunningApplication.runningApplications(withBundleIdentifier: placement.bundleID).first,
                      visible.contains(app.processIdentifier) else { return false }
                let screen = screens[WorkspaceMatcher.displayIndex(for: placement, among: names)]
                let frame = Geometry.frame(for: placement.unitRect, in: screen.visibleFrame, gap: 0)
                guard ShortcutsBridge.moveFrontWindow(of: app, to: Geometry.flip(frame)) else { return false }
                placed.append(app)
                return true
            }
        }
        func finish() {
            // Bring the workspace's apps to the front, the first saved one on top.
            for app in placed.reversed() { app.activate() }
            completion(placed.count)
        }

        attempt()
        guard waiting, !pending.isEmpty else { return finish() }
        var gaps: [TimeInterval] = [0.8, 1, 1.5, 3, 4]
        func retry() {
            DispatchQueue.main.asyncAfter(deadline: .now() + gaps.removeFirst()) {
                attempt()
                if pending.isEmpty || gaps.isEmpty { finish() } else { retry() }
            }
        }
        retry()
    }
}
#endif
