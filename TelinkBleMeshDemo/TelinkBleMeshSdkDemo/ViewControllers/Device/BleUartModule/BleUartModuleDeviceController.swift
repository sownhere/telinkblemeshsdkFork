//
//  BleUartModuleDeviceController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by 王文东 on 2023/8/25.
//

import UIKit
import TelinkBleMesh

protocol BleUartModuleDeviceControllerDelegate: NSObjectProtocol {
    
    func bleUartModuleDeviceControllerDidUpdateDevice(_ controller: BleUartModuleDeviceController)
}

class BleUartModuleDeviceController: UITableViewController {
    
    weak var daliDevice: UartDaliDevice!
    weak var delegate: BleUartModuleDeviceControllerDelegate?
    
    private var cells: [CellType] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = daliDevice.commonName
        
        cells = getCellTypes()
        
        let options = UIBarButtonItem(title: "Options", style: .done, target: self, action: #selector(self.optionsAction))
        navigationItem.rightBarButtonItem = options
        
        UartDaliManager.shared.delegate = self
    }
    
    enum CellType: String {
        case onOff = "ON_OFF"
        case brightness = "BRIGHTNESS"
        case cct = "COLOR_TEMPERATURE"
        case xy = "XY"
        case rgbw = "RGBW"
        case rgbwa = "RGBWA"
        
        case getState = "Get State"
        
        static let all: [CellType] = [
            .onOff, .brightness, .cct, .xy, .rgbw, .rgbwa,
            .getState,
        ]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let type = cells[indexPath.row]
        switch type {
        case .onOff:
            guard let isOn = daliDevice.dataPoints[type.rawValue] as? Bool else { return }
            UartDaliManager.shared.updateDataPoints(gatewayAddress: daliDevice.gatewayAddress, daliAddress: daliDevice.daliAddress, dataPoints: [type.rawValue: !isOn])
            daliDevice.dataPoints[type.rawValue] = !isOn
            
        case .getState:
            UartDaliManager.shared.getDeviceActualDataPoints(gatewayAddress: daliDevice.gatewayAddress, daliAddress: daliDevice.daliAddress)
            
        default:
            break
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        ?? UITableViewCell(style: .value1, reuseIdentifier: "cell")
        let cellType = cells[indexPath.row]
        let key = cellType.rawValue
        cell.textLabel?.text = key
        cell.detailTextLabel?.text = getDetailWithType(cellType)
        return cell
    }
}

extension BleUartModuleDeviceController {
    
    private func showValueInput(key: String, value: Int, range: ClosedRange<Int>, cellType: CellType) {
        
        let alert = UIAlertController(title: key, message: "\(value)\nrange: \(range)", preferredStyle: .alert)
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.width / 2, y: view.bounds.height / 2, width: 1, height: 1)
        var textField: UITextField!
        alert.addTextField() { tf in
            tf.keyboardType = .numberPad
            textField = tf
        }
        let done = UIAlertAction(title: "Done", style: .default) { _ in
            guard let valueString = textField.text, let newValue = Int(valueString), range.contains(newValue) else { return }
            
            
        }
        alert.addAction(done)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
}

extension BleUartModuleDeviceController {
    
    func getCellTypes() -> [CellType] {
        var cells: [CellType] = []
        let keys = daliDevice.dataPoints.keys
        if keys.contains("ON_OFF") {
            cells.append(.onOff)
        }
        if keys.contains("BRIGHTNESS") {
            cells.append(.brightness)
        }
        if keys.contains("COLOR_TEMPERATURE") {
            cells.append(.cct)
        }
        if keys.contains("X") && keys.contains("Y") {
            cells.append(.xy)
        }
        if keys.contains("RED") && keys.contains("GREEN") && keys.contains("BLUE") && keys.contains("WHITE") {
            if keys.contains("AMBER") {
                cells.append(.rgbwa)
            } else {
                cells.append(.rgbw)
            }
        }
        cells.append(contentsOf: [.getState])
        return cells
    }
 
