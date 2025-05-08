//
//  CurtainViewController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by 王文东 on 2024/10/17.
//

import UIKit
import TelinkBleMesh

class CurtainViewController: UITableViewController {
    
    weak var device: MyDevice!
    var network: MeshNetwork!
    private var address: Int { return Int(device.meshDevice.address) }
    
    private var cells: [CellType] = [.open, .stop, .close, .calibrate,]

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Curtain - \(device.meshDevice.address) - \(device.deviceType!.curtainType)"
        let settingsItem = UIBarButtonItem(title: "settings".localization, style: .plain, target: self, action: #selector(self.settingsAction(_:)))
        navigationItem.rightBarButtonItem = settingsItem
    }
    
    @objc func settingsAction(_ sender: Any) {
        let controller = DeviceSettingsViewController(style: .grouped)
        controller.device = device
        controller.network = network
        navigationController?.pushViewController(controller, animated: true)
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch cells[indexPath.row] {
        case .open:
            MeshCommand.openCurtain(address, curtainType: device.deviceType?.curtainType ?? .normal).send()
        case .close:
            MeshCommand.closeCurtain(address, curtainType: device.deviceType?.curtainType ?? .normal).send()
        case .stop:
            MeshCommand.stopCurtainMoving(address, curtainType: device.deviceType?.curtainType ?? .normal)?.send()
        case .calibrate:
            MeshCommand.calibrateCurtain(address).send()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell.textLabel?.text = "\(cells[indexPath.row])"
        return cell
    }

    enum CellType {
        case open
        case stop
        case close
        case calibrate
    }

}
