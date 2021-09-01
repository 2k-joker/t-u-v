//
//  ProfileViewController.swift
//  TUV
//
//  Created by Khalil Kum on 8/22/21.
//

import Foundation
import UIKit

class ProfileViewController: UIViewController {
    // MARK: Properties
    var friendsCount: Int?
    
    // MARK: Outlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var friendsLabel: UILabel!
    @IBOutlet weak var accountsLabel: UILabel!
    @IBOutlet weak var connectAppsButton: UIButton!
    @IBOutlet weak var removeFriendButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    
    // MARK: View States
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendsLabel.text = "\(friendsCount ?? 1)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // TODO: check if user is current user
        configureUI(isCurrentUser: true)
    }
    
    // MARK: Actions
    @IBAction func editProfileTapped(_ sender: UIButton) {
        // setup user data in destination VC
        
        // segue to edit profile VC
        self.performSegue(withIdentifier: "editProfileSegue", sender: sender)
    }

    @IBAction func logoutTapped(_ sender: UIButton) {
        // Logout user
        
        // Segue to login VC
        self.performSegue(withIdentifier: "logoutSegue", sender: sender)
    }
    
    @IBAction func connectAppsTapped(_ sender: UIButton) {
        // TODO: Navigate to add apps VC
        self.performSegue(withIdentifier: "connectAppsSegue", sender: sender)
    }

    // MARK: Functions
    func configureUI(isCurrentUser: Bool) {
        editProfileButton.isHidden = !isCurrentUser
        connectAppsButton.isHidden = !isCurrentUser
        removeFriendButton.isHidden = isCurrentUser
        logOutButton.isHidden = !isCurrentUser
    }
}
