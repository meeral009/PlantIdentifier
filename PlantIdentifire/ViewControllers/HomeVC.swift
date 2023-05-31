//
//  HomeVC.swift
//  PlantIdentifire
//
//  Created by admin on 19/11/22.
//

import CoreData
import GoogleMobileAds
import UIKit

class HomeVC: UIViewController {

    // MARK: - IBOutlates
    @IBOutlet var btnEdit: UIButton!
    @IBOutlet var searchBarView: UIView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var plantCollectionView: UICollectionView!
    @IBOutlet var noDataView: UIView!
    @IBOutlet var editStackView: UIStackView!
    @IBOutlet var lblMycollection: UILabel!
    
    @IBOutlet var btnCancel: UIButton!

    // MARK: - Varibles
    var arrAfterPlantModel: [Plants] = []
    var tableViewItems: [Plants] = []
    var searchActive = false
    /// The ad loader. You must keep a strong reference to the GADAdLoader during the ad loading
    /// process.
    var adLoader: GADAdLoader!
    /// The height constraint applied to the ad view, where necessary.
    var heightConstraint: NSLayoutConstraint?
    /// The native ad view that is being presented.
    var googleNativeAds = GoogleNativeAds()
    let googleBannerAds = GoogleBannerAds()
   
    var isEditOn = false
  
    var isAdLoded = false
    var isfav = false
    var adBannerView = GADBannerView()
    var isShowNativeAds = false
    var nativeAds: GADNativeAd?
   
    var plantModel = PlantModel()

    var arrSelectedPlants = [Int]()
    var arrSelectedPlantIds = [String]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUi()

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            if !isUserSubscribe() {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "PremiumVC") as! PremiumVC
                vc.modalPresentationStyle = .fullScreen
                vc.isFromHome = true
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    

    @objc func onClickCancel(_ sender: UIButton) {
        self.isEditOn = false
        self.editStackView.isHidden = true
        self.arrSelectedPlants.removeAll()
        self.arrSelectedPlantIds.removeAll()
        self.plantCollectionView.reloadData()
    }
    
    
    @objc func onLongTouch(_ sender: UIGestureRecognizer) {
        self.isEditOn = true
        self.arrSelectedPlants.removeAll()
        self.arrSelectedPlantIds.removeAll ()
        self.editStackView.isHidden = false
        self.plantCollectionView.reloadData()
    }
    
