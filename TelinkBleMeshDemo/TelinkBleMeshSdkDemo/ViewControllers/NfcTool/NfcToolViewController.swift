//
//  NfcToolViewController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by 王文东 on 2023/4/12.
//

import UIKit
import TelinkBleMesh

class NfcToolViewController: UITableViewController {
    
    private let sections: [[CellType]] = [
        [.resetDevice]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Nfc Tool"
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cellType = getCellType(at: indexPath)
        switch cellType {
        case .resetDevice:
            NfcToolManager.shared.resetDevice(alertMessage: "Device Resetting...", succeededMessage: "Reset Succeeded!", failedMessage: "Failed to reset!", unsupportedDeviceMessage: "Unsupported Device!")
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sections[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
        let cellType = getCellType(at: indexPath)
        cell.textLabel?.text = cellType.title
        return cell
    }
    
    enum CellType: Int {
        
        case resetDevice = 0
        
        static let titles = ["Reset Device"]
        
        var title: String { return Self.titles[rawValue] }
    }
    
    private func getCellType(at indexPath: IndexPath) -> CellType {
        return sections[indexPath.section][indexPath.row]
    }

}
