//
//  Sword+LoggingService.swift
//  App
//
//  Created by Luke Stringer on 17/06/2018.
//

import Foundation
import Sword

extension Sword: LoggingService {
    func log(_ event: Event) {
        sendMessage(event.message(), to: Constants.Discord.ChannelID.logs) { errorOrNil in
            if let error = errorOrNil {
                print("Error sending log: \(error)")
            }
        }
    }    
}
