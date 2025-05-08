//
//  BleUartModuleDevicesController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by 王文东 on 2023/8/22.
//

import UIKit
import TelinkBleMesh

class BleUartModuleDevicesController: UITableViewController {    
    
    weak var device: MyDevice!
    var network: MeshNetwork!
    
    private var devices: [UartDaliDevice] = []
    
    private var gatewayAddress: Int {
        return Int(device.meshDevice.address)
    }
    
    private let sections: [[CellType]] = [
        [.discoverDevices], [.stop], [.device]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Uart Module Devices"
        
        devices = UartDaliManager.shared.getExistDevices(gatewayAddress)
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addAction))
        navigationItem.rightBarButtonItem = add
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch cellType(at: indexPath) {
        case .discoverDevices:
            devices.removeAll()
            tableView.reloadData()
            UartDaliManager.shared.delegate = self
            UartDaliManager.shared.discoverDevices(gatewayAddress: gatewayAddress)
            
        case .stop:
            UartDaliManager.shared.stopDiscoverDevices(gatewayAddress: gatewayAddress)
            
        case .device:
            deviceClicked(devices[indexPath.row])
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].first == .device ? devices.count : sections[section].count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].first == .device ? "\(devices.count)" : nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if cellType(at: indexPath) == .device {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "device") ??
            UITableViewCell(style: .value1, reuseIdentifier: "device")
            let device = devices[indexPath.row]
            cell.textLabel?.text = device.commonName
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ??
        UITableViewCell(style: .value1, reuseIdentifier: "cell")
        let cellType = sections[indexPath.section][indexPath.row]
        cell.textLabel?.text = cellType.title
        return cell
    }
    
    enum CellType {
        
        case discoverDevices
        case stop
        case device
        
        var title: String {
            switch self {
            case .discoverDevices: return "Discover Devices"
            case .stop: return "Stop Discover Devices"
            case .device: return ""
            }
        }
    }
    
    private func cellType(at indexPath: IndexPath) -> CellType {
        if sections[indexPath.section].first == .device { return .device }
        return sections[indexPath.section][indexPath.row]
    }
    
    private func deviceClicked(_ device: UartDaliDevice) {
        
        let controller = BleUartModuleDeviceController(style: .grouped)
        controller.daliDevice = device
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension BleUartModuleDevicesController: UartDaliManagerDelegate {    
    
    func uartDaliManager(_ manager: TelinkBleMesh.UartDaliManager, didExecuteCommandOK daliAddress: Int, gatewayAddress: Int) {
        guard self.gatewayAddress == gatewayAddress else { return }
        NSLog("didExecuteCommandOK \(daliAddress)", "")
    }
    
    func uartDaliManager(_ manager: TelinkBleMesh.UartDaliManager, didExecuteCommandFailed daliAddress: Int, gatewayAddress: Int, reason: TelinkBleMesh.UartDaliManager.CommandFailedReason, cmdType: TelinkBleMesh.UartDaliManager.ResponseCommandType, cmd: Any?) {
        guard self.gatewayAddress == gatewayAddress else { return }
        guard let cmd = cmd else { return }
        NSLog("didExecuteCommandFailed \(daliAddress), \(reason), \(cmdType), \(cmd)", "")
    }
    
    func uartDaliManager(_ manager: UartDaliManager, didUpdateDeviceList devices: [UartDaliDevice], gatewayAddress: Int) {
        guard self.gatewayAddress == gatewayAddress else { return }
        self.devices = devices
        tableView.reloadData()
    }
    
    func uartDaliManager(_ manager: TelinkBleMesh.UartDaliManager, didDiscoverEnd gatewayAddress: Int, reason: UartDaliManager.DiscoverEndReason) {
        guard self.gatewayAddress == gatewayAddress else { return }
        NSLog("didDiscoverEnd \(reason)", "")
    }
}

extension BleUartModuleDevicesController: BleUartModuleDeviceControllerDelegate {
    
    func bleUartModuleDeviceControllerDidUpdateDevice(_ controller: BleUartModuleDeviceController) {
        reloadDevices()
        controller.navigationController?.popViewController(animated: true)
    }
    
    private func reloadDevices() {
        devices = UartDaliManager.shared.getExistDevices(gatewayAddress)
        tableView.reloadData()
    }
}

extension BleUartModuleDevicesController {
    
    @objc private func addAction() {
        let alert = UIAlertController(title: "Add New Device", message: nil, preferredStyle: .alert)
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.width / 2, y: 88, width: 1, height: 1)
        var addressTextField: UITextField!
        alert.addTextField() { tf in
            addressTextField = tf
            addressTextField.keyboardType = .numberPad
            addressTextField.placeholder = "DALI Address 0-63"
        }
        let types: [UartDaliDevice.DeviceType] = [
            .dt6, .dt8Cct, .dt8Xy, .dt8Rgbw, .dt8Rgbwa
        ]
        types.forEach { item in
            let itemAction = UIAlertAction(title: item.rawValue, style: .default) { _ in
                self.doAddNewDevice(addressText: addressTextField.text, deviceType: item)
            }
            alert.addAction(itemAction)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    private func doAddNewDevice(addressText: String?, deviceType: UartDaliDevice.DeviceType) {
        guard let addressText = addressText, let address = Int(addressText) else {
            NSLog("address is not a int", "")
            return
        }
        guard address >= 0 && address <= 63 else {
            NSLog("address is out of 0-63", "")
            return
        }
        let device = UartDaliDevice(daliAddress: address, gatewayAddress: gatewayAddress, deviceType: deviceType)
        if UartDaliManager.shared.addNewDeviceManually(device) {
            self.reloadDevices()
        } else {
            NSLog("add new device failed, address exists", "")
        }
    }
}
