//
//  BleUartModuleScenesController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by 王文东 on 2023/9/6.
//

import UIKit
import TelinkBleMesh

class BleUartModuleScenesController: UITableViewController {
    
    var gatewayAddress: Int = 0
    private let scenes = [Int](0...15)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let scene = scenes[indexPath.row]
        let alert = UIAlertController(title: "S\(scene)", message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        let execute = UIAlertAction(title: "Execute", style: .default) { _ in
            UartDaliManager.shared.executeScene(gatewayAddress: self.gatewayAddress, scene: scene)
        }
        let settings = UIAlertAction(title: "Settings", style: .default) { _ in
            let controller = BleUartModuleSceneSettingsController(style: .grouped)
            controller.gatewayAddress = self.gatewayAddress
            controller.scene = scene
            self.navigationController?.pushViewController(controller, animated: true)
        }
        alert.addAction(execute)
        alert.addAction(settings)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scenes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
        let scene = scenes[indexPath.row]
        cell.textLabel?.text = "S\(scene)"
        return cell
    }
    
}
