//
//  WelcomeVC.swift
//  PlantIdentifire
//
//  Created by admin on 17/11/22.
//

import GoogleMobileAds
import UIKit
import NVActivityIndicatorView

class WelcomeVC: UIViewController {
    // MARK: - IBOutlates
    
    @IBOutlet var vwGetStarted: UIView!
    
    @IBOutlet var lblAds: UILabel!
    @IBOutlet var activityIndicatorView: NVActivityIndicatorView!
    let googleNativeAds = GoogleNativeAds()
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    // MARK: - IBActionMethods
    
    @IBAction func btngetStartedAction(_ sender: Any) {}
}

// MARK: - UserDEfined Function

extension WelcomeVC {
    func setUpUI() {
        self.vwGetStarted.layer.cornerRadius = 15
        self.activityIndicatorView.type = .circleStrokeSpin
        self.activityIndicatorView.startAnimating()
        self.googleNativeAds.loadAds(self) { nativeAdsTemp in
            NATIVE_ADS = nativeAdsTemp
        }
        self.lblAds.text = "This action can contain ads"
        
        var i = 0.0
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            i += 0.5
            if interstitialAd != nil {
                timer.invalidate()
                self.setUpNavigation()
            } else {
                if i > 4 {
                    self.setUpNavigation()
                    timer.invalidate()
                }
            }
        }
    }
    
    func setUpNavigation() {
        if isUserSubscribe() {
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
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.activityIndicatorView.stopAnimating()
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
