//
//  Constants.swift
//  App
//
//  Created by Luke Stringer on 06/06/2018.
//

import Foundation

struct Constants {
    
    struct DragonCave {
        static let exampleScrollName = "lulu_witch"
        static let exampleForumURL = "https://forums.dragcave.net/profile/67335-lulu_witch/"
        static let scrollBaseURL = "https://dragcave.net/user/"
        static let forumBaseURL = "https://forums.dragcave.net/profile/"
    }
    
    struct Discord {
        
        struct ChannelID {
            static let phoneBookRequests = UInt64(460409351249854482)
            static let phoneBookDirectory = UInt64(460409431562256385)
            static let logs = UInt64(460409465439518721)
        }
        
        struct Role {
            static let verified = UInt64(460409573053038603)
        }
        
        struct VerifyStartMessage {
            static let command = "!verify"
            static let secondsBeforeDeletion = 7.0
        }
    }
}
