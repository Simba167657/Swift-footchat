//
//  ReviewsViewController.swift
//  footchat
//
//  Created by Marten on 10/12/19.
//  Copyright © 2019 Marten. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

class ReviewsViewController: UIViewController {

    private var playerListRefHandle: DatabaseHandle?
    @IBOutlet weak var firstnameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var punctualRating: FloatRatingView!
    @IBOutlet weak var respectfulRatingView: FloatRatingView!
    @IBOutlet weak var pliveLabel: UILabel!
    @IBOutlet weak var pupdateLabel: UILabel!
    @IBOutlet weak var rliveLabel: UILabel!
    @IBOutlet weak var rupdateLabel: UILabel!
    @IBOutlet weak var addDisableButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    var punRating = Double()
    var count = Int()
    var resRating = Double()
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        userinfo()
        punctualRating.backgroundColor = UIColor.clear
        respectfulRatingView.backgroundColor = UIColor.clear
        punctualRating.delegate = self
        respectfulRatingView.delegate = self
        punctualRating.contentMode = UIView.ContentMode.scaleAspectFit
        respectfulRatingView.contentMode = UIView.ContentMode.scaleAspectFit
       
    }
    func config(){
        if UserDefaults.standard.value(forKey: "hoststate") != nil{
            let hoststate = UserDefaults.standard.value(forKey: "hoststate") as! String
            if(hoststate == "on"){
                addDisableButton.isHidden = true
            }
        }
        saveButton.layer.cornerRadius = 15
      
        punctualRating.type = .floatRatings
        respectfulRatingView.type = .floatRatings
    }
    func userinfo(){
        playerListRefHandle =  Constants.refs.databaseUsers.observe(.childAdded, with: { (snapshot) -> Void in
            let playerData = snapshot.value as! Dictionary<String, AnyObject>
            let id = snapshot.key
            if UserDefaults.standard.value(forKey: "hostUid") != nil{
                let hostuid = UserDefaults.standard.value(forKey: "hostUid") as! String
                if playerData["uid"] as! String == UserDefaults.standard.string(forKey: "hostUid")! {
                    let uid = playerData["uid"] as! String
                    let name = playerData["firstname"] as! String
                    let age = playerData["age"] as! String
                    let location = playerData["location"] as! String
                    let email = playerData["email"] as! String
                    let punctualRating = playerData["punctualRating"] as! Double
                    let respectfulRating = playerData["respectfulRating"] as! Double
                    self.count = playerData["count"] as! Int
                    let pRating = punctualRating / Double(self.count)
                    let rRating = respectfulRating / Double(self.count)
                    
                    self.punRating = punctualRating
                    self.resRating = respectfulRating
                    self.firstnameLabel.text =  name
                    self.ageLabel.text = age
                    self.locationLabel.text = location
                    self.punctualRating.rating = pRating
                    self.respectfulRatingView.rating = rRating
                    self.pliveLabel.text = String(format: "%.2f", pRating)
                    self.pupdateLabel.text = String(format: "%.2f", pRating)
                    self.rliveLabel.text = String(format: "%.2f", rRating)
                    self.rupdateLabel.text = String(format: "%.2f", rRating)
                   
                }
                
            }
        })
        
    }
    @IBAction func ratingTypeChanged(_ sender: UISegmentedControl) {
       
          punctualRating.type = .floatRatings
          respectfulRatingView.type = .floatRatings
       
    }
    @IBAction func saveButton(_ sender: UIButton) {
        let punctualRating = self.punctualRating.rating as! Double
        let respectfulRating = self.respectfulRatingView.rating as! Double
        let cnt = self.count + 1
        let puct = self.punRating + punctualRating
        let res = self.resRating + respectfulRating
        let post_data = [
           "punctualRating":puct,
           "respectfulRating":res,
           "count":cnt
            ] as [String : Any]
       self.upload_data(post_data: post_data)
    }
    func upload_data(post_data: [String: Any]) {
         let hostuid = UserDefaults.standard.value(forKey: "hostUid") as! String
        Constants.refs.databaseUsers.child(hostuid).updateChildValues(post_data)
        self.createAlert(title: "", message: "successfully saved")
    }
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func profileButton(_ sender: UIButton) {
        let profileView = self.storyboard?.instantiateViewController(withIdentifier: "profilePage") as! UIViewController
        self.navigationController?.pushViewController(profileView, animated: true)
    }
    
    @IBAction func listButton(_ sender: UIButton) {
        let listView = self.storyboard?.instantiateViewController(withIdentifier: "listhostPage") as! UIViewController
        self.navigationController?.pushViewController(listView, animated: true)
    }
    
    @IBAction func addButton(_ sender: UIButton) {
        let regHostView = self.storyboard?.instantiateViewController(withIdentifier: "reghostPage") as! UIViewController
        self.navigationController?.pushViewController(regHostView, animated: true)
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
extension ReviewsViewController: FloatRatingViewDelegate {
    
    // MARK: FloatRatingViewDelegate
    
    func floatRatingView(_ ratingView: FloatRatingView, isUpdating rating: Double) {
        pliveLabel.text = String(format: "%.2f", self.punctualRating.rating)
        rliveLabel.text = String(format: "%.2f", self.respectfulRatingView.rating)
        
    }
   
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Double) {
        pupdateLabel.text = String(format: "%.2f", self.punctualRating.rating)
        rupdateLabel.text = String(format: "%.2f", self.respectfulRatingView.rating)
    }
    
    
}
