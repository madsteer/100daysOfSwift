//
//  ViewController.swift
//  PhotoCaption
//
//  Created by Cory Steers on 11/11/22.
//

import UIKit

class ViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var pictures = [Picture]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Pictures"
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(addNewPicture))
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        
        let picture = pictures[indexPath.row]
        cell.textLabel?.text = picture.caption
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "PictureView") as? PictureViewController {
            
            let path = getDocumentsDirectory().appendingPathComponent(pictures[indexPath.row].name)
            vc.selectedImage = path.path
            vc.imageCaption = pictures[indexPath.row].caption
            navigationController?.pushViewController(vc, animated: true)
            tableView.reloadData()
        }
    }

    @objc func addNewPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        picker.sourceType = .camera
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jgegData = image.jpegData(compressionQuality: 0.8) {
            try? jgegData.write(to: imagePath)
        }
        
        let picture = Picture(for: imageName, caption: "picture \(pictures.count)")

        pictures.append(picture)
        save()
        tableView.reloadData()
        
        dismiss(animated: true)
        
        let ac = UIAlertController(title: "Add Caption", message: "would you like to add a caption?", preferredStyle: .alert)
        ac.addTextField(configurationHandler: { (textField) -> Void in
            textField.text = "No Caption"
        })
        ac.addAction(UIAlertAction(title: "Add", style: .default) { [weak self, weak ac] _ in
            guard let newCaption = ac?.textFields?[0].text else { return }
            picture.caption = newCaption
            self?.save()
            self?.tableView.reloadData()
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func save() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(pictures) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "pictures")
        }
    }
}
