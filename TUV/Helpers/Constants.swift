//
//  Constants.swift
//  TUV
//
//  Created by Khalil Kum on 8/21/21.
//

import Foundation

class Constants {
    enum UserDefaultKey: String {
        case usernameKey = "userName"
        case emailKey = "email"
    }

    enum AppType: String {
        case instagram = "Instagram"
        case twitter = "Twitter"
        case youtube = "YouTube"

        var controllerIdentifier: String {
            return "\(self.rawValue)ViewController"
        }
        
        var imageName: String {
            return "round_\(self.rawValue.lowercased())_logo"
        }        
    }
    
    enum AppUrlContext {
        case specificContent, profile
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
        case resetLinkSent
        case resetLinkFailed
        
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
                return "Username should be between 4 to 20 characters. Only numbers, letters, underscores and dashes(-) are allowed."
            case .usernameTaken(let username):
                return "\(username) is already taken."
            case .unverifiedUsername:
                return "Username verification failed. Please try again."
            case .weakPassword:
                return "Password should be at least 8 characters, and contain uppercase, lowercase and special characters."
            case .resetLinkSent:
                return "Reset link sent ???"
            case .resetLinkFailed:
                return "Failed to send reset link ???"
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
                return "^[0-9A-Za-z_-]{4,20}$"

            }
        }
        
    }

    enum UIAlertMessage {
        case authFailure(AuthType)
        case invalidLogin
        case emailVerificationSent(String)
        case verifyEmail
        case updateSuccessful
        case updateFailed
        case removeFriendFailed(String)
        case loadDataFailed
        case noConnectedAppsFound
        case connectionTimeout
        
        var description: String {
            switch self {
            case .authFailure(let authType):
                return "Failed to \(authType.action)\nPlease check your input and connection."
            case .invalidLogin:
                return "Invalid username or password"
            case .emailVerificationSent(let email):
                return "Email verification link sent to: \(email)"
            case .verifyEmail:
                return "Email verification required before signing in."
            case .updateSuccessful:
                return "Update successful ???"
            case .updateFailed:
                return "Update failed ???\nPlease try again."
            case .removeFriendFailed(let friendUsername):
                return "Failed to remove \(friendUsername).\nPlease check your connection and try again."
            case .loadDataFailed:
                return "Failed to load information.\nPlease check your connection and try again."
            case .noConnectedAppsFound:
                return "No connected apps found.\nMust have at least 1 app connected."
            case .connectionTimeout:
                return "An error occured due to very poor or no internet connection."
            }
        }
    }

    enum AuthType {
        case login
        case logout
        case signup
        case updatePassword
        case updateEmail
        case sendVerificationLink
        case connectApp
        
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
            case .sendVerificationLink:
                return "send email verification link."
            case .connectApp:
                return "connect to app."
            }
        }
    }
}
