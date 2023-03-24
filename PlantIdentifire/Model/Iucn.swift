//
//  Iucn.swift
//
//  Created by admin on 22/11/22
//  Copyright (c) . All rights reserved.
//

import Foundation

class Iucn: Codable {

  enum CodingKeys: String, CodingKey {
    case category
  }

  var category: Category?

  init (category: Category?) {
    self.category = category
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
      category = try container.decodeIfPresent(Category.self, forKey: .category)
  }

}
