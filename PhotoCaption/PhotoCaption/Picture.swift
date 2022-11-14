//
//  Picture.swift
//  PhotoCaption
//
//  Created by Cory Steers on 11/13/22.
//

import UIKit

class Picture: NSObject, Codable {
    var name: String
    var caption: String

    init(for name: String, caption: String) {
        self.name = name
        self.caption = caption
    }
}
