//
//  activeChatTableViewController.swift
//  Instant
//
//  Created by Suflea Marius on 14/11/2019.
//  Copyright © 2019 Marius Suflea. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

struct Message{
    var type : Int // 0 - received , 1 - sent
    var contentType : Int // 0 - text , 1 - image , 2 - file
    var content : String
    var data : String
    var readStatus : Bool
    var sender : String
    
    var dictionary:[String:Any]{
        return [
            "type" : type,
            "contentType" : contentType,
            "content" : content,
            "data" : data,
            "readStatus" : readStatus,
            "sender": sender
        ]
    }
}

class activeChatTableViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var messageArray = [Message]()
    
    @IBOutlet weak var messageBar: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageInputView: UIView!
    @IBOutlet weak var messageInputField: UITextView! // broken
    @IBOutlet weak var inputField: UITextView!
    
    func newMessage(){
        let dataString = Date().toString(dateFormat: "yyyy-MM-dd HH:mm:ss") //functioon not used hopefully
        // Add a new document with a generated id.
        var ref: DocumentReference? = nil
        ref = db.collection("users/\(globalUserID!)/CHATS/\(activeConversationID)/CHAT/").addDocument(data: [
            "type": 0,
            "contentType": 0,
            "content" : "TEST TEST TEST YOO",
            "data" : dataString,
            "readStatus" : false,
            "sender" : String(globalUserID ?? "error")
            
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
        
    }
    @IBOutlet var popOverView: UIView!
    
    private func showPopup(_ controller: UIViewController, sourceView: UIView) {
        let presentationController = AlwaysPresentAsPopover.configurePresentation(forController: controller)
        presentationController.sourceView = sourceView
        presentationController.sourceRect = sourceView.bounds
        presentationController.permittedArrowDirections = [.down, .up]
        self.present(controller, animated: true)
    }
    
    
    @IBAction func displayPopover(_ sender: UIButton) {
        /*let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "popoverViewController")
        modalPresentationStyle = .popover
        let popover: UIPopoverPresentationController = vc.popoverPresentationController!
        popover.barButtonItem = sender as? UIBarButtonItem
        present(vc, animated: true, completion:nil)
        */
        
        
        //self.view.addSubview(popOverView)
        //popOverView.center = self.view.center
        /*let controller = storyboard!.instantiateViewController(withIdentifier: "popoverViewController")/* create UIViewController here */
            controller.modalPresentationStyle = .popover
        controller.preferredContentSize = CGSize(width: 300, height: 200)
        let presentationController = controller.presentationController as! UIPopoverPresentationController
        presentationController.sourceView = sender
        presentationController.sourceRect = sender.bounds
        presentationController.permittedArrowDirections = [.down, .up]
        self.present(controller, animated: true)*/
        
        let controller = storyboard!.instantiateViewController(withIdentifier: "popoverViewController")/* create UIViewController here */
            controller.preferredContentSize = CGSize(width: 150, height: 200)
        showPopup(controller, sourceView: sender)
        
    }
    
    //NEW MESSAGE, DEPRECATED METHOD
    @IBAction func sendBtnPress(_ sender: Any) {
        
        if(inputField.text != ""){
        
        let dataString = Date().toString(dateFormat: "yyyy-MM-dd HH:mm:ss")
        var ref: DocumentReference? = nil
        ref = db.collection("users/\(globalUserID!)/CHATS/\(activeConversationID)/CHAT/").addDocument(data: [
            "type": 0,
            "contentType": 0,
            "content" : inputField.text ?? "empty message",
            "data" : dataString,
            "readStatus" : false,
            "sender" : String(globalUserID ?? "error")
            
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
        ref = db.collection("users/\(activeConversationID)/CHATS/\(globalUserID!)/CHAT/").addDocument(data: [
            "type": 0,
            "contentType": 0,
            "content" : inputField.text ?? "empty message",
            "data" : dataString,
            "readStatus" : false,
            "sender" : String(globalUserID ?? "error")
            
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
        Update()
        inputField.text = ""
            
        }
    }
    
    
    var db:Firestore!
    
    func Update(){
            messageArray.removeAll()
        db.collection("users/\(globalUserID!)/CHATS/\(activeConversationID)/CHAT/")/*.whereField("", isEqualTo: true)*/.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                var index = 0
                
                for document in querySnapshot!.documents {
                    index = index+1
                    print(index)
                    //print("\(document.documentID) => \(document.data())")
                    let docdata = document.data() as [String : Any]
                    let typeVar = docdata["type"] as? Int ?? 0
                    let contentType = docdata["contentType"] as? Int ?? 0
                    let contentVar = docdata["content"] as? String ?? ""
                    let readVar = docdata["readStatus"] as? Bool ?? false
                    let sender = docdata["sender"] as? String ?? "error"
                    let dataVar = docdata["data"] as? String ?? "ERROR"
                    self.messageArray.append(Message(type: typeVar, contentType: contentType, content: contentVar, data: dataVar, readStatus: readVar,sender: sender))
                    //self.conversationArray[index].name = docdata["name"] as? String ?? ""
                    self.tableView.reloadData()
                    self.sortMessages()
                    if(self.messageArray.count != 0){
                    self.tableView.scrollToBottom()
                    }
                }
                if(self.messageArray.count != 0){
                self.tableView.scrollToBottom()
                }
            }
        }
    }
    
    
        
        
    func sortMessages(){
            messageArray = messageArray.sorted(by: {
                $0.data.compare($1.data) == .orderedAscending
            })
        //var messageArray2 = messageArray
        print("DATES:")
        for x in messageArray{
            print(x.data)

        }
        
        
    }
    
    func cornerRadius(){
        messageInputView.layer.cornerRadius = 15
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNeedsStatusBarAppearanceUpdate()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        db = Firestore.firestore()
        
        //newMessage()
        
        //self.messageArray.append(Message(type: 0, contentType: 0, content: "Hello darkness my old friend I've come to talk with you again", data: Date(), readStatus: false))
        
        //self.messageArray.append(Message(type: 1, contentType: 0, content: "Hii!!!", data: Date(), readStatus: false))
        
        Update()
        cornerRadius()
        sortMessages()
        
        //self.messageArray.append(Message(type: 1, contentType: 0, content: "yoo", data: Date(), readStatus: false))
        
        self.navigationItem.title = activeConversation
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            //if(self.messageBar.frame.origin.y != 0){
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
                //self.messageBar.frame.origin.y -= keyboardSize.height
            }
            if(self.messageArray.count != 0){
                self.tableView.scrollToBottom()
            }
            //if self.tableView.frame.origin.y == 0{
            //self.tableView.frame.origin.y -= keyboardSize.height
            //}
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        //if(self.messageBar.frame.origin.y != 0){
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
            //self.messageBar.frame.origin.y = 0
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self.view.window)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width - 30
        
        if(messageArray[indexPath.row].type == 1)
        {
            return screenWidth
        }
        else {
        return UITableView.automaticDimension
        //return 40
        }
        
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "activeChatCell", for: indexPath) as! activeChatTableViewCell
        
        cell.receivedView.layer.cornerRadius = 17
        cell.sentView.layer.cornerRadius = 17
        
        if(messageArray[indexPath.row].sender == activeConversationID){ //received //.type == 0
            cell.sentView.isHidden = true
            cell.receivedView.isHidden = false
        } else if(messageArray[indexPath.row].sender == globalUserID) { //sent
            cell.sentView.isHidden = false
            cell.receivedView.isHidden = true
        }
        
        if(messageArray[indexPath.row].contentType == 0){ // text
            cell.receivedImage.isHidden = true
            cell.sentImage.isHidden = true
            
            cell.receivedText.isHidden = false
            cell.sentText.isHidden = false
            
            cell.receivedText.text = messageArray[indexPath.row].content
            cell.sentText.text = messageArray[indexPath.row].content
        } else if(messageArray[indexPath.row].contentType == 1){ // photo
            cell.receivedImage.isHidden = false
            cell.sentImage.isHidden = false
            
            cell.receivedText.isHidden = true
            cell.sentText.isHidden = true
            
            let imageLink = NSURL(string: messageArray[indexPath.row].content)
            cell.receivedImage.load(url: imageLink! as URL)
            cell.sentImage.load(url: imageLink! as URL)
        }
        
        //print(messageArray[indexPath.row].content)

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
}
extension UITableView {
    
    func scrollToBottom(){
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(
                row: self.numberOfRows(inSection:  self.numberOfSections - 1) - 1,
                section: self.numberOfSections - 1)
            self.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func scrollToTop() {
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            self.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
}
class AlwaysPresentAsPopover : NSObject, UIPopoverPresentationControllerDelegate {
    
    // `sharedInstance` because the delegate property is weak - the delegate instance needs to be retained.
    private static let sharedInstance = AlwaysPresentAsPopover()
    
    private override init() {
        super.init()
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    static func configurePresentation(forController controller : UIViewController) -> UIPopoverPresentationController {
        controller.modalPresentationStyle = .popover
        let presentationController = controller.presentationController as! UIPopoverPresentationController
        presentationController.delegate = AlwaysPresentAsPopover.sharedInstance
        return presentationController
    }
    
}
