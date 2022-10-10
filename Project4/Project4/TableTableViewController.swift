//
//  TableTableViewController.swift
//  Project4
//
//  Created by Cory Steers on 10/7/22.
//

import UIKit

class TableTableViewController: UITableViewController {
    var websites = ["apple.com", "hackingwithswift.com"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Browser"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        print("websites are \(websites)")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return websites.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WebPage", for: indexPath)
        cell.textLabel?.text = websites[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Page") as? ViewController {
            vc.websites = websites
            vc.selectedSiteIndex = indexPath.row
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
