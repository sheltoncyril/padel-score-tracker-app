import SwiftUI

@main
struct BajadaWatchApp: App {
    @State private var connectivity = WatchConnectivityModel()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(connectivity)
        }
    }
}
