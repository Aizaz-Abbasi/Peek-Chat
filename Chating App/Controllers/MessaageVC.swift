//
//  MessaageVC.swift
//  Chating App
//
//  Created by Mac on 02/06/2020.
//  Copyright © 2020 Peek International. All rights reserved.
//

import UIKit
import Toast_Swift
import Alamofire
import SwiftyJSON
import SocketIO
import iProgressHUD
import NextGrowingTextView
import MobileCoreServices
import Kingfisher
import YangMingShan
import AlamofireImage
import SwipyCell


class MessaageVC: BaseVC {

    var selectedCells = [Int]()
    var isSelected = true
    var isReply = false
    var commentMessage = [message]()
    //GLOBLE VAR
    let manager = SocketManager(socketURL: URL(string: API.SOCKET_URL)!,config: [.log(true)])
    
    @IBOutlet weak var tableviewBottomConstaint: NSLayoutConstraint!
    @IBOutlet weak var inputContainerView: UIView!
    @IBOutlet weak var inputContainerViewBottom: NSLayoutConstraint!
    @IBOutlet weak var collectionView:UICollectionView!
    @IBOutlet weak var sendBtn: UIButton!
    
    @IBOutlet weak var replyView: UIView!
    @IBOutlet weak var nameReplyLbl: UILabel!
    @IBOutlet weak var msgReplyLbl: UILabel!
    
    var isMultiple = false
    var isImage = false
    
    var searchTimer: Timer?
    
    var imageName = [String]()
    var images = [UIImage]()
    private var documents = [Document]()
    var isDocument = false
    private var sourceType: SourceType!
    private var pickerController: UIDocumentPickerViewController?
    //MARK: Getting Values From Previous VC
    var msgSenderId = ""
    var friendName = ""
    var friendData = [users]()
    
    var socket:SocketIOClient!
    @IBOutlet weak var msgText :NextGrowingTextView!
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var preChatLbl:UILabel!
    @IBOutlet weak var delateMsgBtn:UIBarButtonItem!
    var messagesArr = [message]()
    
