//
//  ForgotPasswordViewController.swift
//  footchat
//
//  Created by Marten on 10/2/19.
//  Copyright © 2019 Marten. All rights reserved.
//

import UIKit
import Firebase
class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    // @IBOutlet weak var btn_forgotPwd: UIButton!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView();
    var overlayView:UIView = UIView();
    override func viewDidLoad() {
        super.viewDidLoad()
        //dismiss keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        if UserDefaults.standard.value(forKey: "email") != nil{
            let email = UserDefaults.standard.value(forKey: "email") as! String
            self.emailTextField.text = email
        }
        
    }
    func config(){
        resetButton.layer.cornerRadius = 15
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func isValidEmail(email_str: String) -> Bool {
        let regExp = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", regExp)
        return emailTest.evaluate(with: email_str)
    }
    
    @IBAction func resetButton(_ sender: UIButton) {
        let email = self.emailTextField.text!
        if !isValidEmail(email_str: email) {
            createAlert(title: "Warning!", message: "Please input valid email address.")
            return
        }
        
        
        Auth.auth().sendPasswordReset(withEmail: email, completion: {error in
            self.stopActivityIndicator()
            if error != nil {
                if AuthErrorCode(rawValue: error!._code) == .userDisabled {
                    self.createAlert(title: "Warning!", message: "Your account have been disabled.")
                } else if AuthErrorCode(rawValue: error!._code) == .networkError {
                    self.createAlert(title: "Warning!", message: "Network Error.")
                } else if AuthErrorCode(rawValue: error!._code) == .userNotFound {
                    self.createAlert(title: "Warning!", message: "Email is incorrect. Please try again.")
                } else {
                    self.createAlert(title: "Warning!", message: "There is error in server. Please try again.")
                }
                return
            }
            self.createAlert(title: "Success!", message: "Reset password link have been sent your email address.")
            
        })
    }
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

    @IBAction func loginButton(_ sender: UIButton) {
        loginpage()
    }
    //signin page
    func loginpage(){
        let loginView = self.storyboard?.instantiateViewController(withIdentifier: "loginPage") as! UIViewController
        self.navigationController?.pushViewController(loginView, animated: true)
    }
}
