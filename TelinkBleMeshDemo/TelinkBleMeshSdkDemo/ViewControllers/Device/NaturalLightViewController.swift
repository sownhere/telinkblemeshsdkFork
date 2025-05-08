//
//  NaturalLightViewController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by 王文东 on 2023/5/17.
//

import UIKit
import TelinkBleMesh

class NaturalLightViewController: UITableViewController {
    
    var address: Int = 0
    
    private let sections: [[CellType]] = [
        [.mode, .getCurrentState, .enable, .disable],
        [.getNaturalLight, .setNaturalLight, .editNaturalLight],
        [.resetAll]
    ]
    private var alert: UIAlertController?
    private var naturalLight = MeshCommand.NaturalLight()
    private var mode: MeshCommand.NaturalLight.Mode = .mode1
    private var operation: Operation = .none
    private var runState: RunState = .disabled
    private var getState: GetState = .none

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Natural Light"
        NaturalLightManager.shared.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getCurrentState()
        getNaturalLight()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)        
        NaturalLightManager.shared.stopGetNaturalLight()
        NaturalLightManager.shared.stopSetNaturalLight()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cellType = getCellTypeAt(indexPath)
        switch cellType {
        case .mode:
            changeMode()
        case .getCurrentState:
            getCurrentState()
        case .enable:
            enableAction(true)
        case .disable:
            enableAction(false)
        case .getNaturalLight:
            getNaturalLight()
        case .setNaturalLight:
            setNaturalLight()
        case .resetAll:
            resetAll()
        default:
            break
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
        let cellType = getCellTypeAt(indexPath)
        cell.textLabel?.text = cellType.title
        cell.accessoryType = .disclosureIndicator
        switch cellType {
        case .mode:
            cell.detailTextLabel?.text = mode.title
        case .getCurrentState:
            cell.detailTextLabel?.text = runState.title
        case .getNaturalLight:
            cell.detailTextLabel?.text = getState.title
        default:
            cell.detailTextLabel?.text = nil
        }
        return cell
    }
    
    private func getCellTypeAt(_ indexPath: IndexPath) -> CellType {
        return sections[indexPath.section][indexPath.row]
    }

}

extension NaturalLightViewController {
    
    enum CellType: Int {
        case mode = 0
        case getCurrentState
        case enable
        case disable
        case getNaturalLight
        case setNaturalLight
        case editNaturalLight
        case resetAll
        
        static let titles = [
            "Mode", "Get Current State", "Enable", "Disable",
            "Get Natural Light", "Set Natural Light", "Edit",
            "Reset All"
        ]
        
        var title: String {
            return CellType.titles[rawValue]
        }
    }
    
    enum Operation {
        case none
        case getState
        case getNaturalLight
        case setNaturalLight
        case resetAll
    }
    
    enum RunState: Int {
        case disabled = 0
        case enabled
        
        static let titles = ["Disabled", "Enabled"]
        var title: String { Self.titles[rawValue] }
    }
    
    enum GetState: Int {
        case none = 0
        case invalidData
        case ok
        case empty
        
        static let titles = ["", "Invalid Data", "OK", "Empty"]
        var title: String { Self.titles[rawValue] }
        
        static func makeState(itemsCount: Int) -> GetState {
            if itemsCount == 24 { return .ok }
            if itemsCount == 0 { return .empty }
            return .invalidData
        }
    }
}

extension MeshCommand.NaturalLight.Mode {
    
    var title: String {
        return "Mode \(rawValue)"
    }
}

extension NaturalLightViewController {
    
