//
//  TelinkBleMeshSdkDemoTests.swift
//  TelinkBleMeshSdkDemoTests
//
//  Created by maginawin on 2021/1/13.
//

import XCTest
@testable import TelinkBleMeshSdkDemo
@testable import TelinkBleMesh

class TelinkBleMeshSdkDemoTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testMeshDb_RoomScene() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        var roomScene = RoomScene(identifier: 0, name: "Room Scene 1", roomId: 1, actions: [
            RoomScene.Action(target: 0xFF, isOn: true, brightness: 50, white: 50, colorTemperature: 50, rgb: 0x123456),
            RoomScene.Action(target: 0x01),
            RoomScene.Action(target: 0xA0, brightness: 50),
        ])
        let count = MeshDB.shared.insertRoomScene(roomScene)
        XCTAssert(count > 0)
        roomScene.identifier = count
        roomScene.actions = [RoomScene.Action(target: 0x01),]
        roomScene.name = "room scene updated"
        let isUpdated = MeshDB.shared.updateRoomScene(roomScene)
        XCTAssert(isUpdated == true)
        let lastRoomScene = MeshDB.shared.selectAllRoomScenes(roomId: 1).last!
        XCTAssert(lastRoomScene.identifier == roomScene.identifier)
        XCTAssert(lastRoomScene.actions.count == 1)
        XCTAssert(lastRoomScene.name == "room scene updated")
        
        let roomScene2 = RoomScene(identifier: 0, name: "Room Scene 2", roomId: 2, actions: [
            RoomScene.Action(target: 0xFF, isOn: true, brightness: 50, white: 50, colorTemperature: 50, rgb: 0x123456),
            RoomScene.Action(target: 0x01),
            RoomScene.Action(target: 0xA0, brightness: 50),
        ])
        let count2 = MeshDB.shared.insertRoomScene(roomScene2)
        XCTAssert(count2 > 0)
        
        let scenesString = MeshDB.shared.exportRoomScenesToJsonString()
        NSLog("scenesString: \n\(scenesString)", "")
        
        let scenes = MeshDB.shared.selectAllRoomScenes()
        NSLog("all \(scenes.count)", "")
        XCTAssert(scenes.count > 0)
        
        let scenes1 = MeshDB.shared.selectAllRoomScenes(roomId: 1)
        XCTAssert(scenes1.count > 0)
        
        let scenes3 = MeshDB.shared.selectAllRoomScenes(roomId: 3)
        XCTAssertEqual(scenes3.count, 0)
        
        let del1 = MeshDB.shared.deleteRoomScene(withId: roomScene.identifier)
        XCTAssert(del1 == true)
        MeshDB.shared.deleteAllRoomScenes(forRoomId: 1)
        let s2 = MeshDB.shared.selectAllRoomScenes(roomId: 1)
        XCTAssert(s2.count == 0)
        MeshDB.shared.deleteAllRoomScenes()
        let s3 = MeshDB.shared.selectAllRoomScenes()
        XCTAssert(s3.count == 0)
        
        
        MeshDB.shared.importRoomScenesFromJsonString(scenesString)
        let s4 = MeshDB.shared.selectAllRoomScenes()
        NSLog("s4 \(s4.count)", "")
        XCTAssert(s4.count > 0)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
