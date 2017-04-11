-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local lain          = require("lain")
local menubar       = require("menubar")
local freedesktop   = require("freedesktop")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local assault = require('assault')
local myBRW   = require("brightness-widget")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Select mode
hostname = io.popen("uname -n"):read()

if hostname == "MensOS" then
  ON_LAPTOP = true
  mediaModifiers = {}
  mediaRaiseVol = "XF86AudioRaiseVolume"
  mediaLowerVol = "XF86AudioLowerVolume"
  mediaMuteVol =  "XF86AudioMute"
else
  ON_LAPTOP = false
  mediaModifiers = {"Mod4", "Mod3", "Mod1"}
  mediaRaiseVol = "KP_Add"
  mediaLowerVol = "KP_Subtract"
  mediaMuteVol =  "KP_Divide"
end
-- }}}

-- {{{ Autostart applications
local function run_once(cmd)
  findme = cmd
  firstspace = cmd:find(" ")
  if firstspace then
     findme = cmd:sub(0, firstspace-1)
  end
  awful.spawn.with_shell(string.format("pgrep -u $USER -x %s > /dev/null || (%s)", findme, cmd))
end

if ON_LAPTOP then
  run_once( "nm-applet" )
end

run_once( "unclutter -root" )
run_once( "redshift-gtk" )

run_once( "xmodmap $HOME/.Xmodmap" );
run_once( "xset b off" );
run_once( "gsettings set org.gnome.settings-daemon.plugins.cursor active false" )
run_once( "compton -f --backend glx --vsync opengl-swc --paint-on-overlay -D5 -r6 -l-8 -t-8" )
run_once( "systemd-analyze plot > $HOME/startup.svg" )
run_once( "synclient TapButton1=1 TapButton2=3 TapButton3=2" )

-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
--beautiful.init(awful.util.get_themes_dir() .. "default/theme.lua")
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/powerarrow-darker/theme.lua")

beautiful.get().wallpaper = "/home/daniel/Bilder/WP_LN"
wp_BaseDir                = "/home/daniel/Bilder/Wallpapers"

-- This is used later as the default terminal and editor to run.
terminal = "urxvt"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor
defTagGap = 5

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
altkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.max,
    awful.layout.suit.floating,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- lain
lain.layout.termfair.nmaster        = 3
lain.layout.termfair.ncol           = 1
lain.layout.termfair.center.nmaster = 3
lain.layout.termfair.center.ncol    = 1
-- }}}

naughty.config.defaults.icon_size = 64

