//
//  BleUartModuleLogController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by 王文东 on 2023/9/4.
//

import UIKit

protocol BleUartLogManagerDelegate: NSObjectProtocol {
    
    func bleUartLogManager(_ manager: BleUartLogManager, didAppendLog log: String)
}

public class BleUartLogManager: NSObject {
    
    weak var delegate: BleUartLogManagerDelegate?
    
    private(set) var logs: [String] = []
    
    public static let shared = BleUartLogManager()
    
    private override init() {
        super.init()
    }
    
    public func appendLog(_ log: String) {
        logs.append(log)
        delegate?.bleUartLogManager(self, didAppendLog: log)
    }
    
    public func clearLog() {
        logs.removeAll()
    }
    
}

class BleUartModuleLogController: UITableViewController, BleUartLogManagerDelegate {
    
    private var logs = BleUartLogManager.shared.logs
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Uart Log"
        BleUartLogManager.shared.delegate = self
        
        let clear = UIBarButtonItem(title: "Clear", style: .done, target: self, action: #selector(self.clearHandler))
        navigationItem.rightBarButtonItem = clear
    }
    
    @objc private func clearHandler() {
        BleUartLogManager.shared.clearLog()
        logs = []
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ??
        UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = logs[indexPath.row]
        return cell
    }
    
    func bleUartLogManager(_ manager: BleUartLogManager, didAppendLog log: String) {
        DispatchQueue.main.async {
            self.logs.append(log)
            self.tableView.insertRows(at: [IndexPath(row: self.logs.count - 1, section: 0)], with: .automatic)
        }
    }
    
}
