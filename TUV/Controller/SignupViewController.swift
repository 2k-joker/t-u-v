//
//  SignupViewController.swift
//  TUV
//
//  Created by Khalil Kum on 8/21/21.
//

import UIKit
import Firebase

class SignupViewController: UIViewController {
    // MARK: Properties
//    fileprivate var keyboardOnScreen: Bool!
    
    // MARK: Outlets
    @IBOutlet weak var formStackView: UIStackView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet var hideShowButton: [UIButton]!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: View States
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        errorLabel.isHidden = true
        nextButton.setTitleColor(.lightGray, for: .disabled)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signupNextSegue" {
            let confirmSignupVC = segue.destination as! ConfirmSignupViewController
            
            var mobileNumber: String {
                if numberTextField.text!.isEmpty {
                    return "N/A"
                } else {
                    return numberTextField.text!
                }
            }

            let userInfo = [
                "avatarName": "robot_avatar",
                "mobileNumber": mobileNumber,
                "email": emailTextField.text!,
                "username": usernameTextField.text!,
                "password": passwordTextField.text!,
            ]
            confirmSignupVC.userInfo = userInfo
        }
    }
    
    // MARK: Actions
    @IBAction func emailTyped(_ sender: UITextField) {
        if isInvalidInput(input: sender.text, type: .email) {
            updateErrorLabel(Constants.FormErrors.invalidEmail.message)
        } else {
            updateErrorLabel()
        }
    }
    
    @IBAction func numberTyped(_ sender: UITextField) {
        guard let mobileNumber = sender.text else {
            updateErrorLabel()
            return
        }

        if !mobileNumber.isEmpty && isInvalidInput(input: mobileNumber, type: .mobileNumber) {
            updateErrorLabel(Constants.FormErrors.invalidMobileNumber.message)
        } else {
            updateErrorLabel()
        }
    }
    
    @IBAction func usernameTyped(_ sender: UITextField) {
        if isInvalidInput(input: sender.text, type: .username) {
            updateErrorLabel(Constants.FormErrors.invalidUsername.message)
        } else {
            configureUserInteraction(busy: true)
            
            Database.database().reference().child("users/\(sender.text!)").getData { error, snapshot in
                if error != nil {
                    DispatchQueue.main.async {
                        self.configureUserInteraction(busy: false)
                        self.updateErrorLabel(Constants.FormErrors.unverifiedUsername.message
                        )
                        sender.text!.removeAll()
                    }

                } else if snapshot.exists() {
                    DispatchQueue.main.async {
                        self.configureUserInteraction(busy: false)
                        self.updateErrorLabel(Constants.FormErrors.usernameTaken(sender.text!).message)
                        sender.text!.removeAll()
                    }
                } else {
                    self.configureUserInteraction(busy: false)
                    self.updateErrorLabel()
                }
            }
        }
    }
    
    @IBAction func passwordTyped(_ sender: UITextField) {
        if isInvalidInput(input: sender.text, type: .password){
            updateErrorLabel(Constants.FormErrors.weakPassword.message)
        } else {
            updateErrorLabel()
        }
    }
    
    @IBAction func passwordHideShowTapped(_ sender: UIButton) {
        configureHideShowButton(textField: passwordTextField, button: sender)
    }
    
    @IBAction func passwordConfirmed(_ sender: UITextField) {
        if sender.text != passwordTextField.text {
            updateErrorLabel(Constants.FormErrors.passwordMismatch.message)
        } else {
            updateErrorLabel()
        }
    }
    
    @IBAction func confirmedPasswordHideShowTapped(_ sender: UIButton) {
        configureHideShowButton(textField: confirmPasswordTextField, button: sender)
    }
    
    @IBAction func nextTapped(_ sender: UIButton) {
        if let validationError = validateSignupForm() {
            updateErrorLabel(validationError)
        } else {
            self.performSegue(withIdentifier: "signupNextSegue", sender: sender)
        }
    }
    
    // MARK: Functions
    func configureUserInteraction(busy: Bool) {
        formStackView.isUserInteractionEnabled = !busy
        nextButton.isEnabled = !busy
        
        busy ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }

    func configureHideShowButton(textField: UITextField, button: UIButton) {
        if textField.isSecureTextEntry {
            textField.isSecureTextEntry = false
            button.setTitle("Hide", for: .normal)
        } else {
            textField.isSecureTextEntry = true
            button.setTitle("Show", for: .normal)
        }
    }

    func updateErrorLabel(_ labelMessage: String = "") {
        errorLabel.text = labelMessage
        errorLabel.isHidden = labelMessage.isEmpty
    }
    
    func validateSignupForm() -> String? {
        if isInvalidInput(input: emailTextField.text, type: .email) {
            return Constants.FormErrors.invalidEmail.message
        }
        
        if !numberTextField.text!.isEmpty {
            if isInvalidInput(input: numberTextField.text, type: .mobileNumber) {
                return Constants.FormErrors.invalidMobileNumber.message
            }
        }
        
        if isInvalidInput(input: usernameTextField.text, type: .username) {
            return Constants.FormErrors.invalidUsername.message
        }
        
        if isInvalidInput(input: passwordTextField.text, type: .password) {
            return Constants.FormErrors.weakPassword.message
        }
        
        if confirmPasswordTextField.text != passwordTextField.text {
            return Constants.FormErrors.passwordMismatch.message
        }
        
        return nil
    }
    
    func isInvalidInput(input: String?, type: Constants.RegexPatterns) -> Bool {
        let valid = HelperMethods.validateInput(input: input, type: type)
        
        return !valid
    }
}

extension SignupViewController: UITextFieldDelegate {
    // MARK: Textfield Delegates
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let subjectTextFields = [usernameTextField, passwordTextField, confirmPasswordTextField]
        if subjectTextFields.contains(textField) {
            subscribeToKeyboardNotifications()
        } else {
            unsubscribeFromKeyboardNotifications()
        }
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
