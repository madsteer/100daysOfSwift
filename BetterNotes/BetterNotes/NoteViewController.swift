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
        
        let deleteBarButtonItem = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteNote))
        let shareBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareNote))
        navigationItem.rightBarButtonItems = [deleteBarButtonItem, shareBarButtonItem]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let workingNote = workingNote, let text = textView?.text {
            workingNote.body = text
        }
        
        persist()
    }
    
    @objc func deleteNote() {
        if let workingNote = workingNote {
            notes.removeAll(where: { $0.title == workingNote.title })
            persist()
        }
        navigationController?.popViewController(animated: true)
    }
    
    @objc func shareNote() {
        if let workingNote = workingNote {
            let text = workingNote.title + "\n\n" + workingNote.body
            
            let vc = UIActivityViewController(activityItems: [text], applicationActivities: [])
            vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
            present(vc, animated: true)
        }
    }
        
    func persist() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(notes) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "notes")
        }
    }
}
