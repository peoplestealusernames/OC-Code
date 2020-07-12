local component = require("component")
local term = require("term")
local table = require("table")
local event = require("event")
local thread = require("thread")
local computer = require("computer")
local ScrollAPI = require("ScrollAPI")
local ButtonAPI = require("ButtonAPI")
local gpu = component.gpu

ScrollButtons = {}

local w,h = gpu.getResolution()

local List = {}
local strings = {}

for i=1,200,1 do
	table.insert(strings,"test"..tostring(i))
end

for i,stri in pairs(strings) do
	local insert = {}
	insert.name = stri
	table.insert(List,insert)
end

local function SFNC(index,list,bx,by,w,h2)
	gpu.set(90,12,tostring(#ScrollButtons).." "..tostring(computer.uptime()))
	ScrollButtons = {}
end

function buttonFNC(EH, name)
	gpu.set(90,10,name)
end

local function BFNC(index, item, x, y, w, h)
	local msg = item.name
	gpu.set(x+(w/2)-#msg/2,y+.5,msg)
	local button = ButtonAPI.CreateButton(x,y,w,h,buttonFNC,item.name)
	table.insert(ScrollButtons,button)
end

local function GetButtons()
	return {ScrollButtons}
end
ScrollAPI.createScroll(List, 1, 1, w/2, h-1, 1, BFNC, SFNC)
ButtonAPI.ClickCheckLoop(GetButtons)
