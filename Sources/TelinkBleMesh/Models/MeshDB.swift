//
//  MeshDB.swift
//  
//
//  Created by 王文东 on 2023/8/29.
//

import UIKit
import SQLite3

// MARK: - Basic

public class MeshDB: NSObject {
    
    private var db: OpaquePointer?
    private let dbPath = {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
        return "\(documentsPath)/telink_sdk_sqlite3"
    }()
    private var isOpen = false
    
    public static let shared = MeshDB()
    
    private override init() {
        super.init()
        
        openDb {
            initTables()
        }
    }
    
    deinit {
        isOpen = false
        sqlite3_close(db)
    }
    
    private func openDb(succeed: () -> Void) {
        checkAndCreateFileAtPath(dbPath)
        
        guard !isOpen else {
            succeed()
            return
        }
        if sqlite3_open_v2(dbPath, &db, SQLITE_OPEN_READWRITE|SQLITE_OPEN_FULLMUTEX, nil) == SQLITE_OK {
            isOpen = true
            succeed()
        } else {
            NSLog("\(dbPath) open failed", "")
        }
    }
    
    private func checkAndCreateFileAtPath(_ filePath: String) {
        let fileManager = FileManager.default

        if fileManager.fileExists(atPath: filePath) {
            print("File exists at path: \(filePath)")
        } else {
            if fileManager.createFile(atPath: filePath, contents: nil, attributes: nil) {
                print("File created at path: \(filePath)")
            } else {
                print("Failed to create file at path: \(filePath)")
            }
        }
    }
    
    private func initTables() {
        let createTables = """
        CREATE TABLE IF NOT EXISTS uart_dali_devices(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            dali_address,
            gateway_address,
            device_type,
            name
        );
        
        CREATE TABLE IF NOT EXISTS room_scenes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name,
            roomId,
            actions
        );
        """
        if sqlite3_exec(db, createTables, nil, nil, nil) == SQLITE_OK {
            NSLog("initTables OK", "")
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db))
            NSLog("initTables error \(errmsg)", "")
        }
    }
    
}

// MARK: - UartDaliDevice

extension MeshDB {
    
