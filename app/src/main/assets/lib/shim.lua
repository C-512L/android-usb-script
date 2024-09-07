--!strict
--- Shim which emulates the Java implemented methods
--- Uses lua and native linux commands.
--- Note: This is only for development usage

---@diagnostic disable: lowercase-global

---@module "meta"
local inspect = require('inspect')
require('hid')

-----@package
-----@param str string
--local function shim_print(str)
--  print(string.format("SHIM: %s", str))
--end

---Shim wrapper around print() and string.format()
---@package
---@param str string
---@param ... any
local function shim_print_format(str, ...)
  print(string.format("SHIM: " .. str, ...))
end

---@package
---@param s string
local function is_empty(s)
  return s == nil or s == ''
end

---@package
---@generic T
---@param orig T
---@return T
local function deep_copy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
    copy = {}
    for orig_key, orig_value in next, orig, nil do
      copy[deep_copy(orig_key)] = deep_copy(orig_value)
    end
    setmetatable(copy, deep_copy(getmetatable(orig)))
  else -- number, string, boolean, etc
    copy = orig
  end
  return copy
end

---@package
---@param tbl table
---@param value any
---@return any?
local function reverse_table_lookup(tbl, value)
  for key, val in pairs(tbl) do
    if val == value then
      return key
    end
  end
  return nil
end

--- Waits for a specified amount of miliseconds
---@param ms number Miliseconds
function wait(ms)
  local suc, exitcode, code = os.execute("sleep " .. ms * 0.001)
  -- When Lua creates a new process it propagates signals to its childs
  -- and the main process stops reacting to them
  if not suc then
    shim_print_format("Exiting due to %s", exitcode)
    os.exit(code)
  end
end

---@class PromptCfg
---@field message string
---@field hint string
---@field default string

---@param table PromptCfg
---@return string
function prompt(table)
  shim_print_format(table.message)
  shim_print_format("Hint: %s", table.hint)
  shim_print_format("Default: %s", table.default)
  local line_in = io.read("l")
  if not is_empty(line_in) then
    return line_in
  else
    shim_print_format("Empty response. Using default")
    return table.default
  end
end

---@class ConfirmCfg
---@field message string


---@param msg_cfg ConfirmCfg
---@return boolean
function confirm(msg_cfg)
  shim_print_format(msg_cfg.message)
  ---@type boolean?
  local result
  local is_not_nil = false
  local results = {
    ["Y"] = true,
    ["y"] = true,
    ["N"] = false,
    ["n"] = false,
  }
  shim_print_format("Confirm? (y/n)")
  repeat
    ---@type boolean?
    result = results[io.read("L"):gsub("%s+", "")]
    is_not_nil = result ~= nil
    if not is_not_nil then
      shim_print_format("Invalid option. Try Again")
    end
  until is_not_nil
  return result --[[@as boolean]]
end

--- @alias UsbType "storage"|"keyboard"|"mouse"|"serial"

---@class UsbDev
---@class UsbDevCfg
---@field type UsbType
local usb = {}

---@class StorageDev : UsbDev
---@class StorageDevCfg : UsbDevCfg
---@field id number? Default: 0
---@field file string? Default: "/data/local/tmp/mass_storage-lun0.img"
---@field ro boolean? Default: false
---@field size number? Default: 256
local st_dev = {

}

---@class MouseDevCfg : UsbDevCfg
---@class MouseDev
local ms_dev = {}
--- Move the mouse
---@param dx number Vertical axis
---@param dy number Horizontal axis
function ms_dev:move(dx, dy)
  shim_print_format("Mouse move: dX: %d dY: %d", dx, dy)
  -- The shim assumes a mouse polling rate of 125Hz
  wait(8)
end

---@param mask MouseButton
function ms_dev:click(mask)

end

function ms_dev:scroll(offset)

end

---@class SerialDevCfg : UsbDevCfg
---@class SerialDev
local serial_dev = {}


