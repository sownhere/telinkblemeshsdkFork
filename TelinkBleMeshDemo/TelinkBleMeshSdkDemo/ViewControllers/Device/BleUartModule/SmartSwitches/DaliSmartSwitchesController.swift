//
//  DaliSmartSwitchesController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by 王文东 on 2024/1/2.
//

import UIKit
import TelinkBleMesh

class DaliSmartSwitchesController: UITableViewController {
    
    var gatewayAddress: Int = 0
    
    private var switchIdText = "7000000D"
    private var switchId: Int {
        return Int(switchIdText, radix: 16) ?? 0
    }
    private var buttonCounts = MeshCommand.UartDali.ButtonCount.all
    private var buttonCount = MeshCommand.UartDali.ButtonCount.key4
    private var buttonPositions: [MeshCommand.UartDali.ButtonPosition] {
        return buttonCount.positions
    }
    private var buttonPosition: MeshCommand.UartDali.ButtonPosition = .key4TopLeft
    
    private var sections: [Section] = [.switchId, .buttonCount, .buttonPosition, .buttonAction, .deleteSmartSwitch, .getSmartSwitch]
    
    private typealias ButtonEvent = MeshCommand.UartDali.ButtonEvent
    private var buttonEventActions: [ButtonEvent: MeshCommand.UartDali.SmartSwitchAction] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Smart Switches"
        
        let saveItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.saveItemAction))
        navigationItem.rightBarButtonItem = saveItem
        
        buttonEventActions[.shortPress] = MeshCommand.UartDali.SmartSwitchAction(target: .init(targetType: .broadcast, deviceAddress: nil, groupId: nil), action: .init(actionType: .off, level: nil, sceneId: nil))
        buttonEventActions[.longPressBegin] = MeshCommand.UartDali.SmartSwitchAction(target: .init(targetType: .broadcast, deviceAddress: nil, groupId: nil), action: .init(actionType: .level, level: 125, sceneId: nil))
        buttonEventActions[.longPressEnd] = MeshCommand.UartDali.SmartSwitchAction(target: .init(targetType: .broadcast, deviceAddress: nil, groupId: nil), action: .init(actionType: .none, level: nil, sceneId: nil))
    }
    
    @objc private func saveItemAction() {
        buttonEventActions.forEach { buttonEvent, action in
            let commands = MeshCommand.UartDali.setSmartSwitch(self.gatewayAddress, switchId: switchId, buttonPosition: self.buttonPosition, buttonEvent: buttonEvent, smartSwitchAction: action)
            commands.forEach { $0.send() }
        }
    }
    

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let section = sections[indexPath.section]
        switch section {
        case .switchId:
            break
        case .buttonCount:
            buttonCount = buttonCounts[indexPath.row]
            buttonPosition = buttonPositions.first!
            tableView.reloadData()
        case .buttonPosition:
            buttonPosition = buttonPositions[indexPath.row]
            tableView.reloadData()
        case .buttonAction:
            let buttonEvent = ButtonEvent.all[indexPath.row]
            let controller = DaliActionSettingsController(style: .grouped)
            controller.gatewayAddress = gatewayAddress
            controller.buttonEvent = buttonEvent
            controller.delegate = self
            controller.smartSwitchAction = buttonEventActions[buttonEvent]
            navigationController?.pushViewController(controller, animated: true)
        case .deleteSmartSwitch:
            MeshCommand.UartDali.deleteSmartSwitch(gatewayAddress, buttonPosition: buttonPosition, switchId: switchId).send()
        case .getSmartSwitch:
            (0...7).forEach { index in
                MeshCommand.UartDali.getSmartSwitchId(gatewayAddress, index: index).send()
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .switchId: return 1
        case .buttonCount: return buttonCounts.count
        case .buttonPosition: return buttonPositions.count
        case .buttonAction: return ButtonEvent.all.count
        case .deleteSmartSwitch: return 1
        case .getSmartSwitch: return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ??
        UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell.accessoryType = .none
        cell.detailTextLabel?.text = nil
        
        let section = sections[indexPath.section]
        switch section {
        case .switchId:
            cell.textLabel?.text = section.title
            cell.detailTextLabel?.text = switchIdText
        case .buttonCount:
            let count = buttonCounts[indexPath.row]
            cell.textLabel?.text = count.title
            cell.accessoryType = count == buttonCount ? .checkmark : .none
        case .buttonPosition:
            let position = buttonPositions[indexPath.row]
            cell.textLabel?.text = position.title
            cell.accessoryType = position == buttonPosition ? .checkmark : .none
        case .buttonAction:
            let buttonEvent = ButtonEvent.all[indexPath.row]
            cell.textLabel?.text = buttonEvent.title
            let actionType = buttonEventActions[buttonEvent]?.action.actionType ?? .none
            cell.detailTextLabel?.text = "\(actionType)"
        case .deleteSmartSwitch: fallthrough
        case .getSmartSwitch:
            cell.textLabel?.text = section.title
        }
        return cell
    }
    
    
    
    enum Section {
        case switchId
        case buttonCount
        case buttonPosition
        case buttonAction
        case deleteSmartSwitch
        case getSmartSwitch
        
        var title: String {
            switch self {
            case .switchId:
                return "Switch ID"
            case .buttonCount:
                return "Button Count"
            case .buttonPosition:
                return "Button Position"
            case .buttonAction:
                return "Action"
            case .deleteSmartSwitch:
                return "Delete Smart Switch"
            case .getSmartSwitch:
                return "Get Smart Switches"
            }
        }
    }

}

extension MeshCommand.UartDali.ButtonCount {
    var title: String {
        switch self {
        case .key1: return "KEY 1"
        case .key2: return "KEY 2"
        case .key4: return "KEY 4"
        }
    }
}

extension MeshCommand.UartDali.ButtonPosition {
    var title: String {
        switch self {
        case .key1: return "KEY 1"
        case .key2Left: return "Left"
        case .key2Right: return "Right"
        case .key4TopLeft: return "Top Left"
        case .key4TopRight: return "Top Right"
        case .key4BottomLeft: return "Bottom Left"
        case .key4BottomRight: return "Bottom Right"
        }
    }
}

extension MeshCommand.UartDali.ButtonEvent {
    var title: String {
        switch self {
        case .shortPress:
            return "Short Press"
        case .longPressBegin:
            return "Long Press Begin"
        case .longPressEnd:
            return "Long Press End"
        }
    }
}

extension DaliSmartSwitchesController: DaliActionSettingsControllerDelegate {
    
    func daliActionSettingsController(_ controller: DaliActionSettingsController, didUpdate smartSwitchAction: MeshCommand.UartDali.SmartSwitchAction, forButtonEvent event: MeshCommand.UartDali.ButtonEvent) {
        buttonEventActions[event] = smartSwitchAction
        tableView.reloadData()
    }
    
}
