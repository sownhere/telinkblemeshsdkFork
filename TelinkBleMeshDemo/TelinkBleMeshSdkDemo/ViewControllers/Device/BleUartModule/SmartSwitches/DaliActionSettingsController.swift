//
//  DaliActionSettingsController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by 王文东 on 2024/1/2.
//

import UIKit
import TelinkBleMesh

protocol DaliActionSettingsControllerDelegate: NSObjectProtocol {
    func daliActionSettingsController(_ controller: DaliActionSettingsController, didUpdate smartSwitchAction: MeshCommand.UartDali.SmartSwitchAction, forButtonEvent event: MeshCommand.UartDali.ButtonEvent)
}

class DaliActionSettingsController: UITableViewController {
    
    weak var delegate: DaliActionSettingsControllerDelegate?
    
    var gatewayAddress: Int = 0
    var buttonEvent: MeshCommand.UartDali.ButtonEvent! = .shortPress
    var smartSwitchAction: MeshCommand.UartDali.SmartSwitchAction!
    
    private let sections: [SectionType] = [.target, .action]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = buttonEvent.title

        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneItemAction))
        navigationItem.rightBarButtonItem = doneItem
        
        if smartSwitchAction == nil {
            smartSwitchAction = MeshCommand.UartDali.SmartSwitchAction(target: MeshCommand.UartDali.SmartSwitchAction.Target(targetType: .broadcast, deviceAddress: nil, groupId: nil), action: MeshCommand.UartDali.SmartSwitchAction.Action(actionType: .off, level: nil, sceneId: nil))
        }
    }
    
    @objc private func doneItemAction() {
        delegate?.daliActionSettingsController(self, didUpdate: smartSwitchAction, forButtonEvent: buttonEvent)
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let section = sections[indexPath.section]
        switch section {
        case .target:
            let targetType = TargetCellType.all[indexPath.row]
            switch targetType {
            case .targetType:
                showSelectOptions(title: "Target Type", options: MeshCommand.UartDali.SmartSwitchAction.Target.TargetType.all) { newValue in
                    self.smartSwitchAction.target.targetType = newValue
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            case .deviceAddress:
                showValueInput(title: "Device Address", range: 0...63) { newValue in
                    self.smartSwitchAction.target.deviceAddress = newValue
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            case .groupId:
                showValueInput(title: "Group ID", range: 0...15) { newValue in
                    self.smartSwitchAction.target.groupId = newValue
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        case .action:
            let actionType = ActionCellType.all[indexPath.row]
            switch actionType {
            case .actionType:
                showSelectOptions(title: "Action Type", options: MeshCommand.UartDali.SmartSwitchAction.Action.ActionType.all) { newValue in
                    self.smartSwitchAction.action.actionType = newValue
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            case .levelValue:
                showValueInput(title: "Level Value", range: 0...254) { newValue in
                    self.smartSwitchAction.action.level = newValue
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            case .sceneId:
                showValueInput(title: "Scene ID", range: 0...15) { newValue in
                    self.smartSwitchAction.action.sceneId = newValue
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .target: return TargetCellType.all.count
        case .action: return ActionCellType.all.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ??
        UITableViewCell(style: .value1, reuseIdentifier: "cell")
        let section = sections[indexPath.section]
        switch section {
        case .target:
            let targetType = TargetCellType.all[indexPath.row]
            cell.textLabel?.text = targetType.title
            switch targetType {
            case .targetType:
                cell.detailTextLabel?.text = "\(smartSwitchAction.target.targetType)"
            case .deviceAddress:
                cell.detailTextLabel?.text = "\(smartSwitchAction.target.deviceAddress)"
            case .groupId:
                cell.detailTextLabel?.text = "\(smartSwitchAction.target.groupId)"
            }
        case .action:
            let actionType = ActionCellType.all[indexPath.row]
            cell.textLabel?.text = actionType.title
            switch actionType {
            case .actionType:
                cell.detailTextLabel?.text = "\(smartSwitchAction.action.actionType)"
            case .levelValue:
                cell.detailTextLabel?.text = "\(smartSwitchAction.action.level)"
            case .sceneId:
                cell.detailTextLabel?.text = "\(smartSwitchAction.action.sceneId)"
            }
        }
        return cell
    }

    enum SectionType {
        case target
        case action
    }
    
    enum TargetCellType {
        case targetType
        case deviceAddress
        case groupId
        
        static let all: [TargetCellType] = [.targetType, .deviceAddress, .groupId]
        
        var title: String {
            switch self {
            case .targetType:
                return "Target Type"
            case .deviceAddress:
                return "Device Address"
            case .groupId:
                return "Group ID"
            }
        }
    }
    
    enum ActionCellType {
        case actionType
        case levelValue
        case sceneId
        
        static let all: [ActionCellType] = [.actionType, .levelValue, .sceneId]
        
        var title: String {
            switch self {
            case .actionType:
                return "Action Type"
            case .levelValue:
                return "Level Value"
            case .sceneId:
                return "Scene ID"
            }
        }
    }
    
    private func showSelectOptions<T>(title: String, options: [T], updated: ((T) -> Void)?) {
        guard options.count > 0 else { return }
        let alert = UIAlertController.makeNormal(title: title, message: nil, preferredStyle: .actionSheet, viewController: self)
        options.forEach { option in
            alert.addAction(UIAlertAction(title: "\(option)", style: .default) { _ in
                updated?(option)
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showValueInput(title: String?, range: ClosedRange<Int>, updated: ((Int) -> Void)?) {
        let alert = UIAlertController.makeNormal(title: title, message: "\(range)", preferredStyle: .alert, viewController: self)
        var valueTextField: UITextField?
        alert.addTextField { tf in
            valueTextField = tf
            tf.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction(title: "Done", style: .default) { _ in
            guard let text = valueTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  let value = Int(text), range.contains(value) else {
                return
            }
            updated?(value)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

}
