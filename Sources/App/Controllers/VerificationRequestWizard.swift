//
//  VerificationRequestWizard.swift
//  App
//
//  Created by Luke Stringer on 02/06/2018.
//

import Foundation

struct VerificationRequest: Equatable {
    let userID: UInt64
    let scrollURL: String
    let forumPage: String
    let creationDate: Date
}

protocol VerificationRequestWizardDelegate {
    func wizard(_ wizard: VerificationRequestWizard, completedWith request: VerificationRequest)
}

class VerificationRequestWizard {
    
    enum State {
        case requestScroll
        case confirmScroll(url: String)
        case requestForum
        case confirmForum(url: String)
        case complete(request: VerificationRequest)
    }
    
    private var scrollNameTemp: String?
    private var formumNameTemp: String?
    private(set) var forumName: String?
    
    private let baseScrollURL = "https://dragcave.net/user/"
    private(set) var state: State = .requestScroll
    
    var scrollURL: String? {
        guard let name = scrollNameTemp else {  return nil }
        return baseScrollURL + name
    }
    
    var delegate: VerificationRequestWizardDelegate?
    let userID: UInt64
    
    init(userID: UInt64) {
        self.userID = userID
    }
    
    func inputMessage(_ message: String) {
        guard message.count > 0 else { return }
        
        switch state {
        case .requestScroll:
            scrollNameTemp = message
            state = .confirmScroll(url: scrollURL!)
        case .confirmScroll(_):
            parseConfirmation(message, confirmed: {
                state = .requestForum
            }, retry: {
                scrollNameTemp = nil
                state = .requestScroll
            })
        case .requestForum:
            formumNameTemp = message
            state = .confirmForum(url: formumNameTemp!)
        case .confirmForum(_):
            parseConfirmation(message, confirmed: {
                forumName = formumNameTemp
                let request = VerificationRequest(userID: userID, scrollURL: scrollURL!, forumPage: forumName!, creationDate: Date())
                state = .complete(request: request)
                delegate?.wizard(self, completedWith: request)
            }, retry: {
                formumNameTemp = nil
                forumName = nil
                state = .requestForum
            })
        case .complete(_): print("State is complete. Cannot accept input.")
        }
    }
}

fileprivate extension VerificationRequestWizard {
    func parseConfirmation(_ message: String, confirmed: () -> (), retry: ()-> (), invalid: (_ message: String) -> () = { print("Invalid message: \($0)") }) {
        switch message.lowercased() {
        case "y", "yes": confirmed()
        case "n", "no": retry()
        default: invalid(message)
        }
    }
}

extension VerificationRequestWizard.State {
    var userMessage: String {
        get {
            switch self {
            case .requestScroll:
            let message = """
                Hi! I'm the DC-Phonebook Bot. I can help you get verified.

                To do this I will need your **Scroll Name** (e.g. `lulu_witch`) and **Forum Profile URL** (e.g. `https://forums.dragcave.net/profile/67335-lulu_witch/`).
                
                So let's get started.

                What is your **Scroll Name**?
                """
                return message
                
            case .confirmScroll(let url):
                return "Is this your **Scroll URL**: <\(url)> ?\nType `Yes` or `No`."
            case .requestForum:
                return "What is your **Forum Profile URL**?"
            case .confirmForum(let url):
                return "Is this your **Forum Profile** URL: <\(url)> ?\nType `Yes` or `No`."
            case .complete(_):
                return "Thanks! Your verirication is now awaiting review by the mods."
            }
        }
    }
}

extension VerificationRequestWizard.State : Equatable {
    static func == (lhs: VerificationRequestWizard.State, rhs: VerificationRequestWizard.State) -> Bool {
        switch (lhs, rhs) {
        case (.requestScroll, .requestScroll): return true
        case (.requestForum, .requestForum): return true
        case let (.confirmScroll(scrollLHS), .confirmScroll(scrollRHS)):
            return scrollLHS == scrollRHS
        case let (.confirmForum(forumLHS), .confirmForum(forumRHS)): return forumLHS == forumRHS
        case let (.complete(requestLHS), .complete(requestRHS)): return requestLHS == requestRHS
        default: return false
        }
    }
}

