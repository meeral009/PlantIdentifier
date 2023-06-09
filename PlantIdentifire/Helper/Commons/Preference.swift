//
//  Preference.swift
//  Cozy Up
//
//  Created by Keyur on 15/10/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class Preference: NSObject {

    static let sharedInstance = Preference()
    
    let PRIVACY_POLISY          = "ACCEPT_PRIVACY_POLICY_KEY"
    let FAVOURITE_LIST          = "FAVOURITE_LIST_KEY"
}

func removeDataFromPreference(key: String) {
    UserDefaults.standard.removeObject(forKey: key)
    UserDefaults.standard.synchronize()
}

func removeUserDefaultValues() {
    UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    UserDefaults.standard.synchronize()
}

// MARK: - Accept Term of service
func setIsUserAcceptPrivacyPolicy(isAccepted: Bool) {
    setDataToPreference(data: isAccepted as AnyObject, forKey: Preference.sharedInstance.PRIVACY_POLISY)
}

func isAcceptUserPrivacyPolicy() -> Bool {
    let isAccepted = getDataFromPreference(key: Preference.sharedInstance.PRIVACY_POLISY)
    return isAccepted == nil ? false : (isAccepted as! Bool)
}

// MARK: - Favourite Song
func setPlantDetails(plantResult: Results) {
    var arrPlant = getPlantDetails()
    let index = arrPlant.firstIndex { temp in
        temp.species?.name == plantResult.species?.name
    }
    if index != nil {
        arrPlant.remove(at: index!)
    } else {
        arrPlant.append(plantResult)
    }
    UserDefaults.standard.set(encodable: arrPlant, forKey: Preference.sharedInstance.FAVOURITE_LIST)
}

func savePlantsList(plantResult: [Results]) {
    UserDefaults.standard.set(encodable: plantResult, forKey: Preference.sharedInstance.FAVOURITE_LIST)
}

func getPlantDetails() -> [Results] {
    if let data = UserDefaults.standard.get([Results].self, forKey: Preference.sharedInstance.FAVOURITE_LIST) {
        return data
    }
    return [Results]()
}




extension UserDefaults {

    // MARK: Set Custom Object in UserDefaults
    public func set<T: Encodable>(encodable: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(encodable) {
            set(data, forKey: key)
        }
    }

     // MARK: Get Custom Object from UserDefaults
    public func get<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        if let data = object(forKey: key) as? Data,
            let value = try? JSONDecoder().decode(type, from: data) {
            return value
        }
        return nil
    }
}
