//
//  Picture.swift
//  Project1
//
//  Created by Cory Steers on 11/7/22.
//

import UIKit

class Picture: NSObject, Codable {
    var name: String
    var viewCount: Int
    
    init(for name: String, viewCount: Int) {
        self.name = name
        self.viewCount = viewCount
    }
}
