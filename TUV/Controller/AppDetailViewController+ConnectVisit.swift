//
//  AppDetailViewController+ConnectVisit.swift
//  TUV
//
//  Created by Khalil Kum on 9/26/21.
//

import UIKit

extension AppDetailViewController {
    func connectToApp(of type: Constants.AppType) {
        switch type {
        case .instagram:
            ()
        case .twitter:
            connectToTwitter()
        case .youtube:
            ()
        }
    }

    fileprivate func connectToTwitter() {
        presentInputView { twitterHandle in
            let username = twitterHandle.trim(by: "@")
           
            TwitterApiClient.getUser(username: username) { userData, error in
                if let userData = userData {
                    let update = ["accountId": userData.id, "username": userData.username]
                    let failureMessage = "Failed to connect your twitter account. Please check your input and connection."

                    self.dbReference.child("users/\(self.currentUser.uid)/connectedApps/Twitter").updateChildValues(update) { error, reference in
                        if error != nil {
                            debugPrint("Error updating user twitter info: \(error.debugDescription)")
                            self.presentErrorMessage(message: failureMessage)
                        }
                    }
                } else {
                    self.presentErrorMessage(message: error.debugDescription)
                }

            }
        }
    }
    
    fileprivate func presentInputView(completionHandler: @escaping ((String) -> Void)) {
        let alertVC = UIAlertController(title: nil, message: "Please enter your twitter handle below.", preferredStyle: .alert)
        alertVC.addTextField { textField in
            textField.placeholder = "e.g @my_handle"
        }
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in completionHandler("") }))
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if let textFieldText = alertVC.textFields?.first?.text {
                DispatchQueue.main.async {
                    completionHandler(textFieldText)
                }
            } else {
                DispatchQueue.main.async {
                    completionHandler("")
                }
            }
        }))
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    fileprivate func presentErrorMessage(message: String) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
}
