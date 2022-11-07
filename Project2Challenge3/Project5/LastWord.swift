//
//  LastWord.swift
//  Project5
//
//  Created by Cory Steers on 11/7/22.
//

import UIKit

class LastWord: NSObject, Codable {
    var currentWord: String
    var usedWords: [String]
    
    init(currentWord: String, usedWords: [String]) {
        self.currentWord = currentWord
        self.usedWords = usedWords
    }
}
