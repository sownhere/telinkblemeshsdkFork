//
//  RoomScenesViewController.swift
//  TelinkBleMeshSdkDemo
//
//  Created by 王文东 on 2024/10/14.
//

import UIKit

class RoomScenesViewController: UITableViewController {
    
    private let cells: [CellType] = [.room1, .room2, .custom,]

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Room Scenes"
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var roomId: Int = 0x8001
        switch cells[indexPath.row] {
        case .room1:
            roomId = 0x8001
        case .room2:
            roomId = 0x8002
        case .custom:
            showCustomRoomIdInput()
            return
        }
        showRoomSceneController(roomId: roomId)
    }
    
    private func showCustomRoomIdInput() {
        let alert = UIAlertController.makeNormal(title: "Custom Room ID", message: "Input a room ID", preferredStyle: .alert, viewController: self)
        var roomIdTextField: UITextField!
        alert.addTextField { tf in
            roomIdTextField = tf
            tf.keyboardType = .numberPad
            tf.clearButtonMode = .always
            tf.autocorrectionType = .no
        }
        alert.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            guard let roomIdString = roomIdTextField.text,
                  let roomId = Int(roomIdString) else {
                NSLog("Invalid roomIdString", "")
                return
            }
            self?.showRoomSceneController(roomId: roomId | 0x8000)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showRoomSceneController(roomId: Int) {
        let controller = RoomSceneViewController(style: .insetGrouped)
        controller.roomId = roomId
        navigationController?.pushViewController(controller, animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .value1, reuseIdentifier: "cell")
        let cellType = cells[indexPath.row]
        cell.textLabel?.text = cellType.title
        return cell
    }
    
    enum CellType {
        case room1
        case room2
        case custom
        
        var title: String {
            switch self {
            case .room1: return "Room 1"
            case .room2: return "Room 2"
            case .custom: return "Custom"
            }
        }
    }

}
