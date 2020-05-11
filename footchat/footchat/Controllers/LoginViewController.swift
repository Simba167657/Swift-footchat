//
//  ViewController.swift
//  footchat
//
//  Created by Marten on 10/2/19.
//  Copyright © 2019 Marten. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var hostSwitch: UISwitch!
    @IBOutlet weak var loginButton: UIButton!
    ///////   for activity indicator  //////////
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var overlayView:UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        if UserDefaults.standard.value(forKey: "email") != nil{
            let email = UserDefaults.standard.value(forKey: "email") as! String
            self.emailTextField.text = email
        }
        ////  dismiss keyboard   ///////
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    func config(){
        loginButton.layer.cornerRadius = 15
        passwordTextField.isSecureTextEntry = true
    }
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
    
    @IBAction func loginButton(_ sender: UIButton) {
        let email = self.emailTextField.text!
        let password = self.passwordTextField.text!
        if !isValidEmail(email_str: email){
            self.createAlert(title: "Warning!", message: "Please input valid email address.")
        }
        if password.count < 8 {
            self.createAlert(title: "Warning", message: "Password have to be at lease 8 characters.")
        }
        self.startActivityIndicator()
        Auth.auth().signIn(withEmail: email, password: password, completion: ({(user, error) in
            self.stopActivityIndicator()
            if error != nil {
                if AuthErrorCode(rawValue: error!._code) == .userDisabled {
                    self.createAlert(title: "Warning!", message: "Your account have been disabled.")
                } else if AuthErrorCode(rawValue: error!._code) == .networkError {
                    self.createAlert(title: "Warning!", message: "Network Error.")
                } else if AuthErrorCode(rawValue: error!._code) == .wrongPassword {
                    self.createAlert(title: "Warning!", message: "Password is incorrect. Please try again.")
                } else if AuthErrorCode(rawValue: error!._code) == .userNotFound {
                    self.createAlert(title: "Warning!", message: "Email is incorrect. Please try again.")
                } else {
                    self.createAlert(title: "Warning!", message: "There is error in server. Please try again.")
                }
                return
            }
            }
        ))
       
        if hostSwitch.isOn {
            let hoststate = "on"
            UserDefaults.standard.set(email, forKey: "email")
            UserDefaults.standard.set(hoststate, forKey: "hoststate")
            UserDefaults.standard.synchronize()
            let profileView = self.storyboard?.instantiateViewController(withIdentifier: "profilePage") as! UIViewController
            self.navigationController?.pushViewController(profileView, animated: true)
        }
        else
        {
            let hoststate = "off"
            UserDefaults.standard.set(email, forKey: "email")
            UserDefaults.standard.set(hoststate, forKey: "hoststate")
            UserDefaults.standard.synchronize()
            let profileView = self.storyboard?.instantiateViewController(withIdentifier: "profilePage") as! UIViewController
            self.navigationController?.pushViewController(profileView, animated: true)
        }
       
    }
    
    @IBAction func signupButton(_ sender: UIButton) {
        let signupView = self.storyboard?.instantiateViewController(withIdentifier: "signupPage") as! UIViewController
        self.navigationController?.pushViewController(signupView, animated: true)
    }
    
    @IBAction func forgotPasswordButton(_ sender: UIButton) {
        let forgotView = self.storyboard?.instantiateViewController(withIdentifier: "forgotPage") as! UIViewController
        self.navigationController?.pushViewController(forgotView, animated: true)
    }
    //email check
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
}

