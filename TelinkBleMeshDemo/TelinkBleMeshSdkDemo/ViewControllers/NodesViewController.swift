//
//  PeripheralsViewController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by maginawin on 2021/1/13.
//

import UIKit
import TelinkBleMesh
import Toast

class NodesViewController: UITableViewController {
    
    var network: MeshNetwork = .factory
    
    private var nodes: [MeshNode] = []
    private var stopTimer: Timer?
    private var alertController: UIAlertController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        title = "factory_network".localization + " V\(appVersion)"
        
        let refreshItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshItemAction))
        navigationItem.rightBarButtonItem = refreshItem
        
        let otaItem = UIBarButtonItem(title: "More", style: .plain, target: self, action: #selector(self.moreAction))
        navigationItem.leftBarButtonItem = otaItem
        
        refreshItemAction()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopScan()
    }
    
    deinit {
        
        stopScan()
    }
    
    @objc private func moreAction() {
        
        let alert = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.width / 2, y: view.bounds.height / 2, width: 1, height: 1)
        
        let otaAction = UIAlertAction(title: "OTA", style: .default) { _ in self.otaAction() }
        let nfcToolAction = UIAlertAction(title: "Nfc Tool", style: .default) { _ in self.nfcToolAction() }
        let settings = UIAlertAction(title: "App Settings", style: .default) { _ in
            let controller = AppSettingsViewController(style: .grouped)
            self.navigationController?.pushViewController(controller, animated: true)
        }
        let sensorManager = UIAlertAction(title: "Sensor Manager", style: .default) { _ in
            let controller = DiscoverSensorViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(otaAction)
        alert.addAction(nfcToolAction)
        alert.addAction(settings)
        alert.addAction(sensorManager)
        alert.addAction(UIAlertAction(title: "Room Scenes", style: .default) { _ in
            self.navigationController?.pushViewController(RoomScenesViewController(style: .insetGrouped), animated: true)
        })
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    @objc func refreshItemAction() {
        
        nodes.removeAll()
        tableView.reloadData()
        
        MeshManager.shared.nodeDelegate = self
        MeshManager.shared.scanNode(network, ignoreName: true)
        
        stopTimer?.invalidate()
        stopTimer = Timer.scheduledTimer(withTimeInterval: 8, repeats: false, block: { (timer) in
            
            timer.invalidate()
            MeshManager.shared.stopScanNode()
        })
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        stopScan()
        
        let node = nodes[indexPath.row]
        
        alertController?.dismiss(animated: true, completion: nil)        
        alertController = UIAlertController(title: "Select Action", message: nil, preferredStyle: .actionSheet)
        alertController?.popoverPresentationController?.sourceView = view
        alertController?.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.width / 2, y: view.bounds.height / 2, width: 1, height: 1)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alertController?.addAction(cancel)
        
        let connect = UIAlertAction(title: "Connect", style: .default) { _ in
            
            MeshManager.shared.nodeDelegate = self
            MeshManager.shared.connect(node)
            
            self.alertController = UIAlertController(title: "connecting".localization, message: nil, preferredStyle: .alert)
            self.alertController?.popoverPresentationController?.sourceView = self.view
            self.alertController?.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2, width: 1, height: 1)
            
            self.present(self.alertController!, animated: true, completion: nil)
        }
        alertController?.addAction(connect)
        
        let repair = UIAlertAction(title: "Repair", style: .default) { _ in
            
            let controller = DeviceRepairViewController(style: .grouped)
            controller.node = node
            self.navigationController?.pushViewController(controller, animated: true)
        }
        alertController?.addAction(repair)
        
        present(alertController!, animated: true, completion: nil)
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
        cell.textLabel?.text = node.title
        cell.detailTextLabel?.text = node.detail
        
        return cell
    }
}

extension NodesViewController: MeshManagerNodeDelegate {
    
    func meshManagerNeedTurnOnBluetooth(_ manager: MeshManager) {
        
        view.makeToast("please_turn_on_bluetooth".localization, position: .center)
    }
    
    func meshManager(_ manager: MeshManager, didDiscoverNode node: MeshNode) {
        
        guard !nodes.contains(node) else { return }
        nodes.append(node)
        self.tableView.reloadData()
    }
    
    func meshManager(_ manager: MeshManager, didConnectNode node: MeshNode) {
        
        alertController?.title = "connected".localization
    }
    
    func meshManager(_ manager: MeshManager, didFailToConnectNodeIdentifier identifier: UUID) {
        
        alertController?.title = "fail_to_connect".localization
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            self.alertController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func meshManager(_ manager: MeshManager, didDisconnectNodeIdentifier identifier: UUID) {
        
        view.makeToast("disconnected".localization, position: .bottom)
        
        navigationController?.popToRootViewController(animated: true)
    }
    
    func meshManager(_ manager: MeshManager, didLoginNode node: MeshNode) {
        
        alertController?.title = "login_successful".localization
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            
            self.alertController?.dismiss(animated: true) {
                
                let controller = NodeViewController(style: .grouped)
                controller.node = node
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    func meshManager(_ manager: MeshManager, didFailToLoginNodeIdentifier identifier: UUID) {
        
        alertController?.title = "login_failed".localization
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.alertController?.dismiss(animated: true, completion: nil)
        }
    }
    
}

extension NodesViewController {
    
    private func stopScan() {
        
        stopTimer?.invalidate()
        MeshManager.shared.stopScanNode()
    }
    
}

extension NodesViewController {
    
    private func otaAction() {
        
        let alert = UIAlertController(title: "SelectNetwork".localization, message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceRect = CGRect(x: 30, y: 30, width: 1, height: 1)
        alert.popoverPresentationController?.sourceView = view
        
        let defaultAction = UIAlertAction(title: "Default (Srm@7478@a)", style: .default, handler: { _ in
            
            let controller = OtaListViewController(style: .grouped)
            self.navigationController?.pushViewController(controller, animated: true)
        })
        alert.addAction(defaultAction)
        
        let networks = NetworkManager.shared.networks
        networks?.forEach { network in
            
            let action = UIAlertAction(title: network.name, style: .default) { _ in
                
                let controller = OtaListViewController(style: .grouped)
                controller.network = network
                self.navigationController?.pushViewController(controller, animated: true)
            }
            alert.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func nfcToolAction() {
        
        let controller = NfcToolViewController(style: .grouped)
        navigationController?.pushViewController(controller, animated: true)
    }
}
