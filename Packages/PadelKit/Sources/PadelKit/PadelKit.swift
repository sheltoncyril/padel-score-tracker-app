import Foundation

/// Placeholder for the padel rules engine (Phase 1). Foundation only.
public enum PadelKit {
    public static let version = "0.0.1"
}

/// Keys for the WatchConnectivity ping round trip used by the Phase 0 hello screens.
public enum PingMessage {
    public static let ping = "ping"
    public static let pong = "pong"

    /// Builds the reply to a ping that carried the timestamp `sentAt`.
    public static func reply(to sentAt: String, from device: String) -> [String: String] {
        [pong: sentAt, "from": device]
    }
}