-- {{{ Wallpapers

---     _    _  ___   _      _     ______  ___  ______ ___________  _____     ______ _____ _____ _____ _   _
---    | |  | |/ _ \ | |    | |    | ___ \/ _ \ | ___ \  ___| ___ \/  ___|    | ___ \  ___|  __ \_   _| \ | |
---    | |  | / /_\ \| |    | |    | |_/ / /_\ \| |_/ / |__ | |_/ /\ `--.     | |_/ / |__ | |  \/ | | |  \| |
---    | |/\| |  _  || |    | |    |  __/|  _  ||  __/|  __||    /  `--. \    | ___ \  __|| | __  | | | . ` |
---    \  /\  / | | || |____| |____| |   | | | || |   | |___| |\ \ /\__/ /    | |_/ / |___| |_\ \_| |_| |\  |
---     \/  \/\_| |_/\_____/\_____/\_|   \_| |_/\_|   \____/\_| \_|\____/     \____/\____/ \____/\___/\_| \_/
---


wp_timeout  = 20

-- Initialize the pseudo random number generator
math.randomseed( os.time() )
math.random(); math.random(); math.random()
-- done. :-)

function scandir(directory, filter)
    local i, t, popen = 0, {}, io.popen
    if not filter then
        filter = function(s) return string.match(s,"%.png$") or string.match(s,"%.jpg$") end
    end

    for filename in popen('ls -A "' .. directory .. '"'):lines() do
        if filter(filename) then
            i = i + 1
            t[i] = filename
        end
    end
    return t
end

function rescanDir()
  wp_files = scandir(wp_path)
  if #wp_files == 0 then
    naughty.notify({title = "No Wallpapers", text = "No Wallpapers in " .. wp_path, timeout = 20})
    wp_index = 1
  else
    wp_index = wp_NEXT()
    if wp_index > #wp_files then
      wp_index = 1
    end
  end
end

function changeWPdir(dir)
  wp_path  = wp_BaseDir .. '/' .. dir .. '/'
  naughty.notify({title = "Changed Wallpaper dir -- " .. dir, text = wp_path, timeout = 10})
  rescanDir()
end

function moveWP(dir)
  local ret
  wp_WPM_counter = wp_WPM_counter + 1

  if #wp_files == 0 then
    naughty.notify({title = "Not moving", text = "Do not move backup wallpaper"})
    return
  end
  ret = os.execute('mv ' .. wp_current .. ' ' .. wp_BaseDir .. '/' .. dir )
  if ret == true then
    naughty.notify({title = "MOVED", text = wp_current .. " >> " .. dir .. "  #" .. #wp_files, timeout = 20})
    rescanDir()
  else
    naughty.notify({title = "FAILED to move", text = wp_current .. " >> !! >> " .. dir})
  end
  nextWP()
end

function nextWP()
  wp_last = wp_current
  if #wp_files > 0 then
    wp_current = wp_path .. wp_files[wp_index]
  else
    wp_current = beautiful.wallpaper
  end

  wp_SET()

  if #wp_files == 0 then return end

  wp_index = wp_NEXT()
  if wp_index > #wp_files then
    wp_index = 1
  end
end

function lastWP()
  wp_current = wp_last
  wp_SET()
end

wp_NEXT_random = function() return math.random( 1, #wp_files) end
wp_NEXT_count  = function() return wp_index + 1               end
wp_NEXT        = wp_NEXT_random

wp_SET_max = function() for s = 1, screen.count() do gears.wallpaper.maximized( wp_current, s, true ) end end
wp_SET_fit = function() for s = 1, screen.count() do gears.wallpaper.fit( wp_current, s )             end end
wp_SET     = wp_SET_max

wp_current = beautiful.wallpaper
wp_SET()

wp_WPM_counter = 0
wp_WPM   = gears.timer { timeout = 60         }
wp_timer = gears.timer { timeout = wp_timeout }
wp_timer:connect_signal("timeout", function()
  if wp_timer.timeout ~= wp_timeout then
    wp_timer:stop()
    wp_timer.timeout = wp_timeout
    wp_timer:start()
  end

  nextWP()
end)
wp_WPM:connect_signal("timeout", function()
  if wp_WPM_counter == 0 then return end
  naughty.notify({title = "WPM: " .. wp_WPM_counter, text = "Wallpapers per minute"})
  wp_WPM_counter = 0
end)

wp_timer:start()
-- wp_WPM:start()

---     _    _  ___   _      _     ______  ___  ______ ___________  _____      _____ _   _______
---    | |  | |/ _ \ | |    | |    | ___ \/ _ \ | ___ \  ___| ___ \/  ___|    |  ___| \ | |  _  \
---    | |  | / /_\ \| |    | |    | |_/ / /_\ \| |_/ / |__ | |_/ /\ `--.     | |__ |  \| | | | |
---    | |/\| |  _  || |    | |    |  __/|  _  ||  __/|  __||    /  `--. \    |  __|| . ` | | | |
---    \  /\  / | | || |____| |____| |   | | | || |   | |___| |\ \ /\__/ /    | |___| |\  | |/ /
---     \/  \/\_| |_/\_____/\_____/\_|   \_| |_/\_|   \____/\_| \_|\____/     \____/\_| \_/___/
---

-- }}}

