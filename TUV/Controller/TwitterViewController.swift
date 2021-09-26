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
    fileprivate var friendUid: String!
    fileprivate let dbRference = Database.database().reference()
    fileprivate let currentUser = Auth.auth().currentUser!
    fileprivate var currentUserFriends: [String] = []
    fileprivate var userTwitterData: [String: String] = [:]
    
    // MARK: Outlets
    @IBOutlet weak var visitProfileButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var twitterHandleLabel: UILabel!
    @IBOutlet weak var customTweetView: CustomTweetView!

    // MARK: View States
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBar.barTintColor = self.view.backgroundColor
        
        setApiAuthorization()
    }

    // MARK: Actions
    @IBAction func visitPageTapped(_ sender: UIButton) {
        // TODO: Open user's twitter page
    }
    
    // MARK: Functions
    func setApiAuthorization() {
        dbRference.child("apps/Twitter").getData { error, snapshot in
            if snapshot.exists() {
                let twitterData = snapshot.value as! [String: Any]
                let authorization = twitterData["authorization"] as? String
                TwitterApiClient.authorization = authorization ?? ""
            } else {
                debugPrint("Unable to retrieve app data: \(error.debugDescription)")
            }
            
            self.getCurrentUserFriendsUids()
        }
    }

    func getCurrentUserFriendsUids() {
        dbRference.child("users/\(currentUser.uid)/addedFriends").getData { error, snapshot in
            if snapshot.exists() {
                let friendsUids = (snapshot.value as! [String: Bool]).keys
                let randomUserUid = friendsUids.randomElement()!
                
                self.friendUid = randomUserUid
                self.getFriendTwitterSnapshot(for: self.currentUser.uid)
            } else {
                debugPrint("Unable to retrieve user friends: \(error.debugDescription)")
                self.getFriendTwitterSnapshot(for: self.currentUser.uid)
            }
        }
    }
    
    func getFriendTwitterSnapshot(for userUid: String) {
        dbRference.child("users/\(userUid)/connectedApps/Twitter").getData { error, snapshot in
            if snapshot.exists() {
                self.userTwitterData = snapshot.value as? [String: String] ?? [:]
                self.retrieveUserTweetsByUserId()
            } else {
                debugPrint("Unable to retrieve twitter snaphot: \(error.debugDescription)")
            }
            
            self.retrieveUserTweetsByUserId()
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
            
            updateTweetViewWithExistingUserLatestTweet()
        }
    }

    func updateTweetViewWithExistingUserLatestTweet() {
        let userLatestTweetId = userTwitterData["latestTweetId"]
        
        TwitterApiClient.getTweet(tweetId: userLatestTweetId ?? "") { tweetData, error in
            if error != nil {
                debugPrint(error.debugDescription)
            }
            
            self.updateTweetView(with: tweetData)
        }
    }

    func updateUserLatestTweetId(with newTweetId: String) {
        if userTwitterData["latestTweetId"] != newTweetId {
            dbRference.child("users/\(currentUser.uid)/connectedApps/Twitter").updateChildValues(["latestTweetId": newTweetId])
        }
    }
    
    func updateTweetView(with tweetData: TwitterApiSchemas.TweetData?) {
        let tweetMetrics = tweetData?.publicMetrics
        let tweetText = tweetData?.text ?? "Error retrieving tweet information 😔"
        let likesCount = tweetMetrics?.likeCount ?? 0
        let retweetsCount = tweetMetrics?.retweetCount ?? 0
        let replyCount = tweetMetrics?.replyCount ?? 0

        customTweetView.tweetLabel.text = tweetText.count <= 350 ? tweetText : String(tweetText.prefix(350) + "...")
        customTweetView.likesCountLabel.text = "💙 \(likesCount)"
        customTweetView.retweetsCountLabel.text = "🔁 \(retweetsCount)"
        customTweetView.repliesCountLabel.text = "💬 \(replyCount)"
    }
}
