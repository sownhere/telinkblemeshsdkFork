//
//  File.swift
//  
//
//  Created by 王文东 on 2023/8/24.
//

import UIKit

public protocol UartDaliManagerDelegate: NSObjectProtocol {
    
    func uartDaliManager(_ manager: UartDaliManager, didExecuteCommandOK daliAddress: Int, gatewayAddress: Int, cmdType: UartDaliManager.ResponseCommandType, cmd: Any?)
    
    func uartDaliManager(_ manager: UartDaliManager, didExecuteCommandFailed daliAddress: Int, gatewayAddress: Int, reason: UartDaliManager.CommandFailedReason, cmdType: UartDaliManager.ResponseCommandType, cmd: Any?)
    
    func uartDaliManager(_ manager: UartDaliManager, didUpdateDeviceList devices: [UartDaliDevice], gatewayAddress: Int)
    
    func uartDaliManager(_ manager: UartDaliManager, didDiscoverEnd gatewayAddress: Int, reason: UartDaliManager.DiscoverEndReason)
    
    func uartDaliManager(_ manager: UartDaliManager, didGetDeviceGroups groups: [Int], gatewayAddress: Int, daliAddress: Int)
    
    func uartDaliManager(_ manager: UartDaliManager, didAddDeviceToGroup gatewayAddress: Int, daliAddress: Int)
    
    func uartDaliManager(_ manager: UartDaliManager, didRemoveDeviceFromGroup gatewayAddress: Int, daliAddress: Int)
    
    func uartDaliManager(_ manager: UartDaliManager, didGetDeviceSceneValue sceneValue: [String: Any], gatewayAddress: Int, daliAddress: Int)
    
    func uartDaliManager(_ manager: UartDaliManager, didUpdateDeviceSceneValue gatewayAddress: Int, daliAddress: Int)
    
    func uartDaliManager(_ manager: UartDaliManager, didGetDeviceActualDataPoints dataPoints: [String: Any], gatewayAddress: Int, daliAddress: Int)
    
    func uartDaliManager(_ manager: UartDaliManager, didGetDeviceConfigMinLevel minLevel: Int, gatewayAddress: Int, daliAddress: Int)
    
    func uartDaliManager(_ manager: UartDaliManager, didGetDeviceConfigMaxLevel maxLevel: Int, gatewayAddress: Int, daliAddress: Int)
    
    func uartDaliManager(_ manager: UartDaliManager, didGetDeviceConfigMinCct minCct: Int, gatewayAddress: Int, daliAddress: Int)
    
    func uartDaliManager(_ manager: UartDaliManager, didGetDeviceConfigMaxCct maxCct: Int, gatewayAddress: Int, daliAddress: Int)
    
    func uartDaliManager(_ manager: UartDaliManager, didGetDeviceConfigMinPhysicalCct minCct: Int, gatewayAddress: Int, daliAddress: Int)
    
    func uartDaliManager(_ manager: UartDaliManager, didGetDeviceConfigMaxPhysicalCct maxCct: Int, gatewayAddress: Int, daliAddress: Int)
    
    func uartDaliManager(_ manager: UartDaliManager, didGetDeviceConfigSystemFailureState dataPoints: [String: Any], gatewayAddress: Int, daliAddress: Int)
    
    func uartDaliManager(_ manager: UartDaliManager, didGetDeviceConfigPowerOnState dataPoints: [String: Any], gatewayAddress: Int, daliAddress: Int)
    
    func uartDaliManager(_ manager: UartDaliManager, didGetDeviceConfigFadeTime fadeTime: Int, fadeRate: Int, gatewayAddress: Int, daliAddress: Int)
}

extension UartDaliManagerDelegate {
    
    public func uartDaliManager(_ manager: UartDaliManager, didExecuteCommandOK daliAddress: Int, gatewayAddress: Int, cmdType: UartDaliManager.ResponseCommandType, cmd: Any?) {}
    
    public func uartDaliManager(_ manager: UartDaliManager, didExecuteCommandFailed daliAddress: Int, gatewayAddress: Int, reason: UartDaliManager.CommandFailedReason, cmdType: UartDaliManager.ResponseCommandType, cmd: Any?) {}
    
    public func uartDaliManager(_ manager: UartDaliManager, didUpdateDeviceList devices: [UartDaliDevice], gatewayAddress: Int) {}
    
    public func uartDaliManager(_ manager: UartDaliManager, didDiscoverEnd gatewayAddress: Int, reason: UartDaliManager.DiscoverEndReason) {}
    
    public func uartDaliManager(_ manager: UartDaliManager, didGetDeviceGroups groups: [Int], gatewayAddress: Int, daliAddress: Int) {}
    
    public func uartDaliManager(_ manager: UartDaliManager, didAddDeviceToGroup gatewayAddress: Int, daliAddress: Int) {}
    
    public func uartDaliManager(_ manager: UartDaliManager, didRemoveDeviceFromGroup gatewayAddress: Int, daliAddress: Int) {}
    
    public func uartDaliManager(_ manager: UartDaliManager, didGetDeviceSceneValue sceneValue: [String: Any], gatewayAddress: Int, daliAddress: Int) {}
    
    public func uartDaliManager(_ manager: UartDaliManager, didUpdateDeviceSceneValue gatewayAddress: Int, daliAddress: Int) {}
    
    public func uartDaliManager(_ manager: UartDaliManager, didGetDeviceActualDataPoints dataPoints: [String: Any], gatewayAddress: Int, daliAddress: Int) {}
    
    public func uartDaliManager(_ manager: UartDaliManager, didGetDeviceConfigMinLevel minLevel: Int, gatewayAddress: Int, daliAddress: Int) {}
    
    public func uartDaliManager(_ manager: UartDaliManager, didGetDeviceConfigMaxLevel maxLevel: Int, gatewayAddress: Int, daliAddress: Int) {}
    
    public func uartDaliManager(_ manager: UartDaliManager, didGetDeviceConfigMinCct minCct: Int, gatewayAddress: Int, daliAddress: Int) {}
    
    public func uartDaliManager(_ manager: UartDaliManager, didGetDeviceConfigMaxCct maxCct: Int, gatewayAddress: Int, daliAddress: Int) {}
    
    public func uartDaliManager(_ manager: UartDaliManager, didGetDeviceConfigMinPhysicalCct minCct: Int, gatewayAddress: Int, daliAddress: Int) {}
    
    public func uartDaliManager(_ manager: UartDaliManager, didGetDeviceConfigMaxPhysicalCct maxCct: Int, gatewayAddress: Int, daliAddress: Int) {}
    
    public func uartDaliManager(_ manager: UartDaliManager, didGetDeviceConfigSystemFailureState dataPoints: [String: Any], gatewayAddress: Int, daliAddress: Int) {}
    
    public func uartDaliManager(_ manager: UartDaliManager, didGetDeviceConfigPowerOnState dataPoints: [String: Any], gatewayAddress: Int, daliAddress: Int) {}
    
    public func uartDaliManager(_ manager: UartDaliManager, didGetDeviceConfigFadeTime fadeTime: Int, fadeRate: Int, gatewayAddress: Int, daliAddress: Int) {}
}

