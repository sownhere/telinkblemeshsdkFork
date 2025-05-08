//
//  File.swift
//  
//
//  Created by 王文东 on 2023/5/17.
//

import Foundation

extension MeshCommand {
    
    public struct NaturalLight {
        
        public enum Mode: UInt8 {
            case mode1 = 1
            case mode2 = 2
            case mode3 = 3
            case mode4 = 4
        }
        
        public enum Template {
            case standard
            case office
            case healthCare
        }
        
        public struct Item {
            /**
             hour range [0, 23]
             */
            public var hour: UInt8 = 0
            /**
             minute range [0, 59]
             */
            public let minute: UInt8 = 0
            /**
             brightness range [0, 100]
             */
            public var brightness: UInt8 = 100
            /**
             cct range [0, 100]
             */
            public var cct: UInt8 = 45
            
            public var kelvin: Int {
                get {
                    NaturalLight.getKelvinFromCct(cct)
                }
                set {
                    cct = NaturalLight.getCctFromKelvin(newValue)
                }
            }
            
        }
        
        public var items: [Item] = []
        
        public init() {
            
        }
        
        public static let CT_KELVIN_VALUES: [UInt8: Int] = [
            100: 2000,
            90: 2500,
            80: 3000,
            70: 3500,
            60: 4000,
            45: 4500,
            30: 5000,
            20: 5500,
            10: 6000,
            0: 6500
        ]
        
        public static let KELVIN_CT_VALUES: [Int: UInt8] = {
            var values: [Int: UInt8] = [:]
            CT_KELVIN_VALUES.forEach { key, value in
                values[value] = key
            }
            return values
        }()
        
        /**
         ct: 0, 10, 20, 30, 45, 60, 70, 80, 90, 100.
         
         If cct is out of range, will return 4500K.
         */
        public static func getKelvinFromCct(_ cct: UInt8) -> Int {
            return CT_KELVIN_VALUES[cct] ?? 4500
        }
        
        /**
         kelvin: 2000, 2500, 3000, 3500, 4000, 4500, 5000, 5500, 6000, 6500
         
         If kelvin is out of range, will return 45.
         */
        public static func getCctFromKelvin(_ kelvin: Int) -> UInt8 {
            return KELVIN_CT_VALUES[kelvin] ?? 45
        }
        
        public static func makeTemplateNaturalLight(_ template: Template) -> NaturalLight {
            var naturalLight = NaturalLight()
            var kelvins: [Int] = []
            var bris: [UInt8] = []
            switch template {
            case .standard:
                kelvins = [
                    2000, 2000, 2500, 2500,
                    3000, 3000, 3500, 3500,
                    4000, 4500, 5000, 5500,
                    6000, 6500, 6000, 5500,
                    5000, 4500, 4000, 3500,
                    3000, 2500, 2000, 2000
                ]
                bris = [
                    5, 5, 10, 10,
                    10, 10, 25, 25,
                    25, 75, 75, 100,
                    100, 100, 100, 100,
                    75, 75, 25, 25,
                    10, 10, 5, 5
                ]
            case .office:
                kelvins = [
                    4500, 4500, 4500, 4500,
                    4500, 4500, 4500, 5000,
                    5000, 5500, 6000, 6000,
                    6000, 5500, 5500, 5000,
                    5000, 5000, 5000, 4500,
                    4500, 4500, 4500, 4500
                ]
                bris = [
                    10, 10, 10, 10,
                    10, 10, 10, 100,
                    100, 100, 100, 100,
                    100, 100, 100, 100,
                    100, 100, 100, 100,
                    100, 100, 10, 10
                ]
            case .healthCare:
                kelvins = [
                    2500, 2500, 2500, 2500,
                    2500, 2500, 2500, 2500,
                    2500, 3500, 4500, 4500,
                    5000, 5500, 5500, 5000,
                    5000, 4500, 4500, 4000,
                    3000, 2500, 2500, 2500
                ]
                bris = [
                    10, 10, 10, 10,
                    10, 10, 10, 10,
                    10, 50, 75, 90,
                    100, 100, 100, 90,
                    80, 70, 60, 50,
                    20, 10, 10, 10
                ]
            }
            for hour in 0...23 {
                var item = Item()
                item.hour = UInt8(hour)
                item.kelvin = kelvins[hour]
                item.brightness = bris[hour]
                naturalLight.items.append(item)
            }
            return naturalLight
        }
    }
    
}

extension MeshCommand {
    
    static func setNaturalLight(_ address: Int, naturalLight: NaturalLight, mode: NaturalLight.Mode) -> [MeshCommand] {
        var dynamicControl = MeshCommand.DynamicControl()
        dynamicControl.index = mode.rawValue
        for item in naturalLight.items {
            var dcItem = DynamicControl.Item()
            dcItem.hour = item.hour
            dcItem.brightness = item.brightness
            dcItem.whiteOrCt = item.cct
            dcItem.red = 0
            dcItem.green = 0
            dcItem.blue = 0
            dcItem.whiteOrCtEnabled = true
            dynamicControl.items.append(dcItem)
        }
        return setDynamicControl(address, dynamicControl: dynamicControl)
    }
    
    /**
     item index range [1, 24]
     */
    static func getNaturalLight(_ address: Int, mode: NaturalLight.Mode, hour: UInt8) -> MeshCommand {
        return getDynamicControl(address, dynamicControlIndex: mode.rawValue, itemIndex: hour + 1)
    }
    
    public static func enableNaturalLight(_ address: Int, mode: NaturalLight.Mode) -> MeshCommand {
        return enableDynamicControl(address, dynamicControlIndex: mode.rawValue, repeatCount: 0x00)
    }
    
    public static func disableNaturalLight(_ address: Int) -> MeshCommand {
        return disableDynamicControl(address)
    }
    
    public static func resetNaturalLight(_ address: Int) -> MeshCommand {
        return resetDynamicControl(address)
    }
    
    static func getNaturalLightCurrentState(_ address: Int) -> MeshCommand {
        return getDynamicControlCurrentState(address)
    }
}
