//
//  AppDetailViewController.swift
//  TUV
//
//  Created by Khalil Kum on 8/24/21.
//

import Foundation
import UIKit

class AppDetailViewController: UIViewController {
    // MARK: Properties
    var app: App?
    
    // MARK: Outlets
    @IBOutlet weak var appImageView: UIImageView!
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var connectVisitButton: UIButton!
    @IBOutlet weak var favoriteActionLabel: UILabel!
    @IBOutlet weak var disconnectStackView: UIStackView!
    
    // MARK: View States
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        appImageView.image = app!.image
        appNameLabel.text = app!.name
        
        // TODO: Check if app is current user's favorite
        configureFavoriteState(isFavorite: false)
        
        // TODO: Check if current user has connected app
        configureConnectedState(connected: true)
    }
    
    // MARK: Actions
    @IBAction func favoriteTapped(_ sender: UIButton) {
        if app!.favorite {
            // TODO: update app attribute
            app!.favorite = false
            configureFavoriteState(isFavorite: app!.favorite)
        } else {
            // TODO: update app attribute
            app!.favorite = true
            configureFavoriteState(isFavorite: app!.favorite)
        }
    }
    
    @IBAction func disconnectTapped(_ sender: UIButton) {
        // TODO: Remove app from current user
        
        // TODO: Add app to the available apps list
        
        debugPrint("\(app!.name) disconnected")
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: Functions
    func configureConnectedState(connected: Bool) {
        disconnectStackView.isHidden = !connected
        
        if connected {
            connectVisitButton.setImage(UIImage(named: "visit_page_button_purple"), for: .normal)
        } else {
            connectVisitButton.setImage(UIImage(named: "connect_button"), for: .normal)
        }
    }
    
    func configureFavoriteState(isFavorite: Bool) {
        if isFavorite {
            favoriteButton.setImage(UIImage(named: "favorite_filled"), for: .normal)
            favoriteActionLabel.text = "Unmark Favorite"
        } else {
            favoriteButton.setImage(UIImage(named: "favorite_outlined"), for: .normal)
            favoriteActionLabel.text = "Mark Favorite"
        }
    }
}
