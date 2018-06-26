//
//  DiscordConfig.swift
//  App
//
//  Created by Luke Stringer on 26/06/2018.
//

import Foundation

struct DiscordConfig {
    
    struct ChannelIDs {
        let phoneBookRequests: UInt64
        let phoneBookDirectory: UInt64
        let logs: UInt64
    }
    
    struct RoleIDs {
        let verified: UInt64
    }
    
    struct VerifyStartMessage {
        let command: String
        let secondsBeforeDeletion: Double
    }
    
    let channelIDs: ChannelIDs
    let roleIDs: RoleIDs
    let verifyStartMessage: VerifyStartMessage
    
}

extension DiscordConfig {
    init(config: Config) {
        guard let channelIDs = config["channelIDs"] else {
            fatalError("No channelIDs in config.")
        }
        
        guard let roleIDs = config["roleIDs"] else {
            fatalError("No roleIDs in config.")
        }
        
        guard let verifyStartMessage = config["verifyStartMessage"] else {
            fatalError("No verifyStartMessage in config.")
        }
        
        self.channelIDs = ChannelIDs(config: channelIDs)
        self.roleIDs = RoleIDs(config: roleIDs)
        self.verifyStartMessage = VerifyStartMessage(config: verifyStartMessage)
        
    }
}

extension DiscordConfig.ChannelIDs {
    init(config: Config) {
        guard let phoneBookRequests = config["phoneBookRequests"]?.int else {
            fatalError("No int phoneBookRequests in config.")
        }
        
        guard let phoneBookDirectory = config["phoneBookDirectory"]?.int else {
            fatalError("No int phoneBookDirectory in config.")
        }
        
        guard let logs = config["logs"]?.int else {
            fatalError("No int logs in config.")
        }
        
        self.phoneBookRequests = UInt64(phoneBookRequests)
        self.phoneBookDirectory = UInt64(phoneBookDirectory)
        self.logs = UInt64(logs)
    }
}

extension DiscordConfig.RoleIDs {
    init(config: Config) {
        guard let verified = config["verified"]?.int else {
            fatalError("No int verified in config.")
        }
        
        self.verified = UInt64(verified)
    }
}

extension DiscordConfig.VerifyStartMessage {
    init(config: Config) {
        guard let command = config["command"]?.string else {
            fatalError("No string command in config.")
        }
        
        guard let secondsBeforeDeletion = config["secondsBeforeDeletion"]?.double else {
            fatalError("No double secondsBeforeDeletion in config.")
        }
        
        self.command = command
        self.secondsBeforeDeletion = secondsBeforeDeletion
    }
}
