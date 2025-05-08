//
//  UniversalRemoteActionsController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by 王文东 on 2024/7/4.
//

import UIKit
import TelinkBleMesh

protocol UniversalRemoteActionsControllerDelegate: NSObjectProtocol {
    
    func universalRemoteActionsController(_ controller: UniversalRemoteActionsController, didSelectAction action: MeshCommand.UniversalRemoteAction, atIndex index: Int)
}

class UniversalRemoteActionsController: UITableViewController {
    
    weak var delegate: UniversalRemoteActionsControllerDelegate?
    
    var actionIndex: Int = 0
    var action: MeshCommand.UniversalRemoteAction!
    private var actionTypes: [MeshCommand.UniversalRemoteAction.ActionType] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Actions"
        actionTypes = action.actionTypes
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let type = actionTypes[indexPath.row]
        action.actionType = type
        showArgsInput(title: "\(type)", argsCount: type.argsCount)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actionTypes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .value1, reuseIdentifier: "cell")
        let type = actionTypes[indexPath.row]
        cell.textLabel?.text =  "\(type)"
        return cell
    }
    
    func showArgsInput(title: String?, argsCount: Int) {
        if argsCount == 0 {
            didSelectActionType()
            return
        }
        let alert = UIAlertController.makeNormal(title: title, message: nil, preferredStyle: .alert, viewController: self)
        var textFields: [UITextField] = []
        if argsCount > 0 {
            for _ in 0..<argsCount {
                alert.addTextField { tf in
                    tf.keyboardType = .numberPad
                    textFields.append(tf)
                }
            }
        }
        alert.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            var args: [UInt8] = []
            textFields.forEach { textField in
                if let valueString = textField.text, let value = UInt8(valueString, radix: 10) {
                    args.append(value)
                }
            }
            self?.action.args = args
            self?.didSelectActionType()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func didSelectActionType() {
        navigationController?.popViewController(animated: true)
        delegate?.universalRemoteActionsController(self, didSelectAction: action, atIndex: actionIndex)
    }

}
