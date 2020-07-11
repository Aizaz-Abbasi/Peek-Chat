//
//  AllUsersCell.swift
//  Chating App
//
//  Created by Mac on 08/06/2020.
//  Copyright © 2020 Peek International. All rights reserved.
//

import UIKit



protocol buttonDelegate {
   // func audioCallBtnClick(indexPath:IndexPath)
    //func videoCallBtnClick(indexPath:IndexPath)
    func openChatBtnClick(indexPath:IndexPath)
}
class AllUsersCell: UITableViewCell {

  
    @IBOutlet weak var nameLbl : UILabel!
    @IBOutlet weak var onlineStatusLbl : UILabel!
    var delegate:buttonDelegate?
    
    var indexPath = IndexPath()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func audioCallBtn(_ sender: UIButton) {
        //delegate?.audioCallBtnClick(indexPath: indexPath)
    }
    
    @IBAction func videoCallBtn(_ sender: UIButton) {
       // delegate?.videoCallBtnClick(indexPath: indexPath)
    }
    
    @IBAction func openChatBtn(_ sender: UIButton) {
       delegate?.openChatBtnClick(indexPath: indexPath)
    }

}
