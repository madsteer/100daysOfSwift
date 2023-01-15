//
//  NoteViewController.swift
//  BetterNotes
//
//  Created by Cory Steers on 1/12/23.
//

import UIKit

class NoteViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    
    var notes = [Note]()
    var workingNote: Note?
    var noteTitle = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.black.cgColor
        textView.becomeFirstResponder()
        
        let defaults = UserDefaults.standard
        if let savedNotes = defaults.object(forKey: "notes") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                notes = try jsonDecoder.decode([Note].self, from: savedNotes)
            } catch {
                print("failed to load notes from user defaults")
            }
        }
        
        let foundNotes = notes.filter{ $0.title == noteTitle }
        
        if foundNotes.count > 0 {
            workingNote = foundNotes[0]
            
            title = workingNote?.title
            navigationItem.largeTitleDisplayMode = .automatic
            //        navigationController?.navigationBar.prefersLargeTitles = true ???
            
            textView?.text = workingNote?.body
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let workingNote = workingNote, let text = textView?.text {
            workingNote.body = text
        }
        
        persist()
    }
        
    func persist() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(notes) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "notes")
        }
    }
}
