import SwiftUI
import PadelKit

struct HomeView: View {
    @Environment(WatchConnectivityModel.self) private var connectivity

    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                Text("Bajada")
                    .font(.title2.bold())
                Text("v\(PadelKit.version)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                NavigationLink("Health check") {
                    HealthCheckView()
                }
                Text(connectivity.status)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
