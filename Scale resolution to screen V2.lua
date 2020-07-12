local component = require("component")
local gpu = component.gpu

--component.gpu.getResolution()
--component.gpu.setResolution(x,y)

local function scaleScreen(GPU,Round)--round is optional
	local x,y = component.proxy(gpu.getScreen()).getAspectRatio()
	local mx,my = gpu.maxResolution() -- 160,50
	local ox,oy
	x = x - 0.275--removes the "edge" as aspect ratio is block count
	y = y - 0.275--ie 2x2 blocks = 2x2
	if not(Round == nil) then
		Round = false
	end
	local function sizeToFit(x,y,mx,my,r) --resizes to fit with max can also "rotate" for more vertical setups
		local ox,oy
		local x1,y1,x2,y2
		local function TMPFNC(x,y,mx,my,r)
			if (x>mx) then
				local div = (x/mx)
				x = x/div
				y = y/div
				if (r) then
					x = math.floor(x)
					y = math.ceil(y)
				end
			end
			if (y > my) then
				local div = (y/my)
				x = x/div
				y = y/div
				if (r) then
					x = math.ceil(x)
					y = math.floor(y)
				end
			end
			return x,y
		end
		
		x1,y1 = TMPFNC(x,y,mx,my,r)
		x2,y2 = TMPFNC(x,y,my,mx,r)
		if(x1+y1)>(x2+y2) then
			x,y = x1,y1
		else
			x,y = x2,y2
		end
		return x,y
	end
	
	if (x>y) then
		ox = (my*x/y)*2
		oy = my
		ox,oy = sizeToFit(ox,oy,mx,my,Round)
	elseif (x<y) then
		ox = mx
		oy = (mx*y/x)/2
		ox,oy = sizeToFit(ox,oy,mx,my,Round)
	elseif (x==y) then
		if (mx>my) then
			ox = my*2
			oy = my
			ox,oy = sizeToFit(ox,oy,mx,my,Round)
		elseif (mx<my) then
			ox = mx
			oy = mx/2
			ox,oy = sizeToFit(ox,oy,mx,my,Round)
		else
			ox = mx
			oy = my
		end
	else
		ox = mx
		oy = my
	end
	gpu.setResolution(ox,oy)
	return ox,oy
end

local x,y = scaleScreen(gpu)