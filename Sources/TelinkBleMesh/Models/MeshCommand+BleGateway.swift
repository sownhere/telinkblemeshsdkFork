//
//  File.swift
//  
//
//  Created by 王文东 on 2024/1/13.
//

import Foundation

extension MeshCommand {
    
    public struct BleGateway {
                
        /// return the data.data hexString of the MQTT command SEND_UART_DATA.
        public static func updateLightRunningMode(_ mode: LightRunningMode) -> String {
            let addrLow = UInt8(mode.address & 0xFF)
            let addrHigh = UInt8((mode.address >> 8) & 0xFF)
            var userData3: UInt8 = 0x00
            var userData4: UInt8 = 0x00
            switch mode.state {
            case .stopped:
                break
            case .defaultMode:
                userData3 = mode.defaultMode.rawValue
            case .customMode:
                userData3 = UInt8(mode.customModeId)
                userData4 = mode.customMode.rawValue
            }
            
            let data = Data([
                0xBD, 0xBE, 0x03, 0x04, 
                addrHigh, addrLow,
                0x06, // payload data length
                0xEA, // custom protocol
                SrIndentifier.lightControlMode.rawValue, // userData[0], 0x01
                SrLightControlMode.setLightRunningMode.rawValue, // userData[1], 0x05
                mode.state.rawValue, // userData[2]
                userData3,
                userData4
            ])
            return data.hexString
        }
        
        /// speed range: [0x00, 0x0F], 0x00 -> fastest, 0x0F -> slowest
        public static func updateLightRunningSpeed(_ address: Int, speed: Int) -> String {
            let addrLow = UInt8(address & 0xFF)
            let addrHigh = UInt8((address >> 8) & 0xFF)
            let data = Data([
                0xBD, 0xBE, 0x03, 0x04,
                addrHigh, addrLow,
                0x04, // payload data length
                0xEA, // custom protocol
                SrIndentifier.lightControlMode.rawValue, // userData[0]
                SrLightControlMode.setLightRunningSpeed.rawValue, // userData[1]
                UInt8(speed), // userData[2]
            ])
            return data.hexString
        }
    }
}
