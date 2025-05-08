//
//  UniversalRemoteController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by 王文东 on 2024/6/21.
//

import UIKit
import TelinkBleMesh

class UniversalRemoteController: UITableViewController {
    
    weak var device: MyDevice!
    
    var cells: [CellType] = [.firstRemote, .secondRemote]
    
    var firstId: String?
    var secondId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Universal Remote for \(device.mac)"
        
        MeshManager.shared.deviceDelegate = self
        MeshCommand.getUniversalRemoteId(Int(device.meshDevice.address), remoteIndex: .first).send()
        MeshCommand.getUniversalRemoteId(Int(device.meshDevice.address), remoteIndex: .second).send()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let settings = UniversalRemoteSettingsController(style: .grouped)
        settings.device = device
        switch indexPath.row {
        case 0:
            settings.remoteIndex = .first
            settings.remoteId = firstId
        case 1:
            settings.remoteIndex = .second
            settings.remoteId = secondId
        default:
            break
        }
        navigationController?.pushViewController(settings, animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .value1, reuseIdentifier: "cell")
        let type = cells[indexPath.row]
        cell.textLabel?.text = type.desc
        if (type == .firstRemote) {
            cell.detailTextLabel?.text = firstId ?? "none"
        } else if (type == .secondRemote) {
            cell.detailTextLabel?.text = secondId ?? "none"
        }
        return cell
    }
    
    enum CellType {
        case firstRemote
        case secondRemote
        
        var desc: String {
            switch self {
            case .firstRemote: return "First remote"
            case .secondRemote: return "Second remote"
            }
        }
    }

}

extension UniversalRemoteController: MeshManagerDeviceDelegate {
    
    func meshManager(_ manager: MeshManager, device address: Int, didGetUniversalRemoteId remoteId: String, remoteIndex: MeshCommand.UniversalRemoteIndex) {
        switch remoteIndex {
        case .first:
            firstId = remoteId
        case .second:
            secondId = remoteId
        }
        tableView.reloadData()
    }
    
}
