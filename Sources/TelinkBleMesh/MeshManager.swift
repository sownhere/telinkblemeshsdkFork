//
//  File.swift
//  
//
//  Created by maginawin on 2021/1/13.
//

import Foundation
import CoreBluetooth
import CryptoAction

@objc public protocol MeshManagerNodeDelegate: NSObjectProtocol {
    
    @objc optional func meshManager(_ manager: MeshManager, didDiscoverNode node: MeshNode)
    
    @objc optional func meshManager(_ manager: MeshManager, didConnectNode node: MeshNode)
    
    @objc optional func meshManager(_ manager: MeshManager, didDisconnectNodeIdentifier identifier: UUID)
    
    @objc optional func meshManager(_ manager: MeshManager, didFailToConnectNodeIdentifier identifier: UUID)
    
    @objc optional func meshManager(_ manager: MeshManager, didLoginNode node: MeshNode)
    
    @objc optional func meshManager(_ manager: MeshManager, didFailToLoginNodeIdentifier identifier: UUID)
    
    @available(*, deprecated, message: "use `meshManagerDidUpdateState` instand of it")
    @objc optional func meshManagerNeedTurnOnBluetooth(_ manager: MeshManager)
    
    @available(iOS 10.0, *)
    @objc optional func meshManagerDidUpdateState(_ manager: MeshManager, state: CBManagerState)
    
    @objc optional func meshManager(_ manager: MeshManager, didGetDeviceAddress address: Int)
    
    @objc optional func meshManager(_ manager: MeshManager, didConfirmNewNetwork isSuccess: Bool)
    
    @objc optional func meshManager(_ manager: MeshManager, didGetFirmware firmware: String, node: MeshNode)
    
}

public protocol MeshManagerNodeRssiDelegate: NSObjectProtocol {
    func meshManager(_ manager: MeshManager, didDiscoverNode node: MeshNode, rssiLevel: RssiLevel)
}

extension MeshManagerNodeRssiDelegate {
    public func meshManager(_ manager: MeshManager, didDiscoverNode node: MeshNode, rssiLevel: RssiLevel) {}
}

public protocol MeshManagerDeviceDelegate: NSObjectProtocol {
    
    func meshManager(_ manager: MeshManager, didUpdateMeshDevices meshDevices: [MeshDevice])
    
    func meshManager(_ manager: MeshManager, device address:Int, didUpdateDeviceType deviceType: MeshDeviceType, macData: Data)
    
    func meshManager(_ manager: MeshManager, device address: Int, didGetDate date: Date)
    
    func meshManager(_ manager: MeshManager, device address: Int, didGetLightGammaCurve gamma: MeshCommand.LightGamma)
    
    func meshManager(_ manager: MeshManager, device address: Int, didGetLightOnOffDuration duration: Int)
    
    func meshManager(_ manager: MeshManager, device address: Int, didGetFirmwareVersion version: String)
    
    func meshManager(_ manager: MeshManager, device address: Int, didGetLightRunningMode mode: MeshCommand.LightRunningMode)
    
    func meshManager(_ manager: MeshManager, device address: Int, didGetLightRunningModeIdList idList: [Int])
    
    func meshManager(_ manager: MeshManager, device address: Int, didGetLightRunningModeId modeId: Int, colorsCount: Int, colorIndex: Int, color: MeshCommand.LightRunningMode.Color)
    
    func meshManager(_ manager: MeshManager, device address: Int, didGetGroups groups: [Int])
    
    func meshManager(_ manager: MeshManager, didGetDeviceAddress address: Int)
    
    func meshManager(_ manager: MeshManager, device address: Int, didGetLightSwitchType switchType: MeshCommand.LightSwitchType)
    
    func meshManager(_ manager: MeshManager, device address: Int, didGetLightPwmFrequency frequency: Int)
    
    func meshManager(_ manager: MeshManager, device address: Int, didGetRgbIndependence isEnabled: Bool)
    
    /// Timezone information (`isNegative`, `hour`, `minute`).
    func meshManager(_ manager: MeshManager, device address: Int, didGetTimezone isNegative: Bool, hour: Int, minute: Int, sunriseHour: Int, sunriseMinute: Int, sunsetHour: Int, sunsetMinute: Int)
    
    func meshManager(_ manager: MeshManager, device address: Int, didGetLocation longitude: Float, latitude: Float)
    
    func meshManager(_ manager: MeshManager, device address: Int, didGetSunriseSunsetAction action: SunriseSunsetAction)
    
    func meshManager(_ manager: MeshManager, device address: Int, didGetScene scene: MeshCommand.Scene)
    
    func meshManager(_ manager: MeshManager, device address: Int, didGetAlarm alarm: AlarmProtocol)
    
    func meshManager(_ manager: MeshManager, device address: Int, didGetRemoteGroups groups: [Int], isLeading: Bool)
    
    func meshManager(_ manager: MeshManager, device address: Int, didGetGroupSyncTag tag: MeshCommand.GroupSyncTag, group: Int)
    
    func meshManager(_ manager: MeshManager, device address: Int, didGetSmartSwitchId switchId: Int?, index: Int, count: Int)
    
    func meshManager(_ manager: MeshManager, device address: Int, didSensorReport value: [MeshCommand.SensorReportKey: Any])
    
    func meshManager(_ manager: MeshManager, device address: Int, didGetSensorAttribute value: [MeshCommand.SensorAttributeType: Any])
    
    func meshManager(_ manager: MeshManager, device address: Int, didGetSensorEvent event: MeshCommand.SensorEvent, action: MeshCommand.SensorAction)
    
    /**
     * red [0, 255], green [0, 255], blue [0, 255], brightness[ 0, 100], white [0, 255], cct [0, 100].
     *
     * Note: If brightness equals 0 that means the device is turned off.
     *
     * let whitePercentage = round(float(white) / 2.55))
     */
//    func meshManager(_ manager: MeshManager, device address: Int, didRespondStatusRed red: Int, green: Int, blue: Int, whiteOrCct: Int, brightness: Int)
    func meshManager(_ manager: MeshManager, device address: Int, didRespondStatusRed red: Int, green: Int, blue: Int, white: Int, cct: Int,  brightness: Int, isOn: Bool, reserved1: Int, reserved2: Int)
    
    func meshManager(_ manager: MeshManager, device address: Int, didGetSensorId sensorId: Int, sensorTypeValue: Int)
    
    func meshManager(_ manager: MeshManager, device address: Int, didGetPowerOnState level: Int)
    
    //
    func meshManager(_ manager: MeshManager, device address: Int, didGetUniversalRemoteId remoteId: String, remoteIndex: MeshCommand.UniversalRemoteIndex)
    
    func meshManager(_ manager: MeshManager, device address: Int, didGetUniversalRemoteShortLongAction shortAction: MeshCommand.UniversalRemoteAction, longAction: MeshCommand.UniversalRemoteAction, remoteIndex: MeshCommand.UniversalRemoteIndex)
    
    func meshManager(_ manager: MeshManager, device address: Int, didGetUniversalRemoteRotationAction rotationAction: MeshCommand.UniversalRemoteAction, remoteIndex: MeshCommand.UniversalRemoteIndex)
    
    /// sensorType: [DoorSensor, WaterLeak, Unknown]
    func meshManager(_ manager: MeshManager, device address: Int, didGetManualLinkedSensor sensorId: Int, sensorType: String, isLinked: Bool)
    
}

extension MeshManagerDeviceDelegate {
    
    public func meshManager(_ manager: MeshManager, didUpdateMeshDevices meshDevices: [MeshDevice]) {}
    
    public func meshManager(_ manager: MeshManager, device address:Int, didUpdateDeviceType deviceType: MeshDeviceType, macData: Data) {}
    
    public func meshManager(_ manager: MeshManager, device address: Int, didGetDate date: Date) {}
    
    public func meshManager(_ manager: MeshManager, device address: Int, didGetLightGammaCurve gamma: MeshCommand.LightGamma) {}
    
    public func meshManager(_ manager: MeshManager, device address: Int, didGetLightOnOffDuration duration: Int) {}
    
    public func meshManager(_ manager: MeshManager, device address: Int, didGetFirmwareVersion version: String) {}
    
    public func meshManager(_ manager: MeshManager, device address: Int, didGetLightRunningMode mode: MeshCommand.LightRunningMode) {}
    
    public func meshManager(_ manager: MeshManager, device address: Int, didGetLightRunningModeIdList idList: [Int]) {}
    
    public func meshManager(_ manager: MeshManager, device address: Int, didGetLightRunningModeId modeId: Int, colorsCount: Int, colorIndex: Int, color: MeshCommand.LightRunningMode.Color) {}
    
    public func meshManager(_ manager: MeshManager, device address: Int, didGetGroups groups: [Int]) {}
    
    public func meshManager(_ manager: MeshManager, didGetDeviceAddress address: Int) {}
    
    public func meshManager(_ manager: MeshManager, device address: Int, didGetLightSwitchType switchType: MeshCommand.LightSwitchType) {}
    
    public func meshManager(_ manager: MeshManager, device address: Int, didGetLightPwmFrequency frequency: Int) {}
    
    public func meshManager(_ manager: MeshManager, device address: Int, didGetRgbIndependence isEnabled: Bool) {}
    
    public func meshManager(_ manager: MeshManager, device address: Int, didGetTimezone isNegative: Bool, hour: Int, minute: Int, sunriseHour: Int, sunriseMinute: Int, sunsetHour: Int, sunsetMinute: Int) {}
    
    public func meshManager(_ manager: MeshManager, device address: Int, didGetLocation longitude: Float, latitude: Float) {}
    
    public func meshManager(_ manager: MeshManager, device address: Int, didGetSunriseSunsetAction action: SunriseSunsetAction) {}
    
    public func meshManager(_ manager: MeshManager, device address: Int, didGetScene scene: MeshCommand.Scene) {}
    
    public func meshManager(_ manager: MeshManager, device address: Int, didGetAlarm alarm: AlarmProtocol) {}
    
    public func meshManager(_ manager: MeshManager, device address: Int, didGetRemoteGroups groups: [Int], isLeading: Bool) {}
    
    public func meshManager(_ manager: MeshManager, device address: Int, didGetGroupSyncTag tag: MeshCommand.GroupSyncTag, group: Int) {}
    
    public func meshManager(_ manager: MeshManager, device address: Int, didGetSmartSwitchId switchId: Int?, index: Int, count: Int) {}
    
