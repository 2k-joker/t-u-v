//
//  AddFriendsViewController.swift
//  TUV
//
//  Created by Khalil Kum on 8/22/21.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class AddFriendsViewController: UIViewController, ButtonDelegate {
    // MARK: Properties
    var currentSearchTask: URLSessionTask?
    var otherUsersList: [String]! = []
    fileprivate let currentUser = Auth.auth().currentUser!
    fileprivate let dbReference = Database.database().reference()
    fileprivate var _addedRefHandle: DatabaseHandle!
    fileprivate var _removedRefHandle: DatabaseHandle!
    fileprivate var selectedUserUid: String! = ""
    fileprivate var selectedUserConnectedApps: DataSnapshot!
    fileprivate var addedFriendIndexPath: IndexPath!
    fileprivate var addedFriendUid: String!

    // MARK: Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var friendsTableView: UITableView!
    
    // MARK: View States
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.barTintColor = self.view.backgroundColor

        configureFriendshipAddedObserver()
        configureFriendshipRemovedObserver()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "addFriendProfileSegue":
            let profileVC = segue.destination as! ProfileViewController
            profileVC.userUid = selectedUserUid
        case "addFriendFeedSegue":
            let userFeedVC = segue.destination as! UserFeedViewController
            userFeedVC.userConnectedApps = selectedUserConnectedApps
        default:
            () // Do nothing
        }
    }
    
    // MARK: Actions
    
    // MARK: Functions
    deinit {
        dbReference.child("friendships").removeObserver(withHandle: _addedRefHandle)
        dbReference.child("friendships").removeObserver(withHandle: _removedRefHandle)
    }

    func addFriendship(for addedFriendUid: String, at indexPath: IndexPath, by addButton: UIButton) {
        dbReference.child("friendships").updateChildValues(["\(currentUser.uid)+\(addedFriendUid)": true]) { error, reference in
            if error != nil {
                debugPrint(error.debugDescription)
                self.presentErrorMessage(Constants.UIAlertMessage.updateFailed.description)
                addButton.isHidden = false
            }
        }
    }

    func addFriendButtonTapped(_ button: UIButton, touchPoint: CGPoint?) {
        let buttonPosition = button.convert(touchPoint!, to: friendsTableView)
        let tappedIndexPath = friendsTableView.indexPathForRow(at: buttonPosition)

        if let indexPath = tappedIndexPath {
            let addedUserUid = otherUsersList[indexPath.row]

            dbReference.child("users/\(currentUser.uid)/addedFriends").updateChildValues([addedUserUid: true]) { error, reference in
                if error != nil {
                    debugPrint(error.debugDescription)
                    self.presentErrorMessage(Constants.UIAlertMessage.updateFailed.description)
                } else {
                    self.addedFriendUid = addedUserUid
                    self.addedFriendIndexPath = indexPath
                    button.isHidden = true
                    self.addFriendship(for: addedUserUid, at: indexPath, by: button)
                }
            }
        }
    }

    func profileImageTapped(_ button: UIButton, touchPoint: CGPoint?) {
        let buttonPosition = button.convert(touchPoint!, to: friendsTableView)
        let tappedIndexPath = friendsTableView.indexPathForRow(at: buttonPosition)

        if let indexPath = tappedIndexPath {
            dbReference.child("users/\(otherUsersList[indexPath.row])").getData { error, snapshot in
                if snapshot.exists() {
                    self.selectedUserUid = snapshot.key

                    self.performSegue(withIdentifier: "addFriendProfileSegue", sender: button)
                } else {
                    debugPrint(error.debugDescription)
                    self.performSegue(withIdentifier: "addFriendProfileSegue", sender: button)
                }
            }
        }
    }

    func configureFriendshipAddedObserver() {
        _addedRefHandle = dbReference.child("friendships").observe(.childAdded, with: { snapshot in
            let addedUserUid = HelperMethods.splitFriendShipKey(snapshot.key).last!
            let addingUserUid = HelperMethods.splitFriendShipKey(snapshot.key).first!
            
            if (addingUserUid == self.currentUser.uid) && (addedUserUid == self.addedFriendUid) {

                self.otherUsersList.remove(at: self.addedFriendIndexPath.row)
                self.friendsTableView.deleteRows(at: [self.addedFriendIndexPath], with: .left)
            }
        })
    }
    
    func configureFriendshipRemovedObserver() {
        _removedRefHandle = dbReference.child("friendships").observe(.childRemoved, with: { snapshot in
            let userUid = HelperMethods.splitFriendShipKey(snapshot.key).first
            let removedUid = HelperMethods.splitFriendShipKey(snapshot.key).last!
            
            if userUid == self.currentUser.uid {
                self.otherUsersList.insert(removedUid, at: 0)
                self.friendsTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .left)
            }
        })
    }
    
    func presentErrorMessage(_ message: String) {
        let alertVC = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        self.present(alertVC, animated: true, completion: nil)
    }
}

extension AddFriendsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentSearchTask?.cancel()
        // TODO: perform search based on search query
        currentSearchTask = nil
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}

extension AddFriendsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return otherUsersList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = friendsTableView.dequeueReusableCell(withIdentifier: AddFriendCell.reuseIdentifier, for: indexPath) as! AddFriendCell
        let userUid = otherUsersList[indexPath.row]
        
        cell.tapDelegate = self
        cell.friendImageView.image = UIImage(named: "robot_avatar")
        cell.usernameLabel.text = "unknown"
        cell.detailsLabel.text = "no connected apps"
        
        dbReference.child("users/\(userUid)").getData { error, snapshot in
            if error != nil {
                debugPrint(error.debugDescription)
            } else if snapshot.exists() {
                let userObject = snapshot.value as! [String:Any]
                let avatarName = userObject["avatarName"] as! String
                let username = userObject["username"] as! String
                let connectedApps = userObject["connectedApps"] as? [String:Any]
                let connectAppsNames = connectedApps?.keys.map { $0 }


                cell.friendImageView.image = UIImage(named: avatarName)
                cell.usernameLabel.text = username
                
                if let connectAppsNames = connectAppsNames {
                    cell.detailsLabel.text = connectAppsNames.joined(separator: ", ")
                }
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cell = tableView.cellForRow(at: indexPath)
        
        dbReference.child("users/\(otherUsersList[indexPath.row])/connectedApps").getData { error, snapshot in
            if snapshot.exists() {
                self.selectedUserConnectedApps = snapshot

                tableView.deselectRow(at: indexPath, animated: true)
                self.performSegue(withIdentifier: "addFriendFeedSegue", sender: nil)
            } else {
                tableView.deselectRow(at: indexPath, animated: true)
                debugPrint(error.debugDescription)
                // TODO: Present error getting user detals alert
            }
        }

//        tableView.deselectRow(at: indexPath, animated: true)
//        self.performSegue(withIdentifier: "addFriendFeedSegue", sender: cell)
    }
}
