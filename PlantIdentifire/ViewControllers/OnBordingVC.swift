//
//  OnBordingVC.swift
//  PlantIdentifire
//
//  Created by admin on 17/11/22.
//

import UIKit

class OnBordingVC: UIViewController {
    
//MARK: - IBOutlates
    
    @IBOutlet weak var slidesCollectionView: UICollectionView!
    
    @IBOutlet weak var vwBtn: UIView!
    
    @IBOutlet weak var btnGoOutlet: UIButton!
    @IBOutlet weak var btnSkipOutlet: UIButton!
    
    @IBOutlet weak var btnImageview: UIImageView!
    
//MARK: - Variables
    var slides : [OnboardingModel] = []
    var currentPage = 0

//MARK: - view lifecycle Methods
    
  override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        // Do any additional setup after loading the view.
    }
    
//MARK: - IBAction Method
    
    
    @IBAction func btnSkipAction(_ sender: Any) {
        UserDefaults.isCheckOnBording = false
        
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let redViewController = mainStoryBoard.instantiateViewController(withIdentifier: "CustomTabBarVC") as! CustomTabBarVC
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = redViewController
       
    }
    
    @IBAction func btnGoAction(_ sender: Any) {
        
        if currentPage == slides.count - 1 {
           // set true for avoid inbording scren.  
            UserDefaults.isCheckOnBording = true
            
            let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
            let redViewController = mainStoryBoard.instantiateViewController(withIdentifier: "CustomTabBarVC") as! CustomTabBarVC
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = redViewController
            
        }
        else {
            
            currentPage += 1
         
            self.btnGoOutlet.setTitle("Go", for: .normal)
            self.btnGoOutlet.setTitleColor(.white, for: .normal)
            self.btnImageview.isHidden = true
            let indexPath = IndexPath(item : currentPage, section: 0)
            self.slidesCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            
            self.btnSkipOutlet.isHidden = false
            
        }
    }
    
}

//MARK: - UserDefined Function
extension OnBordingVC {
    
    func setUpUI() {
        
        self.slidesCollectionView.register(UINib(nibName: "OnbordingCell", bundle: .main), forCellWithReuseIdentifier: "OnbordingCell")
        
        self.vwBtn.backgroundColor = UIColor.MyTheme.vwColor
        self.vwBtn.layer.cornerRadius = self.vwBtn.frame.size.width/2
        self.vwBtn.clipsToBounds = true
        
//        if currentPage ==  1 {
//
//        }
        
        slides = [
             
            OnboardingModel(image: UIImage(named: "plantWithScanner")!, description: "Take a photo of plant..", subDescription: "Just take a photo of the plant you want to ID, Make sure the photo is clear.") ,
            
            OnboardingModel(image: UIImage(named: "plant")!, description: "..and voila,\n there is it!", subDescription: "Your plant will be instantly recognized!") ,
        
         ]
        
    }
}

//MARK: - UICollectionview delegates method

extension OnBordingVC : UICollectionViewDelegate , UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout  {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnbordingCell", for: indexPath) as! OnbordingCell
        cell.setUp(slides[indexPath.row])
        return cell

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        currentPage = Int(scrollView.contentOffset.x  / width)
       
    }
    
}
