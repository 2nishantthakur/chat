

import UIKit

class UsersList: UITableViewCell {

    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var UserEmail: UILabel!
    @IBOutlet var view: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profilePicture.layer.cornerRadius = profilePicture.frame.height / 2
        view.layer.cornerRadius = view.frame.size.height / 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
