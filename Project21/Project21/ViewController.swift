//
//  ViewController.swift
//  Project21
//
//  Created by Cory Steers on 1/10/23.
//

import UserNotifications
import UIKit

class ViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    let notificationCategory = "alarm"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleLocalSelector))
    }
    
    
    @objc func registerLocal() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("yay!")
            } else {
                print("D'oh!")
            }
        }
    }
    
    @objc func scheduleLocalSelector() {
        let content = UNMutableNotificationContent()
        content.title = "Late wake up call"
        content.body = "The early bird catches the worm, but the second mouse gets the cheese."
        content.categoryIdentifier = notificationCategory
        content.userInfo = [ "customData": "fizzbuzz" ]
        content.sound = .default
        
        scheduleLocal(existingContent: content)
    }
    
    func scheduleLocal(existingContent: UNMutableNotificationContent? = nil, triggerInterval: Double = 5.0) {
        registerCategories()
        
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        let content = existingContent ?? UNMutableNotificationContent()
        if (existingContent == nil) {
            content.title = "Late wake up call"
            content.body = "The early bird catches the worm, but the second mouse gets the cheese."
            content.categoryIdentifier = notificationCategory
            content.userInfo = [ "customData": "fizzbuzz" ]
            content.sound = .default
        }
        
//        var dateComponents = DateComponents()
//        dateComponents.hour = 10
//        dateComponents.minute = 30
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: triggerInterval, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        center.add(request)
    }

    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        let show = UNNotificationAction(identifier: "show", title: "Tell me more...", options: .foreground)
        let later = UNNotificationAction(identifier: "later", title: "Remind me later", options: .foreground)
        let category = UNNotificationCategory(identifier: notificationCategory, actions: [show, later], intentIdentifiers: [])
        
        center.setNotificationCategories([category])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let customData = userInfo["customData"] as? String {
            print("Custom data received: \(customData)")
            
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                let ac = UIAlertController(title: "Default", message: "The default identifier was chosen.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
            case "show":
                let ac = UIAlertController(title: "More", message: "Show more information ...", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
            case "later":
                let content = UNMutableNotificationContent()
                content.title = "Reminder wake up call"
                content.body = "who knows if there's any cheese left at this point."
                content.categoryIdentifier = notificationCategory
                content.userInfo = [ "customData": "foobar" ]
                content.sound = .default
                scheduleLocal(existingContent: content, triggerInterval: 86400.0)
                print("a 24 hour delayed reminder was set")
            default:
                break
            }
        }
        
        completionHandler()
    }
}

