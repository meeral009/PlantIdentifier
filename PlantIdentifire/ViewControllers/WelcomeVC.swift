//
//  WelcomeVC.swift
//  PlantIdentifire
//
//  Created by admin on 17/11/22.
//

import UIKit

class WelcomeVC: UIViewController {
    
//MARK: - IBOutlates
@IBOutlet weak var vwGetStarted: UIView!

//MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        // Do any additional setup after loading the view.
    }
    
//MARK: - IBActionMethods

    @IBAction func btngetStartedAction(_ sender: Any) {
        
        if UserDefaults.isCheckOnBording {
            let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
            let redViewController = mainStoryBoard.instantiateViewController(withIdentifier: "CustomTabBarVC") as! CustomTabBarVC
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = redViewController
        }else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier:"OnBordingVC") as? OnBordingVC
            self.navigationController?.pushViewController(vc!, animated: true)
        }
            
    }
    
}

//MARK: - UserDEfined Function
extension WelcomeVC {
    
    func setUpUI() {
        
        self.vwGetStarted.layer.cornerRadius = 15
    }
    
}
