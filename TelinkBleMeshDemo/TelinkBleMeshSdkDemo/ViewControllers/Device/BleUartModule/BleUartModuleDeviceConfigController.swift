//
//  BleUartModuleDeviceConfigController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by 王文东 on 2023/10/30.
//

import UIKit
import TelinkBleMesh

class BleUartModuleDeviceConfigController: UITableViewController {
    
    weak var daliDevice: UartDaliDevice!
    
    private var cells: [CellType] = []
    private var values: [String: Any] = [:]
    
    private var minLevel: Int?
    private var maxLevel: Int?
    private var minCct: Int?
    private var maxCct: Int?
    private var minCctPhysical: Int?
    private var maxCctPhysical: Int?
    private var isPowerOnStateMask: Bool?
    private var powerOnState: [String: Any] = [:]
    private var isSystemFailureStateMask: Bool?
    private var systemFailureState: [String: Any] = [:]
    private var fadeTime: Int?
    private var fadeRate: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Config"
        loadCellTypes()
        loadCellValues()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let type = cells[indexPath.row]
        let isChangeable = valueDetailWithType(type) != nil
        if isChangeable {
            setValueToGateway(type: type)
        } else {
            getValueFromGateway(type: type)
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .value1, reuseIdentifier: "cell")
        let type = cells[indexPath.row]
        cell.textLabel?.text = "\(type)"
        cell.detailTextLabel?.text = valueDetailWithType(type)
        return cell
    }
    
    private func loadCellTypes() {
        cells = [.levelRange, .cctRange, .cctPhysicalRange, .systemFailureState, .powerOnState, .fadeTime, .fadeRate]
        tableView.reloadData()
    }
    
    private func valueDetailWithType(_ cellType: CellType) -> String? {
        switch cellType {
        case .levelRange:
            if let minValue = minLevel, let maxValue = maxLevel {
                return UartDaliDevice.getConfigLevelRangeDetail(minLevel: minValue, maxLevel: maxValue)
            }
        case .cctRange:
            if let minValue = minCct, let maxValue = maxCct {
                return UartDaliDevice.getConfigCctRangeDetail(minCct: minValue, maxCct: maxValue)
            }
            
        case .cctPhysicalRange:
            if let minValue = minCctPhysical, let maxValue = maxCctPhysical {
                return UartDaliDevice.getConfigCctRangeDetail(minCct: minValue, maxCct: maxValue)
            }
            
        case .systemFailureState:
            return UartDaliDevice.getConfigStateDetail(level: systemFailureState["BRIGHTNESS"] as? Int)
        case .powerOnState:
            return UartDaliDevice.getConfigStateDetail(level: powerOnState["BRIGHTNESS"] as? Int)
            
        case .fadeTime:
            if let value = fadeTime {
                return UartDaliDevice.getConfigFadeTimeDetail(at: value, unit: "s")
            }
        case .fadeRate:
            if let value = fadeRate {
                return UartDaliDevice.getConfigFadeRateDetail(at: value, unit: "Steps/s")
            }
        }
        return nil
    }
    
    private func loadCellValues() {
        UartDaliManager.shared.delegate = self
        
        UartDaliManager.shared.getLevelRange(gatewayAddress: daliDevice.gatewayAddress, daliAddress: daliDevice.daliAddress)
        UartDaliManager.shared.getCctRange(gatewayAddress: daliDevice.gatewayAddress, daliAddress: daliDevice.daliAddress)
        UartDaliManager.shared.getCctPhysicalRange(gatewayAddress: daliDevice.gatewayAddress, daliAddress: daliDevice.daliAddress)
        UartDaliManager.shared.getSystemFailureState(gatewayAddress: daliDevice.gatewayAddress, daliAddress: daliDevice.daliAddress)
        UartDaliManager.shared.getPowerOnState(gatewayAddress: daliDevice.gatewayAddress, daliAddress: daliDevice.daliAddress)
        UartDaliManager.shared.getFadeTimeAndFadeRate(gatewayAddress: daliDevice.gatewayAddress, daliAddress: daliDevice.daliAddress)
    }
    
    private func getValueFromGateway(type: CellType) {
        switch type {
        case .levelRange:
            UartDaliManager.shared.getLevelRange(gatewayAddress: daliDevice.gatewayAddress, daliAddress: daliDevice.daliAddress)
        case .cctRange:
            UartDaliManager.shared.getCctRange(gatewayAddress: daliDevice.gatewayAddress, daliAddress: daliDevice.daliAddress)
        case .cctPhysicalRange:
            UartDaliManager.shared.getCctPhysicalRange(gatewayAddress: daliDevice.gatewayAddress, daliAddress: daliDevice.daliAddress)
        case .systemFailureState:
            UartDaliManager.shared.getSystemFailureState(gatewayAddress: daliDevice.gatewayAddress, daliAddress: daliDevice.daliAddress)
        case .powerOnState:
            UartDaliManager.shared.getPowerOnState(gatewayAddress: daliDevice.gatewayAddress, daliAddress: daliDevice.daliAddress)
        case .fadeTime: fallthrough
        case .fadeRate:
            UartDaliManager.shared.getFadeTimeAndFadeRate(gatewayAddress: daliDevice.gatewayAddress, daliAddress: daliDevice.daliAddress)
        }
    }
    
    private func setValueToGateway(type: CellType) {
        let alert = UIAlertController.makeNormal(title: "\(type)", message: nil, preferredStyle: .alert, viewController: self)
        var textField: UITextField?
        alert.addTextField() { tf in
            textField = tf
            textField?.keyboardType = .asciiCapable
            textField?.autocorrectionType = .no
        }
        let update = UIAlertAction(title: "Update", style: .default) { _ in
            guard let text = textField?.text, text.count > 0 else {
                return
            }
            let items = text.split(separator: " ")
            guard items.count > 0 else {
                return
            }
            let values = items.map { Int($0) ?? 0 }
            switch type {
            case .levelRange:
                self.setLevelRange(values: values)
            case .cctRange:
                self.setCctRange(values: values)
            case .cctPhysicalRange:
                self.setCctPhysicalRange(values: values)
            case .systemFailureState:
                self.setSystemFailureState(values: values)
            case .powerOnState:
                self.setPowerOnState(values: values)
            case .fadeTime:
                self.setFadeTime(values: values)
            case .fadeRate:
                self.setFadeRate(values: values)
            }
        }
        alert.addAction(update)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func setLevelRange(values: [Int]) {
        guard values.count >= 2 else {
            return
        }
        let min = values[0]
        let max = values[1]
        UartDaliManager.shared.setLevelRange(gatewayAddress: daliDevice.gatewayAddress, daliAddress: daliDevice.daliAddress, minValue: min, maxValue: max)
        UartDaliManager.shared.getLevelRange(gatewayAddress: daliDevice.gatewayAddress, daliAddress: daliDevice.daliAddress)
    }
    
    private func setCctRange(values: [Int]) {
        guard values.count >= 2 else {
            return
        }
        let min = values[0]
        let max = values[1]
        UartDaliManager.shared.setCctRange(gatewayAddress: daliDevice.gatewayAddress, daliAddress: daliDevice.daliAddress, minValue: min, maxValue: max)
        UartDaliManager.shared.getCctRange(gatewayAddress: daliDevice.gatewayAddress, daliAddress: daliDevice.daliAddress)
    }
    
    private func setCctPhysicalRange(values: [Int]) {
        guard values.count >= 2 else {
            return
        }
        let min = values[0]
        let max = values[1]
        UartDaliManager.shared.setCctPhysicalRange(gatewayAddress: daliDevice.gatewayAddress, daliAddress: daliDevice.daliAddress, minValue: min, maxValue: max)
        UartDaliManager.shared.getCctPhysicalRange(gatewayAddress: daliDevice.gatewayAddress, daliAddress: daliDevice.daliAddress)
    }
    
    private func setSystemFailureState(values: [Int]) {
        let dataPoints = getDataPointsFromValues(values)
        UartDaliManager.shared.setSystemFailureState(gatewayAddress: daliDevice.gatewayAddress, daliAddress: daliDevice.daliAddress, dataPoints: dataPoints, deviceType: daliDevice.deviceType)
        UartDaliManager.shared.getSystemFailureState(gatewayAddress: daliDevice.gatewayAddress, daliAddress: daliDevice.daliAddress)
    }
    
    private func setPowerOnState(values: [Int]) {
        let dataPoints = getDataPointsFromValues(values)
        UartDaliManager.shared.setPowerOnState(gatewayAddress: daliDevice.gatewayAddress, daliAddress: daliDevice.daliAddress, dataPoints: dataPoints, deviceType: daliDevice.deviceType)
        UartDaliManager.shared.getPowerOnState(gatewayAddress: daliDevice.gatewayAddress, daliAddress: daliDevice.daliAddress)
    }
    
    private func getDataPointsFromValues(_ values: [Int]) -> [String: Any] {
        var dataPoints: [String: Any] = [:]
        guard values.count > 0 else {
            return dataPoints
        }
        dataPoints["BRIGHTNESS"] = values[0]
        guard values.count > 0 else {
            return dataPoints
        }
        dataPoints["BRIGHTNESS"] = values[0]
        switch daliDevice.deviceType {
        case .dt6:
            break
        case .dt8Cct:
            if values.count > 1 {
                let cct = values[1]
                dataPoints["COLOR_TEMPERATURE"] = cct 
            }
        case .dt8Xy:
            if values.count > 2 {
                let x = values[1]
                let y = values[2]
                dataPoints["X"] = x
                dataPoints["Y"] = y
            }
        case .dt8Rgbw: fallthrough
        case .dt8Rgbwa:
            if values.count > 4 {
                let red = values[1]
                let green = values[2]
                let blue = values[3]
                let white = values[4]
                dataPoints["RED"] = red
                dataPoints["GREEN"] = green
                dataPoints["BLUE"] = blue
                dataPoints["WHITE"] = white
            }
        }
        return dataPoints
    }
    
    private func setFadeTime(values: [Int]) {
        guard values.count > 0 else {
            return
        }
        let fadeTime = values[0]
        UartDaliManager.shared.setFadeTime(gatewayAddress: daliDevice.gatewayAddress, daliAddress: daliDevice.daliAddress, value: fadeTime)
        UartDaliManager.shared.getFadeTimeAndFadeRate(gatewayAddress: daliDevice.gatewayAddress, daliAddress: daliDevice.daliAddress)
    }
    
    private func setFadeRate(values: [Int]) {
        guard values.count > 0 else {
            return
        }
        let fadeRate = values[0]
        UartDaliManager.shared.setFadeRate(gatewayAddress: daliDevice.gatewayAddress, daliAddress: daliDevice.daliAddress, value: fadeRate)
        UartDaliManager.shared.getFadeTimeAndFadeRate(gatewayAddress: daliDevice.gatewayAddress, daliAddress: daliDevice.daliAddress)
    }

}

