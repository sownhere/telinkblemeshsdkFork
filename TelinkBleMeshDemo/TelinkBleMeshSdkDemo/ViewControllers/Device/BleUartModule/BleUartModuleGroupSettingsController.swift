//
//  BleUartModuleGroupSettingsController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by 王文东 on 2023/9/5.
//

import UIKit
import TelinkBleMesh

class BleUartModuleGroupSettingsController: UITableViewController {
    
    var gatewayAddress: Int = 0
    var group: Int = 0x80
    private var devices: [UartDaliDevice] = []
    private var loadIndex: Int = 0
    private var isLoading = false
    private var addingDaliAddress = 0
    private var removingDaliAddress = 0
    
    private enum Status {
        case loading
        case exists
        case noExists
        case error
        
        var title: String {
            switch self {
            case .loading: return "Loading..."
            case .exists: return "Delete"
            case .noExists: return "Add"
            case .error: return "Error"
            }
        }
    }
    /// [daliAddress: Status]
    private var devStatus: [Int: Status] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "G\(group & 0x0F)"
        devices = UartDaliManager.shared.getExistDevices(gatewayAddress)
        
        UartDaliManager.shared.delegate = self
        loadGroups()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if isLoading { return }
        
        let device = devices[indexPath.row]
        let status = devStatus[device.daliAddress]
        switch status {
        case .none: fallthrough
        case .loading:
            break
            
        case .error:
            loadDeviceGroup(indexPath: indexPath)
            
        case .exists:
            removingDaliAddress = device.daliAddress
            UartDaliManager.shared.removeDeviceFromGroup(gatewayAddress: gatewayAddress, daliAddress: device.daliAddress, group: group)
            
        case .noExists:
            addingDaliAddress = device.daliAddress
            UartDaliManager.shared.addDeviceToGroup(gatewayAddress: gatewayAddress, daliAddress: device.daliAddress, group: group)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .value1, reuseIdentifier: "cell")
        let dev = devices[indexPath.row]
        cell.textLabel?.text = dev.deviceType.rawValue + " \(dev.daliAddress)"
        cell.detailTextLabel?.text = getDeviceStatus(daliAddress: dev.daliAddress).title
        return cell
    }
    
}

extension BleUartModuleGroupSettingsController {
    
    private func deviceSelectedHandler(_ device: UartDaliDevice) {
        let alert = UIAlertController(title: "\(device.daliAddress)", message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let getGroups = UIAlertAction(title: "Get Groups", style: .default) { _ in
            UartDaliManager.shared.getDeviceGroups(gatewayAddress: self.gatewayAddress, daliAddress: device.daliAddress, group: self.group)
        }
        alert.addAction(getGroups)
        let addGroup = UIAlertAction(title: "Add Group", style: .default) { _ in
            UartDaliManager.shared.addDeviceToGroup(gatewayAddress: self.gatewayAddress, daliAddress: device.daliAddress, group: self.group)
        }
        alert.addAction(addGroup)
        let removeGroup = UIAlertAction(title: "Remove Group", style: .default) { _ in
            UartDaliManager.shared.removeDeviceFromGroup(gatewayAddress: self.gatewayAddress, daliAddress: device.daliAddress, group: self.group)
        }
        alert.addAction(removeGroup)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    private func loadGroups() {
        loadIndex = 0
        if devices.count <= loadIndex { return }
        devStatus.removeAll()
        isLoading = true
        let dev = devices[loadIndex]
        UartDaliManager.shared.getDeviceGroups(gatewayAddress: gatewayAddress, daliAddress: dev.daliAddress, group: group)
        devStatus[dev.daliAddress] = .loading
    }
    
    private func loadNext() {
        loadIndex += 1
        if loadIndex >= devices.count {
            NSLog("Loading end", "")
            isLoading = false
            return
        }
        let dev = devices[loadIndex]
        UartDaliManager.shared.getDeviceGroups(gatewayAddress: gatewayAddress, daliAddress: dev.daliAddress, group: group)
        devStatus[dev.daliAddress] = .loading
    }
    
    private func loadDeviceGroup(indexPath: IndexPath) {
        let dev = devices[indexPath.row]
        UartDaliManager.shared.getDeviceGroups(gatewayAddress: gatewayAddress, daliAddress: dev.daliAddress, group: group)
        devStatus[dev.daliAddress] = .loading
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    private func getDeviceStatus(daliAddress: Int) -> Status {
        return devStatus[daliAddress] ?? .loading
    }
}

extension BleUartModuleGroupSettingsController: UartDaliManagerDelegate {
    
    func uartDaliManager(_ manager: UartDaliManager, didExecuteCommandOK daliAddress: Int, gatewayAddress: Int, cmdType: UartDaliManager.ResponseCommandType, cmd: Any?) {
        guard self.gatewayAddress == gatewayAddress else {
            NSLog("ohter gatewayAddress \(gatewayAddress)", "")
            return
        }
        NSLog("didExecuteCommandOK daliAddr \(daliAddress), cmd \(cmdType) \(cmd)", "")
    }
    
    func uartDaliManager(_ manager: UartDaliManager, didExecuteCommandFailed daliAddress: Int, gatewayAddress: Int, reason: UartDaliManager.CommandFailedReason, cmdType: UartDaliManager.ResponseCommandType, cmd: Any?) {
        guard self.gatewayAddress == gatewayAddress else {
            NSLog("ohter gatewayAddress \(gatewayAddress)", "")
            return
        }
        NSLog("didExecuteCommandFailed daliAddr \(daliAddress), cmd \(cmdType) \(cmd), reason \(reason)", "")
        
        if devices[loadIndex].daliAddress == daliAddress, cmdType == .query, let cmd = cmd as? MeshCommand.UartDali.Query {
            // if current group > 7, the target cmd must be groups8_15, otherwise it's groups0_7
            let targetCmd = group > 7 ? MeshCommand.UartDali.Query.groups8_15 : .groups0_7
            if cmd == targetCmd {
                devStatus[daliAddress] = .error
                tableView.reloadRows(at: [IndexPath(row: loadIndex, section: 0)], with: .automatic)
                loadNext()
            }
        }
    }
    
    func uartDaliManager(_ manager: UartDaliManager, didGetDeviceGroups groups: [Int], gatewayAddress: Int, daliAddress: Int) {
        guard self.gatewayAddress == gatewayAddress else {
            NSLog("ohter gatewayAddress \(gatewayAddress)", "")
            return
        }
        NSLog("didGetDeviceGroups \(groups), daliAddress \(daliAddress)", "")
        if devices[loadIndex].daliAddress == daliAddress {
            let isExists = groups.contains(group)
            devStatus[daliAddress] = isExists ? .exists : .noExists
            tableView.reloadRows(at: [IndexPath(row: loadIndex, section: 0)], with: .automatic)
            loadNext()
        }
    }
    
    func uartDaliManager(_ manager: UartDaliManager, didAddDeviceToGroup gatewayAddress: Int, daliAddress: Int) {
        guard gatewayAddress == self.gatewayAddress, addingDaliAddress == daliAddress else { return }
        devStatus[addingDaliAddress] = .exists
        tableView.reloadData()
    }
    
    func uartDaliManager(_ manager: UartDaliManager, didRemoveDeviceFromGroup gatewayAddress: Int, daliAddress: Int) {
        guard gatewayAddress == self.gatewayAddress, removingDaliAddress == daliAddress else { return }
        devStatus[removingDaliAddress] = .noExists
        tableView.reloadData()
    }
}
