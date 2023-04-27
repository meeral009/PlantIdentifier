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
    
    //MARK: - variables
    
    var selectedItems = [YPMediaItem]()
    
    var plantModel = PlantModel()
    
    lazy var selectedImageV : UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.45))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
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
        AdsManager.shared.delegate = self
        
        // set action of center tabbar button for open camera.
        if let myTabbar = tabBar as? STTabbar {
            myTabbar.centerButtonActionHandler = {
                DispatchQueue.main.async {
                    UserDefaults.standard.set(true, forKey: "isPresentCamera")
                    AdsManager.shared.presentInterstitialAd1(vc: self)
                }
                
                if isUserSubscribe() {
                    self.presentCameraScreen()
                }
            }
        }
    }
    
    
    // Upload Image api call
    func uploadPlantImage(image : UIImage){
        
        self.plantModel.uploadPlantImage(plantImage: image, isShowLoader: true) { id in
            print("id of plant \(id)")
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlantDetailsVC") as? PlantDetailsVC
            vc?.image = image
            vc?.id = id
            vc?.modalPresentationStyle = .fullScreen
            // self.navigationController?.pushViewController(vc!, animated: false)
            self.present(vc ?? UIViewController(), animated: true)
            
        } failure: { statuscode, error, customError in
            print(error)
            self.showAlert(with: error)
        }
    }
    
    // Managing recent search
    func manamgeRecentSeraches(id : String) {
        
        // Access Shared Defaults Object
        let userDefaults = UserDefaults.standard
        
        // Read/Get Array of Strings
        if let strings = userDefaults.object(forKey: "arrId") as? [String] {
            
            arrId.append(contentsOf: strings)
            
            if arrId.contains(id){
                print("Already exits.")
            } else {
                arrId.append(id)
                userDefaults.set(arrId, forKey: "arrId")
            }
            
        }
        
    }
    
    
    // Present camera and gallery on screen.
    func presentCameraScreen() {
                   
        var config = YPImagePickerConfiguration()
        
        /* Choose what media types are available in the library. Defaults to `.photo` */
        config.library.mediaType = .photoAndVideo
        config.library.itemOverlayType = .grid
        
        /* Enables selecting the front camera by default, useful for avatars. Defaults to false */
        config.usesFrontCamera = false
        
        /* Adds a Filter step in the photo taking process. Defaults to true */
        config.showsPhotoFilters = false
        
        /* Enables you to opt out from saving new (or old but filtered) images to the
         user's photo library. Defaults to true. */
        config.shouldSaveNewPicturesToAlbum = false
        
        /* Defines which screen is shown at launch. Video mode will only work if `showsVideo = true`.
         Default value is `.photo` */
        config.startOnScreen = .photo
        
        /* Defines which screens are shown at launch, and their order.
         Default value is `[.library, .photo]` */
        config.screens = [.library, .photo]
        
        /* Can forbid the items with very big height with this property */
        config.library.minWidthForItem = UIScreen.main.bounds.width * 0.8
        
        /* Adds a Crop step in the photo taking process, after filters. Defaults to .none */
        config.showsCrop = .rectangle(ratio: (10/10))
        
        /* Customize wordings */
        config.wordings.libraryTitle = "Gallery"
        
        /* Defines if the status bar should be hidden when showing the picker. Default is true */
        config.hidesStatusBar = true
        
        /* Defines if the bottom bar should be hidden when showing the picker. Default is false */
        config.hidesBottomBar = false
        
        config.maxCameraZoomFactor = 2.0
        
        config.library.maxNumberOfItems = 5
        config.gallery.hidesRemoveButton = false
        config.library.preselectedItems = selectedItems
        
        config.overlayView = UIView()
        
        let picker = YPImagePicker(configuration: config)
        
        picker.imagePickerDelegate = self
        
        /* Multiple media implementation */
        picker.didFinishPicking { [weak picker] items, cancelled in
            
            if cancelled {
                print("Picker was canceled")
                picker?.dismiss(animated: true, completion: nil)
                return
            }
            _ = items.map { print("🧀 \($0)") }
            
            self.selectedItems = items
            if let firstItem = items.first {
                switch firstItem {
                case .photo(let photo):
                    self.selectedImageV.image = photo.image
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        AdsManager.shared.presentInterstitialAd1(vc: self ?? UIViewController())
                    }
                 
                    picker?.dismiss(animated: true, completion: {
                        [weak self] in
                        print("here api call")
                        self?.uploadPlantImage(image: photo.image)
                        
                    })
                    
                case .video(v: let v):
                    print(v)
                }
            }
        }
        
        if getFreeScan() == 2 && !isUserSubscribe() {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PremiumVC") as! PremiumVC
            vc.modalPresentationStyle = .fullScreen
            vc.isFromHome = true
            self.present(vc, animated: true, completion: nil)
            
        } else {
            setFreeScan()
            self.present(picker, animated: false, completion: {})
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


// YPImagePickerDelegate
extension CustomTabBarVC: YPImagePickerDelegate {
    func imagePickerHasNoItemsInLibrary(_ picker: YPImagePicker) {
        // PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
    }
    
    func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
        return true // indexPath.row != 2
    }
}


extension CustomTabBarVC: AdsManagerDelegate {
    func NativeAdLoad() { }
    
    func DidDismissFullScreenContent() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            
            self.presentCameraScreen()
            UserDefaults.standard.set(false, forKey: "isPresentCamera")
        }
    }
    
    func NativeAdsDidFailedToLoad() { }
}
