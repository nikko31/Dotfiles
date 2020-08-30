
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
    launcher = "rofi -normal-window -modi drun -show drun",
    lock = "xsecurelock",
    screenshot = "gnome-screenshot",
    filebrowser = "vifm",
    browser = "brave",
    editor = "nvim",
    guieditor = "codium"
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
