//
//  PickAvatarViewController.swift
//  TUV
//
//  Created by Khalil Kum on 8/22/21.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class PickAvatarViewController: UIViewController {
    // MARK: Properties
    var currentAvatarName: String = "robot_avatar"
    private var avatarNames: [String] {
        [
            "asian_female_avatar", "asian_male_avatar",
            "black_female_avatar", "black_male_avatar",
            "latinx_female_avatar", "latinx_male_avatar",
            "native_female_avatar", "native_male_avatar",
            "white_female_avatar", "white_male_avatar"
        ]
    }
    
    // MARK: Outlets
    @IBOutlet weak var avatarPreviewImageView: UIImageView!
    @IBOutlet weak var avatarCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var selectAvatarButton: UIButton!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    // MARK: View States
    override func viewDidLoad() {
        super.viewDidLoad()
        
        avatarCollectionView.dataSource = self
        avatarCollectionView.delegate = self
        configureFlowLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // TODO: Set initial preview image
        avatarPreviewImageView.image = UIImage(named: currentAvatarName)
        selectAvatarButton.isEnabled = false
    }
    
    // MARK: Actions
    @IBAction func selectTapped(_ sender: UIButton) {
        let currentUser = Auth.auth().currentUser
        if let currentUser = currentUser {
            let update = ["users/\(currentUser.uid)/avatarName": currentAvatarName]
            updateUserAvatar(update)
        }
    }
    
    // MARK: Functions
    func configureFlowLayout() {
        let space:CGFloat = 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
    }
    
    func updateUserAvatar(_ update: [String:String]) {
        activityIndicator.startAnimating()
        
        FirebaseClient.writeDataToFirebase(withNewData: update) { timedout, error, reference in
            if timedout {
                self.presentMessage(message: .connectionTimeout)
            } else if error != nil {
                self.presentMessage(message: .updateFailed)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
            
            self.activityIndicator.stopAnimating()
        }
    }
    
    func presentMessage(message: Constants.UIAlertMessage) {
        let alertVC = UIAlertController(title: nil, message: message.description, preferredStyle: .alert)

        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        self.present(alertVC, animated: true, completion: nil)
    }
}

extension PickAvatarViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return avatarNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = avatarCollectionView.dequeueReusableCell(withReuseIdentifier: AvatarCollectionViewCell.reuseIdentifier, for: indexPath) as! AvatarCollectionViewCell
        cell.imageView.image = UIImage(named: avatarNames[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentAvatarName = avatarNames[indexPath.row]
        avatarPreviewImageView.image = UIImage(named: currentAvatarName)
        selectAvatarButton.isEnabled = true
    }
}
