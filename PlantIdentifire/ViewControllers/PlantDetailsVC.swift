//
//  PlantDetailsVC.swift
//  PlantIdentifire
//
//  Created by admin on 25/11/22.
//

import CoreData
import SDWebImage
import UIKit

class PlantDetailsVC: UIViewController {
    // MARK: - IBOutlates
    
    @IBOutlet var sliderCollectionView: UICollectionView!
    @IBOutlet var plantImageCollectionView: UICollectionView!
  
    @IBOutlet var lblPlantName: UILabel!
    @IBOutlet var lblFamily: UILabel!
    @IBOutlet var lblauthor: UILabel!
    @IBOutlet var lblGenus: UILabel!
    
    @IBOutlet var nativeAdPlaceholder: UIView!
    @IBOutlet var adsHeightConstraint: NSLayoutConstraint!
    // MARK: - variables

    var id = ""
    var message = ""
    var image = UIImage()
    var timer = Timer()
    var arrImages = [Images]()
    var plantListImages = [Images]()
    
    var resultsModel = Results()
    var counter = 0
    
    var isChecked = false
    var updateId: String?
    var imageString: String?
    var isFromHome = false

    var isShowNativeAds = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isUserSubscribe() {
          self.nativeAdPlaceholder.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
            return .darkContent
        }
    
    @IBAction func btnBackAction(_ sender: Any) {
        if self.isFromHome {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func btnisFavAction(_ sender: UIButton) {
        self.showToast(message: "Plant Saved")
    }
}

// MARK: - Userdefine function

extension PlantDetailsVC {
    func setUpUi() {
   
        self.nativeAdPlaceholder.isHidden = true
        self.adsHeightConstraint.constant = 0
//        if !isUserSubscribe() {
//            if let nativeAds = NATIVE_ADS {
//                self.nativeAdPlaceholder.isHidden = false
//                self.isShowNativeAds = true
//                self.adsHeightConstraint.constant = 150
//                self.googleNativeAds.showAdsView4(nativeAd: nativeAds, view: self.nativeAdPlaceholder)
//            }
//
//            googleNativeAds.loadAds(self) { nativeAdsTemp in
//                NATIVE_ADS = nativeAdsTemp
//                self.nativeAdPlaceholder.isHidden = false
//                self.adsHeightConstraint.constant = 150
//                if !self.isShowNativeAds {
//                    self.googleNativeAds.showAdsView4(nativeAd: nativeAdsTemp, view: self.nativeAdPlaceholder)
//                }
//            }
//        }
        
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.changeImage), userInfo: nil, repeats: true)
        }
        
        self.sliderCollectionView.register(UINib(nibName: "SliderImageCell", bundle: nil), forCellWithReuseIdentifier: "SliderImageCell")
        self.plantImageCollectionView.register(UINib(nibName: "SliderImageCell", bundle: nil), forCellWithReuseIdentifier: "SliderImageCell")
        
        if !self.isFromHome {
            setPlantDetails(plantResult:resultsModel )
        }
        setUpData()
    }
    
    func setUpData(){
        self.lblPlantName.text = resultsModel.species?.name
        self.lblFamily.text = resultsModel.species?.family
        self.lblauthor.text = resultsModel.species?.author
        self.lblGenus.text = resultsModel.species?.genus
        
        if self.resultsModel.similar_images?.count == 0 {
            DispatchQueue.main.async {
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.plantImageCollectionView.frame.width, height: self.plantImageCollectionView.frame.height))
                label.textAlignment = .center
                label.textColor = .black
                label.text = "No Images Found"
                label.font = UIFont(name: "Montserrat-Medium", size: 22)
                self.plantImageCollectionView.backgroundView = label
                self.plantImageCollectionView.reloadData()
            }
            
        }
        self.sliderCollectionView.reloadData()
        self.plantImageCollectionView.reloadData()
    }
    
    @objc func changeImage() {
        if self.resultsModel.images?.count != 0 {
            if self.counter < self.resultsModel.images!.count {
                let index = IndexPath(item: counter, section: 0)
                self.sliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
                self.counter += 1
                
            } else {
                self.counter = 0
                let index = IndexPath(item: counter, section: 0)
                self.sliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
                self.counter = 1
            }
        } else {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.sliderCollectionView.frame.width, height: self.sliderCollectionView.frame.height))
            label.backgroundColor = UIColor(red: 81/255, green: 173/255, blue: 153/255, alpha: 1)
            label.textAlignment = .center
            label.textColor = .white
            label.text = "No Images Found"
            label.font = UIFont(name: "Montserrat-Medium", size: 22)
            sliderCollectionView.backgroundView = label
        }
    }

}

// MARK: - UICollectionview delegate method

extension PlantDetailsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.sliderCollectionView {
            return resultsModel.images?.count ?? 0
        } else {
            return resultsModel.similar_images?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SliderImageCell", for: indexPath) as! SliderImageCell
        if collectionView == self.sliderCollectionView {
            setImageFromUrl(resultsModel.images?[indexPath.row].o ?? "", img: cell.vwImage, placeHolder: "")
        } else {
            cell.layer.cornerRadius = 15
            setImageFromUrl(resultsModel.similar_images?[indexPath.row].o ?? "", img: cell.vwImage, placeHolder: "")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.sliderCollectionView {
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        } else {
            if UIDevice.current.userInterfaceIdiom == .phone {
                return CGSize(width: collectionView.frame.width / 4 - 3, height: 100)
            } else {
                return CGSize(width: collectionView.frame.width / 4 - 3, height: 200)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
   
}
