
import UIKit

class JoinChatViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    private func joinChatRoom() {
        
        let alertController = UIAlertController(title: "Socket", message: "Please enter a name:", preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: nil)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
            
            guard let textFields = alertController.textFields else {
                return
            }
            
            let textfield = textFields[0]
            if textfield.text?.count == 0 {
                self.joinChatRoom()
            } else {
                SocketHelper.shared.isUserExit(textfield.text!, completionHandler: { result in
                    while result{
                        self.joinChatRoom()
                        self.showToast(message: "Name is in-use!", font: .systemFont(ofSize:12.0))
                        }
                })
                guard let nickName = textfield.text else{
                    return
                }
                
                SocketHelper.shared.joinChatRoom(nickname: nickName) { [weak self] in
                    
                    guard let nickName = textfield.text,
                        let self = self else{
                            return
                    }
                    
                    self.moveToNextScreen(nickName)
                }
            }
        }
        
        alertController.addAction(OKAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
    private func moveToNextScreen(_ name: String) {
        
        let storyboard = UIStoryboard(name: "chat", bundle: nil)
        
        guard let chatListViewController = storyboard.instantiateViewController(withIdentifier: "ChatListViewController") as? ChatListViewController else{
            return
        }
        
        chatListViewController.nickName = name
        self.navigationController?.pushViewController(chatListViewController, animated: true)
    }
    
    @IBAction func btnJoinCLK(_ sender: UIButton) {
        joinChatRoom()
    }
    func showToast(message : String, font: UIFont) {

        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 7.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
}
