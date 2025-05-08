//
//  BleUartModuleController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by 王文东 on 2023/8/22.
//

import UIKit
import TelinkBleMesh

class BleUartModuleController: UITableViewController {
    
    weak var device: MyDevice!
    var network: MeshNetwork!
    
    private let sections: [[CellType]] = [
        [.devices, .groups, .scenes],
        [.commands],
        [.smartSwitches]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = device.title
        
        let settingsItem = UIBarButtonItem(title: "settings".localization, style: .plain, target: self, action: #selector(self.settingsAction(_:)))
        navigationItem.rightBarButtonItem = settingsItem
        
        MeshManager.shared.setUartDaliGateway(address: Int(device.meshDevice.address))
    }
    
    deinit {
        MeshManager.shared.resetUartDaliGateway()
    }
    
    @objc func settingsAction(_ sender: Any) {
        
        let controller = DeviceSettingsViewController(style: .grouped)
        controller.device = device
        controller.network = network
        navigationController?.pushViewController(controller, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch sections[indexPath.section][indexPath.row] {
        case .devices:
            let controller = BleUartModuleDevicesController(style: .grouped)
            controller.device = device
            controller.network = .factory
            navigationController?.pushViewController(controller, animated: true)
            
        case .groups:
            let controller = BleUartModuleGroupsController(style: .grouped)
            controller.gatewayAddress = Int(device.meshDevice.address)
            navigationController?.pushViewController(controller, animated: true)
            
        case .scenes:
            let controller = BleUartModuleScenesController(style: .grouped)
            controller.gatewayAddress = Int(device.meshDevice.address)
            navigationController?.pushViewController(controller, animated: true)
            
        case .commands:
            let controler = BleUartModuleCommandsController(style: .grouped)
            controler.gatewayAddress = Int(device.meshDevice.address)
            navigationController?.pushViewController(controler, animated: true)
            
        case .smartSwitches:
            let controller = DaliSmartSwitchesController(style: .grouped)
            controller.gatewayAddress = Int(device.meshDevice.address)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ??
        UITableViewCell(style: .value1, reuseIdentifier: "cell")
        let cellType = sections[indexPath.section][indexPath.row]
        cell.textLabel?.text = cellType.title
        return cell
    }
    
    enum CellType {
        case devices
        case groups
        case scenes
        
        case commands
        
        case smartSwitches
        
        var title: String {
            switch self {
            case .devices: return "Devices"
            case .groups: return "Groups"
            case .scenes: return "Scenes"
                
            case .commands: return "Commands"
                
            case .smartSwitches: return "Smart Switches"
            }
        }
    }
}