extension BleUartModuleDeviceConfigController {
    
    enum CellType {
        case levelRange
        case cctRange
        case cctPhysicalRange
        case systemFailureState
        case powerOnState
        case fadeTime
        case fadeRate
    }
    
}

extension BleUartModuleDeviceConfigController: UartDaliManagerDelegate {
    
    func uartDaliManager(_ manager: UartDaliManager, didGetDeviceConfigMinLevel minLevel: Int, gatewayAddress: Int, daliAddress: Int) {
        guard daliDevice.gatewayAddress == gatewayAddress && daliDevice.daliAddress == daliAddress else {
            return
        }
        self.minLevel = minLevel
        tableView.reloadData()
    }
    
    func uartDaliManager(_ manager: UartDaliManager, didGetDeviceConfigMaxLevel minLevel: Int, gatewayAddress: Int, daliAddress: Int) {
        guard daliDevice.gatewayAddress == gatewayAddress && daliDevice.daliAddress == daliAddress else {
            return
        }
        self.maxLevel = minLevel
        tableView.reloadData()
    }
    
    func uartDaliManager(_ manager: UartDaliManager, didGetDeviceConfigMinCct minCct: Int, gatewayAddress: Int, daliAddress: Int) {
        guard daliDevice.gatewayAddress == gatewayAddress && daliDevice.daliAddress == daliAddress else {
            return
        }
        self.minCct = minCct
        tableView.reloadData()
    }
    
