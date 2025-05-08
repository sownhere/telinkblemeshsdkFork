//
//  File.swift
//  
//
//  Created by maginawin on 2021/3/23.
//

import Foundation

public struct MeshDeviceType {
    
    public enum Category {
        
        case light
        case remote
        case sensor
        case transmitter
        case peripheral
        case curtain
        case outlet
        case bridge
        case rfPa
        
        // Citron 8 keys pannel, 4 buttons IO module
        case customPanel
        
        case unsupported
        
        case universalRemote
    }
    
    public enum Capability {
        
        case onOff
        case brightness
        case colorTemperature
        case white
        case rgb
        case channel1OnOff
        case channel2OnOff
    }
    
    public enum LightType {
        
        case onOff
        case dim
        case cct
        case rgb
        case rgbw
        case rgbCct
        case doubleChannelsOnOff
        
        var lightTypeValue: UInt8 {
            switch self {
            case .onOff: return 0x00
            case .dim: return 0x01
            case .cct: return 0x02
            case .rgb: return 0x03
            case .rgbw: return 0x04
            case .rgbCct: return 0x05
            case .doubleChannelsOnOff: return 0x06
            }
        }
    }
    
    public enum SensorType {
        case none
        case microwaveMotion
        
        public var desc: String {
            switch self {
            case .none: return "none"
            case .microwaveMotion: return "Microwave Motion"
            }
        }
    }
    
    public enum UniversalRemoteType {
        case none
        case k5WithKnob
        case k12WithKnob
        
        public var desc: String {
            switch self {
            case .none: return "none"
            case .k5WithKnob: return "K5 & Knob"
            case .k12WithKnob: return "K12 & Knob"
            }
        }
    }
    
    public enum CurtainType {
        case normal
        case blind
        case dooya
    }
    
    /// Raw value of the device type.
    public let rawValue1: UInt8
    
    /// Raw value of the sub device type.
    public private(set) var rawValue2: UInt8
    
    /// Category of the device.
    public let category: Category
    
    public private(set) var capabilities: [Capability] = []
    
    public private(set) var lightType: LightType = .onOff
    
    public private(set) var sensorType: SensorType = .none
    
    public private(set) var universalRemoteType: UniversalRemoteType = .none
    
    public private(set) var curtainType: CurtainType = .normal
    
    public var isBleUartModule: Bool {
        guard category == .light else { return false }
        switch (rawValue2 & 0xF0) {
        case 0x90: fallthrough
        case 0xC0: fallthrough
        case 0xA0: fallthrough
        case 0xD0:
            return true
        default:
            return false
        }
    }
    
    public var isSupportPowerOnState: Bool {
        guard category == .light else { return false }
        switch (rawValue2) {
        case 0x11...0x1F: fallthrough
        case 0x28...0x2F: fallthrough
        case 0x30...0x3F: fallthrough
        case 0x60...0x6F: fallthrough
        case 0x70...0x7F:
            return true
        default:
            return false 
        }
    }
    
    public var isSupportChangeDeviceType: Bool {
        guard category == .light else { return false }
        switch (rawValue2) {
        case 0x30...0x35: fallthrough
        case 0x60...0x65:
            return true
        default:
            return false
        }
    }
    
    public mutating func updateToNewLightType(newLightType: MeshDeviceType.LightType) {
        self.rawValue2 = (rawValue2 & 0xF0) | newLightType.lightTypeValue
        
        if let (capabilities, lightType, sensorType) = Light(rawValue: rawValue2)?.capabilitiesAndLightTypeSensorType {
            self.capabilities = capabilities
            self.lightType = lightType
            self.sensorType = sensorType
        }
    }
    
