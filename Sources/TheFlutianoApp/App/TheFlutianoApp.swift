import SwiftUI

@main
struct TheFlutianoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var store = WorkspaceStore()

    var body: some Scene {
        WindowGroup {
            AppRootView(store: store)
                .frame(minWidth: 1440, minHeight: 900)
        }
    }
}
