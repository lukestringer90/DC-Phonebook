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
            static let phoneBookRequests = UInt64(450397327295905803)
            static let phoneBookDirectory = UInt64(450397213319757854)
            static let logs = UInt64(450397168046440449)
        }
        
        struct Role {
            static let verified = UInt64(455104920673058817)
        }
        
        struct VerifyStartMessage {
            static let command = "!verify"
            static let secondsBeforeDeletion = 7.0
        }
    }
}