public protocol UartDaliManagerDataDelegate: NSObjectProtocol {
    
    func uartDaliManager(_ manager: UartDaliManager, didReceiveData data: Data)
}

public class UartDaliManager: NSObject {
    
    public weak var delegate: UartDaliManagerDelegate?
    
    public weak var dataDelegate: UartDaliManagerDataDelegate?
    
    public static let shared = UartDaliManager()
    
    // bleShortAddress: GatewayData
    private var uartGatewayDatas: [Int: GatewayData] = [:]
    
    private override init() {
        super.init()
        
    }
    
    // MARK: - Public Methods
    
    public func getExistDevices(_ gatewayAddress: Int) -> [UartDaliDevice] {
        return MeshDB.shared.selectUartDaliDevices(gatewayAddress)
    }
    
    /// Discover old devices, add new devices.
    public func discoverDevices(gatewayAddress: Int) {
        MeshDB.shared.deleteUartDaliDevices(gatewayAddress)
        
        // MeshCommand.UartDali.terminateDiscovering(gatewayAddress).send()
        MeshCommand.UartDali.discoverDevice(gatewayAddress, discover: .withoutShortAddressShallReact).send()
    }
    
    public func stopDiscoverDevices(gatewayAddress: Int) {
        MeshCommand.UartDali.terminateDiscovering(gatewayAddress).send()
    }
    
    public func resetDevice(_ device: UartDaliDevice) {
        MeshDB.shared.deleteUartDaliDevice(device.daliAddress, gatewayAddress: device.gatewayAddress)
        MeshCommand.UartDali.configDevice(device.gatewayAddress, daliAddr: UInt8(device.daliAddress), config: .reset).send()
    }
    
    public func resetAllDevices(gatewayAddress: Int) {
        MeshDB.shared.deleteUartDaliDevices(gatewayAddress)
        MeshCommand.UartDali.configDevice(gatewayAddress, daliAddr: 0xFF, config: .reset).send()
    }
    
    /// If you want to control a group, you need to set daliAddress as `groupId | 0x80`.
    /// If you want to control all devices, you need to set daliAddress as `0xFF`.
    public func updateDataPoints(gatewayAddress: Int, daliAddress: Int, dataPoints: [String: Any]) {
        
        if let isOn = dataPoints["ON_OFF"] as? Bool {
            if isOn {
                MeshCommand.UartDali.controlDevice(gatewayAddress, daliAddr: UInt8(daliAddress), control: .goToLastLevel).send()
            } else {
                MeshCommand.UartDali.controlDevice(gatewayAddress, daliAddr: UInt8(daliAddress), control: .off).send()
            }
        }
        
        if let level = dataPoints["BRIGHTNESS"] as? Int {
            MeshCommand.UartDali.controlDevice(gatewayAddress, daliAddr: UInt8(daliAddress), control: .directArcPowerControl, values: [UInt8(level)]).send()
        }
        
        if let cct = dataPoints["COLOR_TEMPERATURE"] as? Int {
            MeshCommand.UartDali.controlDevice(gatewayAddress, daliAddr: UInt8(daliAddress), control: .activateCct, values: [UInt8((cct >> 8) & 0xFF), UInt8(cct & 0xFF)]).send()
        }
        
        if let x = dataPoints["X"] as? Int, let y = dataPoints["Y"] as? Int {
            var values: [UInt8] = []
            values.append((UInt8(x >> 8) & 0xFF))
            values.append(UInt8(x & 0xFF))
            values.append((UInt8(y >> 8) & 0xFF))
            values.append(UInt8(y & 0xFF))
            MeshCommand.UartDali.controlDevice(gatewayAddress, daliAddr: UInt8(daliAddress), control: .activateXy, values: values).send()
        }
        
        if let red = dataPoints["RED"] as? Int,
           let green = dataPoints["GREEN"] as? Int,
           let blue = dataPoints["BLUE"] as? Int {
            
            let white = dataPoints["WHITE"] as? Int ?? 0xFF
            let amber = dataPoints["AMBER"] as? Int ?? 0xFF
            let values: [UInt8] = [UInt8(red), UInt8(green), UInt8(blue), UInt8(white), UInt8(amber), 0xFF]
            MeshCommand.UartDali.controlDevice(gatewayAddress, daliAddr: UInt8(daliAddress), control: .activateRgbwaf, values: values).send()
        }
    }
    
    public func getDeviceGroups(gatewayAddress: Int, daliAddress: Int, group: Int) {
        let query: MeshCommand.UartDali.Query = (0...7).contains(group) ? .groups0_7 : .groups8_15
        MeshCommand.UartDali.queryDevice(gatewayAddress, daliAddr: UInt8(daliAddress), query: query, values: []).send()
    }
    
    public func addDeviceToGroup(gatewayAddress: Int, daliAddress: Int, group: Int) {
        MeshCommand.UartDali.configDevice(gatewayAddress, daliAddr: UInt8(daliAddress), config: .addToGroup, values: [UInt8(group)]).send()
    }
    
    public func removeDeviceFromGroup(gatewayAddress: Int, daliAddress: Int, group: Int) {
        MeshCommand.UartDali.configDevice(gatewayAddress, daliAddr: UInt8(daliAddress), config: .removeFromGroup, values: [UInt8(group)]).send()
    }
    
    public func executeScene(gatewayAddress: Int, daliAddress: Int = 0xFF, scene: Int) {
        MeshCommand.UartDali.controlDevice(gatewayAddress, daliAddr: UInt8(daliAddress), control: .goToScene, values: [UInt8(scene)]).send()
    }
    
    public func getDeviceSceneValue(gatewayAddress: Int, daliAddress: Int, scene: Int) {
        MeshCommand.UartDali.queryDevice(gatewayAddress, daliAddr: UInt8(daliAddress), query: .sceneValue, values: [UInt8(scene)]).send()
    }
    
