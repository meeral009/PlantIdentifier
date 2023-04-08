//
//  PremiumVC.swift
//  PlantIdentifire
//
//  Created by Miral's iMac on 04/04/23.
//

import UIKit

class PremiumVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet var btnCancel: UIButton!
    @IBOutlet var btnRestore: UIButton!
    @IBOutlet var lblThoghts: UILabel!
    @IBOutlet var lblGetPremiumAccess: UIButton!
    @IBOutlet var lblHelpAllPlants: UILabel!
    @IBOutlet var lblPr: UILabel!
    @IBOutlet var lblFeature1: UILabel!
    @IBOutlet var lblFeature2: UILabel!
    @IBOutlet var lblFeature3: UILabel!
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var lblAutorenewable: UILabel!
    @IBOutlet var lblFreeTrial: UILabel!
    @IBOutlet var freeSwitch: UISwitch!
    @IBOutlet var btnContinue: UIButton!
    @IBOutlet var btnPrivacyPolicy: UIButton!
    @IBOutlet var btnTNC: UIButton!
    var isFromHome = Bool()
}

// MARK: - View life cycle
extension PremiumVC {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.initView()
        
    }
}

// MARK: - Actions
extension PremiumVC {
    
    @IBAction func onClickPrivacyPolicy(_ sender: UIButton) {
        if let url = URL.init(string: PRIVACY_POLICY){
            UIApplication.shared.open(url, options: [:]) { status in
            }
        }
    }
    
    @IBAction func onClickPrivacyTNC(_ sender: UIButton) {
        if let url = URL.init(string: TERM_AND_CONDITION){
            UIApplication.shared.open(url, options: [:]) { status in
            }
        }
    }
    
    @IBAction func onClickContinue(_ sender: UIButton) {
        InAppManager.shared.purchaseProduct(productId: IN_APP_PURCHASE_IDS[0])
    }
    
    @IBAction func onClickRestore(_ sender: UIButton) {
        InAppManager.shared.restoreProduct()
    }
    
    @IBAction func onClickPrivacyCancel(_ sender: UIButton) {
//        if isFromHome{
//            self.dismiss(animated: false) {
//                DispatchQueue.main.asyncAfter(deadline: .now()) {
//                    AdsManager.shared.presentInterstitialAd()
//                }
//            }
//        }else{
            self.dismiss(animated: true, completion: nil)
//        }
    }
    
    @IBAction func onToggleFreeSwitch(_ sender: UISwitch) {
        
    }
}

// MARK: - User defined functions
extension PremiumVC {
    
    func initView(){
        self.getLocalPrice()
    }
    
    
    func getLocalPrice() {
        InAppManager.shared.retriveProductInfo(arrProduct: [IN_APP_PURCHASE_IDS[0]]) { result in
            for product in result {
                let priceString = product.localizedPrice!
                debugPrint("Product: \(product.localizedDescription), price: \(priceString)")
                
                if product.productIdentifier == IN_APP_PURCHASE_IDS[0] {
                    self.lblPrice.text = "Just \(priceString) per year "
                }
            }
        }
    }
}
