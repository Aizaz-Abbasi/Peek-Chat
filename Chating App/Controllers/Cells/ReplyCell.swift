//
//  ReplyCell.swift
//  Chating App
//
//  Created by Mac on 01/07/2020.
//  Copyright © 2020 Peek International. All rights reserved.
//

import UIKit

protocol replyDelegate {
    func replyMsgBtn(indexPath: IndexPath)
}
class ReplyCell: SwipyCell {

    @IBOutlet weak var replyNameLbl:UILabel!
    @IBOutlet weak var replyMsgLbl:UILabel!
    @IBOutlet weak var dateLbl:UILabel!
    @IBOutlet weak var msgLbl:UILabel!
    @IBOutlet var viewContainer : UIView?
    var msgDelegate:replyDelegate?
    var indexPathMsg = IndexPath()
    var indexPath = IndexPath()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
     @IBAction func replyMsgClick(_ sender:UIButton){
        msgDelegate?.replyMsgBtn(indexPath: indexPathMsg)
    }
}
