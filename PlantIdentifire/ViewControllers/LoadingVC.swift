//
//  LoadingVC.swift
//  PlantIdentifire
//
//  Created by Miral's iMac on 24/03/23.
//

import Foundation
import UIKit
import GoogleMobileAds

func delay(_ delay: Double, closure: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay, execute: closure)
}

class LoadingVC: UIViewController {
    
    //MARK: Outlates
    
    @IBOutlet weak var lblLoading: UILabel!
    

    //MARK: Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    // MARK: - Methods
    
    func initView(){
        lblLoading.text = "Loading Ads..."
        UserDefaults.standard.set(false, forKey: "isPresentCamera")
        delay(0.7) {
            if interstitialAd != nil {
                
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    AdsManager.shared.presentInterstitialAd()
                }
                
                if UserDefaults.isCheckOnBording {
                    // Load Interstitial Ad
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
                        let redViewController = mainStoryBoard.instantiateViewController(withIdentifier: "CustomTabBarVC") as! CustomTabBarVC
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.window?.rootViewController = redViewController
                    }
                
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OnBordingVC") as? OnBordingVC
                        self.navigationController?.pushViewController(vc!, animated: true)
                    }
                   
                }
                
//                if !isShowLanguage(){
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                        self.languageVC()
//                    }
//
//                } else if !isShowFristTime() {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                        self.navigateToHome()
//                       // self.introSliderVC()
//                    }
//
//                }else if !isShowParmission(){
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                        self.navigateToHome()
//                      //  self.permissionVC()
//                    }
//                } else {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                        self.navigateToHome()
//                    }
//                }
            }
        }
    }
}
