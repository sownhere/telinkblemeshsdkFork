//
//  SelectMultiSensorActionController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by 王文东 on 2024/8/24.
//

import UIKit
import TelinkBleMesh

protocol SelectMultiSensorActionControllerDelegate: NSObjectProtocol {
    func selectMultiSensorActionController(_ controller: SelectMultiSensorActionController, didSelectActionNo actionNo: MeshCommand.MultiSensorAction.ActionNo, args: [Int], at actionIndex: UInt8)
}

class SelectMultiSensorActionController: UITableViewController {
    
    weak var delegate: SelectMultiSensorActionControllerDelegate?
    
    private let actions = MeshCommand.MultiSensorAction.ActionNo.all
    var actionIndex: UInt8 = 1
    let message = "Brightness (0-100), CCT (0-100), RGB (0-255), Scene (1-16)\nLightMode: On(1), Off(2), Flash0.5(3), Flash1(4), Flash2(5), Flash3(6)\nLevelMode: Current(1), 100%(2), 50%(3), 25%(4)\nColorMode: Current(1), Red(2), Green(3), Blue(4), RedGreen(5), GreenBlue(6), RedBlue(7), WarmWhite(8), CoolWhite(9), White(10)"

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Select Action"
        
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let action = actions[indexPath.row]
        let argsCount = action.argsCount
        if argsCount == 0 {
            delegate?.selectMultiSensorActionController(self, didSelectActionNo: action, args: [], at: actionIndex)
            self.navigationController?.dismiss(animated: true)
        } else if (argsCount > 0) {
            let alert = UIAlertController.makeNormal(title: "\(action)", message: message, preferredStyle: .alert, viewController: self)
            var textFields: [UITextField] = []
            for i in 0..<argsCount {
                alert.addTextField { tf in
                    tf.placeholder = "Arg \(i + 1)"
                    tf.keyboardType = .numberPad
                    tf.clearButtonMode = .always
                    textFields.append(tf)
                }
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Done", style: .default) { _ in
                var args: [Int] = []
                for i in 0..<textFields.count {
                    if let text = textFields[i].text, let value = Int(text, radix: 10) {
                        args.append(value)
                    }
                }
                self.delegate?.selectMultiSensorActionController(self, didSelectActionNo: action, args: args, at: self.actionIndex)
                self.navigationController?.dismiss(animated: true)
            })
            present(alert, animated: true)
        }
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