    var tapPressGesture = UITapGestureRecognizer()
    var longPressGesture = UILongPressGestureRecognizer()
    override func viewDidLoad(){
        super.viewDidLoad()

        //msgText.delegates = self
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        self.tableView.addGestureRecognizer(longPressGesture)
        
         tapPressGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(tapGesture:)))
        //tapPressGesture.minimumPressDuration = 0.5
        tapPressGesture.isEnabled = false
        self.tableView.addGestureRecognizer(tapPressGesture)
        SocketIOManager.sharedInstance.addHandlers()
        SocketIOManager.sharedInstance.establishConnection()
        
        hideKeyboardWhenTappedAround()
        //MARK: TextView Expand
        NotificationCenter.default.addObserver(self, selector: #selector(MessaageVC.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)

           NotificationCenter.default.addObserver(self, selector: #selector(MessaageVC.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(MessaageVC.startTyping), name: UITextView.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MessaageVC.stopTyping), name: UITextView.textDidEndEditingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MessaageVC.startTyping), name: UITextView.textDidChangeNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MessaageVC.stopTyping), name: UITextView.keyboardWillHideNotification, object: nil)

           self.msgText?.layer.cornerRadius = 4
           self.msgText?.backgroundColor = UIColor(white: 0.9, alpha: 1)
           self.msgText?.placeholderAttributedText = NSAttributedString(
             string: "Enter Message To Send",
             attributes: [
               .font: self.msgText.textView.font!,
               .foregroundColor: UIColor.gray
             ]
           )
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.register(UINib(nibName: "MsgImage", bundle: nil), forCellReuseIdentifier: "MsgImageSend")
       self.tableView.register(UINib(nibName: "MsgImageRec", bundle: nil), forCellReuseIdentifier: "MsgImageRec")
        self.tableView.register(UINib(nibName: "MsgFileSend", bundle: nil), forCellReuseIdentifier: "MsgFileSend")
        self.tableView.register(UINib(nibName: "MsgFileRecve", bundle: nil), forCellReuseIdentifier: "MsgFileRecve")
        
        self.tableView.register(UINib(nibName: "ReplyCell", bundle: nil), forCellReuseIdentifier: "ReplyMsg")
        self.tableView.register(UINib(nibName: "ReplyRecvCell", bundle: nil), forCellReuseIdentifier: "ReplyRecvCell")
        
        
        // MARK: Recv Message From Socket
        SocketIOManager.sharedInstance.getChatMessage { (messageInfo) -> Void in
            self.parseSocketMsg(messag: messageInfo)
          }
        // MARK: Update MessageId From Socket
        SocketIOManager.sharedInstance.updateRecvMsg { (messag) in
            print(messag)
            let jsonData = try? JSONSerialization.data(withJSONObject: messag, options: .prettyPrinted)
            let decoder = JSONDecoder()
                do{
                 let jsonData = try decoder.decode([message].self, from: jsonData!)
                let  usersObject = jsonData[0]
                if usersObject.receiverId?._id == GlobalVar.userINFO?[0]._id && usersObject.senderId?._id == self.msgSenderId || usersObject.senderId?._id == GlobalVar.userINFO?[0]._id{
                    //if messag != nil{
                    let index = self.messagesArr.firstIndex{$0._id == "0" || $0._id == nil}
                        if let searchIndex = index{
                            self.messagesArr[searchIndex]._id = usersObject._id
                            self.messagesArr[searchIndex].isDeleted = usersObject.isDeleted
                            }else{
                        //print(error!)
                    }
                  }
                }catch let error as NSError{
                    print(error)}
        }
        
        // MARK: Recv Delete Message From Socket
        SocketIOManager.sharedInstance.recvDeleteMsg { (messag) in
            if case Optional<Any>.none = messag{
                print("duz")
            }else{
            let jsonData = try? JSONSerialization.data(withJSONObject: messag, options: .prettyPrinted)
                let decoder = JSONDecoder()
                do{
                let jsonData = try decoder.decode([message].self, from: jsonData!)
                let  usersObject = jsonData[0]
                if usersObject.receiverId?._id == GlobalVar.userINFO?[0]._id && usersObject.senderId?._id == self.msgSenderId || usersObject.senderId?._id == GlobalVar.userINFO?[0]._id{
                    let msgId = usersObject._id
                 for i in 0..<self.messagesArr.count{
                    if self.messagesArr[i]._id == msgId {
                        self.messagesArr[i].isDeleted = 1
                        let indexPosition = IndexPath(row: i, section: 0)
                        self.tableView.reloadRows(at: [indexPosition], with: .middle)
                            }
                        }
                  }else{
                    self.view.makeToast("Message Recv ")
                 }
                }catch let error as NSError{
                    print(error)
                }
            }
        }
        
        // MARK: Start Typing Response
        SocketIOManager.sharedInstance.StartTypingFriend { (typingData) in
          
            self.typingResponse(data: typingData ,typing: true)
            }
        // MARK: Stop Typing Response
        SocketIOManager.sharedInstance.StopTypingFriend { data in
            self.typingResponse(data: data, typing: false)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        //initUI()
        replyView.isHidden = true
        self.replyView.layer.cornerRadius = 5
        //self.replyView.frame.height = 30
        self.replyView.frame.size.height = CGFloat(60)
            //CGRect(x: 0, y: 0, width: self.view.frame.width, height:  20.0)
        self.navigationItem.titleView =  navTitleWithImageAndText(titleText: friendName, subTitleText: "Last Seen 10:00", imageName: "pro1")
             self.preChatLbl.isHidden = true
        self.tapPressGesture.isEnabled = false;
        self.delateMsgBtn.isEnabled = false
        self.delateMsgBtn.tintColor = .clear
        if messagesArr.count == 0{
          view.showProgress()
        }
        self.navigationItem.leftBarButtonItem = nil
        collectionView.isHidden = true
        loadChat()
    }
    
    func parseSocketMsg(messag: Any){
        let jsonData = try? JSONSerialization.data(withJSONObject: messag, options: .prettyPrinted)
         //var usersObject: MessageResponseData?
        let decoder = JSONDecoder()
        do{
           // print(jsonData)
            let jsonData = try decoder.decode([MessageResponseData].self, from: jsonData!)
            print(jsonData)
            let  usersObject = jsonData[0]
            print(usersObject)
            if usersObject.msgData.receiverId?._id == GlobalVar.userINFO?[0]._id && usersObject.msgData.senderId?._id == msgSenderId || usersObject.msgData.senderId?._id == GlobalVar.userINFO?[0]._id{
                messagesArr.append(usersObject.msgData)
                print(usersObject.msgData)
                print(messagesArr)
                self.tableView.isHidden = false
                self.tableView.reloadData()
                if self.messagesArr.count > 0{
                    self.tableView.scrollToBottom()
                }
                preChatLbl.isHidden = true
            }else{
                //self.view.makeToast("Message Recv ")
            }
        }catch let error as NSError{
            print(error)}
    }
    
    func loadChat(){
        
       // print(msgSenderId)
        DatabaseManager.sharedInstance.GetChat(receiverId:msgSenderId){ (messages) in
                   self.view.dismissProgress()
            if messages?.count != 0 || messages != nil{
                self.messagesArr = messages!
                print(self.messagesArr.count)
                print(self.messagesArr)
                self.tableView.isHidden = false
                       self.tableView.reloadData()
                    if self.messagesArr.count != 0{
                       self.tableView.scrollToBottom()
                    }
                    self.preChatLbl.isHidden = true
                   }else{
                    self.preChatLbl.isHidden = false
                    self.tableView.isHidden = true
                }
            }
    }
    
    @IBAction func sendMsgBtn( _ sender: UIButton){
        hideDeleteBtn()
        
        self.replyView.isHidden = true
        //var msgCmnt = message()
        if !isImage{
            var message = msgText?.textView.text
            message = message?.trimmingCharacters(in: .whitespacesAndNewlines)
            if message != "" && message != nil{
                DatabaseManager.sharedInstance.sendMsg(messag: message!, receiverId: msgSenderId ,isReply:isReply, commentMsg:commentMessage.first){ (error ,messag)  in
               // print(messag!)
                    if messag != nil{
                        let index = self.messagesArr.firstIndex{$0._id == "0"  || $0._id == nil}
                        if let searchIndex = index{
                            self.messagesArr[searchIndex]._id = messag?._id
                        }
                    }else{
                        print(error)
                    }
                }
            msgText.textView.text = ""
            }else{
                self.view.makeToast("Enter some text to send")
            }
        }else{
            self.view.makeToast("Sending")
            if images.count > 0{
                print(images.count)
                for i in 0 ... images.count - 1{
                    DatabaseManager.sharedInstance.sendImage(receiverId: msgSenderId, image: images[i], imageName: imageName[i]){ isSent in
                            if isSent{
                                self.view.makeToast("Sent")
                            }
                        }
                }
                self.isImage = false
                self.collectionView.isHidden = true
            }
        }
        isReply = false
    }

    func sendPing() {
        guard let socket = socket, socket.status == .connected
            else { return }
        //socket.write(ping: "PING")
    }
}

extension MessaageVC : UITableViewDelegate, UITableViewDataSource ,downloadDelegate {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var  cell = MsgImage()
        var  cell2 = MessageCell()
        var  cellFile = MsgFileSend()
        var replyCell = ReplyCell()
        if messagesArr.count - 2 == indexPath.row{
            print(messagesArr[indexPath.row])
        }
        print(messagesArr[indexPath.row])
        var reuseIdentifier = ""
        var bgColor = UIColor(red: (198.0/255.0), green: (198.0/255.0), blue: (200.0/255.0), alpha: 1.0)
        
        if GlobalVar.userINFO?[0]._id != messagesArr[indexPath.row].receiverId?._id{
        bgColor = UIColor(red: (198.0/255.0), green: (198.0/255.0), blue: (200.0/255.0), alpha: 1.0)
         reuseIdentifier = "ChatDetailCellTextSend"
        }

        if GlobalVar.userINFO?[0]._id != messagesArr[indexPath.row].senderId?._id{
            reuseIdentifier = "ChatDetailCellTextReceive"
             bgColor = UIColor(red: (56.0/255.0), green: (199.0/255.0), blue: (164.0/255.0), alpha: 1.0)
        }
        
        if messagesArr[indexPath.row].messageType == 1{
            reuseIdentifier = "MsgImageRec"
            if GlobalVar.userINFO?[0]._id == messagesArr[indexPath.row].senderId?._id{
                 reuseIdentifier = "MsgImageSend"
            }
        }
        if messagesArr[indexPath.row].messageType == 2{
            reuseIdentifier = "MsgFileRecve"
            if GlobalVar.userINFO?[0]._id == messagesArr[indexPath.row].senderId?._id{
                 reuseIdentifier = "MsgFileSend"
            }
        }
        if messagesArr[indexPath.row].chatType == 1{
            reuseIdentifier = "ReplyRecvCell"
            if GlobalVar.userINFO?[0]._id == messagesArr[indexPath.row].senderId?._id{
                 reuseIdentifier = "ReplyMsg"
            }
        }
        if messagesArr[indexPath.row].chatType == 0 && messagesArr[indexPath.row].isDeleted == 1{
            
            print("fd")}
        if messagesArr[indexPath.row].chatType == 0 || messagesArr[indexPath.row].isDeleted == 1{
        if messagesArr.count != 0{
            cell.msgImageView?.layer.masksToBounds = false
            cell.msgImageView?.layer.shadowColor = UIColor.black.cgColor
            cell.msgImageView?.layer.shadowOpacity = 0.0
            cell.msgImageView?.layer.shadowOffset = CGSize(width: 0, height: 10)
            cell.msgImageView?.layer.shadowRadius = 10
            cell.msgImageView?.layer.shadowPath = UIBezierPath(rect: cell.msgImageView!.bounds).cgPath
            cell.msgImageView?.layer.shouldRasterize = true
           
            //Message
             if messagesArr[indexPath.row].messageType == 1 &&  messagesArr[indexPath.row].isDeleted == 0 && messagesArr[indexPath.row].chatType == 0{
               
                cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MsgImage
                    let msg = messagesArr[indexPath.row].message
                    cell.indexPath = indexPath
                if  let url = URL( string: "\(API.GET_IMAGE)\(msg)"){
                        cell.msgImageView?.kf.setImage(with: url)
                        cell.lblDate?.text = getDate(date: messagesArr[indexPath.row].createdAt)
                        cell.backgroundColor = .clear
                        cell.viewContainer?.backgroundColor = bgColor
                        cell.viewContainer?.layer.cornerRadius = 8
                        cell.msgImageView?.layer.cornerRadius = 5
                        if selectedCells.contains(indexPath.row) && cell2.indexPath == indexPath{
                            cell.contentView.backgroundColor = .blue
                        }else{
                            cell.contentView.backgroundColor = .clear
                        }
                        configureCell(cell, forRowAtIndexPath: indexPath)
                    }
                    cell.downloadImg = {
                        var sent = true
                        if GlobalVar.userINFO?[0]._id != self.messagesArr[indexPath.row].senderId?._id{
                            sent = false
                        }
                        DownloadData.sharedInstance.download(isImage: true, isSent: sent, name: self.messagesArr[indexPath.row].message)
                        }
            //File
            }else if messagesArr[indexPath.row].messageType == 2  &&  messagesArr[indexPath.row].isDeleted == 0{
            cellFile = tableView.dequeueReusableCell(withIdentifier:reuseIdentifier ,for: indexPath) as! MsgFileSend
               // if cell.indexPath == indexPath {
                cellFile.delegate = self
                cellFile.downloadDelegate = self
                cellFile.indexPath = indexPath
                cellFile.viewContainer?.layer.cornerRadius = 10
                cellFile.lblDate?.text = getDate(date: messagesArr[indexPath.row].createdAt)
               cellFile.lblName?.text =      messagesArr[indexPath.row].message
                cellFile.msgImageView?.backgroundColor = .clear
                cellFile.msgImageView?.image = UIImage(named: "folder")
                cellFile.backgroundColor = .clear
                cellFile.viewContainer?.backgroundColor = bgColor
                if selectedCells.contains(indexPath.row) || cell2.indexPath == indexPath{
                    cellFile.contentView.backgroundColor = .blue
                }else{
                    cellFile.contentView.backgroundColor = .clear
                }
                configureCell(cellFile, forRowAtIndexPath: indexPath)
            
            }else{
                if GlobalVar.userINFO?[0]._id != messagesArr[indexPath.row].receiverId?._id {
                       bgColor = UIColor(red: (198.0/255.0), green: (198.0/255.0), blue: (200.0/255.0), alpha: 1.0)
                        reuseIdentifier = "ChatDetailCellTextSend"
                       }
                if GlobalVar.userINFO?[0]._id != messagesArr[indexPath.row].senderId?._id{
                        reuseIdentifier = "ChatDetailCellTextReceive"
                        bgColor = UIColor(red: (56.0/255.0), green: (199.0/255.0), blue: (164.0/255.0), alpha: 1.0)
                       }
                cell2 = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MessageCell
                
                cell2.lblSender?.text = ""
                cell2.lblSender?.isHidden = true
                cell2.viewContainer?.layer.cornerRadius = 10.0
                cell2.viewContainer?.backgroundColor = bgColor
                cell2.lblDate?.text = getDate(date: messagesArr[indexPath.row].createdAt)
                
                if  messagesArr[indexPath.row].isDeleted == 1{
                    cell2.lblContent?.text = "Message Deleted!"
                }else{
                    cell2.lblContent?.text = messagesArr[indexPath.row].message
                }
                if selectedCells.contains(indexPath.row) || cell2.indexPath == indexPath{
                    cell2.contentView.backgroundColor = .blue
                }else{
                    cell2.contentView.backgroundColor = .clear
                }
                configureCell(cell2, forRowAtIndexPath: indexPath)
            }
        }
        }else{
             replyCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ReplyCell
              replyCell.viewContainer?.layer.cornerRadius = 10.0
              replyCell.viewContainer?.backgroundColor = bgColor
              replyCell.dateLbl?.text = getDate(date: messagesArr[indexPath.row].createdAt)
              if  messagesArr[indexPath.row].isDeleted == 1{
                  replyCell.msgLbl?.text = "Message Deleted!"
              }else{
                replyCell.msgLbl?.text = messagesArr[indexPath.row].message
              }
            replyCell.msgDelegate = self
            replyCell.indexPathMsg = indexPath
            replyCell.replyNameLbl.text = friendName
            if  messagesArr[indexPath.row].commentId?.isDeleted == 1{
                 replyCell.replyMsgLbl.text = "Message Deleted!"
            }else{
                replyCell.replyMsgLbl.text = messagesArr[indexPath.row].commentId?.message
            }
              if selectedCells.contains(indexPath.row) || replyCell.indexPath == indexPath{
                  replyCell.contentView.backgroundColor = .blue
              }else{
                  replyCell.contentView.backgroundColor = .clear
              }
              configureCell(replyCell, forRowAtIndexPath: indexPath)
        }
        if  messagesArr[indexPath.row].messageType == 1 &&  messagesArr[indexPath.row].isDeleted == 0 && messagesArr[indexPath.row].chatType == 0{
            return cell
        }else if messagesArr[indexPath.row].messageType == 2 &&  messagesArr[indexPath.row].isDeleted == 0 && messagesArr[indexPath.row].chatType == 0{
            return cellFile
        }else if messagesArr[indexPath.row].chatType == 1 &&  messagesArr[indexPath.row].isDeleted == 0 ||  messagesArr[indexPath.row].chatType == 1 &&  messagesArr[indexPath.row].isDeleted == nil{
            return replyCell
        }
        
        return cell2
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell")
        cell?.imageView?.kf.cancelDownloadTask()
    }
    //Tutoril
    func hideDeleteBtn(){
        tapPressGesture.isEnabled = false
        longPressGesture.isEnabled = false
        delateMsgBtn.isEnabled = false
        delateMsgBtn.tintColor = .clear
        longPressGesture.isEnabled = true
        let cells = selectedCells
        selectedCells = []
        for index in cells{
            let indexPosition = IndexPath(row: index, section: 0)
            self.tableView.reloadRows(at: [indexPosition], with: .middle)
        }
    }
    
    func showDeleteBtn(){
        tapPressGesture.isEnabled = false
        longPressGesture.isEnabled = true
        delateMsgBtn.isEnabled = false
        delateMsgBtn.tintColor = .clear
    }
    //MARK: Download image form url
    func downloadFile(indexPath: IndexPath) {
       var sent = true
        if GlobalVar.userINFO?[0]._id != self.messagesArr[indexPath.row].senderId?._id{
            sent = false
        }
        DownloadData.sharedInstance.download(isImage: false, isSent: sent, name: self.messagesArr[indexPath.row].message)
        }
 
    func getDate(date:String) -> String{
        let today = Date()
        let finalDate = date.UTCToLocal(incomingFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", outGoingFormat: "MMM d, yyyy h:mm a")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy h:mm a"
        let msgDate = dateFormatter.date(from: finalDate)

        dateFormatter.dateFormat = "dd-MM-yyyy"
        let dateString = dateFormatter.string(from: msgDate!)
        dateFormatter.dateFormat = "h:mm a"
        let timeString = dateFormatter.string(from: msgDate!)
        let diff = today.interval(ofComponent: .day, fromDate: msgDate!)
        if diff == 0{
            return timeString
        }else if diff == 1 {
            return "Yesterday \(timeString)"
        }
        return dateString
    }
    
    @objc func handleLongPress(longPressGesture: UILongPressGestureRecognizer) {
        if longPressGesture.state == UIGestureRecognizer.State.ended {
             let p = longPressGesture.location(in: self.tableView)
                    let indexPath = self.tableView.indexPathForRow(at: p)
            let cell = self.tableView.cellForRow(at: indexPath!)
                    if indexPath != nil{
                        if let index = selectedCells.firstIndex(of: indexPath!.row) {
                            selectedCells.remove(at: index)
                            cell?.contentView.backgroundColor = .clear
                        }else{
                            selectedCells.append(indexPath!.row)
                            cell?.contentView.backgroundColor = .blue
                        }
                         self.tapPressGesture.isEnabled = true
                    }
           // print(selectedCells)
           self.tapPressGesture.isEnabled = true
            self.delateMsgBtn?.isEnabled = true
            self.delateMsgBtn.tintColor = .white
            if selectedCells.count == 0 || selectedCells == nil{
                cell?.contentView.backgroundColor = .clear
                self.tapPressGesture.isEnabled = true
                self.navigationItem.rightBarButtonItem = nil
            }
        }
    }
    
        @objc func handleTap(tapGesture: UITapGestureRecognizer) {
             if tapGesture.state == UIGestureRecognizer.State.ended {
            let p = tapGesture.location(in: self.tableView)
            let indexPath = self.tableView.indexPathForRow(at: p)
            let cell = self.tableView.cellForRow(at: indexPath!)
            if indexPath != nil{
                if let index = selectedCells.firstIndex(of: indexPath!.row) {
                    selectedCells.remove(at: index)
                    cell?.contentView.backgroundColor = .clear
                }else{
                    selectedCells.append(indexPath!.row)
                    cell?.contentView.backgroundColor = .blue
                }
                self.tapPressGesture.isEnabled = true
            }
                print(selectedCells)
            self.tapPressGesture.isEnabled = true
       
                self.delateMsgBtn.isEnabled = true
                self.delateMsgBtn.tintColor = .white
            if selectedCells.count == 0 || selectedCells == nil{
                cell?.contentView.backgroundColor = .clear
                self.tapPressGesture.isEnabled = false
                self.navigationItem.rightBarButtonItem = nil
            }
        }
    }

    @objc func keyboardWillHide(_ sender: Notification) {
        stopTyping()
      if let userInfo = (sender as NSNotification).userInfo {
        if ((userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height) != nil {
            
          
                if self.view.frame.origin.y != 0 {
                    self.view.frame.origin.y = 0
                if self.messagesArr.count < 5{
                self.tableView.frame.origin.y = 50
                    }
                }
//          self.inputContainerViewBottom.constant =  0
//            self.tableviewBottomConstaint.constant = 0
//            //self.tableView.frame.origin.y = 50
//            self.msgText.frame.origin.y = 1
//            self.sendBtn.frame.origin.y = 1
//          UIView.animate(withDuration: 0.25, animations: { () -> Void in self.view.layoutIfNeeded() })
        }
      }
    }
    @objc func keyboardWillShow(_ sender: Notification) {
        hideDeleteBtn()
      if let userInfo = (sender as NSNotification).userInfo {
        
        if let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
                if self.messagesArr.count < 5{
                    self.tableView.frame.origin.y = 340
                }
            }
        }
//        if let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
//            let origin = self.view.frame.origin.y - keyboardHeight + 60
//            if isReply{
//               // self.tableView.frame.origin.y = origin + 35
//                self.tableviewBottomConstaint.constant = origin + 35
//            }else{
//                self.tableView.frame.origin.y = origin
//            }
//            if self.messagesArr.count > 0{
//                self.tableView.scrollToBottom()
//            }
//            self.sendBtn.frame.origin.y -= keyboardHeight
//            self.msgText.frame.origin.y -= keyboardHeight
//            UIView.animate(withDuration: 0.25, animations: { () -> Void in
//            self.view.layoutIfNeeded()
//          })
       // }
      }
    }
}
//   MARK: Send Files/Images
extension MessaageVC: SwipyCellDelegate{
    func swipyCellDidStartSwiping(_ cell: SwipyCell) {
        print("Swiping")}
    
