local filesystem = require("filesystem")
local file = io.open("Test","w") -- diffrent modes
file:write("HA")
file:close()
--modes : w overwrites file, a adds to file,r reads file only