//
//  SplashViewController.swift
//  LoginExample
//
//  Created by Abhinav on 6/13/20.
//  Copyright © 2020 Gary Tokman. All rights reserved.
//

import UIKit
import Firebase
import Messages
import UserNotifications
import FirebaseMessaging
import FirebaseInstanceID
import AVFoundation
class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if Auth.auth().currentUser != nil{
                          print(" 1navigate to home screen")
               }else {
                          print("1login and stay put")
               }
        // Do any additional setup after loading the view.
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if Auth.auth().currentUser != nil{
                          print("2navigate to home screen")
               }else {
                          print("2login and stay put")
               }
    }*/
}
