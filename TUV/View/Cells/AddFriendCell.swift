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
    weak var tapDelegate: ButtonDelegate?
    
    // MARK: Outlets
    @IBOutlet weak var friendImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var addFriendButton: UIButton!
    
    // MARK: Actions
    @IBAction func addFriendTapped(_ sender: UIButton, forEvent event: UIEvent) {
        let addButton = sender
        let touches = event.touches(for: addButton)
        let touch = touches?.first
        let touchPoint = touch?.location(in: addButton)
       
        tapDelegate?.addFriendButtonTapped(sender, touchPoint: touchPoint)
    }
    

    @IBAction func profileImageTapped(_ sender: UIButton, forEvent event: UIEvent) {
        let imageButton = sender
        let touches = event.touches(for: imageButton)
        let touch = touches?.first
        let touchPoint = touch?.location(in: imageButton)

        tapDelegate?.profileImageTapped(sender, touchPoint: touchPoint)
    }
}