-- {{{ Keyboard
---     _   __           _                         _     ______ _____ _____ _____ _   _
---    | | / /          | |                       | |    | ___ \  ___|  __ \_   _| \ | |
---    | |/ /  ___ _   _| |__   ___   __ _ _ __ __| |    | |_/ / |__ | |  \/ | | |  \| |
---    |    \ / _ \ | | | '_ \ / _ \ / _` | '__/ _` |    | ___ \  __|| | __  | | | . ` |
---    | |\  \  __/ |_| | |_) | (_) | (_| | | | (_| |    | |_/ / |___| |_\ \_| |_| |\  |
---    \_| \_/\___|\__, |_.__/ \___/ \__,_|_|  \__,_|    \____/\____/ \____/\___/\_| \_/
---                 __/ |
---                |___/
-- ))

-- Keyboard map indicator and changer
kbdcfg = {}
kbdcfg.cmd = "setxkbmap"
kbdcfg.layout = { { "de", "" , "Deutsch" }, { "gb", "" , "English" } }

if ON_LAPTOP then
  kbdcfg.default = 1
else
  kbdcfg.default = 2
end

kbdcfg.widget = wibox.widget.textbox()
kbdcfg.set = function (index)
  kbdcfg.current = index
  local t = kbdcfg.layout[index]
  os.execute( kbdcfg.cmd .. " " .. t[1] .. " " .. t[2] )
  os.execute( "xmodmap $HOME/.Xmodmap" )
  kbdcfg.update()
end

kbdcfg.switch = function ()
  kbdcfg.set( kbdcfg.current % #(kbdcfg.layout) + 1 )
end

kbdcfg.update = function ()
  kbdcfg.widget:set_text(" " .. kbdcfg.layout[kbdcfg.current][3] .. " ")
end

kbdcfg.setup = function ()
  local f = io.popen( "setxkbmap -query | grep layout | sed 's/^.*: *//g'", 'r' )
  local s = f:read( "*a" )
  s = string.gsub( s, "\n", '' )

  for i = 1, #kbdcfg.layout do
    if kbdcfg.layout[i][1] == s then
      kbdcfg.current = i
    end
  end

  kbdcfg.update()
end

kbdcfg.set( kbdcfg.default )
kbdcfg.setup()

 -- Mouse bindings
kbdcfg.widget:buttons(
 awful.util.table.join(awful.button({ }, 1, function () kbdcfg.switch() end))
)

---     _   __           _                         _      _____ _   _______
---    | | / /          | |                       | |    |  ___| \ | |  _  \
---    | |/ /  ___ _   _| |__   ___   __ _ _ __ __| |    | |__ |  \| | | | |
---    |    \ / _ \ | | | '_ \ / _ \ / _` | '__/ _` |    |  __|| . ` | | | |
---    | |\  \  __/ |_| | |_) | (_) | (_| | | | (_| |    | |___| |\  | |/ /
---    \_| \_/\___|\__, |_.__/ \___/ \__,_|_|  \__,_|    \____/\_| \_/___/
---                 __/ |
---                |___/
-- ))
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu

myawesomemenu = {
   { "hotkeys", function() return false, hotkeys_popup.show_help end},
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end}
}

--[[ old menu
mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
--]]

local mymainmenu = freedesktop.menu.build({
    before = {
        { "Awesome", myawesomemenu, beautiful.awesome_icon },
        -- other triads can be put here
    },
    after = {
        { "Open terminal", terminal },
        -- other triads can be put here
    }
})
-- }}}


-- {{{ Wibar
local markup = lain.util.markup
local separators = lain.util.separators

local clockicon = wibox.widget.imagebox(beautiful.widget_clock)
--local mytextclock = wibox.widget.textclock(" %a %d %b  %H:%M")

local mytextclock = lain.widgets.abase({
    timeout  = 60,
    cmd      = " date +'%a %d %b %R'",
    settings = function()
        widget:set_markup(" " .. output)
    end
})

-- calendar
lain.widgets.calendar.attach(mytextclock, { font_size = 10 })

-- Mail IMAP check
--local mailicon = wibox.widget.imagebox(beautiful.widget_mail)
--mailicon:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn(mail) end)))
--[[ commented because it needs to be set before use
local mailwidget = lain.widgets.imap({
    timeout  = 180,
    server   = "server",
    mail     = "mail",
    password = "keyring get mail",
    settings = function()
        if mailcount > 0 then
            widget:set_text(" " .. mailcount .. " ")
            mailicon:set_image(beautiful.widget_mail_on)
        else
            widget:set_text("")
            mailicon:set_image(beautiful.widget_mail)
        end
    end
})
]]

