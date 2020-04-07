//
//  PortfolioAssetsViewController.swift
//  RatesView
//
//  Created by Esie on 2/21/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import UIKit

class PortfolioAssetsViewController: UIViewController, UITableViewDelegate {

    private typealias DataSource = UITableViewDiffableDataSource<CDWatchlistSectionAdapter, CDWatchlistAssetAdapter>
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private lazy var tableDataSource = createCell()
    private var sections = [CDWatchlistSectionAdapter]()
    
    weak var item: PortfolioItem!
    weak var presenter: Watchlist.Presenter!
    
    //MARK: Initial Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global(qos: .userInteractive).async {
            let sections = self.presenter.sections.filter { !$0.isPortfolioSection }
            self.sections = sections
        }
        
        view.addSubview(tableView)
        tableView.frameConstraint()
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
        tableView.dataSource = tableDataSource
        tableView.separatorInset = .zero
        tableView.register(PortfolioAssetTableViewCell.self, forCellReuseIdentifier: PortfolioAssetTableViewCell.reuseIdentifier)
        updateData()
    }
    
    //MARK: Update Data
    
    func updateData() {
        DispatchQueue.global(qos: .userInteractive).async { [sections = self.sections] in
            var snapshot = NSDiffableDataSourceSnapshot<CDWatchlistSectionAdapter, CDWatchlistAssetAdapter>()
            snapshot.appendSections(sections)
            
            sections.forEach { (watchlistSection) in
                let assets = watchlistSection.assets!.allObjects as! [CDWatchlistAssetAdapter]
                snapshot.appendItems(assets.sorted { $0.positionInWatchlist > $1.positionInWatchlist },
                                     toSection: watchlistSection)
            }
            
            self.tableDataSource.apply(snapshot, animatingDifferences: true) {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    //MARK: Update Data From Collection Cell Provider
    
    private func createCell() -> DataSource {
        return DataSource(tableView: tableView) { (tableView, indexPath, asset) -> UITableViewCell? in
            let cell = PortfolioAssetTableViewCell(style: .subtitle, reuseIdentifier: PortfolioAssetTableViewCell.reuseIdentifier)
            cell.item = self.item
            cell.asset = asset
            cell.updateData()
            return cell
        }
    }
}

//MARK: - TableView Header

extension PortfolioAssetsViewController {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let headerLabel = UILabel()
        headerLabel.textColor = .label
        headerLabel.text = sections[section].title
        headerLabel.font = .systemFont(ofSize: 14.5, weight: .bold)
        headerView.addSubview(headerLabel)
        headerLabel.heightConstraint(30).widthConstraint(200).bottomConstraint().leadingConstraint(25)
        return headerView
    }
  
}
