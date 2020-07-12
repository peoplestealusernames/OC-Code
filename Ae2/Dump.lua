while true do
	for Crafty,v in pairs(ae2.getCraftables()) do
		if not(Crafty == "n") then
			draw(0.1,0.1*i,0.1,0.1,Crafty.name,0xFFFFFF,0x000000)
		end
	end
	os.sleep(10)
end


print(tostring(ae2.getCraftables()))

local component = require("component")
local ae2 = component.me_interface
for Crafty,_ in pairs(ae2.getCraftables()) do print(tostring(Crafty))end
component.me_interface.getCraftys()[1].getItemStack()
{
damage
tag
label
maxDamage
maxSize
name
size
}


	print(" ")
	print(tostring(x))
	print(tostring(y))
	print(tostring(w2))
	print(tostring(h2))
	
	
local function GetCraftingTabel()
	gpu.setBackground(0x646464)
	CraftingButtons = {}
	local x = 1+w/2
	local y = 2
	local w1 = w/2
	local h1 = h-1
	gpu.fill(x,y,w1,h1," ")
	gpu.setBackground(0xff0000)
	gpu.fill(x+w1/4,y+5,w1/2,4, " ")
	local msg = "Pick a item"
	gpu.set(x+w1/2-#msg/2,y+6, msg)
	local msg = "0"
	gpu.set(x+w1/2-#msg/2,y+7, msg)
	for i,Crafty in pairs(ae2.getCraftables()) do
		if not(i == "n") then
			if (i % 2 == 0) then
				gpu.setBackground(0xffffff)
			else
				gpu.setBackground(0xc8c8c8)
			end
			gpu.setForeground(0x000000)
			local Item = Crafty.getItemStack()
			local items = ae2.getItemsInNetwork({name = Item.name})
			local text = {Item.label}
			local buffer = 1;
			local x = 1
			local y = 2*i
			local w2 = 0.5*w
			local h2 = 2
			gpu.fill(x,y,w2,h2," ")
			local button = {}
			button.x = x
			button.y = y
			button.mx = w2+x
			button.my = h2+y
			button.FNCP = Item.label
			function button.FNC(name)
				print(name)
			end
			table.insert(CraftingButtons,button)
			local msg = tostring(items[1].size)
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
	end
end