    func uartDaliManager(_ manager: UartDaliManager, didGetDeviceConfigMaxCct maxCct: Int, gatewayAddress: Int, daliAddress: Int) {
        guard daliDevice.gatewayAddress == gatewayAddress && daliDevice.daliAddress == daliAddress else {
            return
        }
        self.maxCct = maxCct
        tableView.reloadData()
    }
    
    func uartDaliManager(_ manager: UartDaliManager, didGetDeviceConfigMinPhysicalCct minCct: Int, gatewayAddress: Int, daliAddress: Int) {
        guard daliDevice.gatewayAddress == gatewayAddress && daliDevice.daliAddress == daliAddress else {
            return
        }
        self.minCctPhysical = minCct
        tableView.reloadData()
    }
    
    func uartDaliManager(_ manager: UartDaliManager, didGetDeviceConfigMaxPhysicalCct maxCct: Int, gatewayAddress: Int, daliAddress: Int) {
        guard daliDevice.gatewayAddress == gatewayAddress && daliDevice.daliAddress == daliAddress else {
            return
        }
        self.maxCctPhysical = maxCct
        tableView.reloadData()
    }
    
    func uartDaliManager(_ manager: UartDaliManager, didGetDeviceConfigSystemFailureState dataPoints: [String : Any], gatewayAddress: Int, daliAddress: Int) {
        guard daliDevice.gatewayAddress == gatewayAddress && daliDevice.daliAddress == daliAddress else {
            return
        }
        self.systemFailureState = dataPoints
        self.isSystemFailureStateMask = dataPoints["BRIGHTNESS_MASK"] as? Bool ?? false
        tableView.reloadData()
    }
    
    func uartDaliManager(_ manager: UartDaliManager, didGetDeviceConfigPowerOnState dataPoints: [String : Any], gatewayAddress: Int, daliAddress: Int) {
        guard daliDevice.gatewayAddress == gatewayAddress && daliDevice.daliAddress == daliAddress else {
            return
        }
        self.powerOnState = dataPoints
        self.isPowerOnStateMask = dataPoints["BRIGHTNESS_MASK"] as? Bool ?? false
        tableView.reloadData()
    }
    
    func uartDaliManager(_ manager: UartDaliManager, didGetDeviceConfigFadeTime fadeTime: Int, fadeRate: Int, gatewayAddress: Int, daliAddress: Int) {
        guard daliDevice.gatewayAddress == gatewayAddress && daliDevice.daliAddress == daliAddress else {
            return
        }
        self.fadeTime = fadeTime
        self.fadeRate = fadeRate
        tableView.reloadData()
    }
}