    public func setDeviceSceneValue(gatewayAddress: Int, daliAddress: Int, scene: Int, dataPoints: [String: Any], deviceType: UartDaliDevice.DeviceType) {
        switch deviceType {
        case .dt6:
            let brightness = dataPoints["BRIGHTNESS"] as? Int ?? 0xFF
            MeshCommand.UartDali.configDevice(gatewayAddress, daliAddr: UInt8(daliAddress), config: .setSceneDt6, values: [UInt8(scene), UInt8(brightness)]).send()
        case .dt8Cct:
            let brightness = dataPoints["BRIGHTNESS"] as? Int ?? 0xFF
            let cct = dataPoints["COLOR_TEMPERATURE"] as? Int ?? 0xFFFF
            let c0 = UInt8(cct >> 8 & 0xFF)
            let c1 = UInt8(cct & 0xFF)
            MeshCommand.UartDali.configDevice(gatewayAddress, daliAddr: UInt8(daliAddress), config: .setSceneDt8Cct, values: [UInt8(scene), UInt8(brightness), c0, c1]).send()
        case .dt8Xy:
            let brightness = dataPoints["BRIGHTNESS"] as? Int ?? 0xFF
            let x = dataPoints["X"] as? Int ?? 0xFFFF
            let y = dataPoints["Y"] as? Int ?? 0xFFFF
            let x0 = UInt8(x >> 8 & 0xFF)
            let x1 = UInt8(x & 0xFF)
            let y0 = UInt8(y >> 8 & 0xFF)
            let y1 = UInt8(y & 0xFF)
            MeshCommand.UartDali.configDevice(gatewayAddress, daliAddr: UInt8(daliAddress), config: .setSceneDt8Xy, values: [UInt8(scene), UInt8(brightness), x0, x1, y0, y1]).send()
        case .dt8Rgbw: fallthrough
        case .dt8Rgbwa:
            let brightness = dataPoints["BRIGHTNESS"] as? Int ?? 0xFF
            let red = dataPoints["RED"] as? Int ?? 0xFF
            let green = dataPoints["GREEN"] as? Int ?? 0xFF
            let blue = dataPoints["BLUE"] as? Int ?? 0xFF
            let white = dataPoints["WHITE"] as? Int ?? 0xFF
            let amber = dataPoints["AMBER"] as? Int ?? 0xFF
            MeshCommand.UartDali.setSceneDt8Rgb(gatewayAddress, daliAddr: UInt8(daliAddress), sceneId: UInt8(scene), values: [UInt8(brightness), UInt8(red), UInt8(green), UInt8(blue), UInt8(white), UInt8(amber), 0xFF]).send()
        }
    }
    
    public func getDeviceActualDataPoints(gatewayAddress: Int, daliAddress: Int) {
        MeshCommand.UartDali.queryDevice(gatewayAddress, daliAddr: UInt8(daliAddress), query: .actualLevel).send()
    }
    
}

// MARK: - Update Device

extension UartDaliManager {
    
    /// change success return true, the device doesn't exist return false.
    public func changeDeviceTypeManually(_ device: UartDaliDevice, newDeviceType: UartDaliDevice.DeviceType) -> Bool {
        device.deviceType = newDeviceType
        device.dataPoints = newDeviceType.defaultDataPoints
        return MeshDB.shared.updateUartDaliDevice(device)
    }
    
    /// add success return true, the device exists return false, you have to delete the device first.
    public func addNewDeviceManually(_ device: UartDaliDevice) -> Bool {
        return MeshDB.shared.insertUartDaliDevice(device)
    }
    
    public func deleteDeviceManually(_ device: UartDaliDevice) {
        MeshDB.shared.deleteUartDaliDevice(device.daliAddress, gatewayAddress: device.gatewayAddress)
    }
    
    public func deleteAllDevicesManually(gatewayAddress: Int) {
        MeshDB.shared.deleteUartDaliDevices(gatewayAddress)
    }
    
    // MARK: - Config
    
    /// Will send query minLevel and maxLevel
    public func getLevelRange(gatewayAddress: Int, daliAddress: Int) {
        MeshCommand.UartDali.queryDevice(gatewayAddress, daliAddr: UInt8(daliAddress), query: .minLevel).send()
        MeshCommand.UartDali.queryDevice(gatewayAddress, daliAddr: UInt8(daliAddress), query: .maxLevel).send()
    }
    
    public func getCctRange(gatewayAddress: Int, daliAddress: Int) {
        MeshCommand.UartDali.queryDevice(gatewayAddress, daliAddr: UInt8(daliAddress), query: .cctWarmest).send()
        MeshCommand.UartDali.queryDevice(gatewayAddress, daliAddr: UInt8(daliAddress), query: .cctCoolest).send()
    }
    
    public func getCctPhysicalRange(gatewayAddress: Int, daliAddress: Int) {
        MeshCommand.UartDali.queryDevice(gatewayAddress, daliAddr: UInt8(daliAddress), query: .physicalWarmest).send()
        MeshCommand.UartDali.queryDevice(gatewayAddress, daliAddr: UInt8(daliAddress), query: .physicalCoolest).send()
    }
    
    public func getSystemFailureState(gatewayAddress: Int, daliAddress: Int) {
        MeshCommand.UartDali.queryDevice(gatewayAddress, daliAddr: UInt8(daliAddress), query: .systemFailureLevel).send()
    }
    
    public func getPowerOnState(gatewayAddress: Int, daliAddress: Int) {
        MeshCommand.UartDali.queryDevice(gatewayAddress, daliAddr: UInt8(daliAddress), query: .powerOnLevel).send()
    }
    
    public func getFadeTimeAndFadeRate(gatewayAddress: Int, daliAddress: Int) {
        MeshCommand.UartDali.queryDevice(gatewayAddress, daliAddr: UInt8(daliAddress), query: .fadeTimeOrFadeRate).send()
    }
    
    public func setLevelRange(gatewayAddress: Int, daliAddress: Int, minValue: Int, maxValue: Int) {
        let minValues: [UInt8] = [UInt8(minValue)]
        let maxValues: [UInt8] = [UInt8(maxValue)]
        MeshCommand.UartDali.configDevice(gatewayAddress, daliAddr: UInt8(daliAddress), config: .setMin, values: minValues).send()
        MeshCommand.UartDali.configDevice(gatewayAddress, daliAddr: UInt8(daliAddress), config: .setMax, values: maxValues).send()
    }
    
    public func setCctRange(gatewayAddress: Int, daliAddress: Int, minValue: Int, maxValue: Int) {
        let minValues: [UInt8] = [UInt8(minValue >> 8), UInt8(minValue & 0xFF)]
        let maxValues: [UInt8] = [UInt8(maxValue >> 8), UInt8(maxValue & 0xFF)]
        MeshCommand.UartDali.configDevice(gatewayAddress, daliAddr: UInt8(daliAddress), config: .setCctWarmest, values: minValues).send()
        MeshCommand.UartDali.configDevice(gatewayAddress, daliAddr: UInt8(daliAddress), config: .setCctCoolest, values: maxValues).send()
    }
    
    public func setCctPhysicalRange(gatewayAddress: Int, daliAddress: Int, minValue: Int, maxValue: Int) {
        let minValues: [UInt8] = [UInt8(minValue >> 8), UInt8(minValue & 0xFF)]
        let maxValues: [UInt8] = [UInt8(maxValue >> 8), UInt8(maxValue & 0xFF)]
        MeshCommand.UartDali.configDevice(gatewayAddress, daliAddr: UInt8(daliAddress), config: .setCctPhysicalWarmest, values: minValues).send()
        MeshCommand.UartDali.configDevice(gatewayAddress, daliAddr: UInt8(daliAddress), config: .setCctPhysicalCoolest, values: maxValues).send()
    }
    
