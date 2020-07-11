//
//  MsgFileSend.swift
//  Chating App
//
//  Created by Mac on 22/06/2020.
//  Copyright © 2020 Peek International. All rights reserved.
//

import UIKit

protocol downloadDelegate {
    func downloadFile(indexPath: IndexPath)
}

class MsgFileSend: SwipyCell {

    
    var SelectDelegate: selectDelegate!
    //@IBOutlet var selectBtn : UIButton?
    
    var downloadDelegate:downloadDelegate?
    var indexPath = IndexPath()
    // @IBOutlet var lblSender : UILabel?
     //@IBOutlet var lblDate : UILabel?
     @IBOutlet var lblDate : UILabel?
     @IBOutlet var lblName : UILabel?
     @IBOutlet var viewContainer : UIView?
     //@IBOutlet var imgChecked : UIImageView?
     @IBOutlet var msgImageView : UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func downloadFile(_ sender:UIButton){
        downloadDelegate?.downloadFile(indexPath: indexPath)
    }

//    @IBAction func CellCllicked( _ sender: UIButton){
//        SelectDelegate.selectCellBtn(indexPath:indexPath)
//    }
}
