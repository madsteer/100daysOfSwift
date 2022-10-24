//
//  Person.swift
//  Project10
//
//  Created by Cory Steers on 10/24/22.
//

import UIKit

class Person: NSObject {
    var name: String
    var image: String

    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}