    func swipyCellDidFinishSwiping(_ cell: SwipyCell, atState state: SwipyCellState, triggerActivated activated: Bool) {
        print("finish swip")
        isReply = true
        self.replyView.isHidden = false
    }
    func swipyCell(_ cell: SwipyCell, didSwipeWithPercentage percentage: CGFloat, currentState state: SwipyCellState, triggerActivated activated: Bool) {
        print(state)}
    func configureCell(_ cell: SwipyCell, forRowAtIndexPath indexPath: IndexPath) {
        let checkView = viewWithImageName("reply")
        let clearColor = UIColor.gray
        cell.delegate = self
            cell.addSwipeTrigger(forState: .state(0, .left), withMode: .toggle, swipeView: checkView, swipeColor: clearColor, completion: { cell, trigger, state, mode in
                //print("Did swipe \"Checkmark\" cell")
                self.isReply = true
                print(self.messagesArr[indexPath.row])
                self.commentMessage.insert(self.messagesArr[indexPath.row], at: 0)
                if self.messagesArr[indexPath.row].isDeleted == 1{
                     self.msgReplyLbl.text = "Message Deleted"
                }else{
                    self.msgReplyLbl.text = self.messagesArr[indexPath.row].message
                }
                if self.msgSenderId == self.messagesArr[indexPath.row].senderId?._id{
                    self.nameReplyLbl.text = self.friendName
                }else{
                     self.nameReplyLbl.text = "You"
                }
                if self.messagesArr.count > 0{
                    self.tableView.scrollToBottom()
                }
            })
    }
    
