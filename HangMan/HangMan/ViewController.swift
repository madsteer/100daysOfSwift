//
//  ViewController.swift
//  HangMan
//
//  Created by Cory Steers on 10/20/22.
//

import UIKit

class ViewController: UIViewController {
    var wordLabel: UILabel!
    var wordDescriptionLabel: UILabel!
    var wrongGuessLabel: UILabel!
    var wrongGuessDescriptionLabel: UILabel!
    var letterButtons = [UIButton]()
    
    var allWords = [String]()
    var progressView: UIProgressView!
    var guessWord = String()
    var wrongGuessCount: Float = 0.0 {
        didSet {
            wrongGuessLabel.text = String(Int(wrongGuessCount))
        }
    }

    override func loadView() {
        view = UIView()
        
        view.backgroundColor = .white
        
        wordDescriptionLabel = UILabel()
        wordDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        wordDescriptionLabel.textAlignment = .center
        wordDescriptionLabel.text = "Word to guess:"
        view.addSubview(wordDescriptionLabel)
        
        wordLabel = UILabel()
        wordLabel.translatesAutoresizingMaskIntoConstraints = false
        wordLabel.textAlignment = .center
        wordLabel.text = "---"
        view.addSubview(wordLabel)

        wrongGuessDescriptionLabel = UILabel()
        wrongGuessDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        wrongGuessDescriptionLabel.textAlignment = .center
        wrongGuessDescriptionLabel.text = "Wrong guesses:"
        view.addSubview(wrongGuessDescriptionLabel)

        wrongGuessLabel = UILabel()
        wrongGuessLabel.translatesAutoresizingMaskIntoConstraints = false
        wrongGuessLabel.textAlignment = .center
        wrongGuessLabel.text = "0"
        view.addSubview(wrongGuessLabel)

        let buttonsView = UIView()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsView)

        NSLayoutConstraint.activate([
            wordDescriptionLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 50),
            wordDescriptionLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 10),
            wordDescriptionLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.4, constant: -5),
            
            wordLabel.topAnchor.constraint(equalTo: wordDescriptionLabel.topAnchor),
            wordLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -50),
            wordLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.6, constant: -5),
            wordLabel.heightAnchor.constraint(equalTo: wordDescriptionLabel.heightAnchor),
            
            wrongGuessDescriptionLabel.topAnchor.constraint(equalTo: wordLabel.bottomAnchor, constant: 20),
            wrongGuessDescriptionLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 10),
            wrongGuessDescriptionLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.4, constant: -5),
            
            wrongGuessLabel.topAnchor.constraint(equalTo: wrongGuessDescriptionLabel.topAnchor),
            wrongGuessLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -50),
            wrongGuessLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.6, constant: -5),
            wrongGuessLabel.heightAnchor.constraint(equalTo: wrongGuessDescriptionLabel.heightAnchor),

            buttonsView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            buttonsView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 10),
            buttonsView.heightAnchor.constraint(equalToConstant: 134),
            buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20)
            
        ])
        
        let width = 40
        let height = 40
        var alphabetIndex = 0
        let alphabetArray = buildAlphabetArray()
        
        for row in 0..<3 {
            for column in 0..<9 {
                let letterButton = UIButton(type: .system)
                letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
                letterButton.setTitle(alphabetArray[alphabetIndex], for: .normal)
                letterButton.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
                
                let frame = CGRect(x: column * width, y: row * height, width: width, height: height)
                letterButton.frame = frame
                letterButton.layer.borderWidth = 1
                letterButton.layer.borderColor = UIColor.lightGray.cgColor
                
                buttonsView.addSubview(letterButton)

                letterButtons.append(letterButton)
                alphabetIndex += 1
            }
        }
        
        letterButtons[letterButtons.count - 1].isEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        performSelector(inBackground: #selector(loadWords), with: nil)
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let deathOMeter = UIBarButtonItem(title: "Death-O-meter", style: .plain, target: nil, action: nil)
        
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()
        let progressButton = UIBarButtonItem(customView: progressView)

        toolbarItems = [spacer, deathOMeter, progressButton, spacer]
        navigationController?.isToolbarHidden = false
        
        title = "Hangman"
        
        performSelector(onMainThread: #selector(startGame), with: nil, waitUntilDone: false)
    }
    
    @objc func loadWords() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
    }
    
    @objc func startGame(action: UIAlertAction) {
        if let randomWord = allWords.randomElement() {
            guessWord = randomWord.uppercased()
            let hiddenWord = randomWord.replacingOccurrences(of: ".", with: "-", options: .regularExpression)
            print("hiddenWord for \(randomWord) is \(hiddenWord)")
            wordLabel.text = hiddenWord
            wrongGuessCount = 0
            progressView.progress = wrongGuessCount / 7.0
            
            for letterButton in letterButtons {
                letterButton.isEnabled = true
            }
            letterButtons[letterButtons.count - 1].isEnabled = false
        }
    }

    @objc func letterTapped(_ sender: UIButton) {
        guard let buttonTitle = sender.titleLabel?.text else { return }
        
        if let hiddenWord = wordLabel?.text {
            var hiddenWordLetters = Array(hiddenWord)
            if guessWord.contains(buttonTitle) {
                for (index, letter) in Array(guessWord).enumerated() {
                    if String(letter) == buttonTitle {
                        hiddenWordLetters[index] = Character(buttonTitle)
                    }
                }
                
                wordLabel?.text = String(hiddenWordLetters)
            } else {
                wrongGuessCount += 1.0
                progressView.progress = wrongGuessCount / 7.0
                
                if wrongGuessCount < 7.0 {
                    let ac = UIAlertController(title: "Bad Guess!", message: "There are no \(buttonTitle)'s in this word", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Try Again", style: .default))
                    present(ac, animated: true)
                } else {
                    let ac = UIAlertController(title: "Game Over!", message: "Ya dun been hanged!", preferredStyle: .alert)
                    ac.addAction((UIAlertAction(title: "New Game", style: .default, handler: startGame)))
                    present(ac, animated: true)
                }
            }
            sender.isEnabled = false
            
            if wordLabel?.text == guessWord {
                let ac = UIAlertController(title: "Congratulations!", message: "You won! \(guessWord.lowercased()) is correct.", preferredStyle: .alert)
                ac.addAction((UIAlertAction(title: "New Game", style: .default, handler: startGame)))
                present(ac, animated: true)
            }
        }
    }

    func buildAlphabetArray() -> [String] {
        var result = [String]()
        
        if let aScalarsFirst = "A".unicodeScalars.first {
            let aCode = Int(aScalarsFirst.value)
            
            for i in 0..<26 {
                if let scalar = UnicodeScalar(aCode + i) {
                    result.append(String(Character(scalar)))
                }
            }
        }
        
        result.append("")
        
        return result
    }
}

