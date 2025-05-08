//
//  SensorActionViewController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by 王文东 on 2023/3/22.
//

import UIKit
import TelinkBleMesh

class SensorActionViewController: UITableViewController {
    
    var address: Int = 0
    var event = MeshCommand.SensorEvent.microwaveDetected
    
    private var actions: [MeshCommand.SensorAction] = [
        .turnOnOff(isOn: true, transition: 0, isEnabled: true),
        .recallScene(sceneId: 1, isEnabled: true),
        .setState(brightness: 100, red: 0xFF, green: 0, blue: 0, ctOrWhite: 0, transition: 0, isEnabled: true),
        .setBrightness(brightness: 100, transition: 0, isEnabled: true),
        .setRGB(red: 0, green: 0xFF, blue: 0, isEnabled: true),
        .setRed(red: 0xFF, isEnabled: true),
        .setGreen(green: 0xFF, isEnabled: true),
        .setBlue(blue: 0xFF, isEnabled: true),
        .setRunning(index: 1, isEnabled: true),
        .setCustomRunning(index: 1, mode: .ascendShade, isEnabled: true),
        .stopRunning(isEnabled: true),
        .none
    ]
    
    private var currentAction: MeshCommand.SensorAction?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "\(event)"
        
        let refreshItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.refreshAction))
        navigationItem.rightBarButtonItem = refreshItem
        
        MeshManager.shared.deviceDelegate = self
        refreshAction()
    }
    
    @objc private func refreshAction() {
        
        MeshCommand.getSensorAction(address, event: event).send()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        showActionOptions(actions[indexPath.row])
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return actions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        var action = actions[indexPath.row]
        
        if currentAction?.uniqueId == action.uniqueId {
            
            cell.accessoryType = .checkmark
            actions[indexPath.row] = currentAction!
            action = currentAction!
            
        } else {
            
            cell.accessoryType = .none
        }
        
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = "\(action)"
        
        
        return cell
    }

}

extension SensorActionViewController {
    
    private func showActionOptions(_ action: MeshCommand.SensorAction) {
        
        let alert = UIAlertController(title: "Action", message: "\(action)", preferredStyle: .alert)
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.width / 2, y: view.bounds.height / 2, width: 1, height: 1)
        
        var textFields: [String: UITextField] = [:]
        
