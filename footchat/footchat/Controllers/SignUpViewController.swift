//
//  SignUpViewController.swift
//  footchat
//
//  Created by Marten on 10/2/19.
//  Copyright © 2019 Marten. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class SignUpViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    
    ///////   for activity indicator  //////////
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView();
    var overlayView:UIView = UIView();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        
        ////  dismiss keyboard   ///////
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    //dismiss keyboard setting
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    // for activity indicator setting
    func startActivityIndicator() {
        activityIndicator.center = self.view.center;
        activityIndicator.hidesWhenStopped = true;
        activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge;
        activityIndicator.color = UIColor.black
        view.addSubview(activityIndicator);
        activityIndicator.startAnimating();
        overlayView = UIView(frame:view.frame);
        view.addSubview(overlayView);
        UIApplication.shared.beginIgnoringInteractionEvents();
    }
    
    func stopActivityIndicator() {
        self.activityIndicator.stopAnimating();
        self.overlayView.removeFromSuperview();
        if UIApplication.shared.isIgnoringInteractionEvents {
            UIApplication.shared.endIgnoringInteractionEvents();
        }
    }
    func config(){
        signupButton.layer.cornerRadius = 15
        passwordTextField.isSecureTextEntry = true
        confirmTextField.isSecureTextEntry = true
    }

    @IBAction func signupButton(_ sender: UIButton) {
        let firstname = self.firstNameTextField.text!
        let surname = self.surnameTextField.text!
        let email = self.emailTextField.text!
        let password = self.passwordTextField.text!
        let confirm = self.confirmTextField.text!
        if !isValidEmail(email_str: email){
            createAlert(title: "Warning", message: "Please input valid email address.")
            return
        }
        if password.count < 8 {
            createAlert(title: "Warning", message: "Password have to be at lease 8 characters.")
            return
        }
        if password != confirm {
            createAlert(title: "Warning!", message: "Password doesn't match.")
            return
        }
        Auth.auth().createUser(withEmail: email, password: password, completion: {(user, error) in
            
            if(error != nil) {
                
                if AuthErrorCode(rawValue: error!._code) == .emailAlreadyInUse {
                    self.createAlert(title: "Warning!", message: "Your email address is already exist!")
                } else if AuthErrorCode(rawValue: error!._code) == .networkError {
                    self.createAlert(title: "Warning!", message: "Network Error.")
                } else {
                    self.createAlert(title: "Warning!", message: "There is issue in server. Please try again!")
                }
                return
            }
            // let ref = Database.database().reference()
            let post_data = [
                "uid":Auth.auth().currentUser!.uid,
                "firstname":firstname.capitalized,
                "surname":surname.capitalized,
                "email":email,
                "avatar_url": "",
                ] as [String : Any]
            
            
            Constants.refs.databaseUsers.child(Auth.auth().currentUser!.uid).setValue(post_data, withCompletionBlock: {err, ref in
                
                if err != nil {
                    self.createAlert(title: "Warning!", message: "Network error.")
                } else {
                   // self.createAlert(title: "", message: "Success!")
                    UserDefaults.standard.set(firstname, forKey: "firstname")
                    UserDefaults.standard.set(email, forKey: "email")
                    UserDefaults.standard.set(password, forKey: "password")
                    UserDefaults.standard.set(true, forKey: "signup")
                    UserDefaults.standard.synchronize()
                    self.loginpage()
                    
                }
            })
           
        })
    }
    //signin page
    func loginpage(){
        
        let loginView = self.storyboard?.instantiateViewController(withIdentifier: "loginPage") as! UIViewController
        self.navigationController?.pushViewController(loginView, animated: true)
    }
    func isValidEmail(email_str: String) -> Bool {
        let regExp = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", regExp)
        return emailTest.evaluate(with: email_str)
    }
    //create Alert
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
