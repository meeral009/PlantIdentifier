//
//  PlantDetailsVC.swift
//  PlantIdentifire
//
//  Created by admin on 25/11/22.
//

import UIKit
import SDWebImage
import CoreData
import SVProgressHUD
import GoogleMobileAds


class PlantDetailsVC: UIViewController {
    
    //MARK: - IBOutlates
    
    @IBOutlet weak var sliderCollectionView: UICollectionView!
    
    @IBOutlet weak var plantImageCollectionView: UICollectionView!
    
    @IBOutlet weak var pageView: UIPageControl!
    
    @IBOutlet weak var detailView: UIView!
    
    @IBOutlet weak var nativeAdPlaceholder: UIView!
    @IBOutlet weak var horizonataltackView: UIStackView!
    
    
    @IBOutlet weak var btnFav: UIButton!
    @IBOutlet weak var lblPlantName: UILabel!
    @IBOutlet weak var lblFamily: UILabel!
    @IBOutlet weak var lblauthor: UILabel!
    @IBOutlet weak var lblGenus: UILabel!
    
    //MARK: - variables
    var id = ""
    var message = ""
    var image = UIImage()
    var timer = Timer()
    var arrImages = [Images]()
    var plantListImages = [Images]()
    
    var resultsModelFromList =  [Results]()
    var counter = 0
 
 
    var isChecked = false
    var updateId : String?
    var imageString : String?
    var isFromHome = false
    
    /// The ad loader. You must keep a strong reference to the GADAdLoader during the ad loading
    /// process.
    var adLoader: GADAdLoader!
    /// The height constraint applied to the ad view, where necessary.
    var heightConstraint: NSLayoutConstraint?
    /// The native ad view that is being presented.
    var nativeAdView: GADNativeAdView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUi()
        
        if !isFromHome {
            self.gatePlantDetailAPI(id : self.id)
        }
        // Do any additional setup after loading the view.
    }
    
  
    @IBAction func btnBackAction(_ sender: Any) {
        
        if isFromHome {
            self.navigationController?.popViewController(animated: true)
        }else {
            self.dismiss(animated: true)
        }
    
    }
    
    @IBAction func btnisFavAction(_ sender: UIButton) {
        self.showToast(message: "Plant Saved")
//        isChecked = !isChecked
//     if isChecked {
//
//            sender.setImage(UIImage(named:"heart"), for: .normal)
//            self.updateData()
//
//        } else {
//
//            self.updateData()
//            sender.setImage(UIImage(named:"blankheart"), for: .normal)
//        }
    }
}

//MARK: - Userdefine function
extension PlantDetailsVC {
    
