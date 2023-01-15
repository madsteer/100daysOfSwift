//
//  Note.swift
//  BetterNotes
//
//  Created by Cory Steers on 1/12/23.
//

import Foundation

class Note: NSObject, Codable {
    var title: String
    var body: String
    
    init(title: String, body: String) {
        self.title = title
        self.body = body
    }
}
