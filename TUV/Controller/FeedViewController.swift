//
//  FeedViewController.swift
//  TUV
//
//  Created by Khalil Kum on 8/16/21.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class FeedViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    // MARK: Properties
    fileprivate let currentUser = Auth.auth().currentUser!
    fileprivate var currentUserFriends: [String]?
    fileprivate var pageControl: UIPageControl = UIPageControl()
    private(set) lazy var feedChildViewControllers: [UIViewController?] = {
        return [
            newChildViewController(storyboardId: "TwitterViewController"),
            newChildViewController(storyboardId: "InstagramViewController"),
            newChildViewController(storyboardId: "YoutubeViewController")
        ]
    }()
    
    // MARK: Outlets
    @IBOutlet weak var profileBarButton: UIBarButtonItem!
    @IBOutlet weak var friendsBarButton: UIBarButtonItem!
    
    // MARK: View States
    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        self.delegate = self
        
        if let firstViewController = feedChildViewControllers.first {
            setViewControllers([firstViewController!], direction: .forward, animated: true, completion: nil)
        }
        
        configurePageControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        profileBarButton.tintColor = UIColor.white
        friendsBarButton.tintColor = UIColor.white
        friendsBarButton.isEnabled = false
        getCurrentUserFriends()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "profileSegue":
            let profileVC = segue.destination as! ProfileViewController
            
            profileVC.userUid = currentUser.uid
            
        case "friendsSegue":
            let friendsVC = segue.destination as! FriendsViewController
            
            friendsVC.addedFriends = currentUserFriends ?? []
        default:
            () // Do nothing
        }
    }

    // MARK: Actions
    @IBAction func profileTapped(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func friendsTapped(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "friendsSegue", sender: sender)
    }
    
    // MARK: Functions
    func getCurrentUserFriends() {
        Database.database().reference().child("users/\(currentUser.uid)/addedFriends").getData { error, snapshot in
            if error != nil {
                debugPrint("Error getting user's friends: \(error.debugDescription)")
                self.friendsBarButton.isEnabled = true
            } else if snapshot.exists() {
                let snapshotData = snapshot.value as! [String:Bool]

                self.currentUserFriends = snapshotData.keys.map { $0 }
                self.friendsBarButton.isEnabled = true
            } else {
                self.friendsBarButton.isEnabled = true
            }
        }
    }

    private func newChildViewController(storyboardId: String) -> UIViewController {
        return storyboard!.instantiateViewController(withIdentifier: storyboardId)
    }
    
    func configurePageControl() {
        pageControl = HelperMethods.configurePageControl(numberOfPages: feedChildViewControllers.count)
        self.view.addSubview(pageControl)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let firstVC = viewControllers?.first else { return }
        self.pageControl.currentPage = feedChildViewControllers.firstIndex(of: firstVC) ?? 0
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentViewControllerIndex = feedChildViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = currentViewControllerIndex - 1
        
        guard feedChildViewControllers.count > previousIndex else { return nil }

        guard previousIndex >= 0 else {
            return feedChildViewControllers.last!
        }
        
        return feedChildViewControllers[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentViewControllerIndex = feedChildViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = currentViewControllerIndex + 1
        
        guard feedChildViewControllers.count > nextIndex else {
            return feedChildViewControllers.first!
        }
        
        return feedChildViewControllers[nextIndex]
    }
}
