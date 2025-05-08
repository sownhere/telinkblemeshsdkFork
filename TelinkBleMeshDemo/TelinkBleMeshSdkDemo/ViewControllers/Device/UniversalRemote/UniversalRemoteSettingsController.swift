//
//  UniversalRemoteSettingsController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by 王文东 on 2024/7/2.
//

import UIKit
import TelinkBleMesh

class UniversalRemoteSettingsController: UITableViewController {
    
    weak var device: MyDevice!
    var remoteId: String?
    var remoteIndex: MeshCommand.UniversalRemoteIndex = .first
    var remoteType: MeshDeviceType.UniversalRemoteType = .k12WithKnob
    var actions: [MeshCommand.UniversalRemoteAction] = MeshCommand.UniversalRemoteAction.k12EmptyActions()
    
    var sections: [[CellType]] = [
        [.remoteId, .remoteType, .loadActions],
        [.action],
        [.deleteRemoteId],
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "\(remoteIndex)"
        
        let saveItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(self.saveAction))
        navigationItem.rightBarButtonItem = saveItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // getActionsValue()
    }
    
    func getActionsValue() {
        MeshManager.shared.deviceDelegate = self
        let alert = UIAlertController.makeNormal(title: "Loading...", message: nil, preferredStyle: .alert, viewController: self)
        let interval: TimeInterval = 0.5
        let timeout = actions.count * 500
        present(alert, animated: true)
        let commands = MeshCommand.getUniversalRemoteActions(Int(device.meshDevice.address), remoteIndex: remoteIndex, actions: actions)
        MeshManager.shared.sendCommands(commands, intervalSeconds: interval)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(timeout), execute: {
            alert.dismiss(animated: true)
        })
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch cellType(at: indexPath) {
        case .remoteId:
            changeRemoteId()
        case .remoteType:
            break
        case .loadActions:
            getActionsValue()
        case .action:
            selectAction(actions[indexPath.row], index: indexPath.row)
        case .deleteRemoteId:
            deleteRemoteId()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].first == .action ? actions.count : sections[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.accessoryType = .disclosureIndicator
        let type = cellType(at: indexPath)
        cell.textLabel?.text = type.title
        cell.detailTextLabel?.text = nil
        switch type {
        case .remoteId:
            cell.detailTextLabel?.text = remoteId
        case .remoteType:
            cell.detailTextLabel?.text = remoteType.desc
            cell.accessoryType = .none
        case .loadActions:
            break
        case .action:
            let action = actions[indexPath.row]
            cell.textLabel?.text = action.title
            cell.detailTextLabel?.text = action.detail
        case .deleteRemoteId:
            break
        }
        return cell
    }

    enum CellType {
        case remoteId
        case remoteType
        case loadActions
        
        case action
        case deleteRemoteId
        
        var title: String {
            switch self {
            case .remoteId: return "Remote ID"
            case .remoteType: return "Remote Type"
            case .loadActions: return "Load Actions"
            case .action: return "Action"
            case .deleteRemoteId: return "Delete Remote ID"
            }
        }
    }
    
    func cellType(at indexPath: IndexPath) -> CellType {
        return sections[indexPath.section].first == .action ? .action : sections[indexPath.section][indexPath.row]
    }

    @objc func saveAction() {
        guard let realId = remoteId else {
            return
        }
        let commands = MeshCommand.saveUniversalRemoteActions(Int(device.meshDevice.address), remoteIndex: remoteIndex, remoteId: realId, actions: actions)
        let interval: TimeInterval = 0.5
        MeshManager.shared.sendCommands(commands, intervalSeconds: interval)
        let alert = UIAlertController.makeNormal(title: "Saving...", message: nil, preferredStyle: .alert, viewController: self)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500 * commands.count), execute: {
            alert.dismiss(animated: true)
        })
    }
    
    func changeRemoteId() {
        let controller = DiscoverSensorViewController(style: .grouped)
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func deleteRemoteId() {
        MeshCommand.deleteUniversalRemoteId(Int(device.meshDevice.address), remoteIndex: remoteIndex).send()
    }
    
    func selectAction(_ action: MeshCommand.UniversalRemoteAction, index: Int) {
        let alert = UIAlertController.makeNormal(title: nil, message: nil, preferredStyle: .actionSheet, viewController: self)
        alert.addAction(UIAlertAction(title: "Change Action", style: .default) { _ in
            self.changeAction(action, index: index)
        })
        alert.addAction(UIAlertAction(title: "Get Action", style: .default) { _ in
            MeshManager.shared.deviceDelegate = self
            MeshCommand.getUniversalRemoteAction(Int(self.device.meshDevice.address), remoteIndex: self.remoteIndex, keyIndex: action.keyIndex).send()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func changeAction(_ action: MeshCommand.UniversalRemoteAction, index: Int) {
        let controller = UniversalRemoteActionsController(style: .grouped)
        controller.actionIndex = index
        controller.action = action
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }

}

extension UniversalRemoteSettingsController: DiscoverSensorViewControllerDelegate {
    
    func discoverSensorViewController(_ controller: DiscoverSensorViewController, didSelectUniversalRemote universalRemote: MeshNode) {        
        remoteId = String(universalRemote.macValue, radix: 16).uppercased()
        remoteType = universalRemote.deviceType.universalRemoteType
        // update the actions
        actions = MeshCommand.UniversalRemoteAction.copyActionsWithRemoteType(remoteType, sourceActions: actions)
        tableView.reloadData()
    }
}

extension UniversalRemoteSettingsController: UniversalRemoteActionsControllerDelegate {
    
    func universalRemoteActionsController(_ controller: UniversalRemoteActionsController, didSelectAction action: MeshCommand.UniversalRemoteAction, atIndex index: Int) {
        if actions.count > index {
            actions[index] = action
            tableView.reloadData()
        }
        MeshCommand.setUniversalRemoteAction(Int(device.meshDevice.address), remoteIndex: remoteIndex, action: action).send()
        if let stopAction = action.stopAction {
            Thread.sleep(forTimeInterval: 0.5)
            MeshCommand.setUniversalRemoteAction(Int(device.meshDevice.address), remoteIndex: remoteIndex, action: stopAction).send()
        }
    }
}

extension UniversalRemoteSettingsController: MeshManagerDeviceDelegate {
    
    func meshManager(_ manager: MeshManager, device address: Int, didGetUniversalRemoteShortLongAction shortAction: MeshCommand.UniversalRemoteAction, longAction: MeshCommand.UniversalRemoteAction, remoteIndex: MeshCommand.UniversalRemoteIndex) {
        guard remoteIndex == self.remoteIndex else { return }
        for i in 0..<actions.count {
            let action = actions[i]
            if action.keyIndex == shortAction.keyIndex && action.keyType == shortAction.keyType {
                actions[i] = shortAction
                continue
            }
            if action.keyIndex == longAction.keyIndex && action.keyType == longAction.keyType {
                actions[i] = longAction
            }
        }
        tableView.reloadData()
    }
    
    func meshManager(_ manager: MeshManager, device address: Int, didGetUniversalRemoteRotationAction rotationAction: MeshCommand.UniversalRemoteAction, remoteIndex: MeshCommand.UniversalRemoteIndex) {
        if let index = actions.firstIndex(where: { $0.keyIndex == rotationAction.keyIndex && $0.keyType == rotationAction.keyType }) {
            actions[index] = rotationAction
        }
        tableView.reloadData()
    }
}
