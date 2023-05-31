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
    
    // MARK: - Varibles
     var plantModel = PlantModel()
     
    
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
                self.presentOptionSheet()
            }
        }
    }

    func presentOptionSheet() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "IdentifyOptionsVC") as! IdentifyOptionsVC
        vc.modalPresentationStyle = .overFullScreen
        vc.dismissDelegate = self
        self.present(vc, animated: false, completion: nil)
    }
    
    // Present camera and gallery on screen.
    func presentCameraScreen(screen: String) {
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.allowsEditing = true
        imagePickerVC.delegate = self
        if  screen == "photo" {
            imagePickerVC.sourceType = .photoLibrary
        } else {
            imagePickerVC.sourceType = .camera
        }
       
        if getFreeScan() == 2 && !isUserSubscribe() {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PremiumVC") as! PremiumVC
            vc.modalPresentationStyle = .fullScreen
            vc.isFromHome = true
            self.present(vc, animated: true, completion: nil)

        } else {
            self.present(imagePickerVC, animated: true)
        }
    }
    
    func uploadPlantImage(image : UIImage) {
        
        self.plantModel.uploadPlantImage(plantImage: image, isShowLoader: true) { id in
            print("id of plant \(id)")
            setFreeScan()
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlantDetailsVC") as? PlantDetailsVC
            vc?.image = image
            vc?.id = id
            vc?.modalPresentationStyle = .fullScreen
            self.present(vc ?? UIViewController(), animated: true)
            
        } failure: { statuscode, error, customError in
            print(error)
            self.showAlert(with: error)
        }
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


extension CustomTabBarVC: DismissViewControllerDelegate {
    func dismiss(mode: String) {
        self.presentingViewController?.dismiss(animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.presentCameraScreen(screen: mode)
            UserDefaults.standard.set(false, forKey: "isPresentCamera")
        }
    }
}

extension CustomTabBarVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            AdsManager.shared.presentInterstitialAd1(vc: self ?? UIViewController())
        }
        if let image = info[.originalImage] as? UIImage {
            self.uploadPlantImage(image: image)
        }
    }
}
