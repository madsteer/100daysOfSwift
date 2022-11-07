//
//  ViewController.swift
//  Project1
//
//  Created by Cory Steers on 12/20/21.
//

import UIKit

class ViewController: UITableViewController {
    var pictures = [Picture]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Storm"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let defaults = UserDefaults.standard
        if let savedPeople = defaults.object(forKey: "pictures") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                pictures = try jsonDecoder.decode([Picture].self, from: savedPeople)
            } catch {
                print("Failed to load pictures")
            }
        }

        performSelector(inBackground: #selector(fetchImages), with: nil)
    }

    @objc func fetchImages() {
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        for item in items {
            if item.hasPrefix("nssl") {
                let pic = Picture(for: item, viewCount: 0)
                // this is a picture to laod!
                pictures.append(pic)
            }
        }
        pictures.sort { $0.name < $1.name }
        
        save()
        
        DispatchQueue.main.async{ [weak self] in
            self?.tableView.reloadData()
        }
        
        print(pictures)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        cell.textLabel?.text = pictures[indexPath.row].name
        cell.detailTextLabel?.text = "Shown \(pictures[indexPath.row].viewCount) times"
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.numberOfImages = pictures.count
            vc.selectedImageIndex = indexPath.row
            vc.selectedImage = pictures[indexPath.row].name
            pictures[indexPath.row].viewCount += 1
            save()
            print("view count for \(pictures[indexPath.row].name) is now \(pictures[indexPath.row].viewCount)")
            navigationController?.pushViewController(vc, animated: true)
            tableView.reloadData()
        }
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(pictures) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "pictures")
        }
    }
}

