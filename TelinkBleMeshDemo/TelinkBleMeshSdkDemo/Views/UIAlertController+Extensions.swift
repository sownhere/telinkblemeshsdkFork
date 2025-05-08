//
//  UIAlertController+Extensions.swift
//  TelinkBleMeshSdkDemo
//
//  Created by 王文东 on 2023/10/12.
//

import UIKit

extension UIAlertController {
    
    static func makeNormal(title: String?, message: String?, preferredStyle: UIAlertController.Style, viewController: UIViewController) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        alert.popoverPresentationController?.sourceView = viewController.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: viewController.view.bounds.width / 2, y: 88, width: 1, height: 1)
        return alert
    }
}
