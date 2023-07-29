//
//  AboutUsVC.swift
//  PlantIdentifire
//
//  Created by admin on 07/12/22.
//

import UIKit

class AboutUsVC: UIViewController {
    
    @IBOutlet weak var vwImage: UIImageView!
    @IBOutlet weak var lblVersion: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func btnback(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
  
    }
    

}
extension AboutUsVC {
    
    func setUpUI(){
        
        vwImage.layer.cornerRadius = 15
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] {
                self.lblVersion.text = "\("Version") \(appVersion)"
        }
    }
}
