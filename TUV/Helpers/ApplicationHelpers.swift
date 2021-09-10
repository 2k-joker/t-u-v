//
//  ApplicationHelpers.swift
//  TUV
//
//  Created by Khalil Kum on 8/21/21.
//

import UIKit

class App {
    var image: UIImage?
    var name: String
    var favorite: Bool = false
    
    
    init(type: Constants.AppTypes) {
        self.image = UIImage(named: "round_\(type.rawValue.lowercased())_logo")
        self.name = type.rawValue
    }
}

class HelperMethods {
    class func sanitizeText(_ text: String, characterSet: CharacterSet = .whitespacesAndNewlines) -> String {
        return text.trimmingCharacters(in: characterSet)
    }
    
    class func resetNavigationBarTintColor(viewController: UIViewController) {
        let feedVC = viewController.storyboard!.instantiateViewController(withIdentifier: "FeedViewController") as! FeedViewController
        viewController.navigationController?.navigationBar.barTintColor = feedVC.navigationController?.navigationBar.barTintColor
    }
    
    class func configurePageControl(numberOfPages: Int) -> UIPageControl {
        let pageControl = UIPageControl(frame: CGRect(x: 0, y: UIScreen.main.bounds.maxY - 60, width: UIScreen.main.bounds.width, height: 50))
        pageControl.numberOfPages = numberOfPages
        pageControl.currentPage = 0
        pageControl.tintColor = UIColor.white
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .white
        
        return pageControl
    }
    
    class func validateInput(input: String?, type: Constants.RegexPatterns) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", type.pattern)
        
        return predicate.evaluate(with: input)
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
    func addFriendButtonTapped(_ button: UIButton)
    func profileImageTapped(_ button: UIButton, touchPoint: CGPoint?)
}

extension ButtonDelegate {
    func addFriendButtonTapped(_ button: UIButton) {
        () // Do nothing (i.e make optional)
    }
}
