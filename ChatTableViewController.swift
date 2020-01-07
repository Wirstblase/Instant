//
//  ChatTableViewController.swift
//  Instant
//
//  Created by Marius Suflea on 12/11/2019.
//  Copyright © 2019 Marius Suflea. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

var globalcontinut = ""
var globalcommentarray = ["", ""]

let globalUserID = Auth.auth().currentUser?.uid

struct Conversation{
    var image : String
    var name : String
    var content : String
    var data : Date
    var id : String
    
    
    var dictionary:[String:Any]{
        return [
            "name" : name,
            "image" : image,
            "content" : content,
            "data" : data,
            "id" : id
        ]
    }
}

var activeConversation = ""
var activeConversationID = ""

class ChatTableViewController: UITableViewController {
    
    var conversationArray = [Conversation]()
    
    @IBAction func newChat(_ sender: Any) {
        
        
        
    }
    
    var db:Firestore!
    
    
    /*func getData(id: String){
        
        
        let docRef = self.db.collection("users").document("\(id)")
        
        
        docRef.getDocument { (document1, error) in
            if let document1 = document1, document1.exists {
                
                let doccdata = document1.data() as! [String: Any]
                
                self.nameVar = doccdata["username"] as? String ?? ""
                self.imageVar = doccdata["profileimage"] as? String ?? ""
                
                print("IMAGEVAR")
                print(self.imageVar)
                print("NAMEVAR")
                print(self.nameVar)
                
                
                //print("Document data!!: \(dataDescription)")
            } else {
                print("ERROR ERROR ERROR!!")
            }
        }
    }*/
    
    func Update(){
        
    
        db.collection("users/\(globalUserID!)/CHATS")/*.whereField("", isEqualTo: true)*/.getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    var index = 0
                    
                    for document in querySnapshot!.documents {
                        index = index+1
                        print(index)
                        
                        
                        let docdata = document.data() as [String : Any]
                        let contentVar = docdata["lastMessage"] as? String ?? ""
                        let nameVar = docdata["nickname"] as? String ?? ""
                        let imageVar = docdata["profileimage"] as? String ?? ""
                        self.conversationArray.append(Conversation( image: imageVar, name: nameVar,content: contentVar,data: Date(), id: document.documentID ))
                        print(self.conversationArray)
                        
                        //self.conversationArray[index].name = docdata["name"] as? String ?? ""
                        self.tableView.reloadData()
                        
                    }
                    
                    
                   
                }
        }
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        Update()
        
        //conversationArray.append(Conversation( image: "image", name: "TEST",content: "content",data: Date() ))
        //conversationArray.append(Conversation( image: "image", name: "TEST2",content: "content",data: Date() ))
        
        tableView.reloadData()
        
        tableView.delegate = self
        tableView.dataSource = self

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversationArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableViewCell", for: indexPath) as! ChatTableViewCell
        
        let message = conversationArray[indexPath.row]
        //cell.usernamelabel.text = post.name
        cell.cellNameLabel.text = message.name
        cell.cellLastMessageLbl.text = message.content
        let url = NSURL(string: message.image)
        cell.cellImageView.load(url: url! as URL)
        cell.cellImageViewView.layer.cornerRadius = 30
        cell.cellView.layer.cornerRadius = 20
        

        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        print("selected")
        performSegue(withIdentifier: "enterConvo", sender: self)
        activeConversation = conversationArray[indexPath.row].name
        activeConversationID = conversationArray[indexPath.row].id
        print (activeConversation)
        
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
    }
    

}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

