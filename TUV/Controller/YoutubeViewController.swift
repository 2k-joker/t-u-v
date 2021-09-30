//
//  YoutubeViewController.swift
//  TUV
//
//  Created by Khalil Kum on 8/16/21.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class YoutubeViewController: UIViewController {
    // MARK: Properties
    fileprivate var friendUid: String = ""
    fileprivate let dbRference = Database.database().reference()
    fileprivate let currentUser = Auth.auth().currentUser!
    fileprivate var currentUserFriends: [String] = []
    fileprivate var userYoutubeData: [String: String] = [:]
    
    // MARK: Outlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var thumbnailButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    // MARK: View States
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendUid = (self.parent as? UserFeedViewController)?.userUid ?? ""
        errorLabel.isHidden = true

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBar.barTintColor = self.view.backgroundColor
        thumbnailButton.isEnabled = false
        
        if friendUid.isEmpty {
            getCurrentUserFriendsUids()
        } else {
            getSnapshotForFriend(with: friendUid)
        }
    }
    
    // MARK: Actions
    @IBAction func thumbnailTapped(_ sender: UIButton) {
        HelperMethods.visitPage(for: .youtube, with: userYoutubeData, context: .specificContent)
    }

    // MARK: Functions
    func getCurrentUserFriendsUids() {
        dbRference.child("users/\(currentUser.uid)/addedFriends").getData { error, snapshot in
            if snapshot.exists() {
                let friendsUids = (snapshot.value as? [String: Bool])?.keys
                let randomUserUid = friendsUids?.randomElement() ?? self.currentUser.uid
                
                self.friendUid = randomUserUid
                self.getSnapshotForFriend(with: self.friendUid)
            } else {
                debugPrint("Unable to retrieve user friends: \(error.debugDescription)")
                self.getSnapshotForFriend(with: self.currentUser.uid)
            }
        }
    }
    
    func getSnapshotForFriend(with userUid: String) {
        dbRference.child("users/\(userUid)").getData { error, snapshot in
            if snapshot.exists() {
                let friendData = snapshot.value as! [String: Any]
                let connectedAppsData = friendData["connectedApps"] as? [String: Any]

                self.displayUsernameAndAvatarForFriend(with: friendData)
                self.userYoutubeData = connectedAppsData?["YouTube"] as? [String: String] ?? [:]
                self.updateVideoViewWithUserExistingLatestVideo()
            } else {
                debugPrint("Unable to retrieve friend snapshot: \(error.debugDescription)")
            }
            
            self.retrieveUserLatestVideo()
        }
    }
    
    func displayUsernameAndAvatarForFriend(with appData: [String: Any]) {
        if let avatarName = appData["avatarName"] as? String {
            profileImageView.image = UIImage(named: avatarName)
        }
        
        if let username = appData["username"] as? String {
            usernameLabel.text = username
        }
    }
    
    func updateVideoViewWithUserExistingLatestVideo() {
        let thumbnailUrl = URL(string: userYoutubeData["latestThumbnailUrl"] ?? "")
        updateMediaView(with: thumbnailUrl)
    }
    
    func retrieveUserLatestVideo() {
        let playlistId = userYoutubeData["playlistId"] ?? ""

        YoutubeApiClient.getPlaylist(with: playlistId, completionHandler: handleUserPlaylistItemResponse(response:error:))
    }
    
    func handleUserPlaylistItemResponse(response: YoutubeApiSchemas.PlaylistsResponse?, error: Error?) {
        guard let response = response else {
            debugPrint(error.debugDescription)
           return
        }
        
        if response.pageInfo.totalResults > 0 {
            let latestVideo = response.items.first { $0.snippet.position == 0 }
            let videoId = latestVideo?.contentDetails.videoId  ?? ""
            
            self.updateUserLatestVideoId(with: videoId)
            YoutubeApiClient.getVideo(with: videoId, completionHandler: handleUserVideoResponse(response:error:))
        }
    }
    
    func updateUserLatestVideoId(with newVideoId: String) {
        if !newVideoId.isEmpty && newVideoId != userYoutubeData["latestVideoId"] {
            dbRference.child("users/\(friendUid)/connectedApps/YouTube").updateChildValues(["latestVideoId": newVideoId])
        }
    }
    
    func handleUserVideoResponse(response: YoutubeApiSchemas.VideosResponse?, error: Error?) {
        guard let response = response else {
            debugPrint(error.debugDescription)
           return
        }
        
        if response.pageInfo.totalResults > 0 {
            guard let latestVideoThumbnail = response.items.first?.snippet.thumbnails.high else {
                return
            }

            let newThumbnailUrlString = latestVideoThumbnail.url
            updateUserLatestThumnailUrl(with: newThumbnailUrlString)
            updateMediaView(with: URL(string: newThumbnailUrlString))
        }
    }
    
    func updateUserLatestThumnailUrl(with newThumbnailUrl: String) {
        if !newThumbnailUrl.isEmpty && newThumbnailUrl != userYoutubeData["latestThumbnailUrl"] {
            dbRference.child("users/\(friendUid)/connectedApps/YouTube").updateChildValues(["latestThumbnailUrl": newThumbnailUrl])
        }
    }
    
    func updateMediaView(with thumbnailUrl: URL?) {
        guard let thumbnailUrl = thumbnailUrl else {
            errorLabel.text = "⚠️ Content unavailable"
            errorLabel.isHidden = false
            return
        }

        do {
            let thumbnailData = try Data(contentsOf: thumbnailUrl)
            mediaImageView.image = UIImage(data: thumbnailData)
            errorLabel.isHidden = true
            thumbnailButton.isEnabled = true
        } catch {
            debugPrint(error.localizedDescription)
            errorLabel.text = "⚠️ Download failed!"
            errorLabel.isHidden = false
        }
    }
    
    func setApiAuthorization() {
        dbRference.child("apps/YouTube").getData { error, snapshot in
            if snapshot.exists() {
                let youtubeData = snapshot.value as! [String: Any]
                let apiKey = youtubeData["apiKey"] as? String
                
                if YoutubeApiClient.apiKey.isEmpty {
                    YoutubeApiClient.apiKey = apiKey ?? ""
                }
            } else {
                debugPrint("Unable to retrieve app data: \(error.debugDescription)")
            }
        }
    }
}
