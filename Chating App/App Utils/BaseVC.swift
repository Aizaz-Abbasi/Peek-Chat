//
//  BaseVC.swift
//  Chat App
//
//  Created by Mac on 01/06/2020.
//  Copyright © 2020 Peek International. All rights reserved.
//

import Foundation
import UIKit
import iProgressHUD


class BaseVC: UIViewController {
    
    
        override func viewDidLoad(){
               super.viewDidLoad()
            self.hideKeyboardWhenTappedAround()
            
            let iprogress: iProgressHUD = iProgressHUD()
           // iprogress.indicatorStyle = .ballSpinFadeLoader
            iprogress.indicatorStyle = .ballClipRotatePulse
            iprogress.indicatorSize = 40
            iprogress.captionSize = 10
            iprogress.isShowCaption = false
            iprogress.boxSize = 30
            iprogress.isBlurModal = false
            iprogress.isBlurBox = false
            iprogress.isShowBox = false
            iprogress.boxColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            iprogress.indicatorColor = .blue
            
            iprogress.attachProgress(toView: self.view)
        }
    
        func setGradientBackground() {
        let colorBottom =  UIColor(red: 11.0/255.0, green: 204.0/255.0, blue: 230.0/255.0, alpha: 1.0).cgColor
        let  colorTop = UIColor(red: 11.0/255.0, green: 62.0/255.0, blue: 230.0/255.0, alpha: 1.0).cgColor

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds

        self.view.layer.insertSublayer(gradientLayer, at:0)
    }
    
    
    func navTitleWithImageAndText(titleText: String,subTitleText:String, imageName: String) -> UIView {
        // Creates a new UIView
        let titleView = UIView()
         let label = UILabel(frame: CGRect(x: 0, y: -15, width: 0, height: 0))
        // Creates a new text label
       // let label = UILabel()
        label.text = titleText
        
        label.font = UIFont.boldSystemFont(ofSize: 17)
        //label.center = titleView.center
        label.textColor = .white
        //label.textAlignment = NSTextAlignment.center
        label.sizeToFit()
        
        let subtitleLabel = UILabel(frame: CGRect(x: 0, y: 5, width: 0, height: 0))
        subtitleLabel.backgroundColor = UIColor.clear
        subtitleLabel.textColor = UIColor.white
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.text = subTitleText
        subtitleLabel.sizeToFit()

        // Creates the image view
        let image = UIImageView()
        image.image = UIImage(named: imageName)
        // Maintains the image's aspect ratio:
        let imageAspect = image.image!.size.width / image.image!.size.height

        // Sets the image frame so that it's immediately before the text:
        let imageX = label.frame.origin.x - label.frame.size.height * imageAspect - 20
        let imageY = label.frame.origin.y
        let imageWidth = label.frame.size.height * imageAspect + 15
        let imageHeight = label.frame.size.height + 15
        image.frame = CGRect(x: imageX, y: imageY, width: imageWidth, height: imageHeight)
        image.contentMode = UIView.ContentMode.scaleAspectFit
        // Adds both the label and image view to the titleView
        titleView.addSubview(label)
        titleView.addSubview(image)
        titleView.addSubview(subtitleLabel)
        // Sets the titleView frame to fit within the UINavigation Title
        titleView.sizeToFit()

        return titleView
    }
}


