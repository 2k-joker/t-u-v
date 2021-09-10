//
//  Constants.swift
//  TUV
//
//  Created by Khalil Kum on 8/21/21.
//

import Foundation

class Constants {
    enum AppTypes: String {
        case instagram = "Instagram"
        case twitter = "Twitter"
        case youtube = "YouTube"
        
        var controllerIdentifier: String {
            switch self {
            case .instagram:
                return "InstagramViewController"
            case .twitter:
                return "TwitterViewController"
            case .youtube:
                return "YoutubeViewController"
            }
        }
        
    }

    struct AppViewControllerIndentifier {
        static let twitter = "TwitterViewController"
        static let instagram = "InstagramViewController"
        static let youtube = "YoutubeViewController"
    }
    
    enum FormErrors {
        case emptyEmail
        case emptyUsername
        case emptyPassword
        case emptyCode
        case passwordMismatch
        case invalidEmail
        case invalidMobileNumber
        case invalidUsername
        case usernameTaken(String)
        case unverifiedUsername
        case weakPassword
        case verifiedEmail
        case unverifiedEmail
        
        var message: String {
            switch self {
            case .emptyEmail:
                return "Email cannot be empty."
            case .emptyUsername:
                return "Username cannot be empty."
            case .emptyPassword:
                return "Password cannot be empty."
            case .emptyCode:
                return "Code cannot be empty."
            case .passwordMismatch:
                return "Password does not match."
            case .invalidEmail:
                return "Email is invalid."
            case .invalidMobileNumber:
                return "Mobile number is invalid."
            case .invalidUsername:
                return "Username should be between 4 to 20 characters."
            case .usernameTaken(let username):
                return "\(username) is already taken."
            case .unverifiedUsername:
                return "Username verification failed. Please try again."
            case .weakPassword:
                return "Password should be at least 8 characters, and contain uppercase, lowercase and special characters."
            case .verifiedEmail:
                return "Email verified ✓"
            case .unverifiedEmail:
                return "Email verification failed ✗"
            }
        }
        
    }
    
    enum RegexPatterns {
        case email
        case mobileNumber
        case password
        case username
        
        var pattern: String {
            switch self {
            case .email:
                return "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
            case .mobileNumber:
                return #"^\(?\d{3}\)?[ -]?\d{3}[ -]?\d{4}$"#
            case .password:
                return "^(?=.*[a-z])(?=.*[$@$#!%*?&])(?=.*[A-Z]).{8,}$"
            case .username:
                return "^\\w{4,20}$"

            }
        }
        
    }
    
    enum UIAlertMessage {
        case authFailure(AuthType)
        case invalidLogin
        case verifyEmail
        case updateSuccessful
        case updateFailed
        case removeFriendFailed(String)
        
        var description: String {
            switch self {
            case .authFailure(let authType):
                return "Failed to \(authType.action)\nPlease check your connection and try again."
            case .invalidLogin:
                return "Invalid username or password"
            case .verifyEmail:
                return "You have to verify your new email before it gets updated."
            case .updateSuccessful:
                return "Update successful ✓"
            case .updateFailed:
                return "Update failed ✗\nPlease try again.4"
            case .removeFriendFailed(let friendUsername):
                return "Failed to remove \(friendUsername).\nPlease check your connection and try again."
            }
        }
    }
    
    enum AuthType {
        case login
        case logout
        case signup
        case updatePassword
        case updateEmail
        
        var action: String {
            switch self {
            case .login:
                return "log in user."
            case .logout:
                return "log out user."
            case .signup:
                return "complete sign up process."
            case .updatePassword:
                return "update password."
            case .updateEmail:
                return "update email."
            }
        }
    }
}
