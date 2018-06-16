//
//  VerificationRequest.swift
//  App
//
//  Created by Luke Stringer on 11/06/2018.
//

import Foundation

struct VerificationRequest: Equatable, Codable {
    let userID: UInt64
    let scrollURL: String
    let forumPage: String
    let creationDate: Date
}

extension VerificationRequest {
    var messageRepresentation: String {
        get {
            return """
            <@\(userID)>
            
            Scroll: <\(scrollURL)>
            Forum: <\(forumPage)>
            """
        }
    }
    
    static func extractUserID(from string: String) -> UserID {
        guard
            let at = string.index(of: "@"),
            let closingBracket = string.index(of: ">")
            else {
                fatalError("Cannot get user ID from message content")
        }
        
        let start = string.index(after: at)
        let end = string.index(before: closingBracket)
        
        let userIDString = string[start...end]
        
        guard let userIDDouble = Double(userIDString) else {
            fatalError("Cannot parse message string into double for user ID ")
        }
        
        return UserID(userIDDouble)
    }
}
