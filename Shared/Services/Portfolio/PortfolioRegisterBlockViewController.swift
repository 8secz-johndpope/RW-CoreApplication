//
//  PortfolioRegisterBlockViewController.swift
//  SmartConverter
//
//  Created by Esie on 4/13/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import UIKit
import RWUserInterface
import RWExtensions

final class PortfolioRegisterBlockViewController: UIViewController {

    let signSegmentedControl = UISegmentedControl(items: ["-", "+"])
    let amountNumberField = RWDecimalField()
    let assetSelector = UIButton()
    let priceNumberField = RWDecimalField()
    let tagSelector = UIButton()
    
    @serializable(key: "signIndex", defaultValue: 1)
    var signIndex: Int
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .presentedBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Add Operation"
        addMainView()
    }
    
    private func addMainView() {
        
        // Amount sign segmented view.
        signSegmentedControl.selectedSegmentIndex = signIndex
        signSegmentedControl.addTarget(self, action: #selector(amountSignChanged), for: .valueChanged)
        view.addSubview(signSegmentedControl)
        signSegmentedControl.sizeConstraints(width: 90, height: 30)
            .topConstraint(110).leadingConstraint(.standartPageInset)
        
        // Amount decimal view.
        amountNumberField.placeholder = "  Amount"
        amountNumberField.textColor = .text
        amountNumberField.font = ConditionalProvider.selectorTitle
        amountNumberField.layer.cornerRadius = 5.5
        amountNumberField.layer.masksToBounds = true
        amountNumberField.backgroundColor = .presentedItemBackground
        view.addSubview(amountNumberField)
        amountNumberField.becomeFirstResponder()
        amountNumberField.leadingConstraint(.standartDoubleInset, toTrail: signSegmentedControl).trailingConstraint(-.standartPageInset).verticalConstraint(to: signSegmentedControl)
        
        // Asset.
        assetSelector.setTitle("Asset", for: .normal)
        assetSelector.layer.cornerRadius = 5.5
        assetSelector.layer.masksToBounds = true
        assetSelector.backgroundColor = .presentedItemBackground
        view.addSubview(assetSelector)
        assetSelector.heightConstraint(30).horizontalConstraint(CGFloat.standartPageInset).topConstraint(toBot: amountNumberField)
        
        
    }

}

extension PortfolioRegisterBlockViewController {
    
    @objc private func amountSignChanged() {
        signIndex = signSegmentedControl.selectedSegmentIndex
    }
    
}

