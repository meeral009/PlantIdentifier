//
//  Results.swift
//
//  Created by admin on 22/11/22
//  Copyright (c) . All rights reserved.
//

import Foundation


class Results: Codable {

  enum CodingKeys: String, CodingKey {
    case images
    case species
    case score
  }

  var images: [Images]?
  var species: Species?
  var score: Float?

  init (images: [Images]?, species: Species?, score: Float?) {
    self.images = images
    self.species = species
    self.score = score
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    images = try container.decodeIfPresent([Images].self, forKey: .images)
    species = try container.decodeIfPresent(Species.self, forKey: .species)
    score = try container.decodeIfPresent(Float.self, forKey: .score)
  }
    
    class func getPlantDetailsAPI(isShowLoader : Bool, id : String, success withResponse: @escaping (_ arrResultsModel : [Results] , _ message : String) -> Void, failure: @escaping FailureBlock)
    {

        if isShowLoader {
            ERProgressHud.sharedInstance.show()
            //ERProgressHud.sharedInstance.show(withTitle: "Loading...")
        }
        
        let obj = ["url":"https://bs.floristic.org/image/o/e9d801196734f91b9c860308f052fd91f6f25868",
                   "organ": "leaf"]
        let dictImage = [obj]
        let params = ["images": dictImage]
        
        ServiceManager.makeRequset(url: URL(string: "https://api.plantnet.org/v1/projects/the-plant-list/queries/identify?lang=en&clientType=ios&clientVersion=3.0.1%20-%20138")! , id : id, method: .post, parameter: params) {
            data in
            
            if isShowLoader {
                ERProgressHud.sharedInstance.hide()
            }
            print("response: \(data)")
            
          //  let dict = data as [String:Any]
          //  let message = dict["message"] as? String ?? ""
            
          //  print(message)
            
            do {
                let res = JSONDecoder()
                if let dataa = data as? Data {
                    
                    let ss = try res.decode(PlantModel.self, from:dataa)
                    withResponse(ss.results!,ss.message ?? "")
                   
                }
            }
            catch {
                print(error)
            }
            
           
        } failure : { (error) in
            if isShowLoader {
                
                ERProgressHud.sharedInstance.hide()
            }
            
            failure(0, error, .server)
            
        } connectionFailed: { (connectionError) in
            if isShowLoader {
                ERProgressHud.sharedInstance.hide()
            }
            failure(0, connectionError, .connection)
        }
        

      }
}