    func viewWithImageName(_ imageName: String) -> UIView {
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .center
        return imageView
    }
    
    @IBAction func deleteMessagesBtn(_ sender: UIButton){
        
        for index in selectedCells{
            self.messagesArr[index].isDeleted = 1
            self.hideDeleteBtn()
            DatabaseManager.sharedInstance.DeleteMessage(messageObj: messagesArr[index], msgSenderId: self.msgSenderId) { (message) in
                if message!{
                let indexPosition = IndexPath(row: index, section: 0)
                self.tableView.reloadRows(at: [indexPosition], with: .middle)
                }else{
                    self.view.makeToast("Internet Disconnected Msg Deletion")
                }
            }
        }
    }
}

//   MARK: Send Files/Images
extension MessaageVC{
    
    @IBAction func showAlert(sender: AnyObject) {
        hideDeleteBtn()
        let alert = UIAlertController(title: "Add", message: "Please Select an Option", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: " Image", style: .default , handler:{ (UIAlertAction)in
            print("User click Approve button")
            self.isDocument = false
            self.pickImage()
        }))
        alert.addAction(UIAlertAction(title: "Document", style: .default , handler:{ (UIAlertAction)in
            print("User click Edit button")
            self.folderAction()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default , handler:{ (UIAlertAction)in
            alert.dismiss(animated: true, completion: nil)
        }))
        //self.presentingViewController
        self.present(alert, animated: true, completion: nil)
    }
    //MARK: Pick Image from Gallery
    func pickImage() {
        
        let pickerViewController = YMSPhotoPickerViewController.init()
        pickerViewController.numberOfPhotoToSelect = 5
        let customColor = UIColor.init(red:248.0/255.0, green:217.0/255.0, blue:44.0/255.0, alpha:1.0)
        pickerViewController.theme.titleLabelTextColor = UIColor.black
        pickerViewController.theme.navigationBarBackgroundColor = customColor
        pickerViewController.theme.tintColor = UIColor.black
        pickerViewController.theme.orderTintColor = customColor
        pickerViewController.theme.orderLabelTextColor = UIColor.black
        pickerViewController.theme.cameraVeilColor = customColor
        pickerViewController.theme.cameraIconColor = UIColor.white
        pickerViewController.theme.statusBarStyle = .default
        self.yms_presentCustomAlbumPhotoView(pickerViewController, delegate: self)
    }
}
//MARK: Documents Pickers
extension MessaageVC: UIDocumentPickerDelegate{
    
