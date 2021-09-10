//
//  FriendsViewController.swift
//  TUV
//
//  Created by Khalil Kum on 8/25/21.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class FriendsViewController: UIViewController, ButtonDelegate {
    // MARK: Properties
    var addedFriends: [String]!
    fileprivate let currentUser = Auth.auth().currentUser
    fileprivate var selectedUserUid: String = ""
    fileprivate let dbReference = Database.database().reference()
    fileprivate var selectedUser: User?
    
    // MARK: Outlets
    @IBOutlet var friendsTableView: UITableView!
    
    // MARK: View States
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        // TODO: Load current user's friends
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.barTintColor = self.view.backgroundColor
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "friendProfileSegue":
            let profileVC = segue.destination as! ProfileViewController
            profileVC.userUid = selectedUserUid
        case "friendFeedSegue":
            ()
        default:
            () // Do nothing
        }

        // TODO: set the username from sender
        //friendDetailVC.friendUsername = addedFriends.first
    }
    
    // MARK: Actions
    
    // MARK: Functions
    func profileImageTapped(_ sender: UIButton, touchPoint: CGPoint?) {
        let indexPath = friendsTableView.indexPathForRow(at: touchPoint!)
        
        if let tappedIndexPath = indexPath {
            dbReference.child("users/\(addedFriends[tappedIndexPath.row])").getData { error, snapshot in
                if snapshot.exists() {
                    self.selectedUserUid = snapshot.key

                    self.performSegue(withIdentifier: "friendProfileSegue", sender: sender)
                } else {
                    debugPrint(error.debugDescription)
                }
            }
        }
    }
}

extension FriendsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addedFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = friendsTableView.dequeueReusableCell(withIdentifier: AddedFriendCell.reuseIdentifier) as! AddedFriendCell
        
        let friendUid = addedFriends[indexPath.row]
        cell.tapDelegate = self
        cell.friendImageView.image = UIImage(named: "robot_avatar")
        cell.usernameLabel.text = "username"
        cell.detailsLabel.text = ""
        
        dbReference.child("users/\(friendUid)").getData { error, snapshot in
            if error != nil {
                debugPrint("Error getting data for users/\(friendUid): \(error.debugDescription)")
            } else if snapshot.exists() {
                let userData = snapshot.value as! [String:Any]
                let userAddedFriends = userData["addedFriends"] as? [String: Any]
                let currentUserUid = self.currentUser?.uid ?? ""
                
                
                cell.friendImageView.image = UIImage(named: userData["avatarName"] as! String)
                cell.usernameLabel.text = userData["username"] as? String
                if let userAddedFriends = userAddedFriends {
                    if userAddedFriends[currentUserUid] != nil {
                        cell.detailsLabel.text = "added you"
                    }
                }
            }
        }
        
        if indexPath.row == 1 {
            cell.newContentIndicator.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Get friend at index path
        let friend = addedFriends[indexPath.row]
        
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "friendFeedSegue", sender: friend)
    }
}
