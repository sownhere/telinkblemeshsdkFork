//
//  DeviceViewController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by maginawin on 2021/3/23.
//

import UIKit
import TelinkBleMesh

class DeviceViewController: UITableViewController {
    
    weak var device: MyDevice!
    var network: MeshNetwork!
    
    private var capabilities: [MeshDeviceType.Capability]!
    private let colorSliderTypes: [ColorSliderType] = [.red, .green, .blue, .hue]
    private var extendValue = LightExtendValue()
    
    private var isBrightnessChanging = false
    private var chaningTimer: Timer?
    
    private let cctSliders = ["colorTemperature", "w1", "w2", "w3",]
    
    private var isChannel1On = false
    private var isChannel2On = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let hexAddress = String(format: "0x%02X", device.meshDevice.address)
        self.title = "\(device.meshDevice.address) (\(hexAddress))"
        
        self.capabilities =  device.deviceType?.capabilities ?? []
        
        let settingsItem = UIBarButtonItem(title: "settings".localization, style: .plain, target: self, action: #selector(self.settingsAction(_:)))
        navigationItem.rightBarButtonItem = settingsItem
        
        isChannel1On = device.meshDevice.channel1State == .on
        isChannel2On = device.meshDevice.channel2State == .on
        
        MeshManager.shared.removeAllSendingCache()
        MeshManager.shared.deviceDelegate = self
        MeshCommand.getStatus(Int(device.meshDevice.address)).send()
    }
    
    @objc func settingsAction(_ sender: Any) {
        
        let controller = DeviceSettingsViewController(style: .grouped)
        controller.device = device
        controller.network = network
        navigationController?.pushViewController(controller, animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return capabilities.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let capability = capabilities[section]
        
        if capability == .rgb {
            return colorSliderTypes.count
        } else if capability == .colorTemperature {
            // ct, w1, w2, w3, www, rgbwww
            return cctSliders.count
        }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 52
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return capabilities[section].title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let capability = capabilities[indexPath.section]
        
        switch capability {
        
        case .onOff:
            return dequeueOnOffCell()
            
        case .brightness:
            return dequeueSliderCell("brightness", minValue: 0, maxValue: 100, value: Float(device.meshDevice.brightness), text: "\(device.meshDevice.brightness)")
            
        case .colorTemperature:
            return dequeueColorTemperature(type: cctSliders[indexPath.row])
            
        case .white:
            return dequeueSliderCell("white", minValue: 0, maxValue: 100, value: extendValue.white, text: "\(extendValue.white)")
            
        case .rgb:
            return dequeueColorCell(type: colorSliderTypes[indexPath.row])
            
        case .channel1OnOff:
            return dequeueOnOffChanneCell(channel: 1, isOn: isChannel1On)
        case .channel2OnOff:
            return dequeueOnOffChanneCell(channel: 2, isOn: isChannel2On)
        }
    }
    

}

extension DeviceViewController {
    
    private func dequeueOnOffCell() -> SwitchTableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "onOff") as? SwitchTableViewCell ??
            SwitchTableViewCell(style: .default, reuseIdentifier: "onOff")
        
