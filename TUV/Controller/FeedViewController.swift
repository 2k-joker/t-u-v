//
//  FeedViewController.swift
//  TUV
//
//  Created by Khalil Kum on 8/16/21.
//

import UIKit

class FeedViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    // MARK: Properties
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
    }

    // MARK: Actions
    @IBAction func profileTapped(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func friendsTapped(_ sender: UIBarButtonItem) {
    }
    
    // MARK: Functions
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

