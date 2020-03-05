//
//  ImageObject.swift
//  March3FinalPhotoJournal
//
//  Created by Margiett Gil on 3/3/20.
//  Copyright © 2020 Margiett Gil. All rights reserved.
//

import Foundation

struct ImageObject: Codable & Equatable {
    let imageData: Data
    let date: Date
    let identifier = UUID().uuidString
    var description: String
}
