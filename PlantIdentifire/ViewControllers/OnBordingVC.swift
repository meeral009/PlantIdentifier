//
//  OnBordingVC.swift
//  PlantIdentifire
//
//  Created by admin on 17/11/22.
//

import UIKit
import GoogleMobileAds

class OnBordingVC: UIViewController {
    
//MARK: - IBOutlates
    @IBOutlet weak var slidesCollectionView: UICollectionView!
    @IBOutlet weak var btnGoOutlet: UIButton!
    @IBOutlet weak var btnSkipOutlet: UIButton!
   
    @IBOutlet var pageControl: UIPageControl!
    //MARK: - Variables
    var currentPage = 0
    // Interstitial Ad
    var interstitialAd: GADInterstitialAd?
    
    var isScrolling: Bool = false

//MARK: - view lifecycle Methods
    
  override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        self.loadInterstitialAd()
        // Do any additional setup after loading the view.
    }
    
//MARK: - IBAction Method
    
    
    @IBAction func btnSkipAction(_ sender: Any) {
      //  UserDefaults.isCheckOnBording = false
        UserDefaults.isCheckOnBording = true
        // Load Interstitial Ad
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if self.interstitialAd != nil {
                self.interstitialAd?.present(fromRootViewController: self)
            } else {
                print("Ad wasn't ready")
            }
        }
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let redViewController = mainStoryBoard.instantiateViewController(withIdentifier: "CustomTabBarVC") as! CustomTabBarVC
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = redViewController
       
    }
    
    @IBAction func btnGoAction(_ sender: Any) {
        isScrolling = false
        if currentPage == 2 {
            self.setScrollChanges()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if self.interstitialAd != nil {
                    self.interstitialAd?.present(fromRootViewController: self)
                } else {
                    print("Ad wasn't ready")
                }
            }
            let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
            let redViewController = mainStoryBoard.instantiateViewController(withIdentifier: "CustomTabBarVC") as! CustomTabBarVC
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = redViewController
            
        } else {
           
            self.setScrollChanges()

            let indexPath = IndexPath(item : currentPage, section: 0)
         //   self.slidesCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            self.slidesCollectionView.reloadData()
            self.btnSkipOutlet.isHidden = false
            
        }
    }
    
    
    func setScrollChanges() {
        
        print("Current Index: \(self.currentPage)")
        
        if !isScrolling {
            if currentPage != 2 {
                currentPage += 1
                pageControl.currentPage = currentPage
            } else {
                self.currentPage = 2
            }
        }
        
        if currentPage == 2 {
            // set true for avoid inbording scren.
             self.currentPage = 2
             pageControl.currentPage = currentPage
             UserDefaults.isCheckOnBording = true
             self.btnGoOutlet.setTitle("Get Started", for: .normal)
  
        } else {
            self.btnGoOutlet.setTitle("Next", for: .normal)
        }
        
        self.slidesCollectionView.reloadData()
    }
    
}

//MARK: - UserDefined Function
extension OnBordingVC {
    
    func setUpUI() {
        self.slidesCollectionView.register(UINib(nibName: "OnbordingCell", bundle: .main), forCellWithReuseIdentifier: "OnbordingCell")
    }
}

//MARK: - UICollectionview delegates method

extension OnBordingVC : UICollectionViewDelegate , UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout  {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnbordingCell", for: indexPath) as! OnbordingCell
        if currentPage == 0 {
            cell.view1.isHidden = false
            cell.view2.isHidden = true
            cell.view3.isHidden = true
        } else if currentPage == 1 {
            cell.view1.isHidden = true
            cell.view2.isHidden = false
            cell.view3.isHidden = true
        } else {
            cell.view1.isHidden = true
            cell.view2.isHidden = true
            cell.view3.isHidden = false
        }
        return cell

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.isScrolling = true
        let width = scrollView.frame.width
        if isScrolling {
            currentPage = Int(scrollView.contentOffset.x  / width)
            self.pageControl.currentPage = currentPage
        }
        self.setScrollChanges()
    }

}
// MARK: - Load Interstitial ad
extension OnBordingVC: GADFullScreenContentDelegate {
    func loadInterstitialAd() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: adMob.interstitialAdID.rawValue,
                               request: request,
                               completionHandler: { [self] ad, error in
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                return
            }
            
            if let ad = ad {
                self.interstitialAd = ad
            }
        })
    }
}
