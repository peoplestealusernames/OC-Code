local component = require("component")
local event = require("event")
local track = component.routing_track

local run = true
local userInput

local function setTicket(adress)
	print("changed from "..track.getDestination().." to "..adress)
	print(track.setDestination(adress))
end

while run do
	userInput = io.read()
	if (userInput == "stop") then
		run = false
	else
		setTicket(userInput)
	end
end