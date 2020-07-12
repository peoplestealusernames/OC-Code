local event = require("event")
local table = require("table")
local thread = require("thread")

local ButtonAPI = {}

--[[Made By -10K-
input for ButtonGroups must be a fuction as such

local function GetButtons()
	return {BG1,BG2,BG3,BG4,BG5}
end
ButtonAPI.ClickCheckLoop(GetButtons)

the reason for this is so when the function is called
it will not cach outdated functions
allow rapid button updates can be done
--]]

function ButtonAPI.CreateButton(x,y,w,h,FNC,Params)
	local Button = {}
	Button.x = x
	Button.y = y
	Button.mx = x+w
	Button.my = y+h
	Button["FNC"] = FNC
	Button.FNCP = Params
	
	return Button
end

function ButtonAPI.ClickCheckLoop(ButtonGroups)
	local t1 = thread.create(function(ButtonGroups)
		while true do
			ButtonAPI.WaitForClick(ButtonGroups)
		end
	end,ButtonGroups)
	return t1
end

function ButtonAPI.WaitForClick(ButtonGroups)
	local inst = {event.pull("touch")}
	local _,_,x,y,_,player = table.unpack(inst)
	if not((x == nil) or (y == nil)) then
		RButton = ButtonAPI.CheckClick(x,y,ButtonGroups)
		if (RButton[1] == true) then
			for i, button in pairs(RButton[2]) do
				button.FNC(inst,button.FNCP)
			end
		end
	end
end

function ButtonAPI.CheckClick(x,y,ButtonGroups)
	local OButtons = {}
	local Found = false
	for _, buttongroup in pairs(ButtonGroups()) do
		for i, button in pairs(buttongroup) do
			if ((x>=button.x) and (x<button.mx)) then
				if ((y>=button.y) and (y<button.my)) then
					OButton = table.insert(OButtons,button)
					Found = true
				end
			end
		end 
	end
	return {Found,OButtons}
end

return ButtonAPI