//
//  PortfolioCell.swift
//  CryptoView
//
//  Created by Esie on 4/9/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//
import UIKit
import RWExtensions
import RWUserInterface

final class PortfolioCellView: RWInteractiveCollectionViewCell {

    public static let reuseIdentifier = "PortfolioCellView"
    
    private var displayLink: CADisplayLink?
    private var animationStartDate: Date?

    private let tableView = UITableView()
    private let addButton = UIButton(type: .roundedRect)
    private let optionsButton = UIButton(type: .roundedRect)
    private let mainAssetView = UIView()
    private let iconImageView = UIImageView()
    private let priceOverview = UILabel()
    let nameTextField = UITextField()
    private let changeLabel = UILabel()
    
    private var cachedOldPrice = 0.0
    private var transitOldValue = 0.0
    private var transitNewValue = 0.0
    private var places = 2

    weak var viewController: RatesViewController!
    
    //MARK: Constructor
    
    override func constructView() {
        interactiveView.backgroundColor = .itemInteractive
        interactiveView.layer.cornerRadius = .standartCornerRadius
        interactiveView.clipsToBounds = true
        
        // Main View.
        mainAssetView.backgroundColor = .itemBackground
        mainAssetView.layer.cornerRadius = .standartCornerRadius
        mainAssetView.clipsToBounds = true
        mainView.addSubview(mainAssetView)
        mainAssetView.frameConstraint(CGFloat.standartInset)
        
        // Section Icon
        iconImageView.setPlaceholder(withRadius: 5.5)
        iconImageView.contentMode = .scaleAspectFill
        mainAssetView.addSubview(iconImageView)
        iconImageView.topLeftConstraint(7.5).sizeConstraints(width: 32, height: 32)
        
        // Section name.
        nameTextField.textColor = .text
        nameTextField.delegate = self
        nameTextField.font = UIFont(name: "Futura-Bold", size: 18)
        mainAssetView.addSubview(nameTextField)
        nameTextField.topConstraint(to: iconImageView).heightConstraint(32)
            .leadingConstraint(.standartDoubleInset, toTrail: iconImageView).trailingConstraint()
        
        // Price overview.
        priceOverview.text = "9120.82$"
        priceOverview.textColor = .white
        priceOverview.textAlignment = .left
        priceOverview.font = UIFont(name: "Futura-Bold", size: 32)
        mainAssetView.addSubview(priceOverview)
        priceOverview.horizontalConstraint(15).topConstraint(.standartDoubleInset+5, toBot: nameTextField).heightConstraint(30)
        
        // Options button.
        optionsButton.setImage(.actions, for: .normal)
        mainAssetView.addSubview(optionsButton)
        optionsButton.sizeConstraints(width: 32, height: 32).topRightConstraint(7.5)
        
        // Add button.
        addButton.setImage(.add, for: .normal)
        mainAssetView.addSubview(addButton)
        addButton.sizeConstraints(width: 32, height: 32).topConstraint(7.5).trailingConstraint(-.standartInset, toLead: optionsButton)
        addButton.addTarget(self, action: #selector(addTapped), for: .touchDown)
        
        //
        changeLabel.text = "+340.12$ (1.45%)"
        changeLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.5)
        changeLabel.textColor = .text
        changeLabel.textAlignment = .right
        changeLabel.layer.cornerRadius = 3.5
        changeLabel.layer.masksToBounds = true
        changeLabel.font = UIFont(name: "Futura-Bold", size: 13.5)
        mainAssetView.addSubview(changeLabel)
        changeLabel.verticalCenterConstraint(to: priceOverview).trailingConstraint(-7.5).widthConstraint(140)
        
        
        

    }

    //MARK: Update Data
    
    override func updateView(animated: Bool) {
        guard let section = representedObject as? CDPortfolioSectionAdapter else { return }
        
        if section.position == 0 {
            nameTextField.text = "Overview"
        } else {
            nameTextField.text = section.title
        }
        
        
    }
}

//MARK: - NAME TEXT FIELD DELEGATE

extension PortfolioCellView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        guard let section = representedObject as? CDPortfolioSectionAdapter else { return true }
        section.title = textField.text
        AppDelegate.saveContext()
        return true
    }
    
}



extension PortfolioCellView {
    
    @objc private func addTapped() {
        guard let section = representedObject as? CDPortfolioSectionAdapter else { return }
        
        if section.position == 0 {
            viewController.presenter.addPortfolioSection()
        } else {
            viewController.presenter.addPortfolioBlock()
        }
    }
    
    /*
    @objc private func showChart() {
        guard let asset = representedObject as? CDWatchlistAssetAdapter else { return }
        AnalyticsEvent.register(source: .watchlist, key: RWAnalyticsEventAssetOpened, context: asset.fullCode)
        viewController.presenter.router.routeTo(.toChart, context: [asset.fullCode, asset.name])
    }
    
    private func setNewPriceAnimated(_ newValue: Double) {
        guard let asset = representedObject as? CDWatchlistAssetAdapter else { return }
        animationStartDate = Date()
        transitNewValue = newValue
        places = asset.pricePlaces
        DispatchQueue.main.async {
            if self.displayLink != nil {
                self.displayLink?.invalidate()
                self.displayLink = nil
            }
            self.displayLink = CADisplayLink(target: self, selector: #selector(self.updateFrame))
            self.displayLink?.add(to: .main, forMode: .default)
        }
    }
    
    @objc private func updateFrame() {
        guard let asset = representedObject as? CDWatchlistAssetAdapter else { return }
        let elapsedTime = Date().timeIntervalSince(animationStartDate!)
        let transitionDuration = 0.5
        if elapsedTime > transitionDuration {
            displayLink?.invalidate()
            displayLink = nil
            transitOldValue = Double(truncating: asset.price ?? 0.0).rounded(places: places)
            cachedOldPrice = transitOldValue
        } else {
            let value = transitOldValue + (elapsedTime / transitionDuration * (transitNewValue - transitOldValue))
            transitOldValue = value
            priceOverview.text = String(transitOldValue.rounded(places: places))
        }
    } */
}


extension UIButton {
    
    func addCompletion() {
        
    }
    
    @objc func completionHandler() {
        
    }
    
}
