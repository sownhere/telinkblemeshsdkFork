//
//  DiscoverSensorViewController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by 王文东 on 2024/5/7.
//

import UIKit
import TelinkBleMesh

@objc protocol DiscoverSensorViewControllerDelegate: NSObjectProtocol {
    @objc optional func discoverSensorViewController(_ controller: DiscoverSensorViewController, didSelectSensor sensor: MeshNode)
    @objc optional func discoverSensorViewController(_ controller: DiscoverSensorViewController, didSelectUniversalRemote universalRemote: MeshNode)
}

class DiscoverSensorViewController: UITableViewController, SensorManagerDelegate {
    
    weak var delegate: DiscoverSensorViewControllerDelegate?
    
    private var nodes: [MeshNode] = []
    // mac: sensorType?
    private var sensorTypes: [UInt32: MeshCommand.SingleSensorAction.SensorType?] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Discover Sensor"
        SensorManager.shared.delegate = self
        SensorManager.shared.scanSensor()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SensorManager.shared.stopScan()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let node = nodes[indexPath.row]
        switch node.deviceType.category {
        case .universalRemote:
            delegate?.discoverSensorViewController?(self, didSelectUniversalRemote: node)
            navigationController?.popViewController(animated: true)
        case .sensor:
            delegate?.discoverSensorViewController?(self, didSelectSensor: node)
            navigationController?.popViewController(animated: true)
        default:
            break
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nodes.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .value1, reuseIdentifier: "cell")
        let node = nodes[indexPath.row]
        cell.textLabel?.text = node.macAddress
        if (node.deviceType.category == .universalRemote) {
            let s1 = node.deviceType.category.description
            let s2 = node.deviceType.universalRemoteType.desc 
            cell.detailTextLabel?.text = "\(s1) \(s2)"
        } else if (node.deviceType.category == .sensor) {
            let s1 = node.deviceType.category.description
            // let s2 = node.deviceType.sensorType.desc
            var sensorTypeText = "Unknown \(node.deviceType.rawValue2)"
            if let sensorType = sensorTypes[node.macValue] as? MeshCommand.SingleSensorAction.SensorType {
                sensorTypeText = "\(sensorType)"
            }
            cell.detailTextLabel?.text = "\(s1) \(sensorTypeText)"
        }
        return cell
    }
    
    func sensorManager(_ manager: SensorManager, didDiscover sensor: MeshNode) {
        // don't use this
    }
    
    func sensorManager(_ manager: SensorManager, didDiscoverSingleSensor sensor: MeshNode, sensorType: MeshCommand.SingleSensorAction.SensorType?) {
        if !nodes.contains(sensor) {
            nodes.append(sensor)
            sensorTypes[sensor.macValue] = sensorType
            tableView.reloadData()
        }
    }
    
    func sensorManager(_ manager: SensorManager, didDiscoverUniversalRemote universalRemote: MeshNode) {
        if !nodes.contains(universalRemote) {
            nodes.append(universalRemote)
            tableView.reloadData()
        }
    }
}