    public func setSystemFailureState(gatewayAddress: Int, daliAddress: Int, dataPoints: [String: Any], deviceType: UartDaliDevice.DeviceType) {
        switch deviceType {
        case .dt6:
            let brightness = dataPoints["BRIGHTNESS"] as? Int ?? 0xFF
            MeshCommand.UartDali.configDevice(gatewayAddress, daliAddr: UInt8(daliAddress), config: .setSystemFailDt6, values: [UInt8(brightness)]).send()
        case .dt8Cct:
            let brightness = dataPoints["BRIGHTNESS"] as? Int ?? 0xFF
            let cct = dataPoints["COLOR_TEMPERATURE"] as? Int ?? 0xFFFF
            let c0 = UInt8(cct >> 8 & 0xFF)
            let c1 = UInt8(cct & 0xFF)
            MeshCommand.UartDali.configDevice(gatewayAddress, daliAddr: UInt8(daliAddress), config: .setSystemFailDt8Cct, values: [UInt8(brightness), c0, c1]).send()
        case .dt8Xy:
            let brightness = dataPoints["BRIGHTNESS"] as? Int ?? 0xFF
            let x = dataPoints["X"] as? Int ?? 0xFFFF
            let y = dataPoints["Y"] as? Int ?? 0xFFFF
            let x0 = UInt8(x >> 8 & 0xFF)
            let x1 = UInt8(x & 0xFF)
            let y0 = UInt8(y >> 8 & 0xFF)
            let y1 = UInt8(y & 0xFF)
            MeshCommand.UartDali.configDevice(gatewayAddress, daliAddr: UInt8(daliAddress), config: .setSystemFailDt8Xy, values: [UInt8(brightness), x0, x1, y0, y1]).send()
        case .dt8Rgbw: fallthrough
        case .dt8Rgbwa:
            let brightness = dataPoints["BRIGHTNESS"] as? Int ?? 0xFF
            let red = dataPoints["RED"] as? Int ?? 0xFF
            let green = dataPoints["GREEN"] as? Int ?? 0xFF
            let blue = dataPoints["BLUE"] as? Int ?? 0xFF
            let white = dataPoints["WHITE"] as? Int ?? 0xFF
            let amber = dataPoints["AMBER"] as? Int ?? 0xFF
            MeshCommand.UartDali.setSystemFailDt8Rgb(gatewayAddress, daliAddr: UInt8(daliAddress), values: [UInt8(brightness), UInt8(red), UInt8(green), UInt8(blue), UInt8(white), UInt8(amber), 0xFF]).send()
        }
    }
    
    public func setPowerOnState(gatewayAddress: Int, daliAddress: Int, dataPoints: [String: Any], deviceType: UartDaliDevice.DeviceType) {
        switch deviceType {
        case .dt6:
            let brightness = dataPoints["BRIGHTNESS"] as? Int ?? 0xFF
            MeshCommand.UartDali.configDevice(gatewayAddress, daliAddr: UInt8(daliAddress), config: .setPowerOnDt6, values: [UInt8(brightness)]).send()
        case .dt8Cct:
            let brightness = dataPoints["BRIGHTNESS"] as? Int ?? 0xFF
            let cct = dataPoints["COLOR_TEMPERATURE"] as? Int ?? 0xFFFF
            let c0 = UInt8(cct >> 8 & 0xFF)
            let c1 = UInt8(cct & 0xFF)
            MeshCommand.UartDali.configDevice(gatewayAddress, daliAddr: UInt8(daliAddress), config: .setPowerOnDt8Cct, values: [UInt8(brightness), c0, c1]).send()
        case .dt8Xy:
            let brightness = dataPoints["BRIGHTNESS"] as? Int ?? 0xFF
            let x = dataPoints["X"] as? Int ?? 0xFFFF
            let y = dataPoints["Y"] as? Int ?? 0xFFFF
            let x0 = UInt8(x >> 8 & 0xFF)
            let x1 = UInt8(x & 0xFF)
            let y0 = UInt8(y >> 8 & 0xFF)
            let y1 = UInt8(y & 0xFF)
            MeshCommand.UartDali.configDevice(gatewayAddress, daliAddr: UInt8(daliAddress), config: .setPowerOnDt8Xy, values: [UInt8(brightness), x0, x1, y0, y1]).send()
        case .dt8Rgbw: fallthrough
        case .dt8Rgbwa:
            let brightness = dataPoints["BRIGHTNESS"] as? Int ?? 0xFF
            let red = dataPoints["RED"] as? Int ?? 0xFF
            let green = dataPoints["GREEN"] as? Int ?? 0xFF
            let blue = dataPoints["BLUE"] as? Int ?? 0xFF
            let white = dataPoints["WHITE"] as? Int ?? 0xFF
            let amber = dataPoints["AMBER"] as? Int ?? 0xFF
            MeshCommand.UartDali.setPowerOnDt8Rgb(gatewayAddress, daliAddr: UInt8(daliAddress), values: [UInt8(brightness), UInt8(red), UInt8(green), UInt8(blue), UInt8(white), UInt8(amber), 0xFF]).send()
        }
    }
    
    public func setFadeTime(gatewayAddress: Int, daliAddress: Int, value: Int) {
        MeshCommand.UartDali.configDevice(gatewayAddress, daliAddr: UInt8(daliAddress), config: .setFadeTime, values: [UInt8(value)]).send()
    }
    
    public func setFadeRate(gatewayAddress: Int, daliAddress: Int, value: Int) {
        MeshCommand.UartDali.configDevice(gatewayAddress, daliAddr: UInt8(daliAddress), config: .setFadeRate, values: [UInt8(value)]).send()
    }
    
}

// MARK: - Data Handler

extension UartDaliManager {
    
    struct GatewayData {
        
        enum ResponseTag: Int {
            
            case discoverDt6 = 0x5AA0
            case discoverDt8Xy = 0x5AA1
            case discoverDt8Cct = 0x5AA2
            case discoverDt8Rgb = 0x5AA3
            case discoverEnd = 0x5AAF
            
            case commandOK = 0x5A80
            case commandFailed = 0x5A81
            
            case commandFull = 0x5A8E
            case commandAllocWait = 0x5A8F
            
            case groups0_7 = 0x5A11
            case gropus8_15 = 0x5A12
            
            case sceneValueDt6 = 0x5A3C
            case sceneValueDt8Xy = 0x5A3D
            case sceneValueDt8Cct = 0x5A3E
            case sceneValueDt8Rgbwaf = 0x5A3F
            
            case queryStatus = 0x5A00
            case queryActualLevelDt6 = 0x5A30
            case queryActualLevelDt8Xy = 0x5A31
            case queryActualLevelDt8Cct = 0x5A32
            case queryActualLevelDt8Rgbwaf = 0x5A33
            
            case queryMinLevel = 0x5A0F
            case queryMaxLevel = 0x5A0E
            
            case queryMinCct = 0x5A18
            case queryMaxCct = 0x5A16
            
            case queryPhysicalMinCct = 0x5A19
            case queryPhysicalMaxCct = 0x5A17
            
            case querySystemFailureStateDt6 = 0x5A38
            case querySystemFailureStateDt8Xy = 0x5A39
            case querySystemFailureStateDt8Cct = 0x5A3A
            case querySystemFailureStateDt8Rgbwaf = 0x5A3B
            
            case queryPowerOnStateDt6 = 0x5A34
            case queryPowerOnStateDt8Xy = 0x5A35
            case queryPowerOnStateDt8Cct = 0x5A36
            case queryPowerOnStateDt8Rgbwaf = 0x5A37
            
