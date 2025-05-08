//
//  BindToSensorsViewController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by 王文东 on 2024/8/23.
//

import UIKit
import TelinkBleMesh

class BindToSensorsViewController: UITableViewController {
    
    var address: Int = 0
    
    private var sections: [SectionType] = [.multiSensors, .singleSensor]
    private var multiCells: [CellType] = SectionType.multiSensors.cells
    private var singleCells: [CellType] = SectionType.singleSensor.cells
    private var cells: [SectionType: [CellType]]  = [
        .multiSensors: SectionType.multiSensors.cells,
        .singleSensor: SectionType.singleSensor.cells
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Bind to Sensors"
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch sections[indexPath.section] {
        case .multiSensors:
            let controller = BindMultiSensorViewController(style: .grouped)
            controller.address = address
            controller.sensorIndex = indexPath.row + 1
            navigationController?.pushViewController(controller, animated: true)
        case .singleSensor:
            let controller = BindSingleSensorViewController(style: .grouped)
            controller.address = address
            controller.sensorType = MeshCommand.SingleSensorAction.SensorType.all[indexPath.row]
            navigationController?.pushViewController(controller, animated: true)
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells[sections[section]]?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .value1, reuseIdentifier: "cell")
        let sectionType = sections[indexPath.section]
        let cellType = cells[sectionType]![indexPath.row]
        cell.textLabel?.text = "\(cellType.title)"
        cell.detailTextLabel?.text = nil
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    enum SectionType {
        case multiSensors
        case singleSensor
        
        var cells: [CellType] {
            switch self {
            case .multiSensors:
                return [.sensor1, .sensor2, .sensor3, .sensor4]
            case .singleSensor:
                return [
                    .doorContactSensor, .waterLeakSensor,
                    .smokeSensor, .coSensor, .gasSensor, .airQualitySensor, .glassBreakSensor,
                    .vibrationSensor,
                ]
            }
        }
    
    }
    
    enum CellType {
        case sensor1
        case sensor2
        case sensor3
        case sensor4
        
        case doorContactSensor
        case waterLeakSensor
        case smokeSensor
        case coSensor
        case gasSensor
        case airQualitySensor
        case glassBreakSensor
        case vibrationSensor
        
        var title: String {
            switch self {
            case .sensor1: return "Sensor 1"
            case .sensor2: return "Sensor 2"
            case .sensor3: return "Sensor 3"
            case .sensor4: return "Sensor 4"

            case .doorContactSensor: return "Door Contact"
            case .waterLeakSensor: return "Water Leak"
            case .smokeSensor: return "Smoke"
            case .coSensor: return "CO"
            case .gasSensor: return "Gas"
            case .airQualitySensor: return "Air Quality"
            case .glassBreakSensor: return "Glass Break"
            case .vibrationSensor: return "Vibration"
            }
        }
    }
}
