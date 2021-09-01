//
//  ConfirmSignupViewController.swift
//  TUV
//
//  Created by Khalil Kum on 8/23/21.
//

import Foundation
import UIKit

class ConfirmSignupViewController: UIViewController {
    // MARK: Properties
    // TODO: Get current user object
    
    // MARK: Outlets
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var mobileNumberTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var termsAndPoliciesButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: View States
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: setup view content
        usernameTextField.text = "username"
        emailTextField.text = "email@example.com"
        mobileNumberTextField.text = "N/A"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        usernameTextField.isEnabled = false
        emailTextField.isEnabled = false
        mobileNumberTextField.isEnabled = false
        
        cancelButton.setTitleColor(.lightGray, for: .disabled)
        termsAndPoliciesButton.setTitleColor(.lightGray, for: .disabled)
        configureUI(signingUp: false)
    }
    
    // MARK: Actions
    @IBAction func signupTapped(_ sender: UIButton) {
        configureUI(signingUp: true)
        
        // TODO: create user
        
        self.performSegue(withIdentifier: "confirmSignupSegue", sender: sender)
        configureUI(signingUp: false)
    }
    
    // MARK: Functions
    func configureUI(signingUp: Bool) {
        cancelButton.isEnabled = !signingUp
        signupButton.isEnabled = !signingUp
        termsAndPoliciesButton.isEnabled = !signingUp
        
        signingUp ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
}