    public func meshManager(_ manager: MeshManager, device address: Int, didSensorReport value: [MeshCommand.SensorReportKey: Any]) {}
    
    public func meshManager(_ manager: MeshManager, device address: Int, didGetSensorAttribute value: [MeshCommand.SensorAttributeType: Any]) {}
    
    public func meshManager(_ manager: MeshManager, device address: Int, didGetSensorEvent event: MeshCommand.SensorEvent, action: MeshCommand.SensorAction) {}
    
//    public func meshManager(_ manager: MeshManager, device address: Int, didRespondStatusRed red: Int, green: Int, blue: Int, whiteOrCct: Int, brightness: Int) {}
    public func meshManager(_ manager: MeshManager, device address: Int, didRespondStatusRed red: Int, green: Int, blue: Int, white: Int, cct: Int,  brightness: Int, isOn: Bool, reserved1: Int, reserved2: Int) {}
    
    public func meshManager(_ manager: MeshManager, device address: Int, didGetSensorId sensorId: Int, sensorTypeValue: Int) {}
    
    public func meshManager(_ manager: MeshManager, device address: Int, didGetPowerOnState level: Int) {}
    
    public func meshManager(_ manager: MeshManager, device address: Int, didGetUniversalRemoteId remoteId: String, remoteIndex: MeshCommand.UniversalRemoteIndex) {}
    
    public func meshManager(_ manager: MeshManager, device address: Int, didGetUniversalRemoteShortLongAction shortAction: MeshCommand.UniversalRemoteAction, longAction: MeshCommand.UniversalRemoteAction, remoteIndex: MeshCommand.UniversalRemoteIndex) {}
    
    public func meshManager(_ manager: MeshManager, device address: Int, didGetUniversalRemoteRotationAction rotationAction: MeshCommand.UniversalRemoteAction, remoteIndex: MeshCommand.UniversalRemoteIndex) {}
    
    public func meshManager(_ manager: MeshManager, device address: Int, didGetManualLinkedSensor sensorId: Int, sensorType: String, isLinked: Bool) {}
    
}

public protocol MeshManagerMultiSensorDelegate: NSObjectProtocol {
    func meshManager(_ manager: MeshManager, device address: Int, didGetMultiSensorId sensorId: Int, sensorIndex: Int)
    func meshMnaager(_ manager: MeshManager, device address: Int, didGetMultiSensorAction action: MeshCommand.MultiSensorAction)
}

extension MeshManagerMultiSensorDelegate {
    public func meshManager(_ manager: MeshManager, device address: Int, didGetMultiSensorId sensorId: Int, sensorIndex: Int) {}
    public func meshMnaager(_ manager: MeshManager, device address: Int, didGetMultiSensorAction action: MeshCommand.MultiSensorAction) {}
}

public protocol MeshManagerSingleSensorDelegate: NSObjectProtocol {
    func meshManager(_ manager: MeshManager, device address: Int, didGetSingleSensorId sensorId: Int, sensorType: MeshCommand.SingleSensorAction.SensorType)
    func meshManager(_ manager: MeshManager, device address: Int, didGetSingleSensorAction action: MeshCommand.SingleSensorAction)
}

extension MeshManagerSingleSensorDelegate {
    public func meshManager(_ manager: MeshManager, device address: Int, didGetSingleSensorId sensorId: Int, sensorType: MeshCommand.SingleSensorAction.SensorType) {}
    public func meshManager(_ manager: MeshManager, device address: Int, didGetSingleSensorAction action: MeshCommand.SingleSensorAction)  {}
}

public protocol MeshManagerDeviceEventDelegate: NSObjectProtocol {
    
    func meshManager(_ manager: MeshManager, didUpdateEvent event: MqttDeviceEventProtocol)
    
}

public class MeshManager: NSObject {
    
    public static let shared = MeshManager()
    
    public weak var nodeDelegate: MeshManagerNodeDelegate?
    
    /// If you want to monitor RSSI levels of the node you need to set this delegate.
    public weak var nodeRssiDelegate: MeshManagerNodeRssiDelegate?
    
    public weak var deviceDelegate: MeshManagerDeviceDelegate?
    
    public weak var deviceEventDelegate: MeshManagerDeviceEventDelegate?
    
    public weak var multiSensorDelegate: MeshManagerMultiSensorDelegate?
    
    public weak var singleSensorDelegate: MeshManagerSingleSensorDelegate?
    
    /**
     The default is `true`.
     */
    public var isDebugEnabled: Bool = true
    
    /**
     Current network. The default is `MeshNetwork.factory`.
     */
    public internal(set) var network = MeshNetwork.factory
    
    public private(set) var isLogin = false
    
    
    private var centralManager: CBCentralManager!
    private let serialQueue = DispatchQueue(label: "MeshManager serial")
    private let serialQueueKey = DispatchSpecificKey<Void>()
    private let concurrentQueue = DispatchQueue(label: "MeshManager concurrent", qos: .default, attributes: .concurrent)
    private let concurrentQueueKey = DispatchSpecificKey<Void>()
    
    private var isAutoLogin: Bool = false
    private var isScanIgnoreName: Bool = false
    
    public private(set) var connectNode: MeshNode?
    
    private var notifyCharacteristic: CBCharacteristic?
    private var commandCharacteristic: CBCharacteristic?
    private var pairingCharacteristic: CBCharacteristic?
    private var otaCharacteristic: CBCharacteristic?
    private var firmwareCharacteristic: CBCharacteristic?
    
    // Crypto
    private let loginRand = UnsafeMutablePointer<UInt8>.allocate(capacity: 8)
    private var sectionKey = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
    
    // 200ms every command
    internal private(set) var sendingTimeInterval: TimeInterval = 0.5
    private let sendingQueue = DispatchQueue(label: "MeshManager sending")
    private let sendingQueueKey = DispatchSpecificKey<Void>()
    
    private var setNetworkState: SetNetworkState = .none
    
    private var uartDaliGatewayAddress: Int = 0xFF
    
    private let rssiTimerInterval: TimeInterval = 2.0
    private let rssiMaxTimerInterval: TimeInterval = 5.0
    private var rssiTimer: Timer?
    // [node.mac: [node: MeshNode, date: DateTimeInterval]]
    private var rssiDetectedTimeCache: [String: [String: Any]] = [:]
    
    override private init() {
        super.init()
        
        serialQueue.setSpecific(key: serialQueueKey, value: ())
        concurrentQueue.setSpecific(key: concurrentQueueKey, value: ())
        
        executeSerialAsyncTask {
            
            let options: [String: Any] = [
                CBCentralManagerOptionShowPowerAlertKey: false
            ]
            self.centralManager = CBCentralManager(delegate: self, queue: DispatchQueue(label: "centralManager"), options: options)
            
            _ = SensorManager.shared
            MLog("init centralManager")
            Thread.sleep(forTimeInterval: 1)
        }
        
    }
    
}

// MARK: - Public

extension MeshManager {
    
    /**
     Scan nodes.
     
     - Parameters:
        - network: Scanning `MeshNetwork`.
        - autoLogin: Auto connect and login the node with `network` if `autoLogin` equals `true`. The default is `false`.
        - ignoreName: Scan all nodes if `ignoreName` is equals `true`. The default is false.
     */
    public func scanNode(_ network: MeshNetwork, autoLogin: Bool = false, ignoreName: Bool = false) {
        
        executeSerialAsyncTask {
            
            self.network = network
            
            self.isAutoLogin = autoLogin
            self.isScanIgnoreName = ignoreName
            
            self.stopScanNode()
            self.disconnect(autoLogin: self.isAutoLogin)
            
            MLog("scanNodeTask network \(network.name), password \(network.password), autoLogin " + (autoLogin ? "true" : "false"))
            guard self.isBluetoothPowerOn() else { return }
            
            let options: [String: Any] = [
                CBCentralManagerScanOptionAllowDuplicatesKey: true
            ]
            self.startRssiTimer()
            self.centralManager.scanForPeripherals(withServices: nil, options: options)
        }
    }
    
    /**
     Stop scan node.
     */
    public func stopScanNode() {
        
        executeSerialAsyncTask {
            
            self.stopRssiTimer()
            
            MLog("stopScanNode")
            guard self.isBluetoothPowerOn() else { return }
            self.centralManager.stopScan()
        }
    }
    
    /**
     Stop scan node, disconnect, then connect the `node`. If the state of node is connected or connecting, trigger the `self.delegate.meshManager(_, didConnect:)` then `return`.
     
     - Parameter node: Connecting `MeshNode`.
     */
    public func connect(_ node: MeshNode) {
        
        MeshEntertainmentManager.shared.stop()
        
        executeSerialAsyncTask {
            
            self.updateSendingTimeInterval(node)
            SampleCommandCenter.shared.removeAll()
            
            self.setNetworkState = .none
            
            MLog("connect")
            guard self.isBluetoothPowerOn() else { return }
            
            self.stopScanNode()
            self.disconnect(autoLogin: self.isAutoLogin)
            
            self.connectNode = node
            let options: [String: Any] = [
                CBConnectPeripheralOptionNotifyOnDisconnectionKey: false
            ]
            self.centralManager.connect(node.peripheral, options: options)
        }
    }
    
    /**
     Disconnect all nodes and set `isAutoLogin` to `false`.
     */
    public func disconnect() {

        disconnect(autoLogin: false)
    }
    
    private func disconnect(autoLogin: Bool) {
        
        MeshEntertainmentManager.shared.stop()
        
        executeSerialAsyncTask {
            
            SampleCommandCenter.shared.removeAll()
            
            self.isAutoLogin = autoLogin
            self.isLogin = false
            
            self.connectNode = nil
            self.pairingCharacteristic = nil
            self.notifyCharacteristic = nil
            self.commandCharacteristic = nil
            self.otaCharacteristic = nil
            
            MLog("disconnect autoLogin: \(autoLogin)")
            guard self.isBluetoothPowerOn() else { return }
            
            let accessServiceUUID = CBUUID(string: MeshUUID.accessService)
            let peripherals = self.centralManager.retrieveConnectedPeripherals(withServices: [accessServiceUUID])
            peripherals.forEach {
                
                if $0.state == .connected || $0.state == .connecting {
                    
                    self.centralManager.cancelPeripheralConnection($0)
                }
            }
            
            Thread.sleep(forTimeInterval: 1.0)
        }
    }
    
    public var isConnected: Bool {
        
        return connectNode?.peripheral.state == .connected
    }
    
