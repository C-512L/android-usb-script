# Lua USB samples
The `scripts` directory includes some lua examples of how to write
scripts for the app.

The `lib` directory contains both `hid` and `common` modules
as well as a copy of [inspect.lua] which are available during runtime.
For a description of what each module.

# LuaUSB Shim
The `lib` directory includes a `shim` module which simulates the `luausb` API
exposed inside the app's LuaJ runtime. 

This module can be used to test and develope scripts locally without having to
transfer scripts to your phone. Here is an example of running a script locally
from command line:
```sh
LUA_PATH=lib/?.lua lua -l shim scripts/chromeacct.lua
```



If you want to load this module dynamically you can the following snippet:
```lua
if not _VERSION:find("Luaj") then
  print("LuaJ not detected. Using LuaUSB shim")
  require('shim')
end
```

[inspect.lua]:(https://github.com/kikito/inspect.lua)
