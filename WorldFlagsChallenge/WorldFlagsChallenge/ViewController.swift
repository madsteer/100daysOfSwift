//
//  ViewController.swift
//  WorldFlagsChallenge
//
//  Created by Cory Steers on 10/4/22.
//

import UIKit

class ViewController: UITableViewController {
        var flags = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Country Flags"
        navigationController?.navigationBar.prefersLargeTitles = true
        
//        let fm = FileManager.default
//        let path = Bundle.main.resourcePath!
//        let items = try! fm.contentsOfDirectory(atPath: path)
//        let car = items.firstIndex(of: "Assets.car")
//        print("here's where I'm printing \(items)")
        
        flags += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
        flags.sort()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flags.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Country", for: indexPath)
        cell.textLabel?.text = flags[indexPath.row].uppercased()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Flag") as? FlagViewControlerViewController {
            vc.selectedFlag = flags[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }

}