    /**
     Scan `MeshDevice` after login success.
     */
    public func scanMeshDevices() {
        
        executeSendingAsyncTask {
            
            MLog("scanMeshDevice")
            guard self.isBluetoothPowerOn() else { return }
            
            guard self.isConnected,
                  let notifyCharacteristic = self.notifyCharacteristic else {
                
                return
            }
            
            let data = Data([0x01])
            self.connectNode?.peripheral.writeValue(data, for: notifyCharacteristic, type: .withResponse)
            Thread.sleep(forTimeInterval: self.sendingTimeInterval)
        }
    }
    
    private enum SetNetworkState {
        
        case none
        case processing
    }
    
    public var centralManagerState: CBManagerState? {
        
        if centralManager == nil { return nil }
        return centralManager.state
    }
    
    /**
     Send command to the connected node.
     
     - Parameters:
        - command: Sending command.
        - isSample: The defualt is `false`.
     */
    public func send(_ command: MeshCommand, isSample: Bool = false) {
        
        if isSample {
            
            SampleCommandCenter.shared.append(command)
            return
        }
        
        executeSendingAsyncTask {
            
            MLog("send command isSample \(isSample)")
            guard self.isBluetoothPowerOn() else { return }
            
            guard self.isConnected,
                  let commandCharacteristic = self.commandCharacteristic,
                  let macValue = self.connectNode?.macValue else {
                
                return
            }
            
            let commandData = command.commandData
            guard let data = CryptoAction.exeCMD(commandData, mac: macValue, sectionKey: self.sectionKey) else {
                
                return
            }
            MLog("Will send data \(commandData.hexString)")
            self.connectNode?.peripheral.writeValue(data, for: commandCharacteristic, type: .withoutResponse)
        }        
    }
    
    public func sendCommands(_ commands: [MeshCommand], intervalSeconds: TimeInterval = 1.0) {
        
        executeSendingAsyncTask {
            
            guard self.isBluetoothPowerOn() else { return }
            
            guard self.isConnected,
                  let commandCharacteristic = self.commandCharacteristic,
                  let macValue = self.connectNode?.macValue else {
                
                return
            }
            
            for command in commands {
                
                let commandData = command.commandData
                guard let data = CryptoAction.exeCMD(commandData, mac: macValue, sectionKey: self.sectionKey) else {
                    
                    return
                }
                MLog("Will send data \(commandData.hexString)")
                self.connectNode?.peripheral.writeValue(data, for: commandCharacteristic, type: .withoutResponse)
                Thread.sleep(forTimeInterval: intervalSeconds)
            }
        }
    }
    
    public func removeAllSendingCache() {
        SampleCommandCenter.shared.removeAll()
    }
    
    public func sendMqttMessage(_ message: String, isSample: Bool = false) {
        
        guard let mqttCommand = MqttCommand.makeCommandWithMqttMessage(message) else {
            
            MLog("send mqtt message failed, wrong message \(message)")
            return
        }
        
        MLog("Will send mqtt message \(message)")
        
        switch mqttCommand.commandType {
        
        case .command:
            
            if let command = MeshCommand(mqttCommandData: mqttCommand.data) {
                
                send(command, isSample: isSample)
            }
            
        case .scanMeshDevices:            
            scanMeshDevices()
        }
    }
    
    public func setUartDaliGateway(address: Int) {
        uartDaliGatewayAddress = address
    }
    
    public func resetUartDaliGateway() {
        uartDaliGatewayAddress = 0xFF
    }
    
    public func updateMqttSensorEvent(sensorAddress: Int, event: String) {
        if (event.count != 10) {
            return;
        }
        let eventBytes = event.hexData
        if (eventBytes.count != 5) {
            return;
        }
        let reportHeader = eventBytes[0]
        if (reportHeader != 0x05) { return; }
        
        let type = eventBytes[1]
        guard let reportType = MeshCommand.SensorReportType(rawValue: type) else {
            return
        }
        
        var value: [MeshCommand.SensorReportKey: Any] = [:]        
        switch reportType {
        case .reserved:
            MLog("Reserved")
            
        case .doorState:
            let isOpen = eventBytes[2] == 0x01
            value[.doorState] = isOpen
            
        case .pirMotion:
            let isDetected = eventBytes[2] == 0x01
            value[.isDetected] = isDetected
            
        case .microwareMotion:
            let isDetected = eventBytes[2] == 0x01
            value[.isDetected] = isDetected
            
            let low = Int(eventBytes[3])
            let high = Int(eventBytes[4]) << 8
            let lux = low | high
            value[.lux] = lux
            
        case .lux:
            let low = Int(eventBytes[2])
            let high = Int(eventBytes[3]) << 8
            let lux = low | high
            value[.lux] = lux
            
            let isDetected = eventBytes[4] == 0x01
            value[.isDetected] = isDetected
            
        case .temperature:
            let temp = Int(eventBytes[2])
            value[.temperature] = temp
        }
        
        MLog("Sensor Report \(reportType), value \(value)")
        DispatchQueue.main.async {
            self.deviceDelegate?.meshManager(self, device: sensorAddress, didSensorReport: value)
        }
    }
    
}

// MARK: - Interval

extension MeshManager {
    
    /**
     Set new network for the devices in the current network.
     
     - Parameters:
        - network: The new network.
     */
    func setNewNetwork(_ network: MeshNetwork, isMesh: Bool) {
        
        executeSerialAsyncTask {
            
            self.setNetworkState = .processing
            
            MLog("setNewNetwork \(network.name), \(network.password)")
            guard self.isBluetoothPowerOn() else { return }
            
            /*
             let nameData = CryptoAction.getNetworkName(network.name, sectionKey: self.sectionKey),
             let passwordData = CryptoAction.getNetworkPassword(network.password, sectionKey: self.sectionKey),
             let ltkData = CryptoAction.getNetworkLtk(self.sectionKey, isMesh: isMesh)
             */
            
            guard self.isConnected,
                  let peripheral = self.connectNode?.peripheral,
                  let pairingCharacteristic = self.pairingCharacteristic else {
                
                return
            }
            
            guard let networkDatas = CryptoAction.getNetworkInfo(network.name, password: network.password, sectionKey: self.sectionKey) else { return }
            
            let nameData = networkDatas[0]
            let passwordData = networkDatas[1]
            let ltkData = networkDatas[2]            
            
            MLog("datas " + nameData.hexString + ", " + passwordData.hexString + ", " + ltkData.hexString);
            
            peripheral.writeValue(nameData, for: pairingCharacteristic, type: .withResponse)
            Thread.sleep(forTimeInterval: 0.05)
            
            peripheral.writeValue(passwordData, for: pairingCharacteristic, type: .withResponse)
            Thread.sleep(forTimeInterval: 0.05)
            
            peripheral.writeValue(ltkData, for: pairingCharacteristic, type: .withResponse)
            Thread.sleep(forTimeInterval: 0.05)
            
            peripheral.readValue(for: pairingCharacteristic)
        }
    }
    
    public func readFirmwareWithConnectNode() {
        
        guard self.isLogin else {
            return
        }
        
        executeSendingAsyncTask {
            
            Thread.sleep(forTimeInterval: 3)
            
            guard let firmwareCharacteristic = self.firmwareCharacteristic else { return }
            
            self.connectNode?.peripheral.readValue(for: firmwareCharacteristic)
        }
    }
    
    func writeOtaData(_ data: Data) -> Bool {
        
        guard isLogin, let otaCharacteristic = self.otaCharacteristic else {
            return false
        }
        
        self.connectNode?.peripheral.writeValue(data, for: otaCharacteristic, type: .withoutResponse)
        return true
    }
    
}

// MARK: - CBCentralManagerDelegate

extension MeshManager: CBCentralManagerDelegate {
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        MLog("centralManagerDidUpdateState \(central.state)")
        
        self.isLogin = false 
        
