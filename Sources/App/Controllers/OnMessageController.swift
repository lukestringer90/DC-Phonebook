//
//  OnMessageController.swift
//  App
//
//  Created by Luke Stringer on 01/06/2018.
//

import Foundation
import Sword

struct OnMessageController {
    func handler(data: Any) {
        guard let message = data as? Message else {
            print("Not a message")
            return
        }
        
        let isBot = message.author?.isBot
        guard isBot == nil || isBot == false else { return }
        
        let content = message.content
        
        switch content {
        case "What time is it?": replyWithTime(in: message)
        case "Hello", "Hi": replyWithGreeting(to: message.author, in: message)
        default: replyWithUnknown(in: message)
        }
        
    }
}

fileprivate extension OnMessageController {
    func replyWithTime(in message: Message) {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        let formatted = formatter.string(from: date)
        message.reply(with: "The time is: \(formatted)")
    }
    
    func replyWithGreeting(to sender: User?, in message: Message) {
        var reply = "Hello"
        if let username = sender?.username {
            reply.append(" \(username)")
        }
        reply.append("!")
        reply.append(" Nice to meet you 👋")
        message.reply(with: reply)
    }
    
    func replyWithUnknown(in message: Message) {
        message.reply(with: "Sorry, I don't currently understand \"\(message.content)\"")
    }
}
