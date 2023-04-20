//
//  SettingsVC.swift
//  PlantIdentifire
//
//  Created by admin on 30/11/22.
//

import UIKit

class SettingsVC: UIViewController {
    
    @IBOutlet var imgGif: UIView!
    @IBOutlet var lblVersion: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
    
        
    }
    //MARK: - IBActionMethods
    
    @IBAction func btnPrivacyPolicy(_ sender: Any) {
        
        self.openURL(type: .privacyPolicy)
    }
    
    
    @IBAction func btnShareApp(_ sender: Any) {
        
        self.openURL(type: .shareApp)
        
    }
    

    @IBAction func onClickPremium(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PremiumVC") as! PremiumVC
        vc.modalPresentationStyle = .fullScreen
        vc.isFromHome = false
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btnAboutUs(_ sender: Any) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AboutUsVC") as? AboutUsVC
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
    @IBAction func btnRateUs(_ sender: Any) {
        let REVIEW_LINK         = "https://itunes.apple.com/app/id\("1660916701")?mt=8&action=write-review"
        if let url = URL.init(string: REVIEW_LINK){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
    }
    
}

// MARK: - User defined functions
extension SettingsVC {
    
    func setUpUI() {
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] {
                self.lblVersion.text = "\("Version") \(appVersion)"
        }
        
        
      
        if let imageview = UIImageView.fromGif(frame: self.imgGif.frame, resourceName: "gift") {
            self.imgGif.addSubview(imageview)
            imageview.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageview.topAnchor.constraint(equalTo:   self.imgGif.topAnchor, constant: 0.0),
                imageview.leadingAnchor.constraint(equalTo:   self.imgGif.leadingAnchor, constant: 0.0),
                imageview.trailingAnchor.constraint(equalTo:   self.imgGif.trailingAnchor, constant: 0.0),
                imageview.bottomAnchor.constraint(equalTo:   self.imgGif.bottomAnchor, constant: 0.0),
            ])
            imageview.startAnimating()
        }
       
        
    }

    // Open url in web
    func openURL(type: URLTypes) {
        if let url = URL(string: type.rawValue) {
            UIApplication.shared.open(url)
        }
    }
    
    func shareApp(type: URLTypes) {
        
        if let urlStr = NSURL(string: type.rawValue) {
            let objectsToShare = [urlStr]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

            if UIDevice.current.userInterfaceIdiom == .pad {
                
                if let popup = activityVC.popoverPresentationController {
                    popup.sourceView = self.view
                    popup.sourceRect = CGRect(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 4, width: 0, height: 0)
                }
                
            }
            self.present(activityVC, animated: true, completion: nil)
        }
    }
   
}