        switch action {
            
        case .turnOnOff:
            
            alert.addTextField { tf in
                textFields["isOn"] = tf
                tf.keyboardType = .numberPad
                tf.placeholder = "1 On, 0 Off"
            }
            
            alert.addTextField { tf in
                textFields["transition"] = tf
                tf.keyboardType = .numberPad
                tf.placeholder = "[0, 65535]"
            }
            
            alert.addTextField { tf in
                textFields["isEnabled"] = tf
                tf.keyboardType = .numberPad
                tf.placeholder = "1 Enabled, 0 Disabled"
            }
            
        
        case .recallScene:
            
            alert.addTextField { tf in
                textFields["sceneId"] = tf
                tf.keyboardType = .numberPad
                tf.placeholder = "[1, 254]"
            }
            
            alert.addTextField { tf in
                textFields["isEnabled"] = tf
                tf.keyboardType = .numberPad
                tf.placeholder = "1 Enabled, 0 Disabled"
            }
            
        case .setState:
            
            alert.addTextField { tf in
                textFields["brightness"] = tf
                tf.keyboardType = .numberPad
                tf.placeholder = "[0, 100]"
            }
            
            alert.addTextField { tf in
                textFields["red"] = tf
                tf.keyboardType = .numberPad
                tf.placeholder = "[0, 255]"
            }
            
            alert.addTextField { tf in
                textFields["green"] = tf
                tf.keyboardType = .numberPad
                tf.placeholder = "[0, 255]"
            }
            
            alert.addTextField { tf in
                textFields["blue"] = tf
                tf.keyboardType = .numberPad
                tf.placeholder = "[0, 255]"
            }
            
            alert.addTextField { tf in
                textFields["ctOrWhite"] = tf
                tf.keyboardType = .numberPad
                tf.placeholder = "ct [0, 100], white [0, 255]"
            }
            
            alert.addTextField { tf in
                textFields["transition"] = tf
                tf.keyboardType = .numberPad
                tf.placeholder = "[0, 65535]"
            }
            
            alert.addTextField { tf in
                textFields["isEnabled"] = tf
                tf.keyboardType = .numberPad
                tf.placeholder = "1 Enabled, 0 Disabled"
            }
            
        case .setBrightness:
            
            alert.addTextField { tf in
                textFields["brightness"] = tf
                tf.keyboardType = .numberPad
                tf.placeholder = "[0, 100]"
            }
            
            alert.addTextField { tf in
                textFields["transition"] = tf
                tf.keyboardType = .numberPad
                tf.placeholder = "[0, 65535]"
            }
            
            alert.addTextField { tf in
                textFields["isEnabled"] = tf
                tf.keyboardType = .numberPad
                tf.placeholder = "1 Enabled, 0 Disabled"
            }
            
        case .setRGB:
            
            alert.addTextField { tf in
                textFields["red"] = tf
                tf.keyboardType = .numberPad
                tf.placeholder = "[0, 255]"
            }
            
            alert.addTextField { tf in
                textFields["green"] = tf
                tf.keyboardType = .numberPad
                tf.placeholder = "[0, 255]"
            }
            
            alert.addTextField { tf in
                textFields["blue"] = tf
                tf.keyboardType = .numberPad
                tf.placeholder = "[0, 255]"
            }
            
            alert.addTextField { tf in
                textFields["isEnabled"] = tf
                tf.keyboardType = .numberPad
                tf.placeholder = "1 Enabled, 0 Disabled"
            }
            
        case .setRed:
            
            alert.addTextField { tf in
                textFields["red"] = tf
                tf.keyboardType = .numberPad
                tf.placeholder = "[0, 255]"
            }
            
            alert.addTextField { tf in
                textFields["isEnabled"] = tf
                tf.keyboardType = .numberPad
                tf.placeholder = "1 Enabled, 0 Disabled"
            }
            
        case .setGreen:
            
            alert.addTextField { tf in
                textFields["green"] = tf
                tf.keyboardType = .numberPad
                tf.placeholder = "[0, 255]"
            }
            
            alert.addTextField { tf in
                textFields["isEnabled"] = tf
                tf.keyboardType = .numberPad
                tf.placeholder = "1 Enabled, 0 Disabled"
            }
            
        case .setBlue:
            
            alert.addTextField { tf in
                textFields["blue"] = tf
                tf.keyboardType = .numberPad
                tf.placeholder = "[0, 255]"
            }
            
            alert.addTextField { tf in
                textFields["isEnabled"] = tf
                tf.keyboardType = .numberPad
                tf.placeholder = "1 Enabled, 0 Disabled"
            }
            
        case .setCtOrWhite:
            
            alert.addTextField { tf in
                textFields["ctOrWhite"] = tf
                tf.keyboardType = .numberPad
                tf.placeholder = "ct [0, 100], white [0, 255]"
            }
            
            alert.addTextField { tf in
                textFields["isEnabled"] = tf
                tf.keyboardType = .numberPad
                tf.placeholder = "1 Enabled, 0 Disabled"
            }
            
        case .setRunning:
            
            alert.addTextField { tf in
                textFields["index"] = tf
                tf.keyboardType = .numberPad
                tf.placeholder = "Value range [1, 20]."
            }
            
            alert.addTextField { tf in
                textFields["isEnabled"] = tf
                tf.keyboardType = .numberPad
                tf.placeholder = "1 Enabled, 0 Disabled"
            }
            
        case .setCustomRunning:
        
            alert.addTextField { tf in
                textFields["index"] = tf
                tf.keyboardType = .numberPad
                tf.placeholder = "Value range [0x01, 0x10]."
            }
            
            alert.addTextField { tf in
                textFields["mode"] = tf
                tf.keyboardType = .numberPad
                tf.placeholder = "Value range [0, 5]."
            }
            
            alert.addTextField { tf in
                textFields["isEnabled"] = tf
                tf.keyboardType = .numberPad
                tf.placeholder = "1 Enabled, 0 Disabled"
            }
            
        case .stopRunning:
            
            alert.addTextField { tf in
                textFields["isEnabled"] = tf
                tf.keyboardType = .numberPad
                tf.placeholder = "1 Enabled, 0 Disabled"
            }
            
        case .none:
            break
        }
        
