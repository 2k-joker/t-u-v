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
    fileprivate let dbReference = Database.database().reference()
    fileprivate var currentUserFriends: [String]?
    fileprivate var pageControl: UIPageControl = UIPageControl()
    private(set) lazy var feedChildViewControllers: [UIViewController?] = {
        return [
            newChildViewController(storyboardId: "TwitterViewController"),
            // newChildViewController(storyboardId: "InstagramViewController"),
            newChildViewController(storyboardId: "YouTubeViewController")
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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "profileSegue":
            let profileVC = segue.destination as! ProfileViewController
            
            profileVC.userUid = currentUser.uid
            
        case "friendsSegue":
            let friendsVC = segue.destination as! FriendsViewController
            
            friendsVC.addedFriendsUids = currentUserFriends ?? []
        default:
            () // Do nothing
        }
    }

    // MARK: Actions
    @IBAction func profileTapped(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func friendsTapped(_ sender: UIBarButtonItem) {
        getUserFriendsAndSegue()
    }
    
    // MARK: Functions
    func getUserFriendsAndSegue() {
        Database.database().reference().child("users/\(currentUser.uid)").getData { error, snapshot in
            if error != nil {
                debugPrint("Error getting user's friends: \(error.debugDescription)")
            } else if snapshot.exists() {
                let snapshotData = snapshot.value as! [String:Any]
                let addedFriends = snapshotData["addedFriends"] as? [String:Any]

                self.currentUserFriends = addedFriends?.keys.map { $0 }
            }
            
            self.performSegue(withIdentifier: "friendsSegue", sender: nil)
        }
    }

    private func newChildViewController(storyboardId: String) -> UIViewController {
        return storyboard!.instantiateViewController(withIdentifier: storyboardId)
    }
    
    func configurePageControl() {
        pageControl = ApplicationBuilders.buildPageControl(withNumberOfPages: feedChildViewControllers.count)
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
