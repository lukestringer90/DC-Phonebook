//
//  VerificationRequestWizard+State.swift
//  App
//
//  Created by Luke Stringer on 11/06/2018.
//

import Foundation

extension VerificationRequest {
    enum State {
        case requestScroll
        case confirmScroll(url: String)
        case requestForum
        case invalidForum(url: String)
        case confirmForum(url: String)
        case complete(request: VerificationRequest)
        case approved
        case denied
    }
}

extension VerificationRequest.State {
    var userMessage: String {
        get {
            switch self {
            case .requestScroll:
                let message = """
                Hi! I'm the DC-Phonebook Bot. I can help you get verified.

                To do this I will need your **Scroll Name** (e.g. `\(Constants.DragonCave.exampleScrollName)`) and **Forum Profile URL** (e.g. `\(Constants.DragonCave.exampleForumURL)`).
                
                So let's get started.

                What is your **Scroll Name**?
                """
                return message
            case .confirmScroll(let url):
                return "Confirm this is your **Scroll URL**: <\(url)> ?\nType `Yes` or `No`."
            case .requestForum:
                return "What is your **Forum Profile URL**?"
            case .confirmForum(let url):
                return "Confirm this is your **Forum Profile URL**: <\(url)> ?\nType `Yes` or `No`."
            case .complete(_):
                return "Thanks! Your verification request is now awaiting review by the mods."
            case .approved:
                return "Congratulations, your verification request has been approved! You now have the `Verified` role and can access all the channels."
            case .denied:
                return "Your request for verification has been denied at this time. Please try again ensuring your information is correct. If you have any questions or concerns please contact a mod."
            case .invalidForum:
                return "That is not a valid forum URL. It must start with `\(Constants.DragonCave.forumBaseURL)`. Please try again.\n\(VerificationRequest.State.requestForum.userMessage)"
            }
        }
    }
}

extension VerificationRequest.State : Equatable {
    static func == (lhs: VerificationRequest.State, rhs: VerificationRequest.State) -> Bool {
        switch (lhs, rhs) {
        case (.requestScroll, .requestScroll): return true
        case (.requestForum, .requestForum): return true
        case let (.confirmScroll(scrollLHS), .confirmScroll(scrollRHS)):
            return scrollLHS == scrollRHS
        case let (.confirmForum(forumLHS), .confirmForum(forumRHS)): return forumLHS == forumRHS
        case let (.complete(requestLHS), .complete(requestRHS)): return requestLHS == requestRHS
        case (.approved, .approved): return true
        case (.denied, .denied): return true
        case (.invalidForum, .invalidForum): return true
        default: return false
        }
    }
}
