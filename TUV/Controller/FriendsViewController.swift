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
    var addedFriendsUids: [String]! = []
    fileprivate let currentUser = Auth.auth().currentUser!
    fileprivate var _removedRefHandle: DatabaseHandle!
    fileprivate var _addedRefHandle: DatabaseHandle!
    fileprivate var selectedFriendUid: String!
    fileprivate let dbReference = Database.database().reference()
    fileprivate var addedCurrentUser: [String]! = []
    fileprivate var otherUsers: [String]! = []
    fileprivate var selectedFriendIndexPath: IndexPath!
    fileprivate var selectedFriendConnectedApps: DataSnapshot!
    
    // MARK: Outlets
    @IBOutlet var friendsTableView: UITableView!
    
    // MARK: View States
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.barTintColor = self.view.backgroundColor
        
        addedFriendsUids.removeAll()
        friendsTableView.reloadData()
        configureFriendshipAddedObserver()
        configureFriendshipRemovedObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        selectedFriendIndexPath = nil
        selectedFriendUid = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeFriendshipObservers()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "friendProfileSegue":
            let profileVC = segue.destination as! ProfileViewController
            profileVC.userUid = selectedFriendUid
            profileVC.isCurrentUserFriend = true
        case "friendFeedSegue":
            let friendFeedVC = segue.destination as! UserFeedViewController
            friendFeedVC.userConnectedApps = selectedFriendConnectedApps
            friendFeedVC.userUid = selectedFriendUid
        case "addFriendsSegue":
            let addFriendsVC = segue.destination as! AddFriendsViewController
            addFriendsVC.otherUsersList = otherUsers
        default:
            () // Do nothing
        }
    }

    // MARK: Actions
    @IBAction func addFriendsTapped(_ sender: UIBarButtonItem) {
        getaddedCurrentUser()
    }
    
    // MARK: Functions
    deinit {
        removeFriendshipObservers()
    }

    func configureFriendshipRemovedObserver() {
        _removedRefHandle = dbReference.child("friendships").observe(.childRemoved, with: { snapshot in
            let userUid = HelperMethods.splitFriendShipKey(snapshot.key).first!

            if userUid == self.currentUser.uid {
                if let indexPath = self.selectedFriendIndexPath {

                    self.addedFriendsUids.remove(at: indexPath.row)
                    self.friendsTableView.deleteRows(at: [indexPath], with: .left)
                }
            }
        })
    }

    func configureFriendshipAddedObserver() {
        _addedRefHandle = dbReference.child("friendships").observe(.childAdded, with: { snapshot in
            let userUid = HelperMethods.splitFriendShipKey(snapshot.key).first
            let addedUid = HelperMethods.splitFriendShipKey(snapshot.key).last!
            
            if userUid == self.currentUser.uid {
                self.addedFriendsUids.insert(addedUid, at: 0)
                self.friendsTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            }
        })
    }

    func profileImageTapped(_ sender: UIButton, touchPoint: CGPoint?) {
        let buttonPosition = sender.convert(touchPoint!, to: friendsTableView)
        let indexPath = friendsTableView.indexPathForRow(at: buttonPosition)

        if let tappedIndexPath = indexPath {
            dbReference.child("users/\(addedFriendsUids[tappedIndexPath.row])").getData { error, snapshot in
                if snapshot.exists() {
                    self.selectedFriendUid = snapshot.key
                    self.selectedFriendIndexPath = tappedIndexPath

                    self.performSegue(withIdentifier: "friendProfileSegue", sender: sender)
                } else {
                    debugPrint(error.debugDescription)
                    self.performSegue(withIdentifier: "friendProfileSegue", sender: sender)
                }
            }
        }
    }

    func getaddedCurrentUser() {
        dbReference.child("friendships").queryOrderedByKey().queryEnding(atValue: currentUser.uid).getData { error, snapshot in
            if error != nil {
                debugPrint(error.debugDescription)
            } else if snapshot.exists() {
                let friendships = snapshot.value as? [String:String]
                
                if let friendships = friendships {
                    let uids = friendships.map { HelperMethods.splitFriendShipKey($0.key).first! }
                    
                    self.addedCurrentUser = Array(Set(uids).subtracting(Set(self.addedFriendsUids)))
                }
            }

            self.getOtherUsersAndSegue()
        }
    }
    
    func getOtherUsersAndSegue() {
        dbReference.child("users").queryOrderedByKey().getData { error, snapshot in
            if error != nil {
                debugPrint(error.debugDescription)
            } else if snapshot.exists() {
                let uids = (snapshot.value as! [String:Any]).map { $0.key }

                // everyone except for current user's friends and current user
                self.otherUsers = Array(Set(uids).subtracting(Set(self.addedFriendsUids)).subtracting(Set([self.currentUser.uid])))
            }
            
            self.performSegue(withIdentifier: "addFriendsSegue", sender: nil)
        }
    }
    
    func removeFriendshipObservers() {
        dbReference.child("friendships").removeObserver(withHandle: _addedRefHandle)
        dbReference.child("friendships").removeObserver(withHandle: _removedRefHandle)
    }
}

extension FriendsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addedFriendsUids.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = friendsTableView.dequeueReusableCell(withIdentifier: AddedFriendCell.reuseIdentifier) as! AddedFriendCell
        let friendUid = addedFriendsUids[indexPath.row]
        
        cell.tapDelegate = self
        cell.friendImageView.image = UIImage(named: "robot_avatar")
        cell.usernameLabel.text = "username"
        cell.detailsLabel.text = ""
        
        // TODO: implement new content indicator
        cell.newContentIndicator.isHidden = true

        dbReference.child("users/\(friendUid)").getData { error, snapshot in
            if error != nil {
                debugPrint("Error getting data for users/\(friendUid): \(error.debugDescription)")
            } else if snapshot.exists() {
                let userData = snapshot.value as! [String:Any]
                let userAddedFriends = userData["addedFriends"] as? [String: Any]
                let currentUserUid = self.currentUser.uid

                cell.friendImageView.image = UIImage(named: userData["avatarName"] as! String)
                cell.usernameLabel.text = userData["username"] as? String
                if let userAddedFriends = userAddedFriends {
                    if userAddedFriends[currentUserUid] != nil {
                        cell.detailsLabel.text = "added you"
                    }
                }
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dbReference.child("users/\(addedFriendsUids[indexPath.row])/connectedApps").getData { error, snapshot in
            if snapshot.exists() {
                self.selectedFriendConnectedApps = snapshot

                tableView.deselectRow(at: indexPath, animated: true)
                self.performSegue(withIdentifier: "friendFeedSegue", sender: nil)
            } else {
                tableView.deselectRow(at: indexPath, animated: true)
                debugPrint(error.debugDescription)
            }
        }
    }
}