        let setAction = UIAlertAction(title: "Set", style: .default) { [weak self] _ in
            
            guard let self = self else { return }
            
            switch action {
                
            case .turnOnOff:
                
                guard let isOnText = textFields["isOn"]?.text,
                      let transitionText = textFields["transition"]?.text,
                      let isEnabledText = textFields["isEnabled"]?.text else {
                    
                    NSLog("No text", "")
                    return
                }
                
                let newAction = MeshCommand.SensorAction.turnOnOff(isOn: isOnText == "1", transition: Int(transitionText) ?? 0, isEnabled: isEnabledText == "1")
                MeshCommand.setSensorAction(self.address, event: self.event, action: newAction).send()
                MeshCommand.getSensorAction(self.address, event: self.event).send()
                
            case .recallScene:
            
                guard let sceneIdText = textFields["sceneId"]?.text,
                      let isEnabledText = textFields["isEnabled"]?.text else {
                    
                    NSLog("No text", "")
                    return
                }
                
                let newAction = MeshCommand.SensorAction.recallScene(sceneId: Int(sceneIdText) ?? 0, isEnabled: isEnabledText == "1")
                MeshCommand.setSensorAction(self.address, event: self.event, action: newAction).send()
                MeshCommand.getSensorAction(self.address, event: self.event).send()
                
            case .setState:
                
                guard let brightnessText = textFields["brightness"]?.text,
                      let redText = textFields["red"]?.text,
                      let greenText = textFields["green"]?.text,
                      let blueText = textFields["blue"]?.text,
                      let ctOrWhiteText = textFields["ctOrWhite"]?.text,
                      let transitionText = textFields["transition"]?.text,
                      let isEnabledText = textFields["isEnabled"]?.text else {
                    
                    NSLog("No text", "")
                    return
                }
                
                let newAction = MeshCommand.SensorAction.setState(brightness: Int(brightnessText) ?? 0, red: Int(redText) ?? 0, green: Int(greenText) ?? 0, blue: Int(blueText) ?? 0, ctOrWhite: Int(ctOrWhiteText) ?? 0, transition: Int(transitionText) ?? 0, isEnabled: isEnabledText == "1")
                MeshCommand.setSensorAction(self.address, event: self.event, action: newAction).send()
                MeshCommand.getSensorAction(self.address, event: self.event).send()
                
            case .setBrightness:
            
                guard let brightnessText = textFields["brightness"]?.text,
                      let transitionText = textFields["transition"]?.text,
                      let isEnabledText = textFields["isEnabled"]?.text else {
                    
                    NSLog("No text", "")
                    return
                }
                
                let newAction = MeshCommand.SensorAction.setBrightness(brightness: Int(brightnessText) ?? 0, transition: Int(transitionText) ?? 0, isEnabled: isEnabledText == "1")
                MeshCommand.setSensorAction(self.address, event: self.event, action: newAction).send()
                MeshCommand.getSensorAction(self.address, event: self.event).send()
                
            case .setRGB:
                
                guard let redText = textFields["red"]?.text,
                      let greenText = textFields["green"]?.text,
                      let blueText = textFields["blue"]?.text,
                      let isEnabledText = textFields["isEnabled"]?.text else {
                    
                    NSLog("No text", "")
                    return
                }
                
                let newAction = MeshCommand.SensorAction.setRGB(red: Int(redText) ?? 0, green: Int(greenText) ?? 0, blue: Int(blueText) ?? 0, isEnabled: isEnabledText == "1")
                MeshCommand.setSensorAction(self.address, event: self.event, action: newAction).send()
                MeshCommand.getSensorAction(self.address, event: self.event).send()
                
            case .setRed:
            
                guard let redText = textFields["red"]?.text,
                      let isEnabledText = textFields["isEnabled"]?.text else {
                    
                    NSLog("No text", "")
                    return
                }
                
                let newAction = MeshCommand.SensorAction.setRed(red: Int(redText) ?? 0, isEnabled: isEnabledText == "1")
                MeshCommand.setSensorAction(self.address, event: self.event, action: newAction).send()
                MeshCommand.getSensorAction(self.address, event: self.event).send()
                
            case .setGreen:
                
                guard let greenText = textFields["green"]?.text,
                      let isEnabledText = textFields["isEnabled"]?.text else {
                    
                    NSLog("No text", "")
                    return
                }
                
                let newAction = MeshCommand.SensorAction.setGreen(green: Int(greenText) ?? 0, isEnabled: isEnabledText == "1")
                MeshCommand.setSensorAction(self.address, event: self.event, action: newAction).send()
                MeshCommand.getSensorAction(self.address, event: self.event).send()
                
            case .setBlue:
                
                guard let blueText = textFields["blue"]?.text,
                      let isEnabledText = textFields["isEnabled"]?.text else {
                    
                    NSLog("No text", "")
                    return
                }
                
                let newAction = MeshCommand.SensorAction.setBlue(blue: Int(blueText) ?? 0, isEnabled: isEnabledText == "1")
                MeshCommand.setSensorAction(self.address, event: self.event, action: newAction).send()
                MeshCommand.getSensorAction(self.address, event: self.event).send()
                
            case .setCtOrWhite:
                
                guard let ctOrWhiteText = textFields["ctOrWhite"]?.text,
                      let isEnabledText = textFields["isEnabled"]?.text else {
                    
                    NSLog("No text", "")
                    return
                }
                
                let newAction = MeshCommand.SensorAction.setCtOrWhite(ctOrWhite: Int(ctOrWhiteText) ?? 0, isEnabled: isEnabledText == "1")
                MeshCommand.setSensorAction(self.address, event: self.event, action: newAction).send()
                MeshCommand.getSensorAction(self.address, event: self.event).send()
                
            case .setRunning:
                
                guard let indexText = textFields["index"]?.text,
                      let isEnabledText = textFields["isEnabled"]?.text else {
                    
                    NSLog("No text", "")
                    return
                }
                
                let newAction = MeshCommand.SensorAction.setRunning(index: Int(indexText) ?? 0, isEnabled: isEnabledText == "1")
                MeshCommand.setSensorAction(self.address, event: self.event, action: newAction).send()
                MeshCommand.getSensorAction(self.address, event: self.event).send()
                
            case .setCustomRunning:
                
                guard let indexText = textFields["index"]?.text,
                      let modeText = textFields["mode"]?.text,
                      let isEnabledText = textFields["isEnabled"]?.text else {
                    
                    NSLog("No text", "")
                    return
                }
                
                let modeValue = UInt8(modeText) ?? 0
                let mode = MeshCommand.SensorAction.CustomRunningMode(rawValue: modeValue) ?? .ascendShade
                let newAction = MeshCommand.SensorAction.setCustomRunning(index: Int(indexText) ?? 0, mode: mode, isEnabled: isEnabledText == "1")
                MeshCommand.setSensorAction(self.address, event: self.event, action: newAction).send()
                MeshCommand.getSensorAction(self.address, event: self.event).send()
                
            case .stopRunning:
                
                guard let isEnabledText = textFields["isEnabled"]?.text else {
                    
                    NSLog("No text", "")
                    return
                }
                
                let newAction = MeshCommand.SensorAction.stopRunning(isEnabled: isEnabledText == "1")
                MeshCommand.setSensorAction(self.address, event: self.event, action: newAction).send()
                MeshCommand.getSensorAction(self.address, event: self.event).send()
                
            case .none:
                
                let newAction = MeshCommand.SensorAction.none
                MeshCommand.setSensorAction(self.address, event: self.event, action: newAction).send()
                MeshCommand.getSensorAction(self.address, event: self.event).send()
            }
        }
        alert.addAction(setAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
}

extension SensorActionViewController: MeshManagerDeviceDelegate {
    
    func meshManager(_ manager: MeshManager, device address: Int, didGetSensorEvent event: MeshCommand.SensorEvent, action: MeshCommand.SensorAction) {
        
        guard self.event == event else {
            
            NSLog("event is not the same \(self.event), \(event)", "")
            return
        }
        
        currentAction = action
        tableView.reloadData()
    }
    
}
