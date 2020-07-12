local API = {}
local function API.FNC(FNC1)
  print(tostring(FNC1))
  os.sleep(1)
  print(tostring(FNC1))
end 
--return API

--local API = require("API")
local GLOBALVAR = 1
local function Test()
  return GLOBALVAR
end
thread.create(API.FNC(TEST()))
local GLOBALVAR = 2