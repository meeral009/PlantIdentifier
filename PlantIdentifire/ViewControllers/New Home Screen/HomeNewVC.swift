//
//  HomeNewVC.swift
//  PlantIdentifire
//
//  Created by Sagar Lukhi on 31/07/23.
//

import UIKit
import collection_view_layouts

class HomeNewVC: UIViewController {
    
    //MARK: Outlate
    
    @IBOutlet weak var txtSearchPlants: UITextField!
    @IBOutlet weak var plantsCV: UICollectionView!
    @IBOutlet weak var viewNoList: UIView!
    @IBOutlet weak var imgBack: UIImageView!
    
    //MARK: Veribles
    var tempPlants = [Results]()
    var plantsList = [Results]()
    
    
    //MARK: Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        fetchData()
    }

    //MARK: Methods
    
    func initView(){
        if UIDevice.current.isPad{
            self.imgBack.image = UIImage.init(named: "home_ipad")
        }else{
            if !UIDevice.current.hasNotch{
                self.imgBack.image = UIImage.init(named: "home_iphone")
            }
        }
        self.plantsCV.register(UINib(nibName: "PlantCell", bundle: nil), forCellWithReuseIdentifier: "PlantCell")
        self.plantsCV.delegate = self
        self.plantsCV.dataSource = self
        
        let layout: BaseLayout = PinterestLayout()
        layout.delegate = self
        layout.cellsPadding = ItemsPadding(horizontal: 10, vertical: 10)
        txtSearchPlants.delegate = self
        plantsCV.collectionViewLayout = layout
        addDoneButtonOnKeyboard()
        
    }
    
    func fetchData() {
        plantsList = getPlantDetails()
        tempPlants = getPlantDetails()
        if self.plantsList.count == 0 {
            self.viewNoList.isHidden = false
            self.plantsCV.isHidden = true
        } else {
            self.viewNoList.isHidden = true
            self.plantsCV.isHidden = false
        }
        self.plantsCV.reloadData()
    }
    
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        txtSearchPlants.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction(){
        txtSearchPlants.resignFirstResponder()
    }
    
    //MARK: Btn Actions
    
    @IBAction func actionScanPlant(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CameraVC") as! CameraVC
        vc.modalPresentationStyle = .overFullScreen
        vc.topVC = self
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
extension HomeNewVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,LayoutDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return plantsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantCell", for: indexPath) as? PlantCell
        let data = plantsList[indexPath.row]
        cell?.lblPlantName.text = data.species?.name
        cell?.btnDelete.tag = indexPath.row
        if let family = data.species?.family {
            cell?.lblfamilyName.text = "Family: \(family)"
        }
     
        cell?.btnSelect.tag = indexPath.row
        cell?.imgPlant.sd_setImage(with: URL(string: data.images?.first?.o ?? ""))
        cell?.btnSelect.addTarget(self, action: #selector(actionSelect( _:)), for: .touchUpInside)
        return cell ?? UICollectionViewCell()
    }
    
    @objc func actionSelect(_ sender:UIButton){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            if let index = self.tempPlants.firstIndex(where: { $0.id ?? "" == self.plantsList[sender.tag].id ?? ""}) {
                self.tempPlants.remove(at: index)
            }
            self.plantsList.remove(at: [sender.tag])
            savePlantsList(plantResult: self.plantsList)
            self.fetchData()
        }))
        alert.addAction(UIAlertAction(title: "Share", style: .default, handler: { action in
            self.sharePlant(sender)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            
        }))
        alert.popoverPresentationController?.sourceRect = sender.bounds
        alert.popoverPresentationController?.sourceView = sender
        self.present(alert, animated: true, completion: nil)
    }
    
    func sharePlant(_ sender:UIButton){
        let objectsToShare = [self.plantsList[sender.tag].images,self.plantsList[sender.tag].species?.name ?? "",self.plantsList[sender.tag].species?.family ?? "",self.plantsList[sender.tag].species?.commonNames ?? "",self.plantsList[sender.tag].species?.author ?? "",self.plantsList[sender.tag].species?.genus ?? ""] as [Any]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            if let popup = activityVC.popoverPresentationController {
                popup.sourceView = sender
                popup.sourceRect = sender.bounds
            }
            
        }
        self.present(activityVC, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (collectionView.frame.width-48)/2, height: (collectionView.frame.width-48)/1.2)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        AdsManager.shared.showInterstitialAd(false,isRandom: true,ratio: 3,shouldMatchRandom: 1)
        DispatchQueue.main.asyncAfter(wallDeadline: .now()+0.1){
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlantDetailsNewVC") as? PlantDetailsNewVC
            vc?.hidesBottomBarWhenPushed = true
            vc?.isFromHome = true
            vc?.resultsModel = self.plantsList[indexPath.row]
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        
    }
    
    func cellSize(indexPath: IndexPath) -> CGSize {
        if (indexPath.row+1) % 2 == 0{
            return CGSize(width: (self.plantsCV.frame.width-48)/2, height: (self.plantsCV.frame.width-48)/1.3)
        }else{
            return CGSize(width: (self.plantsCV.frame.width-48)/2, height: (self.plantsCV.frame.width-48)/1)
        }
    }
    
}

extension HomeNewVC : UITextFieldDelegate{
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        if txtSearchPlants.text?.trimmingCharacters(in: .whitespaces).count ?? 0 > 0{
            self.plantsList = self.tempPlants.filter { ($0.species?.name?.lowercased() ?? "").contains(txtSearchPlants.text?.lowercased() ?? "") || ($0.species?.family?.lowercased() ?? "").contains(txtSearchPlants.text?.lowercased() ?? "")}
            self.plantsCV.reloadData()
        }else{
            self.plantsList = self.tempPlants
            self.plantsCV.reloadData()
        }
    }
    
}
