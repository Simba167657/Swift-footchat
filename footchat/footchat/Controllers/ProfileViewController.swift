//
//  ProfileViewController.swift
//  footchat
//
//  Created by Marten on 10/2/19.
//  Copyright © 2019 Marten. All rights reserved.
//

import UIKit
import iOSDropDown
import Firebase
import FirebaseDatabase
import Kingfisher
class ProfileViewController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    ///////   for activity indicator  //////////
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var overlayView:UIView = UIView()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var preferrednameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var positionDropDown: DropDown!
    @IBOutlet weak var genderDropDown: DropDown!
    @IBOutlet weak var footTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var regHostButton: UIButton!
    @IBOutlet weak var addDisableButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        self.startActivityIndicator()
        userinfo()
        positionDropDown_setting()
        genderDropDown_setting()
        let pictureTap = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.imageTapped))
        self.avatarImage.addGestureRecognizer(pictureTap)
        self.avatarImage.isUserInteractionEnabled = true
        
        ////  dismiss keyboard   ///////
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.value(forKey: "locationName") != nil{
            let locationName = UserDefaults.standard.value(forKey: "locationName") as! String
            let latitude = UserDefaults.standard.value(forKey: "latitude") as! String
            let longitude = UserDefaults.standard.value(forKey: "longitude") as! String
            self.locationTextField.text = locationName
         //   self.latitudeLabel.text = latitude
         //   self.longitude.text = longitude
        }
    }
    func config(){
        if UserDefaults.standard.value(forKey: "hoststate") != nil{
            let hoststate = UserDefaults.standard.value(forKey: "hoststate") as! String
            if(hoststate == "on"){
                addDisableButton.isHidden = true
            }
            else {
                addDisableButton.isHidden = true
                regHostButton.isHidden = true
            }
        }
        
        saveButton.layer.cornerRadius = 15
        avatarImage.layer.cornerRadius = avatarImage.bounds.height/2
    }
    //dropdown Setting
    func positionDropDown_setting(){
        self.positionDropDown.optionArray = ["GK","LB","CB","RB","LM","CM","RM","ST"]
        self.positionDropDown.optionIds = [1,2,3,4,5,6,7,8]
        self.positionDropDown.didSelect{(selectedText , index ,id) in
            
        }
        
    }
 
    
    func genderDropDown_setting(){
        self.genderDropDown.optionArray = ["M","F"]
        self.genderDropDown.optionIds = [1,2]
        self.genderDropDown.didSelect{(selectedText , index ,id) in
        }
    }
    func userinfo(){
        let ref = Database.database().reference()
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: {snapshot in
               self.stopActivityIndicator()
            for child in snapshot.children {
              
                let snap = child as! DataSnapshot
                let dic = snap.value as! [String: Any]
               // let ratingInt = Int(rating!) as? Int
                if dic["email"] as! String == UserDefaults.standard.string(forKey: "email")! {
                 //   if(dic["pname"] as? String != nil){
                        self.firstnameTextField.text = dic["firstname"] as? String
                        self.surnameTextField.text = dic["surname"] as? String
                        self.preferrednameTextField.text = dic["pname"] as? String
                        self.locationTextField.text = dic["location"] as? String
                        self.positionDropDown.text = dic["position"] as? String
                        self.ageTextField.text = dic["age"] as? String
                    
                        self.footTextField.text = dic["foot"] as? String
                        self.genderDropDown.text = dic["gender"] as? String
                    
                        if dic["avatar_url"] as? String != "" {
                            let image_url = URL(string: dic["avatar_url"] as! String)
                            self.avatarImage.kf.setImage(with: image_url)
                            
                        }
                    //}
                }
            }
            
        })
       
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    @objc func imageTapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action: UIAlertAction) in
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Gallery", style: .default, handler: {(action: UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.popoverPresentationController?.sourceView = self.view;
        actionSheet.popoverPresentationController?.barButtonItem = self.navigationItem.leftBarButtonItem
        actionSheet.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
        self.present(actionSheet, animated: true, completion: nil)
    }
    @IBAction func saveButton(_ sender: UIButton) {
        let firstname = self.firstnameTextField.text!
        let surname = self.surnameTextField.text!
        let pname = self.preferrednameTextField.text!
        let location = self.locationTextField.text!
        let position = self.positionDropDown.text!
        let age = self.ageTextField.text!
        let foot = self.footTextField.text!
        let gender = self.genderDropDown.text!
      
       // print(rating)
        let post_data = [
            "firstname": firstname,
            "surname":surname,
            "pname":pname,
            "location":location,
            "position":position,
            "age":age,
            "foot":foot,
            "gender":gender
           
            ] as [String : Any]
        self.upload_data(post_data: post_data)
    }
    func upload_data(post_data: [String: Any]) {
        Constants.refs.databaseUsers.child(Auth.auth().currentUser!.uid).updateChildValues(post_data)
        self.createAlert(title: "", message: "successfully saved")
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        self.avatarImage.image = image
        picker.dismiss(animated: true, completion: nil)
        let firstname = self.firstnameTextField.text!
        let surname = self.surnameTextField.text!
        let pname = self.preferrednameTextField.text!
        let location = self.locationTextField.text!
        let position = self.positionDropDown.text!
        let age = self.ageTextField.text!
        let foot = self.footTextField.text!
        let gender = self.genderDropDown.text!
       
        // startActivityIndicator();
        self.uploadImage(image) { url in
            if url != nil {
                //                let email = UserDefaults.standard.string(forKey: "email")
                
                let email = UserDefaults.standard.string(forKey: "email")!
                let post_data = [
                    "firstname": firstname,
                    "lastname":surname,
                    "pname":pname,
                    "location":location,
                    "position":position,
                    "age":age,
                    "foot":foot,
                    "gender":gender,                 
                    "email":email,
                    "avatar_url": url!.absoluteString,
                    ] as [String : Any]
                //                let ref = Database.database().reference()
                //                ref.child("users").child(Auth.auth().currentUser!.uid).setValue(post_data)
                self.upload_data(post_data: post_data)
                self.avatarImage.image = image
                
            } else {
                self.createAlert(title: "Warning!", message: "Network error.")
            }
            
        }
    }
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
   
    
   
    
    @IBAction func regHostButton(_ sender: UIButton) {
        let regHostView = self.storyboard?.instantiateViewController(withIdentifier: "reghostPage") as! UIViewController
        self.navigationController?.pushViewController(regHostView, animated: true)
    }
    
    @IBAction func listLostButton(_ sender: UIButton) {
        if UserDefaults.standard.value(forKey: "hoststate") != nil{
            let hoststate = UserDefaults.standard.value(forKey: "hoststate") as! String
            if(hoststate == "on"){
                let listView = self.storyboard?.instantiateViewController(withIdentifier: "listhostPage") as! UIViewController
                self.navigationController?.pushViewController(listView, animated: true)
            }
            else
            {
                let playerView = self.storyboard?.instantiateViewController(withIdentifier: "listplayerPage") as! UIViewController
                self.navigationController?.pushViewController(playerView, animated: true)
                
            }
        }
    }
  
    @IBAction func logoutButton(_ sender: UIButton) {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                let loginView = self.storyboard?.instantiateViewController(withIdentifier: "loginPage") as! UIViewController
                self.navigationController?.pushViewController(loginView, animated: true)
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func locationButton(_ sender: UIButton) {
        let pageName = "profilePage"
        UserDefaults.standard.set(pageName, forKey: "pageName")
        UserDefaults.standard.synchronize()
        let placeView = self.storyboard?.instantiateViewController(withIdentifier: "placePage") as! UIViewController
        self.navigationController?.pushViewController(placeView, animated: true)
    }
    func startActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        activityIndicator.color = UIColor.black
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        overlayView = UIView(frame:view.frame)
        view.addSubview(overlayView)
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func stopActivityIndicator() {
        self.activityIndicator.stopAnimating()
        self.overlayView.removeFromSuperview()
        if UIApplication.shared.isIgnoringInteractionEvents {
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
    
}
extension ProfileViewController {
    func uploadImage(_ image: UIImage, completion: @escaping (_ url: URL?) -> ()) {
        let currentDate = Date()
        let currentDateMillisecond = Int(currentDate.timeIntervalSince1970 * 1000)
        let upload_image = image.resized(withPercentage: 0.05)
        let filename = "\(currentDateMillisecond).png"
        let storageRef = Storage.storage().reference().child(filename)
        let imgData = upload_image!.pngData()
        let metaData = StorageMetadata()
        metaData.contentType = "image/png"
        storageRef.putData(imgData!, metadata: metaData) { (metadata, error) in
            if error == nil {
                print("success_______________")
                storageRef.downloadURL(completion: {(url, error) in
                    completion(url!)
                })
            } else {
                print("error to upload image_____________")
                completion(nil)
            }
        }
    }
    
    func saveImage(profileURL: URL, purchase_status: Bool, completion: @escaping (_ success: Bool?) -> ()) {
        let ref = Database.database().reference()
        let post_data = [
            //            "name": self.post_name,
            //            "link": self.link,
            //            "earning": self.earning_double,
            //            "category": self.selected_category_index,
            //            "created_at": Firebase.ServerValue.timestamp(),
            //            "visit_count": 0,
            //            "image_url": profileURL.absoluteString,
            //            "purchase_state": purchase_status
            "name": "dddd"
            ] as [String : Any]
        
        
        ref.childByAutoId().setValue(post_data, withCompletionBlock: {err, ref in
            if err != nil {
                completion(false)
            } else {
                completion(true)
            }
        })
    }
}
extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        return UIGraphicsImageRenderer(size: canvas, format: imageRendererFormat).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvas = CGSize(width: CGFloat(ceil(width/size.width * size.height)), height: CGFloat(ceil(width/size.width * size.height)))
        return UIGraphicsImageRenderer(size: canvas, format: imageRendererFormat).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    
}
