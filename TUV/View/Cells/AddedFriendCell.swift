//
//  AddedFriendCell.swift
//  TUV
//
//  Created by Khalil Kum on 8/26/21.
//

import UIKit

internal final class AddedFriendCell: UITableViewCell, FriendCell {
    // MARK: Properties
    static var reuseIdentifier = "addedFriendCell"
    weak var buttonDelegate: ButtonDelegate?

    // MARK: Outlets
    @IBOutlet weak var friendImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var newContentIndicator: UIButton!
    
    // MARK: Actions
    @IBAction func profileImageTapped(_ sender: UIButton) {
        buttonDelegate?.imageButtonTapped(sender)
    }
}
