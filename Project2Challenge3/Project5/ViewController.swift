//
//  ViewController.swift
//  Project5
//
//  Created by Cory Steers on 10/10/22.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()
    var usedWords = [String]()
    var lastWord: LastWord?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "New Word", style: .plain, target: self, action: #selector(startGame))
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        let defaults = UserDefaults.standard
        if let savedState = defaults.object(forKey: "lastWord") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                lastWord = try jsonDecoder.decode(LastWord.self, from: savedState)
            } catch {
                print("Failed to load last word.")
            }
        }

        if let lword = lastWord {
            if !lword.currentWord.isEmpty {
                title = lword.currentWord
                usedWords = lword.usedWords
                tableView.reloadData()
                return
            }
        }
        startGame()
    }

    @objc func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
        lastWord = LastWord(currentWord: title!, usedWords: usedWords)
        persist()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        lastWord = LastWord(currentWord: title ?? "", usedWords: usedWords)
//        persist()
//    }
//
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//
//        lastWord = LastWord(currentWord: title ?? "", usedWords: usedWords)
//        persist()
//    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true )
    }

    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        
        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    usedWords.insert(answer, at: 0)
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    
                    lastWord = LastWord(currentWord: title ?? "", usedWords: usedWords)
                    persist()
                    return
                } else { showErrorMessage("Word not recognized", "You can't just make them up, you know!") }
            } else { showErrorMessage("Duplicate Word", "Be more original!") }
        } else {
            guard let title = title else { return }
            showErrorMessage("Word not possible", "You can't spell that word from '\(title.lowercased())'.")
        }
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(where: {$0.caseInsensitiveCompare(word) == .orderedSame})
    }
    
    func isReal(word: String) -> Bool {
        if word.count < 3 { return false }
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspellegRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspellegRange.location == NSNotFound
    }
    
    func showErrorMessage(_ title: String, _ message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func persist() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(lastWord) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "lastWord")
        }
    }
}

