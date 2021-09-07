//
//  EditProfileViewController.swift
//  TUV
//
//  Created by Khalil Kum on 8/22/21.
//

import Foundation
import UIKit

class EditProfileViewController: UIViewController {
    // MARK: Properties
    let updateAvatarSegue = "updateAvatarSegue"
    let verfifyEmailSegue = "verifyEmailSegue"
    
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
        
        displayUserAvatar()
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
            if !emailTextField.text!.isEmpty {
                configureUI(saving: false)
                presentMessage(message: .verifyEmail)
            } else {
                // Save changes
                configureUI(saving: false)
                presentMessage(message: .updateSuccessful)
            }
        }
    }
    
    // MARK: Functions
    func displayUserAvatar() {
        // TODO: Get user avatar name
        let userAvatarName = ""
        
        if userAvatarName.isEmpty {
            userProfileImage.image = UIImage(named: "robot_avatar")
        } else {
            userProfileImage.image = UIImage(named: userAvatarName)
        }
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
        // TODO: save changes (without email)
        
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
        usernameTextField.text?.removeAll()
        usernameTextField.endEditing(true)
        emailTextField.text?.removeAll()
        emailTextField.endEditing(true)
        mobileNumberTextField.text?.removeAll()
        mobileNumberTextField.endEditing(true)
        passwordTextField.text?.removeAll()
        passwordTextField.endEditing(true)
        confirmPasswordTextField.text?.removeAll()
        confirmPasswordTextField.endEditing(true)
    }
    
    func validateUserInfoForm() -> String? {
        // TODO: Assert that new values are different from existing values
        
        guard isValidInput(input: usernameTextField.text, type: .username) else {
            return Constants.FormErrors.invalidUsername.message
        }

        guard isValidInput(input: emailTextField.text, type: .email) else {
            return Constants.FormErrors.invalidEmail.message
        }
        
        guard isValidInput(input: mobileNumberTextField.text, type: .mobileNumber) else {
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
