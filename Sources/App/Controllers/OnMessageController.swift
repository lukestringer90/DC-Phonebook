//
//  OnMessageController.swift
//  App
//
//  Created by Luke Stringer on 01/06/2018.
//

import Foundation
import Sword

class OnMessageController {
	let discord: Sword
    var wizard: VerificationRequestWizard?
	
    init(discord: Sword) {
        self.discord = discord
    }
    
    func handler(data: Any) {
        guard let message = data as? Message else {
            print("Not a message")
            return
        }
		
		guard let user = message.author else {
			print("No author")
			return
		}
		
		print("Channel: \(message.id)")
        print("From: \(user.username ?? "null")")
		print("Message: \(message.content)")
		
		let isBot = message.author?.isBot
		guard isBot == nil || isBot == false else { return }
		
		message.author?.getDM(then: { dmOrNil, error in
			guard let dm = dmOrNil else {
				print("Could not get DM")
                error.flatMap { print($0) }
				return
			}
            
            if message.content == "!verify" {
                self.wizard = VerificationRequestWizard()
            }
            else {
                if let wizard = self.wizard {
                    wizard.inputMessage(message.content)
                }
            }
            self.discord.send(self.wizard!.state.userMessage, to: dm.id)
		})
	}
}

fileprivate struct Discord {
    struct Username {
        static let phonebookBot = "DC-Phonebook"
    }
    
    struct ChannelID {
        static let general = "452225589978464267"
        static let botDebug = "452229749927051278"
        static let dm_lukestringer90 = "452225869667368960"
    }
}

