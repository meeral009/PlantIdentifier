//
//  PlantDetailsVC.swift
//  PlantIdentifire
//
//  Created by admin on 25/11/22.
//

import CoreData
import GoogleMobileAds
import SDWebImage
import UIKit

class PlantDetailsVC: UIViewController {
    // MARK: - IBOutlates
    
    @IBOutlet var sliderCollectionView: UICollectionView!
    @IBOutlet var plantImageCollectionView: UICollectionView!
  
    @IBOutlet var lblPlantName: UILabel!
    @IBOutlet var lblFamily: UILabel!
    @IBOutlet var lblauthor: UILabel!
    @IBOutlet var lblGenus: UILabel!
    
    @IBOutlet var nativeAdPlaceholder: UIView!
    @IBOutlet var adsHeightConstraint: NSLayoutConstraint!
    // MARK: - variables

    var id = ""
    var message = ""
    var image = UIImage()
    var timer = Timer()
    var arrImages = [Images]()
    var plantListImages = [Images]()
    
    var resultsModelFromList = [Results]()
    var counter = 0
    
    var isChecked = false
    var updateId: String?
    var imageString: String?
    var isFromHome = false

    var isShowNativeAds = false
    var googleNativeAds = GoogleNativeAds()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isUserSubscribe() {
          self.nativeAdPlaceholder.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        if self.isFromHome {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func btnisFavAction(_ sender: UIButton) {
        self.showToast(message: "Plant Saved")
    }
}

// MARK: - Userdefine function

extension PlantDetailsVC {
    func setUpUi() {
   
        self.nativeAdPlaceholder.isHidden = true
        if !self.isFromHome {
            ERProgressHud.sharedInstance.showBlurView(withTitle: "Identifying plant...")
            self.gatePlantDetailAPI(id: self.id)
        }
        
        if let nativeAds = NATIVE_ADS {
            self.nativeAdPlaceholder.isHidden = false
            self.isShowNativeAds = true
            self.googleNativeAds.showAdsView4(nativeAd: nativeAds, view: self.nativeAdPlaceholder)
        }

        googleNativeAds.loadAds(self) { nativeAdsTemp in
            NATIVE_ADS = nativeAdsTemp
            self.nativeAdPlaceholder.isHidden = false
            if !self.isShowNativeAds {
                self.googleNativeAds.showAdsView4(nativeAd: nativeAdsTemp, view: self.nativeAdPlaceholder)
            }
        }

        if isUserSubscribe() {
            self.adsHeightConstraint.priority = UILayoutPriority(rawValue: 749)
            self.adsHeightConstraint.constant = 0
        }
    
    
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.changeImage), userInfo: nil, repeats: true)
        }
        
        self.sliderCollectionView.register(UINib(nibName: "SliderImageCell", bundle: nil), forCellWithReuseIdentifier: "SliderImageCell")
        self.plantImageCollectionView.register(UINib(nibName: "SliderImageCell", bundle: nil), forCellWithReuseIdentifier: "SliderImageCell")
        
