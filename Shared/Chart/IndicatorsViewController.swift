//
//  IndicatorsViewController.swift
//  RatesView
//
//  Created by Esie on 2/20/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import UIKit
import RWExtensions

class IndicatorsViewController: UIViewController, UITableViewDelegate {

    private typealias DataSource = UITableViewDiffableDataSource<String, String>
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let sections = ["Presented", "Hidden"]
    private lazy var dataSource = createCell()
    
    private var indicators = [String]()
    private var presentedIndicators = [String]()
    private var hiddenIndicators = [String]()
    
    weak var presenter: ChartPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        navigationController?.navigationBar.prefersLargeTitles = false
        title = "Indicators"
        view.addSubview(tableView)
        addTableview()
        updateData()
    }
    
    private func addTableview() {
        tableView.frameConstraint()
        tableView.delegate = self
        tableView.backgroundColor = .background
        tableView.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
        tableView.dataSource = dataSource
        tableView.separatorInset = .zero
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier)
    }
    
    private func updateData() {
        DispatchQueue.global(qos: .userInteractive).async {
            self.indicators = self.presenter.indicatorNames()
            self.presentedIndicators = []
            self.hiddenIndicators = []
            var snapshot = NSDiffableDataSourceSnapshot<String, String>()
            snapshot.appendSections(self.sections)
            
            for (index, indicator) in self.indicators.enumerated() {
                if self.presenter.indicatorsMask[index] {
                    self.presentedIndicators.append(indicator)
                    snapshot.appendItems([indicator], toSection: self.sections[0])
                } else {
                    self.hiddenIndicators.append(indicator)
                    snapshot.appendItems([indicator], toSection: self.sections[1])
                }
            }
            
            self.dataSource.apply(snapshot, animatingDifferences: true) {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension IndicatorsViewController {
    
    private func createCell() -> DataSource {
        return DataSource(tableView: tableView) { (tableView, indexPath, string) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier)!
            let isPresented = indexPath.section == 0
            let selectedIndicator = isPresented ? self.presentedIndicators[indexPath.row] : self.hiddenIndicators[indexPath.row]
            cell.imageView?.image = isPresented ? .remove : .add
            cell.textLabel?.text = selectedIndicator
            cell.textLabel?.font = ConditionalProvider.selectorTitle
            cell.textLabel?.textColor = .text
            cell.backgroundColor = .presentedItemBackground
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let headerLabel = UILabel()
        headerLabel.textColor = .text
        headerLabel.text = section == 0 ? presentedIndicators.count == 0 ? "" : sections[section] : sections[section]
        headerLabel.font = ConditionalProvider.selectorHeaderFont
        headerView.addSubview(headerLabel)
        headerLabel.heightConstraint(40).widthConstraint(200).bottomConstraint().leadingConstraint(25)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        let isPresented = indexPath.section == 0
        let selectedIndicator = isPresented ? presentedIndicators[indexPath.row] : hiddenIndicators[indexPath.row]
        let index = indicators.firstIndex(of: selectedIndicator)!
        presenter.indicatorsMask[index] = !presenter.indicatorsMask[index]
        updateData()
        presenter.viewController.openWebChart()
    }
  
}
