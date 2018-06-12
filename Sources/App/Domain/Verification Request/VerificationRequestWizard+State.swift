//
//  VerificationRequestWizard+State.swift
//  App
//
//  Created by Luke Stringer on 11/06/2018.
//

import Foundation

extension VerificationRequestWizard {
    enum State {
        case requestScroll
        case confirmScroll(url: String)
        case requestForum
        case confirmForum(url: String)
        case complete(request: VerificationRequest)
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