    public init(deviceType: UInt8, subDeviceType: UInt8) {
        
        self.rawValue1 = deviceType
        self.rawValue2 = subDeviceType
        
        switch deviceType {
        
        case 0x01:
            
            category = .light
            if let (capabilities, lightType, sensorType) = Light(rawValue: subDeviceType)?.capabilitiesAndLightTypeSensorType {
                
                self.capabilities = capabilities
                self.lightType = lightType
                self.sensorType = sensorType
            }            
            
        case 0x02: fallthrough
        case 0x03: fallthrough
        case 0x0A: fallthrough
        case 0x0B: fallthrough
        case 0x0C: fallthrough
        case 0x0D: fallthrough
        case 0x0E: fallthrough
        case 0x12: fallthrough
        case 0x13: fallthrough
        case 0x14:
            category = .remote
            
        case 0x16:
            category = .customPanel
            
        case 0x04:
            category = .sensor
            
        case 0x05:
            category = .transmitter
            
        case 0x06:
            category = .peripheral
            
        case 0x07:
            category = .curtain
            if (subDeviceType == 0x02) {
                curtainType = .blind
            } else if (subDeviceType == 0x03) {
                curtainType = .dooya
            } else {
                curtainType = .normal
            }
            
        case 0x08:
            category = .outlet
            
        case 0x09:
            category = .unsupported
            
        case 0x50:
            if rawValue2 == 0x02 {
                category = .rfPa
            } else {
                category = .bridge
            }
            
        case 0x10:
            category = .universalRemote
            if (rawValue2 == 0x06) {
                universalRemoteType = .k5WithKnob
            } else if (rawValue2 == 0x07) {
                universalRemoteType = .k12WithKnob
            }
        
        default:
            category = .unsupported
        }
    }
}

extension MeshDeviceType.Category {
    
    public var description: String {
        
        switch self {
        
        case .light:
            return "Light"
            
        case .remote:
            return "Remote"
            
        case .sensor:
            return "Sensor"
            
        case .transmitter:
            return "Transmission module"
            
        case .peripheral:
            return "Peripheral"
            
        case .curtain:
            return "Curtain"
            
        case .outlet:
            return "Outlet"
            
        case .bridge:
            return "Bridge"
            
        case .rfPa:
            return "RF PA"
            
        case .unsupported:
            return "Unsupported"
            
        case .customPanel:
            return "Custom panel"
            
        case .universalRemote:
            return "Universal remote"
        }
    }
    
}

extension MeshDeviceType.Capability {
    
    public var description: String {
        
        switch self {
        
        case .onOff:
            return "OnOff"
            
        case .brightness:
            return "Brightness"
            
        case .colorTemperature:
            return "Color temperature"
            
        case .white:
            return "White"
            
        case .rgb:
            return "RGB"
            
        case .channel1OnOff:
            return "Channel 1 OnOff"
        case .channel2OnOff:
            return "Channel 2 OnOff"
        }
    }
    
}

extension MeshDeviceType {
    
    enum Light: UInt8 {
        
        case endpoint6Pwm = 0x08
        
        case singleDim = 0x11
        case singleOnOff = 0x12
        case singleDim2 = 0x13
        case singleOnOff2 = 0x14
        case rotationDim = 0x15
        case doubleChannels = 0x16
        
        case powerMetering = 0x20
        
        case nfcDim = 0x28
        case nfcCct = 0x29
        
        case nfcDim2 = 0x2A
        case nfcCct2 = 0x2B
        
        case onoff = 0x30
        case onoff2 = 0x60
        
        case dim = 0x31
        case dim3 = 0x61
        
        case cct = 0x32
        case cct3 = 0x62
        
        case rgb = 0x33
        case rgb2 = 0x63
        
        case rgbw = 0x34
        case rgbw2 = 0x64
        
        case rgbCct = 0x35
        case rgbCct2 = 0x65
        
        case dtw = 0x36
        case dtw2 = 0x66
        
        case channel6Pwm = 0x37
        case dim2 = 0x38
        case cct2 = 0x39
        
        case rfPa = 0x3A
        
        /// BL9032A-MW-20210322-1
        case microwaveMotionSensor1 = 0x3C
        /// BL9032A-MW-20210322-2
        case microwaveMotionSensor2 = 0x3D
        /// BL9032A-MW-20210322-3
        case microwaveMotionSensor3 = 0x3E
        /// BL9032A-MW-20210322-4
        case microwaveMotionSensor4 = 0x3F
        case sb9030A_PIR8258 = 0x40
        
