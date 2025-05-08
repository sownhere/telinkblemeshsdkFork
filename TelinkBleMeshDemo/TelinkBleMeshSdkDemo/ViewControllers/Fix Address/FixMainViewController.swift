//
//  FixMainViewController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by 王文东 on 2023/7/18.
//

import UIKit
import TelinkBleMesh
import Toast

protocol FixMainViewControllerDelegate: NSObjectProtocol {
    
    func fixMainViewController(_ controller: FixMainViewController, didFix newAddress: Int, mac: String)
}

class FixMainViewController: UITableViewController {
    
    weak var delegate: FixMainViewControllerDelegate?
    
    var network: MeshNetwork = .factory
    private var nodes: [MeshNode] = []
    private var repeatNodes: [MeshNode] = []
    private var newAddressList: [Int] = []
    private var devices: [MyDevice] = []
    private var sections: [SectionType] = [
        .state, .repeatNodes, .devices
    ]
    private var states: [StateType] = [
        .nodeCount, .repeatCount, .deviceCount, .reloadDevices,
            .allOn, .allOff
    ]
    private var availableAddressList: [Int] = []
    private var oldAddress: Int = 0
    private var newAddress: Int = 0
    private var fixedMacList = Set<String>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = network.name
        
        let refreshItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.reloadDevices))
        navigationItem.rightBarButtonItem = refreshItem
        
        nodes = FixNodesManager.shared.networkNodes(network)
        repeatNodes = FixNodesManager.shared.shortAddressRepeatNodes(network).sorted(by: { $0.shortAddress < $1.shortAddress })
        newAddressList = FixNodesManager.shared.newAddressList(network)

        reloadDevices()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch sections[indexPath.section] {
        case .state:
            switch states[indexPath.row] {
            case .reloadDevices:
                reloadDevices()
            case .allOn:
                MeshCommand.turnOnOff(0xFFFF, isOn: true).send()
            case .allOff:
                MeshCommand.turnOnOff(0xFFFF, isOn: false).send()
            default:
                break
            }
            
        case .repeatNodes:
            let node = repeatNodes[indexPath.row]
            let filterDevices = devices.filter({ !fixedMacList.contains($0.mac) })
            if let device = filterDevices.first(where: { Int($0.meshDevice.address) == Int(node.shortAddress) }) {
                
                if let macData = device.macData {
                    
                    view.makeToastActivity(.center)
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) { [weak self] in
                        self?.view.hideToastActivity()
                    }
                    
                    oldAddress = Int(device.meshDevice.address)
                    newAddress = availableAddressList.removeLast()
                    MeshCommand.changeAddress(Int(device.meshDevice.address), withNewAddress: newAddress, macData: macData).send()
                    NSLog("Change address \(device.meshDevice.address) with new address \(newAddress), mac \(device.mac)", "")
                    
                } else {
                    
                    self.view.makeToast("NoMacFoundMsg".localization, position: .center)
                }
                
            } else {
                
                self.view.makeToast("NoDeviceFoundMsg".localization, position: .center)
            }
            
        case .devices:
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.popoverPresentationController?.sourceView = view
            alert.popoverPresentationController?.sourceRect = CGRect(x: 40, y: 40, width: 1, height: 1)
            let device = devices[indexPath.row]
            let allOn = UIAlertAction(title: "On".localization, style: .default) { _ in
                MeshCommand.turnOnOff(Int(device.meshDevice.address), isOn: true).send()
            }
            let allOff = UIAlertAction(title: "Off".localization, style: .default) { _ in
                MeshCommand.turnOnOff(Int(device.meshDevice.address), isOn: false).send()
            }
            let cancel = UIAlertAction(title: "cancel".localization, style: .cancel)
            alert.addAction(allOn)
            alert.addAction(allOff)
            alert.addAction(cancel)
            navigationController?.present(alert, animated: true)
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch sections[section] {
        case .state:
            return states.count
            
        case .repeatNodes:
            return repeatNodes.count
            
        case .devices:
            return devices.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return sections[section].title
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch sections[indexPath.section] {
        case .state:
            let cell = tableView.dequeueReusableCell(withIdentifier: "state") ?? UITableViewCell(style: .value1, reuseIdentifier: "state")
            let stateType = states[indexPath.row]
            cell.textLabel?.text = stateType.title
            switch stateType {
            case .nodeCount:
                cell.detailTextLabel?.text = "\(nodes.count)"
            case .repeatCount:
                cell.detailTextLabel?.text = "\(repeatNodes.count)"
            case .deviceCount:
                cell.detailTextLabel?.text = "\(devices.count)"
            case .reloadDevices: fallthrough
            case .allOn: fallthrough
            case .allOff:
                cell.detailTextLabel?.text = nil
            }
            return cell
            
        case .repeatNodes:
            let cell = tableView.dequeueReusableCell(withIdentifier: "node") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "node")
            let node = repeatNodes[indexPath.row]
            cell.textLabel?.text = node.title
            cell.detailTextLabel?.text = node.detail
            cell.textLabel?.textColor = .red
            return cell
            
        case .devices:
            let cell = tableView.dequeueReusableCell(withIdentifier: "device") ??
                UITableViewCell(style: .subtitle, reuseIdentifier: "device")
            let device = devices[indexPath.row]
            cell.textLabel?.text = device.title
            cell.detailTextLabel?.text = device.detail
            return cell
        }
    }

}

