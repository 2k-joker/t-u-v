//
//  YoutubeViewController.swift
//  TUV
//
//  Created by Khalil Kum on 8/16/21.
//

import Foundation
import UIKit

class YoutubeViewController: UIViewController {
    // MARK: Properties
    
    // MARK: Outlets
    @IBOutlet weak var visitPageButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var youtubeHandleLabel: UILabel!
    @IBOutlet weak var mediaImageView: UIImageView!
    
    // MARK: View States
    override func viewDidLoad() {
        super.viewDidLoad()        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBar.barTintColor = self.view.backgroundColor
        
        // TODO: Update user profile image (Youtube image?)
        // TODO: Update user username (Youtube handle?)
    }
    
    // MARK: Actions
    @IBAction func visitPageTapped(_ sender: UIButton) {
        // TODO: Open user's youtube page
    }
    
    // MARK: Functions
}
