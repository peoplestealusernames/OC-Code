local component = require("component")
local event = require("event")
local m = component.modem -- get primary modem component
m.setStrength(1000) 
m.open(123)
print(m.isOpen(123)) -- true
print(m.isWireless()) -- true
print(m.getStrength()) -- true
print(m.broadcast(123, "OOF"))