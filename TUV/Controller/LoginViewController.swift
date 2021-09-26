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
        passwordTextField.text?.removeAll()
        configureUI(loggingIn: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // TODO: ???
//    }

    // MARK: Actions
    @IBAction func loginTapped(_ sender: UIButton) {
        configureUI(loggingIn: true)

        if let validationError = validateLoginCreds() {
            configureUI(loggingIn: false)
            presentErrorMessage(validationError)
        } else {
            Database.database().reference().child("users").queryOrdered(byChild: "username").queryEqual(toValue: usernameTextField.text).getData { error, snapshot in
                if error != nil {
                    debugPrint(error.debugDescription)
                    
                    self.presentErrorMessage(Constants.UIAlertMessage.authFailure(.login).description)
                } else if snapshot.exists() {
                    let snapshotObject = (snapshot.value as! [String:Any]).first!
                    let userInfo = snapshotObject.value as! [String:Any]
                    let userEmail = userInfo["email"] as! String

                    self.loginUser(email: userEmail)
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
    func loginUser(email: String) {
        Auth.auth().signIn(withEmail: email, password: passwordTextField.text!) { result, error in
            if error == nil {
                self.configureUI(loggingIn: false)
                self.currentUser = result!.user
                self.checkCurrentUserEmailVerified()
            } else {
                self.presentErrorMessage(Constants.UIAlertMessage.invalidLogin.description)
            }
        }
    }
    
    func checkCurrentUserEmailVerified() {
        if currentUser.isEmailVerified {
            self.performSegue(withIdentifier: "loginSegue", sender: nil)
        } else {
            presentErrorMessage(Constants.UIAlertMessage.verifyEmail.description)
        }
    }
    
    func resendEmailVerification() {
        currentUser.sendEmailVerification { error in
            if error != nil {
                self.presentErrorMessage(Constants.UIAlertMessage.authFailure(.sendVerificationLink).description)
            } else {
                self.presentErrorMessage(Constants.UIAlertMessage.emailVerificationSent(self.currentUser.email!).description)
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

    func presentErrorMessage(_ message: String) {
        let verifyEmail = Constants.UIAlertMessage.verifyEmail
        let alertVC = UIAlertController(title: "Login Error", message: message.description, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.configureUI(loggingIn: false)
        }))

        if message == verifyEmail.description {
            alertVC.addAction(UIAlertAction(title: "Resend Link", style: .default, handler: { action in
                self.resendEmailVerification()
            }))
        }

        self.present(alertVC, animated: true, completion: nil)
    }
}

extension LoginViewController: UITextFieldDelegate {
    // MARK: Textfield Delegates
    func textFieldDidBeginEditing(_ textField: UITextField) {
        subscribeToKeyboardNotifications()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    // MARK: Show/Hide Keyboard
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if view.frame.origin.y == 0 {
            view.frame.origin.y -= keyboardHeight(notification)
        }
    }

    func keyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        subscribeToNotification(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShow(_:)))
        subscribeToNotification(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillHide(_:)))
    }
    
    func subscribeToNotification(_ name: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: name, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}
