//
//  InAppManager.swift
//  PlantIdentifire
//
//  Created by Miral's iMac on 04/04/23.
//

import Foundation
import SwiftyStoreKit
import StoreKit
import UIKit

class InAppManager: NSObject {
    
    static let shared = InAppManager()
    
    // MARK: - Complite pending transactions
    func completeTransition() {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                case .failed, .purchasing, .deferred:
                    break // do nothing
                @unknown default:
                    debugPrint("Default Method Called")
                }
            }
        }
    }
    
    // MARK: - Receipt Verify
    func verifyReciept() {
        var isPurched = false
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: SHARE_SECRET)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
                case .success(let receipt):
                    guard let dict = receipt["latest_receipt_info"] as? [[String:Any]] else { return }
                    for k in dict {
                    let productId = k["product_id"] as! String
                    // Verify the purchase of a Subscription
                    let purchaseResult = SwiftyStoreKit.verifySubscription(
                        ofType: .autoRenewable, // or .nonRenewing (see below)
                        productId: productId,
                        inReceipt: receipt)
                    
                    switch purchaseResult {
                        
                        case .purchased(let expiryDate, let items):
                            debugPrint("\(productId) is valid until \(expiryDate)\n\(items)\n")
                            isPurched = true
                            
                            
                        case .expired(let expiryDate, let items):
                            debugPrint("\(productId) is expired since \(expiryDate)\n\(items)\n")
                            if !isPurched{
                                setIsUserSubscribe(isSubscribe: false)
                            }
                            
                        case .notPurchased:
                            debugPrint("The user has never purchased \(productId)")
                            if !isPurched{
                                setIsUserSubscribe(isSubscribe: false)
                            }
                    }
                      
                }

                case .error(let error):
                    debugPrint("Receipt verification failed: \(error)")
            }
        }
    }
    
    // MARK: - Retrive Information About Product
    func retriveProductInfo(arrProduct: Set<String>, completion: @escaping (Set<SKProduct>) -> Void) {
        SwiftyStoreKit.retrieveProductsInfo(arrProduct) { result in
            completion(result.retrievedProducts)
        }
    }
    
    // MARK: - Purchas Product
    func purchaseProduct(productId: String) {
        showLoader()
        
        SwiftyStoreKit.purchaseProduct(productId, quantity: 1, atomically: true) { result in
                removeLoader()
            
            switch result {
            case .success(let purchase):
                debugPrint("Purchase Success: \(purchase.productId)")
                displayToast("Purchase Successfully !")
                interstitialAd = nil
                NATIVE_ADS = nil
                setIsUserSubscribe(isSubscribe: true)
                    
            case .error(let error):
                displayToast(error.localizedDescription)
                
                switch error.code {
                case .unknown: debugPrint("Unknown error. Please contact support")
                case .clientInvalid: debugPrint("Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: debugPrint("The purchase identifier was invalid")
                case .paymentNotAllowed: debugPrint("The device is not allowed to make the payment")
                case .storeProductNotAvailable: debugPrint("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: debugPrint("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: debugPrint("Could not connect to the network")
                case .cloudServiceRevoked: debugPrint("User has revoked permission to use this cloud service")
                default: debugPrint((error as NSError).localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Restore In App Purchas
    func restoreProduct() {
        showLoader()
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
                removeLoader()
            
            if results.restoreFailedPurchases.count > 0 {
                debugPrint("Restore Failed: \(results.restoreFailedPurchases)")
                displayToast(results.restoreFailedPurchases.debugDescription)
            } else if results.restoredPurchases.count > 0 {
                debugPrint("Restore Success: \(results.restoredPurchases)")
                setIsUserSubscribe(isSubscribe: true)
            } else {
                displayToast("Nothing to Restore")
            }
        }
    }
}
