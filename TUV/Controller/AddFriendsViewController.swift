//
//  AddFriendsViewController.swift
//  TUV
//
//  Created by Khalil Kum on 8/22/21.
//

import Foundation
import UIKit

class AddFriendsViewController: UIViewController, ButtonDelegate {
    // MARK: Properties
    var currentSearchTask: URLSessionTask?
    var friends = [["Friend 1", "Friend 2"], ["Friend 3", "Friend 4", "Friend 5"]]
    let sectionTitles = ["Added Me", "Add Friends"]

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
    
    // MARK: Actions
    
    // MARK: Functions
    func addFriendButtonTapped(_ button: UIButton) {
        // TODO: Add friend to current user's friends list
        // TODO: Remove cell from view
        print("add friend tapped")
    }

    func profileImageTapped(_ button: UIButton, touchPoint: CGPoint?) {
        self.performSegue(withIdentifier: "addFriendProfileSegue", sender: button)
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
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = friendsTableView.dequeueReusableCell(withIdentifier: AddFriendCell.reuseIdentifier, for: indexPath) as! AddFriendCell
        
        cell.tapDelegate = self
        cell.friendImageView.image = UIImage(named: "robot_avatar")
        cell.usernameLabel.text = friends[indexPath.section][indexPath.row]
        cell.detailsLabel.text = "Twitter, Instagram"

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)

        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "addFriendFeedSegue", sender: cell)
    }
}
