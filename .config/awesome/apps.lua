
-- ===================================================================
-- Initialization
-- ===================================================================


local awful = require('awful')
local filesystem = require('gears.filesystem')

-- define module table
local apps = {}


-- ===================================================================
-- App Declarations
-- ===================================================================


apps.default = {
    terminal = "alacritty",
    virtualmachine = "kvm",
    launcher = "dmenu_run -i",
    lock = "xsecurelock",
    screenshot = "gnome-screenshot",
    filebrowser = "pcmanfm",
    browser = "firefox",
    editor = "nvim",
    guieditor = "code"
}

-- List of apps to start once on start-up
local run_on_start_up = {
    "picom --config  $HOME/.config/picom/picom.conf",
    "unclutter"
}


-- ===================================================================
-- Functionality
-- ===================================================================


-- Run all the apps listed in run_on_start_up when awesome starts
function apps.autostart()
   for _, app in ipairs(run_on_start_up) do
      local findme = app
      local firstspace = app:find(" ")
      if firstspace then
         findme = app:sub(0, firstspace - 1)
      end
         awful.spawn.with_shell(string.format("pgrep -u $USER -x %s > /dev/null || (%s)", findme, app), false)
   end
end

return apps