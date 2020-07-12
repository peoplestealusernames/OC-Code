local component = require("component")
local term = require("term")
local table = require("table")
local event = require("event")
local thread = require("thread")
local computer = require("computer")
local ScrollAPI = require("ScrollAPI")
local ButtonAPI = require("ButtonAPI")
local text = require("text")
local serialization = require("serialization")
local keyboard = require("keyboard")
local gpu = component.gpu
local ae2 = component.me_interface
local GlobButtons = {}
local TopButtons = {}
local CraftingButtons = {}
local CraftingSideButtons = {}
local EditBoxNum = 0
local SideCrafting = {}
local Menu = "None"
local CurrentlyCrafting = {}
local MINREQ = 10
local DisplayCrafting = {}
local TEMPThreads = {}

local w,h = gpu.getResolution()
local BFNC,SFNC,GetCraftingTabel,AddTopBar,AddCraftingBar,ClearButtons,ClearMenu

--for k, v in ipairs(ae2) do print(tostring(k),tostring(v)) end
--print(serialization.serialize(ae2,10000))

local function inArray(array, value)
    for _, val in ipairs(array) do
        if value == val then
            return true
        end
    end
	
    return false
end

local function GetBuffer(Item)
	local file,_ = io.open("ae2_CraftingList","r")
	if (file == nil) then
		file,_ = io.open("ae2_CraftingList","w")
	end
	local stri = file:read()
	file:close()
	if not(stri == nil) then
		local array = serialization.unserialize(stri)
		for i,Item1 in pairs(array) do
			if (Item1.label == Item.label) then
				if (Item1.name == Item.name) then
					if (Item1.damage == Item.damage) then
						return Item1.buffer
					end
				end
			end
		end
	end
	return -1
end

local function GetAllBuffers()
	local file,_ = io.open("ae2_CraftingList","r")
	if (file == nil) then
		file,_ = io.open("ae2_CraftingList","w")
	end
	local stri = file:read()
	file:close()
	if not(stri == nil) then
		local array = serialization.unserialize(stri)
		return array
	end
	return {}
end

local function ReqMenu(EH,ARG)
	local ae2 = ARG[1]
	ClearMenu(EH,ARG)
	Menu = "ReqMenu"
	
	local List = GetCraftingTabel(ae2)
	AddCraftingBar(SideCrafting,"Pick a item","0",nil)
	local T1 = ScrollAPI.createScroll(List, 1, 2, math.floor(w/2), h-1, 2, BFNC, SFNC)
	table.insert(TEMPThreads,T1)
	AddTopBar(ae2)
end

local function MonitorMenu(EH,ARG)
	local ae2 = ARG[1]
	ClearMenu(EH,ARG)
	Menu = "Monitor"
end

function ClearMenu(EH,ARG)
	local ae2 = ARG[1]
	Menu = "None"
	gpu.setBackground(0x000000)
	gpu.setForeground(0xffffff)
	term.clear()
	ClearButtons()
	AddTopBar(ae2)
	for i,Val in pairs(TEMPThreads) do
		Val:kill()
	end
	TEMPThreads = {}
end

