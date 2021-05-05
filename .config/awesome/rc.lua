-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
-- require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
require("notifications")
local menubar = require("menubar")
local helpers = require("helpers")
local hotkeys_popup = require("awful.hotkeys_popup")
--local runonce = require("runonce")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
local theme = beautiful.init("~/.config/awesome/themes/nord/theme.lua")

-- Number of attached monitors
local monitors = screen:count()

-- Default Applications
local apps = require("apps").default
 

-- Used later for screen rule that break without this check
-- It is equal to min(monitors, 2), where 2 is the monitor in which I want those programs in a multi monitor setup
local minscreen
if monitors < 2 then
  minscreen = monitors
else
  minscreen = 2
end

-- Helper function that updates a taglist item
local update_taglist = function (item, tag, index)
  if tag.selected then
    item.markup = helpers.colorize_text(beautiful.taglist_text_focused[index], beautiful.taglist_fg_focus)
  elseif tag.urgent then
    item.markup = helpers.colorize_text(beautiful.taglist_text_urgent[index], beautiful.taglist_fg_urgent)
  elseif #tag:clients() > 0 then
    item.markup = helpers.colorize_text(beautiful.taglist_text_occupied[index], beautiful.taglist_fg_occupied)
  else
    item.markup = helpers.colorize_text(beautiful.taglist_text_empty[index], beautiful.taglist_fg_empty)
  end
end

-- Autostart programs
local autostart = function(...)
  local size = select('#', ...)
  
   if size >= 0 then
      awful.spawn.once(select(1, ...), { focus = true })
   end
   if size >= 1 then
      for _, app in ipairs(select(2, ...)) do
         awful.spawn.once(app, { focus = false })
      end
   end
   if size >= 2 then
      for _, app in ipairs(select(3, ...)) do
        awful.spawn.with_shell(app)
      end
   end
end
              -- This is used later as the default terminal and editor to run.
terminal = apps.terminal
editor = apps.editor -- os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey       = "Mod4"
altkey       = "Mod1"
modkey1      = "Control"

-- Notifications icon size
--naughty.config.defaults['icon_size'] = 80

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.spiral.dwindle,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Tray menu
tray = wibox.widget.systray()
tray.visible = false

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end)--,
                    --awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    --awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
      local wallpaper =  beautiful.wallpaper
	local background = beautiful.background
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s)
    end
end



-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        widget_template = {
          widget = wibox.widget.textbox,
          create_callback = function(self, tag, index, _)
            self.align = "left"
            self.valign = "center"
            self.font = beautiful.taglist_text_font

            update_taglist(self, tag, index)
          end,
          update_callback = function(self, tag, index, _)
            update_taglist(self, tag, index)
          end,
        },
        buttons = taglist_buttons
    }

    --[[ Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.focused,

        widget_template = {
          -- {
          --  wibox.widget.base.make_widget(),
          --  forced_height = 5,
          --  id            = 'background_role',
          --  widget        = wibox.container.background,
          --},
          {
            {
                id     = 'clienticon',
                widget = awful.widget.clienticon,
            },
            margins = 5,
            widget  = wibox.container.margin
          },
          nil,
          layout = wibox.layout.align.vertical,
        },
        -- buttons = tasklist_buttons
    }]]--

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s , bg = beautiful.bg_normal})

    s.systray = wibox.widget.systray()
    s.systray.visible = false

    -- s.focused_window = ""

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
	expand = "none",
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
            s.mypromptbox,
        },
        mytextclock,--s.mytasklist, -- Middle widget
        { -- Right widgets
	    layout = wibox.layout.fixed.horizontal,
            s.systray,
            s.mytasklist,
            -- s.mylayoutbox,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end)--,
    --awful.button({ }, 4, awful.tag.viewnext),
    --awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

activetags = {}

-- {{{ Key bindings
-- Import Keybinds
local keys = require("keys")
root.keys(keys.globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
-- Import rules
local create_rules = require("rules").create
awful.rules.rules = create_rules(keys.clientkeys, keys.clientbuttons)
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- Custom commands


--if helpers.file_exists(gears.filesystem.get_configuration_dir().."reload.lck") then
--  os.remove(gears.filesystem.get_configuration_dir().."reload.lck")
--else
--  autostart('kitty', {'telegram-desktop', 'discord', 'firefox'}, {'env LD_PRELOAD=/usr/lib/spotify-adblock.so spotify %U', '/usr/lib/xfce-polkit/xfce-polkit'})
--end
-- naughty.notify({title = "theme color for bar:", text = beautiful.tasklist_bg_normal})
--require("awful.autofocus")

