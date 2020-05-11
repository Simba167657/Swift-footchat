//
//  PlacePickerViewController.swift
//  footchat
//
//  Created by Marten on 10/5/19.
//  Copyright © 2019 Marten. All rights reserved.
//

import UIKit
import GooglePlacePicker
import Firebase
import FirebaseDatabase

class PlacePickerViewController: UIViewController {

    @IBOutlet weak var lblname: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblLatitude: UILabel!
    @IBOutlet weak var lblLongitude: UILabel!   
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var viewContainer: UIView!
    var pageName = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.value(forKey: "pageName") != nil{
            self.pageName = UserDefaults.standard.value(forKey: "pageName") as! String
            
        }
        self.getPlacePickerView()
        config()
        // Do any additional setup after loading the view.
    }
    func config(){
        saveButton.layer.cornerRadius = 15
    }
    func getPlacePickerView() {
        
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        
        
        present(placePicker, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
            let locationName = self.lblname.text!
            let latitude = self.lblLatitude.text!
            let longitude = self.lblLongitude.text!
            let post_data = [
                "location": locationName,
                "latitude":latitude,
                "longitude":longitude
                ] as [String : Any]
        
      let pageNames = self.pageName
        if(pageNames == "profilePage"){
             self.upload_data(post_data: post_data)
        }
       else
        {
             self.upload_data_host(post_data: post_data)
        }
       
    }
    func upload_data(post_data: [String: Any]) {
        let locationName = post_data["location"] as? String
        let latitude = post_data["latitude"] as? String
        let longitude = post_data["longitude"] as? String
        
        UserDefaults.standard.set(locationName, forKey: "locationName")
        UserDefaults.standard.set(latitude, forKey: "latitude")
        UserDefaults.standard.set(longitude, forKey: "longitude")
        UserDefaults.standard.synchronize()
        Constants.refs.databaseUsers.child(Auth.auth().currentUser!.uid).updateChildValues(post_data)       
        let profileView = self.storyboard?.instantiateViewController(withIdentifier: "profilePage") as! UIViewController
        self.navigationController?.pushViewController(profileView, animated: true)
    }
    func upload_data_host(post_data: [String: Any]) {
        let locationName = post_data["location"] as? String
        let latitude = post_data["latitude"] as? String
        let longitude = post_data["longitude"] as? String
      
        UserDefaults.standard.set(locationName, forKey: "locationName")
        UserDefaults.standard.set(latitude, forKey: "latitude")
        UserDefaults.standard.set(longitude, forKey: "longitude")
        UserDefaults.standard.synchronize()
        
        let regHostView = self.storyboard?.instantiateViewController(withIdentifier: "reghostPage") as! UIViewController
        self.navigationController?.pushViewController(regHostView, animated: true)
    }
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
extension PlacePickerViewController : GMSPlacePickerViewControllerDelegate
{
    // GMSPlacePickerViewControllerDelegate and implement this code.
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        self.viewContainer.isHidden = false
        self.indicatorView.isHidden = true
        
        viewController.dismiss(animated: true, completion: nil)
        
        self.lblname.text = place.name
        self.lblAddress.text = place.formattedAddress?.components(separatedBy: ", ")
            .joined(separator: "\n")
        self.lblLatitude.text = String(place.coordinate.latitude)
        self.lblLongitude.text = String(place.coordinate.longitude)
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        
        viewController.dismiss(animated: true, completion: nil)
        
        self.viewContainer.isHidden = true
        self.indicatorView.isHidden = true
    }
}
