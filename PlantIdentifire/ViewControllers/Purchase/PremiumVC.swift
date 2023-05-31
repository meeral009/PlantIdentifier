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
    @IBOutlet var sliderCollectionView: UICollectionView!
    
    var isFromHome = Bool()
    let arrReview = ["This app knows everything \n when it comes to plants and plant care. \n Love it!", "The app has correctly identified \n every plant leaf and flower I've inquired about so far. \n Awesome app, just what I was looking for.", "Very accurate and versatile.Probably as close to perfect as it is possible to be."]
    var timer = Timer()
    var counter = 0
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
        InAppManager.shared.purchaseProduct(productId: IN_APP_PURCHASE_IDS[0], completion: {
            self.dismiss(animated: true)
            
        })
    }
    
    @IBAction func onClickRestore(_ sender: UIButton) {
        InAppManager.shared.restoreProduct(completion: {
            self.dismiss(animated: true)
        })
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
    
    @objc func changeReview() {
        if self.arrReview.count != 0 {
          
            if self.counter < self.arrReview.count {
                let index = IndexPath(item: counter, section: 0)
                self.sliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
                self.counter += 1
                
            } else {
                self.counter = 0
                let index = IndexPath(item: counter, section: 0)
                self.sliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
                self.counter = 1
            }
        }
    }
}

// MARK: - User defined functions
extension PremiumVC {
    
    func initView(){
        self.getLocalPrice()
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.changeReview), userInfo: nil, repeats: true)
        }
        
        self.sliderCollectionView.register(UINib(nibName: "ReviewCell", bundle: nil), forCellWithReuseIdentifier: "ReviewCell")
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
extension PremiumVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return self.arrReview.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReviewCell", for: indexPath) as! ReviewCell
        cell.lblReview.text = self.arrReview[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}
