//
//  PlantDetailsNewVC.swift
//  PlantIdentifire
//
//  Created by Sagar Lukhi on 30/06/23.
//

import UIKit

class PlantDetailsNewVC: UIViewController {
    //MARK: Outlates
    @IBOutlet var sliderCV: UICollectionView!{
        didSet{
            sliderCV.delegate = self
            sliderCV.dataSource = self
            sliderCV.register(UINib(nibName: "SliderImageCell", bundle: nil), forCellWithReuseIdentifier: "SliderImageCell")
        }
    }
    @IBOutlet var plantImageCV: UICollectionView!{
        didSet{
            plantImageCV.delegate = self
            plantImageCV.dataSource = self
            plantImageCV.register(UINib(nibName: "SimilerImageCell", bundle: nil), forCellWithReuseIdentifier: "SimilerImageCell")
        }
    }
    
    @IBOutlet weak var viewTop: UIView!
    
    @IBOutlet var lblPlantName: UILabel!
    @IBOutlet var lblFamily: UILabel!
    @IBOutlet var lblauthor: UILabel!
    @IBOutlet var lblGenus: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet var viewNativeAds: UIView! {
        didSet {
            viewNativeAds.isHidden = true
        }
    }
    
    //MARK: Veribles
    
    var id = ""
    var message = ""
    var image = UIImage()
    var timer = Timer()
    var arrImages = [Images]()
    var plantListImages = [Images]()
    
    var resultsModel = Results()
    var counter = 0
    var index = 0
    var isFromHome = false
    var googleNativeAds = GoogleNativeAds()

    //MARK: Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    //MARK: Methods

    func initView(){
        DispatchQueue.main.async {
            self.viewTop.round(corners: [.bottomLeft,.bottomRight], radius: 30)
        }
        if !self.isFromHome {
            setPlantDetails(plantResult:resultsModel )
        }
        setUpData()
        self.timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.changeImage), userInfo: nil, repeats: true)
        if let nativeAds = NATIVE_ADS {
            self.viewNativeAds.isHidden = false
            self.googleNativeAds.showAdsView1(nativeAd: nativeAds, view: self.viewNativeAds)
        }else{
            googleNativeAds.loadAds(self) { nativeAdsTemp in
                NATIVE_ADS = nativeAdsTemp
                self.googleNativeAds.showAdsView1(nativeAd: nativeAdsTemp, view: self.viewNativeAds)
            }
        }
        
    }
    
    func setUpData(){
        self.lblPlantName.text = resultsModel.species?.name
        self.lblFamily.text = resultsModel.species?.family
        self.lblauthor.text = resultsModel.species?.author
        self.lblGenus.text = resultsModel.species?.genus
        pageControl.numberOfPages = resultsModel.images?.count ?? 0
        pageControl.currentPage = 0
        self.sliderCV.reloadData()
        self.plantImageCV.reloadData()
    }
    
    @objc func changeImage() {
        if self.resultsModel.images?.count != 0 {
            if self.counter < self.resultsModel.images!.count {
                let index = IndexPath(item: counter, section: 0)
                self.sliderCV.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
                pageControl.currentPage = self.counter
                self.counter += 1
                
            } else {
                self.counter = 0
                let index = IndexPath(item: counter, section: 0)
                self.sliderCV.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
                pageControl.currentPage = self.counter
                self.counter = 1
                
            }
        }
        
    }
    
    //MARK: Btn Action
    
    @IBAction func btnBackAction(_ sender: Any) {
        if self.isFromHome {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
}
// MARK: - UICollectionview delegate method

extension PlantDetailsNewVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.sliderCV {
            return resultsModel.images?.count ?? 0
        } else {
            return resultsModel.similar_result?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.sliderCV {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SliderImageCell", for: indexPath) as! SliderImageCell
            setImageFromUrl(resultsModel.images?[indexPath.row].o ?? "", img: cell.vwImage, placeHolder: "")
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SimilerImageCell", for: indexPath) as! SimilerImageCell

            setImageFromUrl(resultsModel.similar_result?[indexPath.row].images?.first?.m ?? "", img: cell.imgPreview, placeHolder: "")
            cell.lblTittle.text = resultsModel.similar_result?[indexPath.row].species?.name
            cell.lblDescription.text = resultsModel.similar_result?[indexPath.row].species?.family
            
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.sliderCV {
            return CGSize(width: self.view.frame.width, height: collectionView.frame.height)
        } else {
            return CGSize(width: collectionView.frame.width/2.5, height: collectionView.frame.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == self.sliderCV{
            counter = indexPath.row
            pageControl.currentPage = self.counter
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == self.sliderCV{
            if self.counter < indexPath.row{
                self.index = indexPath.row-1
            }else{
                if self.counter > indexPath.row{
                    self.index = indexPath.row+1
                }
            }
            counter = self.index
            pageControl.currentPage = self.counter
        }
       
    }
    
}