        if self.isFromHome {
            self.setDataFromList(plantModel: self.resultsModelFromList)
        }
    
    }
    
    @objc func changeImage() {
        if self.arrImages.count != 0 {
          
            if self.counter < self.arrImages.count {
                let index = IndexPath(item: counter, section: 0)
                self.sliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
                self.counter += 1
                
            } else {
                self.counter = 0
                let index = IndexPath(item: counter, section: 0)
                self.sliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
                self.counter = 1
            }
        } else {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.sliderCollectionView.frame.width, height: self.sliderCollectionView.frame.height))
            label.backgroundColor = UIColor(red: 81/255, green: 173/255, blue: 153/255, alpha: 1)
            label.textAlignment = .center
            label.textColor = .white
            label.text = "No Images Found"
            label.font = UIFont(name: "Montserrat-Medium", size: 22)
            sliderCollectionView.backgroundView = label
        }
    }

    
    // show current date
    func getCurrentShortDate() -> String {
        let todaysDate = NSDate()
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM,yyyy"
        let DateInFormat = dateFormatter.string(from: todaysDate as Date)
        return DateInFormat
    }
    
    // set the data for save to core.
    func setPlantdata(plant: Plants, name: String, description: String, family: String, image: String, isfav: Bool, id: String) {
        plant.id = UUID().uuidString
        self.updateId = plant.id
        plant.name = name
        plant.desc = description
        plant.image = image
        plant.family = family
        plant.date = self.getCurrentShortDate()
        plant.isFav = isfav
        plant.plantId = id
    }
    
    // set update data for isfav logic
    func setEditData(plant: Plants) {
        plant.id = self.updateId
        plant.name = self.lblPlantName.text
        plant.desc = description
        plant.image = self.imageString
        plant.family = self.lblFamily.text
        plant.date = self.getCurrentShortDate()
        plant.isFav = self.isChecked
        plant.plantId = self.id
    }
    
    func setDataFromList(plantModel: [Results]) {
        if self.message != "Not a plant." {
            // Set data from first element of Images array from response
            if let arrImages = plantModel.first?.images {
                self.arrImages.append(contentsOf: arrImages)
                self.lblPlantName.text = plantModel.first?.species?.name
                self.lblFamily.text = plantModel.first?.species?.family
                self.lblauthor.text = plantModel.first?.species?.author
                self.lblGenus.text = plantModel.first?.species?.genus
            }
            
            // Set data from second element of Images array from response
            if let plantImages = plantModel[1].images {
                self.plantListImages.append(contentsOf: plantImages)
            }
            
        } else {
            self.showAlert(with: "Choose another image that have plant.")
        }
    }
    
    // api calling for plat details
    func gatePlantDetailAPI(id: String) {
      
        Results.getPlantDetailsAPI(isShowLoader: false, id: id) { plantModel, message in
            print(plantModel)
            if message != "Not a plant." {
                // Set data from first element of Images array from response
               
                
                if let arrImages = plantModel.first?.images {
                    self.arrImages.append(contentsOf: arrImages)
                    
                  
                    DispatchQueue.main.async {
                        ERProgressHud.sharedInstance.hide()
                        self.lblPlantName.text = plantModel.first?.species?.name
                        self.lblFamily.text = plantModel.first?.species?.family
                        self.lblauthor.text = plantModel.first?.species?.author
                        self.lblGenus.text = plantModel.first?.species?.genus
                    
                    }
                    
                  
                    // Set Core data to insert recent serach details
                    
                    // convert image into base64 string
                    // Use image name from bundle to create NSData
                    let image: UIImage = self.image.fixedOrientation() ?? UIImage()
                    // Now use image to create into NSData format
                     let imageData: NSData = image.pngData()! as NSData
                    
                    let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
                    self.imageString = strBase64
                    
                    // check navigate from then not insert.
                    if !self.isFromHome {
                        self.savedata(name: plantModel.first?.species?.name ?? "", desc: "ABCDEFGHIJKLMNOPQRSTUVWXYZ", family: plantModel.first?.species?.family ?? "", image: strBase64, isfav: self.isChecked)
                    }
                }
                
                // Set data from second element of Images array from response
                if plantModel.count > 1 {
                    if let plantImages = plantModel[1].images {
                        self.plantListImages.append(contentsOf: plantImages)
                     
                    }
                }
               
                
                if self.plantListImages.count == 0 {
                    let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.plantImageCollectionView.frame.width, height: self.plantImageCollectionView.frame.height))
                   // label.backgroundColor = UIColor(red: 81/255, green: 173/255, blue: 153/255, alpha: 1)
                    label.textAlignment = .center
                    label.textColor = .black
                    label.text = "No Images Found"
                    label.font = UIFont(name: "Montserrat-Medium", size: 22)
                    self.plantImageCollectionView.backgroundView = label
                    self.plantImageCollectionView.reloadData()
                }
                
            } else {
                ERProgressHud.sharedInstance.hide()
                DispatchQueue.main.async {
                    self.showAlert(with: "Choose another image that have plant.",firstHandler: { action in
                        self.dismiss(animated: true)
                    })
                }
            }
        } failure: { _, error, _ in
            ERProgressHud.sharedInstance.hide()
            DispatchQueue.main.async {
                self.showToast(message: error)
            }
        }
    }
}

// MARK: - UICollectionview delegate method

extension PlantDetailsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.sliderCollectionView {
            return self.arrImages.count
        } else {
            return self.plantListImages.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SliderImageCell", for: indexPath) as! SliderImageCell
        if collectionView == self.sliderCollectionView {
            cell.vwImage.sd_setImage(with: URL(string: self.arrImages[indexPath.row].o ?? ""))
        } else {
            cell.layer.cornerRadius = 15
            cell.vwImage.sd_setImage(with: URL(string: self.plantListImages[indexPath.row].o ?? ""))
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.sliderCollectionView {
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        } else {
            if UIDevice.current.userInterfaceIdiom == .phone {
                return CGSize(width: collectionView.frame.width / 4 - 3, height: 100)
            } else {
                return CGSize(width: collectionView.frame.width / 4 - 3, height: 200)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

// MARK: - Core data method

extension PlantDetailsVC {
    func savedata(name: String, desc: String, family: String, image: String, isfav: Bool) {
        var context: NSManagedObjectContext
        if #available(iOS 10.0, *) {
            context = appDelegate.persistentContainer.viewContext
        } else {
            // Fallback on earlier versions
            context = appDelegate.managedObjectContext
        }
        
        // save
        print("Save")
        let Plants = NSEntityDescription.insertNewObject(forEntityName: "Plants", into: context) as! Plants
        self.setPlantdata(plant: Plants, name: name, description: desc, family: family, image: image, isfav: isfav, id: self.id)
        
        try? context.save()

    }
    
    // update data for only isfavoutite key
    func updateData() {
        var context: NSManagedObjectContext
        if #available(iOS 10.0, *) {
            context = appDelegate.persistentContainer.viewContext
        } else {
            // Fallback on earlier versions
            context = appDelegate.managedObjectContext
        }
        
        var plants: Plants!
        
        let fetchUser: NSFetchRequest<Plants> = Plants.fetchRequest()
        if let id = self.updateId {
            fetchUser.predicate = NSPredicate(format: "id = %@", id as String)
        }
        
        let results = try? context.fetch(fetchUser)
        
        if results?.count != 0 {
            plants = results?.first
        }
        
        self.setEditData(plant: plants)
        
        do {
            try context.save()
        } catch {}
    }
}