    public func folderAction(){
        var types: [String] = [kUTTypePDF as String]
        types.append(kUTTypeText as String)
        types.append(kUTTypeJSON as String)
        types.append(kUTTypeFolder as String)
        types.append(kUTTypeDirectory as String)
        types.append(kUTTypePDF as String)
        types.append(kUTTypeContent as String)
        types.append(kUTTypeData as String)
        types.append(kUTTypeItem as String)
        types.append(kUTTypeZipArchive as String)
        self.pickerController = UIDocumentPickerViewController(documentTypes: types, in: .open)
            self.pickerController!.delegate = self
            self.present(self.pickerController!, animated: true)
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            return
        }
         self.view.makeToast("Sending File")
        documentFromURL(pickedURL: url)
        print(urls[urls.count - 1])
        DatabaseManager.sharedInstance.sendFile(receiverId: msgSenderId, document: documents[documents.count - 1], docName: documents[documents.count - 1].fileURL.lastPathComponent, filesurl: urls[urls.count - 1]) { (isSent) in
            if isSent{
                self.view.makeToast("File Sent")
            }
        }
    }
    private func documentFromURL(pickedURL: URL) {
        let shouldStopAccessing = pickedURL.startAccessingSecurityScopedResource()
        
        defer {
            if shouldStopAccessing {
                pickedURL.stopAccessingSecurityScopedResource()
            }
        }
        NSFileCoordinator().coordinate(readingItemAt: pickedURL, error: NSErrorPointer.none) { (folderURL) in
            do {
               let keys: [URLResourceKey] = [.nameKey, .isDirectoryKey]
               let fileList = try FileManager.default.enumerator(at: pickedURL, includingPropertiesForKeys: keys)
                let document = Document(fileURL: pickedURL)
                documents.append(document)
                switch sourceType {
                    case .files:
                        let document = Document(fileURL: pickedURL)
                        documents.append(document)
                    case .folder:
                        for case let fileURL as URL in fileList! {
                            if !fileURL.isDirectory {
                                let document = Document(fileURL: fileURL)
                                    documents.append(document)
                                }
                            }
                    case .none:
                        break
                    }
                } catch let error {
                            self.view.makeToast("Eorror in Sending File")
                            print("error: ", error.localizedDescription)
                    }
            }
    }
    
}

