//
//  PictureViewController.swift
//  PhotoCaption
//
//  Created by Cory Steers on 11/14/22.
//

import UIKit

class PictureViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    var selectedImage: String?
    var imageCaption: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = imageCaption
        
        if let imageToLoad = selectedImage {
            imageView.image = UIImage(named: imageToLoad)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }
}
