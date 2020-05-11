//
//  RegisterHostViewController.swift
//  footchat
//
//  Created by Marten on 10/2/19.
//  Copyright © 2019 Marten. All rights reserved.
//

import UIKit
import iOSDropDown
import Firebase
import FirebaseDatabase
import DatePickerDialog

class RegisterHostViewController: UIViewController ,UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var starttimeDatePicker: UIDatePicker!
    @IBOutlet weak var endtimeDatePicker: UIDatePicker!
    @IBOutlet weak var starttimeTextField: UITextField!
    @IBOutlet weak var endtimeTextField: UITextField!
    @IBOutlet weak var typeDropDown: DropDown!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var hostLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var longitude: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var addDisableButton: UIButton!
    ///////   for activity indicator  //////////
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView();
    var overlayView:UIView = UIView();
    override func viewDidLoad() {
        super.viewDidLoad()
        let uid = Auth.auth().currentUser!.uid as! String
        let ref = Database.database().reference()
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: {snapshot in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let dic = snap.value as! [String: Any]
                if (dic["uid"] as! String == uid) {
                    self.hostLabel.text = dic["pname"] as? String                   
                }
            }
            
        })
        config()
        typeDropDown_setting()
        // Do any additional setup after loading the view.
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.value(forKey: "locationName") != nil{
            let locationName = UserDefaults.standard.value(forKey: "locationName") as! String
            let latitude = UserDefaults.standard.value(forKey: "latitude") as! String
            let longitude = UserDefaults.standard.value(forKey: "longitude") as! String
            self.locationTextField.text = locationName
            self.latitudeLabel.text = latitude
            self.longitude.text = longitude
        }
    }
    func config(){
        if UserDefaults.standard.value(forKey: "hoststate") != nil{
            let hoststate = UserDefaults.standard.value(forKey: "hoststate") as! String
            if(hoststate == "on"){
                addDisableButton.isHidden = true
            }
        }
        saveButton.layer.cornerRadius = 15
        starttimeTextField.isHidden = true
        endtimeTextField.isHidden = true
        latitudeLabel.isHidden = true
        longitude.isHidden = true
    }
   
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    func validate(textView: UITextView) -> Bool {
        guard let text = textView.text,
            !text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
                return false
        }
        return true
    }
    //dropdown Setting
    func typeDropDown_setting(){
        self.typeDropDown.optionArray = ["5-a-side","7-a-side","11-a-side"]
        self.typeDropDown.optionIds = [1,2,3]
        self.typeDropDown.didSelect{(selectedText , index ,id) in
            
        }
        
    }
    
    @IBAction func dateSettingButton(_ sender: UIButton) {
        DatePickerDialog().show("Please choose your date!", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: Date(), datePickerMode: .date) { (date) in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-d"
                let str_date = formatter.string(from: dt)
                self.dateTextField.text = str_date
            }
        }
        
    }
    @IBAction func starttimeDatePicker(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm"
        let strDate = formatter.string(from: starttimeDatePicker.date)
        self.starttimeTextField.text = strDate
        
    }
    
    @IBAction func endtimeDatePicker(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm"
        let strDate = formatter.string(from: endtimeDatePicker.date)
        self.endtimeTextField.text = strDate
    }
    @IBAction func saveButton(_ sender: UIButton) {
        let uid = Auth.auth().currentUser!.uid as String
        let key = Constants.refs.databaseRoot.childByAutoId().key! as String
        let date = self.dateTextField.text!
        let startTime = self.starttimeTextField.text!
        let endTime = self.endtimeTextField.text!
        let type = self.typeDropDown.text!
        let location = self.locationTextField.text!
        let host = self.hostLabel.text!
        let latitude = self.latitudeLabel.text!
        let longitude = self.longitude.text!
        let post_data = [
            "date":date,
            "starttime":startTime,
            "endtime":endTime,
            "type":type,
            "location":location,
            "latitude":latitude,
            "longitude":longitude,
            "host":host,
            "uid":uid,
            ] as [String: Any]
        Constants.refs.databaseHost.child("\(key)").setValue(post_data, withCompletionBlock: {err, ref in
            
            if err != nil {
                self.createAlert(title: "Warning!", message: "Network error.")
            } else {
                self.createAlert(title: "", message: "successfully saved")
                
            }
        })
        
        
    }
    
    @IBAction func locationButton(_ sender: UIButton) {
        let pageName = "registerPage"
        UserDefaults.standard.set(pageName, forKey: "pageName")
        UserDefaults.standard.synchronize()
        let placeView = self.storyboard?.instantiateViewController(withIdentifier: "placePage") as! UIViewController
        self.navigationController?.pushViewController(placeView, animated: true)
    }
 
    
    @IBAction func addButton(_ sender: UIButton) {
        self.createAlert(title: "", message: "Do you want to add a new host?")
        self.dateTextField.text = ""
        self.starttimeTextField.text = ""
        self.endtimeTextField.text = ""
        // self.typeTextField.text = ""
        self.locationTextField.text = ""
        self.hostLabel.text = ""
        self.dateTextField.delegate = self
    }
    
    @IBAction func profileButton(_ sender: UIButton) {
        let profileView = self.storyboard?.instantiateViewController(withIdentifier: "profilePage") as! UIViewController
        self.navigationController?.pushViewController(profileView, animated: true)
    }
    
    @IBAction func listButton(_ sender: UIButton) {
        let listView = self.storyboard?.instantiateViewController(withIdentifier: "listhostPage") as! UIViewController
        self.navigationController?.pushViewController(listView, animated: true)
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
}
