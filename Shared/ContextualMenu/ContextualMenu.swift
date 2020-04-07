//
//  ContextualMenu.swift
//  RatesView
//
//  Created by Esie on 3/1/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showContextMenu(at sourcePoint: CGPoint, labels: [String], callbacks: [() -> Void]) {
        let sourceView = UIView()
        sourceView.backgroundColor = .clear
        sourceView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        sourceView.center = sourcePoint
        view.addSubview(sourceView)
        
        ContextMenu.shared.show(
            sourceViewController: self,
            viewController: ContextMenuViewController(labels: labels, callbacks: callbacks),
            options: ContextMenu.Options(
                containerStyle: ContextMenu.ContainerStyle(
                    backgroundColor: UIColor(red: 41/255.0, green: 45/255.0, blue: 53/255.0, alpha: 1)
                ),
                menuStyle: .minimal,
                hapticsStyle: .light
            ),
            sourceView: sourceView,
            delegate: nil
        )
    }
    
    func showPresentedMenu(_ vc: UIViewController) {
        ContextMenu.shared.show(
            sourceViewController: self,
            viewController: vc,
            options: ContextMenu.Options(
                containerStyle: ContextMenu.ContainerStyle(
                    backgroundColor: .clear//.presentedBackground
                ),
                menuStyle: .default,
                hapticsStyle: .light
            ),
            sourceView: nil,
            delegate: nil
        )
    }
}

class ContextMenuViewController: UITableViewController {
    
    var labels: [String]!
    var callbacks: [() -> Void]!
    
    init(labels: [String], callbacks: [() -> Void]) {
        super.init(nibName: nil, bundle: nil)
        self.labels = labels
        self.callbacks = callbacks
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier)
        tableView.reloadData()
        tableView.layoutIfNeeded()
        preferredContentSize = CGSize(width: 200, height: tableView.contentSize.height)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        tableView.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: UITableViewCell.reuseIdentifier)
        cell.textLabel?.text = labels[indexPath.row]
        cell.textLabel?.font = .boldSystemFont(ofSize: 17)
        cell.textLabel?.textColor = .white
        cell.backgroundColor = .clear
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        callbacks[indexPath.row]()
    }
}
