local run = true
local userInput = io.read()
while run do
	userInput = io.read()
	if (userInput == "stop") then
		run = false
	end
	print("*",userInput)
end