    private func changeMode() {
        let alert = UIAlertController(title: "Change Mode", message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.width / 2, y: view.bounds.height / 2, width: 1, height: 1)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancel)
        let modes: [MeshCommand.NaturalLight.Mode] = [
            .mode1, .mode2, .mode3, .mode4
        ]
        for mode in modes {
            let modeAction = UIAlertAction(title: "\(mode.title)", style: .default) { [weak self] _ in
                self?.clearItems()
                self?.mode = mode
                self?.tableView.reloadData()
                self?.getNaturalLight()
            }
            alert.addAction(modeAction)
        }
        present(alert, animated: true)
    }
    
    private func getCurrentState() {
        clearItems()
        operation = .getState
        showAlert("Get Current State", message: nil)
        NaturalLightManager.shared.getCurrentState(address: address)
    }
    
    private func enableAction(_ isEnabled: Bool) {
        if (isEnabled) {
            MeshCommand.enableNaturalLight(address, mode: mode).send()
        } else {
            MeshCommand.disableNaturalLight(address).send()
        }
        getCurrentState()
    }
    
    private func getNaturalLight() {
        clearItems()
        tableView.reloadData()
        operation = .getNaturalLight
        showAlert("Get Natural Light", message: "...")
        NaturalLightManager.shared.startGetNaturalLight(address: address, mode: mode)
    }
    
    private func setNaturalLight() {
        if naturalLight.items.count > 0 {
            showAlert("Sorry, you need to reset all first", message: nil)
            return
        }
        operation = .setNaturalLight
        naturalLight = .makeTemplateNaturalLight(.standard)
        showAlert("Set Natural Light", message: "...")
        NaturalLightManager.shared.startSetNaturalLight(address: address, naturalLight: naturalLight, mode: mode, isEnabled: runState == .enabled)
    }
    
    private func clearItems() {
        naturalLight.items.removeAll()
        tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
    }
    
    private func resetAll() {
        showAlert("Resetting...", message: nil)
        operation = .resetAll
        MeshCommand.disableNaturalLight(address).send()
        MeshCommand.resetNaturalLight(address).send()
    }
    
}

extension NaturalLightViewController: NaturalLightManagerDelegate {
    
    func naturalLightManager(manager: NaturalLightManager, didStateEnabled address: Int, mode: MeshCommand.NaturalLight.Mode) {
        guard self.address == address else { return }
        runState = .enabled
        operation = .none
        self.mode = mode
        tableView.reloadData()
        dismissAlert()
    }
    
    func naturalLightManager(manager: NaturalLightManager, didStateDisabled address: Int) {
        guard self.address == address else { return }
        runState = .disabled
        tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
        dismissAlert()
    }
    
    func naturalLightManager(_ manager: NaturalLightManager, address: Int, didGetInvalidDataAt mode: MeshCommand.NaturalLight.Mode) {
        guard self.address == address else { return }
        NSLog("didGetInvalidDataAt \(mode)", "")
        switch operation {
        case .getState:
            break
        case .getNaturalLight:
            getState = GetState.makeState(itemsCount: naturalLight.items.count)
            tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
        default:
            break
        }
        operation = .none
        dismissAlert()
    }
    
    func naturalLightManager(_ manager: NaturalLightManager, address: Int, didGetItem item: MeshCommand.NaturalLight.Item, at mode: MeshCommand.NaturalLight.Mode) {
        guard self.address == address else { return }
        NSLog("didGetItem \(item) at \(mode)", "")
        
        switch operation {
        case .getState:
            break
        case .getNaturalLight:
            guard mode == self.mode else {
                NSLog("mode \(mode) isn't equals self.mode \(self.mode)", "")
                return
            }
            naturalLight.items.append(item)
            updateAlertMessage("\(item.hour)/23")
        case .setNaturalLight:
            updateAlertMessage("\(item.hour)/23")
        default:
            break
        }
    }
    
    func naturalLightManagerDidResetOK(_ manager: NaturalLightManager, address: Int) {
        guard self.address == address else { return }
        operation = .none
        runState = .disabled
        getState = .empty
        tableView.reloadData()
        dismissAlert()
    }
    
    func naturalLightManagerDidSetEnd(_ manager: NaturalLightManager, address: Int) {
        guard self.address == address else { return }
        operation = .none
        getState = GetState.makeState(itemsCount: naturalLight.items.count)
        tableView.reloadData()
        dismissAlert()
    }
    
    func naturalLightManagerDidGetEnd(_ manager: NaturalLightManager, address: Int) {
        guard self.address == address else { return }
        operation = .none
        getState = GetState.makeState(itemsCount: naturalLight.items.count)
        tableView.reloadData()
        dismissAlert()
    }
    
    private func showAlert(_ title: String, message: String?) {
        dismissAlert()
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Close", style: .cancel) { [weak self] _ in
            self?.operation = .none
            self?.getState = GetState.makeState(itemsCount: self?.naturalLight.items.count ?? 0)
            NaturalLightManager.shared.stopGetNaturalLight()
            NaturalLightManager.shared.stopSetNaturalLight()
            self?.tableView.reloadData()
        }
        alert.addAction(cancelAction)
        present(alert, animated: true)
        self.alert = alert
    }
    
    private func dismissAlert() {
        alert?.dismiss(animated: true)
    }
    
    private func updateAlertMessage(_ message: String?) {
        alert?.message = message
    }
}
