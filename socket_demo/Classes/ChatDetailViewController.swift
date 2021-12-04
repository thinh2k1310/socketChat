
import UIKit
import Firebase

class ChatDetailViewController: UIViewController {
    let db = Firestore.firestore()
    @IBOutlet weak var tblChat: ChatDetailsTableView! {
        didSet {
            guard let tblChat = tblChat else {
                return
            }
            tblChat.nickName = nickName
        }
    }
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
        title = "Welcome \(nickName ?? "!")"
    }
}
// MARK:- Action Events -
extension ChatDetailViewController {
    
    @IBAction func btnSendCLK(_ sender: UIButton) {
        
        guard txtMessage.text.count > 0, let message = txtMessage.text, let name = nickName
            else {
            print("Please type your message.")
            return
        }
        let messageSender = name
        let messageDate = Date()
        let messageBody = message
        db.collection("messages").addDocument(data: [
            "sender" : messageSender,
            "body" : messageBody,
            "date" : messageDate
        ]){ (error) in
            if let e = error {
                print("There was an issue saving data to firestore, \(e)")
            } else {
                print("Successfully saved data.")
                
                DispatchQueue.main.async {
                     self.txtMessage.text = ""
                }
            }
        }
        txtMessage.resignFirstResponder()
        SocketHelper.shared.sendMessage(message: message, withNickname: name)
        txtMessage.text = nil
    }
}


