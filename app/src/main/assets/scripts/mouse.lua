---
--- Draw some cool circles using the mouse
---
require('common')

local ms1 = luausb.create({ type = "mouse" }) --[[@as MouseDev]]

while true do
    -- poll until usb plugged in
    wait_for_state("configured")
    local t = 0
    local s = 0.05
    local r = 200
    local pos = {
      x = r,
      y = 0,
    }
    local dx, dy
    while luausb.state() == "configured" do
        local ax, ay = r * math.cos(t), r * math.sin(t)
        dx, dy = math.floor(ax - pos.x), math.floor(ay - pos.y)
        pos.x, pos.y = pos.x + dx, pos.y + dy
        t = t + s
        ms1:move(dx, dy)
    end
end
