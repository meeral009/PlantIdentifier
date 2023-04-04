//
//  LoadingVC.swift
//  PlantIdentifire
//
//  Created by Miral's iMac on 24/03/23.
//

import Foundation
import GoogleMobileAds
import UIKit

func delay(_ delay: Double, closure: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay, execute: closure)
}

class LoadingVC: UIViewController {
    // MARK: Outlates
    
    @IBOutlet var lblLoading: UILabel!
    
    // MARK: Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    // MARK: - Methods
    
    func initView() {
        lblLoading.text = "Loading Ads..."
        UserDefaults.standard.set(false, forKey: "isPresentCamera")
        delay(0.7) {
         //   if interstitialAd != nil {
                AdsManager.shared.presentInterstitialAd1(vc: self)

                if UserDefaults.isCheckOnBording {
                    // Load Interstitial Ad
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
                        let redViewController = mainStoryBoard.instantiateViewController(withIdentifier: "CustomTabBarVC") as! CustomTabBarVC
                        self.navigationController?.viewControllers = [redViewController]
                        self.navigationController?.pushViewController(redViewController, animated: true)

                    }
                
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OnBordingVC") as? OnBordingVC
                        self.navigationController?.pushViewController(vc!, animated: true)
                    }
//                }
            }
        }
    }
}
