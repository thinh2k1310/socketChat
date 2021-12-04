

import Foundation
import Firebase

final class MessageViewModel {
    let db = Firestore.firestore()
    
    var arrMessage: KxSwift<[Message]> = KxSwift<[Message]>([])
    
    func getMessagesFromServer() {
        
        SocketHelper.shared.getMessage { [weak self] (message: Message?) in
            
            guard let self = self,
            let msgInfo = message else {
                return
            }
            
            self.arrMessage.value.append(msgInfo)
        }
    }
    func loadMessagesFromDatabase(){
              db.collection("messages")
                .order(by:"date")
                .getDocuments { (querySnapshot, error) in
                if let e = error {
                    print("There was an issue retrieving data from Firestore. \(e)")
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {
                        for doc in snapshotDocuments {
                            let data = doc.data()
                            if let messageSender = data["sender"] as? String, let messageBody = data["body"] as? String, let messageDate = data["date"] as? String {
                                let newMessage = Message(date: messageDate, message: messageBody, nickname: messageSender)
                                self.arrMessage.value.append(newMessage)
                        }
                    }
                }
            }
        }
    }
}
