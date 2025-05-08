//
//  File.swift
//  
//
//  Created by maginawin on 2021/1/13.
//

import Foundation

public struct MeshDevice {
    
    public enum State {
        
        case offline, on, off
        
        public var title: String {
            
            switch self {
            
            case .offline:
                return "Offline"
                
            case .on:
                return "On"
                
            case .off:
                return "Off"
            }
        }
    }

    public var state = State.on
    
    public var address: UInt8 = 0
    
    public var groupAddress: [UInt16] = []
    
    public var brightness: Int = 0
    
    public var version = "nil"
    
    public var description: String {
        
        let hexAddress = String(format: "0x%02X", address)
        
        return "Address \(address) (\(hexAddress)), state \(state.title), \(brightness)%"
    }
    
    public var doubleChannelsDescription: String {
        let hexAddress = String(format: "0x%02X", address)
        return "Address \(address) (\(hexAddress)), ① \(channel1State.title) \(channel1Brightness)%, ② \(channel2State.title) \(channel2Brightness)%"
    }
    
    public var doubleChannelsState: State {
        if state == .offline { return .offline }
        return (channel1State == .on || channel2State == .on) ? .on : .off
    }
    public var channel1State: State {
        return channel1Brightness > 0 ? .on : .off
    }
    public var channel2State: State {
        return channel2Brightness > 0 ? .on : .off
    }
    public var channel1Brightness: Int = 0
    public var channel2Brightness: Int = 0
    
    /// If `deviceAddr` is 0, return nil.
    public init?(deviceAddr: UInt8, isOnline: Bool, brightness: UInt8, reserved: UInt8) {
        
        guard deviceAddr != 0 else { return nil }
        
        self.address = deviceAddr
        self.state = isOnline ? (brightness > 0 ? .on : .off) : .offline
        self.brightness = Int(brightness)
        
        self.channel1Brightness = Int(brightness)
        self.channel2Brightness = Int(reserved)
    }
    
}

extension MeshDevice {
        
    static func makeMeshDevices(_ data: Data) -> [MeshDevice] {
        
        let tag = data[7]
        let vendorId0 = data[8]
        let vendorId1 = data[9]
        
        guard tag == 0xDC, vendorId0 == 0x11, vendorId1 == 0x02 else {
            
            return []
        }
            
        var devices: [MeshDevice] = []
        
        let firstDeviceAddr = data[10]
        let isFirstOnline = data[11] != 0
        let firstBrightness = data[12]
        
        if let firstDevice = MeshDevice(deviceAddr: firstDeviceAddr, isOnline: isFirstOnline, brightness: firstBrightness, reserved: data[13]) {
            devices.append(firstDevice)
        }
        
        let secondDeviceAddr = data[14]
        let isSecondOnline = data[15] != 0
        let secondBrightness = data[16]
        
        if let secondDevice = MeshDevice(deviceAddr: secondDeviceAddr, isOnline: isSecondOnline, brightness: secondBrightness, reserved: data[17]) {
            devices.append(secondDevice)
        }
        
        return devices
    }
    
}