    func getDetailWithType(_ cellType: CellType) -> String {
        switch cellType {
        case .onOff:
            if let isOn = daliDevice.dataPoints["ON_OFF"] as? Bool {
                return isOn ? "ON" : "OFF"
            }
        case .brightness:
            if let level = daliDevice.dataPoints["BRIGHTNESS"] as? Int {
                return "\(level)"
            }
        case .cct:
            if let cct = daliDevice.dataPoints["COLOR_TEMPERATURE"] as? Int {
                return "\(cct)"
            }
        case .xy:
            if let x = daliDevice.dataPoints["X"] as? Int, let y = daliDevice.dataPoints["Y"] as? Int {
                return "x \(x), y \(y)"
            }
        case .rgbw:
            if let red = daliDevice.dataPoints["RED"] as? Int,
               let green = daliDevice.dataPoints["GREEN"] as? Int,
               let blue = daliDevice.dataPoints["BLUE"] as? Int,
               let white = daliDevice.dataPoints["WHITE"] as? Int {
                return "r \(red), g \(green), b \(blue), w \(white)"
            }
        case .rgbwa:
            if let red = daliDevice.dataPoints["RED"] as? Int,
               let green = daliDevice.dataPoints["GREEN"] as? Int,
               let blue = daliDevice.dataPoints["BLUE"] as? Int,
               let white = daliDevice.dataPoints["WHITE"] as? Int,
               let amber = daliDevice.dataPoints["AMBER"] as? Int {
                return "r \(red), g \(green), b \(blue), w \(white), a \(amber)"
            }
        case .getState:
            return ""
        }
        return "UNKNOWN"
    }
    
}

extension BleUartModuleDeviceController {
    
    @objc private func optionsAction() {
        let alert = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.width / 2, y: 88, width: 1, height: 1)
        let changeType = UIAlertAction(title: "Change Type", style: .default) { _ in
            self.changeTypeAction()
        }
        alert.addAction(changeType)
        let config = UIAlertAction(title: "Config", style: .default) { _ in
            let controller = BleUartModuleDeviceConfigController(style: .grouped)
            controller.daliDevice = self.daliDevice
            self.navigationController?.pushViewController(controller, animated: true)
        }
        alert.addAction(config)
        let delete = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteAction()
        }
        alert.addAction(delete)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    private func changeTypeAction() {
        let alert = UIAlertController(title: "Change Type", message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.width / 2, y: 88, width: 1, height: 1)
        let types: [UartDaliDevice.DeviceType] = [
            .dt6, .dt8Cct, .dt8Xy, .dt8Rgbw, .dt8Rgbwa
        ]
        types.forEach { item in
            let itemAction = UIAlertAction(title: item.rawValue, style: .default) { _ in
                if UartDaliManager.shared.changeDeviceTypeManually(self.daliDevice, newDeviceType: item) {
                    NSLog("change successful", "")
                    self.delegate?.bleUartModuleDeviceControllerDidUpdateDevice(self)
                } else {
                    NSLog("change failed", "")
                }
            }
            alert.addAction(itemAction)
        }
        present(alert, animated: true)
    }
    
    private func deleteAction() {
        UartDaliManager.shared.resetDevice(daliDevice)
        delegate?.bleUartModuleDeviceControllerDidUpdateDevice(self)
    }
    
}

extension BleUartModuleDeviceController: UartDaliManagerDelegate {
    
    func uartDaliManager(_ manager: UartDaliManager, didGetDeviceActualDataPoints dataPoints: [String : Any], gatewayAddress: Int, daliAddress: Int) {
        guard daliDevice.gatewayAddress == gatewayAddress, daliDevice.daliAddress == daliAddress else { return }
        for key in daliDevice.dataPoints.keys {
            if let newValue = dataPoints[key] {
                daliDevice.dataPoints[key] = newValue
            }
        }
        tableView.reloadData()
    }
    
}
