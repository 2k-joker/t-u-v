//
//  AddFriendCell.swift
//  TUV
//
//  Created by Khalil Kum on 8/26/21.
//

import UIKit

internal final class AddFriendCell: UITableViewCell, FriendCell {
    // MARK: Properties
    static var reuseIdentifier = "addFriendCell"
    weak var buttonDelegate: ButtonDelegate?
    
    // MARK: Outlets
    @IBOutlet weak var friendImageView: UIImageView!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var addFriendButton: UIButton!
    
    // MARK: Actions
    @IBAction func addFriendTapped(_ sender: UIButton) {
        buttonDelegate?.addFriendButtonTapped!(sender)
    }

    @IBAction func imageButtonTapped(_ sender: UIButton) {
        buttonDelegate?.imageButtonTapped(sender)
    }
}
