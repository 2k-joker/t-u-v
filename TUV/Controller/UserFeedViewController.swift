//
//  UserFeedViewController.swift
//  TUV
//
//  Created by Khalil Kum on 8/26/21.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class UserFeedViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate  {
    // MARK: Properties
    var userConnectedApps: DataSnapshot!
    var userUid: String!
    fileprivate var pageControl: UIPageControl = UIPageControl()
    fileprivate var feedChildViewControllers: [UIViewController?]!
    
    // MARK: View States
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self
        
        populateFeedChildViewControllers()
        
        if let firstViewController = feedChildViewControllers.first {
            setViewControllers([firstViewController!], direction: .forward, animated: true, completion: nil)
        }
        
        configurePageControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: Functions
    private func buildChildViewControllers(from appNames: [String]) -> [UIViewController] {
        var viewControllers: [UIViewController] = []
        
        for appName in appNames {
            let viewController = storyboard!.instantiateViewController(withIdentifier: "\(appName)ViewController")
            viewControllers.append(viewController)
        }
        
        return viewControllers
    }
    
    private func populateFeedChildViewControllers() {
        let appNames = (userConnectedApps.value as! [String:Any]).map { $0.key }
        feedChildViewControllers = buildChildViewControllers(from: appNames)
    }
    
    private func configurePageControl() {
        pageControl = ApplicationBuilders.buildPageControl(withNumberOfPages: feedChildViewControllers.count)
        
        if feedChildViewControllers.count > 1 {
            self.view.addSubview(pageControl)
        }
    }
    
    // MARK: Page view delegates
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let firstVC = viewControllers?.first else { return }
        self.pageControl.currentPage = feedChildViewControllers.firstIndex(of: firstVC) ?? 0
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentViewControllerIndex = feedChildViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        guard feedChildViewControllers.count > 1 else { return nil }
        
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
        
        guard feedChildViewControllers.count > 1 else { return nil }
        
        let nextIndex = currentViewControllerIndex + 1
        
        guard feedChildViewControllers.count > nextIndex else {
            
            return feedChildViewControllers.first!
        }
        
        return feedChildViewControllers[nextIndex]
    }
}
