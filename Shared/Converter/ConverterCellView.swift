//
//  ConverterCellView.swift
//  RatesView
//
//  Created by Denis Esie on 1/4/19.
//  Copyright © 2019 Denis Esie. All rights reserved.
//

import UIKit
import RWUserInterface
import RWExtensions

final class ConverterCellView: RWInteractiveCollectionViewCell {
    
    private var shadowView = UIView()
    private var flagImageView = UIImageView()
    private var codeLabel = UILabel()
    private var nameLabel = UILabel()
    private var addButton = UIButton(type: .roundedRect)
    private var amountField = RWDecimalField()
    private var displayLink: CADisplayLink?
    
    private var places = 2
    var isInHiddenSection = false
    var index = 0
    var isCellSelected = false
    private var cachedOldPrice = 0.0
    private var transitOldValue = 0.0
    var transitNewValue = 0.0
    var animationStartDate: Date?
    
    weak var presenter: ConverterPresenter!
    
    //MARK: Constructor
    
    override func constructView() {
        interactiveView.backgroundColor = .presentedItemBackground
        interactiveView.layer.cornerRadius = .standartCornerRadius
        interactiveView.clipsToBounds = true
        
        shadowView.backgroundColor = .itemBackground
        shadowView.isOpaque = true
        shadowView.layer.masksToBounds = true
        shadowView.layer.cornerRadius = 8.5
        shadowView.layer.shouldRasterize = true
        mainView.addSubview(shadowView)
        shadowView.verticalConstraint(3.5).horizontalConstraint(2.5)
        
        flagImageView.layer.cornerRadius = 4.5
        flagImageView.clipsToBounds = true
        mainView.addSubview(flagImageView)
        flagImageView.topConstraint(10.5).leadingConstraint(10.5).widthConstraint(50).heightConstraint(30)
        
        codeLabel.textColor = .text
        codeLabel.font = UIFont(name: "Futura-Bold", size: 18)
        codeLabel.textAlignment = .left
        mainView.addSubview(codeLabel)
        codeLabel.topConstraint(to: flagImageView).bottomConstraint(to: flagImageView).leadingConstraint(8.5, toTrail: flagImageView).widthConstraint(50)
        
        nameLabel.textColor = .textDetail
        nameLabel.font = UIFont(name: "Futura-Bold", size: 14)
        nameLabel.textAlignment = .left
        mainView.addSubview(nameLabel)
        nameLabel.topConstraint(toBot: flagImageView).bottomConstraint().leadingConstraint(to: flagImageView).trailingConstraint(-100)
        
        addButton.setImage(.add, for: .normal)
        mainView.addSubview(addButton)
        addButton.verticalConstraint().trailingConstraint(-12).leadingConstraint(toTrail: codeLabel)
        addButton.addTarget(self, action: #selector(addLabelTapped), for: .touchDown)
        
        amountField.textAlignment = .right
        amountField.font = UIFont(name: "Futura-Bold", size: 28)
        amountField.textColor = .text
        amountField.keyboardAppearance = .dark
        amountField.actionDelegate = self
        mainView.addSubview(amountField)
        amountField.verticalConstraint().trailingConstraint(-10.5).leadingConstraint(toTrail: codeLabel)
        
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowRadius = 3.5
        shadowView.layer.shadowOpacity = 0.1
        shadowView.layer.shadowOffset = CGSize.zero
    }
    
    //MARK: Update Data
    
    override func updateView(animated: Bool) {
        let asset = representedObject as! CDWatchlistAssetAdapter
        flagImageView.image = asset.icon
        flagImageView.contentMode = asset.isCurrency ? .scaleAspectFill : .scaleAspectFit
        codeLabel.text = asset.currencyToUSD
        nameLabel.text = asset.name?.uppercased()
        
        if isInHiddenSection {
            amountField.isHidden = true
            addButton.isHidden = false
            return
        } else {
            amountField.isHidden = false
            addButton.isHidden = true
        }
        
        // Select or deselect cell when scrolling collection view.
        if asset.internalFullCode == presenter.selectedAsset?.internalFullCode {
            setSelected()
        } else {
            setDeselected()
        }
        
        // Set value when scrolling collection view.
        if let currentAmount = presenter.convertedAmounts[asset.internalFullCode!] {
            setValue(currentAmount)
        } else {
            setValue(0)
        }
    }
}

extension ConverterCellView {
    
    /// Set new value amount.
    func setNewValue(_ value: Double) {
        transitNewValue = value
        let asset = representedObject as! CDWatchlistAssetAdapter
        places = asset.pricePlaces
        setNewPriceAnimated(value)
    }
    
    /// Set cell to selected state.
    private func setSelected() {
        amountField.isActive = true
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        isCellSelected = true
        let tintColor = flagImageView.image?.averageColor?.withAlphaComponent(0.5)
        UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 0.45, initialSpringVelocity: 0,
                       options: [.curveEaseOut, .allowUserInteraction], animations: {
                        self.transform = CGAffineTransform.init(scaleX: 1.03, y: 1.03)
                        self.shadowView.backgroundColor = tintColor
        })
    }
    
    /// Set cell to deselected state.
    func setDeselected() {
        amountField.isActive = false
        if isCellSelected {
            isCellSelected = false
            UIView.animate(withDuration: 0.25) {
                self.transform = CGAffineTransform.identity
                self.shadowView.backgroundColor = .itemBackground
            }
        }
    }
}

extension ConverterCellView {
    
    /// Animate amount change per frame using displaylink.
    private func setNewPriceAnimated(_ newValue: Double) {
        let asset = representedObject as! CDWatchlistAssetAdapter
        animationStartDate = Date()
        transitNewValue = newValue
        places = asset.converterPricePlaces
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
        let elapsedTime = Date().timeIntervalSince(animationStartDate!)
        let transitionDuration = 0.5
        if elapsedTime > transitionDuration {
            displayLink?.invalidate()
            displayLink = nil
        } else {
            let value = transitOldValue + (elapsedTime / transitionDuration * (transitNewValue - transitOldValue))
            setValue(value)
        }
    }
    
    private func setValue(_ value: Double) {
        transitOldValue = value.rounded(places: places)
        amountField.text = transitOldValue == 0 ? "0" : String(transitOldValue)
    }
    
    @objc private func addLabelTapped() {
        if let asset = representedObject as? CDWatchlistAssetAdapter {
            presenter.unhideAsset(asset)
        }
    }
}

extension ConverterCellView: RWNumberFieldDelegate {
    
    func didPresentedKeyboard(numberField: RWDecimalField, height: CGFloat) {
        let inset = UIEdgeInsets(bottom: height)
        presenter.viewController.collectionView.contentInset = inset
    }
    
    func didBeginEditing(numberField: RWDecimalField) {
        presenter.deselectAllCells()
        setSelected()
        presenter.selectedCurrencyIndex = index
        presenter.selectedAsset = representedObject as? CDWatchlistAssetAdapter
        presenter.selectedCell = self
    }
    
    func didEndEditing(numberField: RWDecimalField) {
        presenter.viewController.collectionView.contentInset = .zero
    }
    
    func didUpdateValue(numberField: RWDecimalField, value: Double) {
        transitNewValue = value
        presenter.updateValue(value)
    }

}