function AddTopBar(ae2)
	TopButtons = {}
	gpu.setBackground(0xff0000)
	gpu.setForeground(0x000000)
	gpu.fill(1,1,w,1," ")
	
	gpu.set(2,1,"ReqMenu")
	local button = ButtonAPI.CreateButton(2,1,#"ReqMenu",1,ReqMenu,{ae2})
	table.insert(TopButtons,button)
	
	gpu.set(10,1,"ClearTerm")
	local button = ButtonAPI.CreateButton(10,1,#"ClearTerm",1,ClearMenu,{ae2})
	table.insert(TopButtons,button)
	
	gpu.set(20,1,"Monitor")
	local button = ButtonAPI.CreateButton(20,1,#"Monitor",1,MonitorMenu,{ae2})
	table.insert(TopButtons,button)
end

local function CraftItemFNC(CraftNet,Req)
	local Data = nil
	if (Req>0) then
		if (Req>=MINREQ) then 
			if not(CraftNet == nil) then
				Data=CraftNet.request(Req)
				return "Crafting",Data
			else
				return "No recipe",Data
			end
		else
			return "Request to small",Data
		end
	else
		return "Buffer full",Data
	end
	return "Error",Data
end

local function CheckAutoCrafting(ae2)
	local Buffers = GetAllBuffers()
	local AllCrafting = ae2.getCraftables()
	local Crafting = {}
	local OCTable = {}
	
	for i,Val in pairs(CurrentlyCrafting) do
		local FiltTab,Amount,FNC = table.unpack(Val)
		if(FNC.Don() or FNC.Can()) then
			CurrentlyCrafting[i] = nil
		else
			Crafting[serialization.serialize(FiltTab)] = Amount
		end
	end
	
	for i,Item in pairs(Buffers) do
		local Buffer = Item.buffer
		local FiltTab = {name = Item.name, damage = Item.damage, label = Item.label}
		local CraftItems = ae2.getCraftables(FiltTab)
		local RealItems = ae2.getItemsInNetwork(FiltTab)
		local RealItem = RealItems[1]
		local Return = "Error"
		local TryCraft = true
		local Stored = 0
		
		if (CraftItems[1] == nil) then
			Return = "No known recipe"
			TryCraft = false
		else
			local CraftItem = CraftItems[1].getItemStack()
		end
		if (TryCraft) then
			local ItemCrafting = Crafting[serialization.serialize(FiltTab)] 
			if (ItemCrafting == nil) then
				ItemCrafting = 0
			end
			local Req = 0
			local data = nil
			
			if not(Buffer == nil) then
				if not(RealItem == nil) then
					Stored = RealItem.size
					Req = Buffer-Stored-ItemCrafting
				else
					Req = Buffer-ItemCrafting
				end
				
				Return,data = CraftItemFNC(CraftItems[1],Req)
			else
				Return = "No Buffer"
			end
			
			if not(data == nil) then
				if (data.isCanceled()) then
					Return = "Could not craft"
				else
					Return = "Crafting"
					table.insert(CurrentlyCrafting,{FiltTab,Req,{Don = data.isDone,Can = data.isCanceled}})
				end
			end
		end--TryCraft
		table.insert(OCTable,{Item,Return,Stored})
		os.sleep(1)
	end
	return OCTable
end

function GetCraftingTabel(ae2)
	local OList = {}
	for i,Crafty in pairs(ae2.getCraftables()) do
		if not(i == "n") then
			local Item = Crafty.getItemStack()
			local RealItems = ae2.getItemsInNetwork({name = Item.name, damage = Item.damage, label = Item.label})
			local RealItem = RealItems[1]
			local buffer = GetBuffer(Item)
			
			RealItem.buffer = buffer
			table.insert(OList,RealItem)
		end
	end
	return OList
end

local function UpdateEditBox(x,y,w2,h2,val)
	gpu.setBackground(0xffffff)
	gpu.setForeground(0x000000)
	gpu.fill(x,y,w2,h2," ")
	gpu.set(x+w2/2-#val/2,y+h2/2,val)
end

local function EditButton(EH,ARG)
	local x = ARG.x
	local y = ARG.y
	local w2 = ARG.w2
	local h2 = ARG.h2
	
	local loop = true
	while loop do 
		UpdateEditBox(x,y,w2,h2,tostring(EditBoxNum).." (EDITING)")
		local _,_,_,key,player = event.pull("key_down")
		local test = keyboard.keys[key]
		local num = tonumber(test)
		if (test == "enter") then
			loop = false
			UpdateEditBox(x,y,w2,h2,tostring(EditBoxNum))
		elseif not(num == nil) then
			EditBoxNum=EditBoxNum*10+num
			UpdateEditBox(x,y,w2,h2,tostring(EditBoxNum).." (EDITING)")
		elseif (test == "back") then
			EditBoxNum=math.floor(EditBoxNum/10)
			UpdateEditBox(x,y,w2,h2,tostring(EditBoxNum).." (EDITING)")
		else
			print(test)
		end
	end
end

local function addEditButton(x,y,w2,h2)
	UpdateEditBox(x,y,w2,h2,"0")
	EditBoxNum = 0
	local ARG = {}
	ARG.x = x
	ARG.y = y
	ARG.w2 = w2
	ARG.h2 = h2
	local button = ButtonAPI.CreateButton(x,y,w2,h2,EditButton,ARG)
	table.insert(CraftingSideButtons,button)
end

local function ApplyButton(EH,ARG)
	local Item = ARG.Item
	local Buffer = EditBoxNum
	if not(Item == nil) then
		local NArr = {}
		NArr.label = Item.label
		NArr.damage = Item.damage
		NArr.name = Item.name
		NArr.buffer = Buffer
		local Stri1 = ""
		local file,_ = io.open("ae2_CraftingList","r")
		if (file == nil) then
			file,_ = io.open("ae2_CraftingList","w")
		end
		local stri = file:read()
		file:close()
		if not(stri == nil) then
			local array = serialization.unserialize(stri)
			local TempTF = false
			for i,Item1 in pairs(array) do
				if (Item1.label == Item.label) then
					if (Item1.name == Item.name) then
						if (Item1.damage == Item.damage) then
							if (Buffer>0) then
								TempTF = true
								array[i] = NArr
							else
								array[i] = nil
							end
						end
					end
				end
			end
			if not(TempTF) then
				if (Buffer>0) then
					table.insert(array,NArr)
				end
			end
			Stri1 = serialization.serialize(array)
		else
			Stri1 = serialization.serialize({NArr})
		end
		local file,_ = io.open("ae2_CraftingList","w")
		file:write(Stri1)
		file:close()
		ReqMenu({},{ae2})
	end
end

function AddCraftingBar(Dim,msg1,msg2,item)
	CraftingSideButtons = {}
	
	x = Dim.x
	y = Dim.y
	w1 = Dim.w1
	h1 = Dim.h1
	
	gpu.setForeground(0x000000)
	gpu.setBackground(0x646464)
	gpu.fill(x,y,w1,h1," ")
	gpu.setBackground(0xff0000)
	gpu.fill(x+w1/2-w1/4,y+5,w1/2,4, " ")
	gpu.set(x+w1/2-#msg1/2,y+6, msg1)
	gpu.set(x+w1/2-#msg2/2,y+7, msg2)
	gpu.setBackground(0x646464)
	gpu.fill(x+w1/2-w1/4,y+9,w1/2,2, " ")
	local msg = "Fill to amount"
	gpu.set(x+w1/2-#msg/2,y+10, msg)
	local msg = "click to edit enter to confirm"
	gpu.set(x+w1/2-#msg/2,y+12, msg)
	local msg = "Apply"
	gpu.setBackground(0xff0000)
	gpu.fill(x+w1/2-w1/8,y+14,w1/4,3," ")
	gpu.set(x+w1/2-#msg/2,y+15, msg)
	local ARG = {}
	ARG.Item = item
	local button = ButtonAPI.CreateButton(x+w1/2-w1/8,y+14,w1/4,3,ApplyButton,ARG)
	table.insert(CraftingSideButtons,button)
	gpu.setBackground(0xffffff)
	addEditButton(x+w1/2-w1/8,y+11,w1/4,1)
end

function SFNC(index,list,bx,by,w,h2)
	CraftingButtons = {}
end

local function CraftingMenuFNC(EH, item)
	local msg = tostring(item.size)
	local buffer = item.buffer
	if (buffer>0) then 
		msg = msg.."/"..tostring(buffer)
	end
	AddCraftingBar(SideCrafting,item.label,msg,item)
end

function BFNC(index, item, x, y, w2, h2)
	local text = {item.label}
	local buffer = item.buffer
	local button = ButtonAPI.CreateButton(x,y,w2,h2,CraftingMenuFNC,item)
	table.insert(CraftingButtons,button)
	local msg = tostring(item.size)
	if (buffer>0) then 
		msg = msg.."/"..tostring(buffer)
	end
	table.insert(text, msg)
	if not(text == {}) then
		for i1,text1 in pairs(text) do
			gpu.set(x+(w2/2)-(#text1/2),y+(i1-1)*1,text1)
		end
	end
end

local function CPUsBusy(ae2)
	for i,Cpui in pairs(ae2.getCpus()) do
		if not(i=="n") then
			if (Cpui.busy) then
				return true
			end
		end
	end
	return false
end

local function MonitorBFNC(index, Tab, x, y, w2, h2)
	local Item,Return,Stored = table.unpack(Tab)
	local text = {Item.label}
	local buffer = Item.buffer
	local msg = tostring(Stored)
	if (buffer>0) then 
		msg = msg.."/"..tostring(buffer)
	end
	table.insert(text, msg)
	table.insert(text, Return)
	if not(text == {}) then
		for i1,text1 in pairs(text) do
			gpu.set(x+(w2/2)-(#text1/2),y+(i1-1)*1,text1)
		end
	end
end

local function MonitorSFNC()
	
end

function ClearButtons()
	CraftingButtons = nil
	GlobButtons = nil
	TopButtons = nil
	CraftingSideButtons = nil
end

--starts execution
SideCrafting.x = 1+w/2
SideCrafting.y = 2
SideCrafting.w1 = w/2
SideCrafting.h1 = h-1

term.clear()

AddTopBar(ae2)
gpu.setBackground(0xffffff)

local function GetButtons()
	return {CraftingButtons,GlobButtons,TopButtons,CraftingSideButtons}
end
ButtonAPI.ClickCheckLoop(GetButtons)

local CraftinLoop = true
while CraftinLoop do
	DisplayCrafting = {stri = "Waiting for CPUs to finish"}
	CraftinLoop = CPUsBusy(ae2)
	if (CraftinLoop) then
		gpu.setBackground(0xffffff)
		gpu.setForeground(0x000000)
		local text = "Wating for CPU to finish"
		gpu.set((w/2)-(#text/2),h/2,text)
		os.sleep(10)
	end
end

while true do
	DisplayCrafting = CheckAutoCrafting(ae2)
	if(Menu == "Monitor") then
		gpu.setBackground(0x000000)
		gpu.setForeground(0xffffff)
		local T1 = ScrollAPI.createScroll(DisplayCrafting, 1, 2, w, h-1, 3, MonitorBFNC, MonitorSFNC)
		table.insert(TEMPThreads,T1)
	end
	os.sleep(5)
end


