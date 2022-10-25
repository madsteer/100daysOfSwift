//
//  ViewController.swift
//  Project1
//
//  Created by Cory Steers on 12/20/21.
//

import UIKit

class ViewController: UICollectionViewController {
    var pictures = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Storm"
        navigationController?.navigationBar.prefersLargeTitles = true

        performSelector(inBackground: #selector(fetchImages), with: nil)
    }

    @objc func fetchImages() {
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        for item in items {
            if item.hasPrefix("nssl") {
                // this is a picture to laod!
//                let picture = Picture(name: item, image: nil)
                pictures.append(item)
            }
        }
        pictures.sort()
        
        DispatchQueue.main.async{ [weak self] in
            self?.collectionView.reloadData()
        }
        
        print(pictures)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictures.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Picture", for: indexPath) as? PictureCell else {
            fatalError("Unable to dequeue a PictureCell")
        }
        
        let picture = pictures[indexPath.item]
        cell.name.text = picture
        
        cell.image.image = UIImage(named: picture)
        
        cell.image.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.image.layer.borderWidth = 2
        cell.image.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.numberOfImages = pictures.count
            vc.selectedImageIndex = indexPath.item
            vc.selectedImage = pictures[indexPath.item]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
