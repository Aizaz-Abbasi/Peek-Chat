//
//  SignupVC.swift
//  Chat App
//
//  Created by Mac on 01/06/2020.
//  Copyright © 2020 Peek International. All rights reserved.
//

import Foundation
import UIKit
import Toast_Swift
import Alamofire
import SwiftyJSON
import iProgressHUD

class SignupVC: BaseVC {

    @IBOutlet weak var nameTxt:UITextField!
    @IBOutlet weak var emailTxt:UITextField!
    @IBOutlet weak var numberTxt:UITextField!
    @IBOutlet weak var passwordTxt:UITextField!
    @IBOutlet weak var loginBtn:UIButton!

    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        setGradientBackground()
        nameTxt.layer.cornerRadius = 18
        emailTxt.layer.cornerRadius = 18
        loginBtn.layer.cornerRadius = 18
        numberTxt.layer.cornerRadius = 18
        passwordTxt.layer.cornerRadius = 18
        nameTxt.clipsToBounds = true
        numberTxt.clipsToBounds = true
        passwordTxt.clipsToBounds = true
        emailTxt.clipsToBounds = true
    }
    
    @IBAction func loginBtn( _ sender: UIButton){
        //check value is empty
        //getVerified()
        
        let value = nameTxt.text!.isBlank && emailTxt.text!.isBlank  && numberTxt.text!.isBlank && passwordTxt.text!.isBlank
        if value  {
            // Check Email
            if emailTxt.text!.isEmail{
            //Check Number
                if numberTxt.text!.isValidContact{
                    
                    if passwordTxt.text!.isValidPassword{
                        view.showProgress()
                        let parameters = [
                        "name" : nameTxt.text! ,
                        "email" : emailTxt.text!,
                        "phone" : numberTxt.text!,
                        "password" : passwordTxt.text!,
                        "projectId" : "5d4c07fb030f5d0600bf5c03"
                        ]
                        DatabaseManager.sharedInstance.signUp(parameters: parameters) { (response, status) in
                            self.view.dismissProgress()
                            if status{
                                 self.view.makeToast(response)
                            Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { (timer) in
                            self.navigationController?.popToRootViewController(animated: true)
                                }
                            }
                        }
                    }else{
                       //pass
                        if passwordTxt.text!.count <= 8 {
                            self.view.makeToast("Passowrd must contain atleast 6 characters.")
                        }else{
                            self.view.makeToast("Passowrd must contain 1 special character and number.")
                        }
                    }
                }else{
                    //number
                    self.view.makeToast("Enter valid number.")
                }
            }else{
               //email
                self.view.makeToast("Incorrect Email.")
            }
        }else{
            self.view.makeToast("Fill all data.")
        }
    }
}
