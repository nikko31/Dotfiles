-- ===================================================================
-- Imports
-- ===================================================================


local awful = require("awful")
local beautiful = require("beautiful")

local screen_height = awful.screen.focused().geometry.height
local screen_width = awful.screen.focused().geometry.width
-- Default Applications
local apps = require("apps").default

-- personal variables
--change these variables if you want

--local browser           = "brave"
--local editor            = "nvim"
--local editorgui         = "code"
--local filemanager       = "vifm"
local mediaplayer       = "vlc"
--local terminal          = "kitty"
--local virtualmachine    = "kvm"

--local dpi = beautiful.xresources.apply_dpi

-- define module table
local rules = {}

-- ===================================================================
-- Rules
-- ===================================================================


function rules.create(clientkeys, clientbuttons)
    return {
        -- All clients will match this rule.
    {
         rule = {},
         properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                     size_hints_honor = false
        }
    },
        -- Titlebars
    { 
        rule_any = { 
            type = { "dialog", "normal" } },
            properties = { titlebars_enabled = false }
    },
    { 
        rule = { class = apps.browser },
          properties = { screen = 1, tag = "1" }
    },

    { 
        rule = { class = apps.guieditor },
          properties = { screen = 1, tag = "2" }
    },

    { 
        rule = { class = mediaplayer },
          properties = { maximized = true }
    },

    -- Floating clients.
    {
        rule_any = {
            instance = {
                "DTA",  -- Firefox addon DownThemAll.
                "copyq",  -- Includes session name in class.
            },
            class = {
                "Arandr",
                "Blueberry",
                "Galculator",
                "Gnome-font-viewer",
                "Gpick",
                "Imagewriter",
                "Font-manager",
                "Kruler",
                "MessageWin",  -- kalarm.
                "Oblogout",
                "Peek",
                "Skype",
                "System-config-printer.py",
                "Sxiv",
                "Unetbootin.elf",
                "Wpa_gui",
                "pinentry",
                "veromix",
                "xtightvncviewer"
            },
            name = {
                "Event Tester",  -- xev.
            },
            role = {
                "AlarmWindow",  -- Thunderbird's calendar.
                "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
                "Preferences",
                "setup",
            }
      }, properties = { floating = true }},
    }
end

-- return module table
return rules
