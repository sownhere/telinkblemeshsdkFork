//
//  BleUartModuleCommandsController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by 王文东 on 2023/8/30.
//

import UIKit
import TelinkBleMesh

class BleUartModuleCommandsController: UITableViewController {
    
    var gatewayAddress: Int = 0
    
    private var sections: [SectionType] = [
        .config, .control, .query, .discover, .stopDiscover
    ]
    
    private var configs: [MeshCommand.UartDali.Config] = [
        .reset, .setMax, .setMin, .setSystemFailDt6,
        .setPowerOnDt6, .setFadeTime, .setFadeRate, .setExtendedFadeTime,
        .addToGroup, .removeFromGroup, .setDimmerCurve, .setFastFadeTime,
        .setOperateMode, .storeDtrAsShortAddress, .setSceneDt6, .removeFromScene,
        //
        .setCctStep, .setCctCoolest, .setCctWarmest, .setCctPhysicalCoolest,
        .setCctPhysicalWarmest, .setRgbwafControl,
        //
        .setPowerOnDt8Xy, .setPowerOnDt8Cct, .setSystemFailDt8Xy, .setSystemFailDt8Cct,
        .setSceneDt8Xy, .setSceneDt8Cct
    ]
    
    private var controls: [MeshCommand.UartDali.Control] = [
        .directArcPowerControl, .off, .up, .down,
        .stepUp, .stepDown, .stepDownAndOff, .onAndStepUp,
        .recallMaxLevel, .recallMinLevel, .goToScene, .goToLastLevel,
        .xCoordinateStepUp, .xCoordinateStepDown, .yCoordinateStepUp, .yCoordinateStepDown,
        .cctStepCooler, .cctStepWarmer,
        //
        .activateXy, .activateCct, .activateRgbwaf
    ]
    
    private var queries: [MeshCommand.UartDali.Query] = [
        .status, .controlGear, .lampFailure, .lampPowerOn,
        .limitError, .resetState, .missingShortAddress, .versionNumber,
        .contentDtr, .contentDtr1, .contentDtr2, .deviceType,
        .physicalMinimumLevel, .powerFailure, .maxLevel, .minLevel,
        .fadeTimeOrFadeRate, .groups0_7, .groups8_15, .memoryLocation,
        .lastLocation, .extendedVersionNumber, .cctCoolest, .physicalCoolest,
        .cctWarmest, .physicalWarmest,
        //
        .actualLevel, .powerOnLevel, .systemFailureLevel, .sceneValue
    ]
    
    private var discovers: [MeshCommand.UartDali.Discover] = [
        .allControlGearShallReact, .withoutShortAddressShallReact, .addressShallReact, .checkBusDevice
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Commands \(gatewayAddress)"
        
        UartDaliManager.shared.dataDelegate = self
        
        let log = UIBarButtonItem(title: "Log", style: .done, target: self, action: #selector(self.logHandler))
        navigationItem.rightBarButtonItem = log
    }
    
    @objc private func logHandler() {
        let controller = BleUartModuleLogController(style: .grouped)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    enum SectionType {
        case config
        case control
        case query
        case discover
        case stopDiscover
        
        var title: String {
            switch self {
            case .config: return "Config"
            case .control: return "Control"
            case .query: return "Query"
            case .discover: return "Discover"
            case .stopDiscover: return ""
            }
        }
    }
}

extension BleUartModuleCommandsController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch sections[indexPath.section] {
        case .config:
            handleConfig(configs[indexPath.row])
            
        case .control:
            handleControl(controls[indexPath.row])
            
        case .query:
            handleQuery(queries[indexPath.row])
            
        case .discover:
            handleDiscover(discovers[indexPath.row])
            
        case .stopDiscover:
            handleStopDiscover()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .config: return configs.count
        case .control: return controls.count
        case .query: return queries.count
        case .discover: return discovers.count
        case .stopDiscover: return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ??
        UITableViewCell(style: .value1, reuseIdentifier: "cell")
        switch sections[indexPath.section] {
        case .config:
            let item = configs[indexPath.row]
            cell.textLabel?.text = "\(item)"
            
        case .control:
            let item = controls[indexPath.row]
            cell.textLabel?.text = "\(item)"
            
        case .query:
            let item = queries[indexPath.row]
            cell.textLabel?.text = "\(item)"
            
        case .discover:
            let item = discovers[indexPath.row]
            cell.textLabel?.text = "\(item)"
            
        case .stopDiscover:
            cell.textLabel?.text = "Stop Discover"
        }
        
        return cell
    }
}

extension BleUartModuleCommandsController {
    
