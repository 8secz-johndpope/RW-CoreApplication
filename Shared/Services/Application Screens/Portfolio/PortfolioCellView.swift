//
//  WatchlistPortfolioCellView.swift
//  RatesView
//
//  Created by Esie on 2/12/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import UIKit

class PortfolioCellView: UICollectionViewCell {
    
    static let reuseIdentifier = "portfolio-cell-reuse-identifier"
    
    private let shadowView = UIView()
    private let mainAssetView = UIView()

    private let chartImageView = UIImageView()
    private let iconImageView = UIImageView()

    private let actionButton = UIButton(type: .roundedRect)
    private let accountsTextView = UITextView()
    private let priceTextView = UITextView()
    private let titleLabel = UITextField()
    private let overviewLabel = UILabel()
    private let changeLabel = UILabel()
    
    var imgPicker: ImagePicker?
    
    weak var viewController: Watchlist.ViewController!
    weak var currentSection: CDWatchlistSectionAdapter!
    weak var asset: PortfolioItem!
    
    //MARK: Initial Cell Setup
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        shadowView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .clear : .white
        shadowView.layer.cornerRadius = 12.5
        shadowView.setStandartShadow()
        addSubview(shadowView)
        shadowView.frameConstraint(5.5)
        
        mainAssetView.backgroundColor = .itemBackground
        mainAssetView.layer.cornerRadius = 10.5
        mainAssetView.clipsToBounds = true
        addSubview(mainAssetView)
        mainAssetView.frameConstraint(5.5)
        
        mainAssetView.addSubview(chartImageView)
        chartImageView.horizontalConstraint().bottomConstraint().topConstraint(50)
        
        iconImageView.setPlaceholder()
        iconImageView.contentMode = .scaleAspectFit
        mainAssetView.addSubview(iconImageView)
        iconImageView.topLeftConstraint(7.5).sizeConstraints(width: 28, height: 28)
        
//        changeLabel.setPlaceholder()
//        changeLabel.textAlignment = .center
//        changeLabel.textColor = .white
//        changeLabel.layer.cornerRadius = 3.5
//        changeLabel.layer.masksToBounds = true
//        changeLabel.font = .systemFont(ofSize: .scaled(9), weight: .bold)
//        mainAssetView.addSubview(changeLabel)
//        changeLabel.trailingConstraint(-7.5).widthConstraint(43.5).topConstraint(7.5).bottomConstraint(-7.5)
        
        titleLabel.delegate = self
        titleLabel.textContentType = .organizationName
        titleLabel.autocorrectionType = .no
        titleLabel.textColor = .text
        titleLabel.font = .systemFont(ofSize: .scaled(16.5), weight: .bold)
        mainAssetView.addSubview(titleLabel)
        titleLabel.topConstraint(to: iconImageView).leadingConstraint(7.5, toTrail: iconImageView).trailingConstraint(-100).bottomConstraint(to: iconImageView)
        
        overviewLabel.setPlaceholder()
        mainAssetView.addSubview(overviewLabel)
        overviewLabel.topConstraint(7.5, toBot: iconImageView).leadingConstraint(to: iconImageView).sizeConstraints(width: width * 0.5, height: 30)
        
        accountsTextView.backgroundColor = .clear
        accountsTextView.textColor = .textDetail
        accountsTextView.font = .systemFont(ofSize: 10, weight: .bold)
        mainAssetView.addSubview(accountsTextView)
        accountsTextView.horizontalConstraint(10).bottomConstraint().topConstraint(height*0.42)

        actionButton.tintColor = .sideElement
        actionButton.addTarget(self, action:  #selector(tappedAction(sender:)), for: .touchDown)
        addSubview(actionButton)
        actionButton.topConstraint(8).trailingConstraint(-17).sizeConstraints(width: 26, height: 26)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Detect Dark Mode
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        shadowView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .clear : .white
        mainAssetView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemFill : .white
        //actionButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .darkGray : .lightGray
    }
    
    //MARK: Update Data From Collection Cell Provider
    
    func updateData(fromCollection: Bool = false) {
        titleLabel.resignFirstResponder()
        titleLabel.text = asset.title
        actionButton.setImage(UIImage(named: asset.isGeneral ? "Watchlist" : "More"), for: .normal)
        
        if let icon = asset.icon {
            iconImageView.image = UIImage(data: icon)
        } else {
            iconImageView.image = nil
        }
    }

}

//MARK: - Actions Button

extension PortfolioCellView {
    
    @objc private func tappedAction(sender: UIGestureRecognizer) {
        if asset.isGeneral {
            let actionVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            actionVC.addAction(UIAlertAction(title: "Add Item", style: .default, handler: addItem))
            actionVC.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            viewController.present(actionVC, animated: true)
        } else {
            let actionVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            actionVC.addAction(UIAlertAction(title: "Add Operation...", style: .default, handler: addOperation))
            actionVC.addAction(UIAlertAction(title: "Add Assets...", style: .default, handler: addAssets))
            actionVC.addAction(UIAlertAction(title: "Set Icon", style: .default, handler: setIcon))
            actionVC.addAction(UIAlertAction(title: "Delete \(asset.title ?? "")", style: .destructive, handler: deleteItem))
            actionVC.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            viewController.present(actionVC, animated: true)
        }
    }
    
    //MARK: General Item Actions
    
    @objc private func addItem(_ action: UIAlertAction) {
        viewController.presenter.addPortfolioItem()
    }
       
    //MARK: User Items Actions
    
    @objc private func addAssets(_ action: UIAlertAction) {
        let prtfvc = PortfolioAssetsViewController()
        prtfvc.title = "Assets For " + asset.title!
        prtfvc.presenter = viewController.presenter
        prtfvc.item = asset
        viewController.navigationController?.pushViewController(prtfvc, animated: true)
    }
    
    @objc private func addOperation(_ action: UIAlertAction) {
        
    }
    
    @objc private func setIcon(_ action: UIAlertAction) {
        imgPicker = ImagePicker(presentationController: self.viewController, delegate: self)
        imgPicker?.present(from: self)
    }
    
    @objc private func deleteItem(_ action: UIAlertAction) {
        
    }
    
}

//MARK: - ImagePicker Delegate (Set Icon)

extension PortfolioCellView: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        guard let selectedImage = image else { return }
        let image = selectedImage.resizeTo(size: CGSize(width: 128, height: 128))
        iconImageView.image = image
        asset.icon = image?.pngData()
    }
}

//MARK: - UITextField Delegate (Set Name)

extension PortfolioCellView: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let newTitle = textField.text
        asset.title = newTitle
        AppDelegate.saveContext()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
}
