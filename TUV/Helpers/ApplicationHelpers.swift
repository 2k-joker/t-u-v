//
//  ApplicationHelpers.swift
//  TUV
//
//  Created by Khalil Kum on 8/21/21.
//

import UIKit
import FirebaseDatabase

class HelperMethods {
    static let usernameKey = "userName"
    static let dbReference: DatabaseReference = Database.database().reference()
    
    class func setUserDefault(forKey key: Constants.UserDefaultKey, withValue value: String?) {
        UserDefaults.standard.setValue(value, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    class func getUserDefault(forKey key: Constants.UserDefaultKey) -> String {
        return UserDefaults.standard.string(forKey: key.rawValue) ?? ""
    }

    class func sanitizeText(_ text: String, characterSet: CharacterSet = .whitespacesAndNewlines) -> String {
        return text.trimmingCharacters(in: characterSet)
    }
    
    class func splitFriendShipKey(_ key: String) -> [String] {
        return key.split(separator: "+").map { String($0) }
    }
    
    class func validateInput(input: String?, type: Constants.RegexPatterns) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", type.pattern)
        
        return predicate.evaluate(with: input)
    }
    
    class func setAppsAuthSettings() {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let twitterVC = mainStoryBoard.instantiateViewController(withIdentifier: Constants.AppType.twitter.controllerIdentifier) as! TwitterViewController
        let youtubeVC = mainStoryBoard.instantiateViewController(withIdentifier: Constants.AppType.youtube.controllerIdentifier) as! YoutubeViewController
        
        twitterVC.setApiAuthorization()
        youtubeVC.setApiAuthorization()
    }
    
    class func visitPage(for appType: Constants.AppType, with appData: [String:Any] = [:], context: Constants.AppUrlContext = .specificContent) {
        var url: URL {
            ApplicationBuilders.buildAppUrl(for: appType, with: appData, context: context)
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    class func makeAttributedBoldString(for textToBold: String, from text: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        let rangeToBold = NSRange(text.range(of: textToBold)!, in: text)
        
        attributedString.addAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)], range: rangeToBold)
        return attributedString
    }
    
    class func configureTimeoutObserver(withTimeoutSeconds interval: TimeInterval = 30, completionHandler: @escaping (() -> Void)) -> Timer {
        Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in
            completionHandler()
        }
    }
}

protocol FriendCell {
    static var reuseIdentifier: String { get set }
    static var friendImageView: UIImageView { get }
    static var usernameLabel: String { get }
    static var detailsLabel: String { get }
}

extension FriendCell {
    static var friendImageView: UIImageView {
        return self.friendImageView
    }
    
    static var usernameLabel: String {
        return self.usernameLabel
    }
    
    static var detailsLabel: String {
        return self.detailsLabel
    }
}

protocol ButtonDelegate: AnyObject {
    func addFriendButtonTapped(_ button: UIButton, touchPoint: CGPoint?)
    func profileImageTapped(_ button: UIButton, touchPoint: CGPoint?)
}

extension ButtonDelegate {
    func addFriendButtonTapped(_ button: UIButton, touchPoint: CGPoint?) {
        () // Do nothing if not overwritten (i.e make optional)
    }
}

extension String {
    func trim(by character: String) -> String {
        return self.trimmingCharacters(in: .init(charactersIn: "@"))
    }
}