        DispatchQueue.main.async {
            
            if #available(iOS 10.0, *) {
                
                self.nodeDelegate?.meshManagerDidUpdateState?(self, state: central.state)
            }
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        executeSerialAsyncTask {
            
            guard let name = advertisementData["kCBAdvDataLocalName"] as? String else { return }
            
            guard self.network.name == name || self.isScanIgnoreName else { return }
            
            MLog("centralManager did discover peripheral \(name), data \(advertisementData), rssi \(RSSI.intValue)")
            
            guard let meshNode = MeshNode(peripheral, advertisementData: advertisementData, rssi: RSSI.intValue) else {
                
                return
            }
            
            DispatchQueue.main.async {
                self.detectNodeRssi(meshNode)
            }
            
            guard RSSI.intValue <= 0 && RSSI.intValue >= -75 else { return }
            
            if self.isAutoLogin
                && self.network.name == name
                && self.connectNode == nil
                && meshNode.deviceType.isSafeConntion {
                
                self.connect(meshNode)
            }
            
            DispatchQueue.main.async {
                
                self.nodeDelegate?.meshManager?(self, didDiscoverNode: meshNode)
            }
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        MLog("centralManager didConnect")
        
        MeshEntertainmentManager.shared.stop()
        
        DispatchQueue.main.async {
            
            guard let node = self.connectNode, node.peripheral.identifier == peripheral.identifier else {
                return
            }
            
            self.nodeDelegate?.meshManager?(self, didConnectNode: node)
        }
        
        executeSerialAsyncTask {
            
            self.stopScanNode()
            
            peripheral.delegate = self
            peripheral.discoverServices(nil)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
        MLog("centralManager didFailToConnect")
        _ = MErrorNotNil(error)
        
        self.connectNode = nil
        
        DispatchQueue.main.async {
            
            if self.isAutoLogin {
                
                self.scanNode(self.network, autoLogin: self.isAutoLogin, ignoreName: self.isScanIgnoreName)
            }
            
            self.nodeDelegate?.meshManager?(self, didFailToConnectNodeIdentifier: peripheral.identifier)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        MLog("centralManager didDisconnectPeripheral " + (error?.localizedDescription ?? "error nil"))
        
        MeshEntertainmentManager.shared.stop()
        
        self.connectNode = nil
        self.isLogin = false
        
        DispatchQueue.main.async {
            
            if self.isAutoLogin {
                
                self.scanNode(self.network, autoLogin: self.isAutoLogin, ignoreName: self.isScanIgnoreName)
            }
            
            self.nodeDelegate?.meshManager?(self, didDisconnectNodeIdentifier: peripheral.identifier)
        }
    }
    
}

// MARK: - CBPeripheralDelegate

extension MeshManager: CBPeripheralDelegate {
    
    public func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        
        let name = peripheral.name ?? "nil"
        MLog("peripheralDidUpdateName \(name)")
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        MLog("peripheral didDiscoverServices " + "\(peripheral.services?.count ?? 0)")
        if MErrorNotNil(error) {
            return
        }
        
        executeSerialAsyncTask {
            
            peripheral.services?.forEach {
                
                peripheral.discoverCharacteristics(nil, for: $0)
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        MLog("peripheral didDiscoverCharacteristicsFor \(MeshUUID.uuidDescription(service.uuid)) \(service.characteristics?.count ?? 0)")
        if MErrorNotNil(error) {
            return
        }
        
        guard let characteristics = service.characteristics else { return }
        executeSerialAsyncTask {
            
            characteristics.forEach {
                
                MLog("characteristic \($0.uuid.uuidString)")
                
                switch $0.uuid.uuidString {
                
                case MeshUUID.notifyCharacteristic:
                    
                    self.notifyCharacteristic = $0
                    peripheral.setNotifyValue(true, for: $0)
                    
                case MeshUUID.commandCharacteristic:
                    
                    self.commandCharacteristic = $0
                    
                case MeshUUID.pairingCharacteristic:
                    
                    self.pairingCharacteristic = $0
                    
                    CryptoAction.getRandPro(self.loginRand, len: 8)
                    
                    let pResult = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
                    CryptoAction.encryptPair(self.network.name, pas: self.network.password, prand: self.loginRand, pResult: pResult)
                    let raw = UnsafeRawPointer(pResult)
                    var data = Data(bytes: raw, count: 16)
                    data.insert(12, at: 0)
                    pResult.deallocate()
                    
                    peripheral.writeValue(data, for: $0, type: .withResponse)
                    
                case MeshUUID.otaCharacteristic:
                    
                    self.otaCharacteristic = $0
                    
                case MeshUUID.firmwareCharacteristic:
                    
                    self.firmwareCharacteristic = $0
                
                default:
                    break
                }
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
        MLog("peripheral didWriteValueFor \(MeshUUID.uuidDescription(characteristic.uuid))")
        if MErrorNotNil(error) {
            MLog("peripheral didWriteValueFor \(MeshUUID.uuidDescription(characteristic.uuid)) error " + (error?.localizedDescription ?? ""))
            return
        }
        
        executeSerialAsyncTask {
                        
            if (MeshUUID.pairingCharacteristic == characteristic.uuid.uuidString) {
                
                if self.setNetworkState == .processing {
                    
                    return
                }
                
                peripheral.readValue(for: characteristic)
            }
        }
        
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        guard let value = characteristic.value, value.count > 0 else {
            MLog("peripheral didUpdateValue nil, return")
            return
        }
        
        MLog("peripheral didUpdateValue, \n=> \(value.hexString) \(MeshUUID.uuidDescription(characteristic.uuid))")
        if MErrorNotNil(error) {
            return
        }
        
        executeSerialAsyncTask {
            
            switch characteristic.uuid.uuidString {
            
            case MeshUUID.notifyCharacteristic:
                
                self.handleNotifyValue(peripheral, value: value)
                
            case MeshUUID.commandCharacteristic:
                
                MLog("commandCharacteristic didUpdateValue \(value.hexString)")
            
            case MeshUUID.pairingCharacteristic:
                
                self.handlePairingValue(peripheral, value: value)
                        
            case MeshUUID.otaCharacteristic:
                
                self.handleOtaValue(value)
                
            case MeshUUID.firmwareCharacteristic:
                
                self.handleFirmwareValue(value)
                
            default:
                break
            }
        }
        
    }
    
}

// MARK: - Private

extension MeshManager {
    
    private func isBluetoothPowerOn() -> Bool {
        if centralManager.state != .poweredOn {
            DispatchQueue.main.async {
                self.nodeDelegate?.meshManagerNeedTurnOnBluetooth?(self)
            }
            return false
        }        
        return true
    }
    
}

// MARK: - Queue tasks

extension MeshManager {
    
    func executeSerialAsyncTask(_ task: @escaping () -> Void) {
        
        if DispatchQueue.getSpecific(key: serialQueueKey) != nil {
            
            task()
            
        } else {
            
            serialQueue.async { task() }
        }
    }
    
    private func executeConcurrentAsyncTask(_ task: @escaping () -> Void) {
        
        if DispatchQueue.getSpecific(key: concurrentQueueKey) != nil {
            
            task()
            
        } else {
            
            concurrentQueue.async { task() }
        }
    }
    
    private func executeSendingAsyncTask(_ task: @escaping () -> Void) {
        
        if DispatchQueue.getSpecific(key: sendingQueueKey) != nil {
            
            task()
            Thread.sleep(forTimeInterval: self.sendingTimeInterval)
            
        } else {
            
            sendingQueue.async {
                
                task()
                Thread.sleep(forTimeInterval: self.sendingTimeInterval)
            }
        }
    }
    
}

// MARK: - did update value handlers

extension MeshManager {
    
    private func handlePairingValue(_ peripheral: CBPeripheral, value: Data) {
        
        if setNetworkState == .processing {
            
            setNetworkState = .none
            let isSuccess = value.first == 0x07
            let log = "setNetworkState isSuccess " + (isSuccess ? "TRUE" : "FALSE")
            MLog(log)
            
            if let firmwareCharacteristic = self.firmwareCharacteristic {
                
                peripheral.readValue(for: firmwareCharacteristic)
            }
            
            DispatchQueue.main.async {
                
                self.nodeDelegate?.meshManager?(self, didConfirmNewNetwork: isSuccess)
            }
            
            return
        }
        
        guard value.count > 1, value.first == 0x0D else {
            
            MLog("pairingCharacteristic didUpdateValue value.first != 0x0D, return")
            
            if !self.isLogin {
                
                DispatchQueue.main.async {
                    
                    self.nodeDelegate?.meshManager?(self, didFailToLoginNodeIdentifier: peripheral.identifier)
                }
                
                self.disconnect(autoLogin: self.isAutoLogin)
            }
            
            return
        }
        
        let tempData = Data(value[1...])
        let prandCount = value.count - 1
        let prand = UnsafeMutablePointer<UInt8>.allocate(capacity: prandCount)
        defer { prand.deallocate() }
        for i in 0..<(prandCount) {
            let temp = tempData[i]
            prand[i] = temp
        }
        
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
        defer { buffer.deallocate() }
        memset(buffer, 0, 16)
        
        if CryptoAction.encryptPair(self.network.name, pas: self.network.password, prand: prand, pResult: buffer) {
            
            memset(buffer, 0, 16)
            
            CryptoAction.getSectionKey(self.network.name, pas: self.network.password, prandm: self.loginRand, prands: prand, pResult: buffer)
            
            memcpy(self.sectionKey, buffer, 16)
            
            self.isLogin = true
            MLog("login successful")
            
            DispatchQueue.main.async {
                
                guard let node = self.connectNode,
                      node.peripheral.identifier == peripheral.identifier else {
                    
                    return
                }
                
                self.nodeDelegate?.meshManager?(self, didLoginNode: node)
            }
            
        } else {
            
            MLog("pairingCharacteristic CryptoAction.encryptPair failed.")
            
            DispatchQueue.main.async {
                
                self.nodeDelegate?.meshManager?(self, didFailToLoginNodeIdentifier: peripheral.identifier)
            }
            
            self.disconnect(autoLogin: self.isAutoLogin)
        }
    }
    
    private func handleNotifyValue(_ peripheral: CBPeripheral, value: Data) {
        
        guard let macValue = self.connectNode?.macValue else {
            MLog("connectNode is nil, return")
            return
        }
        guard value.count == 20, !(value[0] == 0 && value[1] == 0 && value[2] == 0) else {
            MLog("value format error")
            return
        }
        guard let data = CryptoAction.pasterData(value, mac: macValue, sectionKey: self.sectionKey) else {
            
            return
        }
        
        MLog("handleNotifyValue \(data.hexString)")
        
        let tagValue = data[7]
        guard let tag = MeshCommand.Tag(rawValue: tagValue) else {
            
            MLog("Unsupported tag " + String(format: "0x%02X", tagValue))
            return
        }
        
        switch tag {
        
        case .lightStatus:
            
            MLog("lightStatus tag")
            self.handleLightStatusData(data)
            
        case .nodeToApp:
            
            MLog("nodeToApp tag")
            self.handleNodeToAppData(data)
            
        case .getStatus:
            MLog("getStatus tag")
        case .responseStatus:
            MLog("responseStatus tag")
            handleResponseStatusData(data)
            
        case .appToNode:
            
            MLog("appToNode tag")
            self.handleNodeToAppData(data)
            
        case .onOff:
            MLog("onOff tag")
            
        case .brightness:
            MLog("brightness tag")
            
        case .singleChannel:
            MLog("singleChannel tag")
            
        case .replaceAddress:
            MLog("replaceNodeAddress tag")
            
        case .deviceAddressNotify:
            
            MLog("deviceAddrNotify tag")
            self.handleDeviceAddressNotifyData(data)
            
        case .resetNetwork:
            MLog("resetNetwork tag")
            
        case .syncDatetime:
            MLog("syncDatetime tag")
            
        case .getDatetime:
            MLog("getDatetime tag")
            
        case .datetimeResponse:
            
            MLog("datetimeResponse tag")
            self.handleDatetimeResponseData(data)
            
        case .getFirmware:
            MLog("getFirmware tag")
            
        case .firmwareResponse:
            
            MLog("firmwareResponse tag")
            self.handleFirmwareResponseValue(data)
            
        case .getGroups:
            MLog("getGropus tag")
            
        case .responseGroups:
            
            MLog("responseGroups tag")
            self.handleResponseGroupsValue(data)
            
        case .groupAction:
            MLog("groupAction tag")
            
        case .scene:
            MLog("scene tag")
            
        case .loadScene:
            MLog("loadScene tag")
            
        case .getScene:
            MLog("getScene tag")
            
        case .getSceneResponse:
            
            MLog("getSceneResponse tag")
            handleSceneResponseValue(value)
            
        case .getAlarm:
            MLog("getAlarm tag")
            
        case .getAlarmResponse:
            
            MLog("getAlarmResponse tag")
            handleAlarmResponseValue(value)
            
        case .editAlarm:
            MLog("editAlarm tag")
            
        case .setRemoteGroups:
            MLog("setRemoteGroups tag")
            
        case .responseLeadingGroups:
            
            MLog("responseLeadingGroups tag")
            handleRemoteGroupsResponseValue(value, isLeading: true)
            
        case .responseTralingGroups:
            
            MLog("responseLeadingGroups tag")
            handleRemoteGroupsResponseValue(value, isLeading: false)
            
        case .uartModule:
            MLog("uartModule tag")
        }
    }
    
    private func handleLightStatusData(_ data: Data) {
        
        let devices = MeshDevice.makeMeshDevices(data)
        
        guard devices.count > 0 else {
            
            return
        }
        
        devices.forEach {
            
            MLog("Get MeshDevice \($0.description)")
        }
        
        DispatchQueue.main.async {
            
            self.deviceDelegate?.meshManager(self, didUpdateMeshDevices: devices)
            
            let event = MqttDeviceStateEvent(meshDevices: devices)
            self.deviceEventDelegate?.meshManager(self, didUpdateEvent: event)
        }
    }
    
    private func handleNodeToAppData(_ data: Data) {
        
        guard let command = MeshCommand(notifyData: data) else {
            
            MLog("handleNodeToAppData failed, cannot covert to a MeshCommand")
            return
        }
        
        SmartSwitchManager.shared.append(command)
        NaturalLightManager.shared.handleCommand(command)
        
        if command.src == uartDaliGatewayAddress {
            UartDaliManager.shared.receive(command)
            NSLog("uart data from \(command.src)", "")
            return
        }
        
        guard let identifier = MeshCommand.SrIndentifier(rawValue: command.userData[0]) else {
            
            MLog("handleNodeToAppData failed, unsupported identifier " + String(format: "0x%02X", command.userData[0]))
            return
        }
        
        switch identifier {
        
        case .mac:
            
            let deviceType = MeshDeviceType(deviceType: command.userData[1], subDeviceType: command.userData[2])
            let macData = Data(command.userData[3...8].reversed())
            let address = command.src
            
            MLog("DeviceType \(address), \(deviceType.category.description), MAC \(macData.hexString)")
            
            DispatchQueue.main.async {
                
                self.deviceDelegate?.meshManager(self, device: address, didUpdateDeviceType: deviceType, macData: macData)
                
                let event = MqttDeviceTypeEvent(shortAddress: address, deviceType: deviceType, macData: macData)
                self.deviceEventDelegate?.meshManager(self, didUpdateEvent: event)
            }
            
        case .lightControlMode:
            
            MLog("lightControlMode ")
            handleLightCongtrolModeCommand(command)
            
        case .lightSwitchType:
            
            MLog("lightSwitchType")
            handleLightSwitchTypeCommand(command)
            
        case .special:
            MLog("special feature command")
            handleSpecialCommand(command)
            
        case .timezone:
            
            MLog("timezone")
            handleTimezoneCommand(command)
            
        case .getLocation:
            
            MLog("getLocation")
            handleLocationCommand(command)
            
        case .setLocation:            
            MLog("setLocation")
            
        case .sunrise:
            
            MLog("sunrise")
            handleSunriseSunsetCommand(command, type: .sunrise)
            
        case .sunset:
            
            MLog("sunset")
            handleSunriseSunsetCommand(command, type: .sunset)
            
        case .syncInfo:
            
            MLog("syncInfo")
            handleSyncInfoCommand(command)
            
        case .smartSwitchId:
            
            MLog("Mechanical ID")
            handleMechanicalIdCommand(command)
            
        case .sensorReport:
            
            MLog("Sensor Report")
            handleSensorReportCommand(command)
            
        case .sensorUartTx:
            
            MLog("Sensor Uart Tx")
            handleSensorUartTxCommand(command)
            
        case .doorSensorOpen:
            MLog("\(identifier)")
            handleSensorEventActionCommand(command, event: .doorOpen)
            handleSingleSensorActionCommand(command, identifier: identifier)
            
        case .doorSensorClosed:
            MLog("\(identifier)")
            handleSensorEventActionCommand(command, event: .doorClosed)
            handleSingleSensorActionCommand(command, identifier: identifier)
            
        case .pirDetected:
            MLog("\(identifier)")
            handleSensorEventActionCommand(command, event: .pirDetected)
            
        case .pirNotDetected:
            MLog("\(identifier)")
            handleSensorEventActionCommand(command, event: .pirNotDetected)
            
        case .microwaveDetected:
            MLog("\(identifier)")
            handleSensorEventActionCommand(command, event: .microwaveDetected)
            
        case .microwaveNotDetected:
            MLog("\(identifier)")
            handleSensorEventActionCommand(command, event: .microwaveNotDetected)
            
        case .curtainReport:
            MLog("\(identifier)")
            handleCurtainReport(command)
            
        case .waterLeakDetected: fallthrough
        case .waterLeakNotDetected: fallthrough
        case .smokeDetected: fallthrough
        case .smokeNotDetected: fallthrough
        case .coDetected: fallthrough
        case .coNotDetected: fallthrough
        case .gasDetected: fallthrough
        case .gasNotDetected: fallthrough
        case .airQualityDetected: fallthrough
        case .airQualityNotDetected: fallthrough
        case .glassBreakDetected: fallthrough
        case .glassBreakNotDetected: fallthrough
        case .vibrationDetected: fallthrough
        case .vibrationNotDetected:
            handleSingleSensorActionCommand(command, identifier: identifier)
            
        case .universalRemote:
            MLog("universal remote tag")
            handleUniversalRemoteActionCommand(command)
            
        case .pwmChannelsStatus:
            MLog("pwmChannelsStatus tag")
            handlePwmChannelsStatusCommand(command)
            
        case .multiSensorAction:
            MLog("multiSensorAction tag")
            handleMultiSensorActionCommand(command)
        }
    }
    
    private func handleResponseStatusData(_ data: Data) {
        guard let command = MeshCommand(notifyData: data) else {
            return
        }
        let red = command.param
        let green = Int(command.userData[0])
        let blue = Int(command.userData[1])
        let whiteOrCct = Int(command.userData[2])
        let brightness = Int(command.userData[5])
        MLog("Deprecated method. handleResponseStatusData red \(red), green \(green), blue \(blue), whiteOrCct \(whiteOrCct), brightness \(brightness)")
    }
    
    private func handleDeviceAddressNotifyData(_ data: Data) {
        
        guard let command = MeshCommand(notifyData: data) else {
            
            MLog("handleDeviceAddressNotifyData failed, cannot covert to a MeshCommand")
            return
        }
        
        let address = command.param
        MLog("handleDeviceAddressNotifyData newAddress " + String(format: "%02X", address))
        
        DispatchQueue.main.async {
            
            self.nodeDelegate?.meshManager?(self, didGetDeviceAddress: address)
            self.deviceDelegate?.meshManager(self, didGetDeviceAddress: address)
        }
        
    }
    
    private func handleDatetimeResponseData(_ data: Data) {
        
        guard let command = MeshCommand(notifyData: data) else {
            
            MLog("handleDatetimeResponseData failed, cannot covert to a MeshCommand")
            return
        }
        
        let year = command.param | (Int(command.userData[0]) << 8)
        let month = Int(command.userData[1])
        let day = Int(command.userData[2])
        let hour = Int(command.userData[3])
        let minute = Int(command.userData[4])
        let second = Int(command.userData[5])
        
        MLog("handleDatetimeResponseData \(year)/\(month)/\(day) \(hour):\(minute):\(second)")
        
        let calendar = Calendar.current
        let dateComponent = DateComponents(calendar: calendar,year: year, month: month, day: day, hour: hour, minute: minute, second: second)
        
        guard let date = dateComponent.date else {
            
            MLog("handleDatetimeResponseData failed, dateComponent.date is nil")
            return
        }
        
        DispatchQueue.main.async {
            
            self.deviceDelegate?.meshManager(self, device: command.src, didGetDate: date)
            
            let event = MqttDeviceDateEvent(shortAddress: command.src, date: date)
            self.deviceEventDelegate?.meshManager(self, didUpdateEvent: event)
        }
    }
    
    private func handleLightCongtrolModeCommand(_ command: MeshCommand) {
        
        guard let mode = MeshCommand.SrLightControlMode(rawValue: command.userData[1]) else {
            
            MLog("handleLightCongtrolModeCommand failed, unsupported mode \(command.userData[1])")
            return
        }
        
        switch mode {
            
        case .lightGammaCurve:
            guard command.userData[2] == 0x00 else {
                MLog("lightGammaCurve userData[2] != 0x00, is not get/response data")
                return
            }
            if let gamma = MeshCommand.LightGamma(rawValue: command.userData[3]) {
                DispatchQueue.main.async {
                    self.deviceDelegate?.meshManager(self, device: command.src, didGetLightGammaCurve: gamma)
                }
                MLog("lightGammaCurve \(gamma)")
            } else {
                MLog("lightGammaCurve userData[3] is \(command.userData[3]), is not a gamma curve value.")
            }
        
        case .lightOnOffDuration:
            
            guard command.userData[2] == 0x00 else {
                
                MLog("lightOnOffDuration userData[2] != 0x00, is not get/response data")
                return
            }
            
            let duration = Int(command.userData[3]) | (Int(command.userData[4]) << 8)
            DispatchQueue.main.async {
                
                self.deviceDelegate?.meshManager(self, device: command.src, didGetLightOnOffDuration: duration)
                
                let event = MqttDeviceLightOnOffDurationEvent(shortAddress: command.src, duration: duration)
                self.deviceEventDelegate?.meshManager(self, didUpdateEvent: event)
            }
            
        case .getLightRunningMode:
            
            MLog("getLightRunningMode response")
            guard let mode = MeshCommand.LightRunningMode(address: command.src, userData: command.userData) else {
                
                MLog("getLightRunningMode init failed.")
                return
            }
            
            DispatchQueue.main.async {
                
                self.deviceDelegate?.meshManager(self, device: command.src, didGetLightRunningMode: mode)
            }
            
        case .setLightRunningMode:
            MLog("setLightRunningMode")
            
        case .setSyncLightRunningMode:
            MLog("setSyncLightRunningMode")
            
        case .setLightRunningSpeed:            
            MLog("setLightRunningSpeed")
            
        case .customLightRunningMode:
            
            MLog("customLightRunningMode")
            guard command.userData[2] == 0x00 else {
                
                MLog("customLightRunningMode init failed.")
                return
            }
            
            if command.userData[3] == 0x00 {
                
                let value = (Int(command.userData[4]) << 8) | Int(command.userData[5])
                var modeIds: [Int] = []
                for i in 0..<16 {
                    if ((0x01 << i) & value) > 0 {
                        modeIds.append(i + 1)
                    }
                }
                MLog("customLightRunningMode idList count \(modeIds.count)")
                
                DispatchQueue.main.async {
                    
                    self.deviceDelegate?.meshManager(self, device: command.src, didGetLightRunningModeIdList: modeIds)
                }
                
            } else if command.userData[3] >= 0x01 && command.userData[3] <= 0x10 {
             
                let modeId = Int(command.userData[3])
                let colorsCount = Int(command.userData[4])
                let colorIndex = Int(command.userData[5])
                let color = MeshCommand.LightRunningMode.Color(red: command.userData[6], green: command.userData[7], blue: command.userData[8])
                
                MLog("LighRunningColor modeId \(modeId), count \(colorsCount), index \(colorIndex)")
                
                DispatchQueue.main.async {
                    
                    self.deviceDelegate?.meshManager(self, device: command.src, didGetLightRunningModeId: modeId, colorsCount: colorsCount, colorIndex: colorIndex, color: color)
                }
            }
            
        case .lightPwmFrequency:
            
            let frequency = (Int(command.userData[4]) << 8) | Int(command.userData[3])
            MLog("lightPwmFrequency \(frequency)")
            
            guard frequency > 0 else { return }
            
            DispatchQueue.main.async {
                
                self.deviceDelegate?.meshManager(self, device: command.src, didGetLightPwmFrequency: frequency)
            }
            
        case .channelMode:
            
            guard command.userData[2] == 0x04, command.userData[3] == 0x00 else { return }
            
            let isEnabled = command.userData[4] == 0x01
            MLog("channelMode: Rgb independence isEnabled \(isEnabled)")
            
            DispatchQueue.main.async {
                
                self.deviceDelegate?.meshManager(self, device: command.src, didGetRgbIndependence: isEnabled)
            }
            
        case .powerOnState:
            let level = Int(command.userData[3])
            DispatchQueue.main.async {
                self.deviceDelegate?.meshManager(self, device: command.src, didGetPowerOnState: level)
            }
            MLog("powerOnState \(level)")
        }
    }
    
    private func handleLightSwitchTypeCommand(_ command: MeshCommand) {
        
        guard let switchType = MeshCommand.LightSwitchType(rawValue: command.userData[2]) else {
            
            MLog("handleLightSwitchTypeCommand failed, unsupported mode \(command.userData[2])")
            return
        }
        
        MLog("LightSwitchType \(switchType)")
        
        DispatchQueue.main.async {
            
            self.deviceDelegate?.meshManager(self, device: command.src, didGetLightSwitchType: switchType)
        }
    }
    
    private func handleSpecialCommand(_ command: MeshCommand) {
        let userData = command.userData
        let tag = userData[1]
        switch tag {
        case 0x04: // sensor ID
            // read sensor ID
            if userData[2] == 0x00 {
                let sensorTypeValue = userData[3]
                let v1 = Int(userData[4]) << 24
                let v2 = Int(userData[5]) << 16
                let v3 = Int(userData[6]) << 8
                let v4 = Int(userData[7])
                let sensorId = v1 | v2 | v3 | v4
                let sensorIdHex = String(sensorId, radix: 16)
                MLog("get sensor ID \(sensorIdHex)")
                DispatchQueue.main.async {
                    self.deviceDelegate?.meshManager(self, device: command.src, didGetSensorId: sensorId, sensorTypeValue: Int(sensorTypeValue))
                    // This is a multi sensor
                    if (sensorTypeValue & 0xF0) > 0 {
                        self.multiSensorDelegate?.meshManager(self, device: command.src, didGetMultiSensorId: sensorId, sensorIndex: Int(sensorTypeValue & 0x0F))
                    } else {
                        if let sensorType = MeshCommand.SingleSensorAction.SensorType(rawValue: sensorTypeValue) {
                            self.singleSensorDelegate?.meshManager(self, device: command.src, didGetSingleSensorId: sensorId, sensorType: sensorType)
                        }
                    }
                }
            }
        case 0x06: // Universal remote about
            // read response
            if userData[2] == 0x00 {
                guard let remoteIndex = MeshCommand.UniversalRemoteIndex(rawValue: userData[3]) else { return }
                let v1 = Int(userData[4]) << 24
                let v2 = Int(userData[5]) << 16
                let v3 = Int(userData[6]) << 8
                let v4 = Int(userData[7])
                let remoteIdValue = v1 | v2 | v3 | v4
                let idHex = String(remoteIdValue, radix: 16).uppercased()
                MLog("get universal remote ID \(remoteIndex), \(idHex)")
                DispatchQueue.main.async {
                    self.deviceDelegate?.meshManager(self, device: command.src, didGetUniversalRemoteId: idHex, remoteIndex: remoteIndex)
                }
            }
        case 0x00: // Sensor ID about
            let tagCommand = Int(userData[2])
            let isPaired = userData[3] == 0x5A
            let v1 = Int(userData[4]) << 24
            let v2 = Int(userData[5]) << 16
            let v3 = Int(userData[6]) << 8
            let v4 = Int(userData[7])
            let sensorId = v1 | v2 | v3 | v4
            var sensorType = "Unknown"
            switch (tagCommand) {
            case 0x10: // door sensor
                sensorType = "DoorSensor"
            case 0x16: // water leak sensor
                sensorType = "WaterLeak"
            default:
                break
            }
            NSLog("Sensor ID about tag \(tag), sensorType \(sensorType), isPaired \(isPaired), ID \(sensorId.hex)", "")
            DispatchQueue.main.async {
                self.deviceDelegate?.meshManager(self, device: command.src, didGetManualLinkedSensor: sensorId, sensorType: sensorType, isLinked: isPaired)
            }
        default:
            NSLog("unsupported special tag \(tag)", "")
        }
    }
    
    private func handleTimezoneCommand(_ command: MeshCommand) {
        
        if (command.userData[2] == 0
            && command.userData[3] == 0
            && command.userData[4] == 0
            && command.userData[5] == 0
            && command.userData[6] == 0
            && command.userData[7] == 0
            && command.userData[8] == 0) {
            
            return
        }
        
        let hour = Int(command.userData[2] & 0x7F)
        let isNegative = (command.userData[2] & 0x80) == 0x80
        let minute = Int(command.userData[3])
        let sunriseHour = Int(command.userData[5])
        let sunriseMinute = Int(command.userData[6])
        let sunsetHour = Int(command.userData[7])
        let sunsetMinute = Int(command.userData[8])
        
        let sign = isNegative ? "-" : ""
        MLog("handleTimezoneCommand \(command.src), \(sign)\(hour):\(minute), \(sunriseHour):\(sunriseMinute), \(sunsetHour):\(sunsetMinute)")
        
        DispatchQueue.main.async {
            
            self.deviceDelegate?.meshManager(self, device: command.src, didGetTimezone: isNegative, hour: hour, minute: minute, sunriseHour: sunriseHour, sunriseMinute: sunriseMinute, sunsetHour: sunsetHour, sunsetMinute: sunsetMinute)
        }
    }
    
    private func handleLocationCommand(_ command: MeshCommand) {
        
        if (command.userData[1] == 0
            && command.userData[2] == 0
            && command.userData[3] == 0
            && command.userData[4] == 0)
            || (command.userData[5] == 0
            && command.userData[6] == 0
            && command.userData[7] == 0
            && command.userData[8] == 0) {
            
            return
        }
        
        let longitudeData = Data(command.userData[1...4])
        let longitude = longitudeData.floatValue
        let latitudeData = Data(command.userData[5...8])
        let latitude = latitudeData.floatValue
        
        MLog("handleLocationCommand \(longitude), \(latitude)")
        
        DispatchQueue.main.async {
            
            self.deviceDelegate?.meshManager(self, device: command.src, didGetLocation: longitude, latitude: latitude)
        }
    }
    
    private func handleSunriseSunsetCommand(_ command: MeshCommand, type: SunriseSunsetType) {
        
        let actionTypeValue = command.userData[1] & 0x7F
        let isEnabled = (Int(command.userData[1]) & 0x80) == 0
        
        guard let actionType = SunriseSunsetActionType(rawValue: actionTypeValue) else {
            
            MLog("Unsupported actionType \(actionTypeValue)")
            return
        }
        
        var action: SunriseSunsetAction!
        
        switch actionType {
        case .onOff:
            
            var onOffAction = SunriseSunsetOnOffAction(type: type)
            onOffAction.isEnabled = isEnabled
            onOffAction.isOn = command.userData[2] == 0x01
            onOffAction.duration = Int(command.userData[6]) | (Int(command.userData[7]) << 8)
            action = onOffAction
            
        case .scene:
            
            var sceneAction = SunriseSunsetSceneAction(type: type)
            sceneAction.isEnabled = isEnabled
            sceneAction.sceneID = Int(command.userData[2])
            action = sceneAction
            
        case .custom:
            
            var customAction = SunriseSunsetCustomAction(type: type)
            customAction.isEnabled = isEnabled
            customAction.brightness = Int(command.userData[2])
            customAction.red = Int(command.userData[3])
            customAction.green = Int(command.userData[4])
            customAction.blue = Int(command.userData[5])
            customAction.ctOrW = Int(command.userData[6])
            customAction.duration = Int(command.userData[7]) | (Int(command.userData[8]) << 8)
            action = customAction
        }
        
        MLog("SunrisetSunsetAction \(action.description)")
        
        DispatchQueue.main.async {
            
            self.deviceDelegate?.meshManager(self, device: command.src, didGetSunriseSunsetAction: action)
        }
    }
    
    private func handleSyncInfoCommand(_ command: MeshCommand) {
        
        guard command.userData[1] == 0x00 else {
            return
        }
        
        guard let syncTag = MeshCommand.GroupSyncTag(rawValue: command.userData[2]) else {
            return
        }
        NSLog("Sync tag \(syncTag)", "")
        
        let g1 = command.userData[3]
        let g2 = command.userData[4]
        let group = Int(g1) | Int(g2) << 8
        
        DispatchQueue.main.async {
            self.deviceDelegate?.meshManager(self, device: command.src, didGetGroupSyncTag: syncTag, group: group)
        }
    }
    
    private func handleMechanicalIdCommand(_ command: MeshCommand) {
        
        let count = Int(command.userData[1])
        let index = Int(command.userData[2])
        let id1 = Int(command.userData[3])
        let id2 = Int(command.userData[4]) << 8
        let id3 = Int(command.userData[5]) << 16
        let id4 = Int(command.userData[6]) << 24
        var switchId: Int? = id1 | id2 | id3 | id4
        switchId = switchId == 0 ? nil : switchId
        
        DispatchQueue.main.async {
            self.deviceDelegate?.meshManager(self, device: command.src, didGetSmartSwitchId: switchId, index: index, count: count)
        }
    }
    
    private func handleSensorReportCommand(_ command: MeshCommand) {
        
        let type = command.userData[1]
        guard let reportType = MeshCommand.SensorReportType(rawValue: type) else {
            return
        }
        
        var value: [MeshCommand.SensorReportKey: Any] = [:]
        
        switch reportType {
            
        case .reserved:
            MLog("Reserved")
            
        case .doorState:
            
            let isOpen = command.userData[2] == 0x01
            value[.doorState] = isOpen
            
        case .pirMotion:
            
            let isDetected = command.userData[2] == 0x01
            value[.isDetected] = isDetected
            
        case .microwareMotion:
            
            let isDetected = command.userData[2] == 0x01
            value[.isDetected] = isDetected
            
            let low = Int(command.userData[3])
            let high = Int(command.userData[4]) << 8
            let lux = low | high
            value[.lux] = lux
            
        case .lux:
            
            let low = Int(command.userData[2])
            let high = Int(command.userData[3]) << 8
            let lux = low | high
            value[.lux] = lux
            
            let isDetected = command.userData[4] == 0x01
            value[.isDetected] = isDetected
            
        case .temperature:
            
            let temp = Int(command.userData[2])
            value[.temperature] = temp
        }
        
        MLog("Sensor Report \(reportType), value \(value)")
        
        DispatchQueue.main.async {
            
            self.deviceDelegate?.meshManager(self, device: command.src, didSensorReport: value)
        }
    }
    
    private func handleSensorUartTxCommand(_ command: MeshCommand) {
        
        guard command.userData[1] == 0x00 else { return }
        
        guard let type = MeshCommand.SensorAttributeType(rawValue: command.userData[2]) else {
            
            NSLog("Unknown SensorAttributeType \(command.userData[2])", "")
            return
        }
        
        var value: [MeshCommand.SensorAttributeType: Any] = [:]
        
        switch type {
            
        case .humanInductionSensitivity: fallthrough
        case .microwaveModuleOnOffState: fallthrough
        case .lightModuleOnOffState: fallthrough
        case .detectedPwmOutputPercentage: fallthrough
        case .notDetectedPwmOutputPercentage: fallthrough
        case .pwmOutputPercentageAfterNotDetectedDelay: fallthrough
        case .workingMode: fallthrough
        case .sensorState: fallthrough
        case .reportOnOffState: fallthrough
        case .luxScaleFactorOfTheBrightnessSensor:
            
            value[type] = Int(command.userData[3])
            
        case .workingBrightnessThreshold: fallthrough
        case .detectedPwmOutputDelay: fallthrough
        case .detectedPwmOutputBrightness: fallthrough
        case .notDetectedPwmOutputDelay: fallthrough
        case .stateReportInterval:
            
            let low = Int(command.userData[3])
            let high = Int(command.userData[4])
            value[type] = low | (high << 8)
            
        case .luxZeroDeviationOfTheBrightnessSensor:
            
            var newValue = Int(command.userData[3])
            if newValue >= 0x81 {
                
                newValue = (newValue & 0x7F) - 128
                
            } else if newValue == 0x80 {
                
                newValue = 0
            }
            value[type] = newValue
        }
        
        if (type == .sensorState) {
            var reportValue: [MeshCommand.SensorReportKey: Any] = [:]
            let low = Int(command.userData[4])
            let high = Int(command.userData[5]) << 8
            let lux = low | high
            reportValue[MeshCommand.SensorReportKey.lux] = lux
            
            let isDetected = command.userData[3] == 0x01
            reportValue[MeshCommand.SensorReportKey.isDetected] = isDetected
            MLog("Sensor Report \(type), value \(reportValue)")
            DispatchQueue.main.async {
                self.deviceDelegate?.meshManager(self, device: command.src, didSensorReport: reportValue)
            }
        }
        
        MLog("Sensor did get attribute value \(value)")
        
        DispatchQueue.main.async {
            
            self.deviceDelegate?.meshManager(self, device: command.src, didGetSensorAttribute: value)
        }
    }
    
    private func handleSensorEventActionCommand(_ command: MeshCommand, event: MeshCommand.SensorEvent) {
        
        let isEnabled = (command.userData[1] & 0x80) == 0
        let code = (command.userData[1] & 0x7F)
        
        var action: MeshCommand.SensorAction? = nil
        
        switch code {
            
        case 0x01: // turnOnOff
            
            let isOn = command.userData[2] == 0x01
            let transitionLow = Int(command.userData[6])
            let transitionHigh = Int(command.userData[7]) << 8
            let transition = transitionLow | transitionHigh
            action = .turnOnOff(isOn: isOn, transition: transition, isEnabled: isEnabled)
            
        case 0x02: // recallScene
            
            let sceneId = Int(command.userData[2])
            action = .recallScene(sceneId: sceneId, isEnabled: isEnabled)
            
        case 0x04: // setState
            
            let brightness = Int(command.userData[2])
            let red = Int(command.userData[3])
            let green = Int(command.userData[4])
            let blue = Int(command.userData[5])
            let ctOrWhtie = Int(command.userData[6])
            let transitionLow = Int(command.userData[7])
            let transitionHigh = Int(command.userData[8]) << 8
            let transition = transitionLow | transitionHigh
            action = .setState(brightness: brightness, red: red, green: green, blue: blue, ctOrWhite: ctOrWhtie, transition: transition, isEnabled: isEnabled)
            
        case 0x05: // setBrightness
            
            let brightness = Int(command.userData[2])
            let transitionLow = Int(command.userData[6])
            let transitionHigh = Int(command.userData[7]) << 8
            let transition = transitionLow | transitionHigh
            action = .setBrightness(brightness: brightness, transition: transition, isEnabled: isEnabled)
            
        case 0x06: // setRGB, setR, setG, setB, setCtOrWhite
            
            let setType = command.userData[2]
            switch setType {
                
            case 0x01:
                
                let red = Int(command.userData[3])
                action = .setRed(red: red, isEnabled: isEnabled)
                
            case 0x02:
                
                let green = Int(command.userData[3])
                action = .setGreen(green: green, isEnabled: isEnabled)
                
            case 0x03:
                
                let blue = Int(command.userData[3])
                action = .setBlue(blue: blue, isEnabled: isEnabled)
                
            case 0x04:
                
                let red = Int(command.userData[3])
                let green = Int(command.userData[4])
                let blue = Int(command.userData[5])
                action = .setRGB(red: red, green: green, blue: blue, isEnabled: isEnabled)
                
            case 0x05:
                let ctOrWhite = Int(command.userData[3])
                action = .setCtOrWhite(ctOrWhite: ctOrWhite, isEnabled: isEnabled)
                
            default:
                break
            }
            
        case 0x07: // running
            
            guard command.userData[2] == 0x05 else {
                
                MLog("Unknown running.")
                return
            }
            
            let getType = command.userData[3]
            switch getType {
                
            case 0x01:
                
                let index = Int(command.userData[4])
                action = .setRunning(index: index, isEnabled: isEnabled)
                
            case 0x02:
                
                let index = Int(command.userData[4])
                guard let mode = MeshCommand.SensorAction.CustomRunningMode(rawValue: command.userData[5]) else {
                    
                    MLog("Unknown running mode")
                    return
                }
                action = .setCustomRunning(index: index, mode: mode, isEnabled: isEnabled)
                
            case 0x00:
                
                action = .stopRunning(isEnabled: isEnabled)
                
            default:
                break
            }
            
        case 0xC0: fallthrough // none
        case 0x00:
            
            action = MeshCommand.SensorAction.none
            
        default:
            break
        }
        
        if let action = action {
            
            DispatchQueue.main.async {
                
                self.deviceDelegate?.meshManager(self, device: command.src, didGetSensorEvent: event, action: action)
            }
        }
    }
    
    private func handleSingleSensorActionCommand(_ command: MeshCommand, identifier: MeshCommand.SrIndentifier) {
        NSLog("single sensor action \(identifier)", "")
        let sensorTypeRawValue = (command.userData[0] & 0x0F)
        guard let sensorType = MeshCommand.SingleSensorAction.SensorType(rawValue: sensorTypeRawValue) else {
            NSLog("Unsupported single sensor type \(sensorTypeRawValue)", "")
            return
        }
        let actionIndex: UInt8 = (identifier.rawValue & 0xF0) == 0x40 ? 2 : 1
        let actionNoValue = command.userData[1] & 0x7F
        let isEnabled = (command.userData[1] & 0x80) == 0
        var action = MeshCommand.SingleSensorAction(sensorType: sensorType, actionIndex: actionIndex, actionNo: .undefined)
        action.isEnabled = isEnabled
        switch actionNoValue {
        case 0x01:
            action.actionNo = command.userData[2] == 0x01 ? .turnOn : .turnOff
        case 0x05:
            action.actionNo = .setBrightness
            action.brightness = Int(command.userData[2])
        case 0x06:
            if command.userData[2] == 0x04 {
                // rgb
                action.actionNo = .setRgb
                action.red = Int(command.userData[3])
                action.green = Int(command.userData[4])
                action.blue = Int(command.userData[5])
            } else if command.userData[3] == 0x05 {
                // ct or white
                action.actionNo = .setCctOrWhite
                action.cctOrWhite = Int(command.userData[3])
            }
        case 0x02:
            action.actionNo = .recallScene
            action.sceneId = Int(command.userData[2])
        default:
            break
        }
        NSLog("did get single sensor action \(action)", "")
        DispatchQueue.main.async {
            self.singleSensorDelegate?.meshManager(self, device: command.src, didGetSingleSensorAction: action)
        }
    }
    
    private func handleUniversalRemoteActionCommand(_ command: MeshCommand) {
        guard let remoteIndex = MeshCommand.UniversalRemoteIndex(rawValue: command.userData[1]) else {
            MLog("It is not a remote index \(command.userData[1])")
            return
        }
        let keyIndex = command.userData[2]
        // rotatoin
        if keyIndex == 17 {
            let rotationActionType = MeshCommand.UniversalRemoteAction.ActionType.makeRotationActionType(rawValue: command.userData[3])
            let steps = command.userData[4]
            let rotationAction = MeshCommand.UniversalRemoteAction(keyIndex: keyIndex, keyType: .rotationOrLongPressEnding, actionType: rotationActionType, args: [steps])
            MLog("did get rotation action \(rotationAction)")
            DispatchQueue.main.async {
                self.deviceDelegate?.meshManager(self, device: command.src, didGetUniversalRemoteRotationAction: rotationAction, remoteIndex: remoteIndex)
            }
        } else {
            let shortPressActionType = MeshCommand.UniversalRemoteAction.ActionType(rawValue: command.userData[3]) ?? .none
            let longPressActionType = MeshCommand.UniversalRemoteAction.ActionType(rawValue: command.userData[4]) ?? .none
            // let longPressEndActionType = MeshCommand.UniversalRemoteAction.ActionType(rawValue: command.userData[5]) ?? .none
            let shortAction = MeshCommand.UniversalRemoteAction(keyIndex: keyIndex, keyType: .shortPress, actionType: shortPressActionType, args: [command.userData[6], command.userData[7], command.userData[8]])
            let longAction = MeshCommand.UniversalRemoteAction(keyIndex: keyIndex, keyType: .longPress, actionType: longPressActionType, args: [])
            MLog("did get short action \(shortAction), long action \(longAction)")
            DispatchQueue.main.async {
                self.deviceDelegate?.meshManager(self, device: command.src, didGetUniversalRemoteShortLongAction: shortAction, longAction: longAction, remoteIndex: remoteIndex)
            }
        }
    }
    
    private func handlePwmChannelsStatusCommand(_ command: MeshCommand) {
        let brightness = Int(command.userData[1])
        let cct = Int(command.userData[2])
        let red = Int(command.userData[3])
        let green = Int(command.userData[4])
        let blue = Int(command.userData[5])
        let white = Int(command.userData[6])
        let reserved1 = Int(command.userData[7])
        let reserved2 = Int(command.userData[8])
        let isOn = reserved2 == 0
        
        MLog("handleResponseStatusData red \(red), green \(green), blue \(blue), white \(white), cct \(cct), brightness \(brightness), isOn: \(isOn), r1: \(reserved1), r2: \(reserved2)")
        DispatchQueue.main.async {
            self.deviceDelegate?.meshManager(self, device: command.src, didRespondStatusRed: red, green: green, blue: blue, white: white, cct: cct, brightness: brightness, isOn: isOn, reserved1: reserved1, reserved2: reserved2)
        }
    }
    
    private func handleMultiSensorActionCommand(_ command: MeshCommand) {
        guard let action = MeshCommand.MultiSensorAction.makeActionWithUserData(command.userData) else {
            return
        }
        MLog("handleMultiSensorActionCommand \(action)")
        DispatchQueue.main.async {
            self.multiSensorDelegate?.meshMnaager(self, device: command.src, didGetMultiSensorAction: action)
        }
    }
        
    private func handleFirmwareValue(_ value: Data) {
        
        guard let firmware = String(data: value, encoding: .utf8) else {
            return
        }
        let firmwareTrim = firmware.replacingOccurrences(of: "\0", with: "")
        MLog("handleFirmwareValue firmware \(firmwareTrim)")
        
        DispatchQueue.main.async {
            
            guard let node = self.connectNode else { return }
            self.nodeDelegate?.meshManager?(self, didGetFirmware: firmwareTrim, node: node)
        }
    }
    
    private func handleOtaValue(_ value: Data) {
        
    }
    
    private func handleFirmwareResponseValue(_ value: Data) {
        
        guard let command = MeshCommand(notifyData: value) else {
            return
        }
        
        let versionData = command.userData[0...3]
        guard let version = String(data: versionData, encoding: .utf8) else {
            return
        }
        
        let isStandard = version.contains("V")
        MLog("handleFirmwareResponseValue version \(version), src \(command.src)")
        
        DispatchQueue.main.async {
            
            let currentVersion = isStandard ? version : "V0.1"
            self.deviceDelegate?.meshManager(self, device: command.src, didGetFirmwareVersion: currentVersion)
            
            let event = MqttDeviceFirmwareEvent(shortAddress: command.src, firmwareVersion: currentVersion)
            self.deviceEventDelegate?.meshManager(self, didUpdateEvent: event)
        }
    }
    
    private func handleResponseGroupsValue(_ value: Data) {
        
        guard let command = MeshCommand(notifyData: value) else {
            return
        }
        
        let firstGroup = command.param
        guard firstGroup != 0xFF else { return }
        
        var groups = [firstGroup | 0x8000]
        command.userData.forEach {
            
            if $0 == 0xFF { return }
            let temp = Int($0) | 0x8000
            if groups.contains(temp) { return }
            groups.append(temp)
        }
        MLog("handleResponseGroupsValue \(command.src) didGetGroups \(groups)")
        
        DispatchQueue.main.async {
            
            self.deviceDelegate?.meshManager(self, device: command.src, didGetGroups: groups)
        }
    }
    
    private func handleSceneResponseValue(_ value: Data) {
        
        guard let command = MeshCommand(notifyData: value) else { return }
        
        let sceneID = command.param
        guard sceneID > 0 && sceneID <= 16 else { return }
        
        let brightness = Int(command.userData[0])
        let red = Int(command.userData[1])
        let green = Int(command.userData[2])
        let blue = Int(command.userData[3])
        let ctOrW = Int(command.userData[4])
        let duration = Int(command.userData[5]) | (Int(command.userData[6]) << 8)
        
        var scene = MeshCommand.Scene(sceneID: sceneID)
        scene.brightness = brightness
        scene.red = red
        scene.green = green
        scene.blue = blue
        scene.ctOrW = ctOrW
        scene.duration = duration
        MLog("getScene \(sceneID), \(scene)")
        
        DispatchQueue.main.async {
            
            self.deviceDelegate?.meshManager(self, device: command.src, didGetScene: scene)
        }
    }
    
    private func handleAlarmResponseValue(_ value: Data) {
        
        guard let command = MeshCommand(notifyData: value) else { return }
        guard let alarm = MeshCommand.makeAlarm(command) else { return }
        
        MLog("getAlarm \(command.src), \(alarm)")
        
        DispatchQueue.main.async {
            
            self.deviceDelegate?.meshManager(self, device: command.src, didGetAlarm: alarm)
        }
    }
    
    private func handleRemoteGroupsResponseValue(_ value: Data, isLeading: Bool) {
        
        guard let command = MeshCommand(notifyData: value) else {
            return
        }
        
        var groups: [Int] = []
        
        let group1 = command.param
        if group1 != 0xFF && group1 != 0x00 {
            groups.append(group1 | (Int(command.userData[0]) << 8))
        }
        
        let group2 = Int(command.userData[1])
        if group2 != 0xFF && group2 != 0x00 {
            groups.append(group2 | (Int(command.userData[2]) << 8))
        }
        
        let group3 = Int(command.userData[3])
        if group3 != 0xFF && group3 != 0x00 {
            groups.append(group3 | (Int(command.userData[4]) << 8))
        }
        
        let group4 = Int(command.userData[5])
        if group4 != 0xFF && group4 != 0x00 {
            groups.append(group4 | (Int(command.userData[6]) << 8))
        }
        MLog("handleRemoteGroupsResponseValue \(command.src) didGetGroups \(groups) isLeading \(isLeading)")
        
        DispatchQueue.main.async {
            
            self.deviceDelegate?.meshManager(self, device: command.src, didGetRemoteGroups: groups, isLeading: isLeading)
        }
    }
    
    private func handleCurtainReport(_ command: MeshCommand) {
        let feature = command.userData[1]
        switch feature {
        case 0xAC: // Calibrate
            if var report = MeshCommand.CurtainCalibrationReport(state: command.userData[2]) {
                report.motorStartTime =  (Int(command.userData[3]) << 8) | Int(command.userData[4])
                report.totalTravelTime = (Int(command.userData[5]) << 24) | (Int(command.userData[6]) << 16) | (Int(command.userData[7]) << 8) | Int(command.userData[8])
                NSLog("CurtainCalibrationReport \(report)", "")
            }
        default:
            break
        }
    }
    
}

// MARK: - Fileprivate

extension MeshManager {
        
    fileprivate func updateSendingTimeInterval(_ node: MeshNode) {
        
        self.sendingTimeInterval = (node.deviceType.category == .rfPa) ? 0.8 : 0.5
    }
    
}

// MARK: - RSSI timer

extension MeshManager {
    
    private func startRssiTimer() {
        stopRssiTimer()
        DispatchQueue.main.async {
            self.rssiTimer = Timer.scheduledTimer(timeInterval: self.rssiTimerInterval, target: self, selector: #selector(self.rssiTimerAction(_:)), userInfo: nil, repeats: true)
        }
    }
    
    @objc private func rssiTimerAction(_ timer: Timer) {
        NSLog("rssiTimerAction", "")
        // Check if RSSI of all nodes is lost, if the time diff exceeds twice the rssiMaxTimerInterval,
        // the node is considered to have no signal.
        let valuesCopy = Array(rssiDetectedTimeCache.values)
        let now = Date().timeIntervalSince1970
        for value in valuesCopy {
            if let node = value["node"] as? MeshNode,
               let date = value["date"] as? TimeInterval {
                let overtime = now - date
                if overtime >= rssiMaxTimerInterval {
                    // This node has no signal.
                    DispatchQueue.main.async {
                        self.nodeRssiDelegate?.meshManager(self, didDiscoverNode: node, rssiLevel: .none)
                    }
                } else {
                    // If there is not timeout, update RSSI normally.
                    DispatchQueue.main.async {
                        self.nodeRssiDelegate?.meshManager(self, didDiscoverNode: node, rssiLevel: RssiLevel.getRssiLevel(node.rssi))
                    }
                }
            }
        }
    }
    
    private func detectNodeRssi(_ node: MeshNode) {
        // If it's a new device, update the rssi now, otherwise, don't update it.
        if !rssiDetectedTimeCache.contains(where: { (key, value) in node.macAddress == key }) {
            DispatchQueue.main.async {
                self.nodeRssiDelegate?.meshManager(self, didDiscoverNode: node, rssiLevel: RssiLevel.getRssiLevel(node.rssi))
            }
        }
        rssiDetectedTimeCache[node.macAddress] = ["node": node, "date": Date().timeIntervalSince1970]
    }
    
    private func stopRssiTimer() {
        DispatchQueue.main.async {
            self.rssiDetectedTimeCache.removeAll()
            self.rssiTimer?.invalidate()
        }
    }
}
