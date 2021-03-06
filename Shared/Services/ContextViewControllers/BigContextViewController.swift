//
//  BigContextViewController.swift
//  SmartConverter
//
//  Created by Esie on 4/11/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import UIKit
import RWExtensions

class BigContextViewController: UIViewController {

    let reuseIdentifier = "reuseIdentifier"
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    var cells: [String]!
    var icons: [UIImage]!
    var callbacks: [Callback]!
    
    init(cells: [String], icons: [UIImage] = [], callbacks: [Callback] = []) {
        super.init(nibName: nil, bundle: nil)
        self.cells = cells
        self.icons = icons
        self.callbacks = callbacks
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: -10)
        view.addSubview(tableView)
        tableView.frameConstraint()
        view.backgroundColor = .presentedBackground
        tableView.backgroundColor = .presentedBackground
        setOpaqueNavbar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
}

extension BigContextViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
        let index = indexPath.section
        let name = cells[index].split(separator: "-", maxSplits: 1)
        cell.backgroundColor = .presentedBackground
        cell.textLabel?.text = String(name[0])
        cell.textLabel?.textColor = .text
        cell.textLabel?.font = ConditionalProvider.selectorHeaderFont
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = String(name[1])
        cell.detailTextLabel?.font = ConditionalProvider.selectorTitleSecondary
        cell.detailTextLabel?.textColor = .textDetail
        cell.imageView?.image = icons[index].withTintColor(.text)
        cell.selectedBackgroundView = UIView(withBackgroundColor: .presentedItemBackground)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        callbacks[indexPath.section]()
    }

}
