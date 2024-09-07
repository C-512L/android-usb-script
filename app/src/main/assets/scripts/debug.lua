require('common')
local inspect = require('inspect')

local kb = luausb.create({ type = "keyboard" }) --[[@as KeyboardDev]]

wait(1000)

local test
while true do
    while true do
        test = kb:read_lock()
        if test == nil then
            break
        end
        print(inspect(test))
    end
    wait(10)
end
