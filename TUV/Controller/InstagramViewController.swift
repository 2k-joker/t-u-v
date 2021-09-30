//
//  InstagramViewController.swift
//  TUV
//
//  Created by Khalil Kum on 8/16/21.
//

import Foundation
import UIKit

/*  Not going to implement this because facebook requires a user account to access their API.
    My disgust for facebook won't allow me create one.
    Going to leave the skeleton and assets in this project in case it's useful to someone else in the future.
 */
class InstagramViewController: UIViewController {
    // MARK: Properties
    
    // MARK: Outlets
    @IBOutlet weak var visitProfileButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var instagramHandleLabel: UILabel!
    @IBOutlet weak var mediaImageView: UIImageView!
    
    // MARK: View States
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.barTintColor = self.view.backgroundColor
        
        // TODO: Update user profile image (ig image?)
        // TODO: Update user username (ig handle?)
    }
    
    // MARK: Actions
    @IBAction func visitPageTapped(_ sender: UIButton) {
        // TODO: Open user's instagram account
    }
    
    // MARK: Functions
    
}
