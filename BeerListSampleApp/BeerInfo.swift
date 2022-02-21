//
//  BeerInfo.swift
//  BeerListSampleApp
//
//  Created by Mac on 2022/02/18.
//

import UIKit

struct BeerInfo: Codable {
    let id: Int?
    let name, tagLine, description, brewersTip, imageURL: String?
    let foodPairing: [String]?
    
    var realTag: String {
        let tags = tagLine?.components(separatedBy: ". ")
        let hashtag = tags?.map {
            "#" + $0.replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: ".", with: "")
                .replacingOccurrences(of: ",", with: " #")
        }
        return hashtag?.joined(separator: " ") ?? ""
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, description
        case tagLine = "tagline"
        case imageURL = "image_url"
        case brewersTip = "bresers_tips"
        case foodPairing = "food_pairing"
    }
}
