//
//  File.swift
//  TelinkBleMesh
//
//  Created by 王文东 on 2024/10/14.
//

import UIKit

public struct RoomScene {
    
    public struct Action: Codable {
        /// Action target address.
        public var target: Int
        
        public var isOn: Bool?
        
        /// Percentage, range [0, 100]
        public var brightness: Int?
        
        /// Percentage, range [0, 100]
        public var white: Int?
        
        /// Percentage, range [0, 100]
        public var colorTemperature: Int?
        
        /// Range [0x000000, 0xFFFFFF],
        /// 0xFF0000 = red,
        /// 0x00FF00 = green,
        /// 0x0000FF = blue,
        /// and so on.
        public var rgb: Int?
        
        public init(target: Int, isOn: Bool? = nil, brightness: Int? = nil, white: Int? = nil, colorTemperature: Int? = nil, rgb: Int? = nil) {
            self.target = target
            self.isOn = isOn
            self.brightness = brightness
            self.white = white
            self.colorTemperature = colorTemperature
            self.rgb = rgb
        }
        
        public var json: [String: Any] {
            var result: [String: Any] = ["target": target]
            if let isOn = isOn { result["isOn"] = isOn }
            if let brightness = brightness { result["brightness"] = brightness }
            if let white = white { result["white"] = white }
            if let colorTemperature = colorTemperature { result["colorTemperature"] = colorTemperature }
            if let rgb = rgb { result["rgb"] = rgb }
            return result
        }
        
        public static func makeActionFromJson(_ json: [String: Any]) -> Action? {
            guard let target = json["target"] as? Int else {
                return nil
            }
            var action = Action(target: target)
            if let isOn = json["isOn"] as? Bool { action.isOn = isOn }
            if let brightness = json["brightness"] as? Int {  action.brightness = brightness }
            if let white = json["white"] as? Int {  action.white = white }
            if let colorTemperature = json["colorTemperature"] as? Int { action.colorTemperature = colorTemperature }
            if let rgb = json["rgb"] as? Int { action.rgb  = rgb }
            return action
        }
        
        var commands: [MeshCommand] {
            var commands: [MeshCommand] = []
            
            if let rgb = self.rgb {
                let red = (rgb >> 16) & 0xFF
                let green = (rgb >> 8) & 0xFF
                let blue = rgb & 0xFF
                commands.append(MeshCommand.setRgb(self.target, red: red, green: green, blue: blue))
            }
            
            if let isOn = self.isOn {
                commands.append(MeshCommand.turnOnOff(self.target, isOn: isOn))
            }
            
            if let cct = self.colorTemperature {
                commands.append(MeshCommand.setColorTemperature(self.target, value: cct))
            }
            
            if let white = self.white {
                commands.append(MeshCommand.setWhitePercentage(self.target, value: white))
            }
            
            if let brightness = self.brightness {
                commands.append(MeshCommand.setBrightness(self.target, value: brightness))
            }
            return commands
        }
    }
    
    public var identifier: Int = 0
    public var name: String
    /// roomId must start with 0x800.
    public var roomId: Int
    public var actions: [Action] = []
    
    public var isNotEmpty: Bool {
        return name.count > 0 && actions.count > 0
    }
    
    public var containsAllLights: Bool {
        return actions.firstIndex(where: { $0.target & 0x8000 > 0 }) != nil
    }
    
    public var actionsJsonString: String {
        let actionsJson = actions.map { $0.json }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: actionsJson, options: .prettyPrinted)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            NSLog("actionsJsonString error \(error)", "")
        }
        return "[]"
    }
    
    public init(identifier: Int, name: String, roomId: Int, actions: [Action] = []) {
        self.identifier = identifier
        self.name = name
        self.roomId = roomId
        self.actions = actions
    }
    
    public mutating func updateActionsWithJsonString(_ jsonString: String) {
        guard let jsonData = jsonString.data(using: .utf8) else {
            NSLog("updateActionsWithJsonString failed: \(jsonString)", "")
            self.actions = []
            return
        }
        do {
            if let actionsJson = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]] {
                self.actions = actionsJson.compactMap{ Action.makeActionFromJson($0) }
            }
        } catch {
            NSLog("updateActionsWithJsonString error: \(error)", "")
            self.actions = []
        }
    }
    
    public var executeCommands: [MeshCommand] {
        return actions.flatMap { $0.commands }
    }
    
    public var jsonString: String {
        let json: [String: Any] = [
            "identifier": identifier,
            "name": name,
            "roomId": roomId,
            "actions": actions.map{ $0.json },
        ]
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
    
    public static func makeWithJsonString(_ jsonString: String) -> RoomScene? {
        guard let jsonData = jsonString.data(using: .utf8) else {
            NSLog("makeWithJsonString failed: \(jsonString)", "")
            return nil
        }
        do {
            if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                guard let identifier = json["identifier"] as? Int,
                      let name = json["name"] as? String,
                      let roomId = json["roomId"] as? Int,
                      let actionJsons = json["actions"] as? [[String: Any]] else {
                    return nil
                }
                var roomScene = RoomScene(identifier: identifier, name: name, roomId: roomId)
                let actions = actionJsons.compactMap { Action.makeActionFromJson($0) }
                roomScene.actions = actions
                return roomScene
            }
        } catch {
            NSLog("makeWithJsonString error: \(error)", "")
        }
        return nil
    }
}
