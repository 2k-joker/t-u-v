//
//  TwitterViewController.swift
//  TUV
//
//  Created by Khalil Kum on 8/16/21.
//

import UIKit
import WebKit

class TwitterViewController: UIViewController, WKUIDelegate {

    // MARK: Outlets
    @IBOutlet weak var visitProfileButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var twitterHandleLabel: UILabel!
    @IBOutlet weak var webView: WKWebView!

    // MARK: View States
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.uiDelegate = self

        let myURL = URL(string:"https://www.apple.com")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBar.barTintColor = self.view.backgroundColor
        
        // TODO: Update user profile image (twitter image?)
        // TODO: Update user username (twitter handle?)
    }

    // MARK: Actions
    @IBAction func visitPageTapped(_ sender: UIButton) {
        // TODO: Open user's twitter page
    }
    
    // MARK: Functions
    
}
