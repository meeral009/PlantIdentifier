//
//  NoResultVC.swift
//  PlantIdentifire
//
//  Created by Sagar Lukhi on 22/06/23.
//

import UIKit

class NoResultVC: UIViewController {
    
    //MARK: Outlates

    //MARK: Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    //MARK: Methods

    func initView(){
        
    }
    
    //MARK: Btn Action
    
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func actionRetake(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
        delay(0.1) {
            NotificationCenter.default.post(name: NSNotification.Name("OPEN_CAMERA_NOTIFICATION"), object: nil)
        }
    }
}
