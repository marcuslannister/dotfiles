-- Every app starts in English: select ABC when an app becomes active.
local english = "com.apple.keylayout.ABC"

require("hs.ipc") -- lets the `hs` CLI talk to Hammerspoon
hs.autoLaunch(true)

-- Global, so the watcher is not garbage-collected.
englishOnActivate = hs.application.watcher.new(function(_, event)
  if event == hs.application.watcher.activated then
    hs.keycodes.currentSourceID(english)
  end
end)
englishOnActivate:start()
