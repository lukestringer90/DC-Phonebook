import Foundation
import Sword
import PostgreSQLDriver
import FluentProvider

// MARK: - Get env vars

let flavourKey = "flavour"
let botTokenKey = "discordBotToken"

guard let token = ProcessInfo.processInfo.environment[botTokenKey] else {
	fataError_flush("No \(botTokenKey) env var")
}

guard let flavour = ProcessInfo.processInfo.environment[flavourKey] else {
	fataError_flush("No \(flavourKey) env var")
}

print_flush("Running as \(flavour) flavour")

// MARK: - Database setup

func setupDatabase(){
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
}

// MARK: - Discor Bot setup

func setupBot(token: String, config: DiscordConfig) {
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

// MARK: - Load flavour config

func loadConfig(from flavour: String) -> DiscordConfig {
	
	let bytes = try! DataFile(workDir: "").read(at: "Config/Discord/\(flavour).json")
	let data = Data(bytes: bytes)
	return try! JSONDecoder().decode(DiscordConfig.self, from: data)
}

// MARK: - Run setup processes

setupDatabase()
let config = loadConfig(from: flavour)
setupBot(token: token, config: config)

RunLoop.current.run(mode: .defaultRunLoopMode, before: Date.distantFuture)