//Image Picker
extension MessaageVC: YMSPhotoPickerViewControllerDelegate{
    
    // MARK: - YMSPhotoPickerViewControllerDelegate
       func photoPickerViewControllerDidReceivePhotoAlbumAccessDenied(_ picker: YMSPhotoPickerViewController!) {
           let alertController = UIAlertController.init(title: "Allow photo album access?", message: "Need your permission to access photo albumbs", preferredStyle: .alert)
           let dismissAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
           let settingsAction = UIAlertAction.init(title: "Settings", style: .default) { (action) in
            UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!)
           }
           alertController.addAction(dismissAction)
           alertController.addAction(settingsAction)
           self.present(alertController, animated: true, completion: nil)
       }

       func photoPickerViewControllerDidReceiveCameraAccessDenied(_ picker: YMSPhotoPickerViewController!) {
           let alertController = UIAlertController.init(title: "Allow camera album access?", message: "Need your permission to take a photo", preferredStyle: .alert)
           let dismissAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
           let settingsAction = UIAlertAction.init(title: "Settings", style: .default) { (action) in
            UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!)
           }
           alertController.addAction(dismissAction)
           alertController.addAction(settingsAction)
           picker.present(alertController, animated: true, completion: nil)
       }

       func photoPickerViewController(_ picker: YMSPhotoPickerViewController!, didFinishPicking image: UIImage!) {
           picker.dismiss(animated: true) {
               self.images = [image]
            self.isImage = true
            self.collectionView.reloadData()
            self.collectionView.isHidden = false
           }
       }
       func photoPickerViewController(_ picker: YMSPhotoPickerViewController!, didFinishPickingImages photoAssets: [PHAsset]!) {

           picker.dismiss(animated: true) {
               let imageManager = PHImageManager.init()
               let options = PHImageRequestOptions.init()
               options.deliveryMode = .highQualityFormat
               options.resizeMode = .exact
               options.isSynchronous = true

               let mutableImages: NSMutableArray! = []
               for asset: PHAsset in photoAssets
               {
                self.imageName.append(asset.originalFilename)
                   let targetSize = CGSize(width: 80 , height: 78)
                   imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options, resultHandler: { (image, info) in
                       mutableImages.add(image!)
                   })
               }
            self.isImage = true
            self.images = mutableImages.copy() as? NSArray as! [UIImage]
               self.collectionView.reloadData()
            self.collectionView.isHidden = false
           }
       }
}
extension MessaageVC: UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return self.images.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for:indexPath) as! MessageImageCell
        cell.imageView!.image =  self.images[indexPath.row]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize{
         return CGSize(width: 80, height:collectionView.bounds.height)
     }
}
// MARK: Functions/Typing/Title
extension MessaageVC{
    
