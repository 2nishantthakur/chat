

import UIKit
import Firebase

extension ProfileViewController{
    
    func uploadImageToFirestore(image: UIImage) -> String {
        var urlString = String()
        let ref = Storage.storage().reference().child("\((Auth.auth().currentUser?.email as? String)!).png")
        //let dat = image.jpegData(compressionQuality: 0.5)
        if let uploadData = image.jpegData(compressionQuality: 0.5){
            ref.putData(uploadData, metadata: nil) { (metaData, error) in
                if error != nil{
                    print(error)
                }else{
                    ref.downloadURL { (url, error) in
                        if error != nil{
                            print(error)
                        }else{
                            DispatchQueue.main.async {
                                urlString = url!.absoluteString
                                print(urlString)
                                self.updateFirestoreProfilePictureUrl(urlString: urlString)
                            }
                        }
                    }
                }
            }
        }
        return urlString
    }
    
    func updateFirestoreProfilePictureUrl(urlString: String){
        db.collection("UsersList").getDocuments { (querySnapshot, error) in
            self.users = []
            if let e = error{
                print("There was isssue retrieving data from firestore")
            }else{
                if let snapshotDocument = querySnapshot?.documents{
                    for doc in snapshotDocument{
                        let data = doc.data()
                        if let email = data["email"] as? String{
                            if email == Auth.auth().currentUser?.email as? String{
                                DispatchQueue.main.async {
                                    self.db.collection("UsersList").document(doc.documentID).setData(["email": email,"profilePictureUrl": urlString], merge: true)
                                    print("Successfully uploades imageurl")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    func retrieveProfilePictureFromFireStore(){
        db.collection("UsersList").getDocuments { (querySnapshot, error) in
            if let e = error{
                print("There was isssue retrieving data from firestore")
            }else{
                if let snapshotDocument = querySnapshot?.documents{
                    for doc in snapshotDocument{
                        let data = doc.data()
                        if data["email"] as? String == Auth.auth().currentUser?.email as? String{
                            if data["profilePictureUrl"] != nil{
                                print("User Have Some Profile Poic")
                                //MARK:- 1>CREATE A URL
                                if let url = URL(string: (data["profilePictureUrl"] as? String)!){
                                    
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
        }
    }
}
