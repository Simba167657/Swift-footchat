//
//  PlayerListViewController.swift
//  footchat
//
//  Created by Marten on 10/3/19.
//  Copyright © 2019 Marten. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import GoogleMaps
import Kingfisher
class PlayerListViewController: UIViewController,GMSMapViewDelegate,CLLocationManagerDelegate,UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate {
    var playerLists = [Player]()
        private var playerListRefHandle: DatabaseHandle?
        @IBOutlet weak var segmentControl: UISegmentedControl!
        @IBOutlet weak var mapView: GMSMapView!
        @IBOutlet weak var customTableView: UITableView!
        @IBOutlet weak var customView: UIView!
    
    @IBOutlet weak var regHostButton: UIButton!
    @IBOutlet weak var addDisableButton: UIButton!
    var markerSelected: String?
    var cusername = String()
    // MARK: - Activity Indicator
    fileprivate var activityIndicator: UIActivityIndicatorView!
    private var infoWindow = MapInfoWindow()
    fileprivate var locationMarker : GMSMarker? = GMSMarker()
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentControl.addTarget(self, action: #selector(PlayerListViewController.segmentedDidChange(_:)), for: .valueChanged)
        config()
        activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        self.mapView.delegate = self
        location_search()
       // loadPlayerList()
        
    }
    func loadNiB() -> MapInfoWindow{
        let infoWindow = MapInfoWindow.instanceFromNib() as! MapInfoWindow
        return infoWindow
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        activityIndicator.center = self.view.center
    }
    func location_search(){
        if UserDefaults.standard.value(forKey: "hoststate") != nil{
            let hoststate = UserDefaults.standard.value(forKey: "hoststate") as! String
            if(hoststate == "on"){
                    Constants.refs.databasePlayerMatch.observe(DataEventType.value, with: {(DataSnapshot) in
                        if DataSnapshot.childrenCount > 0 {
                            // print(DataSnapshot.childrenCount)
                                for databaserRefer in DataSnapshot.children.allObjects as! [DataSnapshot]
                                {
                                    let  matchObj = databaserRefer.value as? [String: AnyObject]
                                
                                    if UserDefaults.standard.value(forKey: "hostKey") != nil{
                                        let hostKey = UserDefaults.standard.value(forKey: "hostKey") as! String
                                        if(hostKey == matchObj?["hostkey"] as! String){
                                                let  matchuid = matchObj?["uid"] as! String
                                                let query =  Constants.refs.databaseUsers.queryOrdered(byChild: "uid").queryEqual(toValue: "\(matchuid)")
                                                query.observeSingleEvent(of: .value, with: { snapshot in
                                                    for child in snapshot.children {
                                                        let childSnap = child as! DataSnapshot
                                                        let dict = childSnap.value as! [String: Any]
                                                        let  uid = dict["uid"] as! String
                                                        let  name = dict["firstname"] as! String
                                                        let  age = dict["age"] as! String
                                                        let  position = dict["position"] as! String
                                                        let  image_url = dict["avatar_url"]
                                                        let  playerLocation = dict["location"] as! String
                                                        let  playerlatitude = dict["latitude"] as! String
                                                        let  playerlongitude = dict["longitude"] as! String
                                                        //currentuser name
                                                        let  cuid = Auth.auth().currentUser?.uid as! String
                                                        let  cquery = Constants.refs.databaseUsers.queryOrdered(byChild: "uid").queryEqual(toValue: "\(cuid)")
                                                        cquery.observeSingleEvent(of: .value, with: { snapshot in
                                                            for child in snapshot.children {
                                                                let childSnap = child as! DataSnapshot
                                                                let cdict = childSnap.value as! [String: Any]
                                                                self.cusername = cdict["firstname"] as! String
                                                                let currentname = self.cusername
                                                                UserDefaults.standard.set(currentname, forKey: "currentname")
                                                                UserDefaults.standard.synchronize()
                                                            }
                                                        })
                                                        let camera = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(Float(playerlatitude)!), longitude: CLLocationDegrees(Float(playerlongitude)!), zoom: 8.0)
                                                        self.mapView.camera = camera
                                                        let url = URL(string: image_url as! String)
                                                        let data = try? Data(contentsOf: url! as URL)
                                                        let currentname = self.cusername
                                                        let userdatas = uid + "#" + name + "#" + age + "#" + position + "#" + playerLocation 
                                                      
                                                        let marker = GMSMarker()
                                                        marker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(Float(playerlatitude)!), longitude: CLLocationDegrees(Float(playerlongitude)!))
                                                       //marker.icon = self.drawImageWithProfilePic(pp: UIImage.init(data:data!)!, image: UIImage.init(named: "green")!)
                                                         //self.avatarImage.kf.setImage(with: image_url)
                                                      //  marker.icon = UIImage(named: image_url as! String)
                                                        marker.icon = self.drawImageWithProfilePic(pp: UIImage.init(data: data!)!, image: UIImage.init(named: "location_person")!)
                                                        marker.appearAnimation = GMSMarkerAnimation.pop
                                                        marker.userData = userdatas // index
                                                        self.infoWindow = self.loadNiB()
                                                        marker.map = self.mapView
                                                    }
                                                })
                                            }
                                        }
                                    }
                                }
                            })
                        }
            else {
                Constants.refs.databasePlayerMatch.observe(DataEventType.value, with: {(DataSnapshot) in
                    if DataSnapshot.childrenCount > 0 {
                        // print(DataSnapshot.childrenCount)
                        for databaserRefer in DataSnapshot.children.allObjects as! [DataSnapshot]
                        {
                            let  matchObj = databaserRefer.value as? [String: AnyObject]
                            
                            if UserDefaults.standard.value(forKey: "hostKey") != nil{
                                let hostKey = UserDefaults.standard.value(forKey: "hostKey") as! String
                                if(hostKey == matchObj?["hostkey"] as! String){
                                    let  matchuid = matchObj?["uid"] as! String
                                    let query =  Constants.refs.databaseUsers.queryOrdered(byChild: "uid").queryEqual(toValue: "\(matchuid)")
                                    query.observeSingleEvent(of: .value, with: { snapshot in
                                        for child in snapshot.children {
                                            let childSnap = child as! DataSnapshot
                                            let dict = childSnap.value as! [String: Any]
                                            let  uid = dict["uid"] as! String
                                            let  name = dict["firstname"] as! String
                                            let  age = dict["age"] as! String
                                            let  position = dict["position"] as! String
                                            let  image_url = dict["avatar_url"] as! String
                                            let  playerLocation = dict["location"] as! String
                                            let  playerlatitude = dict["latitude"] as! String
                                            let  playerlongitude = dict["longitude"] as! String
                                 //current username
                                            let  cuid = Auth.auth().currentUser?.uid as! String
                                            let  cquery = Constants.refs.databaseUsers.queryOrdered(byChild: "uid").queryEqual(toValue: "\(cuid)")
                                            
                                             cquery.observeSingleEvent(of: .value, with: { snapshot in
                                                for child in snapshot.children {
                                                    let cSnap = child as! DataSnapshot
                                                    let cdict = cSnap.value as! [String: Any]
                                                    self.cusername = cdict["firstname"] as! String
                                                    let currentname = self.cusername
                                                    UserDefaults.standard.set(currentname, forKey: "currentname")
                                                    UserDefaults.standard.synchronize()
                                                }
                                            })
                                            let camera = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(Float(playerlatitude)!), longitude: CLLocationDegrees(Float(playerlongitude)!), zoom: 8.0)
                                            let url = URL(string: image_url as! String)
                                            let data = try? Data(contentsOf: url! as URL)
                                            self.mapView.camera = camera
                                          
                                            let userdatas = uid + "#" + name + "#" + age + "#" + position + "#" + playerLocation
                                            let marker = GMSMarker()
                                            marker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(Float(playerlatitude)!), longitude: CLLocationDegrees(Float(playerlongitude)!))
                                            marker.icon = self.drawImageWithProfilePic(pp: UIImage.init(data: data!)!, image: UIImage.init(named: "location_person")!)
                                            marker.appearAnimation = GMSMarkerAnimation.pop
                                            marker.userData = userdatas // index
                                            marker.map = self.mapView
                                        }
                                    })
                                }
                            }
                        }
                    }
                })
                
            }
        }
        
    }
    func drawImageWithProfilePic(pp: UIImage, image: UIImage) -> UIImage {
        let imgView = UIImageView(image: image)
        imgView.frame = CGRect(x: 0, y: 0, width: 60, height: 90)
        let picImgView = UIImageView(image: pp)
        picImgView.frame = CGRect(x: 0, y: 0, width: 45, height: 45)
        imgView.addSubview(picImgView)
        picImgView.center.x = imgView.center.x
        picImgView.center.y = imgView.center.y - 16
        picImgView.layer.cornerRadius = picImgView.frame.width/2
        picImgView.clipsToBounds = true
        imgView.setNeedsLayout()
        picImgView.setNeedsLayout()
        
        let newImage = imageWithView(view: imgView)
        return newImage
    }
    func imageWithView(view: UIView) -> UIImage {
        var image: UIImage?
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            view.layer.render(in: context)
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        return image ?? UIImage()
    }
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
       
        self.markerSelected = marker.userData as? String
        let userData = self.markerSelected        
        let result = userData?.components(separatedBy: "#")
        let uid = result?[0] as? String
        let firstname = result?[1] as? String
        let age = result?[2] as? String
        let position = result?[3] as? String
        let playerLocation = result?[4] as? String      
        UserDefaults.standard.set(uid, forKey: "uid")
        UserDefaults.standard.set(firstname, forKey: "firstname")
        UserDefaults.standard.synchronize()
         locationMarker = marker
        guard let location = locationMarker?.position else {
            print("locationMarker is nil")
            return false
        }
        infoWindow.removeFromSuperview()
        infoWindow = loadNiB()
        infoWindow.center = mapView.projection.point(for: location)
        infoWindow.center.y = infoWindow.center.y - sizeForOffset(view: infoWindow)
        // userinfo
        infoWindow.nameLabel.text = firstname
        infoWindow.ageLabel.text = age
        infoWindow.locationLabel.text = playerLocation
        infoWindow.positionLabel.text = position       
        infoWindow.chatButton.addTarget(self, action: #selector(PlayerListViewController.chataction(sender:)), for: .touchUpInside)
        
        self.view.addSubview(infoWindow)        
        return false
        //return true
    }
    @objc func chataction(sender: UIButton) {
        let chatView = self.storyboard?.instantiateViewController(withIdentifier: "chatPage") as! UIViewController
        self.navigationController?.pushViewController(chatView, animated: true)
    }
    func sizeForOffset(view: UIView) -> CGFloat {
        return  35.0
    }
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        infoWindow.removeFromSuperview()
    }
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if (locationMarker != nil){
            guard let location = locationMarker?.position else {
                print("locationMarker is nil")
                return
            }
            infoWindow.center = mapView.projection.point(for: location)
            infoWindow.center.y = infoWindow.center.y - sizeForOffset(view: infoWindow)
        }
    }
    
    // MARK: Needed to create the custom info window
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return UIView()
    }
    func config(){
        if UserDefaults.standard.value(forKey: "hoststate") != nil{
            let hoststate = UserDefaults.standard.value(forKey: "hoststate") as! String
            if(hoststate == "on"){
                addDisableButton.isHidden = true
            }
        }
        mapView.isHidden = false
        customView.isHidden = true
        customTableView.isHidden = true
    }
    @objc func segmentedDidChange(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        if index == 0 {
            mapView.isHidden = false
            customView.isHidden = true
            customTableView.isHidden = true
            
            
        }else{
            mapView.isHidden = true
            customView.isHidden = false
            customTableView.isHidden = false
            
        }
        
    }
    @IBAction func doneActn(_ sender: Any) {
        
        mapView.isHidden = false
        customTableView.isHidden = true
        
    }
    
    @IBAction func custmAct(_ sender: Any) {
        mapView.isHidden = true
        customTableView.isHidden = false
    }
    //table
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 165
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playerLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "PlayerTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PlayerTableViewCell  else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        let playerList = playerLists[indexPath.row]
        cell.nameTextField.text = playerList.name
        // cell.photoImageView.image = player.imageURL
       
        
        let photo = playerList.imageURL
        let pURL = URL(string: photo as! String)
        cell.avatarImage.layer.cornerRadius = cell.avatarImage.bounds.height/2
        cell.avatarImage.kf.setImage(with:pURL)
        cell.ageTextField.text = playerList.age
        cell.locationTextField.text = playerList.location
        cell.positionTextField.text = playerList.position
        // Configure the cell...
        
        return cell
    }
    
    //chatting page move
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectRow = self.playerLists[indexPath.row]
        let uid = selectRow.uid as! String
        let uname = selectRow.name as! String
         if UserDefaults.standard.value(forKey: "firstname") != nil{
            let firstname = UserDefaults.standard.value(forKey: "firstname") as! String
            UserDefaults.standard.set(firstname,forKey: "firstname")
            UserDefaults.standard.set(uid, forKey: "uid")
            UserDefaults.standard.set(uname, forKey: "uname")
            UserDefaults.standard.synchronize()
        }
        let chattingView = self.storyboard?.instantiateViewController(withIdentifier: "chatPage") as! UIViewController
        self.navigationController?.pushViewController(chattingView, animated: false)
        //  print(selectRow.personid)
        customTableView.deselectRow(at: indexPath, animated: true)
    }
//button group setting
    @IBAction func profileButton(_ sender: UIButton) {
        let profileView = self.storyboard?.instantiateViewController(withIdentifier: "profilePage") as! UIViewController
        self.navigationController?.pushViewController(profileView, animated: true)
    }
    
    @IBAction func listButton(_ sender: UIButton) {
        let listView = self.storyboard?.instantiateViewController(withIdentifier: "listhostPage") as! UIViewController
        self.navigationController?.pushViewController(listView, animated: true)
    }
    
    @IBAction func regHostButton(_ sender: UIButton) {
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
