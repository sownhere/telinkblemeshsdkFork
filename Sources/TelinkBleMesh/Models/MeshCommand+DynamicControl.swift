//
//  File.swift
//  
//
//  Created by 王文东 on 2023/5/17.
//

import Foundation

extension MeshCommand {
    
    public struct DynamicControl {
        
        /**
         index range [1, 16]
         */
        public var index: UInt8 = 1
        public let indexRange: ClosedRange<UInt8> = 1...16
        public var items: [Item] = []
        
        public struct Item {
            public var hour: UInt8 = 0
            public var minute: UInt8 = 0
            public var delay: UInt16 = 0
            public var brightness: UInt8 = 0
            public var red: UInt8 = 0
            public var green: UInt8 = 0
            public var blue: UInt8 = 0
            public var whiteOrCt: UInt8 = 0
            public var whiteOrCtEnabled = true
        }
        
        public var isValid: Bool {
            return indexRange.contains(index) && items.count > 0
        }
        
        public var isTime: Bool {
            return (1...8).contains(index)
        }
        
        public var isDelay: Bool {
            !isTime
        }
    }
    
}

extension MeshCommand {
    
    public static func setDynamicControl(_ address: Int, dynamicControl: DynamicControl) -> [MeshCommand] {
        
        var commands: [MeshCommand] = []
        if !dynamicControl.isValid {
            return commands
        }
        
        let startIndex: UInt8 = dynamicControl.isTime ? (0x60 - 1) : (0x68 - 1)
        
        if dynamicControl.isTime {
            dynamicControl.items.forEach { item in
                var cmd = MeshCommand()
                cmd.tag = .appToNode
                cmd.dst = address
                cmd.userData[0] = startIndex + dynamicControl.index
                cmd.userData[1] = item.hour
                cmd.userData[2] = item.minute
                cmd.userData[3] = item.brightness
                cmd.userData[4] = item.red
                cmd.userData[5] = item.green
                cmd.userData[6] = item.blue
                cmd.userData[7] = item.whiteOrCt
                cmd.userData[8] = item.whiteOrCtEnabled ? 0x00 : 0x01
                commands.append(cmd)
            }
        } else {
            dynamicControl.items.forEach { item in
                var cmd = MeshCommand()
                cmd.tag = .appToNode
                cmd.dst = address
                cmd.userData[0] = startIndex + dynamicControl.index
                cmd.userData[1] = UInt8((item.delay >> 8) & 0xFF)
                cmd.userData[2] = UInt8(item.delay & 0xFF)
                cmd.userData[3] = item.brightness
                cmd.userData[4] = item.red
                cmd.userData[5] = item.green
                cmd.userData[6] = item.blue
                cmd.userData[7] = item.whiteOrCt
                cmd.userData[8] = item.whiteOrCtEnabled ? 0x00 : 0x01
                commands.append(cmd)
            }
        }
        commands.append(stopSetDynamicControl(address))
        return commands
    }
    
    public static func stopSetDynamicControl(_ address: Int) -> MeshCommand {
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = 0x60
        cmd.userData[1] = 0x80 // stop
        return cmd
    }
    
    /**
     dynamic control index range [1, 16], item index range [1, 32]
     */
    public static func getDynamicControl(_ address: Int, dynamicControlIndex: UInt8, itemIndex: UInt8) -> MeshCommand {
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = 0x60 - 1 + dynamicControlIndex
        cmd.userData[1] = 0xD8 // get
        cmd.userData[2] = itemIndex - 1
        return cmd
    }
    
    /**
     Start (enable) run dynamic control, dynamic control index range [1, 16], if repeat count is 0x00 that means always repeat.
     */
    public static func enableDynamicControl(_ address: Int, dynamicControlIndex: UInt8, repeatCount: UInt8) -> MeshCommand {
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = 0x60 - 1 + dynamicControlIndex
        cmd.userData[1] = 0xA0 // start run
        cmd.userData[2] = repeatCount
        return cmd
    }
    
    /**
     Stop (disable) stop run dynamic control
     */
    public static func disableDynamicControl(_ address: Int) -> MeshCommand {
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = 0x60
        cmd.userData[1] = 0xB0 // stop run
        return cmd
    }
    
    public static func resetDynamicControl(_ address: Int) -> MeshCommand {
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = 0x60
        cmd.userData[1] = 0xC0 // clear
        return cmd
    }
    
    public static func getDynamicControlCurrentState(_ address: Int) -> MeshCommand {
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = 0x60
        cmd.userData[1] = 0xD0 // current state
        return cmd
    }
    
    public static func getDynamicControlTargetState(_ address: Int) -> MeshCommand {
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = 0x60
        cmd.userData[1] = 0xD1 // target state
        return cmd
    }
}