extension FixMainViewController {
    
    enum SectionType {
        case state
        case repeatNodes
        case devices
        
        var title: String {
            switch self {
            case .state: return ""
            case .repeatNodes: return "RepeatNodes".localization
            case .devices: return "Devices".localization
            }
        }
    }
    
    enum StateType {
        case nodeCount
        case repeatCount
        case deviceCount
        case reloadDevices
        case allOn
        case allOff
        
        var title: String {
            switch self {
            case .nodeCount: return "NodeCount".localization
            case .repeatCount: return "RepeatCount".localization
            case .deviceCount: return "DeviceCount".localization
            case .reloadDevices: return "ReloadDevices".localization
            case .allOn: return "AllOn".localization
            case .allOff: return "AllOff".localization
            }
        }
    }
    
    @objc private func reloadDevices() {
        
        availableAddressList = newAddressList
        devices.removeAll()
        tableView.reloadData()
        
        MeshManager.shared.deviceDelegate = self
        MeshManager.shared.scanMeshDevices()
    }
}

extension FixMainViewController: MeshManagerDeviceDelegate {
    
    func meshManager(_ manager: MeshManager, didUpdateMeshDevices meshDevices: [MeshDevice]) {
        
        meshDevices.forEach { [weak self] meshDevice in
            
            guard let self = self else { return }
            
            let device = MyDevice(meshDevice: meshDevice)
            availableAddressList.removeAll(where: {
                $0 == Int(device.meshDevice.address)
            })
            
            // Update old device info.
            if let oldDevice = self.devices.first(where: { $0 == device }) {
                
                oldDevice.meshDevice = meshDevice
                return
            }
            
            self.devices.append(device)
            
            let command = MeshCommand.requestMacDeviceType(Int(meshDevice.address))
            MeshManager.shared.send(command)
        }
        
        tableView.reloadData()
    }
    
    func meshManager(_ manager: MeshManager, device address: Int, didUpdateDeviceType deviceType: MeshDeviceType, macData: Data) {
        
        if let device = devices.first(where: { $0.meshDevice.address == address }) {
            
            device.deviceType = deviceType
            device.macData = macData
            
            if address == newAddress {
                
                fixedMacList.insert(device.mac)
                delegate?.fixMainViewController(self, didFix: address, mac: device.mac)
                
                repeatNodes.removeAll(where: { device.mac.contains($0.macAddress) })
                var otherCount = 0
                repeatNodes.forEach {
                    if $0.shortAddress == oldAddress {
                        otherCount += 1
                    }
                }
                if otherCount <= 1 {
                    repeatNodes.removeAll(where: { $0.shortAddress == oldAddress })
                }
            }
            tableView.reloadData()
        }
    }
}
