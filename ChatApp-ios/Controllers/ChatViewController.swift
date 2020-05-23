
import UIKit
import Firebase

class ChatViewController: UIViewController {
    
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var userName: UILabel!
    @IBOutlet weak var messageTextfield: UITextField!
    
    var messageSentFor = String()
    var oneOfThesenderorReciever = String()
    let db = Firestore.firestore()
    
    var usersDict = [String: String]()
    var messages = [Message]()
    var messageForParticularPerson = [Message]()
    //let profilePic = dp()
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        profilePicture.layer.cornerRadius = profilePicture.frame.size.height / 2
        userName.text = oneOfThesenderorReciever
        navigationItem.title = K.appname
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        loadProfilePic()
        loadMessages()
    }
    
    func loadProfilePic(){
        var profilePicUrl = String()
        db.collection("UsersList").getDocuments { (querySnapshot, error) in
            if error != nil{
                print(error)
            }else{
                if let snapShotDocuments = querySnapshot?.documents{
                    for doc in snapShotDocuments{
                        let data = doc.data()
                        if data["email"] as? String == self.oneOfThesenderorReciever{
                            if data["profilePictureUrl"] != nil{
                                profilePicUrl = (data["profilePictureUrl"] as? String)!
                                break
                            }else{
                                profilePicUrl = "Not Available"
                                break
                            }
                        }
                    }
                    if profilePicUrl != "Not Available" {
                        if let url = URL(string: profilePicUrl ){
                            
                            //MARK:- 2>CREATE A URLSession
                            let session = URLSession(configuration: .default)
                            
                            //MARK:- 3>GIVE the session a task
                            let task = session.dataTask(with: url) { (data, response, error) in
                                if error != nil{
                                    print(error)
                                    return
                                }
                                DispatchQueue.main.async {
                                    self.profilePicture.image = UIImage(data: data!)
                                    
                                }
                            }
                            
                            //MARK:- 4>Start the Task
                            task.resume()
                        }
                    }else{
                        print("No DP")
                    }
                    
                }
            }
        }
    }
    
    
    
    
    func loadMessages() {
        messages = []
        db.collection(K.FStore.collectionName).order(by: K.FStore.dateField).addSnapshotListener{ (querySnapshot, error) in
            self.messages = []
            if let e = error{
                print("There was isssue retrieving data from firestore")
            }else{
                if let snapshotDocuments = querySnapshot?.documents{
                    for doc in snapshotDocuments{
                        let data = doc.data()
                        if let messageSender = data[K.FStore.senderField] as? String,let messageBody = data[K.FStore.bodyField] as? String,let messageReciever = data["Reciever"] as? String{
                            let newMessage = Message(sender: messageSender, body: messageBody, reciever: messageReciever)
                            if (newMessage.sender == Auth.auth().currentUser?.email && newMessage.reciever == self.oneOfThesenderorReciever) || (newMessage.reciever == Auth.auth().currentUser?.email && newMessage.sender == self.oneOfThesenderorReciever){
                                self.messages.append(newMessage)
                                
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                    let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func sendPressed(_ sender: UIButton) {
        if messageTextfield.text != ""{
            if let messageBody =  messageTextfield.text, let messageSender = Auth.auth().currentUser?.email{
                db.collection(K.FStore.collectionName).addDocument(data: [K.FStore.senderField: messageSender, K.FStore.bodyField: messageBody, K.FStore.dateField: Date().timeIntervalSince1970, "Reciever": oneOfThesenderorReciever]) { (error) in
                    if let e = error{
                        print("There was an issue saving data on firestore!")
                    }else{
                        print("Successfully Saved Data")
                        DispatchQueue.main.async {
                            self.messageTextfield.text = ""
                        }
                    }
                }
            }
        }
    }
    @IBAction func logOut(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            print("Logged Out")
            navigationController?.popToRootViewController(animated: true)
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
}
extension ChatViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        cell.label.text = message.body
        print(message.reciever)
        if message.sender == Auth.auth().currentUser?.email && message.reciever == oneOfThesenderorReciever{
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: K.BrandColors.purple)
        }else if message.reciever == Auth.auth().currentUser?.email && message.sender == oneOfThesenderorReciever{
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.label.textColor = UIColor(named: K.BrandColors.lightPurple)
        }
        cell.backgroundColor = .clear
        return cell
    }
}


