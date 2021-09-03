//
//  EmailVerificationViewController.swift
//  TUV
//
//  Created by Khalil Kum on 8/22/21.
//

import Foundation
import UIKit

class EmailVerificationViewController: UIViewController {
    // MARK: Properties
    var userInfo: [String: String]!
    
    // MARK: Outlets
    @IBOutlet weak var verificationStatusLabel: UILabel!
    @IBOutlet weak var resendLinkButton: UIButton!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var codeTextField: UITextField!
    
    // MARK: View States
    override func viewWillAppear(_ animated: Bool) {
        nextButton.setTitleColor(.lightGray, for: .disabled)

        verificationStatusLabel.isHidden = true
        resendLinkButton.isEnabled = false
        verifyButton.isEnabled = false
        nextButton.isEnabled = false
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "verifyEmailNextSegue" {
            let confirmSignupVC = segue.destination as! ConfirmSignupViewController
            
            confirmSignupVC.userInfo = self.userInfo
        }
    }
    
    // MARK: Actions
    @IBAction func codeTypingStarted(_ sender: UITextField) {
        resendLinkButton.isEnabled = true
        verifyButton.isEnabled = true
    }
    
    @IBAction func resendCodeTapped(_ sender: UIButton) {
        // TODO: resend verification code
        
        codeTextField.isEnabled = true
        codeTextField.text?.removeAll()
        verificationStatusLabel.isHidden = true
        codeTextField.endEditing(true)
        verifyButton.isEnabled = false
        nextButton.isEnabled = false
    }
    
    @IBAction func verifyEmailTapped(_ sender: UIButton) {
        guard let verificationCode = codeTextField.text else { return }
        
        if verificationCode.isEmpty {
            configureVerificationLabel(verified: false, Constants.FormErrors.emptyCode.message)
        } else if verificationCode == "1234" {
            configureVerificationLabel(verified: true)
            codeTextField.isEnabled = false
        } else {
            configureVerificationLabel(verified: false)
        }
    }
    
    @IBAction func nextTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "verifyEmailNextSegue", sender: sender)
    }
    
    // MARK: Functions
    func configureVerificationLabel(verified: Bool, _ errorMessage: String? = nil) {
        if verified {
            verificationStatusLabel.text = Constants.FormErrors.verifiedEmail.message
            verificationStatusLabel.textColor = .systemGreen
            nextButton.isEnabled = true
        } else {
            verificationStatusLabel.text = errorMessage ?? Constants.FormErrors.unverifiedEmail.message
            verificationStatusLabel.textColor = UIColor.red
            nextButton.isEnabled = false
        }

        verificationStatusLabel.isHidden = false
    }
}