        if device.deviceType?.lightType == .doubleChannelsOnOff {
            cell.rightSwitch.isOn = device.meshDevice.doubleChannelsState == .on
            cell.rightSwitch.isEnabled = device.meshDevice.state != .offline
            cell.textLabel?.text = device.meshDevice.doubleChannelsState.title
        } else {
            cell.rightSwitch.isOn = device.meshDevice.state == .on
            cell.rightSwitch.isEnabled = device.meshDevice.state != .offline
            cell.textLabel?.text = device.meshDevice.state.title
        }
        cell.delegate = self        
        return cell
    }
    
    private func dequeueOnOffChanneCell(channel: Int, isOn: Bool) -> SwitchTableViewCell {
        let identifier = "onOffChannel_\(channel)"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? SwitchTableViewCell ??
            SwitchTableViewCell(style: .default, reuseIdentifier: identifier)
        cell.rightSwitch.isOn = isOn
        cell.rightSwitch.isEnabled = true
        cell.textLabel?.text = isOn ? "On" : "Off"
        cell.delegate = self
        return cell
    }
    
    
    
    private func dequeueSliderCell(_ identifier: String, minValue: Float, maxValue: Float, value: Float, text: String?) -> SliderTableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? SliderTableViewCell ??
            SliderTableViewCell(style: .default, reuseIdentifier: identifier)
        
        cell.slider.minimumValue = minValue
        cell.slider.maximumValue = maxValue
        cell.slider.value = value
        cell.valueLabel.text = text
        cell.delegate = self
        
        return cell
    }
    
    private func dequeueColorTemperature(type: String) -> SliderTableViewCell {
        switch type {
        case "w1":
            return dequeueSliderCell(type, minValue: 0, maxValue: 255, value: extendValue.w1, text: "\(Int(extendValue.w1))")
        case "w2":
            return dequeueSliderCell(type, minValue: 0, maxValue: 255, value: extendValue.w2, text: "\(Int(extendValue.w2))")
        case "w3":
            return dequeueSliderCell(type, minValue: 0, maxValue: 255, value: extendValue.w3, text: "\(Int(extendValue.w3))")
        default:
            break
        }
        return dequeueSliderCell("colorTemperature", minValue: 0, maxValue: 100, value: extendValue.colorTemperature, text: "\(Int(extendValue.colorTemperature))")
    }
    
    private func dequeueColorCell(type: ColorSliderType) -> SliderTableViewCell {
        
        switch type {
        
        case .red:
            
            let cell = dequeueSliderCell("red", minValue: 0, maxValue: 255, value: extendValue.red, text: "\(Int(extendValue.red))")
            cell.slider.minimumTrackTintColor = .systemRed
            return cell
            
        case .green:
            
            let cell = dequeueSliderCell("green", minValue: 0, maxValue: 255, value: extendValue.green, text: "\(Int(extendValue.green))")
            cell.slider.minimumTrackTintColor = .systemGreen
            return cell
            
        case .blue:
            
            let cell = dequeueSliderCell("blue", minValue: 0, maxValue: 255, value: extendValue.blue, text: "\(Int(extendValue.blue))")
            cell.slider.minimumTrackTintColor = .blue
            return cell
            
        case .hue:
            return dequeueSliderCell("hue", minValue: 0, maxValue: 360, value: extendValue.hue, text: "\(Int(extendValue.hue))")
        }
    }
    
}

extension DeviceViewController: SwitchTableViewCellDelegate {
    
    func switchCell(_ cell: SwitchTableViewCell, switchValueChanged isOn: Bool) {
        cell.textLabel?.text = isOn ? MeshDevice.State.on.title : MeshDevice.State.off.title
        
        // This is an OnOffChannel cell, send OnOffChannel command for it.
        if let identifier = cell.reuseIdentifier, identifier.contains("Channel") {
            if identifier.contains("1") {
                isChannel1On = !isChannel1On
            } else if identifier.contains("2") {
                isChannel2On = !isChannel2On
            }
            MeshCommand.setDoubleChannelsOnOff(Int(device.meshDevice.address), isChannel1On: isChannel1On, isChannel2On: isChannel2On).send()
            return
        }
        
//        MeshCommand.turnOnOff(Int(device.meshDevice.address), isOn: isOn).send()
        let command = MeshCommand.turnOnOff(Int(device.meshDevice.address), isOn: isOn)
        let mqttMessage = MqttMessage.meshCommand(command, userId: "maginawin")
        MeshManager.shared.sendMqttMessage(mqttMessage)
    }
    
}

extension DeviceViewController: SliderTableViewCellDelegate {
    
    func sliderCell(_ cell: SliderTableViewCell, sliderValueChanging value: Float) {
        
        chaningTimer?.invalidate()
        chaningTimer = nil
        isBrightnessChanging = true
        
        handleSliderValueChange(cell, value: value)
    }
    
    func sliderCell(_ cell: SliderTableViewCell, sliderValueChanged value: Float) {
        
        chaningTimer?.invalidate()
        chaningTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] (timer) in
            
