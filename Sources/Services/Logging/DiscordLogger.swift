//
//  SwordLogger.swift
//  App
//
//  Created by Luke Stringer on 26/06/2018.
//

import Foundation
import Sword

struct DiscordLogger {
    let discord: Sword
    let channelID: RecepientID
}

extension DiscordLogger: LoggingService {
    func log(_ event: Event) {
        self.discord.sendMessage(event.message(), to: channelID) { errorOrNil in
            if let error = errorOrNil {
                print_flush("Error sending log: \(error)")
            }
        }
    }
}

extension Sword {
    func logger(forChannel channelID: RecepientID) -> DiscordLogger {
        return DiscordLogger(discord: self, channelID: channelID)
    }
}
