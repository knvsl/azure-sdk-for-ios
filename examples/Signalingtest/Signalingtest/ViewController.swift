import UIKit
import AzureCommunicationChat
import AzureCommunicationCommon
import AzureCore

struct Constants {
    static let endpoint =  "https://kimtestacs.communication.azure.com/"
    static let id1 = "8:acs:d2a829bc-8523-4404-b727-022345e48ca6_0000000a-e537-4183-f40f-343a0d00a855"
    static let skypeToken = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEwMiIsIng1dCI6IjNNSnZRYzhrWVNLd1hqbEIySmx6NTRQVzNBYyIsInR5cCI6IkpXVCJ9.eyJza3lwZWlkIjoiYWNzOmQyYTgyOWJjLTg1MjMtNDQwNC1iNzI3LTAyMjM0NWU0OGNhNl8wMDAwMDAwYS1lNTM3LTQxODMtZjQwZi0zNDNhMGQwMGE4NTUiLCJzY3AiOjE3OTIsImNzaSI6IjE2MjQ2NjA4NzYiLCJpYXQiOjE2MjQ2NjA4NzYsImV4cCI6MTYyNDc0NzI3NiwiYWNzU2NvcGUiOiJjaGF0IiwicmVzb3VyY2VJZCI6ImQyYTgyOWJjLTg1MjMtNDQwNC1iNzI3LTAyMjM0NWU0OGNhNiJ9.MrIa_yEBvrEF8qG4DzInkrj2Y5TlqIkhoA0Zu1HpRR93zEMHqJwnN72UpcOb7bqg4e49Bz1XRTsHHtECiAmwyOb4xA28L7KuBXk4R6RqwRhl5GtuZYojvcpaO1EmYeVsW_zofUm3V8_qzRN1N1CAA8BIslyp-jfTDARWYeprDX8jyerHP7T1d0JnNnY4I0AubD-VSVopbLOqs4dY2h0GWQ0vZDoEz8PuaS2_K2sJ4xjGaTtOpIH8zhtDU399I2V0eYXjY9oHjXox1qlqZOhho6VutXGRZnMDpJNCK2M2FcUpjpDAhJHBP88ccLx0dIxQnoxWv3fix5MN-EkPrtemXg"
    static let id2 = "8:acs:d2a829bc-8523-4404-b727-022345e48ca6_0000000a-e537-422e-f40f-343a0d00a856"
    static let skypeToken2 = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEwMiIsIng1dCI6IjNNSnZRYzhrWVNLd1hqbEIySmx6NTRQVzNBYyIsInR5cCI6IkpXVCJ9.eyJza3lwZWlkIjoiYWNzOmQyYTgyOWJjLTg1MjMtNDQwNC1iNzI3LTAyMjM0NWU0OGNhNl8wMDAwMDAwYS1lNTM3LTQyMmUtZjQwZi0zNDNhMGQwMGE4NTYiLCJzY3AiOjE3OTIsImNzaSI6IjE2MjQ2NjA4NzciLCJpYXQiOjE2MjQ2NjA4NzcsImV4cCI6MTYyNDc0NzI3NywiYWNzU2NvcGUiOiJjaGF0IiwicmVzb3VyY2VJZCI6ImQyYTgyOWJjLTg1MjMtNDQwNC1iNzI3LTAyMjM0NWU0OGNhNiJ9.wRHIPim7MLiumzX1ZKKkYLXcFncY94JPi_1NjzEzAUPu5EBrpIki9S6RYsKt4WQ9lI3cT8G226GMGtpESA18T2r-hqjqHtrES__mzFzB_bmmGZqOFuKC3rt86IBhco_z_Fc6YqrR0QLo1RduqT6KhaUHDmcFoeVyP0J5N_3rgJm2REai56UdIb2tNrG0gdynK3O5DNKdC-iJb1z-_4ghpHvWbtwvOsZOQmKs5w1cMa3pyxAOCX58wO95AdMOAlwh-b7Zi1Hj47OWlawZVTf7Cyq-nxkxPGxfmVCqUJ3r-3HND_ATcmG2qKJnD8zc8KcDxWzGNj4Er3GGMsDm2vskrw"
    
}