-- MPD
local mpdicon = wibox.widget.imagebox(beautiful.widget_music)
mpdicon:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn_with_shell(musicplr) end)))
local mpdwidget = lain.widgets.mpd({
    settings = function()
        if mpd_now.state == "play" then
            artist = " " .. mpd_now.artist .. " "
            title  = mpd_now.title  .. " "
            mpdicon:set_image(beautiful.widget_music_on)
        elseif mpd_now.state == "pause" then
            artist = " mpd "
            title  = "paused "
        else
            artist = ""
            title  = ""
            mpdicon:set_image(beautiful.widget_music)
        end

        widget:set_markup(markup("#EA6F81", artist) .. title)
    end
})

-- MEM
local memicon = wibox.widget.imagebox(beautiful.widget_mem)
local memwidget = lain.widgets.mem({
    settings = function()
        widget:set_text(" " .. mem_now.used .. "MB ")
    end
})

-- CPU
local cpuicon = wibox.widget.imagebox(beautiful.widget_cpu)
local cpuwidget = lain.widgets.cpu({
    settings = function()
        widget:set_text(" " .. cpu_now.usage .. "% ")
    end
})

-- Coretemp
local tempicon = wibox.widget.imagebox(beautiful.widget_temp)
local tempwidget = lain.widgets.temp({
    settings = function()
        widget:set_text(" " .. coretemp_now .. "°C ")
    end
})

-- / fs
local fsicon = wibox.widget.imagebox(beautiful.widget_hdd)
local fsroot = lain.widgets.fs({
    options  = "--exclude-type=tmpfs",
    settings = function()
        widget:set_text(" " .. fs_now.used .. "% ")
    end
})

-- Battery
local baticon = wibox.widget.imagebox(beautiful.widget_battery)
--[[
local batwidget = lain.widgets.bat({
    settings = function()
        if bat_now.status ~= "N/A" then
            if bat_now.ac_status == 1 then
                widget:set_markup(" AC ")
                baticon:set_image(beautiful.widget_ac)
                return
            elseif not bat_now.perc and tonumber(bat_now.perc) <= 5 then
                baticon:set_image(beautiful.widget_battery_empty)
            elseif not bat_now.perc and tonumber(bat_now.perc) <= 15 then
                baticon:set_image(beautiful.widget_battery_low)
            else
                baticon:set_image(beautiful.widget_battery)
            end
            widget:set_markup(" " .. bat_now.perc .. "% ")
        else
            baticon:set_image(beautiful.widget_ac)
        end
    end
})
--]]

-- ALSA volume
-- PulseAudio volume
volicon = wibox.widget.imagebox(beautiful.widget_vol)
volumewidget = lain.widgets.pulseaudio({
    cmd="printf 'muted: %s\nvolume: %d%%\n' $(pamixer --get-mute) $(pamixer --get-volume)",
    settings = function()
        if volume_now.muted == "true" then
            volicon:set_image(beautiful.widget_vol_mute)
        elseif tonumber(volume_now.left) == 0 then
            volicon:set_image(beautiful.widget_vol_no)
        elseif tonumber(volume_now.left) <= 50 then
            volicon:set_image(beautiful.widget_vol_low)
        else
            volicon:set_image(beautiful.widget_vol)
        end

        widget:set_text(" " .. volume_now.left .. "% ")
    end
})

-- Net
local neticon = wibox.widget.imagebox(beautiful.widget_net)
neticon:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn_with_shell(iptraf) end)))
local netwidget = lain.widgets.net({
    settings = function()
        widget:set_markup(markup("#7AC82E", " " .. net_now.received)
                          .. " " ..
                          markup("#46A8C3", " " .. net_now.sent .. " "))
    end
})


