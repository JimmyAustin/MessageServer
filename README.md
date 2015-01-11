# MessageServer
MessageServer injects a small HTTP server into MobileSMS, so you can remotely send and receive SMS and iMessage via a REST interface.

The server starts as soon as you boot up MobileSMS.app, and will persist through app suspension.

Until I add some sort of toggle, I highly reccommend only having the tweak installed while you are actively using it.

# API

<iPhone IP>:12345/getMessages/<Sender>

Gets all messages from a sender. The sender can either be a telephone number (including area code, ex +61 432 123 456), or an iMessage account (IE, example@example.com).

The response is a JSON array full of objects with three fields. Message, date (in seconds since Jan 1st, 2001), and sender.

Example:

[{"message":"What's going on?","date":434196098,"sender":"+61450123456"}]

<iPhone IP>:12345/getNewMessages

Gets all messages that have arrived since the last time this was called. It might take a while for the first call.

The response is a JSON array full of objects with three fields. Message, date (in seconds since Jan 1st, 2001), and sender.

Example:

[{"message":"What's going on?","date":434196098,"sender":"+61450123456"}]

<iPhone IP>:12345/sendMessage/<receipient>/<message>

Sends the message to the receipient.

The response should be a simple "{"code":200}


TODO:
-Extra security. Perhaps a settings panel that lets you set a random token.
-Enable HTTPS. Will need to sort something out for certificates.
-Toggle.