            case queryFadeTimeAndFadeRate = 0x5A10
        }
        
        let bleShortAddress: Int
        let data: Data
        
        var dataString: String {
            return data.hex
        }
        
        var responseTagValue: Int {
            return Int(data[0]) << 8 | Int(data[1])
        }
        
        var isHeaderOK: Bool {
            return data[0] == 0x5A
        }
        
        var typeValue: UInt8 {
            return data[1]
        }
        
        var commandValue: UInt8 {
            return data[2]
        }
    }
    
    func receive(_ cmd: MeshCommand) {
        var data = cmd.userData
        data.insert(UInt8(cmd.param), at: 0)
        let gatewayData = GatewayData(bleShortAddress: Int(cmd.src), data: data)
        NSLog("uart data \(gatewayData.dataString)", "")
        dataDelegate?.uartDaliManager(self, didReceiveData: gatewayData.data)
        
        // If this is a wireless command, return.
        if handleWirelessCommand(cmd) {
            return
        }
        
        guard let responseTag = GatewayData.ResponseTag(rawValue: gatewayData.responseTagValue) else {
            NSLog("uart data no response tag \(gatewayData.responseTagValue)", "")
            return
        }
        NSLog("data tag \(responseTag)", "")
        let gwData = gatewayData.data
        let bleShortAddress = Int(cmd.src)
        
        switch responseTag {
        case .discoverDt6:
            didFoundDevice(daliAddress: Int(gwData[2]), gatewayAddress: bleShortAddress, deviceType: .dt6)
            
        case .discoverDt8Xy:
            didFoundDevice(daliAddress: Int(gwData[2]), gatewayAddress: bleShortAddress, deviceType: .dt8Xy)
            
        case .discoverDt8Cct:
            didFoundDevice(daliAddress: Int(gwData[2]), gatewayAddress: bleShortAddress, deviceType: .dt8Cct)
            
        case .discoverDt8Rgb:
            let deviceType: UartDaliDevice.DeviceType = gatewayData.data.last == 0xC0 ? .dt8Rgbwa : .dt8Rgbw
            didFoundDevice(daliAddress: Int(gwData[2]), gatewayAddress: bleShortAddress, deviceType: deviceType)
            
        case .discoverEnd:
            handleDiscoverEnd(gatewayAddress: bleShortAddress, reasonValue: gwData[2])
            
        case .commandOK:
            handleCommandOK(daliAddress: Int(gwData[2]), gatewayAddress: bleShortAddress, typeValue: gwData[3], cmdValue: gwData[4])
            
        case .commandFailed:
            handleCommandFailed(daliAddress: Int(gwData[2]), gatewayAddress: bleShortAddress, typeValue: gwData[3], cmdValue: gwData[4], reasonValue: gwData[5])
            
        case .commandFull:
            NSLog("command full", "")
            
        case .commandAllocWait:
            NSLog("command alloc wait", "")
            
        case .groups0_7:
            handleGroupsResponse0_7(daliAddress: Int(gwData[2]), gatewayAddress: bleShortAddress, value: Int(gwData[3]))
            
        case .gropus8_15:
            handleGroupsResponse8_15(daliAddress: Int(gwData[2]), gatewayAddress: bleShortAddress, value: Int(gwData[3]))
            
        case .sceneValueDt6:
            handleSceneValueDt6(daliAddress: Int(gwData[2]), gatewayAddress: bleShortAddress, data: gwData)
        case .sceneValueDt8Xy:
            handleSceneValueDt8Xy(daliAddress: Int(gwData[2]), gatewayAddress: bleShortAddress, data: gwData)
        case .sceneValueDt8Cct:
            handleSceneValueDt8Cct(daliAddress: Int(gwData[2]), gatewayAddress: bleShortAddress, data: gwData)
        case .sceneValueDt8Rgbwaf:
            handleSceneValueDt8Rgbwaf(daliAddress: Int(gwData[2]), gatewayAddress: bleShortAddress, data: gwData)
            
        case .queryStatus:
            handleQueryStatus(daliAddress: Int(gwData[2]), gatewayAddress: bleShortAddress, data: gwData)
            
        case .queryActualLevelDt6:
            handleQuertActualLevel(daliAddress: Int(gwData[2]), gatewayAddress: bleShortAddress, data: gwData, deviceType: .dt6)
        case .queryActualLevelDt8Xy:
            handleQuertActualLevel(daliAddress: Int(gwData[2]), gatewayAddress: bleShortAddress, data: gwData, deviceType: .dt8Xy)
        case .queryActualLevelDt8Cct:
            handleQuertActualLevel(daliAddress: Int(gwData[2]), gatewayAddress: bleShortAddress, data: gwData, deviceType: .dt8Cct)
        case .queryActualLevelDt8Rgbwaf:
            handleQuertActualLevel(daliAddress: Int(gwData[2]), gatewayAddress: bleShortAddress, data: gwData, deviceType: .dt8Rgbwa)
            
        case .queryMinLevel:
            handleQueryMinLevel(daliAddress: Int(gwData[2]), gatewayAddress: bleShortAddress, data: gwData)
        case .queryMaxLevel:
            handleQueryMaxLevel(daliAddress: Int(gwData[2]), gatewayAddress: bleShortAddress, data: gwData)
            
        case .queryMinCct:
            handleQueryMinCct(daliAddress: Int(gwData[2]), gatewayAddress: bleShortAddress, data: gwData)
        case .queryMaxCct:
            handleQueryMaxCct(daliAddress: Int(gwData[2]), gatewayAddress: bleShortAddress, data: gwData)
            
        case .queryPhysicalMinCct:
            handleQueryMinPhysicalCct(daliAddress: Int(gwData[2]), gatewayAddress: bleShortAddress, data: gwData)
        case .queryPhysicalMaxCct:
            handleQueryMaxPhysicalCct(daliAddress: Int(gwData[2]), gatewayAddress: bleShortAddress, data: gwData)
            
        case .querySystemFailureStateDt6: fallthrough
        case .querySystemFailureStateDt8Xy: fallthrough
        case .querySystemFailureStateDt8Cct: fallthrough
        case .querySystemFailureStateDt8Rgbwaf:
            handleQuerySystemFailureState(daliAddress: Int(gwData[2]), gatewayAddress: bleShortAddress, data: gwData)
            
        case .queryPowerOnStateDt6: fallthrough
        case .queryPowerOnStateDt8Xy: fallthrough
        case .queryPowerOnStateDt8Cct: fallthrough
        case .queryPowerOnStateDt8Rgbwaf:
            handleQueryPowerOnState(daliAddress: Int(gwData[2]), gatewayAddress: bleShortAddress, data: gwData)
            
        case .queryFadeTimeAndFadeRate:
            handleQueryFadeTimeAndFadeRate(daliAddress: Int(gwData[2]), gatewayAddress: bleShortAddress, data: gwData)
        }
    }
    
