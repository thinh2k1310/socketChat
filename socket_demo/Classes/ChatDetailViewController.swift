
import UIKit
import Firebase

class ChatDetailViewController: UIViewController {
    let db = Firestore.firestore()
    @IBOutlet weak var tblChat: UITableView!
        
    var nickName: String?
    var messageViewModel : MessageViewModel = MessageViewModel()
    
    @IBOutlet weak var txtMessage: UITextView! {
        didSet {
            txtMessage.layer.cornerRadius = txtMessage.frame.height/2
            txtMessage.layer.borderWidth = 1.0
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Welcome \(nickName ?? "!")"
        configuartionTableView()
        configureViewModel()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        loadMessagesFromDatabase()
    }
    private func configuartionTableView() {
        tblChat.dataSource = self
        tblChat.register(UINib(nibName: "MessageSendTableViewCell", bundle: nil), forCellReuseIdentifier: "MessageSendTableViewCell")
        tblChat.register(UINib(nibName: "MessageTableViewCell", bundle: nil), forCellReuseIdentifier: "MessageTableViewCell")
    }
    private func configureViewModel() {
        
        messageViewModel.arrMessage.subscribe { [weak self] (result: [Message]) in
            
            guard let self = self else {
                return
            }
            self.tblChat.reloadData()
            self.tblChat.scrollToBottom(animated: false)
        }
        messageViewModel.getMessagesFromServer()
    }
    func loadMessagesFromDatabase(){
              db.collection("messages")
            .order(by: "date")
                .getDocuments { (querySnapshot, error) in
                if let e = error {
                    print("There was an issue retrieving data from Firestore. \(e)")
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {
                        for doc in snapshotDocuments{
                            let data = doc.data()
                            if let messageSender = data["sender"] as? String, let messageBody = data["body"] as? String ,let messageDate = data["date"] as? String {
                                let newMessage = Message(date: messageDate, message: messageBody, nickname: messageSender)
                                self.messageViewModel.arrMessage.value.append(newMessage)
                                DispatchQueue.main.async {
                                       self.tblChat.reloadData()
                                    let indexPath = IndexPath(row: self.messageViewModel.arrMessage.value.count - 1, section: 0)
                                    self.tblChat.scrollToRow(at: indexPath, at: .top, animated: false)
                        }
                    }
                }
            }
        }
    }
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
        let messageBody = message
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/YYYY, HH:MM a"
        let messageDate = dateFormatter.string(from: date)
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

//MARK:-UITableView-
extension ChatDetailViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message: Message = messageViewModel.arrMessage.value[indexPath.row]
        
        if message.nickname == nickName {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MessageSendTableViewCell") as? MessageSendTableViewCell else {
                return UITableView.emptyCell()
            }
            cell.configureCell(message)
            return cell
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell") as? MessageTableViewCell else {
            return UITableView.emptyCell()
        }
        cell.configureCell(message)
        return cell
   }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageViewModel.arrMessage.value.count
    }
}


