//
//  WelcomeVC.swift
//  PlantIdentifire
//
//  Created by admin on 17/11/22.
//

import GoogleMobileAds
import UIKit

class WelcomeVC: UIViewController {
    // MARK: - IBOutlates
    
    @IBOutlet var vwGetStarted: UIView!
  
    let googleNativeAds = GoogleNativeAds()
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
       
    
        // Do any additional setup after loading the view.
    }
    
    // MARK: - IBActionMethods
    
    @IBAction func btngetStartedAction(_ sender: Any) {
        
        var i = 0.0
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            i+=0.5
            if interstitialAd != nil{
                timer.invalidate()
                self.setUpNavigation()
            }else{
                if i > 4 {
                    self.setUpNavigation()
                    timer.invalidate()
                }
            }
        }
    }
}

// MARK: - UserDEfined Function

extension WelcomeVC {
    func setUpUI() {
        self.vwGetStarted.layer.cornerRadius = 15
        
        self.googleNativeAds.loadAds(self) { nativeAdsTemp in
            NATIVE_ADS = nativeAdsTemp
        }

        
    }
    
    
    func setUpNavigation() {
        if interstitialAd != nil{
           DispatchQueue.main.asyncAfter(deadline: .now()) {
               UserDefaults.standard.set(false, forKey: "isPresentCamera")
               self.loadingVC()
           }
       }
    }
    func loadingVC() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoadingVC") as! LoadingVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
