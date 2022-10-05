//
//  FlagViewControlerViewController.swift
//  WorldFlagsChallenge
//
//  Created by Cory Steers on 10/4/22.
//

import UIKit

class FlagViewControlerViewController: UIViewController {
    @IBOutlet var flag: UIImageView!
    var selectedFlag: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = selectedFlag!.uppercased()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareFlag))
        
        if let imageToLoad = selectedFlag {
            flag.image = UIImage(named: imageToLoad)
        }
    }
    
    @objc func shareFlag() {
        guard let image = flag.image?.jpegData(compressionQuality: 0.8) else {
            print("no image found")
            return
        }
        
        let vc = UIActivityViewController(activityItems: [image, selectedFlag!.uppercased()], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
}
