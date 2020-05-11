//
//  PlayerViewController.swift
//  footchat
//
//  Created by Marten on 10/23/19.
//  Copyright © 2019 Marten. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import GoogleMaps

class PlayerViewController: UIViewController, GMSMapViewDelegate,CLLocationManagerDelegate,UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate{
    var hostLists = [PlayerHostList]()
    private var hostListRefHandle: DatabaseHandle?
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var customView: UIView!
    @IBOutlet weak var customtableView: UITableView!
    @IBOutlet weak var mapView: GMSMapView!
    
    var markerSelected: String?
    var markerSelected1: String?
    private var hostinfoWindow = HostInfoWindow()
    private var ulongitude: String?
    private var curhostlongitude: String?
    var cusername = String()
    struct info {
        let distance: Double
        
    }
    var ticker: Array<info> = []
    fileprivate var locationMarker : GMSMarker? = GMSMarker()
    fileprivate var locationMarker1 : GMSMarker? = GMSMarker()
    // MARK: - Activity Indicator
    fileprivate var activityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        userlogitude()
        segmentControl.addTarget(self, action: #selector(PlayerViewController.segmentedDidChange(_:)), for: .valueChanged)
        config()
        activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        self.mapView.delegate = self
        // self.mapView1.delegate = self
        location_search()
        loadHostList()
       
        // Do any additional setup after loading the view.
    }
    func loadNiB() -> HostInfoWindow{
        let hostinfoWindow = HostInfoWindow.instanceFromNib() as! HostInfoWindow
        return hostinfoWindow
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.center = self.view.center
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
                let uid = Auth.auth().currentUser?.uid as! String
                let query =  Constants.refs.databasePlayerMatch.queryOrdered(byChild: "uid").queryEqual(toValue: "\(uid)")
                query.observeSingleEvent(of: .value, with: { snapshot in
                    if snapshot.childrenCount > 0 {
                        for child in snapshot.children {
                            let childSnap = child as! DataSnapshot
                            let dict = childSnap.value as! [String: Any]
                            let  hostKey = dict["hostkey"] as! String
                            Constants.refs.databaseHost.child(hostKey).observeSingleEvent(of: .value, with: { (snapshot) in
                                // Get user value
                                
                                let HostObj = snapshot.value as? NSDictionary
                                let  hostData = HostObj?["date"] as! String
                                let  hostStartTime = HostObj?["starttime"] as! String
                                let  hostEndTime = HostObj?["endtime"] as! String
                                let  hostType = HostObj?["type"] as! String
                                let  hostlatitude = HostObj?["latitude"] as! String
                                let  hostlongitude = HostObj?["longitude"] as! String
                                let  hostName = HostObj?["host"] as! String
                                let  hostLocation = HostObj?["location"] as! String
                                let  hostuid = HostObj?["uid"] as! String
                                // let  hostUid = HostObj?["uid"] as! String
                                let camera = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(Float(hostlatitude)!), longitude: CLLocationDegrees(Float(hostlongitude)!), zoom: 9.0)
                                self.mapView.camera = camera
                              
                                let playerMatch = "on" as! String
                                let userdatas = hostKey + "#" + hostData + "#" + hostStartTime + "#" + hostEndTime + "#" + hostType + "#" + hostName + "#" + hostLocation + "#" + playerMatch + "#" + hostuid
                                var parkingIcon: String
                                parkingIcon = "football_icon"
                                //parkingIcon = "football_green_icon"
                                // Creates a marker in the center of the map
                                let marker = GMSMarker()
                                marker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(Float(hostlatitude)!), longitude: CLLocationDegrees(Float(hostlongitude)!))
                                //  marker.title =  hostLocation
                                marker.icon = UIImage(named: parkingIcon)
                                marker.userData = userdatas // index
                                marker.map = self.mapView
                                // ...
                            }) { (error) in
                                
                            }
                        }
                        let query =  Constants.refs.databaseUsers.queryOrdered(byChild: "uid").queryEqual(toValue: "\(uid)")
                        query.observeSingleEvent(of: .value, with: { snapshot in
                            if snapshot.childrenCount > 0 {
                                for childs in snapshot.children {
                                    let childSnaps = childs as! DataSnapshot
                                    let player = childSnaps.value as! [String: Any]
                                    let  playername = player["firstname"] as! String
                                    let  playerLocation = player["location"] as! String
                                    let  playerlatitude = player["latitude"] as! String
                                    let playerlongitude = player["longitude"] as! String
                                    let  image_url = player["avatar_url"]
                                    let url = URL(string: image_url as! String)
                                    let data = try? Data(contentsOf: url! as URL)
                                    let camera = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(Float(playerlatitude)!), longitude: CLLocationDegrees(Float(playerlongitude)!), zoom: 9.0)
                                    self.mapView.camera = camera
                                    let marker = GMSMarker()
                                    marker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(Float(playerlatitude)!), longitude: CLLocationDegrees(Float(playerlongitude)!))
                                    marker.icon = self.drawImageWithProfilePic(pp: UIImage.init(data: data!)!, image: UIImage.init(named: "location_person_orange")!)
                                    marker.appearAnimation = GMSMarkerAnimation.pop
                                   // marker.userData = userdatas // index
                                    //  self.infoWindow = self.loadNiB()
                                    marker.map = self.mapView
                                }
                            }
                        })
                        
                        
                    }
                    else {
                        Constants.refs.databaseHost.observe(DataEventType.value, with: {(DataSnapshot) in
                            if DataSnapshot.childrenCount > 0 {
                                // print(DataSnapshot.childrenCount)
                                for databaserRefer in DataSnapshot.children.allObjects as! [DataSnapshot]
                                {
                                    let  HostObj = databaserRefer.value as? [String: AnyObject]
                                    let  hostData = HostObj?["date"] as! String
                                    let  hostStartTime = HostObj?["starttime"] as! String
                                    let  hostEndTime = HostObj?["endtime"] as! String
                                    let  hostType = HostObj?["type"] as! String
                                    let  hostlatitude = HostObj?["latitude"] as! String
                                    let  hostlongitude = HostObj?["longitude"] as! String
                                    let  hostName = HostObj?["host"] as! String
                                    let  hostLocation = HostObj?["location"] as! String
                                    let  playerMatch = "off" as! String
                                    let  hostuid = HostObj?["uid"] as! String
                                    // let  hostUid = HostObj?["uid"] as! String
                                    let hostKey = databaserRefer.key
                                    let camera = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(Float(hostlatitude)!), longitude: CLLocationDegrees(Float(hostlongitude)!), zoom: 9.0)
                                    self.mapView.camera = camera
                                  
                                    let userdatas = hostKey + "#" + hostData + "#" + hostStartTime + "#" + hostEndTime + "#" + hostType + "#" + hostName + "#" + hostLocation +  "#" + playerMatch + "#" + hostuid
                                    var parkingIcon: String
                                    parkingIcon = "football_icon"
                                    let marker = GMSMarker()
                                    marker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(Float(hostlatitude)!), longitude: CLLocationDegrees(Float(hostlongitude)!))
                                    //  marker.title =  hostLocation
                                    marker.icon = UIImage(named: parkingIcon)
                                    marker.userData = userdatas // index
                                    marker.map = self.mapView
                                    //  print(marker.userData)
                                    
                                }
                            }
                        })
                        let query =  Constants.refs.databaseUsers.queryOrdered(byChild: "uid").queryEqual(toValue: "\(uid)")
                        query.observeSingleEvent(of: .value, with: { snapshot in
                            if snapshot.childrenCount > 0 {
                                for childs in snapshot.children {
                                    let childSnaps = childs as! DataSnapshot
                                    let player = childSnaps.value as! [String: Any]
                                    let  playername = player["firstname"] as! String
                                    let  playerLocation = player["location"] as! String
                                    let  playerlatitude = player["latitude"] as! String
                                    let playerlongitude = player["longitude"] as! String
                                    let  image_url = player["avatar_url"]
                                    let url = URL(string: image_url as! String)
                                    let data = try? Data(contentsOf: url! as URL)
                                    let camera = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(Float(playerlatitude)!), longitude: CLLocationDegrees(Float(playerlongitude)!), zoom: 9.0)
                                    self.mapView.camera = camera
                                    let marker = GMSMarker()
                                    marker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(Float(playerlatitude)!), longitude: CLLocationDegrees(Float(playerlongitude)!))
                                    marker.icon = self.drawImageWithProfilePic(pp: UIImage.init(data: data!)!, image: UIImage.init(named: "location_person_orange")!)
                                    marker.appearAnimation = GMSMarkerAnimation.pop
                                    // marker.userData = userdatas // index
                                    //  self.infoWindow = self.loadNiB()
                                    marker.map = self.mapView
                                }
                            }
                        })
                        
                    }
                })
        
      
        
    }
    
    
    //avatar image setting
    func drawImageWithProfilePic(pp: UIImage, image: UIImage) -> UIImage {
        let imgView = UIImageView(image: image)
        imgView.frame = CGRect(x: 0, y: 0, width: 50, height: 80)
        let picImgView = UIImageView(image: pp)
        picImgView.frame = CGRect(x: 0, y: 0, width: 38, height: 38)
        imgView.addSubview(picImgView)
        picImgView.center.x = imgView.center.x
        picImgView.center.y = imgView.center.y - 15
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
        if userData != nil {
                let result = userData?.components(separatedBy: "#")
                let hostKey = result?[0] as? String
                let hostDate = result?[1] as! String
                let hostStartTime = result?[2] as! String
                let hostEndTime = result?[3] as! String
                let hostType = result?[4] as? String
                let hostName = result?[5] as? String
                let hostLocation = result?[6] as? String
                let playermatch = result?[7] as! String
                let hostuid = result?[8] as! String
        
                
                let userid = Auth.auth().currentUser?.uid as! String
                UserDefaults.standard.set(hostKey, forKey: "hostKey")
                UserDefaults.standard.set(hostuid, forKey: "hostuid")
                UserDefaults.standard.synchronize()
                locationMarker = marker
                guard let location = locationMarker?.position else {
                    print("locationMarker is Nil")
                    return false
                }
        if playermatch == "on" {
                hostinfoWindow.removeFromSuperview()
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
              //  hostinfoWindow.dateLabel.text = hostDate
                hostinfoWindow.timeLabel.text = hostStartTime + "~" + hostEndTime
                hostinfoWindow.locationLabel.text = hostLocation
                hostinfoWindow.typeLabel.text = hostType
                hostinfoWindow.checkButton.isHidden = true
                hostinfoWindow.chatButton.addTarget(self, action: #selector(PlayerViewController.chataction(sender:)), for: .touchUpInside)
                self.view.addSubview(hostinfoWindow)
        }
        else
        {
                hostinfoWindow.removeFromSuperview()
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
                //hostinfoWindow.dateLabel.text = hostDate
                hostinfoWindow.timeLabel.text = hostStartTime + "~" + hostEndTime
                hostinfoWindow.locationLabel.text = hostLocation
                hostinfoWindow.typeLabel.text = hostType
            
                hostinfoWindow.chatButton.isHidden = true
                hostinfoWindow.checkButton.addTarget(self, action: #selector(PlayerViewController.checkaction(sender:)), for: .touchUpInside)
                self.view.addSubview(hostinfoWindow)
        }
        }
        else {
            hostinfoWindow.removeFromSuperview()
        }
        return false
        
        
    }
    @objc func chataction(sender: UIButton) {
        let userid = Auth.auth().currentUser?.uid as! String
        let hostKey = UserDefaults.standard.value(forKey: "hostKey")
        let hostuid = UserDefaults.standard.value(forKey: "hostuid")
        let querys =  Constants.refs.databaseUsers.queryOrdered(byChild: "uid").queryEqual(toValue: "\(userid)")
        querys.observeSingleEvent(of: .value, with: { snapshot in
         
                for child in snapshot.children {
                    let childSnap = child as! DataSnapshot
                    let cdict = childSnap.value as! [String: Any]
                    let cusername = cdict["firstname"] as! String
                    UserDefaults.standard.set(cusername, forKey: "currentname")
                    UserDefaults.standard.set(hostuid, forKey: "uid")
                    UserDefaults.standard.synchronize()
                   let chatView = self.storyboard?.instantiateViewController(withIdentifier: "chatPage") as! UIViewController
                   self.navigationController?.pushViewController(chatView, animated: true)
                }
         
           
        })
     
    }
    @objc func checkaction(sender: UIButton) {
        let userid = Auth.auth().currentUser?.uid as! String
                let hostKey = UserDefaults.standard.value(forKey: "hostKey")
                let querys =  Constants.refs.databasePlayerMatch.queryOrdered(byChild: "uid").queryEqual(toValue: "\(userid)")
                querys.observeSingleEvent(of: .value, with: { snapshot in
                    if(snapshot.childrenCount > 0) {
                        UserDefaults.standard.set(hostKey, forKey: "hostKey")
                        UserDefaults.standard.set(userid, forKey: "userid")
                        UserDefaults.standard.synchronize()
                    }
                    else {
                        let post_data = [
                            "uid":userid,
                            "hostkey":hostKey,
                            ] as [String : Any]
                        
                        let key = Constants.refs.databaseRoot.childByAutoId().key! as String
                        Constants.refs.databasePlayerMatch.child("\(key)").setValue(post_data, withCompletionBlock: {err, ref in
                            
                            if err != nil {
                                self.createAlert(title: "Warning!", message: "Network error.")
                            } else
                            {
                                self.createAlert(title: "", message: "Successfully selected Game!")
                                
                            }
                        })
                    }
                })
        
    
        
    }
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        hostinfoWindow.removeFromSuperview()
    }
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if (locationMarker != nil){
            guard let location = locationMarker?.position else {
                print("locationMarker is nil")
                return
            }
            hostinfoWindow.center = mapView.projection.point(for: location)
            hostinfoWindow.center.y = hostinfoWindow.center.y - sizeForOffset(view: hostinfoWindow)
          
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
        customtableView.isHidden = true
        
    }
    @objc func segmentedDidChange(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        if index == 0 {
            mapView.isHidden = false
            customView.isHidden = true
            customtableView.isHidden = true
            
        }else{
            mapView.isHidden = true
            customView.isHidden = false
            customtableView.isHidden = false
            hostinfoWindow.removeFromSuperview()
            
        }
        
    }
    @IBAction func doneActn(_ sender: Any) {
        mapView.isHidden = false
        customtableView.isHidden = true
        
    }
    
    @IBAction func custmAct(_ sender: Any) {
        mapView.isHidden = true
        customtableView.isHidden = false
    }
    //table
    private func loadHostList(){
                let uid = Auth.auth().currentUser?.uid as! String
                let query =  Constants.refs.databasePlayerMatch.queryOrdered(byChild: "uid").queryEqual(toValue: "\(uid)")
                query.observeSingleEvent(of: .value, with: { snapshot in
                    if snapshot.childrenCount > 0 {
                        for child in snapshot.children {
                            let childSnap = child as! DataSnapshot
                            let dict = childSnap.value as! [String: Any]
                            let  hostKey = dict["hostkey"] as! String
                            Constants.refs.databaseHost.child(hostKey).observeSingleEvent(of: .value, with: { (snapshot) in
                                // Get user value
                                let HostObj = snapshot.value as? NSDictionary
                                let  hostData = HostObj?["date"] as! String
                                let  hostStartTime = HostObj?["starttime"] as! String
                                let  hostEndTime = HostObj?["endtime"] as! String
                                let  hostType = HostObj?["type"] as! String
                                let  hostlatitude = HostObj?["latitude"] as! String
                                let  hostlongitude = HostObj?["longitude"] as! String
                                let  hostName = HostObj?["host"] as! String
                                let  hostLocation = HostObj?["location"] as! String
                                let  hostUid = HostObj?["uid"] as! String
                                let userKey = snapshot.key as! String
                                self.hostLists.append(PlayerHostList(
                                    date:hostData,
                                    startTime:hostStartTime,
                                    endTime: hostEndTime,
                                    type: hostType,
                                    location: hostLocation,
                                    host: hostName,
                                    uid: hostUid,
                                    hostkey: userKey
                                   
                                ))
                                self.customtableView.reloadData()
                            }) { (error) in
                                
                            }
                        }
                    }
                    else {
                        Constants.refs.databaseHost.observe(DataEventType.value, with: {(DataSnapshot) in
                            if DataSnapshot.childrenCount > 0 {
                                // print(DataSnapshot.childrenCount)
                                for databaserRefer in DataSnapshot.children.allObjects as! [DataSnapshot]
                                {
                                    let  HostObj = databaserRefer.value as? [String: AnyObject]
                                    let  hostData = HostObj?["date"] as! String
                                    let  hostStartTime = HostObj?["starttime"] as! String
                                    let  hostEndTime = HostObj?["endtime"] as! String
                                    let  hostType = HostObj?["type"] as! String
                                    let  hostlatitude = HostObj?["latitude"] as! String
                                    let  hostlongitude = HostObj?["longitude"] as! String
                                    let  hostName = HostObj?["host"] as! String
                                    let  hostLocation = HostObj?["location"] as! String
                                    let  hostUid = HostObj?["uid"] as! String
                                    let hostKey = databaserRefer.key
                                    // strdistance.sorted()
                                    self.hostLists.append(PlayerHostList(
                                        date:hostData,
                                        startTime:hostStartTime,
                                        endTime: hostEndTime,
                                        type: hostType,
                                        location: hostLocation,
                                        host: hostName,
                                        uid: hostUid,
                                        hostkey: hostKey
                                     
                                    ))
                                    self.customtableView.reloadData()
                                    
                                }
                            }
                        })
                    }
                })
        
       
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hostLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "HostListTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? HostListTableViewCell  else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        let hostList = hostLists[indexPath.row]
        let result = hostList.date.components(separatedBy: "-")
        let hostYear = result[0]  as! String
        let hostMonth = result[1] as! String
        let hostDay = result[2] as! String
        let days:Int = Int(hostDay)!
      
        if days < 10  {
            let hdays = "0" + hostDay
            let hdate = hdays + "-" +  hostMonth + "-" + hostYear
             cell.dateTextField.text =  hdate
        }
        else {
            let hdate = hostDay + "-" +  hostMonth + "-" + hostYear
             cell.dateTextField.text =  hdate
        }
        // let distanceDoule:Double = Double(distance)!
       // cell.dateTextField.text = hostList.date
        cell.startTimeTextField.text = hostList.startTime
        cell.endTimeTextField.text = hostList.endTime
        cell.typeTextField.text = hostList.type
        cell.locationTextField.text = hostList.location
        cell.hostTextField.text = hostList.host      
        // Configure the cell...
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectRow = self.hostLists[indexPath.row]
        let hostkey = selectRow.hostkey as! String
        let hostUid = selectRow.uid as! String
        
                let userid = Auth.auth().currentUser?.uid as! String
                let querys =  Constants.refs.databasePlayerMatch.queryOrdered(byChild: "uid").queryEqual(toValue: "\(userid)")
                querys.observeSingleEvent(of: .value, with: { snapshot in
                    if(snapshot.childrenCount > 0) {
                        let userid = Auth.auth().currentUser?.uid as! String
                        let query =  Constants.refs.databaseUsers.queryOrdered(byChild: "uid").queryEqual(toValue: "\(userid)")
                            query.observeSingleEvent(of: .value, with: { snapshot in
                                for child in snapshot.children {
                                    let childSnap = child as! DataSnapshot
                                    let cdict = childSnap.value as! [String: Any]
                                    let cusername = cdict["firstname"] as! String
                                    UserDefaults.standard.set(cusername, forKey: "currentname")
                                    UserDefaults.standard.set(hostUid, forKey: "uid")
                                    UserDefaults.standard.synchronize()
                                    let chatView = self.storyboard?.instantiateViewController(withIdentifier: "chatPage") as! UIViewController
                                    self.navigationController?.pushViewController(chatView, animated: true)
                            }
                        })
                    }
                    else {
                        print(hostkey)
                        Constants.refs.databaseHost.child(hostkey).observeSingleEvent(of: .value, with: { (snapshot) in
                            if(snapshot.childrenCount > 0) {
                                let post_data = [
                                    "uid":userid,
                                    "hostkey":hostkey,
                                    ] as [String : Any]
                                let key = Constants.refs.databaseRoot.childByAutoId().key! as String
                                Constants.refs.databasePlayerMatch.child("\(key)").setValue(post_data, withCompletionBlock: {err, ref in
                                    
                                    if err != nil {
                                        self.createAlert(title: "Warning!", message: "Network error.")
                                    } else {
                                        self.createAlert(title: "", message: "Successfully selected Game!")
                                        
                                    }
                                })
                            }
                        })
                    }
                })
        
        customtableView.deselectRow(at: indexPath, animated: true)
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
        let playerView = self.storyboard?.instantiateViewController(withIdentifier: "listplayerPage") as! UIViewController
        self.navigationController?.pushViewController(playerView, animated: true)
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
