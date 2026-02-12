import Cocoa
import SwiftUI

// MARK: - App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var buddyWindow: NSWindow?
    var buddyViewController: NSHostingController<BuddyView>?
    var cursorTimer: Timer?
    var isFollowing = true
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        setupBuddyWindow()
        startCursorTracking()
        
        // Register global shortcuts
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleGlobalKeyEvent(event)
        }
    }
    
    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "cursorarrow.motionlines", accessibilityDescription: "Cursor Buddy")
            button.action = #selector(toggleBuddy)
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Toggle Buddy (⌘⇧B)", action: #selector(toggleBuddy), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Toggle Follow (⌘⇧F)", action: #selector(toggleFollow), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Capture Screen", action: #selector(captureScreen), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    func setupBuddyWindow() {
        let buddyView = BuddyView()
        buddyViewController = NSHostingController(rootView: buddyView)
        
        buddyWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 280, height: 140),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        buddyWindow?.contentViewController = buddyViewController
        buddyWindow?.isOpaque = false
        buddyWindow?.backgroundColor = .clear
        buddyWindow?.level = .floating
        buddyWindow?.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        buddyWindow?.ignoresMouseEvents = false
        buddyWindow?.hasShadow = false
        
        buddyWindow?.makeKeyAndOrderFront(nil)
    }
    
    func startCursorTracking() {
        cursorTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.updateBuddyPosition()
        }
    }
    
    func updateBuddyPosition() {
        guard isFollowing, let window = buddyWindow else { return }
        
        let mouseLocation = NSEvent.mouseLocation
        let screenFrame = NSScreen.main?.frame ?? .zero
        
        var x = mouseLocation.x + 30
        var y = mouseLocation.y - 30 - window.frame.height
        
        // Keep on screen
        if x + window.frame.width > screenFrame.maxX {
            x = mouseLocation.x - window.frame.width - 10
        }
        if y < screenFrame.minY {
            y = mouseLocation.y + 30
        }
        
        window.setFrameOrigin(NSPoint(x: x, y: y))
    }
    
    func handleGlobalKeyEvent(_ event: NSEvent) {
        // ⌘⇧B - Toggle buddy
        if event.modifierFlags.contains([.command, .shift]) && event.charactersIgnoringModifiers == "b" {
            toggleBuddy()
        }
        // ⌘⇧F - Toggle follow
        if event.modifierFlags.contains([.command, .shift]) && event.charactersIgnoringModifiers == "f" {
            toggleFollow()
        }
    }
    
    @objc func toggleBuddy() {
        if buddyWindow?.isVisible == true {
            buddyWindow?.orderOut(nil)
        } else {
            buddyWindow?.makeKeyAndOrderFront(nil)
        }
    }
    
    @objc func toggleFollow() {
        isFollowing.toggle()
        NotificationCenter.default.post(name: .followToggled, object: isFollowing)
    }
    
    @objc func captureScreen() {
        // Request screen capture
        NotificationCenter.default.post(name: .captureRequested, object: nil)
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let followToggled = Notification.Name("followToggled")
    static let captureRequested = Notification.Name("captureRequested")
    static let messageUpdated = Notification.Name("messageUpdated")
}

// MARK: - Buddy View
struct BuddyView: View {
    @State private var message = "Hey! I'm your cursor buddy. I'll observe your workflows and suggest ways to help. Press ⌘⇧B to hide me."
    @State private var isHovering = false
    @State private var isFollowing = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack(spacing: 8) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "6B46C1"), Color(hex: "00D9FF")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 24, height: 24)
                    .overlay(Text("🦞").font(.system(size: 12)))
                
                Text("Molty")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                
                Spacer()
                
                Circle()
                    .fill(Color.green)
                    .frame(width: 6, height: 6)
                    .opacity(isFollowing ? 1 : 0.3)
            }
            
            // Message
            Text(message)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.85))
                .lineLimit(3)
            
            // Actions (show on hover)
            if isHovering {
                HStack(spacing: 6) {
                    Button("📸 What's this?") {
                        captureAndAnalyze()
                    }
                    .buttonStyle(BuddyButtonStyle())
                    
                    Button("Got it") {
                        dismiss()
                    }
                    .buttonStyle(BuddyButtonStyle())
                }
                .transition(.opacity)
            }
        }
        .padding(12)
        .frame(width: 260)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .followToggled)) { notification in
            if let following = notification.object as? Bool {
                isFollowing = following
                message = following ? "Following your cursor again! 🎯" : "Staying put! Move me around if needed."
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .captureRequested)) { _ in
            captureAndAnalyze()
        }
    }
    
    func captureAndAnalyze() {
        message = "📷 Capturing screen..."
        
        // Get active app info
        if let frontApp = NSWorkspace.shared.frontmostApplication {
            let appName = frontApp.localizedName ?? "Unknown"
            message = "I see you're using \(appName). Let me know if you need help!"
        }
    }
    
    func dismiss() {
        message = "I'll be here if you need me! 👋"
    }
}

// MARK: - Button Style
struct BuddyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 11))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.white.opacity(configuration.isPressed ? 0.2 : 0.1))
            .foregroundColor(.white.opacity(0.7))
            .cornerRadius(6)
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Main
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
