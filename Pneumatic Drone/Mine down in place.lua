local component = require("component")
local thread = require("thread")
local gpu = component.gpu
local Drones = {}

for address in component.list('droneInterface') do
  local item = component.proxy(address)
  item.Pos = nil
  table.insert(Drones, item)
end

gpu.setBackground(0x000000)
gpu.setForeground(0xffffff)

while true do
	for _,Drone in pairs(Drones) do
		if(Drone.isConnectedToDrone()) then
			gpu.setBackground(0x000000)
			gpu.setForeground(0xffffff)
			local pos = Drone.Pos -- defined table
			if(pos == nil) then 
				pos = {Drone.getDronePosition()}
			end
			if (Drone.isActionDone() == true or Drone.isActionDone() == nil) then
				pos[2] = pos[2] -1
				for _,i in pairs(pos) do 
					print(tostring(i))
				end
				Drone.addArea(table.unpack(pos))
				Drone.setAction("dig")
				Drone.Pos = pos
			end
		else
			Drone.Pos = nil
		end
	end
	os.sleep(1)
end


