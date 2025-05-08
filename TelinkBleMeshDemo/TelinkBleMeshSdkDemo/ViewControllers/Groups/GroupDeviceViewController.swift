//
//  GroupDeviceViewController.swift
//  
//
//  Created by maginawin on 2022/6/13.
//

import UIKit
import TelinkBleMesh

class GroupDeviceViewController: UITableViewController {
    
    var device: Int = 0x01
    var groups: [Int] = []
    var innerGroups: Set<Int> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Device \(device)"        
        
        MeshManager.shared.deviceDelegate = self
        MeshCommand.getGroups(device).send()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let group = groups[indexPath.row]
        if isSelected(group) {
            
            MeshCommand.deleteGroup(group, address: device).send()
            
        } else {
            
            MeshCommand.addGroup(group, address: device).send()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return groups.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ??
        UITableViewCell(style: .default, reuseIdentifier: "cell")

        let group = groups[indexPath.row]
        cell.textLabel?.text = "Group \(group)"
        
        cell.accessoryType = isSelected(group) ? .checkmark : .none

        return cell
    }

    private func isSelected(_ group: Int) -> Bool {
        
        return innerGroups.contains(group)
    }

}

extension GroupDeviceViewController: MeshManagerDeviceDelegate {
    
    func meshManager(_ manager: MeshManager, device address: Int, didGetGroups groups: [Int]) {
        
        guard address == device else {
            return            
        }
        
        innerGroups = innerGroups.union(Set(groups))
        tableView.reloadData()
    }
    
    func meshManager(_ manager: MeshManager, didGetDeviceAddress address: Int) {
        
        innerGroups.insert(address)
        tableView.reloadData()
    }
}
