//
//  PasswordResetViewController.swift
//  TUV
//
//  Created by Khalil Kum on 8/22/21.
//

import UIKit
import FirebaseAuth

class PasswordResetViewController: UIViewController {
    // MARK: Properties
    var userInfo: [String: String]!
    
    // MARK: Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var verificationStatusLabel: UILabel!
    @IBOutlet weak var verifyButton: UIButton!
    
    // MARK: View States
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        verificationStatusLabel.isHidden = true
        verifyButton.isEnabled = false
    }

    // MARK: Actions
    @IBAction func emailTypingStarted(_ sender: UITextField) {
        verifyButton.isEnabled = true
    }
    
    @IBAction func verifyEmailTapped(_ sender: UIButton) {
        if let validationError = validateEmail() {
            configureVerificationLabel(sent: false, validationError)
            emailTextField.endEditing(true)
        } else {
            Auth.auth().sendPasswordReset(withEmail: emailTextField.text!) { error in
                if error != nil {
                    self.configureVerificationLabel(sent: false)
                    self.emailTextField.endEditing(true)
                } else {
                    self.configureVerificationLabel(sent: true)
                    self.emailTextField.endEditing(true)
                }
            }
        }
    }

    @IBAction func cancelTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Functions
    func configureVerificationLabel(sent: Bool, _ errorMessage: String? = nil) {
        if sent {
            verificationStatusLabel.text = Constants.FormErrors.resetLinkSent.message
            verificationStatusLabel.textColor = .systemGreen
        } else {
            verificationStatusLabel.text = errorMessage ?? Constants.FormErrors.resetLinkFailed.message
            verificationStatusLabel.textColor = UIColor.red
        }

        verificationStatusLabel.isHidden = false
    }
    
    func validateEmail() -> String? {
        guard let email = emailTextField.text else {
            return Constants.FormErrors.emptyEmail.message
        }

        let sanitizedEmail = HelperMethods.sanitizeText(email)
        let emailValid = HelperMethods.validateInput(input: sanitizedEmail, type: .email)

        guard !sanitizedEmail.isEmpty else {
            return Constants.FormErrors.emptyEmail.message
        }
        
        guard emailValid else {
            return Constants.FormErrors.invalidEmail.message
        }
        
        return nil
    }
}
