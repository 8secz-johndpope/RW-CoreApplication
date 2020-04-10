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
    private lazy var tableView = UITableView(frame: .zero, style: .insetGrouped)
    private lazy var searchField = UITextField()
    
    override func superDidLoad() {
        setInvisibleNavbar()
        view.backgroundColor = .presentedBackground
    }
    
    //MARK: UI Input
    
    enum InputType: Int {
        case open = 0
    }
    
    //MARK: UI Update
    
    override func updateDataSource(animated: Bool = true) {
        DispatchQueue.global(qos: .userInteractive).async {
            let section = 0
            var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
            let assets = self.presenter.assets
            snapshot.appendSections([section])
            snapshot.appendItems(assets, toSection: section)
            self.dataSource.apply(snapshot, animatingDifferences: animated)
        }
    }
}

//MARK: - PRESENTER->VIEW INTERFACE

extension QuickSearchViewController {
    
    //MARK: Subviews
    
    func addTableView() {
        let inset = CGFloat.standartDoublePageInset
        
        // Search view for the background of the search text field.
        let searchView = UIView()
        searchView.layer.cornerRadius = 6.5
        searchView.backgroundColor = .presentedItemBackground
        view.addSubview(searchView)
        searchView.horizontalConstraint(inset-10).topConstraint(15).heightConstraint(35)
        
        // Search field text view.
        searchField.textColor = .text
        searchField.delegate = self
        searchField.autocorrectionType = .no
        searchField.keyboardAppearance = .dark
        searchField.textAlignment = .left
        searchField.becomeFirstResponder()
        view.addSubview(searchField)
        searchField.horizontalConstraint(inset).topConstraint(15).heightConstraint(35)
        
        // Main table view.
        tableView.delegate = self
        tableView.dataSource = dataSource
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .singleLine
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier)
        tableView.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.horizontalConstraint().bottomConstraint().topConstraint(8.5, toBot: searchField)
    }
    
}

// MARK: - SEARCH FIELD DELEGATE

extension QuickSearchViewController: UITextFieldDelegate {
    
    /// Resign keyboard on Done button.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    /// Delegate search filtering to the presenter.
    func textFieldDidChangeSelection(_ textField: UITextField) {
        presenter.performSearch(text: textField.text)
    }
    
}

// MARK: - TABLE VIEW

extension QuickSearchViewController: UITableViewDelegate {
    
    /// Table view cell provider.
    func makeCell() -> UITableViewDiffableDataSource<Int, String> {
        return UITableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, assetInternalCode in
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
    
    /// React to cell selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let code = presenter.assets[indexPath.row]
        broadcastInput(InputType.open.rawValue, context: code)
    }
}
