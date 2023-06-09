//
//  Species.swift
//
//  Created by admin on 22/11/22
//  Copyright (c) . All rights reserved.
//

import Foundation

class Species: Codable {

  enum CodingKeys: String, CodingKey {
    case name
    case family
    case author
    case genus
 //   case iucn
    case commonNames
  }

  var name: String?
  var family: String?
  var author: String?
  var genus: String?
 //var iucn: Iucn?
  var commonNames: [String]?

  init (name: String?, family: String?, author: String?, genus: String?, commonNames: [String]?) {
    self.name = name
    self.family = family
    self.author = author
    self.genus = genus
//  self.iucn = iucn
    self.commonNames = commonNames
  }
    
    init(){
        self.name = ""
        self.family = ""
        self.author = ""
        self.genus = ""
    //  self.iucn = iucn
        self.commonNames = [""]
    }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    name = try container.decodeIfPresent(String.self, forKey: .name)
    family = try container.decodeIfPresent(String.self, forKey: .family)
    author = try container.decodeIfPresent(String.self, forKey: .author)
    genus = try container.decodeIfPresent(String.self, forKey: .genus)
 // iucn = try container.decodeIfPresent(Iucn.self, forKey: .iucn)
    commonNames = try container.decodeIfPresent([String].self, forKey: .commonNames)
  }

}
