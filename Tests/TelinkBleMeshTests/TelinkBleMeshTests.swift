import XCTest
@testable import TelinkBleMesh

final class TelinkBleMeshTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        // XCTAssertEqual(TelinkBleMesh().text, "Hello, World!")
    }
    
    func testMeshDb_RoomScene() {
        let roomScene = RoomScene(name: "Room Scene 1", roomId: 1, actions: [
            RoomScene.Action(target: 0xFF, isOn: true, brightness: 50, white: 50, colorTemperature: 50, rgb: 0x123456),
            RoomScene.Action(target: 0x01),
            RoomScene.Action(target: 0xA0, brightness: 50),
        ])
        let count = MeshDB.shared.insertRoomScene(roomScene)
        XCTAssertEqual(count, 1)
    }

    static var allTests = [
        ("testMeshDb_RoomScene", testMeshDb_RoomScene),
    ]
}
