
import UIKit

class ChatDetailViewController: UIViewController {

    @IBOutlet weak var tblChat: ChatDetailsTableView! {
        didSet {
            
            guard let tblChat = tblChat else {
                return
            }
            
            tblChat.nickName = nickName
        }
    }
    
    var user: User?
    var nickName: String?
    
    @IBOutlet weak var txtMessage: UITextView! {
        didSet {
            txtMessage.layer.cornerRadius = txtMessage.frame.height/2
            txtMessage.layer.borderWidth = 1.0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func configureNavigation() {
        
        guard let user = user else {
            return
        }
        
        title = user.nickname
    }
    @IBAction func chooseImage(_ sender: UIButton) {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc,animated: true)
        
    }
}

// MARK:- Action Events -
extension ChatDetailViewController {
    
    @IBAction func btnSendCLK(_ sender: UIButton) {
        
        guard txtMessage.text.count > 0,
            let message = txtMessage.text,
            let name = nickName else {
            print("Please type your message.")
            return
        }
        
        txtMessage.resignFirstResponder()
        SocketHelper.shared.sendMessage(message: message, withNickname: name)
        txtMessage.text = nil
    }
}
// MARK:- Send image
extension ChatDetailViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")]{
            print("\(info)")
        }
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
