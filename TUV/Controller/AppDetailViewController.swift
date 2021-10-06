//
//  AppDetailViewController.swift
//  TUV
//
//  Created by Khalil Kum on 8/24/21.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class AppDetailViewController: UIViewController {
    // MARK: Properties
    var selectedAppSnapshot: DataSnapshot!
    let currentUser = Auth.auth().currentUser!
    let dbReference = Database.database().reference()
    fileprivate var selectedAppData: [String:Any]!
    fileprivate var _refFavoriteChangedHandle: DatabaseHandle!
    fileprivate var _refSelectedChangedHandle: DatabaseHandle!
    fileprivate var selectedAppsPath: String!
    fileprivate var isCurrentUserFavorite: Bool! = false
    fileprivate var isCurrentUserConnected: Bool! = false
    
    // MARK: Outlets
    @IBOutlet weak var appImageView: UIImageView!
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var connectVisitButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var connectionsNoticeLabel: UILabel!
    @IBOutlet weak var favoriteActionLabel: UILabel!
    @IBOutlet weak var favoriteStackView: UIStackView!
    @IBOutlet weak var disconnectStackView: UIStackView!
    
    // MARK: View States
    override func viewDidLoad() {
        super.viewDidLoad()
        
        favoriteStackView.isHidden = true
        favoriteStackView.isHidden = true
        errorLabel.isHidden = true

        parseAppData()
        configureSelectedChangedHandler()
        configureFavoriteChangedHandler()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        appImageView.image = UIImage(named: selectedAppData["imageName"] as! String)
        appNameLabel.text = selectedAppSnapshot.key
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        dbReference.child("favoriteApps").removeObserver(withHandle: _refFavoriteChangedHandle)
        dbReference.child("users/\(currentUser.uid)/connectedApps").removeObserver(withHandle: _refSelectedChangedHandle)
    }

    // MARK: Actions
    @IBAction func connectVisitTapped(_ sender: UIButton) {
        let appType = Constants.AppType.init(rawValue: selectedAppSnapshot.key)

        activityIndicator.startAnimating()
        
        if isCurrentUserConnected {
            visitApp(of: appType)
        } else {
            connectToApp(of: appType)
        }
    }

    @IBAction func favoriteTapped(_ sender: UIButton) {
        var favoriteAppName: String {
            if isCurrentUserFavorite {
                return "N/A"
            } else {
                return selectedAppSnapshot.key
            }
        }
        
        updateCurrentUserFavoriteApp(with: favoriteAppName)
    }

    @IBAction func disconnectTapped(_ sender: UIButton) {
        dbReference.child("\(selectedAppsPath!)/\(selectedAppSnapshot.key)").removeValue { error, reference in
            if error != nil {
                debugPrint(error.debugDescription)
            } else {
                self.updateCurrentUserFavoriteApp(with: "N/A")
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    // MARK: Functions
    func configureFavoriteChangedHandler() {
        _refFavoriteChangedHandle = dbReference.child("favoriteApps").observe(.childChanged) { snapshot in
            self.setIsCurrentUserFavorite()
        }
    }
    
    func configureSelectedChangedHandler() {
        _refSelectedChangedHandle = dbReference.child("users/\(currentUser.uid)/connectedApps").observe(.value) { snapshot in
            self.setIsCurrentUserConnected()
        }
    }
    
    func updateCurrentUserFavoriteApp(with newFavoriteAppName: String) {
        dbReference.child("favoriteApps").updateChildValues([currentUser.uid: newFavoriteAppName]) { error, reference in
            if error != nil {
                debugPrint(error.debugDescription)
            }
        }
    }
    
    func updateCurrentUserConnectedApps(with newAppAppInfo: [String: Any]) {
        dbReference.child("users/\(currentUser.uid)/connectedApps").updateChildValues([self.selectedAppSnapshot.key: newAppAppInfo]) { error, reference in
            if error != nil {
                debugPrint(error.debugDescription)
            } else {
                self.updateConnectedUsersForCurrentApp()
            }
        }
    }
    
    func updateConnectedUsersForCurrentApp() {
        dbReference.child("apps/\(selectedAppSnapshot.key)/connectedUsers").updateChildValues([currentUser.uid: true]) { error, reference in
            if error != nil {
                debugPrint(error.debugDescription)
            }
        }
    }
    
    func setConnectionsStatusLabelText() {
        let connectedUsers = (selectedAppData["connectedUser"] as? [String:Any])?.keys.count ?? 0

        if connectedUsers > 5 {
            connectionsNoticeLabel.text = "\(connectedUsers) connected users!"
        } else {
            if isCurrentUserConnected {
                connectionsNoticeLabel.text = "You are one of the first to connect!"
            } else {
                connectionsNoticeLabel.text = "Be one of the first to connect!"
            }
        }
    }

    func parseAppData() {
        selectedAppsPath = "users/\(currentUser.uid)/connectedApps"
        selectedAppData = selectedAppSnapshot.value as? [String:Any]
    }

    func configureCurrentUserAppDetails() {
        if isCurrentUserConnected {
            self.configureConnectedState(true)
            self.configureFavoriteState(self.isCurrentUserFavorite)
        } else {
            self.favoriteStackView.isHidden = true
            self.configureConnectedState(false)
        }
    }

    func setIsCurrentUserFavorite() {
        let query = dbReference.child("favoriteApps").queryOrderedByKey().queryEqual(toValue: currentUser.uid)
        
        FirebaseClient.retrieveDataFromFirebase(forQuery: query) { timedout, error, snapshot in
            if timedout {
                self.connectionsNoticeLabel.isHidden = true
                self.errorLabel.text = Constants.UIAlertMessage.connectionTimeout.description
                self.errorLabel.isHidden = false
            } else if error != nil {
                debugPrint(error.debugDescription)
                self.connectionsNoticeLabel.isHidden = true
                self.errorLabel.text = Constants.UIAlertMessage.loadDataFailed.description
                self.errorLabel.isHidden = false
            } else if let snapshot = snapshot {
                let currentUserfavoriteApp = (snapshot.value as! [String:String]).first!
                
                let favoriteAppName = currentUserfavoriteApp.value
                
                self.isCurrentUserFavorite = favoriteAppName == self.selectedAppSnapshot.key
            }
            
            self.configureCurrentUserAppDetails()
        }
    }

    func setIsCurrentUserConnected() {
        let query = dbReference.child(selectedAppsPath).queryOrderedByKey().queryEqual(toValue: selectedAppSnapshot.key)
        
        FirebaseClient.retrieveDataFromFirebase(forQuery: query) { timedout, error, snapshot in
            if timedout {
                self.connectVisitButton.isEnabled = false
                self.disconnectStackView.isHidden = true
                self.favoriteStackView.isHidden = true
                self.connectionsNoticeLabel.isHidden = true
                self.errorLabel.text = Constants.UIAlertMessage.connectionTimeout.description
                self.errorLabel.isHidden = false
            } else if snapshot != nil {
                self.isCurrentUserConnected = true
                self.setConnectionsStatusLabelText()
                self.setIsCurrentUserFavorite()
            } else {
                debugPrint(error.debugDescription)
                self.connectVisitButton.isEnabled = false
                self.disconnectStackView.isHidden = true
                self.favoriteStackView.isHidden = true
                self.connectionsNoticeLabel.isHidden = true
                self.errorLabel.text = Constants.UIAlertMessage.loadDataFailed.description
                self.errorLabel.isHidden = false
            }
        }
    }

    func configureConnectedState(_ connected: Bool) {
        if connected {
            connectVisitButton.setImage(UIImage(named: "visit_page_button_purple"), for: .normal)
        } else {
            connectVisitButton.setImage(UIImage(named: "connect_button"), for: .normal)
        }
        
        disconnectStackView.isHidden = !connected
        favoriteStackView.isHidden = !connected
    }
    
    func configureFavoriteState(_ isFavorite: Bool) {
        if isFavorite {
            favoriteButton.setImage(UIImage(named: "favorite_filled"), for: .normal)
            favoriteActionLabel.text = "Unmark Favorite"
        } else {
            favoriteButton.setImage(UIImage(named: "favorite_outlined"), for: .normal)
            favoriteActionLabel.text = "Mark Favorite"
        }
    }
}
