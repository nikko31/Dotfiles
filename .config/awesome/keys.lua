-- ===================================================================
-- Initialization
-- ===================================================================


local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

-- Default Applications
local apps = require("apps").default

-- Define mod keys
local modkey       = "Mod4"
local altkey       = "Mod1"
local control      = "Control"

--Define module table
local keys = {}


-- ===================================================================
-- Movement Functions (Called by some keybinds)
-- ===================================================================

-- Move client to given direction
local function move_client(c, direction)
    -- If client is floating, move to edge
    if c.floating or (awful.layout.get(mouse.screen) == awful.layout.suit.floating) then
        local workarea = awful.screen.focused().workarea
        if direction == "up" then
            c:geometry({ nil, y = workarea.y + beautiful.useless_gap * 2, nil, nil })
        elseif direction == "down" then
            c:geometry({ nil, y = workarea.height + workarea.y - c:geometry().height - beautiful.useless_gap * 2 - beautiful.border_width * 2, nil, nil })
        elseif direction == "left" then
            c:geometry({ x = workarea.x + beautiful.useless_gap * 2, nil, nil, nil })
        elseif direction == "right" then
            c:geometry({ x = workarea.width + workarea.x - c:geometry().width - beautiful.useless_gap * 2 - beautiful.border_width * 2, nil, nil, nil })
        end
    -- Otherwise swap the client in the tiled layout
    elseif awful.layout.get(mouse.screen) == awful.layout.suit.max then
        if direction == "up" or direction == "left" then
            awful.client.swap.byidx(-1, c)
        elseif direction == "down" or direction == "right" then
            awful.client.swap.byidx(1, c)
        end
    else
        awful.client.swap.bydirection(direction, c, nil)
    end
end

-- Resize client in given direction
local floating_resize_amount = dpi(20)
local tiling_resize_factor = 0.05

local function resize_client(c, direction)
    if awful.layout.get(mouse.screen) == awful.layout.suit.floating or (c and c.floating) then
        if direction == "up" then
            c:relative_move(0, 0, 0, -floating_resize_amount)
        elseif direction == "down" then
            c:relative_move(0, 0, 0,  floating_resize_amount)
        elseif direction == "left" then
            c:relative_move(0, 0, -floating_resize_amount, 0)
        elseif direction == "right" then
            c:relative_move(0, 0, floating_resize_amount, 0)
        end
    else
        if direction == "up" then
            awful.client.incwfact(-tiling_resize_factor)
        elseif direction == "down" then
            awful.client.incwfact(tiling_resize_factor)
        elseif direction == "left" then
            awful.tag.incmwfact(-tiling_resize_factor)
        elseif direction == "right" then
            awful.tag.incmwfact(tiling_resize_factor)
        end
    end
end


-- raise focused client
local function raise_client()
   if client.focus then
      client.focus:raise()
   end
end

-- Add a new tag                                                                                                                                                                                        
function add_tag(layout)
    awful.prompt.run {
        prompt       = "New tag name: ",
        textbox      = awful.screen.focused().mypromptbox.widget,
        exe_callback = function(name)
            if not name or #name == 0 then return end
            awful.tag.add(name, { screen = awful.screen.focused(), layout = layout or awful.layout.suit.tile }):view_only()
        end
    }
end    
   
-- Rename current tag
function rename_tag()
    awful.prompt.run {
        prompt       = "Rename tag: ",
        textbox      = awful.screen.focused().mypromptbox.widget,
        exe_callback = function(new_name)
            if not new_name or #new_name == 0 then return end
            local t = awful.screen.focused().selected_tag
            if t then
                t.name = new_name
            end
        end
    }
end

-- Move current tag
-- pos in {-1, 1} <-> {previous, next} tag position
function move_tag(pos)
    local tag = awful.screen.focused().selected_tag
    if tonumber(pos) <= -1 then
        awful.tag.move(tag.index - 1, tag)
    else
        awful.tag.move(tag.index + 1, tag)
    end
end

-- Delete current tag
-- Any rule set on the tag shall be broken
function delete_tag()
    local t = awful.screen.focused().selected_tag
    if not t then return end
    t:delete()
end

-- ===================================================================
-- Mouse bindings
-- ===================================================================


-- Mouse buttons on the desktop
keys.desktopbuttons = gears.table.join(
    -- left click on desktop to hide notification
    awful.button({}, 1,
        function ()
            naughty.destroy_all_notifications()
        end
    )
)

-- Mouse buttons on the client
keys.clientbuttons = gears.table.join(
    -- Raise client
    awful.button({}, 1,
        function(c)
            client.focus = c
            c:raise()
        end
    ),

    -- Move and Resize Client
    awful.button({modkey}, 1, 
        awful.mouse.client.move, 
        {description="move client", group="client"}
    ),
    awful.button({modkey}, 3,
        awful.mouse.client.resize,
        {description="move client", group="client"}
    )
)


