local component = require("component")
local gpu = component.gpu
local w, h = gpu.getResolution()
local colors = require "colors"
local function draw(x1,y1,h1,w1,text,back,fore)
	if not(back == nil) then
		gpu.setBackground(back)
	end
	if not(fore == nil) then
		gpu.setForeground(fore)
	end
	gpu.fill((w*x1)+1, (h*y1)+1, w*w1, h*h1, text)
end
gpu.fill(-10, -10, w+50, h+50, " ", 0xffff00, 0x000000)
draw(0, 0, 1, 1, " ", 0xFFFFFF)
draw(0, 0, .5, .5, " ", 0x04ff00)
draw(0, .5, .5, .5, " ", 0x007bff)
draw(.5, 0, .5, .5, " ", 0xff0019)
draw(.5, .5, .5, .5, " ", 0xff00f7)