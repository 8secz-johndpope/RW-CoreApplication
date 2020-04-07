import Foundation

#warning("Transition will be removed in version 3.2")
extension Asset {
    
    var fullCode: String? {
        if source == nil || code == nil {
            return nil
        } else {
            switch type {
                case .stock : return "\(source!):\(code!)"
                case .crypto : return "\(source!):\(code!)USD"
                case .custom, .currency : return inOwn ? "\(source!):\(code!)USD" : "\(source!):USD\(code!)"
                case .undefined : return nil
            }
        }
    }
    
    var type: AssetType {
        if let source = self.source {
            if CurrenciesModel.stockExchanges.contains(source) {
                return .stock
            } else if CurrenciesModel.currenciesExchanges.contains(source) {
                return .currency
            } else if CurrenciesModel.cryptoExchanges.contains(source) {
                return .crypto
            } else {
                return .custom
            }
        } else {
            return .undefined
        }
    }
    
    enum AssetType {
        case stock
        case currency
        case crypto
        case custom
        case undefined
    }
    
}
