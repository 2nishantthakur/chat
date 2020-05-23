
import UIKit
import Firebase


class ChatsViewController: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //navigationItem.hidesBackButton = true
        print(Auth.auth().currentUser?.email!)
        //navigationItem.title = "Chats"
       }
    override func viewWillDisappear(_ animated: Bool) {
        print("ciewWillDisappera")
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    let db = Firestore.firestore()
    var users = [String]()
    var usersDict = [String: String]()
    var temp = 0
    
    @IBOutlet var fullScreenButton: UIButton!
    @IBOutlet var moreOptions: UIView!
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        fullScreenButton.isEnabled = false
        moreOptions.isHidden = true
        moreOptions.layer.cornerRadius = moreOptions.frame.size.height / 10
        navigationController?.navigationBar.isHidden = true
        loadUsers()
        tableView.register(UINib(nibName: "UsersList", bundle: nil), forCellReuseIdentifier: "cell")
        print("x")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func fullScreenButton(_ sender: Any) {
        
            setView(view: moreOptions, hidden: true)
            fullScreenButton.isEnabled = false
            fullScreenButton.isHidden = true
    }
    @IBAction func moreButtonPressed(_ sender: Any) {
        setView(view: moreOptions, hidden: false)
        fullScreenButton.isEnabled = true
        fullScreenButton.isHidden = false
    }
    
    //MARK:- Animating Hiding Of View
    
    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }
    func loadUsers(){
        users = []
        var email = String()
        var temp2 = 0
        db.collection(K.FStore.collectionName).addSnapshotListener{ (querySnapshots, error) in
            if let querySnapshotDocument = querySnapshots?.documents{
                for doc in querySnapshotDocument{
                    
                    let data = doc.data()
                    if  data["Reciever"] as? String == Auth.auth().currentUser?.email! || data[K.FStore.senderField] as? String == Auth.auth().currentUser?.email!{
                        self.temp = 0
                        for userEmail in self.users{
                            if userEmail == data["Reciever"] as? String || userEmail == data[K.FStore.senderField] as? String{
                                self.temp += 1
                            }
                            
                        }
                        if self.temp == 0{
                            
                            if data[K.FStore.senderField] as? String == Auth.auth().currentUser?.email{
                                email = (data["Reciever"] as? String)!
                                self.users.append(data["Reciever"] as! String)
                                print(self.users)
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                            }else{
                                email = (data[K.FStore.senderField] as! String)
                                self.users.append(data[K.FStore.senderField] as! String)
                                print(self.users)
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                            }
                            self.db.collection("UsersList").getDocuments { (querySnapshot, error) in
                                if error != nil{
                                    print(error)
                                }else{
                                    
                                    if let snapshotDocument = querySnapshot?.documents{
                                        for doc in snapshotDocument{
                                            let data = doc.data()
                                            if data["email"] as? String == self.users[temp2]{
                                                
                                                print(data["email"])
                                                if data["profilePictureUrl"] != nil{
                                                    self.usersDict[self.users[temp2]] = data["profilePictureUrl"] as? String
                                                    
                                                }else{
                                                    self.usersDict[self.users[temp2]] = "Not Available"
                                                    
                                                }
                                                print(self.usersDict)
                                                DispatchQueue.main.async {
                                                    self.tableView.reloadData()
                                                }
                                            }
                                            
                                            
                                        }
                                        temp2 += 1
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
extension ChatsViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersDict.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UsersList
        cell.UserEmail.text = users[indexPath.row]
        cell.backgroundColor = .clear
        if usersDict[users[indexPath.row]] != "Not Available"{
            if let url = URL(string: ((usersDict[users[indexPath.row]] as? String)! )){
                
                //MARK:- 2>CREATE A URLSession
                let session = URLSession(configuration: .default)
                
                //MARK:- 3>GIVE the session a task
                let task = session.dataTask(with: url) { (data, response, error) in
                    if error != nil{
                        print(error)
                    }else{
                        DispatchQueue.main.async {
                            cell.profilePicture.image = UIImage(data: data!)
                        }
                    }
                }
                //MARK:- 4>Start the Task
                task.resume()
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatVC = navigationController?.storyboard?.instantiateViewController(identifier: "ChatViewController") as! ChatViewController
        chatVC.oneOfThesenderorReciever = users[indexPath.row]
        chatVC.usersDict = usersDict
        navigationController?.pushViewController(chatVC, animated: true)
    }
}
