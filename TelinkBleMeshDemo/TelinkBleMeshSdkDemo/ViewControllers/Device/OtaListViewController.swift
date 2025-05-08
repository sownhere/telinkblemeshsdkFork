//
//  OtaListViewController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by maginawin on 2021/8/6.
//

import UIKit
import TelinkBleMesh
import Toast

class OtaListViewController: UITableViewController {
    
    var network: MeshNetwork = .factory
    
    private var nodes: [MeshNode] = []
    private var timer: Timer?
    
    private var deviceVersions: [String: String?] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        let refreshItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.refreshAction))
        navigationItem.rightBarButtonItem = refreshItem
        
        title = "OTA Devices"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.refreshAction()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // refreshAction()
    }
    
    @objc private func refreshAction() {
        
        nodes.removeAll()
        tableView.reloadData()
        
        MeshManager.shared.nodeDelegate = self
        MeshManager.shared.scanNode(network)
    }
    
    @objc private func timerAction() {
        
        MeshManager.shared.disconnect()
        
        view.hideToastActivity()
        view.makeToast("Connect failed", position: .center)
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let node = nodes[indexPath.row]
        
        MeshManager.shared.nodeDelegate = self
        MeshManager.shared.connect(node)
        
        view.makeToastActivity(view.center)
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 8, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: false)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return nodes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ??
            UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        let node = nodes[indexPath.row]
        let version = deviceVersions[node.macAddress] as? String ?? "Version unknown"
        cell.textLabel?.text = "\(node.title) [\(version)]"
        cell.textLabel?.numberOfLines = 0 
        cell.detailTextLabel?.text = node.detail
        
        return cell
    }

}

extension OtaListViewController: MeshManagerNodeDelegate {
    
    func meshManager(_ manager: MeshManager, didDiscoverNode node: MeshNode) {
        
        if nodes.contains(node) {
            return
        }
        
        nodes.append(node)
        tableView.reloadData()
    }
    
    func meshManager(_ manager: MeshManager, didLoginNode node: MeshNode) {
        
        timer?.invalidate()
        view.hideToastActivity()
        view.makeToast("Login success", position: .center)
        
        let controller = OtaTableViewController(style: .grouped)
        controller.netework = network
        controller.node = node
        controller.delegate = self
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
}

extension OtaListViewController: OtaTableViewControllerDelegate {
    
    func otaTableViewController(_ controller: OtaTableViewController, didUpdate mac: String, version: String) {
        
        deviceVersions[mac] = version
        tableView.reloadData()
    }
    
}
