//
//  CustomTabbarVC.swift
//  PlantIdentifire
//
//  Created by Sagar Lukhi on 28/07/23.
//

import UIKit

class CustomTabbarVC: UIViewController {

    //MARK: Outlates
    @IBOutlet weak var viewTabbar: UIView!
    @IBOutlet weak var lblHome: UILabel!
    @IBOutlet weak var lblSettings: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    
    @IBOutlet weak var tabBarHeight: NSLayoutConstraint!
    @IBOutlet var viewNativeAds: UIView! {
        didSet {
            viewNativeAds.isHidden = true
        }
    }
    
    @IBOutlet weak var imgHome: UIImageView!
    @IBOutlet weak var imgSettings: UIImageView!
    

    //MARK: Veribles
    
    var shapeLayer: CALayer?
    var googleNativeAds = GoogleNativeAds()
    var isShowNativeAds = false
    var isFirstTime = Bool()
    var isOpenInApp = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !isUserSubscribe() && isOpenInApp{
            isOpenInApp = false
            DispatchQueue.main.asyncAfter(deadline: .now()+2.0){
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "PremiumVC") as! PremiumVC
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
           
        }
    }
    

    //MARK: Methods
    
    func initView(){
        isOpenInApp = true
        addViews(index: 0)
        resetTabsAndSelect(index: 0)
        if !UIDevice.current.hasNotch{
            tabBarHeight.constant = 65
        }
        
        if let nativeAds = NATIVE_ADS {
            self.viewNativeAds.isHidden = false
            self.isShowNativeAds = true
            self.googleNativeAds.showAdsView3(nativeAd: nativeAds, view: self.viewNativeAds)
        }else{
            googleNativeAds.loadAds(self) { nativeAdsTemp in
                NATIVE_ADS = nativeAdsTemp
                if !self.isShowNativeAds{
                    self.googleNativeAds.showAdsView3(nativeAd: nativeAdsTemp, view: self.viewNativeAds)
                }
            }
        }
    }
    
    private func addShape() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = createPath()
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 0
        
        //The below 4 lines are for shadow above the bar. you can skip them if you do not want a shadow
        shapeLayer.shadowOffset = CGSize(width:0, height:0)
        shapeLayer.shadowRadius = 10
        shapeLayer.shadowColor = UIColor.gray.cgColor
        shapeLayer.shadowOpacity = 0.3
        
        if let oldShapeLayer = self.shapeLayer {
            self.viewTabbar.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
        } else {
            self.viewTabbar.layer.insertSublayer(shapeLayer, at: 0)
        }
        self.shapeLayer = shapeLayer
        self.view.layoutIfNeeded()
    }
    
    private func createPath() -> CGPath {
        let f = CGFloat(60 / 2.0) + 10
        let h = self.viewTabbar.frame.height
        let w = self.viewTabbar.frame.width
        let halfW = self.viewTabbar.frame.width/2.0
        let r = CGFloat(18)
        let path = UIBezierPath()
        path.move(to: .zero)
        
        path.addLine(to: CGPoint(x: halfW-f-(r/2.0), y: 0))
        
        path.addQuadCurve(to: CGPoint(x: halfW-f, y: (r/2.0)), controlPoint: CGPoint(x: halfW-f, y: 0))
        
        path.addArc(withCenter: CGPoint(x: halfW, y: (r/2.0)), radius: f, startAngle: .pi, endAngle: 0, clockwise: false)
        
        path.addQuadCurve(to: CGPoint(x: halfW+f+(r/2.0), y: 0), controlPoint: CGPoint(x: halfW+f, y: 0))
        
        path.addLine(to: CGPoint(x: w, y: 0))
        path.addLine(to: CGPoint(x: w, y: h))
        path.addLine(to: CGPoint(x: 0.0, y: h))
        
        return path.cgPath
    }
    
    func resetTabsAndSelect(index: Int) {
        lblHome.textColor = UIColor.gray
        lblSettings.textColor = UIColor.gray
        self.imgHome.tintColor = UIColor.gray
        self.imgSettings.tintColor = UIColor.gray
        if index == 0 {
            lblHome.textColor = UIColor.init(named: "AppColor")
            self.imgHome.tintColor = UIColor.init(named: "AppColor")
        } else if index == 1 {
            lblSettings.textColor = UIColor.init(named: "AppColor")
            self.imgSettings.tintColor = UIColor.init(named: "AppColor")
        }
    }
    
    func removeTopChildViewController() {
         if self.children.count > 0 {
             let viewControllers:[UIViewController] = self.children
                viewControllers.last?.willMove(toParent: nil)
                viewControllers.last?.removeFromParent()
                viewControllers.last?.view.removeFromSuperview()
         }
     }
    
    func addViews(index: Int) {
       
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) { [self] in
            self.removeTopChildViewController()
            self.resetTabsAndSelect(index: index)
            if index == 0 {
                self.view.backgroundColor = UIColor.black
                let tabView = self.storyboard?.instantiateViewController(withIdentifier: "HomeNewVC") as! HomeNewVC
                tabView.view.frame = self.viewContainer.bounds
                self.viewContainer.addSubview(tabView.view)
                addChild(tabView)
                tabView.didMove(toParent: self)
            } else if index == 1 {
                self.view.backgroundColor = UIColor.black
                let tabView = self.storyboard?.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
                tabView.view.frame = viewContainer.bounds
                viewContainer.addSubview(tabView.view)
                addChild(tabView)
                tabView.didMove(toParent: self)
            }
        }
    }

    //MARK: Btn Action
    
    @IBAction func actionTabClicked(_ sender: UIButton) {
        addViews(index: sender.tag)
    }
    
    @IBAction func actionCameraScan(_ sender: Any) {
        
        if getFreeScan() == 2 && !isUserSubscribe() {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PremiumVC") as! PremiumVC
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        } else {
            if !isFirstTime{
                isFirstTime = true
                AdsManager.shared.presentInterstitialAd()
            }else{
                AdsManager.shared.showInterstitialAd(false,isRandom: true,ratio: 3,shouldMatchRandom: 1)
            }
            DispatchQueue.main.asyncAfter(wallDeadline: .now(), execute: {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "CameraVC") as! CameraVC
                vc.modalPresentationStyle = .overFullScreen
                vc.topVC = self
                self.navigationController?.pushViewController(vc, animated: true)
            })
        }
    }
    
    
    
}
