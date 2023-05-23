//
//  IdentifyOptionsVC.swift
//  PlantIdentifire
//
//  Created by Miral's iMac on 29/04/23.
//

import UIKit
import YPImagePicker

protocol DismissViewControllerDelegate {
    func dismiss(mode: String)
}

class IdentifyOptionsVC: UIViewController {
    // MARK: - Variables
    var selectedItems = [YPMediaItem]()
    
    lazy var selectedImageV : UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.45))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
   
    var isScanningModeOn = false
    var dismissDelegate: DismissViewControllerDelegate?
    var mode: String = "photo"
}


// MARK: - View life cycle
extension IdentifyOptionsVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        AdsManager.shared.delegate = self
    }
}

// MARK: - Actions
extension IdentifyOptionsVC {
    @IBAction func onClickQRScan(_ sender: UIButton) {
        self.isScanningModeOn = true
        self.mode = "photo"
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            UserDefaults.standard.set(true, forKey: "isPresentCamera")
            AdsManager.shared.presentInterstitialAd1(vc: self)
        }
        
        if isUserSubscribe() {
            self.dismissDelegate?.dismiss(mode: "photo")
            self.dismiss(animated: true)
        }
    }

    @IBAction func onClickCamera(_ sender: UIButton) {
        self.isScanningModeOn = false
        self.mode = "camera"
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            UserDefaults.standard.set(true, forKey: "isPresentCamera")
            AdsManager.shared.presentInterstitialAd1(vc: self)
        }
        
        if isUserSubscribe() {
            //self.presentCameraScreen()
            self.dismissDelegate?.dismiss(mode: "camera")
            self.dismiss(animated: true)
        }
    }
    
    
    @IBAction func onClickGallery(_ sender: UIButton) {
        self.isScanningModeOn = false
        self.mode = "photo"
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            UserDefaults.standard.set(true, forKey: "isPresentCamera")
            AdsManager.shared.presentInterstitialAd1(vc: self)
        }
        
        if isUserSubscribe() {
            self.dismissDelegate?.dismiss(mode: "photo")
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func onClickDismiss(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

// MARK: - Delagte Functions

extension IdentifyOptionsVC: AdsManagerDelegate {
    func NativeAdLoad() { }
    
    func DidDismissFullScreenContent() {
        self.dismissDelegate?.dismiss(mode: self.mode)
        self.dismiss(animated: true)
    }
    
    func NativeAdsDidFailedToLoad() { }
}
