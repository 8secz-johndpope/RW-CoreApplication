import Foundation
import UIKit

let YES: String = "YES"
let NO: String = "NO"

protocol WDMasterEntityDelegate {
    
    func didFinishLoadingRates(asset: WDMasterEntity)
    
}

class WDMasterEntity: NSObject, NSCoding {
        
    var delegates = [WDMasterEntityDelegate]()
    
    init(rawCode: String, source: String, inOwn: Bool?) {
        self.rawCode = rawCode
        self.source = source
        if inOwn != nil { self.isOwn = inOwn! ? YES : NO }
        
        if AppModel.stockExchanges.contains(source) {
            
        } else if AppModel.currenciesExchanges.contains(source) {
            self.name = AppModel.allCurrenciesDictionary[rawCode]
        } else if AppModel.cryptoExchanges.contains(source) {
            self.name = AppModel.allCryptocurenciesDictionary[rawCode]
        }

    }
    
    override init() {
        
    }
    
    var code: String {
        if isOwn == YES {
            return "\(source!):USD\(rawCode!)"
        } else if isOwn == NO {
            return "\(source!):\(rawCode!)USD"
        } else {
            return "\(source!):\(rawCode!)"
        }
    }
    
    var codeNoSource: String {
        if isOwn == YES {
            return "USD\(rawCode!)"
        } else if isOwn == NO {
            return "\(rawCode!)USD"
        } else {
            return rawCode!
        }
    }
    
    var type: WDReader.type {
        if let src = source {
            
            if AppModel.stockExchanges.contains(src) {
                return .stock
            } else if AppModel.currenciesExchanges.contains(src) {
                return .currency
            } else if AppModel.cryptoExchanges.contains(src) {
                return .crypto
            } else {
                return .other
            }
            
        } else {
            return .undefined
        }
    }
    
    var rawCode: String?
    var source: String?
    var isOwn: String?
    
    var name: String?
    
    var price: Double?
    var change: Double?
    var changeInPercent: Double?
    var open: Double?
    var prev: Double?
    var high: Double?
    var low: Double?
   
    var marketCap: Double?
    var icon: UIImage?
    var chart: UIImage?
    
    var isMarketOpen = false
    var isShownInConverter = YES
    
    var positionInConverterSection: Int?
    var positionInConverterRow: Int?
    
    var sector: String?
    var industry: String?
    var employees: String?
    var profile: String?
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(rawCode, forKey: "rawCode")
        aCoder.encode(source, forKey: "source")
        aCoder.encode(isOwn, forKey: "isOwn")
        
        aCoder.encode(name, forKey: "name")
        
        aCoder.encode(price, forKey: "price")
        aCoder.encode(change, forKey: "change")
        aCoder.encode(changeInPercent, forKey: "changeInPercent")
        aCoder.encode(marketCap, forKey: "marketCap")
        aCoder.encode(icon, forKey: "icon")
        aCoder.encode(chart, forKey: "chart")
        aCoder.encode(isMarketOpen, forKey: "isMarketOpen")
        aCoder.encode(isShownInConverter, forKey: "isShownInConverter")
        aCoder.encode(positionInConverterRow, forKey: "positionInConverter")
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        self.init()
        load(aDecoder: aDecoder)
    }
    
    func load(aDecoder: NSCoder) {
        
        if aDecoder.decodeObject(forKey: "rawCode") != nil {
            rawCode = aDecoder.decodeObject(forKey: "rawCode") as? String
        }
        
        if aDecoder.decodeObject(forKey: "source") != nil {
            source = aDecoder.decodeObject(forKey: "source") as? String
        }
        
        if aDecoder.decodeObject(forKey: "isOwn") != nil {
            isOwn = aDecoder.decodeObject(forKey: "isOwn") as? String
        }
        
        if aDecoder.decodeObject(forKey: "name") != nil {
            name = aDecoder.decodeObject(forKey: "name") as? String
        }
        
        if aDecoder.decodeObject(forKey: "price") != nil {
            price = aDecoder.decodeObject(forKey: "price") as? Double
        }
        
        if aDecoder.decodeObject(forKey: "change") != nil {
            change = aDecoder.decodeObject(forKey: "change") as? Double
        }
        
        if aDecoder.decodeObject(forKey: "changeInPercent") != nil {
            changeInPercent = aDecoder.decodeObject(forKey: "changeInPercent") as? Double
        }
        
        if aDecoder.decodeObject(forKey: "marketCap") != nil {
            marketCap = aDecoder.decodeObject(forKey: "marketCap") as? Double
        }
        
        if aDecoder.decodeObject(forKey: "icon") != nil {
            icon = aDecoder.decodeObject(forKey: "icon") as? UIImage
        }
        
        if aDecoder.decodeObject(forKey: "chart") != nil {
            chart = aDecoder.decodeObject(forKey: "chart") as? UIImage
        }
        
        if aDecoder.decodeObject(forKey: "isMarketOpen") != nil {
            isMarketOpen = aDecoder.decodeBool(forKey: "isMarketOpen")
        }
        
        if aDecoder.decodeObject(forKey: "isShownInConverter") != nil {
            isShownInConverter = aDecoder.decodeObject(forKey: "isShownInConverter") as? String ?? YES
        } else {
            isShownInConverter = NO
        }
        
        if aDecoder.decodeObject(forKey: "positionInConverter") != nil {
            positionInConverterRow = aDecoder.decodeInteger(forKey: "positionInConverter")
        }
        
    }
    
}
