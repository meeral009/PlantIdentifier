//
//  Images.swift
//
//  Created by admin on 22/11/22
//  Copyright (c) . All rights reserved.
//

import Foundation

class Images: Codable {

  enum CodingKeys: String, CodingKey {
    case s
    case license
    case author
    case date
    case m
    case id
    case o
    case organ
  }

  var s: String?
  var license: String?
  var author: String?
  var date: String?
  var m: String?
  var id: String?
  var o: String?
  var organ: String?

  init (s: String?, license: String?, author: String?, date: String?, m: String?, id: String?, o: String?, organ: String?) {
    self.s = s
    self.license = license
    self.author = author
    self.date = date
    self.m = m
    self.id = id
    self.o = o
    self.organ = organ
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    s = try container.decodeIfPresent(String.self, forKey: .s)
    license = try container.decodeIfPresent(String.self, forKey: .license)
    author = try container.decodeIfPresent(String.self, forKey: .author)
    date = try container.decodeIfPresent(String.self, forKey: .date)
    m = try container.decodeIfPresent(String.self, forKey: .m)
    id = try container.decodeIfPresent(String.self, forKey: .id)
    o = try container.decodeIfPresent(String.self, forKey: .o)
    organ = try container.decodeIfPresent(String.self, forKey: .organ)
  }

}
