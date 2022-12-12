//
//  WebViewController.swift
//  Project16
//
//  Created by Cory Steers on 12/12/22.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var urlString: String?

    override func loadView() {
        webView = WKWebView()
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let urlString = urlString else { return }
        
        guard let url = URL(string: urlString) else { return }
        
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
