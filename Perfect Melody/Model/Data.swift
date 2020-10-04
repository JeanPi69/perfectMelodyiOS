//
//  Data.swift
//  Perfect Melody
//
//  Created by JEAN PIERRE HUAPAYA CHAVEZ on 9/14/20.
//  Copyright © 2020 UPC. All rights reserved.
//

import SwiftUI

struct Post: Codable, Identifiable{
    let id = UUID()
    var name: String
    var artist: String
    var confidence: Int
    
    init(name: String, confidence: Int, artist: String) {
        self.name = name
        self.confidence = confidence
        self.artist = artist
    }
}
