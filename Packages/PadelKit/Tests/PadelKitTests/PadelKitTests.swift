import XCTest
@testable import PadelKit

final class PadelKitTests: XCTestCase {
    func testVersionIsSemver() {
        let parts = PadelKit.version.split(separator: ".")
        XCTAssertEqual(parts.count, 3)
        XCTAssertTrue(parts.allSatisfy { Int($0) != nil })
    }

    func testPingReplyEchoesTimestamp() {
        let reply = PingMessage.reply(to: "12:00:00", from: "watch")
        XCTAssertEqual(reply[PingMessage.pong], "12:00:00")
        XCTAssertEqual(reply["from"], "watch")
    }
}
