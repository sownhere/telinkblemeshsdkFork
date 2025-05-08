//
//  AppSettingsViewController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by 王文东 on 2023/11/2.
//

import UIKit

class AppSettingsViewController: UITableViewController {
    
    private var items: [AppSettings.Item] = [
        .autoGetDeviceType
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = items[indexPath.row]
        switch item {
        case .autoGetDeviceType:
            let isAuto = AppSettings.shared.getItemValue(item, defaultValue: true) as? Bool ?? true
            AppSettings.shared.setItemValue(item, newValue: !isAuto)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .value1, reuseIdentifier: "cell")
        let item = items[indexPath.row]
        cell.textLabel?.text = item.title
        switch item {
        case .autoGetDeviceType:
            let isAuto = AppSettings.shared.getItemValue(item, defaultValue: true) as? Bool ?? true
            cell.detailTextLabel?.text = isAuto ? "Auto" : "Manually"
        }
        return cell
    }
}

struct AppSettings {
    
    enum Item: String {
        case autoGetDeviceType = "Auto Get Device Type"
        
        var title: String {
            return self.rawValue
        }
        
        fileprivate var key: String {
            return "App Settings - \(title)"
        }
        
    }
    
    static let shared = AppSettings()
    
    private init() {
        
    }
    
    func getItemValue(_ item: Item, defaultValue: Any) -> Any {
        return UserDefaults.standard.value(forKey: item.key) ?? defaultValue
    }
    
    func setItemValue(_ item: Item, newValue: Any) {
        UserDefaults.standard.set(newValue, forKey: item.key)
        UserDefaults.standard.synchronize()
    }
}

