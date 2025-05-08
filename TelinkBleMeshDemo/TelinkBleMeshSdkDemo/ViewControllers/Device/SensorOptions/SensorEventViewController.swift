//
//  SensorEventViewController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by 王文东 on 2023/3/22.
//

import UIKit
import TelinkBleMesh

class SensorEventViewController: UITableViewController {
    
    var address: Int = 0
    
    private let events: [MeshCommand.SensorEvent] = [
        .doorOpen, .doorClosed,
        .pirDetected, .pirNotDetected,
        .microwaveDetected, .microwaveNotDetected
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Sensor Event"
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let event = events[indexPath.row]
        let controller = SensorActionViewController(style: .grouped)
        controller.event = event
        controller.address = address
        navigationController?.pushViewController(controller, animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return events.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .value1, reuseIdentifier: "cell")
        
        let event = events[indexPath.row]
        cell.textLabel?.text = "\(event)"
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }

}
