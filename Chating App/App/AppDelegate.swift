//
//  AppDelegate.swift
//  Chating App
//
//  Created by Mac on 01/06/2020.
//  Copyright © 2020 Peek International. All rights reserved.
//

import UIKit
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
      if #available(iOS 13.0, *) {
      }else{
        DatabaseManager.sharedInstance.EmptyChatRefId()
        var usersObject: [user] = []
               let defaults = UserDefaults.standard
              let value = defaults.bool(forKey: "isFirst")
                      if value{
                        
                          //GlobalVar.userINFO
                let data = defaults.object(forKey: "userINFO")  as! Data
                    //var json = JSON()
                    do{
                       //json =  try JSON(data: data)
                       //print(json)
                       let decoder = JSONDecoder()
                       let jsonData = try decoder.decode(UserResponseData.self, from: data)
                       usersObject = [jsonData.user]
                       //print(usersObject)
                        SocketIOManager.sharedInstance.login(message: GlobalVar.userINFO?[0]._id as Any)
                        DatabaseManager.sharedInstance.EmptyChatRefId()
                        GlobalVar.userINFO = usersObject
                      }catch let error as NSError{ print(error)}
                          window!.rootViewController = UIStoryboard(name: "App", bundle: nil).instantiateInitialViewController()!
                          window!.makeKeyAndVisible()
                      }
          
        }
        //defaults.set(25, forKey: "isFirst")
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
            return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
       
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        let defaults = UserDefaults.standard
        let value = defaults.bool(forKey: "isFirst")
        if value{
        DatabaseManager.sharedInstance.EmptyChatRefId()
        SocketIOManager.sharedInstance.logout(message: GlobalVar.userINFO?[0]._id as Any)
        }
    }

}
