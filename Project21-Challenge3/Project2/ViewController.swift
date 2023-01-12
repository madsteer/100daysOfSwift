//
//  ViewController.swift
//  Project2
//
//  Created by Cory Steers on 9/29/22.
//

import UIKit

class ViewController: UIViewController, UNUserNotificationCenterDelegate {
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    
    let notificationsCategory = "alarm"
    var countries = [String]()
    var score = 0
    var highScore = 0
    var correctAnswer = 0
    var answered = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestAbilityToSendLocalNotifications()
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Score", style: .plain, target: self, action: #selector(showScore))
        
        let defaults = UserDefaults.standard
        if let savedScore = defaults.object(forKey: "highScore") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                highScore = try jsonDecoder.decode(Int.self, from: savedScore)
            } catch {
                print("Failed to load old high score.")
            }
        }
        
        countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
        
        button1.layer.borderWidth = 1
        button2.layer.borderWidth = 1
        button3.layer.borderWidth = 1
        
        button1.layer.borderColor = UIColor.lightGray.cgColor
        button2.layer.borderColor = UIColor.lightGray.cgColor
        button3.layer.borderColor = UIColor.lightGray.cgColor
        
        askQuestion()
    }
    
    func askQuestion(action: UIAlertAction! = nil) {
        countries.shuffle()
        
        correctAnswer = Int.random(in: 0...2)
        
        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)
        
        title = "Current Score: \(score) - Find \(countries[correctAnswer].uppercased())"
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        var title: String
        
        UIView.animate(withDuration: 0.25, delay: 0, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.80, y: 0.80)
        })
        UIView.animate(withDuration: 1, delay: 0.05, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: [], animations: {
            sender.transform = .identity
        })
        
        if sender.tag == correctAnswer {
            title = "Correct"
            score += 1
        } else {
            title = "Wrong, that's \(countries[sender.tag].uppercased())"
            score -= 1
        }
        
        answered += 1
        
        let ac: UIAlertController
        if answered < 10 {
            ac = UIAlertController(title: title, message: "Your score is \(score)", preferredStyle: .alert)
        } else {
            if score > highScore {
                ac = UIAlertController(title: title, message: "Game over.  You scored \(score) out of \(answered).  That's a new high score!!", preferredStyle: .alert)
                highScore = score
                persist()
            } else {
                ac = UIAlertController(title: title, message: "Game over.  You scored \(score) out of \(answered)", preferredStyle: .alert)
            }
            score = 0
            answered = 0
            scheduleLocalNotifications()
        }
        ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
        present(ac, animated: true)
    }
    
    @objc func showScore() {
        let vc = UIAlertController(title: "Score", message: "Current score is \(score)", preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "OK", style: .default, handler: askQuestion))
        present(vc, animated: true)
    }
    
    func persist() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(highScore) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "highScore")
        }
        print("high score is now \(highScore)")
    }
    
    func requestAbilityToSendLocalNotifications() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Ability to send alerts was granted")
            } else {
                print("Ability to send alerts was denied")
            }
        }
    }
    
    func registerNotificationCategories() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        let show = UNNotificationAction(identifier: "show", title: "Launch Flag Game", options: .foreground)
        let category = UNNotificationCategory(identifier: notificationsCategory, actions: [show], intentIdentifiers: [])
        
        center.setNotificationCategories([category])
    }
    
    func scheduleLocalNotifications() {
        registerNotificationCategories()
        
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Ready for a Break?"
        content.body = "It's time to play the #1 country flag guessing game!"
        content.categoryIdentifier = notificationsCategory
        content.sound = .default
        
        for day in 1...7 {
            let delay = 86400.0 * Double(day)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
            print("adding a reminder for \(day) days out.")
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            break
        case "show":
            let ac = UIAlertController(title: "Let's Play!", message: "Welcome back.  Ready to play?", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        default:
            break
        }
        
        completionHandler()
    }
}

