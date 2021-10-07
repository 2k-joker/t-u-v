//
//  LoginViewController.swift
//  TUV
//
//  Created by Khalil Kum on 8/16/21.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {
    // MARK: Properties
    fileprivate let credsVerificationSegue = "verificationSegue"
    fileprivate var currentUser: User!
    fileprivate let dbReference = Database.database().reference()
    fileprivate var currentUserEmail: String = ""

    // MARK: Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var resetPasswordButton: UIButton!
    @IBOutlet weak var loginActivity: UIActivityIndicatorView!
    @IBOutlet weak var signupButton: UIButton!
    
    // MARK: View States
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        signupButton.setTitleColor(.lightGray, for: .disabled)
        usernameTextField.text = HelperMethods.getUserDefault(forKey: .usernameKey)
        currentUserEmail = HelperMethods.getUserDefault(forKey: .emailKey)
        passwordTextField.text?.removeAll()
        configureUI(loggingIn: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginSegue" {
            HelperMethods.setAppsAuthSettings()
        }
    }

    // MARK: Actions
    @IBAction func loginTapped(_ sender: UIButton) {
        configureUI(loggingIn: true)

        if let validationError = validateLoginCreds() {
            configureUI(loggingIn: false)
            presentErrorMessage(validationError)
        } else {
            findUserEmailByUsername { error, userEmail in
                if error != nil {
                    self.presentErrorMessage(Constants.UIAlertMessage.authFailure(.login).description)
                } else if let userEmail = userEmail {
                    self.loginUser(email: userEmail)
                } else if !self.currentUserEmail.isEmpty {
                    self.loginUser(email: self.currentUserEmail)
                } else {
                    self.presentErrorMessage(Constants.UIAlertMessage.invalidLogin.description)
                }
            }
        }
    }
    
    @IBAction func resetPasswordTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: credsVerificationSegue, sender: sender)
    }
    
    // MARK: Functions
    func findUserEmailByUsername(completionHandler: @escaping ((Error?, String?) -> Void)) {
        let query = dbReference.child("users").queryOrdered(byChild: "username").queryEqual(toValue: usernameTextField.text)
        
        FirebaseClient.retrieveDataFromFirebase(forQuery: query) { timedout, error, snapshot in
            if timedout {
                self.presentErrorMessage(Constants.UIAlertMessage.connectionTimeout.description)
                completionHandler(nil, nil)
                
            } else if error != nil {
                debugPrint(error.debugDescription)
                completionHandler(error, nil)
            } else {
                let snapshotObject = (snapshot!.value as! [String:Any]).first!
                let userInfo = snapshotObject.value as? [String:Any]
                if let userEmail = userInfo?["email"] as? String {
                    completionHandler(nil, userEmail)
                } else {
                    completionHandler(nil, nil)
                }
            }
        }
    }

    func loginUser(email: String) {
        let timer = HelperMethods.configureTimeoutObserver {
            self.presentErrorMessage(Constants.UIAlertMessage.connectionTimeout.description)
        }
        
        Auth.auth().signIn(withEmail: email, password: passwordTextField.text!) { result, error in
            timer.invalidate()

            if error == nil {
                self.configureUI(loggingIn: false)
                self.currentUser = result!.user
                HelperMethods.setUserDefault(forKey: .usernameKey, withValue: self.usernameTextField.text!)
                self.checkCurrentUserEmailVerified()
            } else {
                self.presentErrorMessage(Constants.UIAlertMessage.invalidLogin.description)
            }
        }
    }
    
    func checkCurrentUserEmailVerified() {
        if currentUser.isEmailVerified {
            self.checkCurrentUserHasConnectedApps()
        } else {
            presentErrorMessage(Constants.UIAlertMessage.verifyEmail.description)
        }
    }

    func checkCurrentUserHasConnectedApps() {
        FirebaseClient.retrieveDataFromFirebase(forPath: "users/\(currentUser.uid)/connectedApps") { timedout, error, snapshot in
            if timedout {
                self.presentErrorMessage(Constants.UIAlertMessage.connectionTimeout.description)
            } else if snapshot != nil {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                self.presentErrorMessage(Constants.UIAlertMessage.noConnectedAppsFound.description)
            }
        }
    }

    func resendEmailVerification() {
        let timer = HelperMethods.configureTimeoutObserver {
            self.presentErrorMessage(Constants.UIAlertMessage.connectionTimeout.description)
        }

        currentUser.sendEmailVerification { error in
            timer.invalidate()

            if error != nil {
                self.presentErrorMessage(title: "Error", Constants.UIAlertMessage.authFailure(.sendVerificationLink).description)
            } else {
                self.presentErrorMessage(title: nil, Constants.UIAlertMessage.emailVerificationSent(self.currentUser.email!).description)
            }
        }
    }

    func configureUI(loggingIn: Bool) {
        usernameTextField.isEnabled = !loggingIn
        passwordTextField.isEnabled = !loggingIn
        loginButton.isEnabled = !loggingIn
        signupButton.isEnabled = !loggingIn
        resetPasswordButton.isEnabled = !loggingIn

        loggingIn ? loginActivity.startAnimating() : loginActivity.stopAnimating()
    }

    func validateLoginCreds() -> String? {
        guard let username = usernameTextField.text else {
            return Constants.FormErrors.emptyEmail.message
        }
        
        guard let password = passwordTextField.text else {
            return Constants.FormErrors.emptyPassword.message
        }

        let sanitizedUsername = HelperMethods.sanitizeText(username)
        let sanitizedPassword = HelperMethods.sanitizeText(password)

        guard !sanitizedUsername.isEmpty else {
            return Constants.FormErrors.emptyUsername.message
        }
        
        guard !sanitizedPassword.isEmpty else {
            return Constants.FormErrors.emptyPassword.message
        }
        
        return nil
    }

    func presentErrorMessage(title: String? = "Login Error", _ message: String) {
        let alertVC = UIAlertController(title: title, message: message.description, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.configureUI(loggingIn: false)
        }))

        if message == Constants.UIAlertMessage.verifyEmail.description {
            alertVC.addAction(UIAlertAction(title: "Resend Link", style: .default, handler: { action in
                self.resendEmailVerification()
            }))
        }
        
        if message == Constants.UIAlertMessage.noConnectedAppsFound.description {
            alertVC.addAction(UIAlertAction(title: "Connect Apps", style: .default, handler: { action in
                self.configureUI(loggingIn: false)
                self.performSegue(withIdentifier: "loginToConnectAppsSegue", sender: nil)
            }))
        }

        self.present(alertVC, animated: true, completion: nil)
    }
}
