//
//  BleUartModuleSceneSettingsController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by 王文东 on 2023/9/6.
//

import UIKit
import TelinkBleMesh
import Toast

class BleUartModuleSceneSettingsController: UITableViewController {
    
    var gatewayAddress: Int = 0
    var scene: Int = 0
    
    // daliAddress: detail string
    // private var devStatus: [Int: String] = [:]
    private var loadIndex = 0
    
    private var isLoading = false
    private var devices: [UartDaliDevice] = []
    // daliAddress: dev.dataPoints
    private var devsDataPoints: [Int: [String: Any]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        devices = UartDaliManager.shared.getExistDevices(gatewayAddress)
        
        UartDaliManager.shared.delegate = self
        loadScenes()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard !isLoading else { return }
        let dev = devices[indexPath.row]
        loadIndex = indexPath.row 
        let alert = UIAlertController(title: "Update Scene", message: nil, preferredStyle: .alert)
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        var dataPoints: [String: Any] = dev.dataPoints
        if let _ = dataPoints["ERROR"] {
            dataPoints = dev.dataPoints
        }
        
        var briTextField: UITextField?
        if let brightness = dataPoints["BRIGHTNESS"] as? Int {
            alert.addTextField() { tf in
                briTextField = tf
                tf.keyboardType = .numberPad
                tf.text = "\(brightness)"
                tf.placeholder = "brightness"
            }
        }
        
        var xyTextField: UITextField?
        if let x = dataPoints["X"] as? Int, let y = dataPoints["Y"] as? Int {
            alert.addTextField() { tf in
                xyTextField = tf
                tf.keyboardType = .asciiCapable
                tf.text = "\(x) \(y)"
                tf.placeholder = "x y"
            }
        }
        
        var cctTextField: UITextField?
        if let cct = dataPoints["COLOR_TEMPERATURE"] as? Int {
            alert.addTextField() { tf in
                cctTextField = tf
                tf.keyboardType = .numberPad
                tf.text = "\(cct)"
                tf.placeholder = "cct"
            }
        }
        
        var rgbTextField: UITextField?
        if let r = dataPoints["RED"] as? Int, let g = dataPoints["GREEN"], let b = dataPoints["BLUE"], let w = dataPoints["WHITE"] as? Int {
            if let a = dataPoints["AMBER"] as? Int {
                alert.addTextField() { tf in
                    rgbTextField = tf
                    tf.keyboardType = .asciiCapable
                    tf.placeholder = "r g b w a"
                    tf.text = "\(r) \(g) \(b) \(w) \(a)"
                }
            } else {
                alert.addTextField() { tf in
                    rgbTextField = tf
                    tf.keyboardType = .asciiCapable
                    tf.placeholder = "r g b w"
                    tf.text = "\(r) \(g) \(b) \(w)"
                }
            }
        }
        
        alert.addAction(UIAlertAction(title: "Done", style: .default) { _ in
            
            if let briText = briTextField?.text, let briValue = Int(briText) {
                dataPoints["BRIGHTNESS"] = briValue
            }
            
            if let xyText = xyTextField?.text {
                let items = xyText.split(separator: " ")
                if items.count >= 2 {
                    let xText = String(items[0])
                    let yText = String(items[1])
                    if let xValue = Int(xText), let yValue = Int(yText) {
                        dataPoints["X"] = xValue
                        dataPoints["Y"] = yValue
                    }
                }
            }
            
            if let cctText = cctTextField?.text, let cctValue = Int(cctText) {
                dataPoints["COLLOR_TEMPERATURE"] = cctValue
            }
            
            if let rgbText = rgbTextField?.text {
                let items = rgbText.split(separator: " ")
                if items.count >= 4 {
                    let rValue = Int(items[0])
                    let gValue = Int(items[1])
                    let bValue = Int(items[2])
                    let wValue = Int(items[3])
                    dataPoints["RED"] = rValue
                    dataPoints["GREEN"] = gValue
                    dataPoints["BLUE"] = bValue
                    dataPoints["WHITE"] = wValue
                }
                if items.count >= 5 {
                    let aValue = Int(items[4])
                    dataPoints["AMBER"] = aValue
                }
            }
            
            UartDaliManager.shared.setDeviceSceneValue(gatewayAddress: self.gatewayAddress, daliAddress: dev.daliAddress, scene: self.scene, dataPoints: dataPoints, deviceType: dev.deviceType)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let dev = devices[indexPath.row]
        cell.textLabel?.text = dev.deviceType.rawValue + " \(dev.daliAddress)"
        cell.detailTextLabel?.text = getStatusDetail(daliAddress: dev.daliAddress)
        return cell
    }
}

extension BleUartModuleSceneSettingsController {
    
    private func loadScenes() {
        loadIndex = 0
        if devices.count == 0 { return }
        isLoading = true
        devsDataPoints.removeAll()
        tableView.reloadData()
        let dev = devices[loadIndex]
        UartDaliManager.shared.getDeviceSceneValue(gatewayAddress: gatewayAddress, daliAddress: dev.daliAddress, scene: scene)
    }
    
    private func loadNext() {
        guard isLoading else { return }
        loadIndex += 1
        if devices.count <= loadIndex {
            loadIndex = 0
            isLoading = false
            return
        }
        let dev = devices[loadIndex]
        UartDaliManager.shared.getDeviceSceneValue(gatewayAddress: gatewayAddress, daliAddress: dev.daliAddress, scene: scene)
    }
    
    private func loadSceneValue(daliAddress: Int) {
        UartDaliManager.shared.getDeviceSceneValue(gatewayAddress: gatewayAddress, daliAddress: daliAddress, scene: scene)
    }
}

extension BleUartModuleSceneSettingsController: UartDaliManagerDelegate {
    
    func uartDaliManager(_ manager: UartDaliManager, didExecuteCommandOK daliAddress: Int, gatewayAddress: Int, cmdType: UartDaliManager.ResponseCommandType, cmd: Any?) {
        guard self.gatewayAddress == gatewayAddress else { return }
        let dev = devices[loadIndex]
        guard dev.daliAddress == daliAddress else { return }
        view.makeToast("OK", position: .center)
    }
    
    func uartDaliManager(_ manager: UartDaliManager, didExecuteCommandFailed daliAddress: Int, gatewayAddress: Int, reason: UartDaliManager.CommandFailedReason, cmdType: UartDaliManager.ResponseCommandType, cmd: Any?) {
        guard self.gatewayAddress == gatewayAddress, isLoading else { return }
        let dev = devices[loadIndex]
        guard dev.daliAddress == daliAddress else { return }
        devsDataPoints[daliAddress] = ["ERROR": reason]
        tableView.reloadRows(at: [IndexPath(row: loadIndex, section: 0)], with: .automatic)
        loadNext()
    }
    
    func uartDaliManager(_ manager: UartDaliManager, didGetDeviceSceneValue sceneValue: [String : Any], gatewayAddress: Int, daliAddress: Int) {
        guard self.gatewayAddress == gatewayAddress else { return }
        devsDataPoints[daliAddress] = sceneValue
        if let index = devices.firstIndex(where: { $0.daliAddress == daliAddress }) {
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
        if isLoading {
            loadNext()
        }
    }
    
    func uartDaliManager(_ manager: UartDaliManager, didUpdateDeviceSceneValue gatewayAddress: Int, daliAddress: Int) {
        guard self.gatewayAddress == gatewayAddress else { return }
        loadSceneValue(daliAddress: daliAddress)
    }
    
    private func getStatusDetail(daliAddress: Int) -> String? {
        if let dataPoints = devsDataPoints[daliAddress] {
            if let _ = dataPoints["ERROR"] {
                return "Error"
            } else {
                var result = ""
                if let bri = dataPoints["BRIGHTNESS"] as? Int {
                    result += bri == 0xFF ? "brightness MASK " : "brightness \(bri) "
                }
                if let x = dataPoints["X"] as? Int, let y = dataPoints["Y"] as? Int {
                    let xText = x == 0xFFFF ? "MASK" : "\(x)"
                    let yText = y == 0xFFFF ? "MASK" : "\(y)"
                    result += "xy \(xText), \(yText) "
                }
                if let cct = dataPoints["COLOR_TEMPERATURE"] as? Int {
                    let cctText = cct == 0xFFFF ? "MASK" : "\(cct) "
                    result += "cct \(cctText)"
                }
                if let r = dataPoints["RED"] as? Int, let g = dataPoints["GREEN"], let b = dataPoints["BLUE"] as? Int, let w = dataPoints["WHITE"], let a = dataPoints["AMBER"] as? Int {
                    let rText = r == 0xFF ? "MASK" : "\(r)"
                    let gText = r == 0xFF ? "MASK" : "\(g)"
                    let bText = r == 0xFF ? "MASK" : "\(b)"
                    let wText = r == 0xFF ? "MASK" : "\(w)"
                    let aText = r == 0xFF ? "MASK" : "\(a)"
                    result += "rgbwa \(rText), \(gText), \(bText), \(wText), \(aText) "
                }
                return result
            }
        }
        return "Laoding..."
    }
}
