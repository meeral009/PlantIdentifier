//
//  ServiceManager.swift
//  PlantIdentifire
//
//  Created by admin on 15/11/22.
//

import Foundation
import SystemConfiguration
import Alamofire

class ServiceManager {
    
    public static let shared = ServiceManager()
    
    // MARK: - Check for internet connection
    
    /**
     This method is used to check internet connectivity.
     - Returns: Return boolean value to indicate device is connected with internet or not
     */
    
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
 
    // Mark API Call
    
    class func makeRequset ( url : URL ,id : String , method: HTTPMethod, parameter: [String: Any]?, sucess : @escaping (_ response : Any) -> Void , failure :  @escaping (_ error: String) -> Void, connectionFailed: @escaping (_ error: String) -> Void) {

        if(isConnectedToNetwork()){

            if let param = parameter,
               let data = try? JSONSerialization.data(withJSONObject: param, options: .prettyPrinted) {
                print(String(data: data, encoding: .utf8) ?? "Nil Param")
            }
            
                    var semaphore = DispatchSemaphore (value: 0)

                    let parameters = "{\r\n\t\"images\": [{\r\n\t\t\"url\": \"https://bs.floristic.org/image/o/\(id)\",\r\n\t\t\"organ\": \"leaf\"\r\n\t}]\r\n}"
                    let postData = parameters.data(using: .utf8)

                    var request = URLRequest(
                        url: URL(string:"https://api.plantnet.org/v1/projects/the-plant-list/queries/identify?lang=en&clientType=ios&clientVersion=3.0.1%20-%20138")!,
                        timeoutInterval: Double.infinity
                    )
            
                    request.addValue("plantnet/3.0.1.138 Dalvik/2.1.0 (Linux; U; Android 5.1; 1201 Build/LMY47I)", forHTTPHeaderField: "user-agent")
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

                    request.httpMethod = "POST"
                    request.httpBody = postData

                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    
                        if let response = response {
                                print(response)
                        }
                        if let data = data {
                            do {
                                let json = try JSONSerialization.jsonObject(with: data, options: [])
                                print(json)
                                sucess(data)
                            } catch {
                                failure( "\n Failure: \(error.localizedDescription)")
                            }
                        }
                        
                      semaphore.signal()
                    }

                    task.resume()
                    semaphore.wait()
            
        }else {

            connectionFailed("No Internet Connection")
      
        }


    }
     
    
    public class func callsendImageAPI(url: URL, param:[String: Any],image:UIImage?,imageKey:String, sucess : @escaping (_ response : Any) -> Void , failure :  @escaping (_ error: String) -> Void, connectionFailed: @escaping (_ error: String) -> Void) {
        
        if(isConnectedToNetwork()) {
            
            let headers: HTTPHeaders
            headers = ["Content-type": "multipart/form-data"]
            
            AF.upload(multipartFormData: { (multipartFormData) in
                
                for (key, value) in param {
                    multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
                }
                
                if image != nil {
                    guard let imgData = image?.jpegData(compressionQuality: 1) else { return }
                    multipartFormData.append(imgData, withName: imageKey, fileName: "profile" + ".jpeg", mimeType: "image/jpeg")
                }
                
                
            },to: url, usingThreshold: UInt64.init(),
              method: .post,
              headers: headers).responseJSON { response in
                print(response)
                switch response.result {
                    case .success(let data):
                    sucess(data)
                    
                case .failure(let error):
                    print( "\n Failure: \(error.localizedDescription)")
                    failure( "\n Failure: \(error.localizedDescription)")
                }
                
            }
            
        } else {
            connectionFailed("No Internet connection.")
        }
    }
    
    
}
