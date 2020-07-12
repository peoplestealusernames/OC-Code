local thread = require("thread")
print("Main program start")
A=0

local function printin(wait,stri)
	os.sleep(wait)
	print(stri..A)
	A=A+1
end

local i = 10
while (i>=0) do
	thread.create(function(i)
		printin(i,i.." Seconds")
	end,i)
	i=i-1
end