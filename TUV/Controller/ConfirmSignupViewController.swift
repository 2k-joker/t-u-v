//
//  ConfirmSignupViewController.swift
//  TUV
//
//  Created by Khalil Kum on 8/23/21.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ConfirmSignupViewController: UIViewController {
    // MARK: Properties
    var userInfo: [String: String]!
    
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
        usernameTextField.text = userInfo["username"]
        emailTextField.text = userInfo["email"]
        mobileNumberTextField.text = userInfo["mobileNumber"]
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
        createUser()
    }
    
    // MARK: Functions
    func configureUI(signingUp: Bool) {
        cancelButton.isEnabled = !signingUp
        signupButton.isEnabled = !signingUp
        termsAndPoliciesButton.isEnabled = !signingUp
        
        signingUp ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
    func createUser() {
        Auth.auth().createUser(withEmail: userInfo!["email"]!, password: userInfo!["password"]!) { result, error in
            if error != nil {
                self.presentSignupError()
            } else {
                let dbReference = Database.database().reference()
                let userData = [
                    "username": self.userInfo!["username"],
                    "avatarName": self.userInfo!["avatarName"],
                    "phoneNumber": self.userInfo!["mobileNumber"]
                ]

                dbReference.child("users").child(result!.user.uid).setValue(userData)
                
                self.configureUI(signingUp: false)
                self.performSegue(withIdentifier: "confirmSignupSegue", sender: nil)
            }
        }
    }
    
    func presentSignupError() {
        let alertMessage = "Unable to complete sign up process.\nPlease check your conection and try again."
        let alertVC = UIAlertController(title: "Failed", message: alertMessage, preferredStyle: .alert)
        
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.configureUI(signingUp: false)
        }))
        
        self.present(alertVC, animated: true, completion: nil)
    }
}
