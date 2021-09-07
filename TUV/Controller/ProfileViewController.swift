//
//  ProfileViewController.swift
//  TUV
//
//  Created by Khalil Kum on 8/22/21.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ProfileViewController: UIViewController {
    // MARK: Properties
    var user: User!
    fileprivate var userInfo: [String:Any]!
    fileprivate var dbReference: DatabaseReference = Database.database().reference()

    // MARK: Outlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var friendsLabel: UILabel!
    @IBOutlet weak var appsLabel: UILabel!
    @IBOutlet weak var connectAppsButton: UIButton!
    @IBOutlet weak var removeFriendButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!

    // MARK: View States
    override func viewDidLoad() {
        super.viewDidLoad()

        getUserInfo()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        configureProfile()
    }

    // MARK: Actions
    @IBAction func editProfileTapped(_ sender: UIButton) {
        // setup user data in destination VC
        
        // segue to edit profile VC
        self.performSegue(withIdentifier: "editProfileSegue", sender: sender)
    }

    @IBAction func logoutTapped(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "logoutSegue", sender: sender)
        } catch {
            presentErrorMessage(Constants.UIAlertMessage.authFailure(.logout).description)
        }
    }

    @IBAction func connectAppsTapped(_ sender: UIButton) {
        // TODO: Setup destination with users connected apps

        // TODO: Navigate to add apps VC
        self.performSegue(withIdentifier: "connectAppsSegue", sender: sender)
    }

    @IBAction func removeFriendTapped(_ sender: UIButton) {
        if let currentUser = Auth.auth().currentUser {
            dbReference.child("users").queryOrdered(byChild: "uid").queryEqual(toValue: currentUser.uid).queryLimited(toFirst: 1).getData { error, snapshot in
                if error != nil {
                    DispatchQueue.main.sync {
                        self.presentErrorMessage(Constants.UIAlertMessage.removeFriendFailed(self.usernameLabel.text!).description)
                    }
                } else {
                    let currentUserObject = snapshot.value as! [String:Any]
                    let currentUsername = currentUserObject.first!.key
                    self.dbReference.child("users/\(currentUsername)/addedFriends/\(self.usernameLabel.text!)").removeValue()
                }
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }

    // MARK: Functions
    func getUserInfo() {
        dbReference.child("users").queryOrdered(byChild: "uid").queryEqual(toValue: user.uid).queryLimited(toFirst: 1).getData { error, snapshot in
            if snapshot.exists() {
                DispatchQueue.main.async {
                    let userObject = snapshot.value as! [String:Any]
                    let username = userObject.keys.first!
                    
                    self.userInfo = (userObject[username] as! [String:Any])
                    self.userInfo["username"] = username
                    self.populateUserData()
                }
            } else {
                DispatchQueue.main.async {
                    self.userInfo = [:]
                    self.populateUserData()
                }
            }
        }
    }
    
    func configureProfile() {
        guard let currentUser = Auth.auth().currentUser else {
            configureUI(isCurrentUser: false)
            return
        }

        if user == currentUser {
            configureUI(isCurrentUser: true)
        } else {
            configureUI(isCurrentUser: false)
        }
    }

    func configureUI(isCurrentUser: Bool) {
        editProfileButton.isHidden = !isCurrentUser
        connectAppsButton.isHidden = !isCurrentUser
        removeFriendButton.isHidden = isCurrentUser
        logOutButton.isHidden = !isCurrentUser
    }
    
    func populateUserData() {
        let avatarName = userInfo["avatarName"] as? String
        let username = userInfo["username"] as? String
        let addedFriends = userInfo["addedFriends"] as? [String: String]
        let connectedApps = userInfo["connectedApps"] as? [String: Any]

        profileImageView.image = UIImage(named: avatarName ?? "robot_avatar")
        usernameLabel.text = username ?? "unknown"
        friendsLabel.text = "\(addedFriends?.keys.count ?? 0)"
        appsLabel.text = "\(connectedApps?.keys.count ?? 0)"
    }

    func presentErrorMessage(_ message: String) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alertVC, animated: true, completion: nil)
    }
}
