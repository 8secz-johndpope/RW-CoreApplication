//
//  PortfolioAssetTableViewCell.swift
//  RatesView
//
//  Created by Esie on 2/22/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import UIKit

class PortfolioAssetTableViewCell: UITableViewCell {

    var amountTextField: UITextField!
    
    weak var item: PortfolioItem!
    weak var asset: CDWatchlistAssetAdapter!
    
    func updateData() {
        let icon = UIImage(named: "portfolio")!.withTintColor(.tertiaryLabel)
        let assetItems = asset.inPortfolioItems!.allObjects as! [PortfolioItem]
        let isAlreadyInPortfolioItem = assetItems.contains(item)
        
        textLabel?.text = asset.currencyToUSD
        detailTextLabel?.text = asset.name
        imageView?.image = icon.withTintColor(isAlreadyInPortfolioItem ? .label : .tertiaryLabel)
        
        if amountTextField == nil {
            amountTextField = UITextField()
            amountTextField.delegate = self
            amountTextField.addDoneButtonOnKeyboard()
            amountTextField.backgroundColor = .clear
            amountTextField.placeholder = "Enter Amount"
            amountTextField.font = .systemFont(ofSize: 12, weight: .regular)
            amountTextField.keyboardType = .decimalPad
            amountTextField.textAlignment = .right
            addSubview(amountTextField)
            amountTextField.frame = frame
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
    }

}

//MARK: - UITextField Delegate (Enter Amount)

extension PortfolioAssetTableViewCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text ?? ""
        
        if text.isEmpty && string == "0" {
            return false
        }
        
        if !(text.contains(".") || text.contains(",")) {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            return true
        } else {
            if string == "." || string == "," {
                return false
            } else {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                return true
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let text = (textField.text ?? "0.0").replacingOccurrences(of: ",", with: ".")
        let amount = Double(text)
        
        
    }
    
}

extension UITextField {
    
    func addDoneButtonOnKeyboard() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(resignFirstResponder))
        keyboardToolbar.items = [flexibleSpace, doneButton]
        inputAccessoryView = keyboardToolbar
    }
}
