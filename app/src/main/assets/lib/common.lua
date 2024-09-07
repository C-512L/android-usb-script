--!strict
---@diagnostic disable: lowercase-global
--- Common library functions
--- @module "meta"

require('hid')

--- Wait for USB keyboard detection
---@param kb KeyboardDev
function wait_for_detect(kb)
  while true do
    local lock = kb:read_lock()
    if lock ~= nil then
      return lock
    end
    wait(100)
  end
end

---Wait for certain USB state
---@param state UsbState
function wait_for_state(state)
  while luausb.state() ~= state do
    wait(100)
  end
end

--- Make it really obvious when a script is done running
--- @param kb KeyboardDev
function flash(kb)
  kb:press(Keyboard.Key.NUM_LOCK)
  wait(100)
  local lock
  while true do
    local val = kb:read_lock()
    if val == nil then break end
    lock = val
  end
  if lock == nil then return end

  if lock.num_lock then kb:press(Keyboard.Key.NUM_LOCK) end
  if lock.caps_lock then kb:press(Keyboard.Key.CAPS_LOCK) end
  if lock.scroll_lock then kb:press(Keyboard.Key.SCROLL_LOCK) end

  local state = luausb.state()
  while luausb.state() == state do
    kb:press(Keyboard.Key.NUM_LOCK, Keyboard.Key.CAPS_LOCK, Keyboard.Key.SCROLL_LOCK)
    wait(50)
    kb:press(Keyboard.Key.NUM_LOCK, Keyboard.Key.CAPS_LOCK, Keyboard.Key.SCROLL_LOCK)
    wait(950)
  end
end
