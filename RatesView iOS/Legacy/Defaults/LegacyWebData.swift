import Foundation

class WebDataCoreObject {
    
    var asset: WDMasterEntity!
    var locale = "en"
    var colorTheme = "light"
    
}

class WDProfile: WebDataCoreObject {
    
    init(_ asset: WDMasterEntity) {
        super.init()
        super.asset = asset
    }
    
    var profileCode: String {
        let code = """
        <div class="tradingview-widget-container">
          <div class="tradingview-widget-container__widget"></div>
          <div class="tradingview-widget-copyright"><a href="https://www.tradingview.com/symbols/NASDAQ-AAPL/" rel="noopener" target="_blank"><span class="blue-text"></span></a></div>
          <script type="text/javascript" src="https://s3.tradingview.com/external-embedding/embed-widget-symbol-profile.js" async>
          {
            "symbol": "NASDAQ:\(asset.rawCode!)",
              "width": 480,
              "height": 650,
              "colorTheme": "light",
              "isTransparent": false,
              "locale": "en"
          }
          </script>
        </div>
        """
        print(code)
        return code
    }

}

class CDWebData: WebDataCoreObject {
    
    var stockScript = "embed-widget-symbol-info.js"
    var currencyScript = "embed-widget-single-quote.js"
    var cryptoScript = "embed-widget-symbol-info.js"
    var stockSource = "NASDAQ"
    var currencySource = "FX_IDC"
    var cryptoSource = "BITSTAMP"
    var script: String?
    var source: String?
    
    var widthPercantage = 100
    var isTransparent = "true"
    
    var code: String {
        let symbol = asset.code
        let code = """
               <div class="tradingview-widget-container">
                 <div class="tradingview-widget-container__widget"></div>
                 <script type="text/javascript" src="https://s3.tradingview.com/external-embedding/\(script ?? currencyScript)" async>
                 {
                     "symbol": "\(symbol)",
                     "width": "\(widthPercantage)%",
                     "colorTheme": "\(colorTheme)",
                     "isTransparent": \(isTransparent),
                     "locale": "\(locale)"
                 }
                 </script>
               </div>
               """
        return code
    }
    
}

class CDStockWebData: CDWebData {
    
    init(_ asset: WDMasterEntity) {
        super.init()
        super.asset = asset
        script = stockScript
        source = stockSource
    }
    
}

class CDCurrencyWebData: CDWebData {
    
    init(_ asset: WDMasterEntity) {
        super.init()
        super.asset = asset
        script = stockScript
        source = currencySource
    }
    
}

class CDCryptoWebData: CDWebData {
    
    init(_ asset: WDMasterEntity) {
        super.init()
        super.asset = asset
        script = cryptoScript
        source = cryptoSource
    }
    
}

class CDOtherWebData: CDWebData {
    
    init(_ asset: WDMasterEntity) {
        super.init()
        super.asset = asset
    }
    
}

