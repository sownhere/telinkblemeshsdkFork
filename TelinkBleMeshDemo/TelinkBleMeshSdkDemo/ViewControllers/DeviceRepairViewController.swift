//
//  DeviceRepairViewController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by 王文东 on 2023/5/6.
//

import UIKit
import TelinkBleMesh

class DeviceRepairViewController: UITableViewController {
    
    var node: MeshNode!
    
    private var state: State = .none
    private var sections: [[CellType]] = [
        [.start, .stop],
        [.state]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Device Repair"
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        DeviceRepairManager.shared.stopRepair()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch sections[indexPath.section][indexPath.row] {
        case .start:
            state = .connecting
            tableView.reloadData()
            DeviceRepairManager.shared.delegate = self
            DeviceRepairManager.shared.startRepair(node)
        case .stop:
            state = .none
            tableView.reloadData()
            DeviceRepairManager.shared.stopRepair()
        case .state:
            break
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sections[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .value1, reuseIdentifier: "cell")
        switch sections[indexPath.section][indexPath.row] {
        case .start:
            cell.textLabel?.text = "Start"
            cell.detailTextLabel?.text = nil
        case .stop:
            cell.textLabel?.text = "Stop"
            cell.detailTextLabel?.text = nil
        case .state:
            cell.textLabel?.text = "State"
            cell.detailTextLabel?.text = state.message
        }
        
        
        return cell
    }

}

extension DeviceRepairViewController {
    
    enum State {
        
        case none
        case connecting
        case repairing
        case failedToConnect
        case disconnected
        case succeeded
        
        var message: String {
            switch self {
                
            case .none:
                return "None"
            case .connecting:
                return "Connecting..."
            case .repairing:
                return "Repairing..."
            case .failedToConnect:
                return "Failed to connect"
            case .disconnected:
                return "Disconnected"
            case .succeeded:
                return "Succeeded"
            }
        }
    }
    
    enum CellType {
        case start
        case stop
        case state
    }
    
}

extension DeviceRepairViewController: DeviceRepairManagerDelegate {
    
    func deviceRepairManagerFailedToConnect(_ manager: TelinkBleMesh.DeviceRepairManager) {
        state = .failedToConnect
        tableView.reloadData()
    }
    
    func deviceRepairManagerConnected(_ manager: TelinkBleMesh.DeviceRepairManager) {
        state = .repairing
        tableView.reloadData()
    }
    
    func deviceRepairManagerDisconnected(_ manager: TelinkBleMesh.DeviceRepairManager) {
        state = .disconnected
        tableView.reloadData()
    }
    
    func deviceRepairManagerRepairSucceeded(_ manager: TelinkBleMesh.DeviceRepairManager, mac: String, newAddress: Int) {
        NSLog("deviceRepairManagerRepairSucceeded mac \(mac), new address \(newAddress)", "")
        state = .succeeded
        tableView.reloadData()
    }
    
}
