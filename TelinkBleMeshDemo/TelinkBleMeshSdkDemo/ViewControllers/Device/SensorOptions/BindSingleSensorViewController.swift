//
//  BindSingleSensorViewController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by 王文东 on 2024/8/26.
//

import UIKit
import TelinkBleMesh

class BindSingleSensorViewController: UITableViewController {
    
    var address: Int = 0
    var sensorType: MeshCommand.SingleSensorAction.SensorType = .doorContactSensor
    
    private let cells: [CellType] = [
        .sensorId, .action1, .action2, .link,
        .unlink
    ]
    
    private var isLinking = false
    
    private var sensorId = "00000000"
    private var action1: MeshCommand.SingleSensorAction!
    private var action2: MeshCommand.SingleSensorAction!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        action1 = MeshCommand.SingleSensorAction(sensorType: sensorType, actionIndex: 1, actionNo: .undefined)
        action2 = MeshCommand.SingleSensorAction(sensorType: sensorType, actionIndex: 2, actionNo: .undefined)
        
        MeshManager.shared.singleSensorDelegate = self
        let requestCommands = [
            MeshCommand.getLinkedSingleSensorId(address, sensorType: sensorType),
            MeshCommand.getLinkedSingleSensorAction(address, sensorType: sensorType, actionIndex: 1),
            MeshCommand.getLinkedSingleSensorAction(address, sensorType: sensorType, actionIndex: 2),
        ]
        MeshManager.shared.sendCommands(requestCommands, intervalSeconds: 0.5)

        navigationItem.title = "\(sensorType)"
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
        cell.detailTextLabel?.numberOfLines = 0
        switch cellType {
        case .sensorId:
            cell.detailTextLabel?.text = sensorId
        case .action1:
            cell.detailTextLabel?.text = action1.desc
        case .action2:
            cell.detailTextLabel?.text = action2.desc
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
        let controller = SelectSingleSensorActionController(style: .grouped)
        controller.delegate = self
        controller.actionIndex = index
        controller.sensorType = sensorType
        let nav = UINavigationController(rootViewController: controller)
        navigationController?.present(nav, animated: true)
    }
    
    private func linkActions() {
        isLinking = true
        guard let sensorIdValue = Int(sensorId, radix: 16) else {
            NSLog("Invalid sensor ID \(sensorId)", "")
            return
        }
        let commands = MeshCommand.linkSingleSensor(address, sensorId: sensorIdValue, action1: action1, action2: action2)
        let interval: TimeInterval = 0.5
        MeshManager.shared.sendCommands(commands, intervalSeconds: interval)
        let alert = UIAlertController.makeNormal(title: "Linking...", message: nil, preferredStyle: .alert, viewController: self)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500 * commands.count), execute: {
            alert.dismiss(animated: true)
        })
    }
    
    private func unlink() {
        MeshCommand.unlinkSingleSensorId(address, sensorType: sensorType).send()
        NSLog("Unlink single sensor \(sensorType)", "")
    }
}

extension BindSingleSensorViewController: DiscoverSensorViewControllerDelegate {
    func discoverSensorViewController(_ controller: DiscoverSensorViewController, didSelectSensor sensor: MeshNode) {
        sensorId = sensor.macAddress
        tableView.reloadData()
    }
}

extension BindSingleSensorViewController: SelectSingleSensorActionControllerDelegate {
    func selectSingleSensorActionController(_ controller: SelectSingleSensorActionController, didSelectActionNo action: MeshCommand.SingleSensorAction) {
        if action.actionIndex == 1 {
            action1 = action
        } else if action.actionIndex == 2 {
            action2 = action
        }
        tableView.reloadData()
    }
}

extension BindSingleSensorViewController: MeshManagerSingleSensorDelegate {
    func meshManager(_ manager: MeshManager, device address: Int, didGetSingleSensorId sensorId: Int, sensorType: MeshCommand.SingleSensorAction.SensorType) {
        if isLinking { return }
        guard self.address == address, self.sensorType == sensorType else {
            NSLog("Invalid address \(address) or invalid sensorType \(sensorType)", "")
            return
        }
        self.sensorId = sensorId.hex
        tableView.reloadData()
    }
    
    func meshManager(_ manager: MeshManager, device address: Int, didGetSingleSensorAction action: MeshCommand.SingleSensorAction) {
        if isLinking { return }
        guard self.address == address, self.sensorType == action.sensorType else {
            NSLog("Invalid address \(address) or invalid sensorType \(action.sensorType)", "")
            return
        }
        if action.actionIndex == 1 {
            action1 = action
        } else if action.actionIndex == 2 {
            action2 = action
        }
        tableView.reloadData()
    }
}
