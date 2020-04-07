import Foundation

class GlobalEntity {
    
    var dataContainer = [Int : [WDMasterEntity]]()
    var converterItems = [Int : [WDMasterEntity]]()
    
    static var current = GlobalEntity()
    
    init() {
        loadEverything()
    }
    
    var isInitial: Bool {
        return UserDefaults.standard.bool(forKey: UserDefaults.legacyKeys.globalEntityFirstLanch)
    }
    
    func loadEverything() {
        if isInitial {
            if  let decoded = UserDefaults.standard.object(forKey: UserDefaults.legacyKeys.globalEntityData) as? Data {
                dataContainer = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [Int : [WDMasterEntity]]
            } 
        } 
    }
    
    func saveEverything() {
        DispatchQueue.global(qos: .utility).async {
            let defaults = UserDefaults.standard
            let data = NSKeyedArchiver.archivedData(withRootObject:  GlobalEntity.current.dataContainer)
            defaults.set(data, forKey: UserDefaults.legacyKeys.globalEntityData)
            defaults.set(true, forKey: UserDefaults.legacyKeys.globalEntityFirstLanch)
        }
    }
    
    func calculateConverterItems() {
        var currentWatchlistNonhiddenItems = [WDMasterEntity]()
        var currentWatchlistHiddenItems = [WDMasterEntity]()
        let baseUSD = WDMasterEntity()
        baseUSD.price = 1.0
        baseUSD.rawCode = "USD"
        baseUSD.name = "US dollar"
        
        currentWatchlistNonhiddenItems.append(baseUSD)
        for asset in dataContainer[1]! {
            if asset.isShownInConverter == YES {
                currentWatchlistNonhiddenItems.append(asset)
            } else {
                currentWatchlistHiddenItems.append(asset)
            }
        }
        
        for asset in dataContainer[2]! {
            if asset.isShownInConverter == YES {
                currentWatchlistNonhiddenItems.append(asset)
            } else {
                currentWatchlistHiddenItems.append(asset)
            }
        }
        converterItems[0] = currentWatchlistNonhiddenItems
        converterItems[1] = currentWatchlistHiddenItems
    }
}
