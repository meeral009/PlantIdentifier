//
//  PhotoScanVC.swift
//  PlantIdentifire
//
//  Created by Miral's iMac on 29/04/23.
//

import UIKit
import Lottie

class PhotoScanVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet var mainImage: UIImageView!
    @IBOutlet var animationView: LottieAnimationView!
    
    // MARK: - Variables
    var plantModel = PlantModel()
    var capturedImage = UIImage()
}

// MARK: - View life cycle
extension PhotoScanVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUI()
    }
}

// MARK: - Actions
extension PhotoScanVC {
    @IBAction func onClickDismiss(_ sender: UIButton) {
        
    }
}

// MARK: - User defined functions
extension PhotoScanVC {
    func setUI() {
        self.animationView.contentMode = .scaleAspectFill
        self.animationView.loopMode = .loop
        self.animationView.animationSpeed = 0.5
        self.animationView.play()
        
        self.mainImage.image = self.capturedImage
        
        self.uploadPlantImage(image: self.capturedImage)
    }
    
    
    // Upload Image api call
    func uploadPlantImage(image : UIImage) {
        
        self.plantModel.uploadPlantImage(plantImage: image, isShowLoader: true) { id in
            self.animationView.pause()
            print("id of plant \(id)")
            setFreeScan()
          
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlantDetailsVC") as? PlantDetailsVC
            vc?.image = image
            vc?.id = id
            vc?.modalPresentationStyle = .fullScreen
            self.dismiss(animated:  true, completion:  {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.present(vc ?? UIViewController(), animated: true)
                }
            })
        } failure: { statuscode, error, customError in
            print(error)
            self.showAlert(with: error)
        }
    }
}

// MARK: - Delagte Functions
extension PhotoScanVC {
    
}
