//
//  CropImageVC.swift
//  PlantIdentifire
//
//  Created by Sagar Lukhi on 21/06/23.
//

import IGRPhotoTweaks

import UIKit
import HorizontalDial

class CropImageVC : IGRPhotoTweakViewController {
    
//    MARK: Outlates
    
    @IBOutlet var btnBack:UIButton!
    @IBOutlet weak var btncrop: UIButton!
    @IBOutlet weak var btnrotate: UIButton!
    @IBOutlet weak var cropView: UIStackView!
    @IBOutlet weak fileprivate var angleLabel: UILabel?
    @IBOutlet var btncropoption: [UIButton]!
    @IBOutlet weak var btnreset: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var Headerhieghtconst: NSLayoutConstraint!
    @IBOutlet weak fileprivate var horizontalDial: HorizontalDial? {
        didSet {
            self.horizontalDial?.migneticOption = .none
            self.horizontalDial?.verticalAlign = "bottom"
        }
    }
    
    //MARK: Veribles
    
    var selectedPhoto = UIImage()
    
    
    // MARK: - Life Cicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
       initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.layoutIfNeeded()
        UIApplication.shared.statusBarStyle = .lightContent
    }

    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .darkContent
    }
    //MARK: Methods
    
    func initView(){
        self.delegate = self
        Headerhieghtconst.constant = !UIDevice.current.hasNotch ? 70 : 90
        self.selectedPhoto = self.image
        
        setupAngleLabelValue(radians: 0.0)
      
        self.onCropAction(self.btncrop)
        self.setCropAspectRect(aspect: "1:1")
    }
    
    
    //MARK: - BTNS ACTIONS
    
    @IBAction func onCropAction(_ sender: UIButton) {
        if !btncrop.isSelected{
            self.cropView.isHidden = false
            self.horizontalDial!.isHidden = true
            
            btncrop.isSelected = true
            btnrotate.isSelected = false
            
            self.btncrop.tintColor = UIColor(named: "AppColor")
            self.btnrotate.tintColor =  UIColor.white
        }
    }
    
    @IBAction func onRotateAction(_ sender: UIButton) {
        if !btnrotate.isSelected{
            
            self.horizontalDial!.isHidden = false
            self.cropView.isHidden = true
            
            btncrop.isSelected = false
            btnrotate.isSelected = true
            
            self.btnrotate.tintColor = UIColor(named: "AppColor")
            self.btncrop.tintColor =  UIColor.white
        }
    }
    
    @IBAction func onCropOptionsAction(_ sender: UIButton) {
        
        self.btncropoption.forEach({
            $0.setTitleColor(UIColor.white, for: .normal)
        })
        sender.setTitleColor(UIColor(named: "AppColor"), for: .normal)
        if sender.tag == 0{
            self.setCropAspectRect(aspect: "1:1")
        }else if sender.tag == 1{
            self.setCropAspectRect(aspect: "3:4")
        }else if sender.tag == 2{
            self.resetAspectRect()
        }else if sender.tag == 3{
            self.setCropAspectRect(aspect: "4:3")
        }else if sender.tag == 4{
            self.setCropAspectRect(aspect: "9:16")
        }
    }
    
    fileprivate func setupAngleLabelValue(radians: CGFloat) {
        let intDegrees = IGRRadianAngle.toDegrees(radians)
        self.angleLabel?.text = String(format: "%.1f", intDegrees)
    }
    
    // MARK: - Rotation
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context) in
            self.view.layoutIfNeeded()
        }) { (context) in
            //
        }
    }
    
    // MARK: - Actions

    @IBAction func onTouchResetButton(_ sender: UIButton) {
        self.horizontalDial?.value = 0.0
        setupAngleLabelValue(radians: 0.0)
        self.resetView()
    }
    
    @IBAction func onBackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
  
    @IBAction func onSelectImageAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScanImageVC") as! ScanImageVC
        vc.image = selectedPhoto
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

extension CropImageVC : HorizontalDialDelegate, IGRPhotoTweakViewControllerDelegate{
    
    func horizontalDialDidValueChanged(_ horizontalDial: HorizontalDial) {
        if horizontalDial.tag == 0{
            let degrees = horizontalDial.value
            let radians = IGRRadianAngle.toRadians(CGFloat(degrees))
            
            self.setupAngleLabelValue(radians: radians)
            self.changeAngle(radians: radians)
        }else{
            
        }
    }
    
    func horizontalDialDidEndScroll(_ horizontalDial: HorizontalDial) {
        self.stopChangeAngle()
    }
    
    func photoTweaksControllerDidCancel(_ controller: IGRPhotoTweakViewController) {
        
    }
    
    func photoTweaksController(_ controller: IGRPhotoTweakViewController, didFinishWithCroppedImage croppedImage: UIImage) {
        self.selectedPhoto = croppedImage
    }
    
}
