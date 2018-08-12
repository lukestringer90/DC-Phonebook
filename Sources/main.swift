import Foundation
import Sword
import PostgreSQLDriver
import FluentProvider

let discordConfigFileName = "discord"
let botTokenKey = "discordBotToken"

guard let token = ProcessInfo.processInfo.environment[botTokenKey] else {
	print_flush("No \(botTokenKey) env var")
    abort()
}

let driver: PostgreSQLDriver.Driver = {
	if let dbURL = ProcessInfo.processInfo.environment["DATABASE_URL"] {
		do {
			print_flush("Using env var for DB URL: \(dbURL)")
			fflush(stdout)
			return try PostgreSQLDriver.Driver(url: dbURL)
		}
		catch {
			print_flush(error)
			abort()
		}
	}
	print_flush("Using localhost for DB URL")
	fflush(stdout)
	return try! PostgreSQLDriver.Driver(masterHostname: "localhost", readReplicaHostnames: [], user: "", password: "", database: "luke")
}()
let database = Database(driver)
try! database.prepare([VerifyStartSignal.self, VerificationRequest.self])

// TODO: Either read from proper env config JSON or change
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
