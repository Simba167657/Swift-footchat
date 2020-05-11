//
//  ListHostViewController.swift
//  footchat
//
//  Created by Marten on 10/2/19.
//  Copyright © 2019 Marten. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import FirebaseDatabase
import GoogleMaps
import Kingfisher

class ListHostViewController: UIViewController, GMSMapViewDelegate,CLLocationManagerDelegate,UISearchBarDelegate, UITableViewDataSource,UITableViewDelegate {
  
    var playerLists = [Player]()

    private let cellIdentifier = "PlayerTableViewCell"
    
    
    
    
    private var hostListRefHandle: DatabaseHandle?
    private var playerListRefHandle: DatabaseHandle?
    //@IBOutlet weak var map_View: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var customView: UIView!
    @IBOutlet weak var customTableView: UITableView!
    var markerSelected: String?
    var markerSelected1: String?
    private var hostinfoWindow = HostListWindow()
    private var infoWindow = MapInfoWindow()
    private var ulongitude: String?
    private var curhostlongitude: String?
    var cusername = String()
    struct info {
        let distance: Double
        
    }
    
    var ticker: Array<info> = []
    fileprivate var locationMarker : GMSMarker? = GMSMarker()
    fileprivate var locationMarker1 : GMSMarker? = GMSMarker()
    @IBOutlet weak var regHostButton: UIButton!
    @IBOutlet weak var addDisableButton: UIButton!
    
