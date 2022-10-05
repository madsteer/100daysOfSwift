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
        flag.image = UIImage(named: selectedFlag!)
    }
    
}
