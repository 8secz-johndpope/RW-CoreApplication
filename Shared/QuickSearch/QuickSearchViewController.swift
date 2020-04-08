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

final class QuickSearchViewController: RWViewController {
    
    var presenter: QuickSearchPresenter!
    
    private lazy var dataSource = makeCell()
    private let typeTableView = UITableView(frame: .zero, style: .insetGrouped)
    private let searchField = UITextField()
    
    override func superDidLoad() {
        setInvisibleNavbar()
        view.backgroundColor = .presentedBackground
    }
    
    //MARK: UI Input
    
    enum InputType: Int {
        case open = 0
    }
    
    //MARK: UI Update
    
    override func dataSourceDidChanged(animated: Bool = true) {
        DispatchQueue.global(qos: .userInteractive).async {
            var tableSnapshot = NSDiffableDataSourceSnapshot<String, String>()
            let assets = self.presenter.assets
            tableSnapshot.appendSections(["Section"])
            tableSnapshot.appendItems(assets, toSection: "Section")
            self.dataSource.apply(tableSnapshot, animatingDifferences: animated)
        }
    }
}

//MARK: - PRESENTER->VIEW INTERFACE

extension QuickSearchViewController {
    
    //MARK: Subviews
    
    func addTableView() {
        let searchView = UIView()
        searchView.layer.cornerRadius = 6.5
        searchView.backgroundColor = .presentedItemBackground
        view.addSubview(searchView)
        searchView.horizontalConstraint(CGFloat.standartDoublePageInset-10).topConstraint(15).heightConstraint(35)
        searchField.textColor = .text
        searchField.delegate = self
        searchField.autocorrectionType = .no
        searchField.keyboardAppearance = .dark
        searchField.textAlignment = .left
        searchField.becomeFirstResponder()
        view.addSubview(searchField)
        searchField.horizontalConstraint(CGFloat.standartDoublePageInset).topConstraint(15).heightConstraint(35)
        
        typeTableView.delegate = self
        typeTableView.dataSource = dataSource
        typeTableView.showsVerticalScrollIndicator = false
        typeTableView.separatorStyle = .singleLine
        typeTableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier)
        typeTableView.backgroundColor = .clear
        view.addSubview(typeTableView)
        typeTableView.horizontalConstraint().bottomConstraint().topConstraint(8.5, toBot: searchField)
    }
    
}

// MARK: - SEARCH

extension QuickSearchViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        presenter.performSearch(text: textField.text)
    }
    
}

// MARK: - TABLE VIEW

extension QuickSearchViewController: UITableViewDelegate {
    
    //MARK: Cell Provider
    
    func makeCell() -> UITableViewDiffableDataSource<String, String> {
        return UITableViewDiffableDataSource(tableView: typeTableView, cellProvider: { tableView, indexPath, assetInternalCode in
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: UITableViewCell.reuseIdentifier)
            cell.backgroundColor = .clear
            cell.textLabel?.text = assetName(fromInternalCode: assetInternalCode)
            cell.textLabel?.textColor = .text
            cell.detailTextLabel?.text = assetInternalCode
            cell.detailTextLabel?.textColor = .textDetail
            cell.accessoryType = .disclosureIndicator
            return cell
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let code = presenter.assets[indexPath.row]
        let name = assetName(fromInternalCode: code)
        resignCurrentContextController()
        AnalyticsEvent.register(source: .quicksearch, key: RWAnalyticsEventAssetOpened, context: code.toFullcode())
        broadcastInput(InputType.open.rawValue, context: [code.toFullcode(), name])
    }
}


