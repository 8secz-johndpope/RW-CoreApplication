import Foundation
import Vision
import UIKit

class WDReader: WebDataCoreObject {

    private var rawData = [String]()
    
    var delegate: WDReaderProtocol!
    
    func registerProfile(image: UIImage) {
        
        let request = VNRecognizeTextRequest { request, error in
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                fatalError("Received invalid observations.")
            }
            
            for observation in observations {
                guard let bestCandidate = observation.topCandidates(1).first else {
                    fatalError("Invalid data widget detected.")
                    continue
                }
                self.rawData.append(bestCandidate.string)
            }
            
        }
        
        let requests = [request]
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            guard let img = image.cgImage else {
                fatalError("Missing data image.")
            }
            
            let handler = VNImageRequestHandler(cgImage: img, options: [:])
            
            do {
                
                try handler.perform(requests)
                print("Raw profile text data: \(self.rawData)")
                
                self.asset.sector = self.rawData[1]
                self.asset.industry = self.rawData[2]
                self.asset.employees = self.rawData[3]
                
                self.asset.profile = String()
                for i in 4...self.rawData.count-5 {
                    self.asset.profile = self.asset.profile?.appending(self.rawData[i])
                    self.asset.profile = self.asset.profile?.appending(" ")
                }
                
                DispatchQueue.main.async {
                    self.delegate.didFinishLoadingData(asset: self.asset)
                }
                
            } catch {
                print("Profile error!")
            }
        }
        
    }
    
    func register(image: UIImage) {
        
        let request = VNRecognizeTextRequest { request, error in
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                fatalError("Received invalid observations.")
            }
            
            for observation in observations {
                guard let bestCandidate = observation.topCandidates(1).first else {
                    fatalError("Invalid data widget detected.")
                    continue
                }
                self.rawData.append(bestCandidate.string)
            }
            
        }
        
        let requests = [request]
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            guard let img = image.cgImage else {
                fatalError("Missing data image.")
            }
            
            let handler = VNImageRequestHandler(cgImage: img, options: [:])
            
            do {
                
                try handler.perform(requests)

                if self.asset.type == .stock {
                    let name = self.rawData[0]
                    self.asset.name = name
                }
                
            } catch {
                fatalError("Invalid data image.")
            }
            
            for deledate in self.asset.delegates {
                deledate.didFinishLoadingRates(asset: self.asset)
            }
            
        }
    }
    
}

protocol WDReaderProtocol {
    
    func didFinishLoadingData(asset: WDMasterEntity)
    
}

extension WDReader {
    
    enum type: String {
        case stock = "Stock"
        case currency = "Currency"
        case crypto = "Crypto"
        case undefined = "Undefined"
        case other = "..."
    }
    
}
