//
//  HomeViewController.swift
//  LoginExample
//
//  Created by Abhinav on 5/26/20.
//  Copyright © 2020 Gary Tokman. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import Alamofire
import AVFoundation
class HomeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
 
    var friendsArray = ["Be Polite"]
    @IBOutlet weak var homeLabel: UILabel!
    @IBOutlet weak var signOutUser: UIButton!
    @IBAction func signOutUser(_ sender: Any) {
        do{
              try Auth.auth().signOut()
              let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
              let nextViewController = storyBoard.instantiateViewController(withIdentifier: "loginStory") as! ViewController
              self.present(nextViewController, animated:true, completion:nil)
          }catch let err{
              print(err)
          }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let db = Firestore.firestore()
        let userId = Auth.auth().currentUser?.uid
        // Display welcome message
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                print("starting name display")
                for document in querySnapshot!.documents {
                    let documentUserId = document.get("usid") as?String
                    if documentUserId != nil && documentUserId == userId {
                        let displayName = document.data()["displayName"] ?? ""
                        self.homeLabel.text = "Welcome \(displayName)"
                    }
                }
            }
        }
        //Display Names of friends
        myFriendsTable.dataSource = self
        myFriendsTable.delegate = self
        //Assign friends name as an array
        db.collection("users").whereField("usid",isEqualTo:userId ).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            }
            else {
                self.friendsArray = []
                for document in querySnapshot!.documents {
                    let friendEmail = document.data()["friendsList"] as! [Any]
                    print(friendEmail)
                    for s in friendEmail{
                        self.friendsArray.append(s as! String)
                    }
                }
                self.myFriendsTable.reloadData()
            }
        }
      
    }
    @IBOutlet weak var myFriendsTable: UITableView!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCellId", for: indexPath)
        cell.backgroundColor = UIColor.clear
        cell.textLabel!.text = friendsArray[indexPath.row]
        cell.textLabel!.textAlignment = .center
        cell.textLabel!.textColor = UIColor.blue
        cell.textLabel!.font = UIFont(name: "Helvetica", size: 18)
        cell.layer.cornerRadius = cell.frame.height/2
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let db = Firestore.firestore()
        // Send Message to the clicked user
           db.collection("userTokenMapping").whereField("userEmail",isEqualTo:friendsArray[indexPath.row] ).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            }
            else{
                for document in querySnapshot!.documents {
                    var userSendToToken = document.data()["userToken"] ?? ""
                    var userFromToken = String()
                    var msg = String()
                    var serverKey =
                    "AAAAhvPj3O8:APA91bFNUPUullONuJDPbUz2bGFxk4umBvyjEJSL8G0j0R6NippgOC2F4caGi9hBNgQknPFLl5Z-LZyUqMgNvvJrSRUU6V97XxqrWvo5Pp0DkbrNCK7RPGT3E1YQXZ4hj1I4REx8C7Ip"
                    var notificationUrl = "https://fcm.googleapis.com/fcm/send"
                    //get current user token
                    InstanceID.instanceID().instanceID { (result, error) in
                      if let error = error {
                        print("Error fetching remote instance ID: \(error)")
                      } else if let result = result {
                        userFromToken = result.token
                      }
                    }
                    db.collection("level1Message").getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("error in reading polite message")
                        }
                        else{
                            let number = Int.random(in: 1 ..< 6)
                            for document in querySnapshot!.documents {
                                if querySnapshot!.documents.count != 1{
                                    msg = document.data()["message1"] as! String
                                    print("first message is\(msg)")
                                    //create send message request
                                    let title = "\(self.friendsArray[indexPath.row])"
                                    let body = "Be Polite - \(msg)"
                                    print("body is \(body)")
                                    var headers:HTTPHeaders = HTTPHeaders()
                                    
                                    headers = ["Content-Type":"application/json","Authorization":"key=\(serverKey)"]
                                    print("Send to toekn id is\(userSendToToken)")
                                    let notification = ["to":"\(userSendToToken)","notification":["body" : body,"title" : title,"content_available" : true,"priority" : "high","sound":"default"]] as [String:Any]
                                    Alamofire.request(notificationUrl as URLConvertible,method: .post as HTTPMethod,parameters:notification,encoding:JSONEncoding.default,headers:headers).responseJSON{(response) in
                                        print("message sent response is \(response)")
                                    }
                                    //read the message sent
                                    /*var speechSynthesizer = AVSpeechSynthesizer()
                                    var speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string: "Be Polite \(msg)")
                                    speechUtterance.rate = AVSpeechUtteranceMaximumSpeechRate / 2.0
                                    speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                                    speechSynthesizer.speak(speechUtterance) */

                                    //alert to display user what message was sent
                                    let alertController = UIAlertController(title: "Polite message sent to \(self.friendsArray[indexPath.row])", message: "\(body)", preferredStyle: .alert)
                                                           let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                                           alertController.addAction(OKAction)
                                                           self.present(alertController, animated: true, completion: nil)
                                }
                                else {
                                    print(number)
                                    msg = document.data()["message\(number)"] as! String
                                    print("random message is\(msg)")
                                    //create send message request
                                    let title = "\(self.friendsArray[indexPath.row])"
                                    let body = "Be Polite - \(msg)"
                                    print("body is \(body)")
                                    var headers:HTTPHeaders = HTTPHeaders()
                                    
                                    headers = ["Content-Type":"application/json","Authorization":"key=\(serverKey)"]
                                    print("Send to toekn id is\(userSendToToken)")
                                    let notification = ["to":"\(userSendToToken)","notification":["body" : body,"title" : title,"content_available" : true,"priority" : "high","sound":"default"]] as [String:Any]
                                    Alamofire.request(notificationUrl as URLConvertible,method: .post as HTTPMethod,parameters:notification,encoding:JSONEncoding.default,headers:headers).responseJSON{(response) in
                                        print("message sent response is \(response)")
                                    }
                                    //read the message sent
                                   /* var speechSynthesizer = AVSpeechSynthesizer()
                                    var speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string: "Be Polite \(msg)")
                                    speechUtterance.rate = AVSpeechUtteranceMaximumSpeechRate / 2.0
                                    speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                                    speechSynthesizer.speak(speechUtterance) */
                                    //alert to display user what message was sent
                                                                      let alertController = UIAlertController(title: "Polite message sent to \(self.friendsArray[indexPath.row])", message: "\(body)", preferredStyle: .alert)
                                                                                             let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                                                                             alertController.addAction(OKAction)
                                                                                             self.present(alertController, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, -500, 10, 0)
        cell.layer.transform = rotationTransform
        UIView.animate(withDuration:1.0){
            cell.layer.transform = CATransform3DIdentity
        }
    }
}
