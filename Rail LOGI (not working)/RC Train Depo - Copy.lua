local component = require("component")
local event = require("event")
local text = require("text")
local thread = require("thread")

local depotype = "chest"
local port = 19294
local inredstone = 3
local outredstone = 5

local m = component.modem
local redstone = component.redstone
local track = component.routing_track

if not (m.isWireless()) then 
	print("EXIT CODE:Computer is not wireless please add wireless card")
	os.exit()
end
m.close()
m.open(port)
if not (m.isOpen(port)) then 
	print("EXIT CODE:Could not open port:"..tostring(port))
	os.exit()
end
if (track.getDestination == false) then
	print("EXIT CODE:use crowbar to put golden ticket in routing track")
	os.exit()
end
if (redstone == nil) then
	print("EXIT CODE:connect to redstone io for train check")
	os.exit()
end

m.setStrength(1000)
print("Broadcast ditsnace:"..tostring(m.getStrength()))

local function sendMsg(msg,sendPort)
	if sendPort == nil then sendPort = port end
	local didsend = m.broadcast(sendPort,msg)
	print("Broadcasted:'"..msg.."' to port:"..sendPort)
end

local function TrainAvailable() 
	local train = false
	print(redstone.getInput(inredstone))
	print("Out:"..redstone.getOutput(outredstone))
	if(redstone.getInput(inredstone)>0) then
		if(redstone.getOutput(outredstone)==0) then
			train = true
		end
	end
	return train
end

local function setTicket(adress)
	print("changed from "..track.getDestination().." to "..adress)
	print(track.setDestination(adress))
end

local function ReleaseTrain()
	redstone.setOutput(outredstone,16)
	while (redstone.getInput(inredstone)>0) do
		os.sleep(0.5)
	end
	redstone.setOutput(outredstone,0)
end

local function MSGForUs(MSGSplit,msg,from,port)
	local FuncStri = MSGSplit[2]
	print("FNC:"..FuncStri)
	if (FuncStri == "Request") then
		print("Request")
		--Depo Request *type* *TicketChar*
		local TrainType = MSGSplit[3]
		local Ticket = MSGSplit[4]
		if (TrainType == depotype) then
			print("DEPO")
			local train = TrainAvailable()
			if (train) then
				print("MSG")
				sendMsg("Mainframe R "..Ticket.." FoundTrain")
			end
		end
	end
	if (FuncStri == "SendTrain") then
		--m.send(address, tonumber(port), "Depo SendTrain "..stationAdress..Ticket)
		local stationAdress = MSGSplit[3]
		local Ticket = MSGSplit[4]
		if (TrainAvailable()) then
			print(from,port,"Mainframe R "..Ticket.." Sent")
			m.send(from,port,"Mainframe R "..Ticket.." Sent")
			setTicket(stationAdress)
			ReleaseTrain()
		else
			m.send(from,port,"Mainframe R "..Ticket.." Failed")
		end
	end
end

local function MSGRecived(msg,from,port)
	if not (msg == nil) then
		local MSGSplit = text.tokenize(msg)
		if (MSGSplit[1] == "Depo") then 
			print("PROCCESSING:"..msg)
			MSGForUs(MSGSplit,msg,from,port)
		end
	end
end

local function CheckForMSG()
	local _, _, from, port, _, message = event.pull( "modem_message" ) -- parts with "_" are not stored
	print("RAW : Got "..tostring(message).." from "..from.." on port "..port)
	thread.create(function(message,from,port)
		MSGRecived(tostring(message),from,port)
	end,message,from,port)
end

while true do
	CheckForMSG()
end