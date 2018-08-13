# Setting up the Bot

## Server Configuration values

Config values needed from the Discord Server:

- **Requests** channel ID. 
- **Directory** channel
- **Logs** channel ID
- **Verifired** role ID. Type `\@verified`

Add these values to the appropriate JSON file in `Config/Discord/<flavour>.json`

## Inviting the Bot

Invited the bot to the Discord Server using:

`https://discordapp.com/oauth2/authorize?&client_id=BOT-TOKEN-HERE&scope=bot&permissions=268516416`

NOTE: `268516416` is the permission integer for:

- Manage Roles
- View Channels
- Send Messages
- Sent TTS Messages
- Manage Messages
- Read Message History
- Add Reactions

See [here](https://github.com/reactiflux/discord-irc/wiki/Creating-a-discord-bot-&-getting-a-token) for more info on making the bot and inviting it.

## Setting Permissions

Once invited the bot will have an "automatically managed" role.

If the channels listed above are private you will need to give the bot some permission. With Developer Mode enabled, right click the channel > Edit Channel > Permissions > Roles/Members + > <Bot Name>. Then enable:

- Read Messages
- Send Messages
- Add Reactions