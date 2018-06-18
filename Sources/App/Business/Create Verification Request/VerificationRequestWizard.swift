//
//  VerificationRequestWizard.swift
//  App
//
//  Created by Luke Stringer on 02/06/2018.
//

import Foundation

protocol VerificationRequestWizardDelegate {
    func wizard(_ wizard: VerificationRequestWizard, completedWith request: VerificationRequest)
}

class VerificationRequestWizard {
    
    // MARK: - Private vars
    
    private let baseScrollURL = "https://dragcave.net/user/"
    private var scrollNameTemp: String?
    private var formumNameTemp: String?
    private(set) var forumName: String?
    private(set) var state: VerificationRequest.State = .requestScroll
    
    // MARK: - Public vars
    
    var delegate: VerificationRequestWizardDelegate?
    let userID: UInt64
    
    // MARK: - Computed vars
    
    var scrollURL: String? {
        guard let name = scrollNameTemp else {  return nil }
        return baseScrollURL + name
    }
    
    // MARK: - Public Functions
    
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
            parseConfirmation(message, confirm: {
                state = .requestForum
            }, retry: {
                scrollNameTemp = nil
                state = .requestScroll
            })
        case .requestForum:
            handleInputOf(forumURL: message)
        case .invalidForum:
            handleInputOf(forumURL: message)
        case .confirmForum(_):
            parseConfirmation(message, confirm: {
                forumName = formumNameTemp
                let request = VerificationRequest(userID: userID, scrollURL: scrollURL!, forumPage: forumName!, creationDate: Date())
                state = .complete(request: request)
                delegate?.wizard(self, completedWith: request)
            }, retry: {
                formumNameTemp = nil
                forumName = nil
                state = .requestForum
            })
        case .complete, .approved, .denied: print("Cannot accept input for this state: \(state).")
        }
    }
}

// MARK: - Private Functions

fileprivate extension VerificationRequestWizard {
    func handleInputOf(forumURL: String) {
        if validate(forumURL: forumURL) {
            formumNameTemp = forumURL
            state = .confirmForum(url: formumNameTemp!)
        }
        else {
            state = .invalidForum(url: forumURL)
        }
    }
    
    func validate(forumURL: String) -> Bool {
        return forumURL.hasPrefix("https://forums.dragcave.net/profile/")
    }
    
    func parseConfirmation(_ message: String, confirm: () -> (), retry: ()-> (), invalid: (_ message: String) -> () = { print("Invalid message: \($0)") }) {
        switch message.lowercased() {
        case "y", "yes": confirm()
        case "n", "no": retry()
        default: invalid(message)
        }
    }
}
