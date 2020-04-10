//
//  AssetSelectorViewController.swift
//  RatesView
//
//  Created by Dennis Esie on 11/26/19.
//  Copyright © 2019 Denis Esie. All rights reserved.
//

import UIKit
import RWExtensions
import RWUserInterface

final class AssetSelectorViewController: RWViewController {
    
    var presenter: AssetSelectorPresenter!
    
    private lazy var dataSource = makeCell()
    private lazy var typeTableView = UITableView(frame: .zero, style: .insetGrouped)
    private lazy var searchField = UITextField()
    
    override func superDidLoad() {
        setInvisibleNavbar()
        view.backgroundColor = .presentedBackground
        preferredContentSize = standartPresentationSize
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dissmis))
    }
    
    //MARK: UI Update
    
    override func updateDataSource(animated: Bool) {
        DispatchQueue.global(qos: .userInteractive).async {
            var tableSnapshot = NSDiffableDataSourceSnapshot<FinanceAsset.SourceSection, String>()
            let sections = self.presenter.currentList
            tableSnapshot.appendSections(sections)
            
            for section in sections {
                let items = section.items
                tableSnapshot.appendItems(items, toSection: section)
            }
            
            self.dataSource.apply(tableSnapshot, animatingDifferences: animated)
        }
    }
}

// MARK: - PRESENTER->VIEW INTERFACE

extension AssetSelectorViewController {
    
    //MARK: Subviews
    
    func addTableView() {
        
        // Search field text view.
        searchField.backgroundColor = .presentedItemBackground
        searchField.layer.cornerRadius = 8.5
        searchField.placeholder = "  " + NSLocalizedString("Search", comment: "")
        searchField.delegate = self
        searchField.autocorrectionType = .no
        view.addSubview(searchField)
        searchField.horizontalConstraint(19).topConstraint(50).heightConstraint(40)
        
        // Main table view.
        typeTableView.delegate = self
        typeTableView.dataSource = dataSource
        typeTableView.showsVerticalScrollIndicator = false
        typeTableView.separatorStyle = .singleLine
        typeTableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier)
        typeTableView.backgroundColor = .clear
        typeTableView.contentInset = UIEdgeInsets(top: 16)
        view.addSubview(typeTableView)
        typeTableView.horizontalConstraint().bottomConstraint().topConstraint(8.5, toBot: searchField)
    }
    
}

// MARK: - SEARCH

extension AssetSelectorViewController: UITextFieldDelegate {
    
    /// Resign keyboard on Done button.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    /// Delegate search filtering to the presenter.
    func textFieldDidChangeSelection(_ textField: UITextField) {
        presenter.performSearch(text: textField.text!)
    }
    
}

// MARK: - TABLE VIEW

extension AssetSelectorViewController: UITableViewDelegate {
    
    //MARK: Header
    
    /// Header height.
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    /// Header view.
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        let section = presenter.currentList[section]
        let label = UILabel()
        label.text = NSLocalizedString(section.name, comment: "")
        label.textColor = .text
        label.font = ConditionalProvider.selectorHeaderFont
        header.addSubview(label)
        label.heightConstraint(40).widthConstraint(200).bottomConstraint().leadingConstraint(15)
        return header
    }
    
    //MARK: Cell Provider
    
    /// Table view cell provider.
    func makeCell() -> UITableViewDiffableDataSource<FinanceAsset.SourceSection, String> {
        return UITableViewDiffableDataSource(tableView: typeTableView, cellProvider: { tableView, indexPath, assetInternalCode in
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: UITableViewCell.reuseIdentifier)
            cell.backgroundColor = .presentedItemBackground
            cell.textLabel?.text = assetName(fromInternalCode: assetInternalCode)
            cell.textLabel?.textColor = .text
            cell.textLabel?.font = ConditionalProvider.selectorTitle
            cell.detailTextLabel?.text = assetInternalCode
            cell.detailTextLabel?.textColor = .textDetail
            cell.detailTextLabel?.font = ConditionalProvider.selectorTitleSecondary
            cell.accessoryType = .disclosureIndicator
            cell.imageView?.image = assetIconResized(fromInternalCode: assetInternalCode)
            cell.imageView?.layer.cornerRadius = 3.5
            cell.imageView?.clipsToBounds = true
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
            cell.addGestureRecognizer(tapGesture)
            return cell
        })
    }

    /// Handles user tap on a cell.
    @objc private func handleTap(sender: UITapGestureRecognizer) {
        guard let cell = sender.view as? UITableViewCell, let text = cell.detailTextLabel?.text else { return }
        presenter.addAsset(internalCode: text)
    }
    
    /// Dismisses this view controller.
    @objc private func dissmis() {
        resignCurrentContextController()
    }
}
