import App
import Sword


let bot = Sword(token: "NDUwMzk0OTMwMDYyNDI2MTEy.DfMVYw.AybPKPH18cu1N9BBTvOtr1jqlfw")

bot.editStatus(to: "online", playing: "Testing!")

bot.on(.messageCreate) { data in
    let msg = data as! Message
    
    if msg.content == "!ping" {
        msg.reply(with: "Pong!")
    }
}

bot.connect()