func generateId () -> String
{
    var place = 1
    var finalNumber = 0;
    for _ in 1...12 {
        finalNumber += Int(arc4random_uniform(10)) * place
        place *= 10
   }
    return "8:acs:46849534-eb08-4ab7-bde7-c36928cd1547_00000006-f3dd-7f8c-1655-"+String(finalNumber)
}

extension ViewController: MyTableViewCellDelegate {
    func showErrorWindow(with message: String)
    {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func didTapButton(with title: String) {
        switch title {
        case "Subscribe to Thread Creation":
            chatClient?.register(event: ChatEventId.chatThreadCreated, handler:{
                (response)
                in
                self.handleChatEvents(response: response)
            })
            DispatchQueue.main.async {
                self.logArea.text += "\n------> Subscribed to Thread Creation"
                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                self.logArea.scrollRangeToVisible(range)
            }
        case "Subscribe to Message":
            chatClient?.register(event: ChatEventId.chatMessageReceived, handler:{
                (response)
                in
                self.handleChatEvents(response: response)
            })
            DispatchQueue.main.async {
                self.logArea.text += "\n------> Subscribed to Message"
                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                self.logArea.scrollRangeToVisible(range)
            }
        case "Subscribe to Typing Indicator":
            chatClient?.register(event: ChatEventId.typingIndicatorReceived, handler:{
                (response)
                in
                self.handleChatEvents(response: response)
            })
            DispatchQueue.main.async {
                self.logArea.text += "\n------> Subscribed to Typing Indicator"
                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                self.logArea.scrollRangeToVisible(range)
            }
        case "Subscribe to Read Receipt":
            chatClient?.register(event: ChatEventId.readReceiptReceived, handler:{
                (response)
                in
                self.handleChatEvents(response: response)
            })
            DispatchQueue.main.async {
                self.logArea.text += "\n------> Subscribed to Read Receipt"
                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                self.logArea.scrollRangeToVisible(range)
            }
        case "Subscribe to Message Update":
            chatClient?.register(event: ChatEventId.chatMessageEdited, handler:{
                (response)
                in
                self.handleChatEvents(response: response)
            })
            DispatchQueue.main.async {
                self.logArea.text += "\n------> Subscribed to Message Update"
                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                self.logArea.scrollRangeToVisible(range)
            }
        case "Subscribe to Message Deletion":
            chatClient?.register(event: ChatEventId.chatMessageDeleted, handler:{
                (response)
                in
                self.handleChatEvents(response: response)
            })
            DispatchQueue.main.async {
                self.logArea.text += "\n------> Subscribed to Message Deletion"
                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                self.logArea.scrollRangeToVisible(range)
            }
        case "Subscribe to Thread Topic Update":
            chatClient?.register(event: ChatEventId.chatThreadPropertiesUpdated, handler:{
                (response)
                in
                self.handleChatEvents(response: response)
            })
            DispatchQueue.main.async {
                self.logArea.text += "\n------> Subscribed to Thread Topic Update"
                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                self.logArea.scrollRangeToVisible(range)
            }
        case "Subscribe to Participant Addition":
            chatClient?.register(event: ChatEventId.participantsAdded, handler:{
                (response)
                in
                self.handleChatEvents(response: response)
            })
            DispatchQueue.main.async {
                self.logArea.text += "\n------> Subscribed to Participant Addition"
                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                self.logArea.scrollRangeToVisible(range)
            }
        case "Subscribe to Participant Removal":
            chatClient?.register(event: ChatEventId.participantsRemoved, handler:{
                (response)
                in
                self.handleChatEvents(response: response)
            })
            DispatchQueue.main.async {
                self.logArea.text += "\n------> Participant Removal"
                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                self.logArea.scrollRangeToVisible(range)
            }
        case "Subscribe to Thread Deletion":
            chatClient?.register(event: ChatEventId.chatThreadDeleted, handler:{
                (response)
                in
                self.handleChatEvents(response: response)
            })
            DispatchQueue.main.async {
                self.logArea.text += "\n------> Subscribed to Thread Deletion"
                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                self.logArea.scrollRangeToVisible(range)
            }
        case "Create Thread":
            let participant = ChatParticipant(
                id: CommunicationUserIdentifier(Constants.id1),
                displayName: "Bob",
                                            shareHistoryTime: Iso8601Date(string: "2020-10-30T10:50:50Z")
            )
            let participant2 = ChatParticipant(
                id: CommunicationUserIdentifier(Constants.id2),
                displayName: "Alice",
                                            shareHistoryTime: Iso8601Date(string: "2020-10-30T10:50:50Z")
            )
            let request = CreateChatThreadRequest(
                topic: "Lunch Thread",
                participants: [
                    participant,participant2
                ]
            )
            chatClient?.create(thread: request) { result, _ in
                switch result {
                case let .success(response):
                    print(response)
                    DispatchQueue.main.async {
                        self.logArea.text += "\n------> Created a Thread"
                        let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                        self.logArea.scrollRangeToVisible(range)
                    }
                    guard let thread = response.chatThread else {
                        print("Failed to extract chatThread from response")
                        return
                    }
                    do {
                        self.chatThreadClient = try self.chatClient?.createClient(forThread: thread.id)
                        self.chatThreadClient2 = try self.chatClient2?.createClient(forThread: thread.id)
                    } catch _ {
                        print("Failed to initialize ChatThreadClient")
                    }
                case let .failure(error):
                    print("Unexpected failure happened in Create Thread")
                    print("\(error)")
                }
            }
        case "Send Message":
            if chatThreadClient == nil{
                showErrorWindow(with: "You need to creat a thread before you can send a message")
                return
            }
            let messageRequest = SendChatMessageRequest(
                content: "This is a message from Bob!",
                senderDisplayName: "Bob"
            )
            chatThreadClient?.send(message: messageRequest, completionHandler: { result, _ in
                switch result {
                case let .success(response):
                    print(response)
                    self.chatMessageId = response.id
                    DispatchQueue.main.async {
                        self.logArea.text += "\n------> Sent a Message"
                        let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                        self.logArea.scrollRangeToVisible(range)
                    }
                case .failure:
                    print("Unexpected failure happened in send message")
                }
            })
            
        case "Send Typing Indicator":
            if chatThreadClient == nil{
                showErrorWindow(with: "You need to creat a thread before you can send a typing indicator")
                return
            }
            chatThreadClient?.sendTypingNotification(completionHandler: { result, _ in
                switch result {
                case let .success(response):
                    print(response)
                    DispatchQueue.main.async {
                        self.logArea.text += "\n------> Sent a Typing Indicator"
                        let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                        self.logArea.scrollRangeToVisible(range)
                    }
                    
                case .failure:
                    print("Unexpected failure happened in send typing notification")
                }
            })
        case "Send Read Receipt":
            if chatThreadClient == nil{
                showErrorWindow(with: "You need to creat a thread before you can send a read receipt")
                return
            }
            else if chatMessageId == nil{
                showErrorWindow(with: "You need to send a message before you can send a read receipt")
                return
            }
            
            chatThreadClient2?.sendReadReceipt(forMessage: chatMessageId!, completionHandler: { result, _ in
                switch result {
                case let .success(response):
                    print(response)
                    DispatchQueue.main.async {
                        self.logArea.text += "\n------> Sent a Read Receipt"
                        let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                        self.logArea.scrollRangeToVisible(range)
                    }
                    
                case .failure:
                    print("Unexpected failure happened in send read receipt")
                }
            })
        case "Edit Message":
            if chatThreadClient == nil{
                showErrorWindow(with: "You need to creat a thread before you can edit a message")
                return
            }
            else if chatMessageId == nil{
                showErrorWindow(with: "You need to send a message before you can edit the message")
                return
            }

            chatThreadClient?.update(content: "Updated Message", forMessage: chatMessageId!, completionHandler: { result, _ in
                switch result {
                case let .success(response):
                    print(response)
                    DispatchQueue.main.async {
                        self.logArea.text += "\n------> Edited a Message"
                        let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                        self.logArea.scrollRangeToVisible(range)
                    }
                    
                case .failure:
                    print("Unexpected failure happened in update chat message")
                }
            })
        case "Delete Message":
            if chatThreadClient == nil{
                showErrorWindow(with: "You need to creat a thread before you can delete a message")
                return
            }
            else if chatMessageId == nil{
                showErrorWindow(with: "You need to send a message before you can delete the message")
                return
            }
            
            chatThreadClient?.delete(message: chatMessageId!, completionHandler: { result, _ in
                switch result {
                case let .success(response):
                    print(response)
                    self.chatMessageId = nil
                    DispatchQueue.main.async {
                        self.logArea.text += "\n------> Deleted a Message"
                        let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                        self.logArea.scrollRangeToVisible(range)
                    }
                    
                case .failure:
                    print("Unexpected failure happened in delete message")
                }
            })
        case "Edit Thread Topic":
            if chatThreadClient == nil{
                showErrorWindow(with: "You need to creat a thread before you can change its topic name")
                return
            }
            chatThreadClient?.update(topic: "updated topic", completionHandler: { result, _ in
                switch result {
                case let .success(response):
                    print(response)
                    DispatchQueue.main.async {
                        self.logArea.text += "\n------> Updated Thread Topic"
                        let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                        self.logArea.scrollRangeToVisible(range)
                    }
                    
                case .failure:
                    print("Unexpected failure happened in update chat thread properties")
                }
                
            })
        case "Add Participant":
            if chatThreadClient == nil{
                showErrorWindow(with: "You need to creat a thread before you can add a participant")
                return
            }
            let participant = ChatParticipant(
                id: CommunicationUserIdentifier(generateId()),
                displayName: "William",
                shareHistoryTime: Iso8601Date(string: "2020-10-30T10:50:50Z")
            )
            chatThreadClient?.add(participants: [participant], completionHandler: { result, _ in
                switch result {
                case let .success(response):
                    print(response)
                    DispatchQueue.main.async {
                        self.logArea.text += "\n------> Added a Participant"
                        let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                        self.logArea.scrollRangeToVisible(range)
                    }
                    
                case .failure:
                    print("Unexpected failure happened in Add participant")
                }
            })
        case "Remove Participant":
            if chatThreadClient == nil{
                showErrorWindow(with: "You need to creat a thread before you can remove a participant")
                return
            }
            chatThreadClient?.listParticipants(completionHandler: { result, _ in
                switch result {
                case let .success(response):
                    print(response)
                    var existLoop = false
                    while (existLoop == false)
                    {
                        response.nextItem { result in
                            switch result {
                            case let .success(participant):
                                let id = participant.id as! CommunicationUserIdentifier
                                if id.identifier == Constants.id1 || id.identifier == Constants.id2
                                {
                                    return
                                }
                                existLoop = true
                                self.chatThreadClient?.remove(participant: participant.id, completionHandler: { result, _ in
                                    switch result {
                                    case let .success(response):
                                        print(response)
                                        DispatchQueue.main.async {
                                            self.logArea.text += "\n------> Removed a Participant"
                                            let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                                            self.logArea.scrollRangeToVisible(range)
                                        }
                                    case .failure:
                                        print("Unexpected failure happened in remove participant")
                                    }
                                })
                            case .failure:
                                print("Unexpected failure happened in list participants")
                                existLoop = true
                                self.showErrorWindow(with: "You need to add a participant before you can remove the participant")
                            }
                        }
                    }
                case .failure:
                    print("Unexpected failure happened in list participants")
                }
            })
        case "Delete Thread":
            if chatThreadClient == nil{
                showErrorWindow(with: "You need to creat a thread before you can delete the thread")
                return
            }
            chatClient?.delete(thread: chatThreadClient!.threadId, completionHandler:  { result, _ in
                switch result {
                case let .success(response):
                    print(response)
                    DispatchQueue.main.async {
                        self.logArea.text += "\n------> Deleted a Thread"
                        let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                        self.logArea.scrollRangeToVisible(range)
                    }
                case .failure:
                    print("Unexpected failure happened in Delete Thread")
                }
            })
            
        default:
            print("Nothing")
        }
    }
}

class ViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet var chatEventTable: UITableView!
    @IBOutlet var subscribeToChatEventTable: UITableView!
    @IBOutlet var logArea: UITextView!
    
