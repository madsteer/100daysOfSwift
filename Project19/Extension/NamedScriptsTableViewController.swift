//
//  NamedScriptsTableViewController.swift
//  Extension
//
//  Created by Cory Steers on 12/22/22.
//

import UIKit

class NamedScriptsTableViewController: UITableViewController {

    var scriptNames = [String]()
    var previousViewController: ActionViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "JS Scripts"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let defaults = UserDefaults.standard
        if let savedScriptNameKeys = (defaults.object(forKey: "savedScripts") as? [String: String])?.keys {
            scriptNames = Array(savedScriptNameKeys)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return scriptNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScriptName", for: indexPath)
        
        let scriptName = scriptNames[indexPath.row]
        cell.textLabel?.text = scriptName

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let scriptName = scriptNames[indexPath.row]
        if let selectedScript = previousViewController?.savedScripts[scriptName] {
            previousViewController?.script?.text = selectedScript
        }
        navigationController?.popViewController(animated: true)
    }
}
