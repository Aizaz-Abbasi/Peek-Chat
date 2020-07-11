//
//  MessageCell.swift
//  Chating App
//
//  Created by Mac on 08/06/2020.
//  Copyright © 2020 Peek International. All rights reserved.
//

import UIKit


protocol selectDelegate {
    func selectCellBtn(indexPath:IndexPath)
}

class MessageCell: SwipyCell {

    
    @IBOutlet var lblSender : UILabel?
    @IBOutlet var lblDate : UILabel?
    @IBOutlet var lblContent : UILabel?
    @IBOutlet var viewContainer : UIView?
    @IBOutlet var imgChecked : UIImageView?
    @IBOutlet var msgImageView : UIImageView?
    
    //@IBOutlet var selectBtn : UIButton?
    
    var SelectDelegate: selectDelegate!
    var indexPath = IndexPath()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//       let tapGesture = UITapGestureRecognizer(target: self, action: #selector(MessageCell.tapEdit(_:)))
//        MessageCell.addGestureRecognizer(tapGesture!)
//        tapGesture!.delegate = self
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       // self.accessoryType = selected ? .checkmark : .none
        // Configure the view for the selected state
    }
    
//    @IBAction func CellCllicked( _ sender: UIButton){
//       // SelectDelegate.selectCellBtn(indexPath:indexPath)
//    }
}


