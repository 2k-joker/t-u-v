//
//  UserEmailVerficationViewController.swift
//  TUV
//
//  Created by Khalil Kum on 8/28/21.
//

import Foundation
import UIKit

class UserEmailVerificationViewController: UIViewController {
    // MARK: Properties
    var userEmail: String = "N/A"
    
    // MARK: Outlets
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var noticeLabel: UILabel!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var resendCodeButton: UIButton!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: View States
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateNoticeLabel()
        errorLabel.isHidden = true
        resendCodeButton.isEnabled = false
        verifyButton.isEnabled = false
    }
    
    // MARK: Actions
    @IBAction func cancelTapped(_ sender: UIButton) {
        presentCancelConfirmationMessage()
    }

    @IBAction func codeTypingStarted(_ sender: UITextField) {
        resendCodeButton.isEnabled = true
        verifyButton.isEnabled = true
    }

    @IBAction func resendCodeTapped(_ sender: UIButton) {
        // TODO: resend verification code
        
        codeTextField.isEnabled = true
        codeTextField.text?.removeAll()
        errorLabel.isHidden = true
//        verifyButton.isEnabled = true
    }
    
    @IBAction func verifyTapped(_ sender: UIButton) {
        // TODO: verify email
        guard let verificationCode = codeTextField.text else { return }
        configureVerifyingState(verifying: true)
    
        if verificationCode.isEmpty {
            configureErrorLabel(errorMessage: Constants.FormErrors.emptyCode.message)
            configureVerifyingState(verifying: false)
        } else if verificationCode != "1234" {
            configureErrorLabel()
            configureVerifyingState(verifying: false)
        } else {
            configureVerifyingState(verifying: false)
            presentConfirmationMessage(message: .updateFailed)
        }
    }
    
    // MARK: Functions
    func configureErrorLabel(errorMessage: String? = nil) {
        errorLabel.text = errorMessage ?? Constants.FormErrors.unverifiedEmail.message
        errorLabel.isHidden = false
    }

    func presentConfirmationMessage(message: Constants.UIAlertMessage) {
        let updateFailedMessage = Constants.UIAlertMessage.updateFailed
        let alertVC = UIAlertController(title: nil, message: message.description, preferredStyle: .alert)
        
        if message.description == updateFailedMessage.description {
            alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
                self.verifyButton.isEnabled = false
                self.codeTextField.text?.removeAll()
                self.codeTextField.endEditing(true)
            }))
        } else {
            errorLabel.isHidden = true
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                self.performSegue(withIdentifier: "userFeedSegue", sender: action)
            }))
        }
        
        activityIndicator.stopAnimating()
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func presentCancelConfirmationMessage() {
        let alertMessage = "All other updates have been save. You can try updating your email again at another time."
        let alertVC = UIAlertController(title: nil, message: alertMessage, preferredStyle: .alert)
        
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.performSegue(withIdentifier: "editProfileSegue", sender: action)
        }))
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func makeBold(_ text:String) -> NSMutableAttributedString {
        let boldFont = UIFont.boldSystemFont(ofSize: 15)
        let attributes:[NSAttributedString.Key : Any] = [
            .font : boldFont
        ]
        let boldedText = NSMutableAttributedString(string: text, attributes: attributes)
        return boldedText
    }
    
    func updateNoticeLabel() {
        let attributedString = NSMutableAttributedString(string: "Verifcation code sent to: ")
        let boldedEmail = makeBold(userEmail)
        
        attributedString.append(boldedEmail)
        noticeLabel.attributedText = attributedString
    }
    
    func configureVerifyingState(verifying: Bool) {
        resendCodeButton.isEnabled = !verifying
        verifyButton.isEnabled = !verifying
        codeTextField.isEnabled = !verifying
        
        verifying ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
}
