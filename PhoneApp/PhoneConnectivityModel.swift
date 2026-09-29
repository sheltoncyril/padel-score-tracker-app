import Foundation
import Observation
import WatchConnectivity
import PadelKit

/// WatchConnectivity status for the iPhone hello screen, plus a ping round trip.
@MainActor
@Observable
final class PhoneConnectivityModel: NSObject, WCSessionDelegate {
    private(set) var isPaired = false
    private(set) var isWatchAppInstalled = false
    private(set) var isReachable = false
    private(set) var pingResult = "No ping yet"

    override init() {
        super.init()
        guard WCSession.isSupported() else {
            pingResult = "WatchConnectivity is not supported here"
            return
        }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    func ping() {
        let session = WCSession.default
        guard session.activationState == .activated else {
            pingResult = "Session not active yet"
            return
        }
        let sent = Date.now.formatted(date: .omitted, time: .standard)
        let started = Date()
        pingResult = "Pinging..."
        session.sendMessage(
            [PingMessage.ping: sent],
            replyHandler: { reply in
                let echoed = reply[PingMessage.pong] as? String ?? "?"
                let ms = Int(Date().timeIntervalSince(started) * 1000)
                Task { @MainActor in
                    self.pingResult = echoed == sent
                        ? "Pong from watch in \(ms) ms"
                        : "Unexpected reply: \(echoed)"
                }
            },
            errorHandler: { error in
                let text = error.localizedDescription
                Task { @MainActor in self.pingResult = "Ping failed: \(text)" }
            }
        )
    }

    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        let paired = session.isPaired
        let installed = session.isWatchAppInstalled
        let reachable = session.isReachable
        let text = error?.localizedDescription
        Task { @MainActor in
            self.isPaired = paired
            self.isWatchAppInstalled = installed
            self.isReachable = reachable
            if let text { self.pingResult = "Activation failed: \(text)" }
        }
    }

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    nonisolated func sessionWatchStateDidChange(_ session: WCSession) {
        let paired = session.isPaired
        let installed = session.isWatchAppInstalled
        let reachable = session.isReachable
        Task { @MainActor in
            self.isPaired = paired
            self.isWatchAppInstalled = installed
            self.isReachable = reachable
        }
    }

    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        let reachable = session.isReachable
        Task { @MainActor in self.isReachable = reachable }
    }
}
