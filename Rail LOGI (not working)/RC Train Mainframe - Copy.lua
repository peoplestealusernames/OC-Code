local component = require("component")
local event = require("event")
local text = require("text")
local thread = require("thread")
--local filesystem = require("filesystem")

local m = component.modem
local DefultPort = 19294
local MaxRefTime = 10 --amount of times in seconds until the message is rebroadcast for a depo to respond

GlobalTicket = 0

local CheckForMSG,RequestTrainLoop

local function ResetDir()
	os.execute("rm -r Tickets")
	os.execute("mkdir Tickets")
end

ResetDir()

if not (m.isWireless()) then 
	print("EXIT CODE:Computer is not wireless please add wireless card")
	os.exit()
end
m.close()
m.open(DefultPort)
if not (m.isOpen(DefultPort)) then 
	print("EXIT CODE:Could not open DefultPort:"..tostring(DefultPort))
	os.exit()
end

m.setStrength(1000)
print("Broadcast ditsnace:"..tostring(m.getStrength()))

local function sendMsg(msg,sendPort)
	if sendPort == nil then sendPort = DefultPort end
	local didsend = m.broadcast(sendPort,msg)
	print("Broadcasted:'"..msg.."' to Port:"..sendPort)
end

local function MakeTicket()
	GlobalTicket = GlobalTicket+1
	local Ticket = GlobalTicket
	return Ticket
end

local function GetTicketDir(numb)
	return "Tickets/"..numb
end

local function DelTicket(numb)
	os.execute("del "..GetTicketDir(numb))
	print("Deleted Ticket:"..numb)
end

local function RequestTrain(TrainType)
	local Ticket = MakeTicket()
	local train = nil
	local MSG = "Depo Request "..TrainType.." "..Ticket
	sendMsg(MSG)
	local ticketFileDir = GetTicketDir(Ticket)
	
	local file = io.open(ticketFileDir,"w")
	file:close()
	print("Creating Ticket file:"..Ticket)
	
	local stri,ticketFile,Reply,address,port,striSplit
	local tries = 0
	
	local result = false
	while not result do
		tries = tries+1
		--CheckForMSG()--testing only
		ticketFile = io.open(ticketFileDir,"r")
		stri = ticketFile:read()
		if not (stri==nil) then 
			striSplit = text.tokenize(stri)
			Reply = striSplit[1]
			address = striSplit[2]
			port = striSplit[3]
			
			train = {Reply,address,port,Ticket}
			result = true
			print("Ticket:"..Ticket.." got depo respond")
		end
		ticketFile:close()
		os.sleep(1)
		if (tries>MaxRefTime) then
			train = nil
			result = true
			print("Timed out on ticket "..Ticket.." refreshing")
			DelTicket(Ticket)
		end
	end
	return train
end

local function SendTrain(Train,stationAdress,TrainType)
	--local Reply,address,port,Ticket = train
	local ret = false
	local Reply = Train[1]
	local address = Train[2]
	local port = Train[3]
	local Ticket = Train[4]
	
	local ticketFileDir = GetTicketDir(Ticket)
	local stri,ticketFile,striSplit,Reply1
	
	ticketFile = io.open(ticketFileDir,"w")
	ticketFile:write("")
	ticketFile:close()
	
	print(address, tonumber(port), "Depo SendTrain "..stationAdress.." "..Ticket)
	m.send(address, tonumber(port), "Depo SendTrain "..stationAdress.." "..Ticket)
	
	local times = 0
	local result = false
	while not result do
		times=times+1
		--CheckForMSG()--testing only
		ticketFile = io.open(ticketFileDir,"r")
		stri = ticketFile:read()
		if not (stri==nil) then
			striSplit = text.tokenize(stri)
			Reply1 = striSplit[1]
			if (Reply1=="Failed") then 
				print("Failed request after sent Ticket:"..Ticket)
				RequestTrainLoop(TrainType,stationAdress)
				DelTicket(Ticket)
				result=true
			end
			if (Reply1=="Sent") then 
				print("Sent train to station:"..stationAdress)
				DelTicket(Ticket)
				result=true
			end
		end
		if (times>20) then 
			print("ERROR:No response recived after requesting train to leave Ticket:"..Ticket)
			DelTicket(Ticket)
			result=true
		end
		ticketFile:close()
		os.sleep(1)
	end
end

function RequestTrainLoop(TrainType,stationAdress)
	local train
	print("Requesting "..TrainType.." to "..stationAdress)
	while train==nil do
		train = RequestTrain(TrainType)
	end
	print("Sending Train")
	SendTrain(train,stationAdress,TrainType)
end

local function MSGForUs(MSGSplit,msg,from,port)
	local FuncStri = MSGSplit[2]
	print("FNC:"..FuncStri)
	if (FuncStri == "RequestTrain") then
		local TrainType = MSGSplit[3]
		local stationAdress = MSGSplit[4]
		--Mainframe RequestTrain *type* *send adress*
		RequestTrainLoop(TrainType,stationAdress)
	end
	if (FuncStri == "R") then
		local Ticket = MSGSplit[3]
		local Reply = MSGSplit[4]
		local ticketFileDir = GetTicketDir(Ticket)
		local ticketFile = io.open(ticketFileDir,"a")
		ticketFile:write(Reply.." "..from.." "..port)
		ticketFile:close()
		print("TICKET:"..Ticket.." edited")
	end
end

local function MSGRecived(msg,from,port)
	if not (msg == nil) then
		local MSGSplit = text.tokenize(msg)
		if (MSGSplit[1] == "Mainframe") then 
			print("PROCCESSING:"..msg)
			MSGForUs(MSGSplit,msg,from,port)
		end
	end
end

function CheckForMSG()
	local _, _, from, port, _, message = event.pull( "modem_message" ) -- parts with "_" are not stored
	print("RAW : Got "..tostring(message).." from "..from.." on port "..port)
	thread.create(function(message,from,port)
		MSGRecived(tostring(message),from,port)
	end,message,from,port)
	--dissable threads to get error
end

while true do
	CheckForMSG()
end
