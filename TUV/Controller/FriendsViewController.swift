//
//  FriendsViewController.swift
//  TUV
//
//  Created by Khalil Kum on 8/25/21.
//

import Foundation
import UIKit

class FriendsViewController: UIViewController, ButtonDelegate {
    // MARK: Properties
    let addedFriends = ["Friend 1", "Friend 2"]
    
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
            ()
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
    func imageButtonTapped(_ button: UIButton) {
        self.performSegue(withIdentifier: "friendProfileSegue", sender: button)
    }
}

extension FriendsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addedFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = friendsTableView.dequeueReusableCell(withIdentifier: AddedFriendCell.reuseIdentifier) as! AddedFriendCell
        
        cell.buttonDelegate = self
        cell.friendImageView.image = UIImage(named: "robot_avatar")
        cell.usernameLabel.text = addedFriends[indexPath.row]
        cell.detailsLabel.text = "added you"
        
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
