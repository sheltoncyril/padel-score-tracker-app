import Foundation
import Observation
import WatchConnectivity
import PadelKit

/// Activates WCSession on the watch and answers pings from the iPhone.
@MainActor
@Observable
final class WatchConnectivityModel: NSObject, WCSessionDelegate {
    private(set) var status = "Phone link: starting"

    override init() {
        super.init()
        guard WCSession.isSupported() else {
            status = "Phone link: unsupported"
            return
        }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    private func setStatus(_ text: String) {
        status = text
    }

    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        let text: String
        if let error {
            text = "Phone link: \(error.localizedDescription)"
        } else {
            text = activationState == .activated ? "Phone link: active" : "Phone link: inactive"
        }
        Task { @MainActor in self.setStatus(text) }
    }

    nonisolated func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        let sentAt = message[PingMessage.ping] as? String ?? "?"
        replyHandler(PingMessage.reply(to: sentAt, from: "watch"))
        Task { @MainActor in self.setStatus("Phone link: ping \(sentAt)") }
    }
}
