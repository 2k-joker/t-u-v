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
    private var dbReference: DatabaseReference!
    
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
        configureUi(loggingIn: false)
    }

    // MARK: Actions
    @IBAction func loginTapped(_ sender: UIButton) {
        configureUi(loggingIn: true)

        if let validationError = validateLoginCreds() {
            configureUi(loggingIn: false)
            presentErrorMessage(validationError)
        } else {
            // TODO: Find user by username or email
            
            Auth.auth().signIn(withEmail: usernameTextField.text!, password: passwordTextField.text!) { result, error in
                if error == nil {
                    self.configureUi(loggingIn: false)
                    self.performSegue(withIdentifier: "loginSegue", sender: sender)
                } else {
                    self.configureUi(loggingIn: false)
                    self.presentErrorMessage(Constants.FormErrors.invalidLogin.message)
                }
            }
            
        }
    }
    
    // MARK: Functions
    func configureUi(loggingIn: Bool) {
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
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alertVC, animated: true, completion: nil)
    }
}
