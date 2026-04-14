import SwiftUI

struct AppRootView: View {
    let store: WorkspaceStore

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            BackgroundArtView()

            HStack(spacing: 0) {
                SidebarView(store: store)

                Group {
                    switch store.selectedScreen {
                    case .dashboard:
                        DashboardView(store: store)
                    case .projects:
                        ProjectsView(store: store)
                    case .newProject:
                        NewProjectView(store: store)
                    default:
                        DashboardView(store: store)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            if let toast = store.toast {
                ToastOverlayView(toast: toast)
                    .padding(.trailing, 24)
                    .padding(.bottom, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .background(FlutianoTheme.background)
        .task(id: store.toast?.id) {
            guard let toastID = store.toast?.id else { return }
            try? await Task.sleep(for: .seconds(2.8))
            if store.toast?.id == toastID {
                withAnimation(.easeInOut(duration: 0.22)) {
                    store.dismissToast()
                }
            }
        }
        .animation(.easeInOut(duration: 0.18), value: store.selectedScreen)
        .animation(.easeInOut(duration: 0.22), value: store.toast?.id)
    }
}
