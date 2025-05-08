//
//  File.swift
//  
//
//  Created by 王文东 on 2023/5/5.
//

import Foundation

/**
 用于修复短地址重复问题。
 */
public protocol DeviceRepairManagerDelegate: NSObjectProtocol {
    
    /**
     连接设备失败。
     */
    func deviceRepairManagerFailedToConnect(_ manager: DeviceRepairManager)
    
    /**
     连接设备成功，下一步修复。
     */
    func deviceRepairManagerConnected(_ manager: DeviceRepairManager)
    
    /**
     在修复过程中，设备断开连接。
     */
    func deviceRepairManagerDisconnected(_ manager: DeviceRepairManager)
    
    /**
     修复成功，并返回修复设备的 Mac（iOS 只有后 4 个字节）及修复后的新短地址。
     */
    func deviceRepairManagerRepairSucceeded(_ manager: DeviceRepairManager, mac: String, newAddress: Int)
}

/**
 用于修复设备短地址重复。
 */
public class DeviceRepairManager: NSObject {
    
    public static let shared = DeviceRepairManager()
    
    public weak var delegate: DeviceRepairManagerDelegate?
    
    private var network: MeshNetwork = .factory
    private var timer: Timer?
    
    private let scanningInterval: TimeInterval = 4
    private let connectingInterval: TimeInterval = 8
    private let addressChangingInterval: TimeInterval = 8
    
    private var node: MeshNode?
    private var existAddresses: Set<Int> = []
    private let allAddresses: Set<Int> = Set<Int>.init(1...253)
    private var newAddress: Int?
    
    private override init() {
        super.init()
    }
    
    private enum State {
        case none
        case connecting
        case connected
        case changing
    }
    private var state: State = .none
    
    /**
     开始修复，传入需要修复的 MeshNode。
     */
    public func startRepair(_ node: MeshNode) {
        
        MLog("Start repair \(node)")
        
        state = .connecting
        self.node = node
        existAddresses.removeAll()
        newAddress = nil
        
        MeshManager.shared.stopScanNode()
        MeshManager.shared.disconnect()
        MeshManager.shared.nodeDelegate = self
        MeshManager.shared.deviceDelegate = self
        startConnectTimer()
        MeshManager.shared.connect(node)
    }
    
    /**
     立即中止修复。
     */
    public func stopRepair() {
        
        MLog("Stop repair")
        state = .none
        existAddresses.removeAll()
        cancelTimer()
        newAddress = nil
        
        MeshManager.shared.nodeDelegate = nil
        MeshManager.shared.deviceDelegate = nil
        MeshManager.shared.stopScanNode()
        MeshManager.shared.disconnect()
    }
    
}

extension DeviceRepairManager: MeshManagerNodeDelegate {
    
    public func meshManager(_ manager: MeshManager, didLoginNode node: MeshNode) {
        
        MLog("Repair didLoginNode")
        timer?.invalidate()
        guard state == .connecting else { return }
        state = .connected
        delegate?.deviceRepairManagerConnected(self)
        MeshCommand.identify(MeshCommand.Address.connectedNode).send()
        // Connected, then scan devices.
        startScanMeshDevicesTimer()
        manager.scanMeshDevices()
    }
    
    public func meshManager(_ manager: MeshManager, didFailToConnectNodeIdentifier identifier: UUID) {
        
        MLog("Repair didFailToConnectNodeIdentifier")
        timer?.invalidate()
        guard state == .connecting else { return }
        state = .none
        delegate?.deviceRepairManagerFailedToConnect(self)
    }
    
    public func meshManager(_ manager: MeshManager, didFailToLoginNodeIdentifier identifier: UUID) {
        
        MLog("Repair didFailToLoginNodeIdentifier")
        timer?.invalidate()
        guard state == .connecting else { return }
        state = .none
        delegate?.deviceRepairManagerFailedToConnect(self)
    }
    
    public func meshManager(_ manager: MeshManager, didDisconnectNodeIdentifier identifier: UUID) {
        
        MLog("Repair didDisconnectNodeIdentifier")
        guard state == .connected else { return }
        state = .none
        delegate?.deviceRepairManagerDisconnected(self)
    }
    
    public func meshManager(_ manager: MeshManager, didGetDeviceAddress address: Int) {
        
        MLog("Repair didGetDeviceAddress \(address)")
        if state == .connected {
            MLog("state is connected, insert address and restart timer.")
            existAddresses.insert(address)
            startScanMeshDevicesTimer()
        } else if state == .changing {
            MLog("state is changing, if the address is the new address, changing end.")
            if address == newAddress {
                MLog("new address is the address, change succeeded.")
                stopRepair()
                delegate?.deviceRepairManagerRepairSucceeded(self, mac: self.node?.macAddress ?? "NONE", newAddress: address)
            }
        } else {
            MLog("state is \(state), nothing will happen.")
        }
    }
    
    public func meshManager(_ manager: MeshManager, didUpdateMeshDevices meshDevices: [MeshDevice]) {
        
        MLog("didUpdateMeshDevices")
    }
    
    private func startConnectTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: connectingInterval, target: self, selector: #selector(self.connectTimerEnd), userInfo: nil, repeats: false)
    }
    
    @objc private func connectTimerEnd() {
        MLog("connect timer timeover, stop and failed to connect.")
        stopRepair()
        delegate?.deviceRepairManagerFailedToConnect(self)
    }
    
    private func startScanMeshDevicesTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: scanningInterval, target: self, selector: #selector(self.scanMeshDevicesTimerEnd), userInfo: nil, repeats: false)
    }
    
    // Scan mesh devices finish.
    @objc private func scanMeshDevicesTimerEnd() {
        MLog("scan mesh devices timer end, will get available address and set a new one.")
        state = .changing
        timer?.invalidate()
        // Get valid address.
        let availableAddresses = allAddresses.subtracting(existAddresses)
        if let newAddress = availableAddresses.randomElement() {
            MLog("There is a new address \(newAddress), i will set it.")
            self.newAddress = newAddress
            startChangingTimer()
            MeshCommand.changeAddress(MeshCommand.Address.connectedNode, withNewAddress: newAddress).send()
        } else {
            MLog("There are no available addresses, disconnect the node.")
            stopRepair()
            delegate?.deviceRepairManagerDisconnected(self)
        }
    }
    
    private func cancelTimer() {
        timer?.invalidate()
    }
    
    private func startChangingTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: addressChangingInterval, target: self, selector: #selector(self.changingTimerEnd), userInfo: nil, repeats: false)
    }
    
    @objc private func changingTimerEnd() {
        MLog("changing timer timeout, disconnect and change failed.")
        stopRepair()
        delegate?.deviceRepairManagerDisconnected(self)
    }
}

extension DeviceRepairManager: MeshManagerDeviceDelegate {
    
}