    func typingResponse(data:Any , typing:Bool){
        if case Optional<Any>.none = data {
                       }else{
                       do{
                       let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                           let decoder = JSONDecoder()
                           do{
                           let json = try decoder.decode([TypingResponse].self, from: jsonData!)
                               print(json)
                let  usersObject = json[0]
             if usersObject.UserId == self.msgSenderId && GlobalVar.userINFO![0]._id == usersObject.selectFrienddata._id{
                var response = ""
                if typing{
                    self.navigationItem.titleView =  navTitleWithImageAndText(titleText: friendName, subTitleText: "Typing....", imageName: "pro1")
                    response = "    Typing...."
                }else{
                    self.navigationItem.titleView =  navTitleWithImageAndText(titleText: friendName, subTitleText: "Last Seen 10:00", imageName: "pro1")
                    response = " Enter Some text to Send"
                }
//                self.msgText?.placeholderAttributedText = NSAttributedString(
//                        string: response, attributes: [
//                                    .font: self.msgText.textView.font!,
//                        .foregroundColor: UIColor.gray])
                }
            }
           }catch let error as NSError{print(error)
        }
       }
    }
}
//MARK: Send Start/Stop Typing Response on socket
extension MessaageVC: replyDelegate {
    @objc func startTyping() {
        SocketIOManager.sharedInstance.StartTyping(message: JSONSendData.sharedInstance.typing(msgSenderId: msgSenderId) )
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(stopTyping), userInfo: nil, repeats: false)
    }
    
    @objc func stopTyping() {
        SocketIOManager.sharedInstance.StopTyping(message: JSONSendData.sharedInstance.typing(msgSenderId: msgSenderId))
    }
    
    @IBAction func replyCancel(_ sender: UIButton){
        self.replyView.isHidden = true
        isReply = false
    }
    
    func replyMsgBtn(indexPath: IndexPath) {
        let index = self.messagesArr.firstIndex{$0._id == self.messagesArr[indexPath.row].commentId?._id}
               if let searchIndex = index{
                let indexPath = IndexPath(item: searchIndex, section: 0)
                //tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
                //tableView.row
                tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                   }else{
               //print(error!)
           }
       }
}





