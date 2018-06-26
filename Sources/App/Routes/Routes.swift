import Vapor
import Sword
import Foundation

extension Droplet {
    func setupRoutes() throws {
        
        let secretsConfigFilename = "secrets"
        let envKey = "discordBotToken"
        
        guard let token = config[secretsConfigFilename, envKey]?.string else {
            fatalError("No \(envKey) value in \(secretsConfigFilename).json")
        }
		
		var options = SwordOptions()
		options.willCacheAllMembers = true
        let bot = Sword(token: token, with: options)
        
        let onMessageController = OnMessageController(discord: bot)
        let onReactionAddController = OnReactionAddController(discord: bot)
        
        bot.editStatus(to: "online", playing: "In Development")
        bot.on(.messageCreate, do: onMessageController.handle)
        bot.on(.reactionAdd, do: onReactionAddController.handle)
        bot.connect()
    }
}

