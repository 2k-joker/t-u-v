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
    weak var tapDelegate: ButtonDelegate?

    // MARK: Outlets
    @IBOutlet weak var friendImageView: UIImageView!
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var newContentIndicator: UIButton!
    
    // MARK: Actions
    @IBAction func profileImageTapped(_ sender: UIButton, forEvent event: UIEvent) {
        let imageButton = sender
        let touches = event.touches(for: imageButton)
        let touch = touches?.first
        let touchPoint = touch?.location(in: imageButton)
        
        tapDelegate?.profileImageTapped(sender, touchPoint: touchPoint)
    }
    
}
