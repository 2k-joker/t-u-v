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
    fileprivate let updateAvatarSegue = "updateAvatarSegue"
    fileprivate let verfifyEmailSegue = "verifyEmailSegue"

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
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        retrieveUserInfo()
        displayUserInfo()
        errorLabel.isHidden = true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case updateAvatarSegue:
            () // TODO: set preview image to user's avatar
        case verfifyEmailSegue:
            let verifyEmailVC = segue.destination as! UserEmailVerificationViewController
            verifyEmailVC.userEmail = emailTextField.text!
        default:
            () // Do nothing
        }
    }
    
    // MARK: Actions
    @IBAction func cancelTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "userFeedSegue", sender: sender)
    }

    @IBAction func updateAvatarTapped(_ sender: UIButton) {
        // segue to pick avatar VC
        self.performSegue(withIdentifier: updateAvatarSegue, sender: sender)
    }

    @IBAction func saveTapped(_ sender: UIButton) {
        configureUI(saving: true)
        
        // Validate changes
        if let validationError = validateUserInfoForm() {
            updateErrorLabel(validationError)
            configureUI(saving: false)
        } else {
            if (!emailTextField.text!.isEmpty) && (emailTextField.text! != currentUser.email) {
                configureUI(saving: false)
                presentMessage(message: .verifyEmail)
            } else {
                // Save changes
                saveProfileUpdate()
                configureUI(saving: false)
                presentMessage(message: .updateSuccessful)
            }
        }
    }
    
    // MARK: Functions
    func saveProfileUpdate() {
        var updates: [String:String] = [:]
        let basePath = "users/\(currentUser.uid)"
        
        if !usernameTextField.text!.isEmpty {
            updates["\(basePath)/username"] = usernameTextField.text
        }
        
        if !mobileNumberTextField.text!.isEmpty {
            updates["\(basePath)/mobileNumber"] = mobileNumberTextField.text
        }
        
        if !passwordTextField.text!.isEmpty {
            updateUserPassword(passwordTextField.text!)
        }
        
        dbReference.updateChildValues(updates) { error, reference in
            if error != nil {
                debugPrint(error.debugDescription)
                self.presentMessage(message: .updateFailed)
            }
        }
    }

    func retrieveUserInfo() {
        dbReference.child("users/\(currentUser.uid)").getData { error, snapshot in
            if snapshot.exists() {
                self.userInfo = snapshot.value as? [String:Any]
            } else {
                debugPrint(error.debugDescription)
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
                self.presentMessage(message: .authFailure(.updatePassword))
            }
        }
    }
    
    func presentMessage(message: Constants.UIAlertMessage) {
        let  verifyEmailMessage = Constants.UIAlertMessage.verifyEmail
        let alertVC = UIAlertController(title: nil, message: message.description, preferredStyle: .alert)
   
        if message.description == verifyEmailMessage.description {
            alertVC.addAction(UIAlertAction(title: "Continue", style: .default, handler: handleVerifyUserEmail(action:)))
            alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        } else {
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                self.resetUserInfoForm()
            }))
        }
        
        self.present(alertVC, animated: true, completion: nil)
    }

    func handleVerifyUserEmail(action: UIAlertAction) {
        // save changes (without email)
        saveProfileUpdate()
        
        self.performSegue(withIdentifier: verfifyEmailSegue, sender: action)
        resetUserInfoForm()
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
    
    // TODO: Add a listener to update avatar when changes occur
}
