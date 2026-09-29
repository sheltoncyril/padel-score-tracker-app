import SwiftUI
import PadelKit

struct ContentView: View {
    @Environment(PhoneConnectivityModel.self) private var connectivity

    private var appVersion: String {
        let info = Bundle.main.infoDictionary
        let short = info?["CFBundleShortVersionString"] as? String ?? "?"
        let build = info?["CFBundleVersion"] as? String ?? "?"
        return "\(short) (\(build))"
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    LabeledContent("App version", value: appVersion)
                    LabeledContent("PadelKit", value: PadelKit.version)
                }
                Section("Apple Watch") {
                    StatusRow(title: "Paired", value: connectivity.isPaired)
                    StatusRow(title: "App installed", value: connectivity.isWatchAppInstalled)
                    StatusRow(title: "Reachable", value: connectivity.isReachable)
                }
                Section {
                    Button("Ping watch") { connectivity.ping() }
                    Text(connectivity.pingResult)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Bajada")
        }
    }
}

private struct StatusRow: View {
    let title: String
    let value: Bool

    var body: some View {
        LabeledContent(title) {
            Text(value ? "Yes" : "No")
                .foregroundStyle(value ? .green : .secondary)
        }
    }
}
