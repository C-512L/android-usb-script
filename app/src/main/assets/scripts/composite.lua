---
--- Composite device composed of every suupported gadget
---

require('common')

local kb, _, _, _ = luausb.create(
    { type = "keyboard" },
    { type = "mouse" },
    { type = "storage" },
    { type = "serial" }
)

while true do
    print("idle")

    wait_for_state("configured")
    wait_for_detect(kb --[[@as KeyboardDev]])
    print("running")

    wait(1000)

    print("done")
    wait_for_state("not-attached")

    print("disconnected")

    wait(1000)
end