-- Bightness
if ON_LAPTOP then
  brightnesswidget = myBRW:new({step=5})

  myassault = assault({
    battery = "BAT1", -- battery ID to get data from
    adapter = "ACAD", -- ID of the AC adapter to get data from
    width = 36, -- width of battery
    height = 13, -- height of battery
    bolt_width = 19, -- width of charging bolt
    bolt_height = 10, -- height of charging bolt
    stroke_width = 2, -- width of battery border
  --  peg_top = (calculated), -- distance from the top of the battery to the start of the peg
  --  peg_height = (height / 3), -- height of the peg
    peg_width = 2, -- width of the peg
    font = beautiful.font, -- font to use
    critical_level = 0.15, -- battery percentage to mark as critical (between 0 and 1, default is 10%)
    normal_color = beautiful.fg_normal, -- color to draw the battery when it's discharging
    critical_color = "#cf0000", -- color to draw the battery when it's at critical level
    charging_color = "#00cf00" -- color to draw the battery when it's charging
  })
else
  brightnesswidget = {}
  myassault        = {}
end


-- Separators
local spr     = wibox.widget.textbox(' ')
local arrl_dl = separators.arrow_left(beautiful.bg_focus, "alpha")
local arrl_ld = separators.arrow_left("alpha", beautiful.bg_focus)

-- Create a wibox for each screen and add it
local taglist_buttons = awful.util.table.join(
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
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() and c.first_tag then
                                                      c.first_tag:view_only()
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, client_menu_toggle_fn()),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Quake application
    s.quake = lain.util.quake({ app = terminal })

    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    -- Set gap
    for i, currTag in ipairs(s.tags) do
      awful.tag.incgap( defTagGap, currTag )
    end

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    currentArrl = arrl_dl
    local function nextArrl ()
      if currentArrl == arrl_dl then
        currentArrl = arrl_ld
      else
        currentArrl = arrl_dl
      end
      return currentArrl
    end

    local function wrapOBJ (obj)
      if currentArrl == arrl_ld then
        return wibox.container.background(obj, beautiful.bg_focus)
      else
        return obj
      end
    end

    local function l (obj)
      if ON_LAPTOP then
        return obj
      end

      -- Fix currentArrl
      if obj == arrl_dl then
        currentArrl = arrl_ld
      elseif obj == arrl_ld then
        currentArrl = arrl_dl
      end

      return nil
    end

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            spr,
            s.mytaglist,
            s.mypromptbox,
            spr,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            wibox.widget.systray(),
            spr,
            nextArrl(),
            --nextArrl(),
            --wrapOBJ(mpdicon),
            --wrapOBJ(mpdwidget),

            l(nextArrl()),
            l(wrapOBJ(brightnesswidget.widget)),
            l(wrapOBJ(spr)),
            l(wrapOBJ(brightnesswidget.textWidget)),
            l(wrapOBJ(spr)),

            nextArrl(),
            wrapOBJ(volicon),
            wrapOBJ(volumewidget),

            --nextArrl(),
            --wrapOBJ(mailicon),
            --wrapOBJ(mailwidget),

            nextArrl(),
            wrapOBJ(memicon),
            wrapOBJ(memwidget),

            nextArrl(),
            wrapOBJ(cpuicon),
            wrapOBJ(cpuwidget),

            nextArrl(),
            wrapOBJ(tempicon),
            wrapOBJ(tempwidget),

            nextArrl(),
            wrapOBJ(fsicon),
            wrapOBJ(fsroot),

            l(nextArrl()),
            --l(wrapOBJ(baticon)),
            l(wrapOBJ(spr)),
            l(wrapOBJ(myassault)),
            --l(wrapOBJ(batwidget)),
            l(wrapOBJ(spr)),

            nextArrl(),
            wrapOBJ(kbdcfg.widget),

            nextArrl(),
            wrapOBJ(neticon),
            wrapOBJ(netwidget),

            nextArrl(),
            wrapOBJ(mytextclock),
            wrapOBJ(spr),

            nextArrl(),
            wrapOBJ(s.mylayoutbox),
        },
    }
