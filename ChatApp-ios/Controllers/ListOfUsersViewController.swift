
import UIKit
import Firebase

class ListOfUsersViewController: UIViewController {

    @IBOutlet var listTableView: UITableView!
    var users = ["A","B"]
    var usersdict = [String: String]()
    var usersProfilePics = [UIImage?]()
    let db = Firestore.firestore()
    //let profilePic = dp()
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        print("X")
        navigationItem.title = "Start a new Chat"
        listTableView.delegate = self
        listTableView.dataSource = self
        listTableView.register(UINib(nibName: "UsersList", bundle: nil), forCellReuseIdentifier: "cell")
        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.loadUsers()
        }
        
        
        
    }
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    
    func loadUsers(){
        users = []
        usersdict = [:]
        db.collection("UsersList").getDocuments{ (querySnapshot, error) in
            var temp = 0
            self.users = []
            self.usersProfilePics = []
            if let e = error{
                print("There was isssue retrieving data from firestore")
            }else{
                if let snapshotDocument = querySnapshot?.documents{
                    for doc in snapshotDocument{
                        let data = doc.data()
                        if let email = data["email"] as? String{
                            if email != Auth.auth().currentUser?.email as? String{
                                self.users.append(email)
                                if data["profilePictureUrl"] != nil {
                                    self.usersdict[email] = data["profilePictureUrl"] as! String
                                }else{
                                    self.usersdict[email] = "Not Available"
                                }
                                DispatchQueue.main.async {
                                    self.listTableView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

extension ListOfUsersViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersdict.count
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = listTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UsersList
        DispatchGroup().enter()
        cell.UserEmail.text = users[indexPath.row]
        if usersdict[users[indexPath.row]] != "Not Available"{
            if let url = URL(string: (usersdict[users[indexPath.row]] as? String)!){
                    
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
            }else{
                print("No DP")
            }
        return cell
        }
        
        
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatVC = navigationController?.storyboard?.instantiateViewController(identifier: "ChatViewController") as! ChatViewController
        chatVC.oneOfThesenderorReciever = users[indexPath.row]
        chatVC.usersDict = usersdict
        navigationController?.pushViewController(chatVC, animated: true)
    }


}
