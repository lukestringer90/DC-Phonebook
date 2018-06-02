//
//  VerificationRequestWizard.swift
//  App
//
//  Created by Luke Stringer on 02/06/2018.
//

import Foundation

struct VerificationRequest: Equatable {
    let scrollName: String
    let forumPage: String
    let creationDate: Date
}

class VerificationRequestWizard {
    
    private var scrollNameTemp: String?
    private var formumNameTemp: String?
    
    var scrollName: String?
    var forumName: String?
    
    enum State {
        case requestScroll
        case confirmScroll(scrollName: String)
        case requestForum
        case confirmForum(forumName: String)
        case complete(request: VerificationRequest)
    }
    
    private(set) var state: State = .requestScroll
    
    func inputMessage(_ message: String) {
        guard message.count > 0 else { return }
        
        switch state {
        case .requestScroll:
            scrollNameTemp = message
            state = .confirmScroll(scrollName: scrollNameTemp!)
        case .confirmScroll(_):
            
            parseConfirmation(message, confirmed: {
                scrollName = scrollNameTemp
                state = .requestForum
            }, retry: {
                scrollNameTemp = nil
                scrollName = nil
                state = .requestScroll
            })
            
        case .requestForum:
            formumNameTemp = message
            state = .confirmForum(forumName: formumNameTemp!)
        case .confirmForum(_):
            
            parseConfirmation(message, confirmed: {
                forumName = formumNameTemp
                let request = VerificationRequest(scrollName: scrollName!, forumPage: forumName!, creationDate: Date())
                state = .complete(request: request)
            }, retry: {
                formumNameTemp = nil
                forumName = nil
                state = .requestForum
            })
            
        default:
            break
        }
    }
    
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
                return "What is your scroll?"
            case .confirmScroll(let scrollName):
                return "Are you sure it is `\(scrollName)`? Type \"Yes\" or \"No\""
            case .requestForum:
                return "What is your forum name?"
            case .confirmForum(let forumName):
                return "Are you sure it is `\(forumName)`? Type \"Yes\" or \"No\""
            case .complete(_):
                return "Thanks! The mods will now review your verificiation request."
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