    private func didFoundDevice(daliAddress: Int, gatewayAddress: Int, deviceType: UartDaliDevice.DeviceType) {
        
        let device = UartDaliDevice(daliAddress: daliAddress, gatewayAddress: gatewayAddress, deviceType: deviceType)
        // If is new device
        _ = MeshDB.shared.insertOrUpdateUartDaliDevice(device)
        let devices = MeshDB.shared.selectUartDaliDevices(gatewayAddress)
        DispatchQueue.main.async {
            self.delegate?.uartDaliManager(self, didUpdateDeviceList: devices, gatewayAddress: gatewayAddress)
        }
    }
    
    private func handleDiscoverEnd(gatewayAddress: Int, reasonValue: UInt8) {
        if let reason = DiscoverEndReason(rawValue: reasonValue) {
            DispatchQueue.main.async {
                self.delegate?.uartDaliManager(self, didDiscoverEnd: gatewayAddress, reason: reason)
            }
        }
    }
    
    private func handleCommandOK(daliAddress: Int, gatewayAddress: Int, typeValue: UInt8, cmdValue: UInt8) {
        guard let type = ResponseCommandType(rawValue: typeValue) else {
            NSLog("command ok but type is nil \(typeValue)", "")
            return
        }
        var cmd: Any?
        switch type {
        case .config:
            cmd = MeshCommand.UartDali.Config(rawValue: cmdValue)
            
            if let configCmd = cmd as? MeshCommand.UartDali.Config {
                switch configCmd {
                case .addToGroup:
                    DispatchQueue.main.async {
                        self.delegate?.uartDaliManager(self, didAddDeviceToGroup: gatewayAddress, daliAddress: daliAddress)
                    }
                    
                case .removeFromGroup:
                    DispatchQueue.main.async {
                        self.delegate?.uartDaliManager(self, didRemoveDeviceFromGroup: gatewayAddress, daliAddress: daliAddress)
                    }
                    
                case .setSceneDt6: fallthrough
                case .setSceneDt8Xy: fallthrough
                case .setSceneDt8Cct:
                    DispatchQueue.main.async {
                        self.delegate?.uartDaliManager(self, didUpdateDeviceSceneValue: gatewayAddress, daliAddress: daliAddress)
                    }
                    
                default:
                    break
                }
            }
            
        case .control:
            cmd = MeshCommand.UartDali.Control(rawValue: cmdValue)
            
        case .query:
            cmd = MeshCommand.UartDali.Query(rawValue: cmdValue)
            
        case .dt8SetScene0: fallthrough
        case .dt8SetScene1: fallthrough
        case .dt8SetScene2: fallthrough
        case .dt8SetScene3: fallthrough
        case .dt8SetScene4: fallthrough
        case .dt8SetScene5: fallthrough
        case .dt8SetScene6: fallthrough
        case .dt8SetScene7: fallthrough
        case .dt8SetScene8: fallthrough
        case .dt8SetScene9: fallthrough
        case .dt8SetScene10: fallthrough
        case .dt8SetScene11: fallthrough
        case .dt8SetScene12: fallthrough
        case .dt8SetScene13: fallthrough
        case .dt8SetScene14: fallthrough
        case .dt8SetScene15:
            break
        }
        
        DispatchQueue.main.async {
            self.delegate?.uartDaliManager(self, didExecuteCommandOK: daliAddress, gatewayAddress: gatewayAddress, cmdType: type, cmd: cmd)
        }
    }
    
    private func handleCommandFailed(daliAddress: Int, gatewayAddress: Int, typeValue: UInt8, cmdValue: UInt8, reasonValue: UInt8) {
        guard let reason = CommandFailedReason(rawValue: reasonValue) else { return }
        guard let type = ResponseCommandType(rawValue: typeValue) else { return }
        var cmd: Any?
        switch type {
        case .config:
            cmd = MeshCommand.UartDali.Config(rawValue: cmdValue)
        case .control:
            cmd = MeshCommand.UartDali.Control(rawValue: cmdValue)
        case .query:
            cmd = MeshCommand.UartDali.Query(rawValue: cmdValue)
        case .dt8SetScene0: fallthrough
        case .dt8SetScene1: fallthrough
        case .dt8SetScene2: fallthrough
        case .dt8SetScene3: fallthrough
        case .dt8SetScene4: fallthrough
        case .dt8SetScene5: fallthrough
        case .dt8SetScene6: fallthrough
        case .dt8SetScene7: fallthrough
        case .dt8SetScene8: fallthrough
        case .dt8SetScene9: fallthrough
        case .dt8SetScene10: fallthrough
        case .dt8SetScene11: fallthrough
        case .dt8SetScene12: fallthrough
        case .dt8SetScene13: fallthrough
        case .dt8SetScene14: fallthrough
        case .dt8SetScene15:
            break 
        }
        DispatchQueue.main.async {
            self.delegate?.uartDaliManager(self, didExecuteCommandFailed: daliAddress, gatewayAddress: gatewayAddress, reason: reason, cmdType: type, cmd: cmd)
        }
    }
    
    private func handleGroupsResponse0_7(daliAddress: Int, gatewayAddress: Int, value: Int) {
        var groups: [Int] = []
        for i in 0...7 {
            if ((0x01 << i) & value) > 0 {
                groups.append(i)
            }
        }
        DispatchQueue.main.async {
            self.delegate?.uartDaliManager(self, didGetDeviceGroups: groups, gatewayAddress: gatewayAddress, daliAddress: daliAddress)
        }
    }
    
    private func handleGroupsResponse8_15(daliAddress: Int, gatewayAddress: Int, value: Int) {
        var groups: [Int] = []
        for i in 0...7 {
            if ((0x01 << i) & value) > 0 {
                groups.append(i + 8)
            }
        }
        DispatchQueue.main.async {
            self.delegate?.uartDaliManager(self, didGetDeviceGroups: groups, gatewayAddress: gatewayAddress, daliAddress: daliAddress)
        }
    }
    
    private func handleSceneValueDt6(daliAddress: Int, gatewayAddress: Int, data: Data) {
        let level = Int(data[3])
        let isOn = level > 0
        let value: [String: Any] = [
            "ON_OFF": isOn,
            "BRIGHTNESS": level
        ]
        DispatchQueue.main.async {
            self.delegate?.uartDaliManager(self, didGetDeviceSceneValue: value, gatewayAddress: gatewayAddress, daliAddress: daliAddress)
        }
    }
    
    private func handleSceneValueDt8Xy(daliAddress: Int, gatewayAddress: Int, data: Data) {
        let level = Int(data[3])
        let isOn = level > 0
        let x = (Int(data[4]) << 8) | Int(data[5])
        let y = (Int(data[6]) << 8) | Int(data[7])
        let value: [String: Any] = [
            "ON_OFF": isOn,
            "BRIGHTNESS": level,
            "X": x,
            "Y": y
        ]
        DispatchQueue.main.async {
            self.delegate?.uartDaliManager(self, didGetDeviceSceneValue: value, gatewayAddress: gatewayAddress, daliAddress: daliAddress)
        }
    }
    
