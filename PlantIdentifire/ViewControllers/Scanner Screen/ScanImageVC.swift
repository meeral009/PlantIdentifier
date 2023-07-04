//
//  ScanImageVC.swift
//  PlantIdentifire
//
//  Created by Sagar Lukhi on 22/06/23.
//

import UIKit

class ScanImageVC: UIViewController {
    
    //MARK: Outlates
    
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var imgCheck1: UIImageView!
    @IBOutlet weak var imgCheck2: UIImageView!
    @IBOutlet weak var imgCheck3: UIImageView!
    
    @IBOutlet weak var loader1: UIActivityIndicatorView!
    @IBOutlet weak var loader2: UIActivityIndicatorView!
    @IBOutlet weak var loader3: UIActivityIndicatorView!
    
    @IBOutlet weak var viewBgImageScanner: UIView!
    @IBOutlet weak var imgScannerLine: UIImageView!
    
    @IBOutlet var viewNativeAds: UIView! {
        didSet {
            viewNativeAds.isHidden = true
        }
    }
    
    //MARK: Veribles
    
    var image: UIImage = UIImage() // Passed
    var plantModel = PlantModel()
    var googleNativeAds = GoogleNativeAds()
    
    //MARK: Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgView.image = image
        setDefaultUI(showLoader: 1)
       
        DispatchQueue.main.asyncAfter(wallDeadline: .now()+1.0){
            self.setDefaultUI(showLoader: 2)
            self.uploadPlantImage(image: self.image)
        }
        animateScanner()
        if let nativeAds = NATIVE_ADS {
            self.viewNativeAds.isHidden = false
            self.googleNativeAds.showAdsView3(nativeAd: nativeAds, view: self.viewNativeAds)
        }else{
            googleNativeAds.loadAds(self) { nativeAdsTemp in
                NATIVE_ADS = nativeAdsTemp
                self.googleNativeAds.showAdsView3(nativeAd: nativeAdsTemp, view: self.viewNativeAds)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    // MARK: - Methods
    
    func setDefaultUI(showLoader: Int) {
        
        imgCheck1.isHidden = true
        imgCheck2.isHidden = true
        imgCheck3.isHidden = true
        
        loader1.isHidden = true
        loader2.isHidden = true
        loader3.isHidden = true
        
        if showLoader == 1 {
            loader1.isHidden = false
        }
        if showLoader == 2 {
            imgCheck1.isHidden = false
            loader2.isHidden = false
        }
        if showLoader == 3 {
            imgCheck1.isHidden = false
            imgCheck2.isHidden = false
            loader3.isHidden = false
        }
    }
    
    func animateScanner() {
        DispatchQueue.main.async {
            func animTop(){
                UIView.animate(withDuration: 1, delay: 0, options: [.transitionFlipFromBottom], animations: { [self] in
                    imgScannerLine.frame.origin.y = 0
                    viewBgImageScanner.layoutIfNeeded()
                }, completion: {(_ completed: Bool) -> Void in
                    animBottom()
                })
            }
            
            func animBottom() {
                UIView.animate(withDuration: 1, delay: 0, options: [.curveLinear], animations: { [self] in
                    imgScannerLine.frame.origin.y = viewBgImageScanner.frame.height
                    viewBgImageScanner.layoutIfNeeded()
                }, completion: {(_ completed: Bool) -> Void in
                    animTop()
                })
            }
            animBottom()
        }
       
    }
    
    //MARK: API Callings
    
    func uploadPlantImage(image : UIImage) {
        DispatchQueue.global(qos: .userInteractive).async {
            self.plantModel.uploadPlantImage(plantImage: image, isShowLoader: false) { id in
                print("id of plant \(id)")
                setFreeScan()
                self.setDefaultUI(showLoader: 3)
                DispatchQueue.global(qos: .userInteractive).async {
                    Results.getPlantDetailsAPI(isShowLoader: false, id: id) { plantModel, message in
                        print(plantModel)
                        if message != "Not a plant." {
                            // Set data from first element of Images array from response
                            
                            if let result = plantModel.first{
                                var similarImages = [Images]()
                                var similarResults = [Results]()
                                if plantModel.count > 1 {
                                    if let plantImages = plantModel[1].images {
                                        similarImages.append(contentsOf: plantImages)
                                        
                                    }
                                    for i in 1..<plantModel.count{
                                        similarResults.append(plantModel[i])
                                    }
                                    
                                }
                                result.similar_images = similarImages
                                result.similar_result = similarResults
                                result.id = UUID().uuidString
                                if result.images?.count ?? 0 > 0{
                                    AdsManager.shared.presentInterstitialAd()
                                    DispatchQueue.main.asyncAfter(wallDeadline: .now(), execute: {
                                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlantDetailsNewVC") as! PlantDetailsNewVC
                                        vc.image = image
                                        vc.id = id
                                        vc.resultsModel = result
                                        self.navigationController?.pushViewController(vc, animated: true)
                                    })
                                }else{
                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "NoResultVC") as! NoResultVC
                                    self.navigationController?.pushViewController(vc, animated: true)
                                }
                                
                            }else{
                                DispatchQueue.main.async {
                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "NoResultVC") as! NoResultVC
                                    self.navigationController?.pushViewController(vc, animated: true)
                                }
                            }
                            
                        } else {
                            ERProgressHud.sharedInstance.hide()
                            DispatchQueue.main.async {
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "NoResultVC") as! NoResultVC
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        }
                    } failure: { _, error, _ in
                        ERProgressHud.sharedInstance.hide()
                        DispatchQueue.main.async {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "NoResultVC") as! NoResultVC
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
                
            } failure: { statuscode, error, customError in
                print(error)
                self.showAlert(with: error)
            }
        }
       
    }
    
}
