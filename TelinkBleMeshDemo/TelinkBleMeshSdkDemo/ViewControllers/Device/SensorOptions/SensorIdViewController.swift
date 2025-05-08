//
//  SensorIdViewController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by 王文东 on 2023/3/23.
//

import UIKit
import TelinkBleMesh

class SensorIdViewController: UITableViewController {
    
    var address: Int = 0
    var sensorType: MeshCommand.SensorReportType = .microwareMotion
    
    private var sensorId: Int = 0

    private let sections: [[CellType]] = [
        [.get, .set],
        [.unbind],
        [.sensorId]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "\(sensorType)"
        
        MeshManager.shared.deviceDelegate = self
        MeshCommand.getSensorId(address, sensorType: sensorType).send()
        
        let typesItem = UIBarButtonItem(title: "Types", style: .done, target: self, action: #selector(self.typesItemAction))
        navigationItem.rightBarButtonItem = typesItem
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch getCellType(at: indexPath) {
            
        case .get:
            MeshCommand.getSensorId(address, sensorType: sensorType).send()
            
        case .set:
            setSelectedAction()
            
        case .unbind:
            MeshCommand.unbindSensorId(address, sensorType: sensorType).send()
            
        case .sensorId:
            let controller = DiscoverSensorViewController()
            navigationController?.pushViewController(controller, animated: true)
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sections[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .value1, reuseIdentifier: "cell")
        
        let type = getCellType(at: indexPath)
        cell.textLabel?.text = type.title
        if type == .sensorId {
            let value = String(format: "%08X", sensorId)
            cell.detailTextLabel?.text = value
        } else {
            cell.detailTextLabel?.text = nil
        }
        
        return cell
    }
    
    private func getCellType(at indexPath: IndexPath) -> CellType {
        
        return sections[indexPath.section][indexPath.row]
    }
}

extension SensorIdViewController {
    
    enum CellType: Int {
        
        case get = 0
        case set
        case unbind
        case sensorId
        
        static let titles = [
            "Get", "Set", "Unbind", "SensorId"
        ]
        
        var title: String { return Self.titles[rawValue] }
    }
    
}

extension SensorIdViewController: MeshManagerDeviceDelegate {
    
    func meshManager(_ manager: MeshManager, device address: Int, didGetSensorId sensorId: Int, sensorTypeValue: Int) {
        self.sensorId = sensorId
        tableView.reloadData()
    }
}

extension SensorIdViewController {
    
    @objc private func typesItemAction() {
        let sensorTypes: [MeshCommand.SensorReportType] = [
            .doorState, .pirMotion, .microwareMotion,
            ]
        let alert = UIAlertController(title: "Types", message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.width / 2, y: 88, width: 1, height: 1)
        sensorTypes.forEach { item in
            let itemAction = UIAlertAction(title: "\(item)", style: .default) { _ in
                self.sensorType = item
                self.navigationItem.title = "\(item)"
                MeshCommand.getSensorId(self.address, sensorType: item).send()
            }
            alert.addAction(itemAction)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func setSelectedAction() {
        let alert = UIAlertController.makeNormal(title: "Set", message: nil, preferredStyle: .alert, viewController: self)
        var idTextField: UITextField!
        alert.addTextField() { tf in
            idTextField = tf
            idTextField.keyboardType = .asciiCapable
            idTextField.autocorrectionType = .no
            idTextField.text = ""
            idTextField.placeholder = "Sensor ID"
        }
        let set = UIAlertAction(title: "Set", style: .default) { _ in
            guard let idText = idTextField.text, let idValue = Int(idText, radix: 16) else {
                return
            }
            MeshCommand.bindSensorId(self.address, sensorType: self.sensorType, sensorId: idValue).send()
        }
        alert.addAction(set)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
        
    }
    
}