    private func handleSceneValueDt8Cct(daliAddress: Int, gatewayAddress: Int, data: Data) {
        let level = Int(data[3])
        let isOn = level > 0
        let cct = (Int(data[4]) << 8) | Int(data[5])
        let value: [String: Any] = [
            "ON_OFF": isOn,
            "BRIGHTNESS": level,
            "COLOR_TEMPERATURE": cct
        ]
        DispatchQueue.main.async {
            self.delegate?.uartDaliManager(self, didGetDeviceSceneValue: value, gatewayAddress: gatewayAddress, daliAddress: daliAddress)
        }
    }
    
    private func handleSceneValueDt8Rgbwaf(daliAddress: Int, gatewayAddress: Int, data: Data) {
        let level = Int(data[3])
        let isOn = level > 0
        let r = Int(data[4])
        let g = Int(data[5])
        let b = Int(data[6])
        let w = Int(data[7])
        let a = Int(data[8])
        // let f = Int(data[9])
        let value: [String: Any] = [
            "ON_OFF": isOn,
            "BRIGHTNESS": level,
            "RED": r,
            "GREEN": g,
            "BLUE": b,
            "WHITE": w,
            "AMBER": a
        ]
        DispatchQueue.main.async {
            self.delegate?.uartDaliManager(self, didGetDeviceSceneValue: value, gatewayAddress: gatewayAddress, daliAddress: daliAddress)
        }
    }
    
    private func handleQueryStatus(daliAddress: Int, gatewayAddress: Int, data: Data) {
        let value = Int(data[3])
        let isControlGearFailure = (value & 0b0000_0001) > 0
        let isLampFailure = (value & 0b0000_0010) > 0
        let isLampOn = (value & 0b0000_0100) > 0
        let state: [String: Any] = [
            "ON_OFF": isLampOn,
            "LAMP_FAILURE": isLampFailure,
            "CONTROL_GEAR_FAILURE": isControlGearFailure,
        ]
        DispatchQueue.main.async {
            self.delegate?.uartDaliManager(self, didGetDeviceActualDataPoints: state, gatewayAddress: gatewayAddress, daliAddress: daliAddress)
        }
    }
    
    private func handleQuertActualLevel(daliAddress: Int, gatewayAddress: Int, data: Data, deviceType: UartDaliDevice.DeviceType) {
        let level = Int(data[3])
        let isOn = level != 0
        let isFailure = level == 0xFF
        var dataPoints: [String: Any] = [
            "LAMP_FAILURE": isFailure,
            "ON_OFF": isOn,
            "BRIGHTNESS": level,
            "DEVICE_TYPE": deviceType.rawValue
        ]
        
        switch deviceType {
        case .dt6:
            break
        case .dt8Cct:
            let c1 = Int(data[4])
            let c2 = Int(data[5])
            dataPoints["COLOR_TEMPERATURE"] = (c1 << 8) | c2
        case .dt8Xy:
            let x1 = Int(data[4])
            let x2 = Int(data[5])
            let y1 = Int(data[6])
            let y2 = Int(data[7])
            dataPoints["X"] = (x1 << 8) | x2
            dataPoints["Y"] = (y1 << 8) | y2
        case .dt8Rgbw: fallthrough
        case .dt8Rgbwa:
            // let f = Int(data[9])
            dataPoints["RED"] = Int(data[4])
            dataPoints["GREEN"] = Int(data[5])
            dataPoints["BLUE"] = Int(data[6])
            dataPoints["WHITE"] = Int(data[7])
            dataPoints["AMBER"] = Int(data[8])
        }
        DispatchQueue.main.async {
            self.delegate?.uartDaliManager(self, didGetDeviceActualDataPoints: dataPoints, gatewayAddress: gatewayAddress, daliAddress: daliAddress)
        }
    }
    
    private func handleQueryMinLevel(daliAddress: Int, gatewayAddress: Int, data: Data) {
        var level = Int(data[3])
        if !UartDaliDevice.levelRange.contains(level) {
            level = UartDaliDevice.levelRange.lowerBound
        }
        DispatchQueue.main.async {
            self.delegate?.uartDaliManager(self, didGetDeviceConfigMinLevel: level, gatewayAddress: gatewayAddress, daliAddress: daliAddress)
        }
    }
    
    private func handleQueryMaxLevel(daliAddress: Int, gatewayAddress: Int, data: Data) {
        var level = Int(data[3])
        if !UartDaliDevice.levelRange.contains(level) {
            level = UartDaliDevice.levelRange.upperBound
        }
        DispatchQueue.main.async {
            self.delegate?.uartDaliManager(self, didGetDeviceConfigMaxLevel: level, gatewayAddress: gatewayAddress, daliAddress: daliAddress)
        }
    }
    
    private func handleQueryMinCct(daliAddress: Int, gatewayAddress: Int, data: Data) {
        let c1 = Int(data[3]) << 8
        let c2 = Int(data[4])
        var cct = c1 | c2
        if !UartDaliDevice.cctRange.contains(cct) {
            cct = UartDaliDevice.cctRange.lowerBound
        }
        DispatchQueue.main.async {
            self.delegate?.uartDaliManager(self, didGetDeviceConfigMinCct: cct, gatewayAddress: gatewayAddress, daliAddress: daliAddress)
        }
    }
    
    private func handleQueryMaxCct(daliAddress: Int, gatewayAddress: Int, data: Data) {
        let c1 = Int(data[3]) << 8
        let c2 = Int(data[4])
        var cct = c1 | c2
        if !UartDaliDevice.cctRange.contains(cct) {
            cct = UartDaliDevice.cctRange.upperBound
        }
        DispatchQueue.main.async {
            self.delegate?.uartDaliManager(self, didGetDeviceConfigMaxCct: cct, gatewayAddress: gatewayAddress, daliAddress: daliAddress)
        }
    }
    
    private func handleQueryMinPhysicalCct(daliAddress: Int, gatewayAddress: Int, data: Data) {
        let c1 = Int(data[3]) << 8
        let c2 = Int(data[4])
        var cct = c1 | c2
        if !UartDaliDevice.cctRange.contains(cct) {
            cct = UartDaliDevice.cctRange.lowerBound
        }
        DispatchQueue.main.async {
            self.delegate?.uartDaliManager(self, didGetDeviceConfigMinPhysicalCct: cct, gatewayAddress: gatewayAddress, daliAddress: daliAddress)
        }
    }
    
    private func handleQueryMaxPhysicalCct(daliAddress: Int, gatewayAddress: Int, data: Data) {
        let c1 = Int(data[3]) << 8
        let c2 = Int(data[4])
        var cct = c1 | c2
        if !UartDaliDevice.cctRange.contains(cct) {
            cct = UartDaliDevice.cctRange.upperBound
        }
        DispatchQueue.main.async {
            self.delegate?.uartDaliManager(self, didGetDeviceConfigMaxPhysicalCct: cct, gatewayAddress: gatewayAddress, daliAddress: daliAddress)
        }
    }
    
