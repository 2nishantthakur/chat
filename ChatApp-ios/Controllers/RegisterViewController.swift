

import UIKit
import Firebase

class RegisterViewController: UIViewController {

    let db = Firestore.firestore()
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    @IBAction func registerPressed(_ sender: UIButton) {
        if let email = emailTextfield.text, let password = passwordTextfield.text{
            Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                if let e = error{
                    print(e.localizedDescription)
                } else {
                    //Navigate to ChatViewController
                    self.db.collection("UsersList").addDocument(data: ["email": email]) { (error) in
                    if let e = error{
                        print("There was an issue registering New User")
                    }else{
                        print("Successfully Registered User Data")
                    }
                    }
                    self.performSegue(withIdentifier: "newChatSegue", sender: self)
                }
            }
        }
    }
    
}
