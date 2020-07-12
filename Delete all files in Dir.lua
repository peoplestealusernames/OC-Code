local filesystem = require("filesystem")
local dirName = "Test"

local files,stri,A = filesystem.get(dirName)

print(files)
print(stri)
print(A)