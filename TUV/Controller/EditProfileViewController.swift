//
//  EditProfileViewController.swift
//  TUV
//
//  Created by Khalil Kum on 8/22/21.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class EditProfileViewController: UIViewController {
    // MARK: Properties
    var userInfo: [String:Any]!
    fileprivate let currentUser = Auth.auth().currentUser!
    fileprivate let dbReference = Database.database().reference()
    fileprivate var _avatarChangedRefHandle: DatabaseHandle!
    fileprivate let updateAvatarSegue = "updateAvatarSegue"

    // MARK: Outlets
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var updateAvatar: UIButton!
    @IBOutlet weak var userInfoStackView: UIStackView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var mobileNumberTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var saveButton: UIButton!

    // MARK: View States
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        displayUserInfo()
        errorLabel.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureProfileImageListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
        dbReference.child("users/\(currentUser.uid)").removeObserver(withHandle: _avatarChangedRefHandle)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == updateAvatarSegue {
            let pickAvatarVC = segue.destination as! PickAvatarViewController
            pickAvatarVC.currentAvatarName = userInfo["avatarName"] as! String
        }
    }
    
    // MARK: Actions
    @IBAction func cancelTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "userFeedSegue", sender: sender)
    }

    @IBAction func updateAvatarTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: updateAvatarSegue, sender: sender)
    }

    @IBAction func saveTapped(_ sender: UIButton) {
        configureUI(saving: true)
        
        // Validate changes
        if let validationError = validateUserInfoForm() {
            updateErrorLabel(validationError)
            configureUI(saving: false)
        } else {
            // Save changes
            saveProfileUpdate()
            configureUI(saving: false)

            if (!emailTextField.text!.isEmpty) && (emailTextField.text! != currentUser.email) {
                updateUserEmail(emailTextField.text!)
            } else {
                presentMessage(message: Constants.UIAlertMessage.updateSuccessful.description)
            }
        }
    }
    
    // MARK: Functions
    
    // Add a listener to update avatar when changes occur
    func configureProfileImageListener() {
        _avatarChangedRefHandle = dbReference.child("users/\(currentUser.uid)").observe(.childChanged, with: { snapshot in
            if snapshot.key == "avatarName" {
                let newAvatarName = snapshot.value as! String
                self.userProfileImage.image = UIImage(named: newAvatarName)
            }
        })
    }

    func saveProfileUpdate() {
        var updates: [String:String] = [:]
        let basePath = "users/\(currentUser.uid)"
        
        if !usernameTextField.text!.isEmpty {
            updates["\(basePath)/username"] = usernameTextField.text
        }
        
        if !mobileNumberTextField.text!.isEmpty {
            updates["\(basePath)/mobileNumber"] = mobileNumberTextField.text
        } else if mobileNumberTextField.text!.isEmpty {
            updates["\(basePath)/mobileNumber"] = "N/A"
            mobileNumberTextField.text = "N/A"
        }
        
        if !passwordTextField.text!.isEmpty {
            updateUserPassword(passwordTextField.text!)
        }
        
        dbReference.updateChildValues(updates) { error, reference in
            if error != nil {
                debugPrint(error.debugDescription)
                self.presentMessage(message: Constants.UIAlertMessage.updateFailed.description)
            } else {
                HelperMethods.setUsername(to: self.usernameTextField.text!)
            }
        }
    }
    
    func displayUserInfo() {
        // TODO: Get user avatar name
        let avatarName = userInfo["avatarName"] as! String
        let username = userInfo["username"] as! String
        let email = userInfo["email"] as! String
        let mobileNumber = userInfo["mobileNumber"] as! String
        
        userProfileImage.image = UIImage(named: avatarName)
        usernameTextField.text = username
        emailTextField.text = email
        mobileNumberTextField.text = mobileNumber
    }

    func configureUI(saving: Bool) {
        updateAvatar.isEnabled = !saving
        userInfoStackView.isUserInteractionEnabled = !saving
        saveButton.isEnabled = !saving
        
        saving ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
    func updateErrorLabel(_ labelMessage: String = "") {
        errorLabel.text = labelMessage
        errorLabel.isHidden = labelMessage.isEmpty
    }
    
    func updateUserPassword(_ password: String) {
        currentUser.updatePassword(to: password) { error in
            if error != nil {
                self.presentMessage(message: Constants.UIAlertMessage.authFailure(.updatePassword).description)
            }
        }
    }
    
    func updateUserEmail(_ email: String) {
        currentUser.updateEmail(to: email) { error in
            if error != nil {
                self.presentFailedToUpdateEmailMessage()
            } else {
                let updates = ["users/\(self.currentUser.uid)/email": email]
                
                self.dbReference.updateChildValues(updates) { error, reference in
                    if error != nil {
                        self.presentFailedToUpdateEmailMessage()
                    } else {
                        self.sendEmailVerificationLink()
                    }
                }
                
            }
        }
    }
    
    func sendEmailVerificationLink() {
        currentUser.sendEmailVerification { error in
            if error != nil {
                self.presentFailedToUpdateEmailMessage()
            } else {
                let alertMessage = [
                    Constants.UIAlertMessage.updateSuccessful.description,
                    Constants.UIAlertMessage.emailVerificationSent(self.currentUser.email!).description
                ].joined(separator: "\n")
                
                self.presentMessage(message: alertMessage)
            }
        }
    }
    
    func presentFailedToUpdateEmailMessage() {
        presentMessage(message: Constants.UIAlertMessage.authFailure(.updateEmail).description)
    }
    
    func presentMessage(message: String) {
        let alertVC = UIAlertController(title: nil, message: message, preferredStyle: .alert)

        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.resetUserInfoForm()
        }))
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func isValidInput(input: String?, type: Constants.RegexPatterns) -> Bool {
        // If the user didn't update the field, it is valid
        guard let input = input else { return true }
        guard !input.isEmpty else { return true }
        
        return HelperMethods.validateInput(input: input, type: type)
    }
    
    func resetUserInfoForm() {
        usernameTextField.endEditing(true)
        emailTextField.endEditing(true)
        mobileNumberTextField.endEditing(true)
        passwordTextField.text?.removeAll()
        passwordTextField.endEditing(true)
        confirmPasswordTextField.text?.removeAll()
        confirmPasswordTextField.endEditing(true)
        errorLabel.isHidden = true
    }
    
    func validateUserInfoForm() -> String? {
        // TODO: Assert that new values are different from existing values
        
        guard isValidInput(input: usernameTextField.text, type: .username) else {
            return Constants.FormErrors.invalidUsername.message
        }

        guard isValidInput(input: emailTextField.text, type: .email) else {
            return Constants.FormErrors.invalidEmail.message
        }
        
        guard isValidInput(input: mobileNumberTextField.text, type: .mobileNumber) || mobileNumberTextField.text! == "N/A" else {
            return Constants.FormErrors.invalidMobileNumber.message
        }
        
        guard isValidInput(input: passwordTextField.text, type: .password) else {
            return Constants.FormErrors.weakPassword.message
        }
        
        guard confirmPasswordTextField.text == passwordTextField.text else {
            return Constants.FormErrors.passwordMismatch.message
        }
        
        return nil
    }
}

extension EditProfileViewController: UITextFieldDelegate {
    // MARK: Textfield Delegates
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let subjectTextFields = [mobileNumberTextField, passwordTextField, confirmPasswordTextField]
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
