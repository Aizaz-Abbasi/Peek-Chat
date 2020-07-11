//
//  SceneDelegate.swift
//  Chating App
//
//  Created by Mac on 01/06/2020.
//  Copyright © 2020 Peek International. All rights reserved.
//

import UIKit
import SwiftyJSON

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        var usersObject: [user] = []
         let defaults = UserDefaults.standard
        let value = defaults.bool(forKey: "isFirst")
        let isLoggedIn = defaults.bool(forKey: "isLoggedIn")
                if value{
                    let data = defaults.object(forKey: "userINFO")  as! Data
                    var json = JSON()
                do{
                                json =  try JSON(data: data)
                                               print(json)
                                           let decoder = JSONDecoder()
                                           let jsonData = try decoder.decode(UserResponseData.self, from: data)
                                usersObject = [jsonData.user]
                                           print(usersObject)
                                           GlobalVar.userINFO = usersObject
                SocketIOManager.sharedInstance.login(message: GlobalVar.userINFO?[0]._id as Any)
                DatabaseManager.sharedInstance.EmptyChatRefId()
                                
                }catch let error as NSError{ print(error)}
                    window!.rootViewController = UIStoryboard(name: "App", bundle: nil).instantiateInitialViewController()!
                    window!.makeKeyAndVisible()
                }
        
        
        
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    @available(iOS 13.0, *)
    func sceneDidDisconnect(_ scene: UIScene) {
        let defaults = UserDefaults.standard
        let value = defaults.bool(forKey: "isFirst")
        if value{
        DatabaseManager.sharedInstance.EmptyChatRefId()
        SocketIOManager.sharedInstance.logout(message: GlobalVar.userINFO?[0]._id as Any)
        }
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    @available(iOS 13.0, *)
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    @available(iOS 13.0, *)
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    @available(iOS 13.0, *)
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    @available(iOS 13.0, *)
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