    private func handleQuerySystemFailureState(daliAddress: Int, gatewayAddress: Int, data: Data) {
        let tag = data[1]
        var dataPoints: [String: Any] = [:]
        let level = Int(data[3])
        dataPoints["BRIGHTNESS"] = level
        
        switch tag {
        case 0x38: // dt6
            break
            
        case 0x39: // dt8 xy
            let x1 = Int(data[4]) << 8
            let x2 = Int(data[5])
            let x = x1 | x2
            let xMask = x == UartDaliDevice.stateXyMask
            let y1 = Int(data[6]) << 8
            let y2 = Int(data[7])
            let y = y1 | y2
            let yMask = y == UartDaliDevice.stateXyMask
            dataPoints["X"] = x
            dataPoints["Y"] = y
            dataPoints["X_MASK"] = xMask
            dataPoints["Y_MASK"] = yMask
            
        case 0x3A: // dt8 cct
            let c1 = Int(data[4]) << 8
            let c2 = Int(data[5])
            let cct = c1 | c2
            let cctMask = cct == UartDaliDevice.stateCctMask
            dataPoints["COLOR_TEMPERATURE"] = cct
            dataPoints["COLOR_TEMPERATURE_MASK"] = cctMask
            
        case 0x3B: // dt8 rgbwaf
            let red = Int(data[4])
            let green = Int(data[5])
            let blue = Int(data[6])
            let white = Int(data[7])
            let amber = Int(data[8])
            dataPoints["RED"] = red
            dataPoints["RED_MASK"] = red == UartDaliDevice.stateRgbwafMask
            dataPoints["GREEN"] = green
            dataPoints["GREEN_MASK"] = green == UartDaliDevice.stateRgbwafMask
            dataPoints["BLUE"] = blue
            dataPoints["BLUE_MASK"] = blue == UartDaliDevice.stateRgbwafMask
            dataPoints["WHITE"] = white
            dataPoints["WHITE_MASK"] = white == UartDaliDevice.stateRgbwafMask
            dataPoints["AMBER"] = amber
            dataPoints["AMBER_MASK"] = amber == UartDaliDevice.stateRgbwafMask
            
        default:
            break
        }
        
        DispatchQueue.main.async {
            self.delegate?.uartDaliManager(self, didGetDeviceConfigSystemFailureState: dataPoints, gatewayAddress: gatewayAddress, daliAddress: daliAddress)
        }
    }
    
    private func handleQueryPowerOnState(daliAddress: Int, gatewayAddress: Int, data: Data) {
        let tag = data[1]
        var dataPoints: [String: Any] = [:]
        let level = Int(data[3])
        dataPoints["BRIGHTNESS"] = level
        
        switch tag {
        case 0x34: // dt6
            break
            
        case 0x35: // dt8 xy
            let x1 = Int(data[4]) << 8
            let x2 = Int(data[5])
            let x = x1 | x2
            let xMask = x == UartDaliDevice.stateXyMask
            let y1 = Int(data[6]) << 8
            let y2 = Int(data[7])
            let y = y1 | y2
            let yMask = y == UartDaliDevice.stateXyMask
            dataPoints["X"] = x
            dataPoints["Y"] = y
            dataPoints["X_MASK"] = xMask
            dataPoints["Y_MASK"] = yMask
            
        case 0x36: // dt8 cct
            let c1 = Int(data[4]) << 8
            let c2 = Int(data[5])
            let cct = c1 | c2
            let cctMask = cct == UartDaliDevice.stateCctMask
            dataPoints["COLOR_TEMPERATURE"] = cct
            dataPoints["COLOR_TEMPERATURE_MASK"] = cctMask
            
        case 0x37: // dt8 rgbwaf
            let red = Int(data[4])
            let green = Int(data[5])
            let blue = Int(data[6])
            let white = Int(data[7])
            let amber = Int(data[8])
            dataPoints["RED"] = red
            dataPoints["RED_MASK"] = red == UartDaliDevice.stateRgbwafMask
            dataPoints["GREEN"] = green
            dataPoints["GREEN_MASK"] = green == UartDaliDevice.stateRgbwafMask
            dataPoints["BLUE"] = blue
            dataPoints["BLUE_MASK"] = blue == UartDaliDevice.stateRgbwafMask
            dataPoints["WHITE"] = white
            dataPoints["WHITE_MASK"] = white == UartDaliDevice.stateRgbwafMask
            dataPoints["AMBER"] = amber
            dataPoints["AMBER_MASK"] = amber == UartDaliDevice.stateRgbwafMask
            
        default:
            break
        }
        
        DispatchQueue.main.async {
            self.delegate?.uartDaliManager(self, didGetDeviceConfigPowerOnState: dataPoints, gatewayAddress: gatewayAddress, daliAddress: daliAddress)
        }
    }
    
    private func handleQueryFadeTimeAndFadeRate(daliAddress: Int, gatewayAddress: Int, data: Data) {
        let value = Int(data[3])
        let fadeTime = (value >> 4) & 0x0F
        let fadeRate = value & 0x0F
        DispatchQueue.main.async {
            self.delegate?.uartDaliManager(self, didGetDeviceConfigFadeTime: fadeTime, fadeRate: fadeRate, gatewayAddress: gatewayAddress, daliAddress: daliAddress)
        }
    }
    
}

extension UartDaliManager {
    
    public enum CommandFailedReason: UInt8 {
        case paramsOutOfRange = 1
        case queryNoAnswer = 2
        case wrongCommand = 3
    }
    
    public enum DiscoverEndReason: UInt8 {
        case auto = 0x00
        case manual = 0x01
        case assignAddressError = 0x02
    }
    
    public enum ResponseCommandType: UInt8 {
        case config = 0x01
        case control = 0x02
        case query = 0x03
        
        case dt8SetScene0 = 0x40
        case dt8SetScene1 = 0x41
        case dt8SetScene2 = 0x42
        case dt8SetScene3 = 0x43
        case dt8SetScene4 = 0x44
        case dt8SetScene5 = 0x45
        case dt8SetScene6 = 0x46
        case dt8SetScene7 = 0x47
        case dt8SetScene8 = 0x48
        case dt8SetScene9 = 0x49
        case dt8SetScene10 = 0x4A
        case dt8SetScene11 = 0x4B
        case dt8SetScene12 = 0x4C
        case dt8SetScene13 = 0x4D
        case dt8SetScene14 = 0x4E
        case dt8SetScene15 = 0x4F
    }
}

extension UartDaliManager {
    
    /// If this is a wireless command, return true, otherwise return false.
    private func handleWirelessCommand(_ cmd: MeshCommand) -> Bool {
        guard cmd.tag == .nodeToApp, cmd.vendorID == 0x1102 else {
            return false
        }
        let data = cmd.userData
        let tag = Int(data[0])
        switch tag {
        case 0x72: // Smart switches response
            let count = Int(data[1])
            let index = Int(data[2])
            let value0 = Int(data[6]) << 24
            let value1 = Int(data[5]) << 16
            let value2 = Int(data[4]) << 8
            let value3 = Int(data[3])
            let smartSwitchId = value0 | value1 | value2 | value3
            let hexStrig = String(smartSwitchId, radix: 16)
            NSLog("DALI smart switches count \(count), index \(index), ID \(hexStrig)", "")
            return true
            
        default:
            return false
        }
    }
    
}
