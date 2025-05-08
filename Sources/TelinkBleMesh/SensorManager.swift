//
//  File.swift
//  
//
//  Created by 王文东 on 2024/5/7.
//

import Foundation
import CoreBluetooth

public protocol SensorManagerDelegate: NSObjectProtocol {
    @available(*, deprecated, message: "use `didDiscoverSingleSensor` instand of it")
    func sensorManager(_ manager: SensorManager, didDiscover sensor: MeshNode)
    
    func sensorManager(_ manager: SensorManager, didDiscoverUniversalRemote universalRemote: MeshNode)
    func sensorManager(_ manager: SensorManager, didDiscoverSingleSensor sensor: MeshNode, sensorType: MeshCommand.SingleSensorAction.SensorType?)
}

extension SensorManagerDelegate {
    public func sensorManager(_ manager: SensorManager, didDiscover sensor: MeshNode) {}
    public func sensorManager(_ manager: SensorManager, didDiscoverUniversalRemote universalRemote: MeshNode) {}
    public func sensorManager(_ manager: SensorManager, didDiscoverSingleSensor sensor: MeshNode, sensorType: MeshCommand.SingleSensorAction.SensorType?) {}
}

public class SensorManager: NSObject {
    
    public static let shared = SensorManager()
    public var delegate: SensorManagerDelegate?
    
    private var centralManager: CBCentralManager!
    private var network = MeshNetwork.factory
    
    private override init() {
        super.init()
        
        let options: [String: Any] = [
            CBCentralManagerOptionShowPowerAlertKey: false
        ]
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue(label: "SensorManagerCentralManager"), options: options)
    }
    
    public func scanSensor() {
        let options: [String: Any] = [
            CBCentralManagerScanOptionAllowDuplicatesKey: true
        ]
        
        centralManager.scanForPeripherals(withServices: nil, options: options)
    }
    
    public func stopScan() {
        MLog("SensorManager stopScan")
        if isBluetoothPowerOn() {
            centralManager.stopScan()
        }
    }
    
    private func isBluetoothPowerOn() -> Bool {
        return centralManager.state == .poweredOn
    }
    
}

extension SensorManager: CBCentralManagerDelegate {
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let meshNode = MeshNode(peripheral, advertisementData: advertisementData, rssi: RSSI.intValue) else {
            return
        }
        if meshNode.deviceType.category == .sensor {
            DispatchQueue.main.async {
                self.delegate?.sensorManager(self, didDiscover: meshNode)
                var sensorType: MeshCommand.SingleSensorAction.SensorType?
                switch meshNode.deviceType.rawValue2 {
                case 0x01:
                    sensorType = .doorContactSensor
                case 0x02:
                    sensorType = .waterLeakSensor
                default:
                    break
                }
                self.delegate?.sensorManager(self, didDiscoverSingleSensor: meshNode, sensorType: sensorType)
            }
            MLog("didDiscover sensor \(meshNode.macAddress)")
        } else if meshNode.deviceType.category == .universalRemote {
            DispatchQueue.main.async {
                self.delegate?.sensorManager(self, didDiscoverUniversalRemote: meshNode)
            }
            MLog("didDiscover universal remote \(meshNode.macAddress)")
        }
    }
    
}
