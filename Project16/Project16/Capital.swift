//
//  Capital.swift
//  Project16
//
//  Created by Cory Steers on 12/11/22.
//

import MapKit
import UIKit

class Capital: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String
    var urlString: String
    
    init(title: String, coordinate: CLLocationCoordinate2D, info: String, url: String) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
        self.urlString = url
    }
}