--- Represents a virtual HID Mass Storage device
--- @class storage
--- Represents a virtual HID Serial device
--- @class serial
--- Represents a virtual HID Mouse device


---@class KeyboardDevState
local kb_state = {
  num_lock = false,
  caps_lock = false,
  scroll_lock = false,
}

---@class KeyboardDevCfg
---@class KeyboardDev : UsbDev
---@field private _lock_state KeyboardDevState
local kb_dev = {
  _lock_state = kb_state
}

--- Makes the HID keyboard type the string passed
--- @param str string
function kb_dev:string(str)
  shim_print_format("Keyboard string: '%s')", str)
end

--- Querys the keyboard caps/num/keyboard lock status
--- @return KeyboardDevState The keyboard state
function kb_dev:read_lock()
    return self._lock_state
end

--- @param mod Keyboard.Mod
--- @param key Keyboard.Key
function kb_dev:chord(mod, key)
  self:_update_lock_state(mod)
  shim_print_format(
    "Keyboard Press: Mod: '%s' Key: '%s'",
    reverse_table_lookup(Keyboard.Mod, mod),
    reverse_table_lookup(Keyboard.Key, key)
  )
end

--- Types the following key
--- @param ... Keyboard.Key
function kb_dev:press(...)
  local keys = {...}
  for _,value in ipairs(keys) do
    self:chord(Keyboard.Mod.NONE, value)
  end
end

---@package
local LockStatus = {
  [true] = "ENABLED",
  [false] = "DISABLED",
}

function kb_dev:_update_lock_state(key)
  if key == Keyboard.Key.NUM_LOCK then
    self._lock_state.num_lock = not self._lock_state.num_lock
    shim_print_format("Keyboard Num lock %s", LockStatus[self._lock_state.num_lock])
  end
  if key == Keyboard.Key.SCROLLLOCK then
    self._lock_state.scroll_lock = not self._lock_state.scroll_lock
    shim_print_format("Keyboard Scroll lock %s", LockStatus[self._lock_state.scroll_lock])
  end
  if key == Keyboard.Key.CAPS_LOCK then
    self._lock_state.caps_lock = not self._lock_state.caps_lock
    shim_print_format("Keyboard Caps lock %s", LockStatus[self._lock_state.caps_lock])
  end
end

--- @class LuaUsb
luausb = {}
--- Creates a USB device
---@vararg UsbDevCfg
---@return UsbDev ...
function luausb.create(...)
  local arr_cfg = { ... }
  ---@type UsbDev[]
  local ret = {}
  for _, value in ipairs(arr_cfg) do
    assert(value, "Expected valid cfg, found nil")
    ---@type UsbDev[]
    local res = {
      ["keyboard"] = kb_dev,
      ["storage"] = st_dev,
      ["serial"] = serial_dev,
      ["mouse"] = ms_dev,
    }
    shim_print_format("Creating device of type: %s", value.type)
    table.insert(ret, deep_copy(res[value.type]))
  end
  return table.unpack(ret)
end

--- Wait for USB states
--- See https://www.kernel.org/doc/Documentation/ABI/stable/sysfs-class-udc
--- /sys/class/udc/<udc>/state
--- @alias UsbState
--- | "not-attached"
--- | "attached"
--- | "powered"
--- | "reconnecting"
--- | "unauthenticated"
--- | "default"
--- | "addressed"
--- | "configured"
--- | "suspended"

--- @return UsbState
function luausb.state()
  return "configured"
end

--- Proof of concept implementation of a select dialog
--- Do NOT call this on external code yet
---@package
---@class DialogOpts
---@field message string
---@field select_opts string[]
---@field multiple boolean?

---@package
---@param dialog_opts DialogOpts
---@return number selection
function dialog(dialog_opts)
    return 1
end

dialog({
  message = "ehheh",
    select_opts = {
    [1] = "njeje"
    },
    multiple = true
})


