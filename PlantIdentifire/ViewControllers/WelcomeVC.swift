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
        
        
        
//        if UserDefaults.isCheckOnBording {
//            // Load Interstitial Ad
//            if interstitialAd != nil {
//               DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//                   self.loadingVC()
//               }
//
//            } else {
//                let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
//                let redViewController = mainStoryBoard.instantiateViewController(withIdentifier: "CustomTabBarVC") as! CustomTabBarVC
//                let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                appDelegate.window?.rootViewController = redViewController
//            }
//
//        } else {
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "OnBordingVC") as? OnBordingVC
//            self.navigationController?.pushViewController(vc!, animated: true)
//        }
    }
}

// MARK: - UserDEfined Function

extension WelcomeVC {
    func setUpUI() {
        self.vwGetStarted.layer.cornerRadius = 15
        
        self.googleNativeAds.loadAds(self) { nativeAdsTemp in
            NATIVE_ADS = nativeAdsTemp
        }
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
    
    
    func setUpNavigation() {
        if interstitialAd != nil{
           DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
               self.loadingVC()
           }
       }
    }
    func loadingVC() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoadingVC") as! LoadingVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
