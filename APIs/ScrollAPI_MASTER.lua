local component = require("component")
local event = require("event")
local thread = require("thread")
local computer = require("computer")
local gpu = component.gpu

local ScrollAPI = {}
function ScrollAPI.scroll(index, List, sx, sy, sw, bh, amount, BFNC, SFNC)
	local remain = ((#List)-index)
	if (remain>amount) then
		remain = amount
	end
	SFNC(index,List,sx,sy,sw,bh)
	for i=1,remain,1 do
		if (i % 2 == 0) then
			gpu.setBackground(0xffffff)
		else
			gpu.setBackground(0xc8c8c8)
		end
		local x = sx
		local y = sy+bh*(i-1)
		gpu.fill(x,y,sw,bh," ")
		local item = List[i+index]
		BFNC(i+index, item, x, y, sw, bh)
	end
end

function ScrollAPI.createScroll(List,sx,sy,sw,sh,bh,BFNC,SFNC)
	gpu.setBackground(0x646464)
	gpu.setForeground(0x000000)
	gpu.fill(sx,sy,sw,sh," ")
	local sxm = sx+sw
	local sym = sy+sh
	local t1 = thread.create(function()
		local scrollThread = thread.create(function() end)
		local index = 0
		local amount = math.floor(sh/bh)
		ScrollAPI.scroll(index, List, sx, sy, sw, bh, amount, BFNC, SFNC)
		while true do
			local _, screen, x, y, dir, playerName = event.pull("scroll")
			if not((x>=sx) and (x<sxm)) then
				if ((y>=sy) and (y<sym)) then
					index=index-dir
					if not(scrollThread:status() == "running") then
						scrollThread = thread.create(function()
							local uptime = computer.uptime()
							local loop = true
							local pindex = -1
							while loop do
								if not(pindex == index) then
									pindex = index
									uptime = computer.uptime()
									if (index<0) then 
										index = 0
									elseif (index>#List-amount) then
										index = #List-amount
									end
									ScrollAPI.scroll(index, List, sx, sy, sw, bh, amount, BFNC, SFNC)
								end
								if (uptime+10<computer.uptime()) then
									loop = false
								end
								os.sleep(0.1)
							end
						end)
					end
				end
			end
		end
	end)
	return t1
end

return ScrollAPI