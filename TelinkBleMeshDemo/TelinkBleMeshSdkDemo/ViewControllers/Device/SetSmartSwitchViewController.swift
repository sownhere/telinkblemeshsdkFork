//
//  SetSmartSwitchViewController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by 王文东 on 2023/5/9.
//

import UIKit
import TelinkBleMesh

class SetSmartSwitchViewController: UITableViewController {
    
    var address: Int = 0
    
    typealias Actions = MeshCommand.SmartSwitchActions
    private var actions = Actions.default
    private var switchIdText: String? = "70000141"
    
    private let sections: [[CellType]] = [
        [.switchId],
        [.buttonCount, .buttonPosition, .shortPress, .longPress],
        [.delete]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Set Smart Switch"
        
        let saveItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(self.saveItemAction))
        navigationItem.rightBarButtonItem = saveItem
    }
    
    @objc private func saveItemAction() {
        guard let switchId = MeshCommand.getSmartSwitchId(switchIdText) else {
            NSLog("Please enter a valid Switch ID.", "")
            return
        }
        
        let commands = MeshCommand.saveSmartSwitch(address, switchId: switchId, actions: actions)
        MeshManager.shared.sendCommands(commands)
        let alert = UIAlertController(title: "Saving...", message: nil, preferredStyle: .alert)
        alert.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.width / 2, y: view.bounds.height / 2, width: 1, height: 1)
        alert.popoverPresentationController?.sourceView = view
        present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) { [weak self] in
            guard let self = self else { return }
            alert.dismiss(animated: true) {
                let alert2 = UIAlertController(title: "Saved!", message: nil, preferredStyle: .alert)
                alert2.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2, width: 1, height: 1)
                alert2.popoverPresentationController?.sourceView = self.view
                self.present(alert2, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    alert2.dismiss(animated: true)
                }
            }
        }
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cellType = sections[indexPath.section][indexPath.row]
        switch cellType {
        case .switchId:
            changeSwitchId()
        case .buttonCount:
            selectButtonCount()
        case .buttonPosition:
            selectButtonPosition()
        case .shortPress:
            selectShortPress()
        case .longPress:
            selectLongPress()
        case .delete:
            deleteSmartSwitch()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .value1, reuseIdentifier: "cell")
        let cellType = sections[indexPath.section][indexPath.row]
        cell.textLabel?.text = cellType.title
        switch cellType {
        case .switchId:
            cell.detailTextLabel?.text = switchIdText
        case .buttonCount:
            cell.detailTextLabel?.text = "\(actions.buttonCount)"
        case .buttonPosition:
            cell.detailTextLabel?.text = "\(actions.buttonPosition)"
        case .shortPress:
            cell.detailTextLabel?.text = "\(actions.shortPress)"
        case .longPress:
            cell.detailTextLabel?.text = "\(actions.longPress)"
        case .delete:
            cell.detailTextLabel?.text = nil
        }
        return cell
    }
    
    private func changeSwitchId() {
        let alert = UIAlertController.makeNormal(title: "Switch ID", message: "Hex String", preferredStyle: .alert, viewController: self)
        var textField: UITextField!
        alert.addTextField { tf in
            tf.keyboardType = .asciiCapable
            tf.autocorrectionType = .no
            tf.becomeFirstResponder()
            tf.clearButtonMode = .always
            textField = tf
        }
        alert.addAction(UIAlertAction(title: "Done", style: .default) { _ in
            if let newText = textField.text, newText.count == 8 {
                self.switchIdText = newText
                self.tableView.reloadData()
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func selectButtonCount() {
        let items = MeshCommand.SmartSwitchActions.ButtonCount.all
        let alert = UIAlertController(title: "Button Count", message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.width / 2, y: view.bounds.height / 2, width: 1, height: 1)
        alert.popoverPresentationController?.sourceView = view
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancel)
        items.forEach { item in
            let itemAction = UIAlertAction(title: "\(item)", style: .default) { [weak self] _ in
                self?.actions.buttonCount = item
                self?.actions.buttonPosition = item.positions.first!
                self?.tableView.reloadData()
            }
            alert.addAction(itemAction)
        }
        present(alert, animated: true)
    }
    
    private func selectButtonPosition() {
        let items: [MeshCommand.SmartSwitchActions.ButtonPosition] = actions.buttonCount.positions
        let alert = UIAlertController(title: "Button Position", message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.width / 2, y: view.bounds.height / 2, width: 1, height: 1)
        alert.popoverPresentationController?.sourceView = view
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancel)
        items.forEach { item in
            let itemAction = UIAlertAction(title: "\(item)", style: .default) { [weak self] _ in
                self?.actions.buttonPosition = item
                self?.tableView.reloadData()
            }
            alert.addAction(itemAction)
        }
        present(alert, animated: true)
    }
    
    private func selectShortPress() {
        let items = MeshCommand.SmartSwitchActions.ShortPress.all
        let alert = UIAlertController(title: "Short Press", message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.width / 2, y: view.bounds.height / 2, width: 1, height: 1)
        alert.popoverPresentationController?.sourceView = view
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancel)
        items.forEach { item in
            let itemAction = UIAlertAction(title: "\(item)", style: .default) { [weak self] _ in
                self?.actions.shortPress = item
                self?.tableView.reloadData()
                switch item {
                case .setBrightness:
                    self?.setBrightnessAction()
                default:
                    break
                }
            }
            alert.addAction(itemAction)
        }
        present(alert, animated: true)
    }
    
    private func selectLongPress() {
        let items = MeshCommand.SmartSwitchActions.LongPress.all
        let alert = UIAlertController(title: "Long Press", message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.width / 2, y: view.bounds.height / 2, width: 1, height: 1)
        alert.popoverPresentationController?.sourceView = view
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancel)
        items.forEach { item in
            let itemAction = UIAlertAction(title: "\(item)", style: .default) { [weak self] _ in
                self?.actions.longPress = item
                self?.tableView.reloadData()
            }
            alert.addAction(itemAction)
        }
        present(alert, animated: true)
    }
    
    private func deleteSmartSwitch() {
        guard let switchId = MeshCommand.getSmartSwitchId(switchIdText) else {
            NSLog("Please enter a valid Switch ID.", "")
            return
        }
        MeshCommand.deleteSavedSmartSwitch(address, switchId: switchId, buttonPosition: actions.buttonPosition).send()
    }
    
    private func setBrightnessAction() {
        let alert = UIAlertController(title: "Set brightness", message: nil, preferredStyle: .alert)
        alert.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.width / 2, y: view.bounds.height / 2, width: 1, height: 1)
        alert.popoverPresentationController?.sourceView = view
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancel)
        var textField: UITextField?
        alert.addTextField() { tf in
            textField = tf
        }
        let done = UIAlertAction(title: "Done", style: .default) { _ in
            guard let text = textField?.text, let value = UInt8(text) else {
                return
            }
            self.actions.brightness = value
        }
        alert.addAction(done)
        present(alert, animated: true)
    }
}

extension SetSmartSwitchViewController {
    
    enum CellType {
        case switchId
        case buttonCount
        case buttonPosition
        case shortPress
        case longPress
        case delete
        
        var title: String {
            switch self {
            case .switchId:
                return "Switch ID"
            case .buttonCount:
                return "Button Count"
            case .buttonPosition:
                return "Button Position"
            case .shortPress:
                return "Short Press Action"
            case .longPress:
                return "Long Press Action"
            case .delete:
                return "Delete Smart Switch"
            }
        }
    }
    
}
