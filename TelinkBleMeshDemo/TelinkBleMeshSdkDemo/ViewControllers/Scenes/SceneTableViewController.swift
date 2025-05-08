//
//  SceneTableViewController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by maginawin on 2021/11/12.
//

import UIKit
import TelinkBleMesh

class SceneTableViewController: UITableViewController {
    
    var addresses: [Int] = []
    var sceneID: Int = 0
    
    private var scenes: [Int: MeshCommand.Scene] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "scene".localization + " \(sceneID)"
        
        view.makeToastActivity(.center)
        MeshManager.shared.deviceDelegate = self 
        
        let queue = DispatchQueue(label: "getQueue")
        queue.async {
            
            for address in self.addresses {
                
                MeshCommand.getSceneDetail(address, sceneID: self.sceneID).send()
                Thread.sleep(forTimeInterval: 0.5)
            }
            
            DispatchQueue.main.async {
                
                self.view.hideToastActivity()
            }
        }
        
        let testItem = UIBarButtonItem(title: "Test", style: .done, target: self, action: #selector(self.testAction))
        navigationItem.rightBarButtonItem = testItem
    }
    
    @objc private func testAction() {
        
        let alert = UIAlertController(title: "Test", message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.width / 2, y: view.bounds.height / 2, width: 1, height: 1)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        let saveGroup1 = UIAlertAction(title: "Group 1 All On", style: .default) { _ in
            
            let s = MeshCommand.Scene(sceneID: 0x01)
            MeshCommand.addOrUpdateScene(0x8001, scene: s).send()
            
        }
        alert.addAction(saveGroup1)
        
        let deleteGroup1 = UIAlertAction(title: "Delete Group 1 All On", style: .default) { _ in
            
            MeshCommand.deleteScene(0x8001, sceneID: 0x01).send()
        }
        alert.addAction(deleteGroup1)
        
        let saveGroup2 = UIAlertAction(title: "Save Group 1 All Off", style: .default) { _ in
            
            var s = MeshCommand.Scene(sceneID: 0x02)
            s.brightness = 0x00
            MeshCommand.addOrUpdateScene(0x8001, scene: s).send()
        }
        alert.addAction(saveGroup2)
        
        let deleteGroup2 = UIAlertAction(title: "Delete Group 1 All off", style: .default) { _ in
            
            MeshCommand.deleteScene(0x8001, sceneID: 0x02).send()
        }
        alert.addAction(deleteGroup2)
        
        present(alert, animated: true)
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let controller = SceneEditViewController(style: .grouped)
        let address = addresses[indexPath.row]
        controller.address = address
        if let scene = scenes[address] {
            controller.scene = scene
        } else {
            controller.scene = MeshCommand.Scene(sceneID: sceneID)
        }
        navigationController?.pushViewController(controller, animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return addresses.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        ?? UITableViewCell(style: .value1, reuseIdentifier: "cell")
        
        let addr = addresses[indexPath.row]
        cell.textLabel?.text = "device".localization + String(format: " 0x%02X", addr)        
        cell.accessoryType = scenes[addr] != nil ? .checkmark : .none
        
        return cell
    }

}

extension SceneTableViewController: MeshManagerDeviceDelegate {
    
    func meshManager(_ manager: MeshManager, device address: Int, didGetScene scene: MeshCommand.Scene) {
        
        scenes[address] = scene
        tableView.reloadData()
    }
}
