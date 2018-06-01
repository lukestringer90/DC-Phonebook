import Vapor
import Sword

let bot = Sword(token: "NDUwMzk0OTMwMDYyNDI2MTEy.DfMVYw.AybPKPH18cu1N9BBTvOtr1jqlfw")

extension Droplet {
    func setupRoutes() throws {
        let onMessageController = OnMessageController()
        
        bot.editStatus(to: "online", playing: "In Development")
        bot.on(.messageCreate, do: onMessageController.handler)
        bot.connect()
    }
}
