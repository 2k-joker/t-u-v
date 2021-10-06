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
        self.performSegue(withIdentifier: "editProfileCancelSegue", sender: sender)
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
            saveProfileUpdate { success in
                if success {
                    HelperMethods.setUserDefault(forKey: .usernameKey, withValue: self.usernameTextField.text!)
                    self.presentMessage(message: Constants.UIAlertMessage.updateSuccessful.description)
                    
                    if (!self.emailTextField.text!.isEmpty) && (self.emailTextField.text! != self.currentUser.email) {
                        self.configureUI(saving: true)
                        self.updateUserEmail(self.emailTextField.text!)
                    }
                } else {
                    self.presentMessage(message: Constants.UIAlertMessage.updateFailed.description)
                }
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

    func saveProfileUpdate(completionHandler: @escaping ((Bool) -> Void)) {
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
        
        FirebaseClient.writeDataToFirebase(withNewData: updates) { timedout, error, reference in
            if timedout {
                self.presentMessage(message: Constants.UIAlertMessage.connectionTimeout.description)
            } else if error != nil {
                debugPrint(error.debugDescription)
                completionHandler(false)
            } else {
                completionHandler(true)
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
        let timer = HelperMethods.configureTimeoutObserver {
            self.presentMessage(message: Constants.UIAlertMessage.connectionTimeout.description)
            self.presentFailedToUpdateEmailMessage()
        }

        currentUser.updateEmail(to: email) { error in
            timer.invalidate()

            if error != nil {
                self.presentFailedToUpdateEmailMessage()
            } else {
                let updates = ["users/\(self.currentUser.uid)/email": email]
                
                FirebaseClient.writeDataToFirebase(withNewData: updates) { timedout, error, reference in
                    if timedout {
                        self.presentMessage(message: Constants.UIAlertMessage.connectionTimeout.description)
                        self.presentFailedToUpdateEmailMessage()
                    } else if error != nil {
                        self.presentFailedToUpdateEmailMessage()
                    } else {
                        HelperMethods.setUserDefault(forKey: .emailKey, withValue: email)
                        self.sendEmailVerificationLink()
                    }
                }
            }
        }
    }
    
    func sendEmailVerificationLink() {
        let timer = HelperMethods.configureTimeoutObserver {
            self.presentMessage(message: Constants.UIAlertMessage.connectionTimeout.description)
        }

        currentUser.sendEmailVerification { error in
            if error != nil {
                self.presentMessage(message: Constants.UIAlertMessage.authFailure(.sendVerificationLink).description)
                self.presentFailedToUpdateEmailMessage()
            } else {
                self.presentMessage(message: Constants.UIAlertMessage.emailVerificationSent(self.currentUser.email!).description)
            }
            
            timer.invalidate()
        }
    }
    
    func presentFailedToUpdateEmailMessage() {
        presentMessage(message: Constants.UIAlertMessage.authFailure(.updateEmail).description)
    }
    
    func presentMessage(message: String) {
        let alertVC = UIAlertController(title: nil, message: message, preferredStyle: .alert)

        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.configureUI(saving: false)
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
