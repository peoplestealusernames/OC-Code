local component = require("component")
local event = require("event")
local m = component.modem -- get primary modem component
m.setStrength(1000)
m.open(123)
print(m.isOpen(123)) -- true
print(m.isWireless()) -- true
print(m.getStrength()) -- true
while true do
  -- don't need the sleep in there, event.pull blocks until the signal is detected
  local _, _, from, port, _, message = event.pull( "modem_message" ) -- parts with "_" are not stored
  print( "Got " .. tostring( message ) .. " from " .. from .. " on port " .. port ) 
end