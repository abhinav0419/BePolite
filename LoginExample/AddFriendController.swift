//
//  AddFriendController.swift
//  LoginExample
//
//  Created by Abhinav on 5/30/20.
//  Copyright © 2020 Gary Tokman. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore
import Toast_Swift

class AddFriendController: UIViewController {
    @IBOutlet weak var friendUserNameAdd: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func friendAddClick(_ sender: Any) {
        
    }
    
    @IBAction func clickAddFriend(_ sender: Any) {
        let addFriendEmail = friendUserNameAdd.text!
        if addFriendEmail.isEmpty{
            let alertController = UIAlertController(title: "Email is empty.", message: "Enter email to connect with friends.", preferredStyle: .alert)
                                   let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                   alertController.addAction(OKAction)
                                   self.present(alertController, animated: true, completion: nil)
        }
        else{
            //check if email exists in firebase
            // if exists display success alert and move to home screen
            // if does not exists display alert
            Auth.auth().fetchSignInMethods(forEmail: addFriendEmail){ signInMethods, error in
                print("methods \(signInMethods as Any)")
                if((error) != nil){
                     let alertController = UIAlertController(title: "Cannot add user.", message: "Something went wrong please try again.", preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                         alertController.addAction(OKAction)
                        self.present(alertController, animated: true, completion: nil)
                }
                else if signInMethods == nil {
                    let alertController = UIAlertController(title: "Cannot add user.", message: "Email does not exist in the database. Enter correct email.", preferredStyle: .alert)
                        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(OKAction)
                        self.present(alertController, animated: true, completion: nil)
                }
                else{
                    print("Can be saved")
                    //1. display error if logged in user id is same as usid of email entered
                    let db = Firestore.firestore()
                    let userId = Auth.auth().currentUser?.uid
                    db.collection("users").whereField("usid",isEqualTo:userId ).getDocuments() { (querySnapshot, err) in
                        
                        if let err = err {
                            print("Error getting documents: \(err)")
                        }
                        else {
                            for document in querySnapshot!.documents {
                                let documentEmail = document.data()["userEmail"] as?String
                                if documentEmail != nil && documentEmail == addFriendEmail {
                                    let alertController = UIAlertController(title: "Cannot add user.", message: "You cannot add yourself as a friend.", preferredStyle: .alert)
                                    let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                    alertController.addAction(OKAction)
                                                      self.present(alertController, animated: true, completion: nil)
                                }
                                else{
                                    //2. save the entered username usid in the friend list
                                        print("Safe to be saved in friend list")
                                    let friendListLocal = db.collection("users").document(userId!)
                                    friendListLocal.updateData(["friendsList" :  FieldValue.arrayUnion([addFriendEmail])])
                                    print("Saved Friend")
                                    let alertController = UIAlertController(title: "User added to friend list", message: "Lets be polite", preferredStyle: .alert)
                                    let OKAction = UIAlertAction(title: "OK", style: .default, handler: { action in
                                        self.navigateToHome()
                                    })
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
    
    func navigateToHome(){
         let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                                         let nextViewController = storyBoard.instantiateViewController(withIdentifier: "homestory") as! HomeViewController
                                         self.present(nextViewController, animated:true, completion:nil)
    }

}
