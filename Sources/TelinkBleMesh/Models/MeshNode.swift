//
//  File.swift
//  
//
//  Created by maginawin on 2021/1/13.
//

import Foundation
import CoreBluetooth

public struct MeshUUID {
    
    public static let accessService = "00010203-0405-0607-0809-0A0B0C0D1910"
    
    
    public static let notifyCharacteristic = "00010203-0405-0607-0809-0A0B0C0D1911"
    
    public static let commandCharacteristic = "00010203-0405-0607-0809-0A0B0C0D1912"
    
    public static let pairingCharacteristic = "00010203-0405-0607-0809-0A0B0C0D1914"
    
    public static let otaCharacteristic = "00010203-0405-0607-0809-0A0B0C0D1913"
    
    
//    public static let deviceInformationService = UUID(uuidString: "0000180a-0000-1000-8000-00805f9b34fb")!
    public static let deviceInformationService = "180A"
    
//    public static let firmwareCharacteristic = UUID(uuidString: "00002a26-0000-1000-8000-00805f9b34fb")!
    public static let firmwareCharacteristic = "2A26"
    
    static func uuidDescription(_ uuidString: String) -> String {
        
        switch uuidString {
        
        case accessService:
            return "accessService"
        
        case notifyCharacteristic:
            return "notifyCharacteristic"
            
        case commandCharacteristic:
            return "commandCharacteristic"
            
        case pairingCharacteristic:
            return "pairingCharacteristic"
            
        case otaCharacteristic:
            return "otaCharacteristic"
            
        case deviceInformationService:
            return "deviceInformationService"
            
        case firmwareCharacteristic:
            return "firmwareCharacteristic"
            
        default:
            return "unknown \(uuidString)"
        }
    }
    
    static func uuidDescription(_ uuid: UUID) -> String {
        
        return uuidDescription(uuid.uuidString)
    }
    
    static func uuidDescription(_ uuid: CBUUID) -> String {
        
        return uuidDescription(uuid.uuidString)
    }
    
}

public enum RssiLevel {
    case excellent
    case good
    case fair
    case poor
    case none
    
    public static func getRssiLevel(_ rssi: Int) -> RssiLevel {
        if (rssi >= -50 && rssi < 0) {
            return .excellent
        } else if (rssi >= -65 && rssi < -50) {
            return .good
        } else if (rssi >= -75 && rssi < -65) {
            return .fair
        } else if (rssi >= -90 && rssi < -75) {
            return .poor
        } else {
            return .none
        }
    }
}

public class MeshNode: NSObject {
    
    public internal(set) var peripheral: CBPeripheral
    
    public internal(set) var name = "nil"
    
    public internal(set) var manufacturerId: UInt16 = 0
    
    public internal(set) var meshUUID: UInt16 = 0
    
    public internal(set) var macValue: UInt32 = 0
    
    public internal(set) var macAddress = "nil"
    
    public internal(set) var productUUID: UInt16 = 0
    
    public internal(set) var productId: UInt16 = 0
    
    public var shortAddress: UInt16 = 0
    
    public internal(set) var rssi: Int = 0
    
    public internal(set) var deviceType: MeshDeviceType
    
    /**
     设备是否处于被发现状态。
     只有连按两下设备上面的按钮，该设备的 isDiscovering 才会是 true，否则为 false。默认为 false。
     */
    public internal(set) var isDiscovering: Bool = false
    
    init?(_ peripheral: CBPeripheral, advertisementData: [String: Any], rssi: Int) {
        
        self.peripheral = peripheral
        
        guard let name = advertisementData["kCBAdvDataLocalName"] as? String else {
            return nil
        }
        self.name = name
        
        guard let manufacturerData = advertisementData["kCBAdvDataManufacturerData"] as? Data,
              manufacturerData.count > 17 else {
            return nil
        }
        
        MLog("manufacturerData \(manufacturerData.hexString)")
        
        let manufacturerId = manufacturerData[0...1].uint16Value
        guard manufacturerId == 0x1102 else { return nil }
        
        self.manufacturerId = manufacturerId
        self.meshUUID = manufacturerData[2...3].uint16Value
        let macData = Data(manufacturerData[4...7].reversed())
        self.macValue = macData.uint32Value
        self.macAddress = macData.hexString
        self.productUUID = manufacturerData[8...9].uint16Value
        self.shortAddress = Data(manufacturerData[11...12].reversed()).uint16Value
        self.rssi = rssi
                
        guard self.productUUID == 0x1102 else {
            return nil
        }
        
        self.shortAddress = UInt16(manufacturerData[17])
        let productIdData = manufacturerData[14...15]
        self.productId = productIdData.uint16Value
        
        self.deviceType = MeshDeviceType(deviceType: UInt8((productId >> 8) & 0xFF), subDeviceType: UInt8(productId & 0xFF))
        
        let tag = Int(manufacturerData[2]) << 8 | Int(manufacturerData[3])
        self.isDiscovering = tag == 0x1803
        
        MLog("productId \(productIdData.hexString), shortAddress \(shortAddress), isDiscovering \(self.isDiscovering) tag \(tag.hex)")
    }
    
}

extension MeshNode {
    
    public override func isEqual(_ object: Any?) -> Bool {
        
        guard let other = object as? MeshNode else {
            return false
        }
        return other.macValue == self.macValue
    }
}