    let chatEvents = [
        "Create Thread",
        "Send Message",
        "Send Typing Indicator",
        "Send Read Receipt",
        "Edit Message",
        "Delete Message",
        "Edit Thread Topic",
        "Add Participant",
        "Remove Participant",
        "Delete Thread"
    ]
    
    let subscribeToChatEvents = [
        "Subscribe to Thread Creation",
        "Subscribe to Message",
        "Subscribe to Typing Indicator",
        "Subscribe to Read Receipt",
        "Subscribe to Message Update",
        "Subscribe to Message Deletion",
        "Subscribe to Thread Topic Update",
        "Subscribe to Participant Addition",
        "Subscribe to Participant Removal",
        "Subscribe to Thread Deletion"
    ]
    
    var chatClient: ChatClient? = nil
    var chatClient2: ChatClient? = nil
    var chatThreadClient: ChatThreadClient? = nil
    var chatThreadClient2: ChatThreadClient? = nil
    var chatMessageId: String? = nil
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == chatEventTable{
            let cell = tableView.dequeueReusableCell(withIdentifier: MyTableViewCell.identifier, for: indexPath) as! MyTableViewCell
            cell.configure(with: chatEvents[indexPath.row])
            cell.delegate = self
            return cell
        } else if tableView == subscribeToChatEventTable{
            let cell = tableView.dequeueReusableCell(withIdentifier: MyTableViewCell.identifier, for: indexPath) as! MyTableViewCell
            cell.configure(with: subscribeToChatEvents[indexPath.row])
            cell.delegate = self
            return cell
        }
        return UITableViewCell()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logArea.isScrollEnabled = true
        chatEventTable.register(MyTableViewCell.nib(), forCellReuseIdentifier: MyTableViewCell.identifier)
        chatEventTable.dataSource = self
        subscribeToChatEventTable.register(MyTableViewCell.nib(), forCellReuseIdentifier: MyTableViewCell.identifier)
        subscribeToChatEventTable.dataSource = self
        onStart(skypeToken: Constants.skypeToken)
    }
    
    func onStop()
    {
        chatClient?.stopRealTimeNotifications()
    }
    
    func onStart (skypeToken: String)
    {
        let communicationUserCredential: CommunicationTokenCredential
        do {
            communicationUserCredential = try CommunicationTokenCredential(token:skypeToken)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        let communicationUserCredential2: CommunicationTokenCredential
        do {
            communicationUserCredential2 = try CommunicationTokenCredential(token:Constants.skypeToken2)
        } catch {
            fatalError(error.localizedDescription)
        }
        chatClient = getClient(credential:communicationUserCredential)
        chatClient2 = getClient(credential:communicationUserCredential2)

        let semaphore = DispatchSemaphore(value: 0)
        chatClient?.startRealTimeNotifications { result in
            switch result {
            case .success:
                print("\n------> Started realtime notifications")
            case .failure:
                print("\n------> Failed to start realtime notifications")
            }
            semaphore.signal()
        }
        semaphore.wait()
    }
    
    func getClient(credential: CommunicationTokenCredential? = nil) -> ChatClient {
        let scope = Constants.endpoint
        do {
            let options = AzureCommunicationChatClientOptions(logger: ClientLoggers.none)
            return try ChatClient(endpoint: scope, credential: credential!, withOptions: options)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func handleChatEvents (response:TrouterEvent)
    {
        let test = response
        print("Received event")
//        if (eventId == ChatEventId.chatMessageReceived)
//        {
//            let response = response as! ChatMessageReceivedEvent
//            print("\n------> ChatMessageReceivedEvent Received: ", response)
//            print("\n------> threadId is: ", response.threadId)
//            print("\n------> id is: ", response.id)
//            print("\n------> content is: ", response.message)
//
//            DispatchQueue.main.async {
//                self.logArea.text += "\n------> ChatMessageReceivedEvent Received: "
//                self.logArea.text += "\n threadId is: " + String(response.threadId)
//                self.logArea.text += "\n id is: " + String(response.id)
//                self.logArea.text += "\n content is: " + String(response.message)
//                self.logArea.text += "\n"
//
//                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
//                self.logArea.scrollRangeToVisible(range)
//            }
//        }
//        else if(eventId == ChatEventId.typingIndicatorReceived)
//        {
//            let response = response as! TypingIndicatorReceivedEvent
//            print("\n------> TypingIndicatorReceivedEvent Received: ", response)
//            print("\n------> threadId is: ", response.threadId)
//            print("\n------> receivedOn is: ", response.receivedOn?.requestString ?? "")
//            print("\n------> version is: ", response.version)
//
//            DispatchQueue.main.async {
//                self.logArea.text += "\n------> TypingIndicatorReceivedEvent Received: "
//                self.logArea.text += "\n threadId is: " + String(response.threadId)
//                self.logArea.text += "\n receivedOn is: " + String(response.receivedOn?.requestString ?? "")
//                self.logArea.text += "\n version is: " + String(response.version)
//                self.logArea.text += "\n"
//
//                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
//                self.logArea.scrollRangeToVisible(range)
//            }
//        }
//        else if(eventId == ChatEventId.readReceiptReceived)
//        {
//            let response = response as! ReadReceiptReceivedEvent
//            print("\n------> ReadReceiptReceivedEvent Received: ", response)
//            print("\n------> threadId is: ", response.threadId)
//            print("\n------> readOn is: ", response.readOn?.requestString ?? "")
//            print("\n------> chatMessageId is: ", response.chatMessageId)
//
//            DispatchQueue.main.async {
//                self.logArea.text += "\n------> ReadReceiptReceivedEvent Received: "
//                self.logArea.text += "\n threadId is: " + String(response.threadId)
//                self.logArea.text += "\n readOn is: " + String(response.readOn?.requestString ?? "")
//                self.logArea.text += "\n chatMessageId is: " + String(response.chatMessageId)
//                self.logArea.text += "\n"
//
//                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
//                self.logArea.scrollRangeToVisible(range)
//            }
//        }
//        else if(eventId == ChatEventId.chatMessageEdited)
//        {
//            let response = response as! ChatMessageEditedEvent
//            print("\n------> ChatMessageEditedEvent Received: ", response)
//            print("\n------> threadId is: ", response.threadId)
//            print("\n------> editedOn is: ", response.editedOn?.requestString ?? "")
//            print("\n------> content is: ", response.message)
//
//            DispatchQueue.main.async {
//                self.logArea.text += "\n------> ChatMessageEditedEvent Received: "
//                self.logArea.text += "\n threadId is: " + String(response.threadId)
//                self.logArea.text += "\n editedOn is: " + String(response.editedOn?.requestString ?? "")
//                self.logArea.text += "\n content is: " + String(response.message)
//                self.logArea.text += "\n"
//
//                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
//                self.logArea.scrollRangeToVisible(range)
//            }
//        }
//        else if(eventId == ChatEventId.chatMessageDeleted)
//        {
//            let response = response as! ChatMessageDeletedEvent
//            print("\n------> ChatMessageDeletedEvent Received: ", response)
//            print("\n------> threadId is: ", response.threadId)
//            print("\n------> deletedOn is: ", response.deletedOn?.requestString ?? "")
//
//            DispatchQueue.main.async {
//                self.logArea.text += "\n------> ChatMessageDeletedEvent Received: "
//                self.logArea.text += "\n threadId is: " + String(response.threadId)
//                self.logArea.text += "\n deletedOn is: " + String(response.deletedOn?.requestString ?? "")
//                self.logArea.text += "\n"
//
//                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
//                self.logArea.scrollRangeToVisible(range)
//            }
//        }
//        else if(eventId == ChatEventId.chatThreadCreated)
//        {
//            let response = response as! ChatThreadCreatedEvent
//            print("\n------> ChatThreadCreatedEvent Received: ", response)
//            print("\n------> threadId is: ", response.threadId)
//            print("\n------> createdOn is: ", response.createdOn?.requestString ?? "")
//
//            DispatchQueue.main.async {
//                self.logArea.text += "\n------> ChatThreadCreatedEvent Received: "
//                self.logArea.text += "\n threadId is: " + String(response.threadId)
//                self.logArea.text += "\n createdOn is: " + String(response.createdOn?.requestString ?? "")
//                self.logArea.text += "\n"
//
//                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
//                self.logArea.scrollRangeToVisible(range)
//            }
//        }
//        else if(eventId == ChatEventId.chatThreadPropertiesUpdated)
//        {
//            let response = response as! ChatThreadPropertiesUpdatedEvent
//            print("\n------> ChatThreadPropertiesUpdatedEvent Received: ", response)
//            print("\n------> threadId is: ", response.threadId)
//            print("\n------> updatedOn is: ", response.updatedOn?.requestString ?? "")
//
//            DispatchQueue.main.async {
//                self.logArea.text += "\n------> ChatThreadPropertiesUpdatedEvent Received: "
//                self.logArea.text += "\n threadId is: " + String(response.threadId)
//                self.logArea.text += "\n updatedOn is: " + String(response.updatedOn?.requestString ?? "")
//                self.logArea.text += "\n"
//
//                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
//                self.logArea.scrollRangeToVisible(range)
//            }
//        }
//        else if(eventId == ChatEventId.chatThreadDeleted)
//        {
//            let response = response as! ChatThreadDeletedEvent
//            print("\n------> ChatThreadDeletedEvent Received: ", response)
//            print("\n------> threadId is: ", response.threadId)
//            print("\n------> deletedOn is: ", response.deletedOn?.requestString ?? "")
//
//            DispatchQueue.main.async {
//                self.logArea.text += "\n------> ChatThreadDeletedEvent Received: "
//                self.logArea.text += "\n threadId is: " + String(response.threadId)
//                self.logArea.text += "\n deletedOn is: " + String(response.deletedOn?.requestString ?? "")
//                self.logArea.text += "\n"
//
//                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
//                self.logArea.scrollRangeToVisible(range)
//            }
//        }
//        else if(eventId == ChatEventId.participantsAdded)
//        {
//            let response = response as! ParticipantsAddedEvent
//            print("\n------> ParticipantsAddedEvent Received: ", response)
//            print("\n------> threadId is: ", response.threadId)
//            print("\n------> addedOn is: ", response.addedOn?.requestString ?? "")
//
//            DispatchQueue.main.async {
//                self.logArea.text += "\n------> ParticipantsAddedEvent Received: "
//                self.logArea.text += "\n threadId is: " + String(response.threadId)
//                self.logArea.text += "\n addedOn is: " + String(response.addedOn?.requestString ?? "")
//                self.logArea.text += "\n shareHistoryTime is: " + String(response.participantsAdded?[0].shareHistoryTime?.requestString ?? "")
//                self.logArea.text += "\n"
//
//                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
//                self.logArea.scrollRangeToVisible(range)
//            }
//        }
//        else if(eventId == ChatEventId.participantsRemoved)
//        {
//            let response = response as! ParticipantsRemovedEvent
//            print("\n------> ParticipantsRemovedEvent Received: ", response)
//            print("\n------> threadId is: ", response.threadId)
//            print("\n------> removedOn is: ", response.removedOn?.requestString ?? "")
//
//            DispatchQueue.main.async {
//                self.logArea.text += "\n------> ParticipantsRemovedEvent Received: "
//                self.logArea.text += "\n threadId is: " + String(response.threadId)
//                self.logArea.text += "\n removedOn is: " + String(response.removedOn?.requestString ?? "")
//                self.logArea.text += "\n shareHistoryTime is: " + String(response.participantsRemoved?[0].shareHistoryTime?.requestString ?? "")
//                self.logArea.text += "\n"
//
//                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
//                self.logArea.scrollRangeToVisible(range)
//            }
//        }
    }
    
}

