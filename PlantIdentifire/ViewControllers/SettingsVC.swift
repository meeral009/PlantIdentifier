//
//  SettingsVC.swift
//  PlantIdentifire
//
//  Created by admin on 30/11/22.
//

import UIKit

class SettingsVC: UIViewController {
    
    @IBOutlet weak var vwPrivacy: UIView!
    @IBOutlet weak var vwShareApp: UIView!
    @IBOutlet weak var vwAboutUs: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        // Do any additional setup after loading the view.
    }
    
    //MARK: - IBActionMethods
    
    @IBAction func btnPrivacyPolicy(_ sender: Any) {
        
        self.openURL(type: .privacyPolicy)
    }
    
    
    @IBAction func btnShareApp(_ sender: Any) {
        
        self.openURL(type: .shareApp)
        
    }
    

    @IBAction func btnAboutUs(_ sender: Any) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AboutUsVC") as? AboutUsVC
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
}

// MARK: - User defined functions
extension SettingsVC {
    
    func setUpUI() {
        
        self.vwPrivacy.customView()
        self.vwAboutUs.customView()
        self.vwShareApp.customView()
        
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


