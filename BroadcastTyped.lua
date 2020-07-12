local defultport = 123

local component = require("component")
local event = require("event")
local m = component.modem -- get primary modem component

local run = true
local userInput

local function sendMsg(msg,port)
	if port == nil then port = defultport end
	print(m.broadcast(port,msg))
	
end

while run do
	userInput = io.read()
	if (userInput == "stop") then
		run = false
	else
		print("*",userInput)
		sendMsg(userInput)
	end
end