    /// return isSuccess, if the device exists then return false.
    public func insertUartDaliDevice(_ device: UartDaliDevice) -> Bool {
        var isSuccess = false
        let selectSQL = """
            SELECT * FROM uart_dali_devices WHERE dali_address = ? AND gateway_address = ?;
        """
        
        var selectStmt: OpaquePointer?
        if sqlite3_prepare_v2(db, selectSQL, -1, &selectStmt, nil) == SQLITE_OK {
            sqlite3_bind_int(selectStmt, 1, Int32(device.daliAddress))
            sqlite3_bind_int(selectStmt, 2, Int32(device.gatewayAddress))
            
            if sqlite3_step(selectStmt) == SQLITE_ROW {
                isSuccess = false
                
            } else {
                // insert
                NSLog("insert device", "")
                
                let insertSQL = """
                INSERT OR REPLACE INTO uart_dali_devices (dali_address, gateway_address, device_type, name) VALUES (?, ?, ?, ?);
                """
                
                var stmt: OpaquePointer?
                if sqlite3_prepare_v2(db, insertSQL, -1, &stmt, nil) == SQLITE_OK {
                    sqlite3_bind_int(stmt, 1, Int32(device.daliAddress))
                    sqlite3_bind_int(stmt, 2, Int32(device.gatewayAddress))
                    sqlite3_bind_text(stmt, 3, (device.deviceType.rawValue as NSString).utf8String, -1, nil)
                    sqlite3_bind_text(stmt, 4, (device.name as NSString).utf8String, -1, nil)
                    
                    if sqlite3_step(stmt) == SQLITE_DONE {
                        NSLog("insertOrReplaceUartDaliDevice OK", "")
                        isSuccess = true
                    } else {
                        let errmsg = String(cString: sqlite3_errmsg(db))
                        NSLog("insertOrReplaceUartDaliDevice stmt error \(errmsg)", "")
                    }
                    sqlite3_finalize(stmt)
                    
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(db))
                    NSLog("insertOrReplaceUartDaliDevice error \(errmsg)", "")
                }
            }
            sqlite3_finalize(selectStmt)
            
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db))
            NSLog("insertOrReplaceUartDaliDevice select error \(errmsg)", "")
        }
        return isSuccess
    }
    
    /// return isSuccess, if the device doesn't exist, return false.
    public func updateUartDaliDevice(_ device: UartDaliDevice) -> Bool {
        var isSuccess = false
        let selectSQL = """
            SELECT * FROM uart_dali_devices WHERE dali_address = ? AND gateway_address = ?;
        """
        
        var selectStmt: OpaquePointer?
        if sqlite3_prepare_v2(db, selectSQL, -1, &selectStmt, nil) == SQLITE_OK {
            sqlite3_bind_int(selectStmt, 1, Int32(device.daliAddress))
            sqlite3_bind_int(selectStmt, 2, Int32(device.gatewayAddress))
            
            if sqlite3_step(selectStmt) == SQLITE_ROW {
                // update
                NSLog("update device", "")
                let updateSQL = """
                    UPDATE uart_dali_devices SET device_type = ?, name = ? WHERE dali_address = ? AND gateway_address = ?;
                """
                
                var updateStmt: OpaquePointer?
                if sqlite3_prepare_v2(db, updateSQL, -1, &updateStmt, nil) == SQLITE_OK {
                    sqlite3_bind_text(updateStmt, 1, (device.deviceType.rawValue as NSString).utf8String, -1, nil)
                    sqlite3_bind_text(updateStmt, 2, (device.name as NSString).utf8String, -1, nil)
                    sqlite3_bind_int(updateStmt, 3, Int32(device.daliAddress))
                    sqlite3_bind_int(updateStmt, 4, Int32(device.gatewayAddress))
                    
                    if sqlite3_step(updateStmt) == SQLITE_DONE {
                        NSLog("updated", "")
                        isSuccess = true
                    } else {
                        let errmsg = String(cString: sqlite3_errmsg(db))
                        NSLog("insertOrReplaceUartDaliDevice update error \(errmsg)", "")
                    }
                    sqlite3_finalize(updateStmt)
                    
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(db))
                    NSLog("insertOrReplaceUartDaliDevice update prepare error \(errmsg)", "")
                }
                
            } else {
                // doesn't exist
                isSuccess = false
            }
            sqlite3_finalize(selectStmt)
            
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db))
            NSLog("insertOrReplaceUartDaliDevice select error \(errmsg)", "")
        }
        return isSuccess
    }
    
    /// return isNewDevice
    public func insertOrUpdateUartDaliDevice(_ device: UartDaliDevice) -> Bool {
        var isNewDevice = false
        let selectSQL = """
            SELECT * FROM uart_dali_devices WHERE dali_address = ? AND gateway_address = ?;
        """
        
        var selectStmt: OpaquePointer?
        if sqlite3_prepare_v2(db, selectSQL, -1, &selectStmt, nil) == SQLITE_OK {
            sqlite3_bind_int(selectStmt, 1, Int32(device.daliAddress))
            sqlite3_bind_int(selectStmt, 2, Int32(device.gatewayAddress))
            
            if sqlite3_step(selectStmt) == SQLITE_ROW {
                // update
                NSLog("update device", "")
                let updateSQL = """
                    UPDATE uart_dali_devices SET device_type = ?, name = ? WHERE dali_address = ? AND gateway_address = ?;
                """
                
                var updateStmt: OpaquePointer?
                if sqlite3_prepare_v2(db, updateSQL, -1, &updateStmt, nil) == SQLITE_OK {
                    sqlite3_bind_text(updateStmt, 1, (device.deviceType.rawValue as NSString).utf8String, -1, nil)
                    sqlite3_bind_text(updateStmt, 2, (device.name as NSString).utf8String, -1, nil)
                    sqlite3_bind_int(updateStmt, 3, Int32(device.daliAddress))
                    sqlite3_bind_int(updateStmt, 4, Int32(device.gatewayAddress))
                    
                    if sqlite3_step(updateStmt) == SQLITE_DONE {
                        NSLog("updated", "")
                    } else {
                        let errmsg = String(cString: sqlite3_errmsg(db))
                        NSLog("insertOrReplaceUartDaliDevice update error \(errmsg)", "")
                    }
                    sqlite3_finalize(updateStmt)
                    
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(db))
                    NSLog("insertOrReplaceUartDaliDevice update prepare error \(errmsg)", "")
                }
                
            } else {
                // insert
                NSLog("insert device", "")
                
                let insertSQL = """
                INSERT OR REPLACE INTO uart_dali_devices (dali_address, gateway_address, device_type, name) VALUES (?, ?, ?, ?);
                """
                
                var stmt: OpaquePointer?
                if sqlite3_prepare_v2(db, insertSQL, -1, &stmt, nil) == SQLITE_OK {
                    sqlite3_bind_int(stmt, 1, Int32(device.daliAddress))
                    sqlite3_bind_int(stmt, 2, Int32(device.gatewayAddress))
                    sqlite3_bind_text(stmt, 3, (device.deviceType.rawValue as NSString).utf8String, -1, nil)
                    sqlite3_bind_text(stmt, 4, (device.name as NSString).utf8String, -1, nil)
                    
                    if sqlite3_step(stmt) == SQLITE_DONE {
                        NSLog("insertOrReplaceUartDaliDevice OK", "")
                        isNewDevice = true
                    } else {
                        let errmsg = String(cString: sqlite3_errmsg(db))
                        NSLog("insertOrReplaceUartDaliDevice stmt error \(errmsg)", "")
                    }
                    sqlite3_finalize(stmt)
                    
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(db))
                    NSLog("insertOrReplaceUartDaliDevice error \(errmsg)", "")
                }
            }
            sqlite3_finalize(selectStmt)
            
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db))
            NSLog("insertOrReplaceUartDaliDevice select error \(errmsg)", "")
        }
        return isNewDevice
    }
    
    public func selectUartDaliDevices(_ gatewayAddress: Int) -> [UartDaliDevice] {
        var result = [UartDaliDevice]()
        
        let selectSQL = """
            SELECT * FROM uart_dali_devices WHERE gateway_address = ?;
        """
        
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, selectSQL, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(gatewayAddress))
            
            while sqlite3_step(stmt) == SQLITE_ROW {
                // (id, dali_address, gateway_address, device_type, name)
                let daliAddress = Int(sqlite3_column_int(stmt, 1))
                let deviceTypeRawValue = String(cString: sqlite3_column_text(stmt, 3))
                let name = String(cString: sqlite3_column_text(stmt, 4))
                
                NSLog("selectUartDaliDevices \(daliAddress) \(gatewayAddress) \(deviceTypeRawValue) \(name)", "")
                if let deviceType = UartDaliDevice.DeviceType(rawValue: deviceTypeRawValue) {
                    let device = UartDaliDevice(daliAddress: daliAddress, gatewayAddress: gatewayAddress, deviceType: deviceType)
                    device.name = name
                    result.append(device)
                }
            }
            sqlite3_finalize(stmt)
            
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db))
            NSLog("selectUartDaliDevices error \(errmsg)", "")
        }
        return result.sorted { left, right in
            left.daliAddress < right.daliAddress
        }
    }
    
    public func deleteUartDaliDevices(_ gatewayAddress: Int) {
        let deleteSQL = """
            DELETE FROM uart_dali_devices WHERE gateway_address = ?;
        """
        
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, deleteSQL, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(gatewayAddress))
            
            if sqlite3_step(stmt) == SQLITE_DONE {
                NSLog("deleteUartDaliDevices OK \(gatewayAddress)", "")
            } else {
                let errmsg = String(cString: sqlite3_errmsg(db))
                NSLog("deleteUartDaliDevices stmt error \(errmsg)", "")
            }
            sqlite3_finalize(stmt)
            
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db))
            NSLog("deleteUartDaliDevices error \(errmsg)", "")
        }
    }
    
    public func deleteUartDaliDevice(_ daliAddress: Int, gatewayAddress: Int) {
        let deleteSQL = """
            DELETE FROM uart_dali_devices WHERE gateway_address = ? AND dali_address = ?;
        """
        
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, deleteSQL, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(gatewayAddress))
            sqlite3_bind_int(stmt, 2, Int32(daliAddress))
            
            if sqlite3_step(stmt) == SQLITE_DONE {
                NSLog("deleteUartDaliDevice OK \(gatewayAddress)", "")
            } else {
                let errmsg = String(cString: sqlite3_errmsg(db))
                NSLog("deleteUartDaliDevice stmt error \(errmsg)", "")
            }
            sqlite3_finalize(stmt)
            
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db))
            NSLog("deleteUartDaliDevice error \(errmsg)", "")
        }
    }
    
}

