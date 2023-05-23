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
    @IBOutlet var lblMycollection: UILabel!
//    @IBOutlet var viewNativeAds: UIView! {
//        didSet {
//            self.viewNativeAds.isHidden = true
//        }
//    }
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchData()
        
//        if isUserSubscribe() {
//            NATIVE_ADS = nil
//            self.viewNativeAds.isHidden = true
//        }
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
        
        
//        if !isUserSubscribe() {
//            if let nativeAds = NATIVE_ADS {
//                self.viewNativeAds.isHidden = false
//                self.isShowNativeAds = true
//                self.googleNativeAds.showAdsView4(nativeAd: nativeAds, view: self.viewNativeAds)
//            }
//        }
       
    }
    
    @objc func onEditClick(_ sender: UIButton) {
                            self.isEditOn.toggle()
        if isEditOn {
            self.btnEdit.setTitle("Done", for: .normal)
        } else {
            self.btnEdit.setTitle("Edit", for: .normal)
        }
        self.plantCollectionView.reloadData()
    }
    
    
    @objc func onLongTouch(_ sender: UIGestureRecognizer) {
        self.isEditOn.toggle()
        self.plantCollectionView.reloadData()
    }
    
    @objc func onDeleteClick(_ sender: UIButton) {
        if searchActive {
            self.deleteData(id: self.arrAfterPlantModel[sender.tag].id ?? "", index: sender.tag)
        } else {
            self.deleteData(id: self.tableViewItems[sender.tag].id ?? "", index: sender.tag)
        }
    }
 
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
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
        self.btnEdit.addTarget(self, action: #selector(self.onEditClick(_:)), for: .touchUpInside)
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
//        if isEditOn {
            cell?.btnDelete.isHidden = false
//        } else {
//            cell?.btnDelete.isHidden = true
//        }
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(onLongTouch(_:)))
        longPressGesture.minimumPressDuration = 2
        cell?.addGestureRecognizer(longPressGesture)
        cell?.btnDelete.addTarget(self, action: #selector(onDeleteClick(_:)), for: .touchUpInside)
        cell?.imgPlant.image = self.decodeImage(base64String: data.image ?? "")
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
        
        self.plantCollectionView.reloadData()
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