end)

-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

wp_usage = [[


  Usage:

  Dirs: AWESOME super TODO good  ok  badAspect nature
  CD:     F1          F2     F3     F4      F5       F6      F7
  Move: ENTER     Up    t  Right  Down    Left   bacspace

   - Timeout --
   + Timeout ++

   space - next wallpaper
   shift - r - Start
   shift - s - stop

   r - random
   c - counter
   m - maximized
   f - fit
   i - Info]]

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

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
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"}),


    -- ALSA volume control
    awful.key(mediaModifiers, mediaRaiseVol,
        function ()
            os.execute(string.format("pamixer -i 1"))
            volumewidget.update()
        end
        ,{description = "increase volume", group = "misc"}),
    awful.key(mediaModifiers, mediaLowerVol,
        function ()
            os.execute(string.format("pamixer -d 1"))
            volumewidget.update()
        end
        ,{description = "decrease volume", group = "misc"}),
    awful.key(mediaModifiers, mediaMuteVol,
        function ()
            os.execute(string.format("pamixer -t"))
            volumewidget.update()
        end
        ,{description = "toggle mute", group = "misc"}),
    awful.key({}, "XF86Sleep", function() os.execute(string.format("systemctl suspend")) end),
    awful.key({}, "XF86MonBrightnessDown", function() brightnesswidget:down() end),
    awful.key({}, "XF86MonBrightnessUp", function() brightnesswidget:up() end),

    -- Gap handling
    awful.key({ modkey, "Mod3" }, "Prior",
      function () awful.tag.incgap(1) end
      ,{description = "increase gap of current tag by 1", group = "tag"}),

    awful.key({ modkey, "Mod3" }, "Next",
      function () awful.tag.incgap(-1) end
      ,{description = "decrease gap of current tag by 1", group = "tag"}),

    awful.key({ modkey, "Mod3", altkey }, "Prior",
      function () for i, t in ipairs(root.tags()) do awful.tag.incgap(1, t) end end
      ,{description = "increase gap of all tags by 1", group = "tag"}),

    awful.key({ modkey, "Mod3", altkey }, "Next",
      function () for i, t in ipairs(root.tags()) do awful.tag.incgap(-1, t) end end
      ,{description = "decrease gap of all tags by 1", group = "tag"}),

