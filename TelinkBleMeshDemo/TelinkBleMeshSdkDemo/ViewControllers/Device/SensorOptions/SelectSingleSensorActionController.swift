//
//  SelectSingleSensorActionController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by 王文东 on 2024/8/24.
//

import UIKit
import TelinkBleMesh

protocol SelectSingleSensorActionControllerDelegate: NSObjectProtocol {
    func selectSingleSensorActionController(_ controller: SelectSingleSensorActionController, didSelectActionNo action: MeshCommand.SingleSensorAction)
}

class SelectSingleSensorActionController: UITableViewController {
    
    weak var delegate: SelectSingleSensorActionControllerDelegate?
    
    private let actions = MeshCommand.SingleSensorAction.ActionNo.all
    var sensorType: MeshCommand.SingleSensorAction.SensorType = .doorContactSensor
    var actionIndex: UInt8 = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Select Action"
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let actionNo = actions[indexPath.row]
        var action = MeshCommand.SingleSensorAction(sensorType: sensorType, actionIndex: actionIndex, actionNo: actionNo)
        let alert = UIAlertController.makeNormal(title: "\(actionNo)", message: nil, preferredStyle: .alert, viewController: self)
        var brightnessTextField: UITextField?
        var cctOrWhiteTextField: UITextField?
        var redTextField: UITextField?
        var greenTextField: UITextField?
        var blueTextField: UITextField?
        var sceneIdTextField: UITextField?
        switch actionNo {
        case .setBrightness:
            alert.addTextField { tf in
                tf.keyboardType = .numberPad
                tf.clearButtonMode = .always
                tf.placeholder = "Brightness 0-100"
                brightnessTextField = tf
            }
        case .setCctOrWhite:
            alert.addTextField { tf in
                tf.keyboardType = .numberPad
                tf.clearButtonMode = .always
                tf.placeholder = "CCT 0-100, White 0-255"
                cctOrWhiteTextField = tf
            }
        case .setRgb:
            alert.addTextField { tf in
                tf.keyboardType = .numberPad
                tf.clearButtonMode = .always
                tf.placeholder = "Red 0-255"
                redTextField = tf
            }
            alert.addTextField { tf in
                tf.keyboardType = .numberPad
                tf.clearButtonMode = .always
                tf.placeholder = "Green 0-255"
                greenTextField = tf
            }
            alert.addTextField { tf in
                tf.keyboardType = .numberPad
                tf.clearButtonMode = .always
                tf.placeholder = "Blue 0-255"
                blueTextField = tf
            }
        case .recallScene:
            alert.addTextField { tf in
                tf.keyboardType = .numberPad
                tf.clearButtonMode = .always
                tf.placeholder = "Scene ID 1-254"
                sceneIdTextField = tf
            }
        case .undefined: fallthrough
        case .turnOn: fallthrough
        case .turnOff:
            delegate?.selectSingleSensorActionController(self, didSelectActionNo: action)
            navigationController?.dismiss(animated: true)
            return
        }
        alert.addAction(UIAlertAction(title: "Done", style: .default) { _ in
            action.brightness = self.getTextValue(brightnessTextField) ?? action.brightness
            action.cctOrWhite = self.getTextValue(cctOrWhiteTextField) ?? action.cctOrWhite
            action.red = self.getTextValue(redTextField) ?? action.red
            action.green = self.getTextValue(greenTextField) ?? action.green
            action.blue = self.getTextValue(blueTextField) ?? action.blue
            action.sceneId = self.getTextValue(sceneIdTextField) ?? action.sceneId
            self.delegate?.selectSingleSensorActionController(self, didSelectActionNo: action)
            self.navigationController?.dismiss(animated: true)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func getTextValue(_ textField: UITextField?) -> Int? {
        if let text = textField?.text, let value = Int(text) {
            return value
        }
        return nil
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .value1, reuseIdentifier: "cell")
        let action = actions[indexPath.row]
        cell.textLabel?.text = "\(action)"
        return cell
    }

}
