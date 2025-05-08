//
//  BindMultiSensorViewController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by 王文东 on 2024/8/24.
//

import UIKit
import TelinkBleMesh

class BindMultiSensorViewController: UITableViewController {
    
    var address: Int = 0
    // 1-4
    var sensorIndex: Int = 1
    
    private let cells: [CellType] = [
        .sensorId, .action1, .action2, .link,
        .unlink
    ]
    
    private var isLinking = false
    
    private var sensorId = "00000000"
    private var action1: MeshCommand.MultiSensorAction!
    private var action2: MeshCommand.MultiSensorAction!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        action1 = MeshCommand.MultiSensorAction.makeUndefinedAction(UInt8(sensorIndex), actionIndex: 1)
        action2 = MeshCommand.MultiSensorAction.makeUndefinedAction(UInt8(sensorIndex), actionIndex: 2)
        
        MeshManager.shared.multiSensorDelegate = self
        let requestCommands: [MeshCommand] = [
            MeshCommand.getLinkedMultiSensorId(address, sensorIndex: sensorIndex),
            MeshCommand.getLinkedMultiSensorAction(address, sensorIndex: sensorIndex, actionIndex: 1),
            MeshCommand.getLinkedMultiSensorAction(address, sensorIndex: sensorIndex, actionIndex: 2),
        ]
        MeshManager.shared.sendCommands(requestCommands, intervalSeconds: 0.5)

        navigationItem.title = "Sensor \(sensorIndex)"
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch cells[indexPath.row] {
        case .sensorId:
            discoverSensor()
        case .action1:
            selectActionAtActionIndex(1)
        case .action2:
            selectActionAtActionIndex(2)
        case .link:
            linkActions()
        case .unlink:
            unlink()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .value1, reuseIdentifier: "cell")
        let cellType = cells[indexPath.row]
        cell.textLabel?.text = "\(cellType)"
        cell.detailTextLabel?.text = nil
        switch cellType {
        case .sensorId:
            cell.detailTextLabel?.text = sensorId
        case .action1:
            cell.detailTextLabel?.text = "\(action1.desc)"
        case .action2:
            cell.detailTextLabel?.text = "\(action2.desc)"
        default:
            break
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    enum CellType {
        case sensorId
        case action1
        case action2
        case link
        case unlink 
    }
    
    private func discoverSensor() {
        let controller = DiscoverSensorViewController(style: .grouped)
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func selectActionAtActionIndex(_ index: UInt8) {
        let controler = SelectMultiSensorActionController(style: .grouped)
        controler.delegate = self
        controler.actionIndex = index
        let nav = UINavigationController(rootViewController: controler)
        navigationController?.present(nav, animated: true)
    }
    
    private func linkActions() {
        isLinking = true
        guard let sensorIdValue = Int(sensorId, radix: 16) else {
            NSLog("Invalid sensor ID \(sensorId)", "")
            return
        }
        let commands = MeshCommand.linkMultiSensor(address, sensorId: sensorIdValue, action1: action1, action2: action2, sensorType: .waterLeak)
        let interval: TimeInterval = 0.5
        MeshManager.shared.sendCommands(commands, intervalSeconds: interval)
        let alert = UIAlertController.makeNormal(title: "Linking...", message: nil, preferredStyle: .alert, viewController: self)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500 * commands.count), execute: {
            alert.dismiss(animated: true)
        })
    }
    
    private func unlink() {
        MeshCommand.unlinkMultiSensorId(address, sensorIndex: sensorIndex).send()
        NSLog("Unlink multi sensor index \(sensorIndex)", "")
    }

}

extension BindMultiSensorViewController: DiscoverSensorViewControllerDelegate {
    func discoverSensorViewController(_ controller: DiscoverSensorViewController, didSelectSensor sensor: MeshNode) {
        sensorId = sensor.macAddress
        tableView.reloadData()
    }
}

extension BindMultiSensorViewController: SelectMultiSensorActionControllerDelegate {
    func selectMultiSensorActionController(_ controller: SelectMultiSensorActionController, didSelectActionNo actionNo: MeshCommand.MultiSensorAction.ActionNo, args: [Int], at actionIndex: UInt8) {
        let action = MeshCommand.MultiSensorAction.makeActionWithActionNo(UInt8(sensorIndex), actionIndex: actionIndex, actionNo: actionNo, args: args)
        if actionIndex == 1 {
            action1 = action
        } else if actionIndex == 2 {
            action2 = action
        }
        tableView.reloadData()
    }
}

extension BindMultiSensorViewController: MeshManagerMultiSensorDelegate {
    func meshManager(_ manager: MeshManager, device address: Int, didGetMultiSensorId sensorId: Int, sensorIndex: Int) {
        guard isLinking == false else {
            NSLog("isLinking", "")
            return
        }
        guard self.address == address, self.sensorIndex == sensorIndex else {
            NSLog("address \(address) or \(sensorIndex) is not the same", "")
            return
        }
        self.sensorId = sensorId.hex
        tableView.reloadData()
    }
    
    func meshMnaager(_ manager: MeshManager, device address: Int, didGetMultiSensorAction action: MeshCommand.MultiSensorAction) {
        guard isLinking == false else {
            NSLog("isLinking", "")
            return
        }
        guard self.address == address else {
            NSLog("address \(address) is not the same.", "")
            return
        }
        if action.actionIndex == 1 {
            action1 = action
        } else if action.actionIndex == 2 {
            action2 = action
        }
        self.tableView.reloadData()
    }
}
