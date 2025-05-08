//
//  BleUartModuleGroupsController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by 王文东 on 2023/9/5.
//

import UIKit
import TelinkBleMesh

class BleUartModuleGroupsController: UITableViewController {
    
    var gatewayAddress: Int = 0
    private var groups = [Int](0...15)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Groups"
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let group = groups[indexPath.row]
        cellSelectedHandler(group: group)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ??
        UITableViewCell(style: .value1, reuseIdentifier: "cell")
        let group = groups[indexPath.row]
        cell.textLabel?.text = "G\(group)"
        return cell
    }
}

extension BleUartModuleGroupsController {
    
    private func cellSelectedHandler(group: Int) {
        let alert = UIAlertController(title: "G\(group)", message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        let allOn = UIAlertAction(title: "All On", style: .default) { _ in
            UartDaliManager.shared.updateDataPoints(gatewayAddress: self.gatewayAddress, daliAddress: group | 0x80, dataPoints: [
                "ON_OFF": true
            ])
        }
        alert.addAction(allOn)
        let allOff = UIAlertAction(title: "All Off", style: .default) { _ in
            UartDaliManager.shared.updateDataPoints(gatewayAddress: self.gatewayAddress, daliAddress: group | 0x80, dataPoints: [
                "ON_OFF": false
            ])
        }
        alert.addAction(allOff)
        let settings = UIAlertAction(title: "Settings", style: .default) { _ in
            let controller = BleUartModuleGroupSettingsController(style: .grouped)
            controller.group = group
            controller.gatewayAddress = self.gatewayAddress
            self.navigationController?.pushViewController(controller, animated: true)
        }
        alert.addAction(settings)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
}
