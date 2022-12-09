//
//  Country.swift
//  CountryTrivia
//
//  Created by Cory Steers on 12/9/22.
//

import UIKit

class Country: Codable {
    var name: String
    var capital: String
    var nationalLanguage: String
    var areaInSqKm: Int
    var population: Int
    var gdp: String
    var currency: String
    var timezone: String
    var drivingSide: String
}