    func setUpUi(){
     
        self.nativeAdPlaceholder.isHidden  = true
        self.pageView.currentPage = 0
        
        
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.changeImage), userInfo: nil, repeats: true)
        }
        
        self.sliderCollectionView.register(UINib(nibName: "SliderImageCell", bundle: nil), forCellWithReuseIdentifier: "SliderImageCell")
        self.plantImageCollectionView.register(UINib(nibName: "SliderImageCell", bundle: nil), forCellWithReuseIdentifier: "SliderImageCell")
        
        self.loadXIB()
        
        // load native ad
        if self.isConnectedToNetwork() {
            self.loadAd()
        }else {
            self.nativeAdPlaceholder.isHidden = true
        }
        
        
        if isFromHome {
           
                self.setDataFromList(plantModel: self.resultsModelFromList)
           
           
        }
       
       
    }
    
    @objc func changeImage() {
     
     if counter < self.arrImages.count
 {
         let index = IndexPath.init(item: counter, section: 0)
         self.sliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
         pageView.currentPage = counter
         counter += 1
         
     } else {
         
         counter = 0
         let index = IndexPath.init(item: counter, section: 0)
         self.sliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
         pageView.currentPage = counter
         counter = 1
         
     }
         
     }
    
    func loadXIB() {
        guard let nibObjects = Bundle.main.loadNibNamed("NativeAdView", owner: nil, options: nil),
            let  adView = nibObjects.first as? GADNativeAdView
        else {
            return
        }
        
        // set up AdView
        self.setAdView(adView)
    }
    
    func setAdView(_ view: GADNativeAdView) {
        // Remove the previous ad view.
        nativeAdView = view
        nativeAdPlaceholder.addSubview(nativeAdView)
        nativeAdView.translatesAutoresizingMaskIntoConstraints = false
        
        // Layout constraints for positioning the native ad view to stretch the entire width and height
        // of the nativeAdPlaceholder.
        let viewDictionary = ["_nativeAdView": nativeAdView!]
        self.view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[_nativeAdView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary)
        )
        self.view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[_nativeAdView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary)
        )
    }
    
    func loadAd() {
        self.adLoader = GADAdLoader(
            adUnitID:adMob.nativeAdID.rawValue, rootViewController: self,
            adTypes: [.native], options: nil)
        self.adLoader.delegate = self
        self.adLoader.load(GADRequest())
      //self.nativeAdPlaceholder.isHidden = false
    }
    
    // show current date
    func getCurrentShortDate() -> String {
        let todaysDate = NSDate()
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM,yyyy"
        let DateInFormat = dateFormatter.string(from: todaysDate as Date)
        return DateInFormat
    }
    
    //set the data for save to core.
    func setPlantdata(plant : Plants , name : String , description : String , family : String , image : String , isfav : Bool , id : String){
        
        plant.id = UUID().uuidString
        self.updateId = plant.id
        plant.name = name
        plant.desc = description
        plant.image = image
        plant.family = family
        plant.date = getCurrentShortDate()
        plant.isFav = isfav
        plant.plantId = id
        
    }
    
    //set update data for isfav logic
    func setEditData(plant : Plants){
        
        plant.id = self.updateId
        plant.name =  self.lblPlantName.text
        plant.desc = description
        plant.image = self.imageString
        plant.family =  self.lblFamily.text
        plant.date = getCurrentShortDate()
        plant.isFav = self.isChecked
        plant.plantId = id
        
    }
    
    
    func setDataFromList ( plantModel : [Results]) {
        
        if message != "Not a plant." {
        // Set data from first element of Images array from response
        if let arrImages = plantModel.first?.images {
            
            self.arrImages.append(contentsOf: arrImages)
            
            DispatchQueue.main.async {
                self.pageView.numberOfPages = self.arrImages.count
            }
            
            self.lblPlantName.text =  plantModel.first?.species?.name
            self.lblFamily.text = plantModel.first?.species?.family
            self.lblauthor.text =  plantModel.first?.species?.author
            self.lblGenus.text =  plantModel.first?.species?.genus
        }
        
        // Set data from second element of Images array from response
        if let plantImages = plantModel[1].images{
            
            self.plantListImages.append(contentsOf: plantImages)
            
        }
        
        }else {
            
            self.showAlert(with: "Choose another image that have plant.")
           
        }
        
    }
    
    // api calling for plat details
    func gatePlantDetailAPI(id : String) {
        
        Results.getPlantDetailsAPI(isShowLoader: true , id: id ) { plantModel , message in
            print(plantModel)
            if message != "Not a plant." {
            // Set data from first element of Images array from response
            if let arrImages = plantModel.first?.images {
                
                self.arrImages.append(contentsOf: arrImages)
                
                DispatchQueue.main.async {
                    self.pageView.numberOfPages = self.arrImages.count
                }
                
                self.lblPlantName.text =  plantModel.first?.species?.name
                self.lblFamily.text = plantModel.first?.species?.family
                self.lblauthor.text =  plantModel.first?.species?.author
                self.lblGenus.text =  plantModel.first?.species?.genus
                
                
                //Set Core data to insert recent serach details
                
                //convert image into base64 string
                //Use image name from bundle to create NSData
                let image : UIImage = self.image
                //Now use image to create into NSData format
                let imageData:NSData = image.pngData()! as NSData
                
                let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
                self.imageString = strBase64
                
                // check navigate from then not insert.
                if !self.isFromHome {
                    self.savedata(name: plantModel.first?.species?.name ?? "", desc: "ABCDEFGHIJKLMNOPQRSTUVWXYZ", family: plantModel.first?.species?.family ?? "", image:  strBase64  , isfav: self.isChecked)
                }
            }
            
            // Set data from second element of Images array from response
            if let plantImages = plantModel[1].images{
                
                self.plantListImages.append(contentsOf: plantImages)
                
            }
            
            }else {
                
                self.showAlert(with: "Choose another image that have plant.")
               
            }
            
        } failure: { statuscode, error, customError in
            self.showAlert(with: error)
        }

    }
    
}

//MARK: - UICollectionview delegate method
extension PlantDetailsVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.sliderCollectionView {
            
