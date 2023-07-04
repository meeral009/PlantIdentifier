//
//  IdentifyOptionsVC.swift
//  PlantIdentifire
//
//  Created by Miral's iMac on 29/04/23.
//

import UIKit
import YPImagePicker

protocol DismissViewControllerDelegate {
    func dismiss(mode: String,img:UIImage)
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
//        AdsManager.shared.delegate = self
    }
}

// MARK: - Actions
extension IdentifyOptionsVC {
    @IBAction func onClickQRScan(_ sender: UIButton) {
        self.isScanningModeOn = true
        self.mode = "photo"

        if isUserSubscribe() {
            self.dismissDelegate?.dismiss(mode: "photo", img: UIImage())
            self.dismiss(animated: true)
        } else if getFreeScan() == 2 && !isUserSubscribe()  {
            self.dismissDelegate?.dismiss(mode: "camera", img: UIImage())
            self.dismiss(animated: true)
        }  else {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                UserDefaults.standard.set(true, forKey: "isPresentCamera")
//                AdsManager.shared.presentInterstitialAd1(vc: self)
            }
        }
    }

    @IBAction func onClickCamera(_ sender: UIButton) {
        self.isScanningModeOn = false
        self.mode = "camera"
        if isUserSubscribe() {
            //self.presentCameraScreen()
            self.dismissDelegate?.dismiss(mode: "camera", img: UIImage())
            self.dismiss(animated: true)
        } else if getFreeScan() == 2 && !isUserSubscribe()  {
            self.dismissDelegate?.dismiss(mode: "camera", img: UIImage())
            self.dismiss(animated: true)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                UserDefaults.standard.set(true, forKey: "isPresentCamera")
//                AdsManager.shared.presentInterstitialAd1(vc: self)
            }
        }
    }
    
    
    @IBAction func onClickGallery(_ sender: UIButton) {
        self.isScanningModeOn = false
        self.mode = "photo"
        if isUserSubscribe() {
            self.dismissDelegate?.dismiss(mode: "photo", img: UIImage())
            self.dismiss(animated: true)
        } else if getFreeScan() == 2 && !isUserSubscribe()  {
            self.dismissDelegate?.dismiss(mode: "camera", img: UIImage())
            self.dismiss(animated: true)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                UserDefaults.standard.set(true, forKey: "isPresentCamera")
//                AdsManager.shared.presentInterstitialAd1(vc: self)
            }
        }
    }
    
    @IBAction func onClickDismiss(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
