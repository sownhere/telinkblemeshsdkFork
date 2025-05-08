//
//  ManualLinkedSensorsController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by 王文东 on 2024/11/19.
//

import UIKit
import TelinkBleMesh

class ManualLinkedSensorsController: UITableViewController, MeshManagerDeviceDelegate {
    
    var address: Int = 0
    
    var doorSensorId: String?
    var waterLeakSesnorId: String?
    
    let sections = [
        ["Get door sensor ID", "Get water leak sensor ID"],
        ["Door sensor ID", "Water leak sensor ID"],
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Manual Linked Sensors"
        MeshManager.shared.deviceDelegate = self
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let text = sections[indexPath.section][indexPath.row]
        switch text {
        case "Get door sensor ID":
            MeshCommand.getManualLinkedDoorSensorId(address).send()
        case "Get water leak sensor ID":
            MeshCommand.getManualLinkedWaterLeakSensorId(address).send()
        case "Door sensor ID":
            handleSensorIdClicked(sensorType: "DoorSensor")
        case "Water leak sensor ID":
            handleSensorIdClicked(sensorType: "WaterLeak")
        default:
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let text = sections[indexPath.section][indexPath.row]
        cell.textLabel?.text = text
        switch text {
        case "Door sensor ID":
            cell.detailTextLabel?.text = doorSensorId
        case "Water leak sensor ID":
            cell.detailTextLabel?.text = waterLeakSesnorId
        default:
            cell.detailTextLabel?.text = nil
        }
        return cell
    }
    
    func meshManager(_ manager: MeshManager, device address: Int, didGetManualLinkedSensor sensorId: Int, sensorType: String, isLinked: Bool) {
        if (sensorType == "DoorSensor") {
            doorSensorId = "Linked: \(isLinked), ID: \(sensorId.hex)"
        } else if (sensorType == "WaterLeak") {
            waterLeakSesnorId = "Linked: \(isLinked), ID: \(sensorId.hex)"
        }
        tableView.reloadData()
    }
    
    func handleSensorIdClicked(sensorType: String) {
        if (sensorType == "DoorSensor") {
            MeshCommand.clearManualLinkedDoorSensorId(address).send()
            MeshCommand.getManualLinkedDoorSensorId(address).send()
        } else if (sensorType == "WaterLeak") {
            MeshCommand.clearManualLinkedWaterLeakSensorId(address).send()
            MeshCommand.getManualLinkedWaterLeakSensorId(address).send()
        }
    }

}
