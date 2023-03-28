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
    // MARK: - Varibles
    
    var arrPlantModel = [Plants]()
    // getDate vise objects in single array
    var arrAfterFiltered: [Plants] = []
    // getDate vise objects in single array
    var arrAfterPlantModel: [Plants] = []
    // The table view items.
    var tableViewItems: [Plants] = []
    
    /// The ad loader. You must keep a strong reference to the GADAdLoader during the ad loading
    /// process.
    var adLoader: GADAdLoader!
    /// The height constraint applied to the ad view, where necessary.
    var heightConstraint: NSLayoutConstraint?
    /// The native ad view that is being presented.
    var googleNativeAds = GoogleNativeAds()
    let googleBannerAds = GoogleBannerAds()
    
    @IBOutlet var btnEdit: UIButton!
    
    // MARK: - IBOutlates
    
    @IBOutlet var vwTable: UITableView!
    
    @IBOutlet var noDataView: UIView!
    @IBOutlet var lblMycollection: UILabel!
    @IBOutlet var viewNativeAds: UIView! {
        didSet {
            self.viewNativeAds.isHidden = true
        }
    }
    
    // MARK: - Variables
    
    var isChecked = false
    var isAdLoded = false
    var isfav = false
    var adBannerView = GADBannerView()
    var isShowNativeAds = false
    var nativeAds: GADNativeAd?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUi()
        if let nativeAds = NATIVE_ADS {
            self.viewNativeAds.isHidden = false
            self.isShowNativeAds = true
            self.googleNativeAds.showAdsView4(nativeAd: nativeAds, view: self.viewNativeAds)
        }
        self.googleNativeAds.loadAds(self) { nativeAdsTemp in
            NATIVE_ADS = nativeAdsTemp
            if !self.isShowNativeAds {
                self.googleNativeAds.showAdsView4(nativeAd: nativeAdsTemp, view: self.viewNativeAds)
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    @objc func onEditClick(_ sender: UIButton) {
        print(self.isChecked)
        self.isChecked = !self.isChecked
        
        if self.isChecked {
            self.vwTable.setEditing(true, animated: true)
            self.btnEdit.setTitle("Done", for: .normal)
            
        } else {
            self.vwTable.setEditing(false, animated: true)
            self.btnEdit.setTitle("Edit", for: .normal)
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
        self.vwTable.register(UINib(nibName: "PlantDetiailCell", bundle: nil), forCellReuseIdentifier: "PlantDetiailCell")
        self.vwTable.register(UINib(nibName: "AdCell", bundle: nil), forCellReuseIdentifier: "AdCell")
        
        self.vwTable.separatorColor = UIColor.clear
        
        //        if self.tableViewItems.count != 0 {
        //            self.fetchData()
        //        }
        
        //  self.loadBannerAd()
        self.btnEdit.addTarget(self, action: #selector(self.onEditClick(_:)), for: .touchUpInside)
    }
    
    // Decode image from base64 String
    
    func decodeImage(base64String: String) -> UIImage {
        let dataDecoded = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters)!
        let decodedimage = UIImage(data: dataDecoded) ?? UIImage()
        return decodedimage
    }
}

// MARK: - UITableview delegate methods

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableViewItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdCell", for: indexPath) as? AdCell
            
            self.googleNativeAds.loadAds(self) { nativeAdsTemp in
                
                self.googleNativeAds.showAdsView3(nativeAd: nativeAdsTemp, view: cell?.adView ?? UIView())
            }
            
            return cell ?? UITableViewCell()
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlantDetiailCell") as! PlantDetiailCell
            cell.lblDate.text = self.tableViewItems[indexPath.row].date
            cell.namePlantlabel.text = self.tableViewItems[indexPath.row].name
            cell.familyLabel.text = self.tableViewItems[indexPath.row].family
            
            // cell.btnIsFav.isEnabled = false
            
            cell.vwImage.image = self.decodeImage(base64String: self.tableViewItems[indexPath.row].image ?? "")
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return 100.0
        } else {
            return 200.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AdsManager.shared.checkRandomAndPresentInterstitial(isRandom: true, ratio: 3, shouldMatchRandom: 1)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlantDetailsVC") as? PlantDetailsVC
        vc?.hidesBottomBarWhenPushed = true
        vc?.isFromHome = true
        Results.getPlantDetailsAPI(isShowLoader: true, id: self.tableViewItems[indexPath.row].plantId ?? "") { arrResultsModel, message in
            
            vc?.image = self.decodeImage(base64String: self.tableViewItems[indexPath.row].image ?? "")
            vc?.isChecked = self.tableViewItems[indexPath.row].isFav
            vc?.updateId = self.tableViewItems[indexPath.row].id
            vc?.resultsModelFromList = arrResultsModel
            vc?.message = message
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            
        } failure: { _, error, _ in
            self.showAlert(with: error)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // below code will delete one row - you can mange another kind of deletion here like delete from database also
        if editingStyle == .delete {
            self.deleteData(id: self.tableViewItems[indexPath.row].id ?? "", index: indexPath.row)
        }
    }
}

// MARK: - CoreData Methods

extension HomeVC {
    // Fetch data
    func fetchData() {
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
            self.noDataView.isHidden = false
        } else {
            self.noDataView.isHidden = true
        }
        if self.tableViewItems.count > 0 {
            self.tableViewItems.insert(Plants(), at: 1)
        }
        
        self.vwTable.reloadData()
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
            self.noDataView.isHidden = false
        } else {
            self.noDataView.isHidden = true
        }
        
        do {
            try context.save() // <- remember to put this :)
        } catch {}
        
        self.vwTable.reloadData()
    }
}
