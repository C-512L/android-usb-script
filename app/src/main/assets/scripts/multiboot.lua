--!strict
---@diagnostic disable: lowercase-global
require('common')

print(string.format("_VERSION: %s", _VERSION))

--- Base path to look for image files
BASE_PATH = os.getenv("BASE_PATH") or "/storage/emulated/0/multiboot"

--- Check for a string suffix
---@package
---@param str string
---@param suffix string
function ends_with(str, suffix)
  return suffix == "" or str:sub(- #suffix) == suffix
end


--- Gets the basename of a file path
--- Internally uses the `basename` command
--- @return string
local function basename(path)
  local str = assert(io.popen("basename " .. path, "r"), "Failed basename command")
  return tostring(str:lines("a"))
end


--- Executes a find command and returns its results
--- @param dir string
--- @param type 'b' | 'c' | 'd' | 'f' | 'l' | 'p' | 's'
--- @return file*
local function find(dir, type)
  local cmd_args = '\'' .. dir .. '\' -mindepth 1 -maxdepth 1 -print0 -type ' .. type .. " 2>"
  local handle = assert(io.popen('find' .. cmd_args, "r"))
  local ret = {}
  for line in handle:lines() do
    table:insert(ret, {
      basename = basename(line),
      abs_path = line,
    })
  end
  return ret
end

--- An selectable boot entry
--- @class BootEntry
--- @field basename string
--- @field abs_path string
--- Boot Menu
--- @class MultiBoot
--- @field boot_opts BootEntry[]
--- @field boot_sel number?
local MultiBoot = {
  boot_opts = {},
  boot_sel = nil,
}
---@private
function MultiBoot:valid_selection()
  return self.boot_opts[self.boot_sel] ~= nil
end

---@param val BootEntry
function MultiBoot:insert(val)
  table.insert(self.boot_opts,val)
end

function MultiBoot:read_only()
  return self.boot_opts[self.boot_sel].basename:ends_with(".iso")
end

---@param base_path string
function MultiBoot:main_loop(base_path)
  print(string.format("Searching on %s", base_path))
  local handle = find(base_path, 'f')
  repeat
    MultiBoot.boot_sel = tonumber(prompt({
      message = "Enter the Image boot selection",
      hint = "Listed option",
      default = "0",
    }))
  until not self:valid_selection()
  _ = luausb.create(
    {
      type = "storage",
      file = self.boot_opts[self.boot_sel].abs_path,
      ro = self:read_only(),
        }
    )
    while true do
        wait(10000)
    end
end

MultiBoot:main_loop(BASE_PATH)