        var capabilitiesAndLightTypeSensorType: ([Capability], LightType, SensorType) {
            
            switch self {
            
            case .singleOnOff: fallthrough
            case .singleOnOff2: fallthrough
            case .onoff: fallthrough
            case .onoff2:
                return ([.onOff], .onOff, .none)
            case .doubleChannels:
                return ([.onOff, .channel1OnOff, .channel2OnOff], .doubleChannelsOnOff, .none)
                
            case .powerMetering:
                return ([.onOff, .brightness], .dim, .none)
                
            case .singleDim: fallthrough
            case .singleDim2: fallthrough
            case .dim: fallthrough
            case .dim2: fallthrough
            case .dim3: fallthrough
            case .dtw: fallthrough
            case .dtw2: fallthrough
            case .nfcDim: fallthrough
            case .nfcDim2: fallthrough
            case .rotationDim:
                return ([.onOff, .brightness], .dim, .none)

            case .cct: fallthrough
            case .cct2: fallthrough
            case .cct3: fallthrough
            case .endpoint6Pwm: fallthrough
            case .channel6Pwm: fallthrough
            case .nfcCct: fallthrough
            case .nfcCct2:
                return ([.onOff, .brightness, .colorTemperature], .cct, .none)
                
            case .rgb: fallthrough
            case .rgb2:
                return ([.onOff, .brightness, .rgb], .rgb, .none)
                
            case .rgbw: fallthrough
            case .rgbw2:
                return ([.onOff, .brightness, .white, .rgb], .rgbw, .none)
                
            case .rgbCct: fallthrough
            case .rgbCct2:
                return ([.onOff, .brightness, .colorTemperature, .rgb], .rgbCct, .none)
                
            case .rfPa:
                return ([], .onOff, .none)
                
            case .microwaveMotionSensor1: fallthrough
            case .microwaveMotionSensor2: fallthrough
            case .microwaveMotionSensor3: fallthrough
            case .microwaveMotionSensor4: fallthrough
            case .sb9030A_PIR8258:
                return ([.onOff, .brightness], .dim, .microwaveMotion)
            }
        }
    }
    
}

extension MeshDeviceType: Equatable {}

public func == (lhs: MeshDeviceType, rhs: MeshDeviceType) -> Bool {
    
    return lhs.rawValue1 == rhs.rawValue1 && lhs.rawValue2 == rhs.rawValue2
}

extension MeshDeviceType {
    
    public var isSupportMeshAdd: Bool {
        
        switch category {
        
        case .light: fallthrough
        case .curtain: fallthrough
        case .bridge: fallthrough
        case .outlet:
            return true
            
        case .remote: fallthrough
        case .sensor: fallthrough
        case .transmitter: fallthrough
        case .peripheral: fallthrough
        case .rfPa: fallthrough
        case .unsupported: fallthrough
        case .customPanel: fallthrough
        case .universalRemote:
            return false
        }
    }
    
    public var isSafeConntion: Bool {
        
        switch category {
        
        case .light: fallthrough
        case .curtain: fallthrough
        case .outlet: fallthrough
        case .rfPa:
            return true
            
        case .remote: fallthrough
        case .sensor: fallthrough
        case .transmitter: fallthrough
        case .peripheral: fallthrough
        case .unsupported: fallthrough
        case .customPanel: fallthrough
        case .bridge: fallthrough
        case .universalRemote:
            return false
        }
    }
    
    ///
    /// This is a lighting.
    ///
    /// Supports:
    ///
    ///     * Set a sensor ID
    ///     
    public var isSupportSensorAction: Bool {        
        if category == .curtain { return true }
        
        guard category == .light else { return false }
        guard capabilities.count > 0 else { return false }
        guard sensorType == .none else { return false }
        guard !isBleUartModule else { return false }
        return true
    }
    
}
