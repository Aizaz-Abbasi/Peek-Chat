//
//  AllUsersVC.swift
//  Chating App
//
//  Created by Mac on 08/06/2020.
//  Copyright © 2020 Peek International. All rights reserved.
//

import UIKit
import iProgressHUD

class AllUsersVC: BaseVC {

    var users : [users]!
    @IBOutlet weak var tableView:UITableView!
    let iprogress: iProgressHUD = iProgressHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        setGradientBackground()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        iprogress.indicatorStyle = .ballSpinFadeLoader
        iprogress.indicatorSize = 40
        iprogress.captionSize = 10
        iprogress.isShowCaption = false
        iprogress.boxSize = 30
        iprogress.boxColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.714067851)
        iprogress.attachProgress(toView: self.view)
        if users == nil{
           view.showProgress()
        }
        DatabaseManager.sharedInstance.getAllUsers { (error, user) in
        if user != nil{
            if self.users == nil || user?.count != self.users.count{
                self.users = user
                self.view.dismissProgress()
                self.tableView.reloadData()
            }
           }
        }
        //
        SocketIOManager.sharedInstance.login(message: GlobalVar.userINFO?[0]._id as Any)
    }
}

extension AllUsersVC : UITableViewDelegate, UITableViewDataSource ,buttonDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         if users == nil{
            return 0
         }
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                 let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! AllUsersCell
                cell.delegate = self
                cell.indexPath = indexPath
                cell.nameLbl.text = users[indexPath.row].name.capitalizingFirstLetter()
                let onlineStatus = users[indexPath.row].onlineStatus
                if onlineStatus == 0{
                    //cell.onlineStatusLbl.text = "Offline"
                    //cell.onlineStatusLbl.textColor = UIColor.red
                }else{
                    //cell.onlineStatusLbl.text = "Online"
                   // cell.onlineStatusLbl.textColor = UIColor.green
                }
                       return cell
    }
    
    func openChatBtnClick(indexPath: IndexPath) {
        
           let vc = UIStoryboard.init(name: "App", bundle: Bundle.main).instantiateViewController(withIdentifier: "MessaageVC") as? MessaageVC
        print(users[indexPath.row])
           vc?.msgSenderId = users[indexPath.row]._id
           vc?.title = users[indexPath.row].name.capitalizingFirstLetter()
           vc!.friendData.append(users[indexPath.row])
           vc?.friendName = users[indexPath.row].name
           self.navigationController?.pushViewController(vc!, animated: true)
       }
}
