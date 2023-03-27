//
//  ExitAdVC.swift
//  PlantIdentifire
//
//  Created by Miral's iMac on 27/03/23.
//

import UIKit

class ExitAdVC: UIViewController {
    // MARK: - Outlets
    @IBOutlet var nativeAdView: UIView! {
        didSet {
            self.nativeAdView.isHidden = true
        }
    }
    
    // MARK: - Variables
    var googleNativeAds = GoogleNativeAds()
    var isShowNativeAds = false
}

// MARK: - View life cycle
extension ExitAdVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNativeAd()
    }
}

// MARK: - Actions
extension ExitAdVC {
    @IBAction func onClickExit(_ sender: UIButton) {
        exit(0)
    }
    
    @IBAction func onClickDismiss(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

// MARK: - User defined functions
extension ExitAdVC {
    func setNativeAd() {
        if let nativeAds = NATIVE_ADS {
            self.nativeAdView.isHidden = false
            self.isShowNativeAds = true
            self.googleNativeAds.showAdsView1(nativeAd: nativeAds, view: self.nativeAdView)
        }
        googleNativeAds.loadAds(self) { nativeAdsTemp in
            NATIVE_ADS = nativeAdsTemp
            if !self.isShowNativeAds{
                self.googleNativeAds.showAdsView1(nativeAd: nativeAdsTemp, view: self.nativeAdView)
            }
        }
    }
}

