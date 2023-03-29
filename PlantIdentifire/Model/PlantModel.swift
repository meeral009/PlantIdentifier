//
//  PlantModel.swift
//
//  Created by admin on 22/11/22
//  Copyright (c) . All rights reserved.
//

import Foundation
import UIKit


//MARK: - Error enum
enum ErrorType: String {
    case server = "Error"
    case connection = "No connection"
    case response = ""
}

//typealias FailureBlock = (_ error: String, _ customError: ErrorType) -> Void
typealias FailureBlock = (_ statuscode: Int,_ error: String, _ customError: ErrorType) -> Void

class PlantModel: Codable {
    
  enum CodingKeys: String, CodingKey {
    case session
    case date
  //case organs
    case results
    case message
  }

  var session: String?
  var date: Int?
//var organs: Any?
  var results: [Results]?
 var message: String?

    init (session: String?, date: Int?, organs: Any?, results: [Results]? ,message : String?) {
    self.session = session
    self.date = date
 //   self.organs = organs
    self.results = results
    self.message = message
  }
    
   init() {
        
   }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    session = try container.decodeIfPresent(String.self, forKey: .session)
    date = try container.decodeIfPresent(Int.self, forKey: .date)
   // organs = try container.decodeIfPresent([].self, forKey: .organs)
    results = try container.decodeIfPresent([Results].self, forKey: .results)
    message = try container.decodeIfPresent(String.self, forKey: .message)
  }
    
 
 func uploadPlantImage( plantImage: UIImage?, isShowLoader : Bool, success withResponse: @escaping (_ id : String) -> Void, failure: @escaping FailureBlock) {
       
       if isShowLoader {
           ERProgressHud.sharedInstance.showBlurView(withTitle: "Identifying Plant...")

       }
        
        ServiceManager.callsendImageAPI(url: URL(string: "https://bs.plantnet.org/v1/image")!, param: [:], image: plantImage, imageKey: "file") {
            response in
            
            if isShowLoader {
                ERProgressHud.sharedInstance.hide()
            }
            let dict = response as? [String:Any] ?? [:]
            let id = dict["id"] as? String ?? ""
            withResponse(id)
            
        } failure : { (error) in
            if isShowLoader {
                ERProgressHud.sharedInstance.hide()
            }
            print("error")
           failure(0, error, .server)
            
        } connectionFailed: { (connectionError) in
            if isShowLoader {
                ERProgressHud.sharedInstance.hide()
            }
            print("error")
        failure(0, connectionError, .connection)
        }
    }
    

  

}