    private func handleConfig(_ config: MeshCommand.UartDali.Config) {
        let alert = UIAlertController(title: "Config", message: "\(config)", preferredStyle: .alert)
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        var daliAddressTextField: UITextField?
        alert.addTextField() { tf in
            daliAddressTextField = tf
            tf.placeholder = "DALI Address"
            tf.keyboardType = .numberPad
        }
        var valuesTextField: UITextField?
        alert.addTextField() { tf in
            valuesTextField = tf
            tf.autocorrectionType = .no
            tf.placeholder = "Values (Optional)"
            tf.keyboardType = .asciiCapable
        }
        let done = UIAlertAction(title: "Done", style: .default) { _ in
            let daliAddress = UInt8(daliAddressTextField?.text ?? "0") ?? 0
            let values = self.getValuesFromText(valuesTextField?.text)
            MeshCommand.UartDali.configDevice(self.gatewayAddress, daliAddr: daliAddress, config: config, values: values).send()
        }
        alert.addAction(done)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    private func handleControl(_ control: MeshCommand.UartDali.Control) {
        let alert = UIAlertController(title: "Control", message: "\(control)", preferredStyle: .alert)
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        var daliAddressTextField: UITextField?
        alert.addTextField() { tf in
            daliAddressTextField = tf
            tf.placeholder = "DALI Address"
            tf.keyboardType = .numberPad
        }
        var valuesTextField: UITextField?
        alert.addTextField() { tf in
            valuesTextField = tf
            tf.autocorrectionType = .no
            tf.placeholder = "Values (Optional)"
            tf.keyboardType = .asciiCapable
        }
        let done = UIAlertAction(title: "Done", style: .default) { _ in
            let daliAddress = UInt8(daliAddressTextField?.text ?? "0") ?? 0
            let values = self.getValuesFromText(valuesTextField?.text)
            MeshCommand.UartDali.controlDevice(self.gatewayAddress, daliAddr: daliAddress, control: control, values: values).send()
        }
        alert.addAction(done)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    private func handleQuery(_ query: MeshCommand.UartDali.Query) {
        let alert = UIAlertController(title: "Query", message: "\(query)", preferredStyle: .alert)
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        var daliAddressTextField: UITextField?
        alert.addTextField() { tf in
            daliAddressTextField = tf
            tf.placeholder = "DALI Address"
            tf.keyboardType = .numberPad
        }
        var valuesTextField: UITextField?
        alert.addTextField() { tf in
            valuesTextField = tf
            tf.autocorrectionType = .no
            tf.placeholder = "Values (Optional)"
            tf.keyboardType = .asciiCapable
        }
        let done = UIAlertAction(title: "Done", style: .default) { _ in
            let daliAddress = UInt8(daliAddressTextField?.text ?? "0") ?? 0
            let values = self.getValuesFromText(valuesTextField?.text)
            MeshCommand.UartDali.queryDevice(self.gatewayAddress, daliAddr: daliAddress, query: query, values: values).send()
        }
        alert.addAction(done)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    private func getValuesFromText(_ text: String?) -> [UInt8] {
        var result: [UInt8] = []
        if let text = text, text.count > 0 {
            let items = text.split(separator: " ")
            for item in items {
                if let value = Int(item) {
                    if value > 255 {
                        result.append(UInt8((value >> 8) & 0xFF))
                        result.append(UInt8(value & 0xFF))
                    } else {
                        result.append(UInt8(value & 0xFF))
                    }
                }
            }
        }
        return result
    }
    
    private func handleDiscover(_ discover: MeshCommand.UartDali.Discover) {
        MeshCommand.UartDali.terminateDiscovering(gatewayAddress).send()
        MeshCommand.UartDali.discoverDevice(gatewayAddress, discover: discover).send()
    }
    
    private func handleStopDiscover() {
        MeshCommand.UartDali.terminateDiscovering(gatewayAddress).send()
    }
    
}

extension BleUartModuleCommandsController: UartDaliManagerDataDelegate {
    
    func uartDaliManager(_ manager: UartDaliManager, didReceiveData data: Data) {
        BleUartLogManager.shared.appendLog(data.hex)
    }
}
