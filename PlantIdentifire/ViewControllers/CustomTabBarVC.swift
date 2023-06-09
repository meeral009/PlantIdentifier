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
        
        
    }
   
}

// MARK: - User Define function
extension CustomTabBarVC {
    
    // Initial set up for UIView.
    func setUPUI() {
        // set action of center tabbar button for open camera.
        self.navigationController?.viewControllers = [self]
        if let myTabbar = tabBar as? STTabbar {
            myTabbar.centerButtonActionHandler = {
                self.presentOptionSheet()
            }
        }
    }

    func presentOptionSheet() {
        if getFreeScan() == 2 && !isUserSubscribe() {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PremiumVC") as! PremiumVC
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        } else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CameraVC") as! CameraVC
            vc.modalPresentationStyle = .overFullScreen
            vc.dismissDelegate = self
            vc.topVC = self
            self.navigationController?.pushViewController(vc, animated: true)
//            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    // Present camera and gallery on screen.
    func presentCameraScreen(screen: String,img:UIImage) {
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
            
            Results.getPlantDetailsAPI(isShowLoader: false, id: id) { plantModel, message in
                print(plantModel)
                if message != "Not a plant." {
                    // Set data from first element of Images array from response
                   
                    if let result = plantModel.first{
                        var similarImages = [Images]()
                        if plantModel.count > 1 {
                            if let plantImages = plantModel[1].images {
                                similarImages.append(contentsOf: plantImages)
                                
                            }
                        }
                        result.similar_images = similarImages
                        result.id = UUID().uuidString
                        DispatchQueue.main.async {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlantDetailsVC") as! PlantDetailsVC
                            vc.image = image
                            vc.id = id
                            vc.resultsModel = result
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                     
                        
                    }else{
                        DispatchQueue.main.async {
                            self.showToast(message: message)
                        }
                    }
                    
                } else {
                    ERProgressHud.sharedInstance.hide()
                    DispatchQueue.main.async {
                        self.showAlert(with: "Choose another image that have plant.",firstHandler: { action in
                            self.dismiss(animated: true)
                        })
                    }
                }
            } failure: { _, error, _ in
                ERProgressHud.sharedInstance.hide()
                DispatchQueue.main.async {
                    self.showToast(message: error)
                }
            }
            
            
           
            
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
    func dismiss(mode: String, img: UIImage) {
        self.presentingViewController?.dismiss(animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.uploadPlantImage(image: img)
        }
    }
    
//    func dismiss(mode: String) {
//        self.presentingViewController?.dismiss(animated: true)
//        DispatchQueue.main.asyncAfter(deadline: .now()) {
//            self.presentCameraScreen(screen: mode)
//            UserDefaults.standard.set(false, forKey: "isPresentCamera")
//        }
//    }
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
