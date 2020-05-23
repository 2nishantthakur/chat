

import UIKit
import Firebase

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    var users = [String]()
    var imagePicker = UIImagePickerController()
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    let db = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()

        retrieveProfilePictureFromFireStore()
        imagePicker.delegate = self
        profilePicture.layer.cornerRadius = profilePicture.frame.size.height / 2
        emailLabel.text = Auth.auth().currentUser?.email 
        // Do any additional setup after loading the view.
    }
    @IBAction func backButtonPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func changeProfilePicture(_ sender: Any) {
//        self.btnEdit.setTitleColor(UIColor.white, for: .normal)
//        self.btnEdit.isUserInteractionEnabled = true

        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))

        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary()
        }))

        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func editUsername(_ sender: Any) {
    }
    
    @IBAction func logOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            print("Logged Out")
            navigationController?.popToRootViewController(animated: true)
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
            
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func openGallary()
    {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    //MARK:-- ImagePicker delegate
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            profilePicture.contentMode = .scaleAspectFit
            
            if let editedImage = info[.editedImage] as? UIImage{
                profilePicture.image = editedImage
            }
            else{
                 profilePicture.image = pickedImage
            }
            let profileImageUrl = self.uploadImageToFirestore(image: self.profilePicture.image!)
//            DispatchQueue.main.async {
//
//            }
//            DispatchQueue.main.async {
//                self.updateFirestoreProfilePictureUrl(urlString: profileImageUrl)
//            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
