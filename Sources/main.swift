import Foundation
import Sword
import PostgreSQLDriver
import FluentProvider

let discordConfigFileName = "discord"
let botTokenKey = "discordBotToken"

guard let token = ProcessInfo.processInfo.environment[botTokenKey] else {
	fataError_flush("No \(botTokenKey) env var")
}

let driver: PostgreSQLDriver.Driver = {
	if let dbURL = ProcessInfo.processInfo.environment["DATABASE_URL"] {
		do {
			print_flush("Using env var for DB URL: \(dbURL)")
			fflush(stdout)
			return try PostgreSQLDriver.Driver(url: dbURL)
		}
		catch {
			fataError_flush(error)
		}
	}
	print_flush("Using localhost for DB URL")
	fflush(stdout)
	return try! PostgreSQLDriver.Driver(masterHostname: "localhost", readReplicaHostnames: [], user: "", password: "", database: "luke")
}()
let database = Database(driver)
try! database.prepare([VerifyStartSignal.self, VerificationRequest.self])

let bytes = try! DataFile(workDir: "").read(at: "Config/Discord/beta.json")
let data = Data(bytes: bytes)

let config = try! JSONDecoder().decode(DiscordConfig.self, from: data)

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
