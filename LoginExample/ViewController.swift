//
//  ViewController.swift
//  LoginExample
//
//  Created by Gary Tokman on 3/10/19.
//  Copyright © 2019 Gary Tokman. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore
import AVFoundation
class ViewController: UIViewController {

    @IBOutlet weak var displayName: UITextField!
    @IBOutlet weak var signUpDisplayName: UIStackView!
    @IBOutlet weak var signUpUserName: UITextField!
    @IBOutlet weak var signUpPassword: UITextField!
    @IBOutlet weak var loginUserName: UITextField!
    static var tokenId = String()
    
    @IBOutlet weak var loginPassword: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @IBAction func loginClick(_ sender: Any) {
        let userName = loginUserName.text!
        let passwordLogin = loginPassword.text!
        let db = Firestore.firestore()
        Auth.auth().signIn(withEmail: userName, password: passwordLogin){
            (result,error) in
            if error != nil {
                //add error alert
                let alertController = UIAlertController(title: "Error", message: "Unable to Sign in. User does not exist. Please sign up!", preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(OKAction)
                    self.present(alertController, animated: true, completion: nil)
            }
            else {
                
                //Save the instance id of device on login
                InstanceID.instanceID().instanceID { (result, error) in
                  if let error = error {
                    print("Error fetching remote instance ID: \(error)")
                  } else if let result = result {
                    print("Remote instance ID token: \(result.token)")
                    //saving user email and token
                        db.collection("userTokenMapping").whereField("userEmail",isEqualTo:userName ).getDocuments() { (querySnapshot, err) in
                            if querySnapshot!.documents.count != 1 {
                                db.collection("userTokenMapping").document().setData(["userEmail":userName,"userToken":result.token]){(error) in
                                    if error != nil {
                                        print("error in saving token")
                                    }else{
                                        print("token saved")
                                    }
                                                                                             
                                 }
                            }
                            else{
                                let document = querySnapshot!.documents.first
                                              document?.reference.updateData([
                                              "userToken": result.token
                                ])
                            }
                        }
                  }
                }
                let User = UserDefaults.standard
                User.set(userName, forKey: "userName")
                User.set(passwordLogin, forKey: "password")
                User.set(true, forKey: "automaticLogIn")
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "homestory") as! HomeViewController
                self.present(nextViewController, animated:true, completion:nil)
            }
        }
        
    }
    @IBAction func signUpClick(_ sender: Any) {
        let userName = signUpUserName.text!
        let passwordLogin = signUpPassword.text!
        let displayNameValue = displayName.text!
        
        if displayNameValue.isEmpty{
            let alertController = UIAlertController(title: "Display name is mandatory.", message: "Display name cannot be blank.", preferredStyle: .alert)
                                   let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                   alertController.addAction(OKAction)
                                   self.present(alertController, animated: true, completion: nil)
        }
        else if userName.isEmpty || passwordLogin.isEmpty{
            let alertController = UIAlertController(title: "Error", message: "Cannot have empty username and password. ", preferredStyle: .alert)
                                  let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                  alertController.addAction(OKAction)
                                  self.present(alertController, animated: true, completion: nil)
        }
        else{
            Auth.auth().createUser(withEmail: userName, password: passwordLogin){
                (result,error) in
                if error != nil {
                    print(error!.localizedDescription)
                    if error!.localizedDescription ==  "The password must be 6 characters long or more." {
                        let alertController = UIAlertController(title: "Unable to Sign up.", message: "Password must be 6 characters long.", preferredStyle: .alert)
                                               let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                               alertController.addAction(OKAction)
                                               self.present(alertController, animated: true, completion: nil)
                    }
                    else{
                        //add error alert
                        let alertController = UIAlertController(title: "Unable to Sign up.", message: "User already exists. Please try again.", preferredStyle: .alert)
                            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(OKAction)
                            self.present(alertController, animated: true, completion: nil)
                    }
                }
                else {
                    let db = Firestore.firestore()
                    db.collection("users").document(result!.user.uid).setData(["displayName":displayNameValue,"usid":result!.user.uid,"userEmail":userName,"friendsList":[]]){(error) in
                        if error != nil {
                            let alertController = UIAlertController(title: "Error", message: "Unable to Sign up. Please Try Again!", preferredStyle: .alert)
                                                   let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                                   alertController.addAction(OKAction)
                                                   self.present(alertController, animated: true, completion: nil)
                        }
                        
                    }
                    InstanceID.instanceID().instanceID { (result, error) in
                      if let error = error {
                        print("Error fetching remote instance ID: \(error)")
                      } else if let result = result {
                        print("Remote instance ID token: \(result.token)")
                        ViewController.tokenId = result.token
                        //saving user email and token
                        db.collection("userTokenMapping").document().setData(["userEmail":userName,"userToken":result.token]){(error) in
                            if error != nil {
                              print("error in saving token")
                            }else{
                               print("token saved")
                            }
                                                              
                       }
                      }
                    }
                    
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    let nextViewController = storyBoard.instantiateViewController(withIdentifier: "homestory") as! HomeViewController
                    self.present(nextViewController, animated:true, completion:nil)
                }
            }
        }
    }
}

