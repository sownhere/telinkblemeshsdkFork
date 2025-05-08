//
//  SensorOptionsViewController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by 王文东 on 2023/3/16.
//

import UIKit
import TelinkBleMesh

class SensorOptionsViewController: UITableViewController {
    
    var address: Int = 0
    
    private var reportValues: [MeshCommand.SensorReportKey: Any] = [:]
    private var attributeTypes: [MeshCommand.SensorAttributeType] = [
        .humanInductionSensitivity,
        .microwaveModuleOnOffState,
        .lightModuleOnOffState,
        .workingBrightnessThreshold,
        .detectedPwmOutputDelay,
        .detectedPwmOutputBrightness,
        .detectedPwmOutputPercentage,
        .notDetectedPwmOutputDelay,
        .notDetectedPwmOutputPercentage,
        .pwmOutputPercentageAfterNotDetectedDelay,
        .workingMode,
        .sensorState,
        .stateReportInterval,
        .reportOnOffState,
        .luxZeroDeviationOfTheBrightnessSensor,
        .luxScaleFactorOfTheBrightnessSensor
    ]
    private var attributeValues: [MeshCommand.SensorAttributeType: Any] = [:]
    
    private let sections: [[CellType]] = [
        [.lux, .state],
        [.attribute]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Sensor Options"
        
        MeshManager.shared.deviceDelegate = self
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let type = getCellType(at: indexPath)
        switch type {
            
        case .attribute:
            handleAttributeSelected(attributeTypes[indexPath.row])
            
        case .lux: fallthrough
        case .state:
            break
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sections[section].first == .attribute ? attributeTypes.count : sections[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .value1, reuseIdentifier: "cell")
        let cellType = getCellType(at: indexPath)
        
        cell.textLabel?.text = cellType.title
        cell.textLabel?.numberOfLines = 0
        
        switch cellType {
        case .lux:
            
            if let textValue = reportValues[.lux] as? Int {
                
                cell.detailTextLabel?.text = "\(textValue)"
                
            } else {
                
                cell.detailTextLabel?.text = nil
            }
            
        case .state:
            
            if let isDetected = reportValues[.isDetected] as? Bool {
                
                cell.detailTextLabel?.text = isDetected ? "Detected" : "Not Detected"
                
            } else {
                
                cell.detailTextLabel?.text = nil
            }
            
        case .attribute:
            
            let type = attributeTypes[indexPath.row]
            cell.textLabel?.text = "\(type)"
            if let attrValue = attributeValues[type] as? Int {
                
                cell.detailTextLabel?.text = "\(attrValue)"
                
            } else {
                
                cell.detailTextLabel?.text = nil
            }
        }
        
        return cell
    }
    
    private func getCellType(at indexPath: IndexPath) -> CellType {
        
        return sections[indexPath.section].first == .attribute ? .attribute : sections[indexPath.section][indexPath.row]
    }

}

extension SensorOptionsViewController {
    
    enum CellType: Int {
        
        case lux = 0
        case state
        case attribute
        
        static let titles = [
            "LUX", "State", "Attribute"
        ]
        
        var title: String { return Self.titles[self.rawValue] }
    }
    
}

extension SensorOptionsViewController: MeshManagerDeviceDelegate {
    
    func meshManager(_ manager: MeshManager, device address: Int, didSensorReport value: [MeshCommand.SensorReportKey : Any]) {
        
        guard self.address == address else { return }
        
        value.forEach { k, v in
            reportValues[k] = v
        }
        tableView.reloadData()
    }
    
    func meshManager(_ manager: MeshManager, device address: Int, didGetSensorAttribute value: [MeshCommand.SensorAttributeType : Any]) {
        
        guard self.address == address else { return }
        
        value.forEach { k, v in
            attributeValues[k] = v
        }
        tableView.reloadData()
    }
    
}

extension SensorOptionsViewController {
    
    private func handleAttributeSelected(_ type: MeshCommand.SensorAttributeType) {
        
        let alert = UIAlertController(title: "\(type)", message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.width / 2, y: view.bounds.height / 2, width: 1, height: 1)
        
        let getAction = UIAlertAction(title: "Get", style: .default) { [weak self] _ in
            
            guard let self = self else { return }
            MeshCommand.getSensorAttribute(self.address, type: type).send()
        }
        alert.addAction(getAction)
        
        let setAction = UIAlertAction(title: "Set", style: .default) { [weak self] _ in
            
            self?.handleSetAttribute(type)
        }
        if !type.isReadonly {
            
            alert.addAction(setAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func handleSetAttribute(_ type: MeshCommand.SensorAttributeType) {
        
        let alert = UIAlertController(title: "\(type)", message: "Range \(type.valueRange)", preferredStyle: .alert)
        
        var textField: UITextField!
        
        alert.addTextField(){ tv in
            textField = tv
            textField.keyboardType = .asciiCapableNumberPad
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        let setAction = UIAlertAction(title: "Set", style: .default) { [weak self] _ in
            
            guard let self = self, let text = textField.text, let value = Int(text) else {
                return
            }
            
            NSLog("Will set \(type) to \(value)", "")
            
            MeshCommand.setSensorAttribute(self.address, type: type, value: value).send()
            MeshCommand.getSensorAttribute(self.address, type: type).send()
        }
        alert.addAction(setAction)
        present(alert, animated: true)
    }
    
}