    // MARK: - Activity Indicator
    fileprivate var activityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //userlogitude()
        deleteData()
        segmentControl.addTarget(self, action: #selector(ListHostViewController.segmentedDidChange(_:)), for: .valueChanged)
        config()
        activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        self.mapView.delegate = self
        // self.mapView1.delegate = self
        location_search()
        loadHostList()
        
        
    }
    func loadNiB() -> HostListWindow{
        let hostinfoWindow = HostListWindow.instanceFromNib() as! HostListWindow
        return hostinfoWindow
    }
    func loadNiB1() -> MapInfoWindow{
        let infoWindow = MapInfoWindow.instanceFromNib() as! MapInfoWindow
        return infoWindow
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.center = self.view.center
    }
    func deleteData(){
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat =  "yyyy-MM-d"
        let currentDateNow = formatter.string(from: now)
        Constants.refs.databaseHost.observe(DataEventType.value, with: {(DataSnapshot) in
            if DataSnapshot.childrenCount > 0 {
                // print(DataSnapshot.childrenCount)
                for databaserRefer in DataSnapshot.children.allObjects as! [DataSnapshot]
                {
                    let  HostObj = databaserRefer.value as? [String: AnyObject]
                    let  dateString = HostObj?["date"] as! String
                    let result = dateString.components(separatedBy: "-")
                    let hostYear = result[0]  as! String
                    let hostMonth = result[1] as! String
                    let hostDay = result[2] as! String
                    //let IntDay = hostDay
                    let IntDay: Int = Int(hostDay)!
                    //currentDate
                    let res = currentDateNow.components(separatedBy: "-")
                    let curYear = res[0]  as! String
                    let curMonth = res[1] as! String
                    let curDay = res[2] as! String
                    let IntcDay: Int = Int(curDay)!
                    if ( hostYear == curYear && hostMonth == curMonth && IntDay < IntcDay ){
                        let key = databaserRefer.key as! String
                      // print(key)
                        let query =  Constants.refs.databasePlayerMatch.queryOrdered(byChild: "hostkey").queryEqual(toValue: "\(key)")
                       
                        query.observeSingleEvent(of: .value, with: { snapshot in
                            for child in snapshot.children {
                                let childSnap = child as! DataSnapshot
                                let dict = childSnap.value as! [String: Any]
                                let  hostkey = dict["hostkey"] as! String
                               // if key == hostkey {
                                    let playkey = childSnap.key
                                    Constants.refs.databasePlayerMatch.child("\(playkey)").removeValue()
                              //  }
                            }
                        })
                        Constants.refs.databaseHost.child("\(key)").removeValue()
                    }
                    else
                    {
                        
                    }
                }
                
            }
        })
        
    }
    //logitude of users
    func userlogitude(){
        let uid = Auth.auth().currentUser?.uid as! String
        let  cquery = Constants.refs.databaseUsers.queryOrdered(byChild: "uid").queryEqual(toValue: "\(uid)")
        cquery.observeSingleEvent(of: .value, with: { snapshot in
            for child in snapshot.children {
                let cSnap = child as! DataSnapshot
                let cdict = cSnap.value as! [String: Any]
                let userlogitude = cdict["longitude"] as! String
                self.ulongitude = userlogitude
                // print(self.ulongitude)
            }
        })
    }
    // search location
    func location_search(){
        Constants.refs.databaseHost.observe(DataEventType.value, with: {(DataSnapshot) in
            if DataSnapshot.childrenCount > 0 {
                // print(DataSnapshot.childrenCount)
                for databaserRefer in DataSnapshot.children.allObjects as! [DataSnapshot]
                {
                    let  HostObj = databaserRefer.value as? [String: AnyObject]
                    let  uid = Auth.auth().currentUser?.uid
                    if uid as! String == HostObj?["uid"] as! String{
                        let  hostData = HostObj?["date"] as! String
                        let  hostStartTime = HostObj?["starttime"] as! String
                        let  hostEndTime = HostObj?["endtime"] as! String
                        let  hostType = HostObj?["type"] as! String
                        let  hostlatitude = HostObj?["latitude"] as! String
                        let  hostlongitude = HostObj?["longitude"] as! String
                        let  hostName = HostObj?["host"] as!  String
                        let  hostLocation = HostObj?["location"] as! String
                        // let  hostUid = HostObj?["uid"] as! String
                        let cudate = hostData as! String
                        let hostKey = databaserRefer.key
                        self.curhostlongitude = hostlongitude
                        let camera = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(Float(hostlatitude)!), longitude: CLLocationDegrees(Float(hostlongitude)!), zoom: 9.0)
                        self.mapView.camera = camera
                        let curdate = hostData as! String
                        var parkingIcon: String
                        //Distance
             
                        parkingIcon = "football_icon"
                        let marker = GMSMarker()
                        marker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(Float(hostlatitude)!), longitude: CLLocationDegrees(Float(hostlongitude)!))
                        let userdatas = hostKey + "#" + hostData + "#" + hostStartTime + "#" + hostEndTime + "#" + hostType + "#" + hostName + "#" + hostLocation
                        //  marker.title =  hostLocation
                        marker.icon = UIImage(named: parkingIcon)
                        marker.userData = userdatas // index
                        marker.map = self.mapView
                        //  print(marker.userData)
                        // player list
                        Constants.refs.databasePlayerMatch.observe(DataEventType.value, with: {(DataSnapshot) in
                            if DataSnapshot.childrenCount > 0 {
                                // print(DataSnapshot.childrenCount)
                                for databaserRefer in DataSnapshot.children.allObjects as! [DataSnapshot]
                                {
                                    let  matchObj = databaserRefer.value as? [String: AnyObject]
                                    
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
                                                let camera = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(Float(playerlatitude)!), longitude: CLLocationDegrees(Float(playerlongitude)!), zoom: 9.0)
                                                self.mapView.camera = camera
                                                let url = URL(string: image_url as! String)
                                                let data = try? Data(contentsOf: url! as URL)
                                                let currentname = self.cusername
                                           
                                                let userdatas = uid + "#" + name + "#" + age + "#" + position + "#" + playerLocation 
                                                let marker = GMSMarker()
                                                marker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(Float(playerlatitude)!), longitude: CLLocationDegrees(Float(playerlongitude)!))
                                                marker.icon = self.drawImageWithProfilePic(pp: UIImage.init(data: data!)!, image: UIImage.init(named: "location_person")!)
                                                marker.appearAnimation = GMSMarkerAnimation.pop
                                                marker.userData = userdatas // index
                                                //  self.infoWindow = self.loadNiB()
                                                marker.map = self.mapView
                                            }
                                        })
                                    }
                                }
                                
                            }
                        })
                        //  print(hostKey)
                    }
                }
                
            }
            
        })
        
    }
    //avatar image setting
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
    func sizeForOffset(view: UIView) -> CGFloat {
        return  35.0
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        self.markerSelected = marker.userData as? String
        let userData = self.markerSelected
        let result = userData?.components(separatedBy: "#")
        if(result?.count == 7){
            let hostKey = result?[0] as? String
            let hostDate = result?[1] as! String
            let hostStartTime = result?[2] as! String
            let hostEndTime = result?[3] as! String
            let hostType = result?[4] as? String
            let hostName = result?[5] as? String
            let hostLocation = result?[6] as? String
            
            let userid = Auth.auth().currentUser?.uid as! String
            UserDefaults.standard.set(hostKey, forKey: "hostKey")
            UserDefaults.standard.synchronize()
            locationMarker = marker
            guard let location = locationMarker?.position else {
                print("locationMarker is Nil")
                return false
            }
            hostinfoWindow.removeFromSuperview()
            infoWindow.removeFromSuperview()
            hostinfoWindow = loadNiB()
            hostinfoWindow.center = mapView.projection.point(for: location)
            hostinfoWindow.center.y =  hostinfoWindow.center.y - sizeForOffset(view: hostinfoWindow)
            // hostinfo
            let result = hostDate.components(separatedBy: "-")
            let hostYear = result[0]  as! String
            let hostMonth = result[1] as! String
            let hostDay = result[2] as! String
            let days:Int = Int(hostDay)!
            if days < 10 {
                let hdays = "0" + hostDay
                let hdate = hdays + "-" +  hostMonth + "-" + hostYear
                hostinfoWindow.dateLabel.text =  hdate
            }
            else {
                let hdate = hostDay + "-" +  hostMonth + "-" + hostYear
                hostinfoWindow.dateLabel.text =  hdate
            }
            hostinfoWindow.hostnameLabel.text = hostName
         //   hostinfoWindow.dateLabel.text = dateObj as! String
            hostinfoWindow.timeLabel.text = hostStartTime + "~" + hostEndTime
            hostinfoWindow.locationLabel.text = hostLocation
            hostinfoWindow.typeLabel.text = hostType
            self.view.addSubview(hostinfoWindow)
            //infoWindow.removeFromSuperview()
        }
        else {
            
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
           // infoWindow.removeFromSuperview()
            hostinfoWindow.removeFromSuperview()
            infoWindow = loadNiB1()
            infoWindow.center = mapView.projection.point(for: location)
            infoWindow.center.y = infoWindow.center.y - sizeForOffset(view: infoWindow)
            // userinfo
            infoWindow.nameLabel.text = firstname
            infoWindow.ageLabel.text = age
            infoWindow.locationLabel.text = playerLocation
            infoWindow.positionLabel.text = position
            infoWindow.chatButton.addTarget(self, action: #selector(ListHostViewController.chataction(sender:)), for: .touchUpInside)
            
            self.view.addSubview(infoWindow)
            //hostinfoWindow.removeFromSuperview()
        }
        
        return false
        
        
    }
    @objc func chataction(sender: UIButton) {
        let chatView = self.storyboard?.instantiateViewController(withIdentifier: "chatPage") as! UIViewController
        self.navigationController?.pushViewController(chatView, animated: true)
    }
   
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        hostinfoWindow.removeFromSuperview()
        infoWindow.removeFromSuperview()
        
    }
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if (locationMarker != nil){
            guard let location = locationMarker?.position else {
                print("locationMarker is nil")
                return
            }
            hostinfoWindow.center = mapView.projection.point(for: location)
            hostinfoWindow.center.y = hostinfoWindow.center.y - sizeForOffset(view: hostinfoWindow)
            
            infoWindow.center = mapView.projection.point(for: location)
            infoWindow.center.y = infoWindow.center.y - sizeForOffset(view: infoWindow)
        }
    }
    
    // MARK: Needed to create the custom info window
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return UIView()
    }
    //create Alert
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    func config(){
        mapView.isHidden = false
        customView.isHidden = true
        customTableView.isHidden = true
        if UserDefaults.standard.value(forKey: "hoststate") != nil{
            let hoststate = UserDefaults.standard.value(forKey: "hoststate") as! String
            if(hoststate == "on"){
                addDisableButton.isHidden = true
            }
        }
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
            hostinfoWindow.removeFromSuperview()
            infoWindow.removeFromSuperview()
            
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
    private func loadHostList(){
        
        Constants.refs.databaseHost.observe(DataEventType.value, with: {(DataSnapshot) in
            if DataSnapshot.childrenCount > 0 {
                // print(DataSnapshot.childrenCount)
                for databaserRefer in DataSnapshot.children.allObjects as! [DataSnapshot]
                {
                    let  uid = Auth.auth().currentUser?.uid
                    
                    let  HostObj = databaserRefer.value as? [String: AnyObject]
                    if uid as! String == HostObj?["uid"] as! String{
                        let  hostData = HostObj?["date"] as! String
                        let  hostStartTime = HostObj?["starttime"] as! String
                        let  hostEndTime = HostObj?["endtime"] as! String
                        let  hostType = HostObj?["type"] as! String
                        let  hostlatitude = HostObj?["latitude"] as! String
                        let  hostlongitude = HostObj?["longitude"] as! String
                        let  hostName = HostObj?["host"] as! String
                        let  hostLocation = HostObj?["location"] as! String
                        let  hostUid = HostObj?["uid"] as! String
                        let  hostKey = databaserRefer.key
                     
                        Constants.refs.databasePlayerMatch.observe(DataEventType.value, with: {(DataSnapshot) in
                            if DataSnapshot.childrenCount > 0 {
                                // print(DataSnapshot.childrenCount)
                                for databaserRefer in DataSnapshot.children.allObjects as! [DataSnapshot]
                                {
                                    let  matchObj = databaserRefer.value as? [String: AnyObject]
                                    
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
                                                let url = URL(string: image_url as! String)
                                                let data = try? Data(contentsOf: url! as URL)
                                                let hostLongitude = self.curhostlongitude as! String
                                         
                                                print(name)
                                                self.playerLists.append(Player(
                                                    name:name,
                                                    uid: uid,
                                                    imageURL: image_url,
                                                    age:age,
                                                    location:playerLocation,
                                                    position: position
                                                ))
                                                self.customTableView.reloadData()
                                            }
                                        })
                                    }
                                }
                                
                            }
                        })
                        
                    }
                    
                    
                }
                
            }
            
        })
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135
    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        let pcnt = playerLists.count
 
        return pcnt
        //return sectionIsExpanded[section] ? (1+pcnt) : 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PlayerTableViewCell
            
            let playerList = playerLists[indexPath.row]
            let photo = playerList.imageURL
            let pURL = URL(string: photo as! String)
            let uid = playerList.uid
            //config
            cell.nameTextField.isEnabled = false
            cell.ageTextField.isEnabled = false
            cell.locationTextField.isEnabled = false
            cell.positionTextField.isEnabled = false
            //
            cell.nameTextField.text = playerList.name
            cell.avatarImage.layer.cornerRadius = cell.avatarImage.bounds.height/2
            cell.avatarImage.kf.setImage(with:pURL)
            cell.ageTextField.text = playerList.age
            cell.locationTextField.text = playerList.location
            cell.positionTextField.text = playerList.position
            //  cell.distanceTextField.text = String(format: "%.2f", distanceDoule)
            
            //  cell.playerChatButton.addTarget(self, action: #selector(ListHostViewController.chataction(sender:)), for: .touchUpInside)
            
            return cell
     
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
            let selectRow = self.playerLists[indexPath.row]
            let hostUid = selectRow.uid as! String
            UserDefaults.standard.set(hostUid, forKey: "uid")        
            UserDefaults.standard.synchronize()
        let chattingView = self.storyboard?.instantiateViewController(withIdentifier: "chatPage") as! UIViewController
        self.navigationController?.pushViewController(chattingView, animated: false)
            customTableView.deselectRow(at: indexPath, animated: true)
       
    }
    //button group events
    
    @IBAction func regHostButton(_ sender: UIButton) {
        let regHostView = self.storyboard?.instantiateViewController(withIdentifier: "reghostPage") as! UIViewController
        self.navigationController?.pushViewController(regHostView, animated: true)
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
