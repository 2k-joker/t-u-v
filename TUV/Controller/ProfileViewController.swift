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
    var userUid: String = ""
    var isCurrentUserFriend: Bool = false
    fileprivate let activeUser = Auth.auth().currentUser
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editProfileSegue" {
            let editProfileVC = segue.destination as! EditProfileViewController
            editProfileVC.userInfo = userInfo
        }
    }

    // MARK: Actions
    @IBAction func editProfileTapped(_ sender: UIButton) {
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
        // TODO: Navigate to add apps VC
        self.performSegue(withIdentifier: "connectAppsSegue", sender: sender)
    }

    @IBAction func removeFriendTapped(_ sender: UIButton) {
        if let currentUser = activeUser {
            dbReference.child("users/\(currentUser.uid)/addedFriends/\(userUid)").removeValue()
            dbReference.child("friendships/\(currentUser.uid)+\(userUid)").removeValue()
            
            self.dismiss(animated: true, completion: nil)
        }
    }

    // MARK: Functions
    func getUserInfo() {
        FirebaseClient.retrieveDataFromFirebase(forPath: "users/\(userUid)", withTimeout: 15) { timedout, error, snapshot in
            if timedout {
                self.presentErrorMessage(Constants.UIAlertMessage.connectionTimeout.description)
                self.userInfo = [:]
            } else if let snapshot = snapshot {
                self.userInfo = (snapshot.value as! [String:Any])
            } else {
                self.userInfo = [:]
            }

            self.populateUserData()
        }
    }
    
    func configureProfile() {
        guard let currentUser = activeUser else {
            configureUI(isCurrentUser: false)
            return
        }

        if userUid == currentUser.uid {
            configureUI(isCurrentUser: true)
        } else {
            configureUI(isCurrentUser: false)
        }
    }

    func configureUI(isCurrentUser: Bool) {
        editProfileButton.isHidden = !isCurrentUser
        connectAppsButton.isHidden = !isCurrentUser
        removeFriendButton.isHidden = isCurrentUser || !isCurrentUserFriend
        logOutButton.isHidden = !isCurrentUser
    }
    
    func populateUserData() {
        let avatarName = userInfo["avatarName"] as? String
        let username = userInfo["username"] as? String
        let addedFriends = userInfo["addedFriends"] as? [String: Any]
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
