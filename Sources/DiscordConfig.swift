//
//  DiscordConfig.swift
//  App
//
//  Created by Luke Stringer on 26/06/2018.
//

import Foundation

struct DiscordConfig: Codable {
    
    struct ChannelIDs: Codable {
        let phoneBookRequests: UInt64
        let phoneBookDirectory: UInt64
        let logs: UInt64
    }
    
    struct RoleIDs: Codable {
        let verified: UInt64
    }
    
    struct VerifyStartMessage: Codable {
        let command: String
        let secondsBeforeDeletion: Double
    }
    
    let channelIDs: ChannelIDs
    let roleIDs: RoleIDs
    let verifyStartMessage: VerifyStartMessage
    
}