            return self.arrImages.count
        }else {
            return self.plantListImages.count
        }
      
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SliderImageCell", for: indexPath) as! SliderImageCell
        if collectionView == self.sliderCollectionView {
            cell.vwImage.sd_setImage(with: URL(string: self.arrImages[indexPath.row].s ?? ""))
        }
        else {
            cell.layer.cornerRadius = 15
            cell.vwImage.sd_setImage(with: URL(string: self.plantListImages[indexPath.row].s ?? ""))
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == self.sliderCollectionView {
            return CGSize(width: collectionView.frame.width , height: collectionView.frame.height)
        }else {
            if UIDevice.current.userInterfaceIdiom == .phone {
                return CGSize(width : collectionView.frame.width / 4 - 3, height: 100)
            }else {
                return CGSize(width : collectionView.frame.width / 4 - 3, height: 200)
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

//MARK: - Core data method

extension PlantDetailsVC {
    
    func savedata(name : String , desc : String , family : String , image : String , isfav : Bool) {
        
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
        self.setPlantdata(plant: Plants, name: name, description: desc, family: family, image: image , isfav: isfav, id: id)
            
        try? context.save()
        self.dismiss(animated: true)
      
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
        } catch {

        }
    }
}

// MARK: - GADAdLoaderDelegate implementation

extension PlantDetailsVC: GADAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print("\(adLoader) failed with error: \(error.localizedDescription)")
        
       self.nativeAdPlaceholder.isHidden = true
    }
}

// MARK: - GADNativeAdLoaderDelegate implementation

extension PlantDetailsVC : GADNativeAdLoaderDelegate {
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        
        
        // Set ourselves as the native ad delegate to be notified of native ad events.
        nativeAd.delegate = self
        // Deactivate the height constraint that was set when the previous video ad loaded.
        self.heightConstraint?.isActive = false
        self.nativeAdPlaceholder.isHidden = false
        // Populate the native ad view with the native ad assets.
        // The headline and mediaContent are guaranteed to be present in every native ad.
        (self.nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        self.nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
        
        // Some native ads will include a video asset, while others do not. Apps can use the
        // GADVideoController's hasVideoContent property to determine if one is present, and adjust their
        // UI accordingly.
        let mediaContent = nativeAd.mediaContent
        if mediaContent.hasVideoContent {
            // By acting as the delegate to the GADVideoController, this ViewController receives messages
            // about events in the video lifecycle.
            mediaContent.videoController.delegate = self
            
        }
        
        // This app uses a fixed width for the GADMediaView and changes its height to match the aspect
        // ratio of the media it displays.
        if let mediaView = nativeAdView.mediaView, nativeAd.mediaContent.aspectRatio > 0 {
            self.heightConstraint = NSLayoutConstraint(
                item: mediaView,
                attribute: .height,
                relatedBy: .equal,
                toItem: mediaView,
                attribute: .width,
                multiplier: CGFloat(1 / nativeAd.mediaContent.aspectRatio),
                constant: 0)
            self.heightConstraint?.isActive = true
        }
        
        // These assets are not guaranteed to be present. Check that they are before
        // showing or hiding them.
        (self.nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        self.nativeAdView.bodyView?.isHidden = nativeAd.body == nil
        
        (self.nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        self.nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil
        
        (self.nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        self.nativeAdView.iconView?.isHidden = nativeAd.icon == nil
    
        
        (self.nativeAdView.storeView as? UILabel)?.text = nativeAd.store
        self.nativeAdView.storeView?.isHidden = nativeAd.store == nil
        
        (self.nativeAdView.priceView as? UILabel)?.text = nativeAd.price
        self.nativeAdView.priceView?.isHidden = nativeAd.price == nil
        
        (self.nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        self.nativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil
        
        // In order for the SDK to process touch events properly, user interaction should be disabled.
        self.nativeAdView.callToActionView?.isUserInteractionEnabled = false
        
        // Associate the native ad view with the native ad object. This is
        // required to make the ad clickable.
        // Note: this should always be done after populating the ad views.
        self.nativeAdView.nativeAd = nativeAd
        
    }
}
// MARK: - GADNativeAdDelegate implementation
extension PlantDetailsVC: GADNativeAdDelegate {
    
    func nativeAdDidRecordClick(_ nativeAd: GADNativeAd) {
        print("\(#function) called")
    }
    
    func nativeAdDidRecordImpression(_ nativeAd: GADNativeAd) {
        print("\(#function) called")
    }
    
    func nativeAdWillPresentScreen(_ nativeAd: GADNativeAd) {
        print("\(#function) called")
    }
    
    func nativeAdWillDismissScreen(_ nativeAd: GADNativeAd) {
        print("\(#function) called")
    }
    
    func nativeAdDidDismissScreen(_ nativeAd: GADNativeAd) {
        print("\(#function) called")
    }
    
    func nativeAdWillLeaveApplication(_ nativeAd: GADNativeAd) {
        print("\(#function) called")
    }
}

// MARK: - GADVideoControllerDelegate implementation
extension PlantDetailsVC : GADVideoControllerDelegate {
    func videoControllerDidEndVideoPlayback(_ videoController: GADVideoController) {}
}


