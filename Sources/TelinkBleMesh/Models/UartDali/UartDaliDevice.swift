//
//  File.swift
//  
//
//  Created by 王文东 on 2023/8/24.
//

import UIKit

public class UartDaliDevice: NSObject {
    
    public enum DeviceType: String {
        case dt6 = "DT6"
        case dt8Cct = "DT8 CCT"
        case dt8Xy = "DT8 XY"
        case dt8Rgbw = "DT8 RGBW"
        case dt8Rgbwa = "DT8 RGBWA"
        
        public var defaultDataPoints: [String: Any] {
            var result: [String: Any] = [
                "ON_OFF": true,
                "BRIGHTNESS": 254
            ]
            switch self {
            case .dt6:
                break
            case .dt8Cct:
                result["COLOR_TEMPERATURE"] = 4500
            case .dt8Xy:
                result["X"] = 0
                result["Y"] = 1
            case .dt8Rgbw:
                result["RED"] = 254
                result["GREEN"] = 254
                result["BLUE"] = 254
                result["WHITE"] = 254
            case .dt8Rgbwa:
                result["RED"] = 254
                result["GREEN"] = 254
                result["BLUE"] = 254
                result["WHITE"] = 254
                result["AMBER"] = 254
            }
            return result
        }
    }
    
    public var daliAddress: Int
    public var gatewayAddress: Int
    public var deviceType: DeviceType
    public var dataPoints: [String: Any] = [:]
    public var isOnline: Bool = true
    public var name: String = ""
    
    public var commonName: String {
        return deviceType.rawValue + " \(daliAddress)"
    }
    
    public init(daliAddress: Int, gatewayAddress: Int, deviceType: DeviceType) {
        
        self.daliAddress = daliAddress
        self.gatewayAddress = gatewayAddress
        self.deviceType = deviceType
        self.dataPoints = deviceType.defaultDataPoints
        
        super.init()
    }
}

extension UartDaliDevice {
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let new = object as? UartDaliDevice else { return false }
        return self.daliAddress == new.daliAddress && self.gatewayAddress == new.gatewayAddress
    }
}

// MARK: - Value Range

extension UartDaliDevice {
    
    // Level equals brightness
    
    public static let levelRange: ClosedRange<Int> = 1...254
    public static let cctRange: ClosedRange<Int> = 1000...10000
    
    public static let stateLevelRange: ClosedRange<Int> = 0...254
    public static let stateLevelMask: Int = 0xFF
    
    public static let stateXyRange: ClosedRange<Int> = 1...65534
    public static let stateXyMask: Int = 0xFFFF
    
    public static let stateCctRange: ClosedRange<Int> = 1000...10000
    public static let stateCctMask: Int = 0xFFFF
    
    public static let stateRgbwafRange: ClosedRange<Int> = 0...254
    public static let stateRgbwafMask: Int = 0xFF
    
    public static let fadeTimeRange: ClosedRange<Int> = 0...15
    public static let fadeRateRange: ClosedRange<Int> = 1...15
    
    public static func getConfigLevelRangeDetail(minLevel: Int, maxLevel: Int) -> String {
        var minValue = minLevel
        var maxValue = maxLevel
        if !Self.levelRange.contains(minLevel) {
            minValue = Self.levelRange.lowerBound
        }
        if !Self.levelRange.contains(maxLevel) {
            maxValue = Self.levelRange.upperBound
        }
        let minFloat = Float(minValue) * 100.0 / Float(Self.levelRange.upperBound)
        let maxFloat = Float(maxValue) * 100.0 / Float(Self.levelRange.upperBound)
        return String(format: "%.1f%%-%.1f%%", minFloat, maxFloat)
    }
    
    public static func getConfigCctRangeDetail(minCct: Int, maxCct: Int) -> String {
        return String(format: "%dK-%dK", minCct, maxCct)
    }
    
    public static func getConfigStateDetail(level: Int?) -> String? {
        if let value = level {
            if value == 0xFF {
                return "MASK"
            }
            let valueFloat = Float(value) * 100.0 / 254.0
            return String(format: "%.1f%%", valueFloat)
        }
        return nil
    }
    
    private static let fadeTimeValues: [Int: String] = [
        0: "Extended fade",
        1: "0.7",
        2: "1.0",
        3: "1.4",
        4: "2.0",
        5: "2.8",
        6: "4.0",
        7: "5.7",
        8: "8.0",
        9: "11.3",
        10: "16.0",
        11: "22.6",
        12: "32.0",
        13: "45.3",
        14: "64.0",
        15: "90.5"
    ]
    
    public static func getConfigFadeTimeDetail(at fadeTime: Int, unit: String) -> String {
        if fadeTime == 0 {
            return fadeTimeValues[fadeTime]!
        }
        if let value = fadeTimeValues[fadeTime] {
            return value + unit
        }
        return ""
    }
    
    private static let fadeRateValues: [Int: String] = [
        1: "358",
        2: "253",
        3: "179",
        4: "127",
        5: "89.4",
        6: "63.3",
        7: "44.7",
        8: "31.6",
        9: "22.4",
        10: "15.8",
        11: "11.2",
        12: "7.9",
        13: "5.6",
        14: "4.0",
        15: "2.8"
    ]
    
    public static func getConfigFadeRateDetail(at fadeRate: Int, unit: String) -> String {
        if let value = fadeRateValues[fadeRate] {
            return value + " \(unit)"
        }
        return ""
    }
    
}
