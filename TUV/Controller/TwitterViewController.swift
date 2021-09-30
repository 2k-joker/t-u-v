//
//  TwitterViewController.swift
//  TUV
//
//  Created by Khalil Kum on 8/16/21.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class TwitterViewController: UIViewController {
    //MARK: Properties
    fileprivate var friendUid: String = ""
    fileprivate let dbRference = Database.database().reference()
    fileprivate let currentUser = Auth.auth().currentUser!
    fileprivate var currentUserFriends: [String] = []
    fileprivate var userTwitterData: [String: String] = [:]
    
    // MARK: Outlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var customTweetView: CustomTweetView!
    @IBOutlet var tweetViewTapRecognizer: UITapGestureRecognizer!

    // MARK: View States
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendUid = (self.parent as? UserFeedViewController)?.userUid ?? ""
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBar.barTintColor = self.view.backgroundColor
        tweetViewTapRecognizer.isEnabled = false
        
        if friendUid.isEmpty {
            getCurrentUserFriendsUids()
        } else {
            getSnapshotForFriend(with: friendUid)
        }
    }

    // MARK: Actions
    @IBAction func tweetViewTapped(_ sender: UITapGestureRecognizer) {
        HelperMethods.visitPage(for: .twitter, with: userTwitterData)
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
                self.userTwitterData = connectedAppsData?["Twitter"] as? [String: String] ?? [:]
                self.updateTweetViewWithUserExistingLatestTweet()
            } else {
                debugPrint("Unable to retrieve friend snapshot: \(error.debugDescription)")
            }
            
            self.retrieveUserTweetsByUserId()
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

    func retrieveUserTweetsByUserId() {
        let userId = userTwitterData["accountId"] ?? ""
 
        TwitterApiClient.getUserTweets(userId: userId, completionHandler: handleUserTweetsResponse(response:error:))
    }
    
    func handleUserTweetsResponse(response: TwitterApiSchemas.TweetsResponse?, error: Error?) {
        if let response = response {
            let newestTweetId = response.tweetsMetadata.newestId
            let newestTweetData = response.tweetsData.first { $0.id == newestTweetId }

            updateUserLatestTweetId(with: newestTweetId)
            updateTweetView(with: newestTweetData!)

        } else {
            debugPrint(error.debugDescription)
        }
    }

    func updateUserLatestTweetId(with newTweetId: String) {
        if userTwitterData["latestTweetId"] != newTweetId {
            let userUid = friendUid.isEmpty ? currentUser.uid : friendUid
            dbRference.child("users/\(userUid)/connectedApps/Twitter").updateChildValues(["latestTweetId": newTweetId])
        }
    }

    func updateTweetViewWithUserExistingLatestTweet() {
        let userLatestTweetId = userTwitterData["latestTweetId"]
        
        TwitterApiClient.getTweet(tweetId: userLatestTweetId ?? "") { tweetData, error in
            if error != nil {
                debugPrint(error.debugDescription)
                self.updateTweetView(with: nil)
            }
            
            self.updateTweetView(with: tweetData)
        }
    }
    
    func updateTweetView(with tweetData: TwitterApiSchemas.TweetData?) {
        let tweetMetrics = tweetData?.publicMetrics
        let tweetText = tweetData?.text ?? "Unable to retrieve tweet information 🤷🏽‍♂️"
        let likesCount = tweetMetrics?.likeCount ?? 0
        let retweetsCount = tweetMetrics?.retweetCount ?? 0
        let replyCount = tweetMetrics?.replyCount ?? 0

        customTweetView.tweetLabel.text = tweetText.count <= 350 ? tweetText : String(tweetText.prefix(350) + "...")
        customTweetView.likesCountLabel.text = "💙 \(likesCount)"
        customTweetView.retweetsCountLabel.text = "🔁 \(retweetsCount)"
        customTweetView.repliesCountLabel.text = "💬 \(replyCount)"
        
        tweetViewTapRecognizer.isEnabled = true
    }
    
    func setApiAuthorization() {
        dbRference.child("apps/Twitter").getData { error, snapshot in
            if snapshot.exists() {
                let twitterData = snapshot.value as! [String: Any]
                let authorization = twitterData["authorization"] as? String
                
                if TwitterApiClient.authorization.isEmpty {
                    TwitterApiClient.authorization = authorization ?? ""
                }
            } else {
                debugPrint("Unable to retrieve app data: \(error.debugDescription)")
            }
        }
    }
}
