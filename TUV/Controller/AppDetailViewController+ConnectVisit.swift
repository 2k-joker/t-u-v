//
//  AppDetailViewController+ConnectVisit.swift
//  TUV
//
//  Created by Khalil Kum on 9/26/21.
//

import UIKit

extension AppDetailViewController {
    func connectToApp(of type: Constants.AppType?) {
        // TODO: update these to implement user OAuth flow
        switch type {
        case .twitter:
            connectToTwitter()
        case .youtube:
            connectToYoutube()
        default:
            presentErrorMessage()
        }
    }
    
    func visitApp(of type: Constants.AppType?) {
        if let appType = type {
            getAppData(for: appType) { appData in
                if let appData = appData {
                    HelperMethods.visitPage(for: appType, with: appData, context: .profile)
                } else {
                    self.presentErrorMessage()
                }
            }
        } else {
            presentErrorMessage()
        }
    }

    fileprivate func connectToTwitter() {
        let promptMessage = "Please enter your twitter handle below:"
        
        presentInputView(message: promptMessage) { action, twitterHandle in
            let username = twitterHandle.trim(by: "@")
           
            if action.title != "Cancel" {
                TwitterApiClient.getUser(username: username) { userData, error in
                    if let userData = userData {
                        let update = ["accountId": userData.id, "appUsername": userData.username, "imageName": Constants.AppType.twitter.imageName]

                        self.dbReference.child("users/\(self.currentUser.uid)/connectedApps/Twitter").updateChildValues(update) { error, reference in
                            if error != nil {
                                debugPrint("Error updating user twitter info: \(error.debugDescription)")
                                self.presentErrorMessage()
                            }
                        }
                    } else {
                        if let customError = error as? TwitterApiSchemas.ApiClientError {
                            self.presentErrorMessage(title: customError.title, message: customError.detail)
                        } else {
                            self.presentErrorMessage()
                        }
                    }

                }
            }
        }
    }
    
    func connectToYoutube() {
        let promptMessage = "Please enter your YouTube Channel Id  below:\n(Profile -> Settings -> Advanced settings -> Channel ID)"
        
        presentInputView(message: promptMessage, placeholderText: "e.g ABCxyZabC123Xyz-9aBc") { action, channelId in
            if action.title != "Cancel" {
                YoutubeApiClient.getChannel(with: channelId) { channelResponse, error in
                    if let channelResponse = channelResponse {
                        guard channelResponse.pageInfo.totalResults > 0 else {
                            let channelNotFoundError = "No such channel with Channel ID [\(channelId)]."
                            self.presentErrorMessage(message: channelNotFoundError)
                            return
                        }
                        
                        let channelObject = channelResponse.items.first!
                        let channelId = channelObject.id
                        let playlistId = channelObject.contentDetails.relatedPlaylists.playlistId
                        let update = ["channelId": channelId, "playlistId": playlistId, "imageName": Constants.AppType.youtube.imageName]
                        
                        self.dbReference.child("users/\(self.currentUser.uid)/connectedApps/YouTube").updateChildValues(update) { error, reference in
                            if error != nil {
                                debugPrint("Error updating user youtube info: \(error.debugDescription)")
                                self.presentErrorMessage()
                            }
                        }
                    } else if let customError = error as? YoutubeApiSchemas.ApiClientErrorObject {
                        self.presentErrorMessage(message: customError.message)
                    } else {
                        self.presentErrorMessage()
                    }
                }
            }
        }
    }
    
    func getAppData(for appType: Constants.AppType, completionHandler: @escaping (([String:Any]?) -> Void)) {
        dbReference.child("users/\(currentUser.uid)/connectedApps").getData { error, snapshot in
            if snapshot.exists() {
                let connectedAppsData = snapshot.value as? [String:Any]
                let appData = connectedAppsData?[appType.rawValue] as? [String:String]
                
                if let appData = appData {
                    completionHandler(appData)
                } else {
                    completionHandler(nil)
                }
            } else {
                completionHandler(nil)
            }
        }
    }
    
    fileprivate func presentInputView(message: String, placeholderText: String? = nil, completionHandler: @escaping ((UIAlertAction, String) -> Void)) {
        let alertVC = UIAlertController(title: nil, message: message, preferredStyle: .alert)

        alertVC.addTextField { textField in
            textField.placeholder = placeholderText ?? "e.g @my_handle"
        }
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in completionHandler(action, "") }))
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if let textFieldText = alertVC.textFields?.first?.text {
                completionHandler(action, textFieldText)
            } else {
                completionHandler(action, "")
            }
        }))
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    fileprivate func presentErrorMessage(title: String? = nil, message: String = Constants.UIAlertMessage.authFailure(.connectApp).description) {
        let alertVC = UIAlertController(title: title ?? "Error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
}
