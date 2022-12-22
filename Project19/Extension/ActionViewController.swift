//
//  ActionViewController.swift
//  Extension
//
//  Created by Cory Steers on 12/20/22.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class ActionViewController: UIViewController {
    @IBOutlet var script: UITextView!
    
    var pageTitle = ""
    var pageUrl = ""
    var savedScripts = [String: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let defaults = UserDefaults.standard
        if let saved = defaults.object(forKey: "savedScripts") as? [String: String] {
            savedScripts = saved
        }
        
        print("saved scripts are \(savedScripts)")

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(pickFromSavedScripts))
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
            if let itemProvider = inputItem.attachments?.first {
                itemProvider.loadItem(forTypeIdentifier: UTType.propertyList.identifier as String) { [weak self] (dict, error) in
                    guard let itemDictionary = dict as? NSDictionary else { return }
                    guard let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
                    
                    self?.pageTitle = javaScriptValues["title"] as? String ?? ""
                    self?.pageUrl = javaScriptValues["URL"] as? String ?? ""
                    
                    DispatchQueue.main.async { // dont' need [weak self] here as it's already weak from outer closure
                        self?.title = self?.pageTitle
                    }
                }
            }
        }
    }

    @IBAction func done() {
        let ac = UIAlertController(title: "Name your Script", message: "Would you like to name and save your script?", preferredStyle: .alert)
        ac.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "No name"
        })
        ac.addAction(UIAlertAction(title: "Save & Run", style: .default) { [ weak self, weak ac] _ in
            guard let newName = ac?.textFields?[0].text else { return }
            self?.savedScripts[newName] = self?.script.text
            self?.persist()
            self?.performDone()
        })
        ac.addAction(UIAlertAction(title: "Just Run", style: .cancel) { [weak self] _ in
            self?.performDone()
        })
        
        present(ac, animated: true)
    }
    
    func performDone() {
        // essentially doing the opposite of what we're doing in viewDidLoad above
        let item = NSExtensionItem()
        let argument: NSDictionary = ["customJavaScript": script.text!]
        let webDictionary: NSDictionary  = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: UTType.propertyList.identifier as String)
        item.attachments = [customJavaScript]
        extensionContext?.completeRequest(returningItems: [item])
    }

    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            script.contentInset = .zero
        } else {
            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        script.scrollIndicatorInsets = script.contentInset
        
        let selectedRange = script.selectedRange
        script.scrollRangeToVisible(selectedRange)
    }
    
    @objc func pickFromSavedScripts() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "SavedScriptsView") as? NamedScriptsTableViewController {
            vc.previousViewController = self
            navigationController?.pushViewController(vc, animated: true)
            view.reloadInputViews()
        }
    }
    
    func persist() {
        let defaults = UserDefaults.standard
        defaults.set(savedScripts, forKey: "savedScripts")
    }
}
