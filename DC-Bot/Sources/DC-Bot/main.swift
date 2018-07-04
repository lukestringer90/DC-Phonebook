import Foundation
import Sword
import DC_BotCore

let discordConfigFileName = "discord"
let botTokenKey = "discordBotToken"

//guard let token = ProcessInfo.processInfo.environment[botTokenKey] else {
//    fatalError("No \(botTokenKey) env var")
//}

let token = "NDUwMzk0OTMwMDYyNDI2MTEy.DhwRgg.pAeg8PIXalSM9b3OB_PGfjbFX2k"

let config = DiscordConfig(channelIDs: DiscordConfig.ChannelIDs(phoneBookRequests: UInt64(450397327295905803), phoneBookDirectory: UInt64(450397213319757854), logs: UInt64(450397168046440449)), roleIDs: DiscordConfig.RoleIDs(verified: 455104920673058817), verifyStartMessage: DiscordConfig.VerifyStartMessage(command: "!verify", secondsBeforeDeletion: 7.0))

var options = SwordOptions()
options.willCacheAllMembers = true
let bot = Sword(token: token, with: options)

let onMessageController = OnMessageController(discord: bot, config: config)
let onReactionAddController = OnReactionAddController(discord: bot, config: config)

bot.editStatus(to: "online", playing: "In Development")
bot.on(.messageCreate, do: onMessageController.handle)
bot.on(.reactionAdd, do: onReactionAddController.handle)
bot.connect()

let runLoop = RunLoop.current
let distantFuture = Date.distantFuture

runLoop.run(mode: .defaultRunLoopMode, before: distantFuture)
