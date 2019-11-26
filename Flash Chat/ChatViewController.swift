
import UIKit
import Firebase
import SVProgressHUD
import ChameleonFramework

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // instance variables
    var messageArray: [Message] = [Message]()
    
    // IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set self as the delegate and datasource
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        //Set self as the delegate of the text field
        messageTextfield.delegate = self
        
        //Set the tapGesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)

        //Register your MessageCell.xib file
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        configureTableView()
        retrieveMessages()
        
        messageTableView.separatorStyle = .none
    }
    
    //MARK: - TableView DataSource Methods
    
    // cellForRowAtIndexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        
        if cell.senderUsername.text == Auth.auth().currentUser?.email {
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
        } else {
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatGray()
        }
        
        return cell
    }
    
    // numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    // yableViewTapped
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true)
    }
    
    // configureTableView
    func configureTableView() {
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    //MARK:- TextField Delegate Methods
    
    // textFieldDidBeginEditing
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 308
            self.view.layoutIfNeeded()
        }
    }
    
    // textFieldDidEndEditing
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }

    
    //MARK: - Send & Recieve from Firebase
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        messageTextfield.endEditing(true)
        
        // Send the message to Firebase and save it in our database
        
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        let messageDB = Database.database().reference().child("Messages")
        let messageDict = ["Sender": Auth.auth().currentUser?.email!, "MessageBody": messageTextfield.text! ]
        
        messageDB.childByAutoId().setValue(messageDict) {
            (error, reference) in
            if error != nil {
                print(error!)
            } else {
                print("Message saved successfuly!")
                self.sendButton.isEnabled = true
                self.messageTextfield.isEnabled = true
                self.messageTextfield.text = ""
            }
        }
    }
    
    //retrieveMessages method
    func retrieveMessages() {
        
        let messageDB = Database.database().reference().child("Messages")
        
        messageDB.observe(.childAdded) {
            (snapshot) in
            
            let snapshotValue = snapshot.value as! Dictionary<String, String>
            
            if snapshotValue["MessageBody"] != nil && snapshotValue["Sender"] != nil{
                
                let text = snapshotValue["MessageBody"]!
                let sender = snapshotValue["Sender"]!
                let message = Message()
                message.messageBody = text
                message.sender = sender
                self.messageArray.append(message)
                
                self.configureTableView()
                self.messageTableView.reloadData()
            }
        }
    }
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        //Log out the user and send them back to WelcomeViewController
        do {
            try Auth.auth().signOut()
            print("Logged out")
            navigationController?.popToRootViewController(animated: true)
            
        } catch {
            print("error, there was a problem signig out.")
        }
        
    }
    
}