// MARK: - Room Scene

extension MeshDB {
    
    public func insertRoomScene(_ roomScene: RoomScene) -> Int {
        let insertSQL = """
            INSERT INTO room_scenes (name, roomId, actions)
            VALUES (?, ?, ?);
        """
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            NSLog("Error preparing insert statement: %@", errmsg)
            return -1
        }
        
        defer {
            sqlite3_finalize(statement)
        }
        
        sqlite3_bind_text(statement, 1, (roomScene.name as NSString).utf8String, -1, nil)
        sqlite3_bind_int(statement, 2, Int32(roomScene.roomId))
        sqlite3_bind_text(statement, 3, (roomScene.actionsJsonString as NSString).utf8String, -1, nil)
        
        if sqlite3_step(statement) == SQLITE_DONE {
            let newId = Int(sqlite3_last_insert_rowid(db))
            return newId
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            NSLog("Error inserting room scene: %@", errmsg)
            return -1
        }
    }
    
    func replaceAllRoomScenes(_ scenes: [RoomScene]) -> Bool {
        let deleteSQL = "DELETE FROM room_scenes;"

        let insertSQL = """
            INSERT INTO room_scenes (name, roomId, actions) 
            VALUES (?, ?, ?);
        """
        
        var deleteStatement: OpaquePointer?
        var insertStatement: OpaquePointer?
        
        guard sqlite3_prepare_v2(db, deleteSQL, -1, &deleteStatement, nil) == SQLITE_OK else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            NSLog("Error preparing delete statement: %@", errmsg)
            return false
        }
        
        guard sqlite3_prepare_v2(db, insertSQL, -1, &insertStatement, nil) == SQLITE_OK else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            NSLog("Error preparing insert statement: %@", errmsg)
            sqlite3_finalize(deleteStatement)
            return false
        }
        
        defer {
            sqlite3_finalize(deleteStatement)
            sqlite3_finalize(insertStatement)
        }
        
        sqlite3_exec(db, "BEGIN TRANSACTION", nil, nil, nil)
        
        if sqlite3_step(deleteStatement) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            NSLog("Error deleting existing room scenes: %@", errmsg)
            sqlite3_exec(db, "ROLLBACK", nil, nil, nil)
            return false
        }
        
        var insertedCount = 0
        
        for scene in scenes {
            sqlite3_reset(insertStatement)
            
            sqlite3_bind_text(insertStatement, 1, (scene.name as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 2, Int32(scene.roomId))
            sqlite3_bind_text(insertStatement, 3, (scene.actionsJsonString as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                insertedCount += 1
            } else {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                NSLog("Error inserting room scene: %@", errmsg)
                sqlite3_exec(db, "ROLLBACK", nil, nil, nil)
                return false
            }
        }
        
        sqlite3_exec(db, "COMMIT", nil, nil, nil)
        
        NSLog("Successfully replaced all room scenes. Deleted all existing scenes and inserted %d new scenes", insertedCount)
        return true
    }
    
    public func selectAllRoomScenes() -> [RoomScene] {
        let querySQL = "SELECT id, name, roomId, actions FROM room_scenes;"
        var statement: OpaquePointer?
        var roomScenes: [RoomScene] = []

        guard sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            NSLog("Error preparing select statement: %@", errmsg)
            return []
        }

        defer {
            sqlite3_finalize(statement)
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            let id = Int(sqlite3_column_int(statement, 0))
            let name = String(cString: sqlite3_column_text(statement, 1))
            let roomId = Int(sqlite3_column_int(statement, 2))
            let actionsJsonString = String(cString: sqlite3_column_text(statement, 3))

            var roomScene = RoomScene(identifier: id, name: name, roomId: roomId, actions: [])
            roomScene.updateActionsWithJsonString(actionsJsonString)
            roomScenes.append(roomScene)
        }

        return roomScenes
    }
    
    public func selectAllRoomScenes(roomId: Int) -> [RoomScene] {
        var scenes: [RoomScene] = []
        
        let query = "SELECT * FROM room_scenes WHERE roomId = ?"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            NSLog("Error preparing statement: %@", errmsg)
            return scenes
        }
        
        defer {
            sqlite3_finalize(stmt)
        }
        
        guard sqlite3_bind_int(stmt, 1, Int32(roomId)) == SQLITE_OK else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            NSLog("Error binding roomId: %@", errmsg)
            return scenes
        }
        
        while sqlite3_step(stmt) == SQLITE_ROW {
            let identifier = Int(sqlite3_column_int(stmt, 0))
            guard let namePointer = sqlite3_column_text(stmt, 1) else {
                NSLog("Error retrieving name", "")
                continue
            }
            let name = String(cString: namePointer)
            guard let actionsJsonPointer = sqlite3_column_text(stmt, 3) else {
                NSLog("Error retrieving actions JSON", "")
                continue
            }
            let actionsJsonString = String(cString: actionsJsonPointer)
            
            var scene = RoomScene(identifier: identifier, name: name, roomId: roomId)
            scene.updateActionsWithJsonString(actionsJsonString)
            scenes.append(scene)
        }
        
        if sqlite3_errcode(db) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            NSLog("Error fetching data: %@", errmsg)
        }
        
        return scenes
    }
    
    public func updateRoomScene(_ roomScene: RoomScene) -> Bool {
        let updateSQL = """
            UPDATE room_scenes
            SET name = ?, roomId = ?, actions = ?
            WHERE id = ?;
        """
        
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, updateSQL, -1, &statement, nil) == SQLITE_OK else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            NSLog("Error preparing update statement: %@", errmsg)
            return false
        }
        
        defer {
            sqlite3_finalize(statement)
        }
        
        guard sqlite3_bind_text(statement, 1, (roomScene.name as NSString).utf8String, -1, nil) == SQLITE_OK else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            NSLog("Error binding name: %@", errmsg)
            return false
        }
        
        guard sqlite3_bind_int(statement, 2, Int32(roomScene.roomId)) == SQLITE_OK else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            NSLog("Error binding roomId: %@", errmsg)
            return false
        }
        
        guard sqlite3_bind_text(statement, 3, (roomScene.actionsJsonString as NSString).utf8String, -1, nil) == SQLITE_OK else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            NSLog("Error binding actions: %@", errmsg)
            return false
        }
        
        guard sqlite3_bind_int(statement, 4, Int32(roomScene.identifier)) == SQLITE_OK else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            NSLog("Error binding identifier: %@", errmsg)
            return false
        }
        
        if sqlite3_step(statement) == SQLITE_DONE {
            return true
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            NSLog("Error updating room scene: %@", errmsg)
            return false
        }
    }
    
    public func deleteRoomScene(withId identifier: Int) -> Bool {
        let deleteSQL = "DELETE FROM room_scenes WHERE id = ?;"
        
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, deleteSQL, -1, &statement, nil) == SQLITE_OK else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            NSLog("Error preparing delete statement: %@", errmsg)
            return false
        }
        
        defer {
            sqlite3_finalize(statement)
        }
        
        guard sqlite3_bind_int(statement, 1, Int32(identifier)) == SQLITE_OK else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            NSLog("Error binding identifier: %@", errmsg)
            return false
        }
        
        if sqlite3_step(statement) == SQLITE_DONE {
            let rowsAffected = sqlite3_changes(db)
            if rowsAffected > 0 {
                NSLog("Room scene with id %d deleted successfully", identifier)
                return true
            } else {
                NSLog("No room scene found with id %d", identifier)
                return false
            }
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            NSLog("Error deleting room scene: %@", errmsg)
            return false
        }
    }
    
    /// You should call this method when you delete a room.
    public func deleteAllRoomScenes(forRoomId roomId: Int) {
        let deleteSQL = "DELETE FROM room_scenes WHERE roomId = ?;"
        
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, deleteSQL, -1, &statement, nil) == SQLITE_OK else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            NSLog("Error preparing delete statement: %@", errmsg)
            return
        }
        
        defer {
            sqlite3_finalize(statement)
        }
        
        guard sqlite3_bind_int(statement, 1, Int32(roomId)) == SQLITE_OK else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            NSLog("Error binding roomId: %@", errmsg)
            return
        }
        
        if sqlite3_step(statement) == SQLITE_DONE {
            let rowsAffected = sqlite3_changes(db)
            NSLog("Deleted %d room scenes for roomId %d", rowsAffected, roomId)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            NSLog("Error deleting room scenes: %@", errmsg)
        }
    }
    
    /// You should call this method when you remove a light in the room.
    public func deleteRoomSceneLights(forRoomId roomId: Int, lightAddress: Int) {
        let scenes = selectAllRoomScenes(roomId: roomId)
        let newScenes = deleteRoomSceneActions(scenes, lightAddress: lightAddress)
        updateExistingRoomScenes(newScenes)
    }
    
    /// You should call this method when you delete a light from the light settings.
    public func deleteAllRoomSceneLights(lightAddress: Int) {
        let scenes = selectAllRoomScenes()
        let newScenes = deleteRoomSceneActions(scenes, lightAddress: lightAddress)
        updateExistingRoomScenes(newScenes)
    }
    
    /// You should call this method when you reset your network or replace your network.
    public func deleteAllRoomScenes() {
        let deleteSQL = "DELETE FROM room_scenes;"
        
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, deleteSQL, -1, &statement, nil) == SQLITE_OK else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            NSLog("Error preparing delete all statement: %@", errmsg)
            return
        }
        
        defer {
            sqlite3_finalize(statement)
        }
        
        if sqlite3_step(statement) == SQLITE_DONE {
            let rowsAffected = sqlite3_changes(db)
            NSLog("Deleted all room scenes. Total records deleted: %d", rowsAffected)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            NSLog("Error deleting all room scenes: %@", errmsg)
        }
    }
    
    func deleteRoomSceneActions(_ scenes: [RoomScene], lightAddress: Int) -> [RoomScene] {
        return scenes.map { scene in
            let actions = scene.actions.filter { $0.target != lightAddress }
            var newScene = scene
            newScene.actions = actions
            return newScene
        }
    }
    
    func updateExistingRoomScenes(_ scenes: [RoomScene]) {
        let updateSQL = """
            UPDATE room_scenes
            SET name = ?, roomId = ?, actions = ?
            WHERE id = ?;
        """
        
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, updateSQL, -1, &statement, nil) == SQLITE_OK else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            NSLog("Error preparing update statement: %@", errmsg)
            return
        }
        
        defer {
            sqlite3_finalize(statement)
        }
        
        sqlite3_exec(db, "BEGIN TRANSACTION", nil, nil, nil)
        
        var updatedCount = 0
        
        for scene in scenes {
            sqlite3_reset(statement)
            
            sqlite3_bind_text(statement, 1, (scene.name as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 2, Int32(scene.roomId))
            sqlite3_bind_text(statement, 3, (scene.actionsJsonString as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 4, Int32(scene.identifier))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                if sqlite3_changes(db) > 0 {
                    updatedCount += 1
                }
            } else {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                NSLog("Error updating room scene: %@", errmsg)
                sqlite3_exec(db, "ROLLBACK", nil, nil, nil)
                return
            }
        }
        
        sqlite3_exec(db, "COMMIT", nil, nil, nil)
        NSLog("Successfully updated %d out of %d room scenes", updatedCount, scenes.count)
    }
    
    /// This  function will get all room scenes and conver them into a json string.
    /// If there are no room scenes, return "{}"
    public func exportRoomScenesToJsonString() -> String {
        let roomScenes = selectAllRoomScenes().map { $0.jsonString }
        let json: [String: Any] = ["roomScenes": roomScenes]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            NSLog("actionsJsonString error \(error)", "")
        }
        return "{}"
        
    }
    
    /// This funciton will first delete all room scenes and then import new room scenes from the json string.
    public func importRoomScenesFromJsonString(_ jsonString: String) {
        var roomScenes: [RoomScene] = []
        do {
            if let jsonData = jsonString.data(using: .utf8),
               let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
               let roomScenesString = json["roomScenes"] as? [String] {
                roomScenes = roomScenesString.compactMap { RoomScene.makeWithJsonString($0) }
            }
        } catch {
            NSLog("replaceAllRoomScnees error: \(error)", "")
        }
        let isOK = replaceAllRoomScenes(roomScenes)
        NSLog("replaceAllRoomScnees isOK? \(isOK)", "")
    }
}

// MARK: - Test

extension MeshDB {
    
    public func testUartDaliDevice() {
        
    }
    
}
