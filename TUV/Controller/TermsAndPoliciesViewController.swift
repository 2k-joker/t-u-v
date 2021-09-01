//
//  TermsAndPoliciesViewController.swift
//  TUV
//
//  Created by Khalil Kum on 8/23/21.
//

import Foundation
import UIKit

class TermsAndPoliciesViewController: UIViewController, UIScrollViewDelegate {
    // MARK: Properties
    
    // MARK: Outlets
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: View States
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        doneButton.setTitleColor(.lightGray, for: .disabled)
//        doneButton.isEnabled = false
        
        // TODO: set label text
    }
    
    // MARK: Actions
    @IBAction func doneTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Functions
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        doneButton.isEnabled = true
//    }
    
}
