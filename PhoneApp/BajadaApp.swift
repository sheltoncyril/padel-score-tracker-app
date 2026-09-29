import SwiftUI

@main
struct BajadaApp: App {
    @State private var connectivity = PhoneConnectivityModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(connectivity)
        }
    }
}
