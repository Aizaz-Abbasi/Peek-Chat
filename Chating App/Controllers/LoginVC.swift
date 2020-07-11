//
//  LoginVC.swift
//  Chat App
//
//  Created by Mac on 01/06/2020.
//  Copyright © 2020 Peek International. All rights reserved.
//

import UIKit
import Toast_Swift
import Alamofire
import SwiftyJSON
import iProgressHUD

class LoginVC: BaseVC {

    @IBOutlet weak var userNameTxt:UITextField!
    @IBOutlet weak var passwordTxt:UITextField!
    @IBOutlet weak var loginBtn:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        setGradientBackground()
        userNameTxt.layer.cornerRadius = 18
        passwordTxt.layer.cornerRadius = 18
        userNameTxt.clipsToBounds = true
        passwordTxt.clipsToBounds = true
        loginBtn.layer.cornerRadius = 18

    }
    
    @IBAction func loginBtn( _ sender: UIButton){
        //getVerified()
        if userNameTxt.text!.isBlank && passwordTxt.text!.isBlank {
            self.view.showProgress()
        DatabaseManager.sharedInstance.getVerified(name:userNameTxt.text!,password:passwordTxt.text!, completion: { error , status in
            self.view.dismissProgress()
            if status{
                if let nav = UIStoryboard(name: "App", bundle: nil).instantiateViewController(withIdentifier: "NavC") as? NavC{
                let rootVc  = UIStoryboard(name: "App", bundle: nil).instantiateViewController(withIdentifier: "UsersVC")
                          nav.viewControllers = [rootVc]
                UIApplication.shared.keyWindow?.rootViewController = nav
                }
            }else{
                self.view.makeToast("UserName or password is incorrect")
            }
//                if  error == nil {
//                     self.view.makeToast("UserName or password is incorrect")
//                }
            })
        }else{
            self.view.makeToast("Enter username or password.")
        }
    }

}
