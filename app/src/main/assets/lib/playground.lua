---@diagnostic disable: lowercase-global


---@package
---@param s string
local function is_empty(s)
  return s == nil or s == ''
end


---@param type "user"|"group"
---@return number
---@return number
function get_id(type)
  local CMD_ID_ARGS = {
    ["user"] = "-u",
    ["group"] = "-g",
  }
  local file, errormsg = io.popen("id" .. CMD_ID_ARGS[type]);
  assert(file, errormsg)
  return file:read("*n")
end


---@param dir boolean? Wether the temporary file should be a directory
function mktemp(dir)
  local args = " -q"
  if dir then
    args = args .. "d"
  end
  local file, errormsg = io.popen("mktemp" .. args, "r")
  assert(file, errormsg)
  local out = file:read("*l")
  ---@type string
  return out
end


--- Wrapper that executes and stores the stdout and stderr in temp files
function exec(cmd, args)
  local tmp_files = {
    stdout = mktemp(),
    stderr = mktemp(),
  }
  local suc, exitcode, code = os.execute(cmd .. " " .. args .. " 1>" .. tmp_files.stdout .. " 2>" .. tmp_files.stderr)
  return suc, exitcode, code, io.open(tmp_files.stdout, "r"), io.open(tmp_files.stderr, "r")
end