-- ===================================================================
-- Key bindings
-- ===================================================================


keys.globalkeys = gears.table.join(
    -- =========================================
    -- SPAWN APPLICATION KEY BINDINGS
    -- =========================================

    awful.key({ modkey }, "s",
        hotkeys_popup.show_help,
        {description="show help", group="awesome"}
    ),
    -- Spawn terminal              
    awful.key({ modkey }, "Return",
        function ()
            awful.spawn(apps.terminal)
        end,
        {description = "open a terminal", group = "launcher"}
    ),
    -- launch rofi
    awful.key({ modkey, "Shift" }, "Return",
        function ()
            awful.spawn(apps.launcher)
        end,
        {description = "launch rofi", group = "launcher"}
    ),
    awful.key({ modkey }, "x",    
        function ()
            awful.prompt.run {
              prompt       = "Run Lua code: ",
              textbox      = awful.screen.focused().mypromptbox.widget,
              exe_callback = awful.util.eval,
              history_path = awful.util.get_cache_dir() .. "/history_eval"
            }  
        end,
        {description = "lua execute prompt", group = "awesome"}),
    -- =============================================
    -- SPAWN APPLICATION KEY BINDINGS (Super+Alt+Key)
    -- =============================================

    --launch browser
    awful.key({ modkey, altkey }, "b",
        function ()
            awful.spawn(apps.browser)
        end,
        {description = "open "..apps.browser, group = "launcher"}
    ),
    --launch editor
    awful.key({ modkey, altkey }, "v", 
        function () 
            awful.spawn( terminal.." -e "..apps.editor )
        end,
        {description = "open "..apps.editor , group = "launcher" }
    ),
    --launch code
    awful.key({ modkey, altkey }, "c", 
        function () 
            awful.spawn( apps.guieditor )
        end,
        {description = "open "..apps.guieditor , group = "launcher" }
    ),
    --launch file manager
    awful.key({ modkey, altkey }, "f",
        function ()
            awful.spawn(terminal.." -e "..apps.filebrowser)
        end,
        {description = "open file manager "..apps.filebrowser, group = "launcher"}
    ),
    -- =========================================
    -- FUNCTION KEYS
    -- =========================================

    -- Brightness
    awful.key({}, "XF86MonBrightnessUp",
        function()
            awful.spawn("xbacklight -inc 5", false)
            if toggleBriOSD ~= nil then
                toggleBriOSD(true)
            end
            if UpdateBrOSD ~= nil then
                UpdateBriOSD()
            end
        end,
        {description = "+5%", group = "hotkeys"}
    ),
    awful.key({}, "XF86MonBrightnessDown",
        function()
            awful.spawn("xbacklight -dec 5", false)
            if toggleBriOSD ~= nil then
                toggleBriOSD(true)
            end
            if UpdateBrOSD ~= nil then
                UpdateBriOSD()
            end
        end,
        {description = "-5%", group = "hotkeys"}
    ),

   -- PULSE volume control
    --awful.key({ control }, "Up",
    awful.key({ }, "XF86AudioRaiseVolume", 
      function () 
        awful.util.spawn("pactl set-sink-volume 0 +2%", false) 
      end
    ),
    awful.key({ }, "XF86AudioLowerVolume", 
      function () 
        awful.util.spawn("pactl set-sink-volume 0 -2%", false) 
      end
    ),
    awful.key({ }, "XF86AudioMute", 
      function () 
        awful.util.spawn("pactl set-sink-mute 0 toggle", false) 
      end
    ),

    --[[ awful.key({ }, "XF86AudioRaiseVolume",
        function ()
            os.execute(string.format("pactl -- set-sink-volume 0 +1%%", beautiful.volume.channel))
            beautiful.volume.update()
        end
    ),
    --awful.key({ control }, "Down",
    awful.key({ }, "XF86AudioLowerVolume",
        function ()
            os.execute(string.format("pactl -- set-sink-volume 0 -1%%", beautiful.volume.channel))
            beautiful.volume.update()
        end
    ),
    awful.key({ }, "XF86AudioMute",
        function ()
            os.execute(string.format("pactl -- set-sink-mute 0 toggle", beautiful.volume.togglechannel or beautiful.volume.channel))
            beautiful.volume.update()
        end
    ), ]]--

    awful.key({}, "XF86AudioNext",
        function()
            awful.spawn("mpc next", false)
        end
    ),
    awful.key({}, "XF86AudioPrev",
        function()
            awful.spawn("mpc prev", false)
        end
    ),
    awful.key({}, "XF86AudioPlay",
        function()
            awful.spawn("mpc toggle", false)
        end
    ),

    -- Screenshot on prtscn using scrot
    awful.key({}, "Print",
        function ()
            awful.util.spawn(apps.screenshot, false)
        end
    ),

	-- =========================================
	-- RELOAD / QUIT AWESOME
    -- =========================================
    	
    -- Reload Awesome
    awful.key({modkey, "Shift"}, "r",
       awesome.restart,
       {description = "reload awesome", group = "awesome"}
    ),

    -- Quit Awesome
    awful.key({modkey}, "Escape",
          -- emit signal to show the exit screen
          --awesome.emit_signal("show_exit_screen")
        awesome.quit,
        {description = "quit awesome", group = "awesome"}
    ),

    awful.key({}, "XF86PowerOff",
       function()
          exit_screen.show()
       end,
       {description = "toggle exit screen", group = "hotkeys"}
    ),
    
    -- =========================================
    -- CLIENT FOCUSING
    -- =========================================

    -- Focus client by direction (hjkl keys)
    awful.key({ modkey }, "j",
        function()
            awful.client.focus.bydirection("down")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus down", group = "client"}
    ),
    awful.key({ modkey }, "k",
        function()
            awful.client.focus.bydirection("up")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus up", group = "client"}
    ),
    awful.key({ modkey }, "h",
        function()
            awful.client.focus.bydirection("left")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus left", group = "client"}
    ),
    awful.key({ modkey }, "l",
        function()
            awful.client.focus.bydirection("right")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus right", group = "client"}
    ),

    -- Focus client by direction (arrow keys)
    awful.key({ modkey }, "Down",
        function()
            awful.client.focus.bydirection("down")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus down", group = "client"}
    ),
    awful.key({ modkey }, "Up",
        function()
            awful.client.focus.bydirection("up")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus up", group = "client"}
    ),
    awful.key({ modkey }, "Left",
        function()
            awful.client.focus.bydirection("left")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus left", group = "client"}
    ),
    awful.key({ modkey }, "Right",
        function()
            awful.client.focus.bydirection("right")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus right", group = "client"}
    ),

    -- Tag browsing alt + tab
    awful.key({ modkey }, "Tab",
        awful.tag.viewnext,
        {description = "view next", group = "tag"}
    ),
    awful.key({ modkey, "Shift" }, "Tab",
        awful.tag.viewprev,
        {description = "view previous", group = "tag"}
    ),

    -- Focus client by index (cycle through clients)
    awful.key({ altkey }, "Tab",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ altkey, "Shift" }, "Tab",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),

    -- =========================================
    -- GAP CONTROL
    -- =========================================

    -- Gap control
    awful.key({ modkey, "Shift" }, "minus",
        function ()
            awful.tag.incgap(5, nil)
        end,
        {description = "increment gaps size for the current tag", group = "gaps"}
    ),
    awful.key({ modkey }, "minus",
        function ()
            awful.tag.incgap(-5, nil)
        end,
        {description = "decrement gap size for the current tag", group = "gaps"}
    ),

    -- =========================================
    -- CLIENT RESIZING
    -- =========================================
	
   awful.key({modkey, control}, "Down",
      function(c)
         resize_client(client.focus, "down")
      end
   ),
   awful.key({modkey, control}, "Up",
      function(c)
         resize_client(client.focus, "up")
      end
   ),
   awful.key({modkey, control}, "Left",
      function(c)
         resize_client(client.focus, "left")
      end,
      {description = "resize left", group = "client"}
   ),
   awful.key({modkey, control}, "Right",
      function(c)
         resize_client(client.focus, "right")
      end,
      {description = "resize right", group = "client"}
   ),
   awful.key({modkey, control}, "j",
      function(c)
         resize_client(client.focus, "down")
      end,
      {description = "resize down", group = "client"}
   ),
   awful.key({ modkey, control }, "k",
      function(c)
         resize_client(client.focus, "up")
      end,
      {description = "resize up", group = "client"}
   ),
   awful.key({modkey, control}, "h",
      function(c)
         resize_client(client.focus, "left")
      end,
      {description = "resize left", group = "client"}
   ),
   awful.key({modkey, control}, "l",
      function(c)
         resize_client(client.focus, "right")
      end,
      {description = "resize right", group = "client"}
   ),
             
    -- =========================================
    -- NUMBER OF MASTER / COLUMN CLIENTS
    -- =========================================

    -- Number of master clients
    awful.key({ modkey, altkey }, "h",
        function ()
            awful.tag.incnmaster( 1, nil, true)
        end,
        {description = "increase the number of master clients", group = "layout"}
    ),
    awful.key({ modkey, altkey }, "l",
        function ()
            awful.tag.incnmaster(-1, nil, true)
        end,
        {description = "decrease the number of master clients", group = "layout"}
    ),
    awful.key({ modkey, altkey }, "Left",
        function ()
            awful.tag.incnmaster( 1, nil, true)
        end,
        {description = "increase the number of master clients", group = "layout"}
    ),
    awful.key({ modkey, altkey }, "Right",
        function ()
            awful.tag.incnmaster(-1, nil, true)
        end,
        {description = "decrease the number of master clients", group = "layout"}
    ),

    -- Number of columns
    awful.key({ modkey, altkey }, "k",
        function ()
            awful.tag.incncol( 1, nil, true)
        end,
        {description = "increase the number of columns", group = "layout"}
    ),
    awful.key({ modkey, altkey }, "j",
        function ()
            awful.tag.incncol( -1, nil, true)
        end,
        {description = "decrease the number of columns", group = "layout"}
    ),
    awful.key({ modkey, altkey }, "Up",
        function ()
            awful.tag.incncol( 1, nil, true)
        end,
        {description = "increase the number of columns", group = "layout"}
    ),
    awful.key({ modkey, altkey }, "Down",
        function ()
            awful.tag.incncol( -1, nil, true)
        end,
        {description = "decrease the number of columns", group = "layout"}
    ),

    -- =========================================
    -- LAYOUT SELECTION
    -- =========================================

    -- select next layout
    awful.key({ modkey }, "space",
        function ()
            awful.layout.inc(1)
        end,
        {description = "select next layout", group = "layout"}
    ),
    -- select previous layout
    awful.key({ modkey, "Shift" }, "space",
        function ()
            awful.layout.inc(-1)
        end,
        {description = "select previous layout", group = "layout"}
    ),
    awful.key({ modkey }, ".",
        function ()
            awful.screen.focus_relative( 1) 
        end,
        {description = "focus the next screen", group = "screen"}
    ),
    awful.key({ modkey }, ",",
        function ()
            awful.screen.focus_relative(-1) 
        end,
        {description = "focus the previous screen", group = "screen"}
    ),

    -- =========================================
    -- CLIENT CONTROL
    -- =========================================

    -- restore minimized client
    awful.key({ modkey, "Shift" }, "n",
        function ()
            local c = awful.client.restore()
            -- Focus restored client
            if c then
                client.focus = c
                c:raise()
            end
        end,
        {description = "restore minimized", group = "client"}
    ),
    -- =========================================
    -- TAGGING
    -- =========================================

    awful.key({ modkey, "Shift" }, "n", 
        function () 
            add_tag() 
        end,
        {description = "add new tag", group = "tag"}
    ),

    awful.key({ modkey, "Control" }, "r", 
        function () 
            rename_tag() 
        end,
        {description = "rename tag", group = "tag"}
    ),
    awful.key({ modkey, "Shift" }, "Left", 
        function () 
            move_tag(-1) 
        end,
        {description = "move tag to the left", group = "tag"}
    ),
    awful.key({ modkey, "Shift" }, "Right", 
        function () 
            move_tag(1) 
        end,
        {description = "move tag to the right", group = "tag"}
    ),
    awful.key({ modkey, "Shift" }, "d", 
        function () 
            delete_tag() 
        end,
        {description = "delete tag", group = "tag"}
    )
)


keys.clientkeys = gears.table.join(
    -- toggle fullscreen
    awful.key({ modkey }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
        end,
        {description = "toggle fullscreen", group = "client"}
    ),

    -- close client
    awful.key({ modkey, "Shift" }, "c",
        function (c)
            c:kill()
        end,
        {description = "close", group = "client"}
    ),

    -- Minimize
    awful.key({ modkey, }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end,
        {description = "minimize", group = "client"}
    ),

    -- Maximize
    awful.key({ modkey, }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end,
        {description = "(un)maximize", group = "client"}
    ),
     -- Move to other screen
    awful.key({ modkey, }, "o",
        function (c) 
            c:move_to_screen()
        end,
        {description = "move to screen", group = "client"}
    ),

    awful.key({ modkey, "Control" }, "Return", 
        function (c)
            c:swap(awful.client.getmaster()) 
        end,
        {description = "move to master", group = "client"}
    )
)

-- Bind all key numbers to tags
for i = 1, 9 do
    keys.globalkeys = gears.table.join(keys.globalkeys,
        -- Switch to tag
        awful.key({ modkey }, "#" .. i + 9,
            function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    tag:view_only()
                end
            end,
            {description = "view tag #", group = "tag"}
        ),
        -- Move client to tag
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
            function ()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
            {description = "move focused client to tag #", group = "tag"}
        ),
        -- Toggle tag on focused client.
        awful.key({ modkey, control, "Shift" }, "#" .. i + 9,
            function ()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:toggle_tag(tag)
                    end
                end
            end,
            {description = "toggle focused client on tag #", group = "tag"}
        )
    )
end

return keys
