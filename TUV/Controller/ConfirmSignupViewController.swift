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
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var mobileNumberTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var termsAndPoliciesButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var backButton: UIButton!
    
    // MARK: View States
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.text = userInfo["username"]
        emailTextField.text = userInfo["email"]
        mobileNumberTextField.text = userInfo["mobileNumber"]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        usernameTextField.isEnabled = false
        emailTextField.isEnabled = false
        mobileNumberTextField.isEnabled = false
        
        backButton.setTitleColor(.lightGray, for: .disabled)
        termsAndPoliciesButton.setTitleColor(.lightGray, for: .disabled)
        configureUI(signingUp: false)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "confirmSignupSegue" {
//            HelperMethods.setAppsAuthSettings()
//        }
//    }

    // MARK: Actions
    @IBAction func signupTapped(_ sender: UIButton) {
        configureUI(signingUp: true)
        signupUser()
    }
    
    // MARK: Functions
    func configureUI(signingUp: Bool) {
        signupButton.isEnabled = !signingUp
        backButton.isEnabled = !signingUp
        termsAndPoliciesButton.isEnabled = !signingUp
        
        signingUp ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
    func signupUser() {
        Auth.auth().createUser(withEmail: userInfo["email"]!, password: userInfo["password"]!) { result, error in
            if error != nil {
                self.presentSignupError()
            } else {
                self.createUserRecord(for: result!.user)
            }
        }
    }
    
    func createUserRecord(for user: User) {
        let dbReference = Database.database().reference()
        let userData = [
            "username": userInfo["username"],
            "email": userInfo["email"],
            "avatarName": userInfo["avatarName"],
            "mobileNumber": userInfo["mobileNumber"]
        ]
        
        dbReference.child("users/\(user.uid)").setValue(userData) { error, reference in
            if error != nil {
                self.presentSignupError()
                Auth.auth().currentUser!.delete(completion: nil)
            } else {
                HelperMethods.setUsername(to: self.userInfo["username"])
                self.configureUI(signingUp: false)
                self.sendUserEmailVerification(for: user)
            }
        }
    }
    
    func sendUserEmailVerification(for user: User) {
        user.sendEmailVerification { error in
            if error != nil {
                debugPrint(error.debugDescription)
            }

            self.performSegue(withIdentifier: "confirmSignupSegue", sender: nil)
        }
    }

    func presentSignupError() {
        let alertMessage = Constants.UIAlertMessage.authFailure(.signup).description
        let alertVC = UIAlertController(title: "Failed", message: alertMessage, preferredStyle: .alert)
        
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.configureUI(signingUp: false)
        }))
        
        self.present(alertVC, animated: true, completion: nil)
    }
}
