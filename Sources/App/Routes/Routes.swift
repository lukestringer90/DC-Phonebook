import Vapor
import Sword
import Foundation

extension Droplet {
    func setupRoutes() throws {
        
        let discordConfigFileName = "discord"
        let secretsConfigFilename = "secrets"
        let botTokenKey = "discordBotToken"
        
        guard let token = self.config[secretsConfigFilename, botTokenKey]?.string else {
            fatalError("No \(botTokenKey) value in \(secretsConfigFilename).json")
        }
        
        guard let discordConfigFile = self.config[discordConfigFileName] else {
            fatalError("No \(discordConfigFileName).json")
        }
        let config = DiscordConfig(config: discordConfigFile)
		
		var options = SwordOptions()
		options.willCacheAllMembers = true
        let bot = Sword(token: token, with: options)
        
        let onMessageController = OnMessageController(discord: bot, config: config)
        let onReactionAddController = OnReactionAddController(discord: bot, config: config)
        
        bot.editStatus(to: "online", playing: "In Development")
        bot.on(.messageCreate, do: onMessageController.handle)
        bot.on(.reactionAdd, do: onReactionAddController.handle)
        bot.connect()
    }
}

