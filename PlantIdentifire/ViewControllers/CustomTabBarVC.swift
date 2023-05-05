//
//  CustomTabBarVC.swift
//  PlantIdentifire
//
//  Created by admin on 15/11/22.
//

import UIKit
import STTabbar
import YPImagePicker
import AVFoundation
import AVKit
import Photos
import GoogleMobileAds

class CustomTabBarVC: UITabBarController {
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUPUI()
        
        // Do any additional setup after loading the view.
    }
}

// MARK: - User Define function
extension CustomTabBarVC {
    
    // Initial set up for UIView.
    func setUPUI() {
       
        // set action of center tabbar button for open camera.
        if let myTabbar = tabBar as? STTabbar {
            myTabbar.centerButtonActionHandler = {
//                DispatchQueue.main.asyncAfter(deadline: .now()) {
//                    AdsManager.shared.presentInterstitialAd1(vc: self)
//                }
//
//                if isUserSubscribe() {
                    //self.presentCameraScreen()
                    self.presentOptionSheet()
//                }
            }
        }
    }

    func presentOptionSheet() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "IdentifyOptionsVC") as! IdentifyOptionsVC
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false, completion: nil)
    }
    
}

// Support methods
extension CustomTabBarVC {
    /* Gives a resolution for the video by URL */
    func resolutionForLocalVideo(url: URL) -> CGSize? {
        guard let track = AVURLAsset(url: url).tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
}