---     _    _       _ _
---    | |  | |     | | |
---    | |  | | __ _| | |_ __   __ _ _ __   ___ _ __ ___
---    | |/\| |/ _` | | | '_ \ / _` | '_ \ / _ \ '__/ __|
---    \  /\  / (_| | | | |_) | (_| | |_) |  __/ |  \__ \
---     \/  \/ \__,_|_|_| .__/ \__,_| .__/ \___|_|  |___/
---                     | |         | |
---                     |_|         |_|

    awful.key({ modkey, "Mod3", altkey }, "i", function ()
      naughty.notify({ title = "Current Wallpaper", text = wp_current .. "\nTimeout: " .. wp_timeout .. wp_usage, timeout = 0 })
    end,{description = "current WP information", group = "wallpaper"}),

    awful.key({ modkey, "Mod3", altkey }, "+", function ()
      wp_timeout = wp_timeout + 1
      naughty.notify({ title = "Wallpaper timeout", text = "New Timeout: " .. wp_timeout .. "s", timeout = 3 })
    end,{description = "increase WP timer", group = "wallpaper"}),

    awful.key({ modkey, "Mod3", altkey }, "-", function ()
      if wp_timeout > 1 then
        wp_timeout = wp_timeout - 1
      end
      naughty.notify({ title = "Wallpaper timeout", text = "New Timeout: " .. wp_timeout .. "s", timeout = 3 })
    end,{description = "decrease WP timer", group = "wallpaper"}),


    awful.key({ modkey, "Mod3", "Shift" }, "r", function ()
      wp_timer:stop()
      wp_timer.timeout = wp_timeout
      wp_timer:start()
      naughty.notify({ title = "Started Wallpaper", text = "-- started --", timeout = 20 })
    end,{description = "start Wallpaper loop", group = "wallpaper"}),

    awful.key({ modkey, "Mod3", "Shift" }, "s", function ()
      wp_timer:stop()
      naughty.notify({ title = "STOPPED Wallpaper", text = "-- stopped --", timeout = 20 })
    end,{description = "stop WP loop", group = "wallpaper"}),

    awful.key({ modkey, "Mod3", altkey }, "space", function () nextWP() end,{description = "next WP", group = "wallpaper"}),
    awful.key({ modkey, "Mod3", altkey }, "l",     function () lastWP() end,{description = "last WP", group = "wallpaper"}),

    awful.key({ modkey, "Mod3", altkey }, "F1", function () changeWPdir( "AWESOME" )   end),
    awful.key({ modkey, "Mod3", altkey }, "F2", function () changeWPdir( "super" )     end),
    awful.key({ modkey, "Mod3", altkey }, "F3", function () changeWPdir( "TODO" )      end),
    awful.key({ modkey, "Mod3", altkey }, "F4", function () changeWPdir( "good" )      end),
    awful.key({ modkey, "Mod3", altkey }, "F5", function () changeWPdir( "ok" )        end),
    awful.key({ modkey, "Mod3", altkey }, "F6", function () changeWPdir( "badAspect" ) end),
    awful.key({ modkey, "Mod3", altkey }, "F7", function () changeWPdir( "nature" )    end),
    awful.key({ modkey, "Mod3", altkey }, "F9", function () changeWPdir( "best" )      end),

    awful.key({ modkey, "Mod3", altkey }, "Return",    function () moveWP( "AWESOME" )   end),
    awful.key({ modkey, "Mod3", altkey }, "Up",        function () moveWP( "super" )     end),
    awful.key({ modkey, "Mod3", altkey }, "t",         function () moveWP( "TODO" )      end),
    awful.key({ modkey, "Mod3", altkey }, "Right",     function () moveWP( "good" )      end),
    awful.key({ modkey, "Mod3", altkey }, "Down",      function () moveWP( "ok" )        end),
    awful.key({ modkey, "Mod3", altkey }, "Left",      function () moveWP( "badAspect" ) end),
    awful.key({ modkey, "Mod3", altkey }, "BackSpace", function () moveWP( "nature" )    end),


    awful.key({ modkey, "Mod3", altkey }, "r", function ()
      wp_NEXT = wp_NEXT_random
      naughty.notify({ title = "Wallpaper RANDOM", text = "-- random --",  timeout = 10 })
    end,{description = "random WP", group = "wallpaper"}),

    awful.key({ modkey, "Mod3", altkey }, "c", function ()
      wp_NEXT = wp_NEXT_count
      naughty.notify({ title = "Wallpaper COUNTER", text = "-- counter --", timeout = 10 })
    end,{description = "counter WP change", group = "wallpaper"}),


    awful.key({ modkey, "Mod3", altkey }, "m", function ()
      wp_SET = wp_SET_max
      wp_SET()
      naughty.notify({ title = "Wallpaper Maximized",  timeout = 10 })
    end,{description = "maximize WP", group = "wallpaper"}),

    awful.key({ modkey, "Mod3", altkey }, "f", function ()
      wp_SET = wp_SET_fit
      wp_SET()
      naughty.notify({ title = "Wallpaper Fit", timeout = 10 })
    end,{description = "fit WP", group = "wallpaper"})

)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "maximize", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  i <= 4 and {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  i <= 4 and {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  i <= 4 and {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  i <= 4 and {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,

                     maximized_vertical = false,
                     maximized_horizontal = false,
                     maximized = false,

                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
        },
        class = {
          "Arandr",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Wpa_gui",
          "pinentry",
          "veromix",
          "xtightvncviewer"},

        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = awful.util.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
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
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}


-- MENSE; Autostart {{{

changeWPdir( "AWESOME" )

-- }}} MENSE; Autostart