            self?.isBrightnessChanging = false
        })
        
        handleSliderValueChange(cell, value: value)
    }
    
    private func handleSliderValueChange(_ cell: SliderTableViewCell, value: Float) {
        
        let intValue = Int(round(value))
        cell.valueLabel.text = "\(intValue)"
        
        let address = Int(device.meshDevice.address)
        
        switch cell.reuseIdentifier {
        
        case "brightness":
            
            MeshCommand.setBrightness(address, value: intValue).send(isSample: true)
            
        case "colorTemperature":
            extendValue.colorTemperature = value
            MeshCommand.setColorTemperature(address, value: intValue).send(isSample: true)
        case "w1":
            extendValue.w1 = value
            MeshCommand.setW1(address, value: intValue, ctwDisabled: false).send(isSample: true)
        case "w2":
            extendValue.w2 = value
            MeshCommand.setW2(address, value: intValue, ctwDisabled: false).send(isSample: true)
        case "w3":
            extendValue.w3 = value
            MeshCommand.setW3(address, value: intValue, ctwDisabled: false).send(isSample: true)
            
        case "white":
            
            extendValue.white = value
            MeshCommand.setWhitePercentage(address, value: intValue).send(isSample: true)
            
        case "red":
            
            extendValue.red = value
            MeshCommand.setRed(address, value: intValue).send(isSample: true)
            
        case "green":
            
            extendValue.green = value
            MeshCommand.setGreen(address, value: intValue).send(isSample: true)
            
        case "blue":
            
            extendValue.blue = value
            MeshCommand.setBlue(address, value: intValue).send(isSample: true)
            
        case "hue":
            
            extendValue.hue = value
            let hue = CGFloat(intValue) / 360.0
            let color = UIColor(hue: hue, saturation: 1, brightness: 1, alpha: 1)
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            color.getRed(&red, green: &green, blue: &blue, alpha: nil)
            MeshCommand.setRgb(address, red: Int(red * 255), green: Int(green * 255), blue: Int(blue * 255)).send(isSample: true)
        
        default:
            break
        }
    }
    
}

extension DeviceViewController: MyDeviceDelegate {
    
    func deviceDidUpdateState(_ device: MyDevice) {
        
        guard device == self.device else { return }
        
        guard let index = capabilities.firstIndex(of: .onOff) else {
            
            return
        }
        
        let indexPath = IndexPath(row: 0, section: index)
        
        guard let cell = tableView.cellForRow(at: indexPath) as? SwitchTableViewCell else {
            
            return
        }
        
        // State on/off changed
        if cell.rightSwitch.isOn != (device.meshDevice.state == .on) {
            
            cell.rightSwitch.isOn = device.meshDevice.state == .on
            cell.rightSwitch.isEnabled = device.meshDevice.state != .offline
            cell.textLabel?.text = device.meshDevice.state.title
        }
        
        // Don't update brightness cell if is sliding.
        if isBrightnessChanging {
            
            return
        }
        
        // Update brightness if it's exists.
        if let brightnessIndex = capabilities.firstIndex(of: .brightness),
           let brightnessCell = tableView.cellForRow(at: IndexPath(row: 0, section: brightnessIndex)) as? SliderTableViewCell {
            
            brightnessCell.slider.value = Float(device.meshDevice.brightness)
            brightnessCell.valueLabel.text = "\(device.meshDevice.brightness)"
        }
    }
    
}

extension DeviceViewController {
    
    private enum ColorSliderType {
        case red
        case green
        case blue
        case hue
    }
    
    private struct LightExtendValue {
        var white: Float = 0
        var colorTemperature: Float = 0
        var w1: Float = 0
        var w2: Float = 0
        var w3: Float = 0
        var red: Float = 0
        var green: Float = 0
        var blue: Float = 0
        var hue: Float = 0
    }
    
}

extension DeviceViewController: MeshManagerDeviceDelegate {
    
    func meshManager(_ manager: MeshManager, device address: Int, didRespondStatusRed red: Int, green: Int, blue: Int, white: Int, cct: Int, brightness: Int, isOn: Bool, reserved1: Int, reserved2: Int) {
        if (device.meshDevice.state != .offline) {
            device.meshDevice.state = isOn ? .on : .off
        }
        device.meshDevice.brightness = brightness
        extendValue.red = Float(red)
        extendValue.green = Float(green)
        extendValue.blue = Float(blue)
        extendValue.white = Float(white)
        extendValue.colorTemperature = Float(cct)
        tableView.reloadData()
    }
    
    func meshManager(_ manager: MeshManager, didUpdateMeshDevices meshDevices: [MeshDevice]) {
        if let meshDevice = meshDevices.first(where: {$0.address == device.meshDevice.address}) {
            device.meshDevice = meshDevice
            isChannel1On = device.meshDevice.channel1State == .on
            isChannel2On = device.meshDevice.channel2State == .on
            tableView.reloadData()
        }
    }
    
}
