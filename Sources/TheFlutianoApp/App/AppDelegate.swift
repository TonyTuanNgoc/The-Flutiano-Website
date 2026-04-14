import AppKit
import CoreText

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        registerBundledFonts()
        NSApp.setActivationPolicy(.regular)

        DispatchQueue.main.async {
            NSApp.windows.forEach { window in
                window.titleVisibility = .hidden
                window.titlebarAppearsTransparent = true
                window.isMovableByWindowBackground = true
                window.toolbar = nil
                window.styleMask.insert(.fullSizeContentView)
                window.backgroundColor = .clear
            }

            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private func registerBundledFonts() {
        let fontFiles = [
            "Manrope-Medium.ttf",
            "Manrope-SemiBold.ttf",
            "Manrope-Bold.ttf",
            "Manrope-ExtraBold.ttf",
            "Sora-Medium.ttf",
            "Sora-SemiBold.ttf",
            "Sora-Bold.ttf"
        ]

        for file in fontFiles {
            guard let url = Bundle.module.url(forResource: file, withExtension: nil) else { continue }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}