    @objc func onDeleteClick(_ sender: UIButton) {
        if searchActive {
            for i in 0..<self.arrSelectedPlants.count {
                if let index = self.arrAfterPlantModel.firstIndex(where: { $0.id == self.arrSelectedPlantIds[i] }) {
                    self.deleteData(id: self.arrAfterPlantModel[index].id ?? "", index: sender.tag)
//                    self.arrSelectedPlants.removeFirst()
//                    self.arrSelectedPlantIds.removeFirst()
                }
            }
        } else {
            for i in 0..<self.arrSelectedPlants.count {
                if let index = self.tableViewItems.firstIndex(where: { $0.id == self.arrSelectedPlantIds[i] }) {
                    self.deleteData(id: self.tableViewItems[index].id ?? "", index: sender.tag)
//                    self.arrSelectedPlants.removeFirst()
//                    self.arrSelectedPlantIds.removeFirst()
                }
             
            }
        }
        self.isEditOn = false
        self.editStackView.isHidden = true
        self.plantCollectionView.reloadData()
    }
 
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if !self.isEditOn {
            DispatchQueue.main.async {
                ERProgressHud.sharedInstance.showBlurView(withTitle: "Identifying plant...")
            }
            if let indexPath = self.plantCollectionView?.indexPathForItem(at: sender.location(in: self.plantCollectionView)) {
                //Do your stuff here
                
                AdsManager.shared.checkRandomAndPresentInterstitial(isRandom: true, ratio: 3, shouldMatchRandom: 1)
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlantDetailsVC") as? PlantDetailsVC
                 vc?.hidesBottomBarWhenPushed = true
                vc?.isFromHome = true
               
                Results.getPlantDetailsAPI(isShowLoader: false, id: self.tableViewItems[indexPath.row].plantId ?? "") { arrResultsModel, message in
                    DispatchQueue.main.async {
                        ERProgressHud.sharedInstance.hide()
                    }
                    vc?.image = self.decodeImage(base64String: self.tableViewItems[indexPath.row].image ?? "")
                    vc?.isChecked = self.tableViewItems[indexPath.row].isFav
                    vc?.updateId = self.tableViewItems[indexPath.row].id
                    vc?.resultsModelFromList = arrResultsModel
                    vc?.message = message
                    DispatchQueue.main.async {
                        self.navigationController?.pushViewController(vc!, animated: true)
                    }
                    
                } failure: { _, error, _ in
                    ERProgressHud.sharedInstance.hide()
                    self.showAlert(with: error)
                }
            }
        }
    }
    
    @objc func onClickSelectPlant(_ sender: UIButton) {
        if sender.isSelected == true {
            self.arrSelectedPlants.remove(at: sender.tag)
            self.arrSelectedPlantIds.remove(at: sender.tag)
            sender.isSelected = false
        } else {
            self.arrSelectedPlants.append(sender.tag)
            if searchActive {
                self.arrSelectedPlantIds.append(self.arrAfterPlantModel[sender.tag].id ?? "")
            } else {
                self.arrSelectedPlantIds.append(self.tableViewItems[sender.tag].id ?? "")
            }
            sender.isSelected = true
        }
        self.plantCollectionView.reloadData()
    }
    
    @IBAction func onClickExitApp(_ sender: UIButton) {
        let exitPopUp = self.storyboard?.instantiateViewController(withIdentifier: "ExitAdVC") as? ExitAdVC
        exitPopUp?.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(exitPopUp!, animated: true)
    }
}

// MARK: - Userdefined Function

extension HomeVC {
    func setUpUi() {
        self.hideKeyboardWhenTappedAround()
        self.customizeSearchField()
        self.plantCollectionView.register(UINib(nibName: "PlantCell", bundle: nil), forCellWithReuseIdentifier: "PlantCell")
        self.btnEdit.addTarget(self, action: #selector(self.onDeleteClick(_:)), for: .touchUpInside)
        self.btnCancel.addTarget(self, action: #selector(onClickCancel(_:)), for: .touchUpInside)
        self.plantCollectionView.delegate = self
        self.plantCollectionView.dataSource = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.plantCollectionView.addGestureRecognizer(tap)
        self.plantCollectionView.isUserInteractionEnabled = true
    }
    
    // Decode image from base64 String
    func decodeImage(base64String: String) -> UIImage {
        let dataDecoded = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters)!
        let decodedimage = UIImage(data: dataDecoded) ?? UIImage()
        return decodedimage
    }
    
    fileprivate func customizeSearchField(){
        UISearchBar.appearance().setSearchFieldBackgroundImage(UIImage(), for: .normal)
        self.searchBar.backgroundColor = .white
        if let searchTextField = self.searchBar.value(forKey: "searchField") as? UITextField {
            searchTextField.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                searchTextField.heightAnchor.constraint(equalToConstant: 50),
                searchTextField.leadingAnchor.constraint(equalTo: self.searchBar.leadingAnchor, constant: 10),
                searchTextField.trailingAnchor.constraint(equalTo: self.searchBar.trailingAnchor, constant: -10),
                searchTextField.centerYAnchor.constraint(equalTo: self.searchBar.centerYAnchor, constant: 0)
            ])
        }
    }
}


extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchActive {
            return self.arrAfterPlantModel.count
        } else {
            return self.tableViewItems.count
        }
      
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantCell", for: indexPath) as? PlantCell
        var data = Plants()
        if searchActive {
            data = self.arrAfterPlantModel[indexPath.row]
        } else {
            data = self.tableViewItems[indexPath.row]
        }
        cell?.lblPlantName.text = data.name
        cell?.btnDelete.tag = indexPath.row
        if let family = data.family {
            cell?.lblfamilyName.text = "Family: \(family)"
        }
        if isEditOn {
            cell?.btnSelect.isHidden = false
            if self.arrSelectedPlants.contains(indexPath.row) {
                cell?.btnSelect.isSelected = true
            } else {
                cell?.btnSelect.isSelected = false
            }
        } else {
            cell?.btnSelect.isHidden = true
        }
    
        cell?.btnSelect.tag = indexPath.row
    
       
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(onLongTouch(_:)))
        longPressGesture.minimumPressDuration = 0.5
        cell?.addGestureRecognizer(longPressGesture)
        cell?.btnDelete.addTarget(self, action: #selector(onDeleteClick(_:)), for: .touchUpInside)
        cell?.btnSelect.addTarget(self, action: #selector(onClickSelectPlant(_:)), for: .touchUpInside)
        cell?.imgPlant.sd_setImage(with: URL(string: data.image ?? ""))
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 195)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
    
}

// MARK: - CoreData Methods

extension HomeVC {
    // Fetch data
    func fetchData() {
        self.presentedViewController?.dismiss(animated: true)
        self.tableViewItems.removeAll()
        
        let context: NSManagedObjectContext
        let fetchRequest: NSFetchRequest<Plants> = Plants.fetchRequest()
        // Get the context object
        if #available(iOS 10.0, *) {
            context = appDelegate.persistentContainer.viewContext
            
        } else {
            // Fallback on earlier versions
            context = appDelegate.managedObjectContext
        }
        // Fetch User list from CoreData
        if let plants = try? context.fetch(fetchRequest) {
            for data in plants as [Plants] {
                print(data)
                self.tableViewItems.append(data)
            }
        }
        
        if self.tableViewItems.count == 0 {
            self.searchBarView.isHidden = true
            self.noDataView.isHidden = false
        } else {
            self.searchBarView.isHidden = false
            self.noDataView.isHidden = true
        }
       
        self.plantCollectionView.reloadData()
    }
    
    func deleteData(id: String, index: Int) {
        let context: NSManagedObjectContext
        if #available(iOS 10.0, *) {
            context = appDelegate.persistentContainer.viewContext
            
        } else {
            // Fallback on earlier versions
            context = appDelegate.managedObjectContext
        }
        
        let fetchRequest: NSFetchRequest<Plants> = Plants.fetchRequest()
        if let id = id as? String {
            fetchRequest.predicate = NSPredicate(format: "id = %@", id as String)
        }
        
        let objects = try! context.fetch(fetchRequest)
        for obj in objects {
            context.delete(obj)
        }
        self.tableViewItems.remove(at: index)
        
        if self.tableViewItems.count == 0 {
            self.searchBarView.isHidden = true
            self.noDataView.isHidden = false
        } else {
            self.searchBarView.isHidden = false
            self.noDataView.isHidden = true
        }
        
        do {
            try context.save() // <- remember to put this :)
        } catch {}
        
        self.fetchData()
       
    }
    

}

// MARK: - Delagte Functions

extension HomeVC: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
        self.plantCollectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.text = ""
        self.arrAfterPlantModel = []
        searchActive = false
        self.searchBar.showsCancelButton = false
        self.searchBar.endEditing(true)
        self.dismiss(animated: true, completion: nil)
        self.plantCollectionView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text! == "jj"  {
            self.arrAfterPlantModel = self.tableViewItems
            self.plantCollectionView.reloadData()
        } else {
            let lowerSearchText = searchText.lowercased()

            let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            self.arrAfterPlantModel = self.tableViewItems.filter { $0.name?.lowercased().prefix(trimmed.count) ?? "" == trimmed.lowercased() || $0.family?.lowercased().prefix(trimmed.count) ?? "" == trimmed.lowercased() }
            self.plantCollectionView.reloadData()
        }
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        self.searchBar.endEditing(true)
        self.plantCollectionView.reloadData()
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
     // self.isEditOn = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        searchActive = false
        self.plantCollectionView.reloadData()
        view.endEditing(true)
    }
}


