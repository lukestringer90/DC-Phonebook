import Vapor
import Sword
import Foundation

extension Droplet {
    func setupRoutes() throws {
        
        let envKey = "DISCORD_PHONEBOOK_BOT_TOKEN"
        
        guard let token = ProcessInfo.processInfo.environment[envKey] else {
            fatalError("No \(envKey) varaible set")
        }
        
        let bot = Sword(token: token)
        
        let onMessageController = OnMessageController(discord: bot)
        let onReactionAddController = OnReactionAddController(discord: bot)
        
        bot.editStatus(to: "online", playing: "In Development")
        bot.on(.messageCreate, do: onMessageController.handle)
        bot.on(.reactionAdd, do: onReactionAddController.handle)
        bot.connect()
    }
}

