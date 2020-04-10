//
//  ModuleViewController.swift
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
    private let typeTableView = UITableView(frame: .zero, style: .insetGrouped)
    private let searchField = UITextField()
    
    //MARK: ViewDidLoad
    
    override func superDidLoad() {
        setInvisibleNavbar()
        view.backgroundColor = .presentedBackground
        preferredContentSize = standartPresentationSize
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dissmisController))
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
        searchField.backgroundColor = .presentedItemBackground
        searchField.layer.cornerRadius = 8.5
        searchField.placeholder = "  " + NSLocalizedString("Search", comment: "")
        searchField.delegate = self
        searchField.autocorrectionType = .no
        view.addSubview(searchField)
        searchField.horizontalConstraint(19).topConstraint(50).heightConstraint(40)
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        presenter.performSearch(text: textField.text!)
    }
    
}

// MARK: - TABLE VIEW

extension AssetSelectorViewController: UITableViewDelegate {
    
    //MARK: Header
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        let section = presenter.currentList[section]
        let headerLabel = UILabel()
        headerLabel.text = NSLocalizedString(section.name, comment: "")
        headerLabel.textColor = .text
        headerLabel.font = ConditionalProvider.selectorHeaderFont
        header.addSubview(headerLabel)
        headerLabel.heightConstraint(40).widthConstraint(200).bottomConstraint().leadingConstraint(15)
        return header
    }
    
    //MARK: Cell Provider
    
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
            
            let cellTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
            cell.addGestureRecognizer(cellTapGesture)
            return cell
        })
    }

    @objc private func handleTap(sender: UITapGestureRecognizer) {
        guard let cell = sender.view as? UITableViewCell else { return }
        let splitedCode = cell.detailTextLabel!.text!.split(separator: ":", maxSplits: 1)
        let source = String(splitedCode[0])
        let type = assetType(fromSource: source)
        let internalCode = String(splitedCode[1])
        presenter.addAsset(type: type, source: source, code: internalCode)
    }
    
    @objc private func dissmisController() {
        resignCurrentContextController()
    }
}
