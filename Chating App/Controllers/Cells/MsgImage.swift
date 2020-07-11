//
//  MsgImage.swift
//  Chating App
//
//  Created by Mac on 18/06/2020.
//  Copyright © 2020 Peek International. All rights reserved.
//

import UIKit

class MsgImage: SwipyCell {

    var SelectDelegate: selectDelegate?
    //@IBOutlet var selectBtn : UIButton?
    
    var indexPath = IndexPath()
    var downloadImg : (() -> Void)? = nil
   // @IBOutlet var lblSender : UILabel?
    @IBOutlet var lblDate : UILabel?
    //@IBOutlet var lblContent : UILabel?
    @IBOutlet var viewContainer : UIView?
    //@IBOutlet var imgChecked : UIImageView?
    @IBOutlet var msgImageView : UIImageView?
    

    @IBAction func downloadImage(_ sender:UIButton){
           if let downloadBtnAction = self.downloadImg
           {
               downloadBtnAction()
             //  user!("pass string")
           }
       }
    
//    @IBAction func CellCllicked( _ sender: UIButton){
//        SelectDelegate?.selectCellBtn(indexPath:indexPath)
//    }
}
