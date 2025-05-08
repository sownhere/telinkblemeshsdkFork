//
//  FixAddressViewController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by 王文东 on 2023/7/18.
//

import UIKit
import TelinkBleMesh

class FixAddressViewController: UITableViewController {
    
    var network: MeshNetwork = MeshNetwork.factory {
        didSet {
            navigationItem.title = network.name
        }
    }
    
    private var sections: [SectionType] = [
        .state, .nodes
    ]
    private var states: [StateType] = [
        .nodeCount, .repeatCount, .fixNow
    ]
    private var nodes: [MeshNode] {
        return FixNodesManager.shared.networkNodes(network)
    }
    private var nodesRssi: [String: RssiLevel] = [:]
    private var alertController: UIAlertController?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = network.name
        
        let refreshItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.refreshAction))
        navigationItem.rightBarButtonItem = refreshItem
        
        let menuItem = UIBarButtonItem(title: "Menu".localization, style: .plain, target: self, action: #selector(self.menuAction))
        navigationItem.leftBarButtonItem = menuItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scanNodes()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopScan()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch sections[indexPath.section] {
        case .state:
            switch states[indexPath.row] {
            case .fixNow:
                stopScan()
                MeshManager.shared.scanNode(network, autoLogin: true)
                alertController?.dismiss(animated: true)
                alertController = UIAlertController(title: "connecting".localization, message: nil, preferredStyle: .alert)
                alertController?.popoverPresentationController?.sourceView = view
                alertController?.popoverPresentationController?.sourceRect = CGRect(x: 40, y: 40, width: 1, height: 1)
                let cancel = UIAlertAction(title: "cancel".localization, style: .cancel) { [weak self] _ in
                    // disconnect and scan again
                    self?.refreshAction()
                }
                alertController?.addAction(cancel)
                navigationController?.present(alertController!, animated: true)                
                
            default:
                break
            }
            
        case .nodes:
            stopScan()
            
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch sections[section] {
        case .state: return states.count
        case .nodes: return nodes.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case .state:
            let cell = tableView.dequeueReusableCell(withIdentifier: "state") ?? UITableViewCell(style: .value1, reuseIdentifier: "state")
            let state = states[indexPath.row]
            cell.textLabel?.text = state.title
            switch state {
            case .nodeCount:
                cell.detailTextLabel?.text = "\(nodes.count)"
            case .repeatCount:
                cell.detailTextLabel?.text = "\(FixNodesManager.shared.repeatCount(network))"
            case .fixNow:
                cell.detailTextLabel?.text = nil
            }
            return cell
            
        case .nodes:
            let cell = tableView.dequeueReusableCell(withIdentifier: "node") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "node")
            let node = nodes[indexPath.row]
            cell.textLabel?.text = node.title
            if let rssi = nodesRssi[node.macAddress] {
                cell.detailTextLabel?.text = node.detail + " \(rssi)"
            } else {
                cell.detailTextLabel?.text = node.detail + " unknown"
            }
            let isRepeat = FixNodesManager.shared.isShortAddressRepeat(node)
            cell.textLabel?.textColor = isRepeat ? .red : .darkText
            return cell
        }
    }

}

extension FixAddressViewController {
    
    enum SectionType {
        case state
        case nodes
    }
    
    enum StateType {
        case nodeCount
        case repeatCount
        case fixNow
        
        var title: String {
            switch self {
            case .nodeCount:
                return "NodeCount".localization
            case .repeatCount:
                return "RepeatCount".localization
            case .fixNow:
                return "FixNow".localization
            }
        }
    }
}

extension FixAddressViewController: MeshManagerNodeDelegate, MeshManagerNodeRssiDelegate {
    
    @objc private func menuAction() {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = CGRect(x: 40, y: 40, width: 1, height: 1)
        let selectNetwork = UIAlertAction(title: "SelectNetwork".localization, style: .default) { [weak self] _ in
            let select = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            select.popoverPresentationController?.sourceView = self?.view
            select.popoverPresentationController?.sourceRect = CGRect(x: 40, y: 40, width: 1, height: 1)
            let factoryNet = MeshNetwork.factory
            let factory = UIAlertAction(title: factoryNet.name, style: .default) { [weak self] _ in
                self?.network = factoryNet
                self?.tableView.reloadData()
            }
            select.addAction(factory)
            let networks = NetworkManager.shared.networks
            networks?.forEach { network in
                let net = UIAlertAction(title: network.name, style: .default) { [weak self] _ in
                    self?.network = network
                    self?.tableView.reloadData()
                }
                select.addAction(net)
            }
            select.addAction(UIAlertAction(title: "cancel".localization, style: .cancel))
            self?.navigationController?.present(select, animated: true)
        }
        let cancel = UIAlertAction(title: "cancel".localization, style: .cancel)
        alert.addAction(selectNetwork)
        alert.addAction(cancel)
        navigationController?.present(alert, animated: true)
    }
    
    @objc private func refreshAction() {
        FixNodesManager.shared.clear(at: network)
        tableView.reloadData()
        scanNodes()
    }
    
    private func scanNodes() {
        
        MeshManager.shared.nodeDelegate = self
        MeshManager.shared.nodeRssiDelegate = self
        MeshManager.shared.scanNode(network, ignoreName: true)
    }
    
    private func stopScan() {
        
        MeshManager.shared.stopScanNode()
    }
    
    func meshManagerNeedTurnOnBluetooth(_ manager: MeshManager) {
        
        view.makeToast("please_turn_on_bluetooth".localization, position: .center)
    }
    
    func meshManager(_ manager: MeshManager, didDiscoverNode node: MeshNode) {
        
//        guard !nodes.contains(node) else { return }
//        if FixNodesManager.shared.appendNode(node) {
//            self.tableView.reloadData()            
//        }
    }
    
    func meshManager(_ manager: MeshManager, didDiscoverNode node: MeshNode, rssiLevel: RssiLevel) {
        NSLog("didDiscoverNode: \(node.macAddress), rssi: \(rssiLevel)", "")
        
        if !nodes.contains(node) {
            _ = FixNodesManager.shared.appendNode(node)
            updateRssiLevel(node: node, rssiLevel: rssiLevel, updateUI: false)
            tableView.reloadData()
        } else {
            updateRssiLevel(node: node, rssiLevel: rssiLevel, updateUI: true)
        }
    }
    
    private func updateRssiLevel(node: MeshNode, rssiLevel: RssiLevel, updateUI: Bool) {
        nodesRssi[node.macAddress] = rssiLevel
        if updateUI {
            if let index = nodes.firstIndex(where: { $0.macAddress == node.macAddress }) {
                let indexPath = IndexPath(row: index, section: 1)
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.textLabel?.text = node.title
                    if let rssi = nodesRssi[node.macAddress] {
                        cell.detailTextLabel?.text = node.detail + " \(rssi)"
                    } else {
                        cell.detailTextLabel?.text = node.detail + " unknown"
                    }
                    let isRepeat = FixNodesManager.shared.isShortAddressRepeat(node)
                    cell.textLabel?.textColor = isRepeat ? .red : .darkText
                }
            }
        }        
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
            
            self.alertController?.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                
                let controller = FixMainViewController(style: .grouped)
                controller.network = self.network
                controller.delegate = self
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

extension FixAddressViewController: FixMainViewControllerDelegate {
    
    func fixMainViewController(_ controller: FixMainViewController, didFix newAddress: Int, mac: String) {
        
        FixNodesManager.shared.updateNewAddress(newAddress, mac: mac, network: network)
        tableView.reloadData()
    }
}
