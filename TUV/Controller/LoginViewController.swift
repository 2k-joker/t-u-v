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

    // MARK: Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
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

    // MARK: Actions
    @IBAction func loginTapped(_ sender: UIButton) {
        configureUI(loggingIn: true)

        if let validationError = validateLoginCreds() {
            configureUI(loggingIn: false)
            presentErrorMessage(validationError)
        } else {
            Database.database().reference().child("users").queryOrdered(byChild: "username").queryEqual(toValue: usernameTextField.text).getData { error, snapshot in
                if error != nil {
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

    // MARK: Functions
    func loginUser(email: String) {
        Auth.auth().signIn(withEmail: email, password: passwordTextField.text!) { result, error in
            if error == nil {
                self.configureUI(loggingIn: false)
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                self.presentErrorMessage(Constants.UIAlertMessage.invalidLogin.description)
            }
        }
    }

    func configureUI(loggingIn: Bool) {
        usernameTextField.isEnabled = !loggingIn
        passwordTextField.isEnabled = !loggingIn
        loginButton.isEnabled = !loggingIn
        signupButton.isEnabled = !loggingIn

        loggingIn ? loginActivity.startAnimating() : loginActivity.stopAnimating()
    }

    func validateLoginCreds() -> String? {
        guard let usernameOrEmail = usernameTextField.text else {
            return Constants.FormErrors.emptyEmail.message
        }
        
        guard let password = passwordTextField.text else {
            return Constants.FormErrors.emptyPassword.message
        }

        let sanitizedEmail = HelperMethods.sanitizeText(usernameOrEmail)
        let sanitizedPassword = HelperMethods.sanitizeText(password)
        
        guard !sanitizedEmail.isEmpty else {
            return Constants.FormErrors.emptyEmail.message
        }
        
        guard !sanitizedPassword.isEmpty else {
            return Constants.FormErrors.emptyPassword.message
        }
        
        return nil
    }
    
    func presentErrorMessage(_ message: String) {
        let alertVC = UIAlertController(title: "Login Error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.configureUI(loggingIn: false)
        }))
        
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
