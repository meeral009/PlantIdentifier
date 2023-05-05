//
//  IdentifyOptionsVC.swift
//  PlantIdentifire
//
//  Created by Miral's iMac on 29/04/23.
//

import UIKit
import YPImagePicker

class IdentifyOptionsVC: UIViewController {
    // MARK: - Variables
    var selectedItems = [YPMediaItem]()
    
    lazy var selectedImageV : UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.45))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    var plantModel = PlantModel()
    var mode: YPPickerScreen = .photo
   
    var isScanningModeOn = false
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
        self.mode = .photo
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            UserDefaults.standard.set(true, forKey: "isPresentCamera")
            AdsManager.shared.presentInterstitialAd1(vc: self)
        }
        
        if isUserSubscribe() {
            //self.presentCameraScreen()
            self.presentCameraScreen(screen: .photo)
        }
    }

    @IBAction func onClickCamera(_ sender: UIButton) {
        self.isScanningModeOn = false
        self.mode = .photo
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            UserDefaults.standard.set(true, forKey: "isPresentCamera")
            AdsManager.shared.presentInterstitialAd1(vc: self)
        }
        
        if isUserSubscribe() {
            //self.presentCameraScreen()
            self.presentCameraScreen(screen: .photo)
        }
    }
    
    
    @IBAction func onClickGallery(_ sender: UIButton) {
        self.mode = .library
        self.isScanningModeOn = false
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            UserDefaults.standard.set(true, forKey: "isPresentCamera")
            AdsManager.shared.presentInterstitialAd1(vc: self)
        }
        
        if isUserSubscribe() {
            //self.presentCameraScreen()
            self.presentCameraScreen(screen: .library)
        }
    }
    
    @IBAction func onClickDismiss(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

// MARK: - User defined functions
extension IdentifyOptionsVC {
    // Present camera and gallery on screen.
    func presentCameraScreen(screen: YPPickerScreen) {
       
        var config = YPImagePickerConfiguration()
        
        /* Choose what media types are available in the library. Defaults to `.photo` */
        config.library.mediaType = .photo
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
        config.screens = [screen]
        
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
                        if self?.isScanningModeOn == true {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                let vc = self?.storyboard?.instantiateViewController(withIdentifier: "PhotoScanVC") as! PhotoScanVC
                                vc.modalPresentationStyle = .fullScreen
                                vc.capturedImage = photo.image
                                self?.present(vc, animated: true, completion: nil)
                            }
                        } else {
                            self?.uploadPlantImage(image: photo.image)
                        }
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
            self.present(picker, animated: false, completion: {})
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
            // self.navigationController?.pushViewController(vc!, animated: false)
            self.present(vc ?? UIViewController(), animated: true)
            
        } failure: { statuscode, error, customError in
            print(error)
            self.showAlert(with: error)
        }
    }

}

// MARK: - Delagte Functions
extension IdentifyOptionsVC: YPImagePickerDelegate {
    func imagePickerHasNoItemsInLibrary(_ picker: YPImagePicker) {
        // PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
    }
    
    func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
        return true // indexPath.row != 2
    }
}

extension IdentifyOptionsVC: AdsManagerDelegate {
    func NativeAdLoad() { }
    
    func DidDismissFullScreenContent() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            self.presentCameraScreen()
            self.presentCameraScreen(screen: self.mode)
            UserDefaults.standard.set(false, forKey: "isPresentCamera")
        }
    }
    
    func NativeAdsDidFailedToLoad() { }
}
