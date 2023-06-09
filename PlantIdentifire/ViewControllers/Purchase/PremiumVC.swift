//
//  PremiumVC.swift
//  PlantIdentifire
//
//  Created by Miral's iMac on 04/04/23.
//

import UIKit

class PremiumVC: UIViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var viewYear: UIView!
    @IBOutlet weak var lblYearPrice: UILabel!
    @IBOutlet weak var lblYearDescription: UILabel!
    
    @IBOutlet weak var viewMonth: UIView!
    @IBOutlet weak var lblMonthPrice: UILabel!
    @IBOutlet weak var lblMonthDescription: UILabel!
    
    @IBOutlet weak var btnContinueWithLimit: UIButton!
    @IBOutlet weak var btnContinueWithLimitConstant: NSLayoutConstraint!
    
    @IBOutlet weak var btnRestore: UIButton!
    @IBOutlet weak var btnTermsOfuse: UIButton!
    @IBOutlet weak var btnPrivacyPolicy: UIButton!
    @IBOutlet weak var topImageHeightConstant: NSLayoutConstraint!
    
    
    //MARK: - Variables
    var selectedIndex = 0
    var isFromHome = Bool()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.initView()
    }
    
    //MARK: - Methods
    func initView() {
      
        if !UIDevice.current.hasNotch && UIDevice.current.isPhone{
            topImageHeightConstant.constant = 260
        }
        self.btnRestore.setTitle("Restore purchase", for: .normal)
        self.btnPrivacyPolicy.setTitle("Privacy Policy", for: .normal)
        self.btnTermsOfuse.setTitle(" •  "+"Terms & Use", for: .normal)
        self.lblDescription.text = "Discover & Identify: Your personal botanist in your pocket,helping you uncover the wonders of the plant kingdom!"
        
        self.lblYearDescription.text = "Year billed annually"
        self.lblMonthDescription.text = "Year billed annuallyYear billed annually"
        
        getLocalPrice()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+3.0){
            self.btnContinueWithLimitConstant.constant = 30
            self.btnContinueWithLimit.alpha = 0.0
            UIView.animate(withDuration: 2, delay: 0.0, options: [.curveLinear], animations: {
                self.btnContinueWithLimit.alpha = 1.0
                
            }, completion: nil)
        }
    }
    
    func getLocalPrice() {
        InAppManager.shared.retriveProductInfo(arrProduct: [IN_APP_PURCHASE_IDS[0],IN_APP_PURCHASE_IDS[1]]) { result in
            for product in result {
                let priceString = product.localizedPrice!
                debugPrint("Product: \(product.localizedDescription), price: \(priceString)")
                
                if product.productIdentifier == IN_APP_PURCHASE_IDS[0] {
                    self.lblYearPrice.text = "Yearly - \(priceString) / year"
                }else if product.productIdentifier == IN_APP_PURCHASE_IDS[1] {
                    self.lblMonthPrice.text = "7 Day Free Trial - \(priceString) / month"
                }
            }
        }
    }
  
    //MARK: Btn Actions
    @IBAction func actionClose(_ sender: Any) {
        if isFromHome{
            self.dismiss(animated: false) {
                if !isUserSubscribe() {
                    AdsManager.shared.presentInterstitialAd()
                }
            }
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func actionSelection(_ sender: UIButton) {
        InAppManager.shared.purchaseProduct(productId: IN_APP_PURCHASE_IDS[self.selectedIndex]) {
            
        }
    }
    
    @IBAction func actionRestorePurchase(_ sender: Any) {
        InAppManager.shared.restoreProduct {
            
        }
    }
    
    @IBAction func actionPrivacyPolicy(_ sender: Any) {
        if let url = URL.init(string: PRIVACY_POLICY){
            UIApplication.shared.open(url, options: [:]) { status in
            }
        }
    }
    
    @IBAction func actionTermsOfUse(_ sender: Any) {
        if let url = URL.init(string: TERM_AND_CONDITION){
            UIApplication.shared.open(url, options: [:]) { status in
            }
        }
    }
    
    
}
