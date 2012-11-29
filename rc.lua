-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")

-- Widget library
require("vicious")

-- Theme handling library
require("beautiful")

-- Notification library
require("naughty")

-- Expose library
require("revelation")

-- Load Debian menu entries
--require("debian.menu")

awful.util.spawn("sh /home/agavoty/.screenlayout/layout.sh")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/home/agavoty/.config/awesome/themes/skymod/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "lxterminal"
editor = os.getenv("EDITOR") or "gvim"
editor_cmd = terminal .. " -e " .. editor


function run_once(prg)
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. prg .. " || (" .. prg .. ")")
end

-- Volume configuration
-- Sound Control
cardid  = 0
channel = "Master"
--function volume (mode, widget)
	--if mode == "update" then
             --local fd = io.popen("amixer -c " .. cardid .. " -- sget " .. channel)
             --local status = fd:read("*all")
             --fd:close()

		--local volume = string.match(status, "(%d?%d?%d)%%")
		--volume = string.format("% 3d", volume)

		--status = string.match(status, "%[(o[^%]]*)%]")

		--if string.find(status, "on", 1, true) then
			--volume = "<span color='green'>" .. volume .. "</span>% "
		--else
			--volume = "<span color='red'>" .. volume .. "</span>M "
		--end
		--widget.text = volume
	--elseif mode == "up" then
		--io.popen("amixer -q -c " .. cardid .. " sset " .. channel .. " 5%+"):read("*all")
		--volume("update", widget)
	--elseif mode == "down" then
		--io.popen("amixer -q -c " .. cardid .. " sset " .. channel .. " 5%-"):read("*all")
		--volume("update", widget)
	--else
		--io.popen("amixer -c " .. cardid .. " sset " .. channel .. " toggle"):read("*all")
		--volume("update", widget)
	--end
--end

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Window management layouts
layouts = {
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.floating,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
    names = { "Main", "Web", "Dev","IM", "Zik"},
    layout = { layouts[3], layouts[3], layouts[3], layouts[2], layouts[3]}
    }
tagss = {
    names = { "Files", "Term", "VM","Monitor"},
    layout = { layouts[3], layouts[3], layouts[3], layouts[2]}
    }
--for s = 1, screen.count() do
    -- Each screen has its own tag table.
tags[1] = awful.tag(tags.names, 1, tags.layout)
tags[2] = awful.tag(tagss.names, 2, tagss.layout)
--end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", "gvim" .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    --{ "Debian", debian.menu.Debian_menu.Debian },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.widget_arch),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox

-- Separators
spacer = widget({ type = "textbox" })
separator = widget({ type = "textbox" })
separator.text, spacer.text = "  ", " "

-- Arch icon
arch_img = widget({ type = "imagebox" })
arch_img.image = image(beautiful.widget_pacman)

-- Create Volume Control Widget
--sound_img = widget({ type = "imagebox" })
--sound_img.image = image(beautiful.widget_sound)
 --tb_volume = widget({ type = "textbox", name = "tb_volume", align = "right" })
 --tb_volume:buttons(awful.util.table.join(
	--awful.button({ }, 4, function () volume("up", tb_volume) end),
	--awful.button({ }, 5, function () volume("down", tb_volume) end),
	--awful.button({ }, 1, function () volume("mute", tb_volume) end)
 --))
 --volume("update", tb_volume)

-- refresh the Volume Control Widget
--tb_volume_timer = timer({ timeout = 10 })
--tb_volume_timer:add_signal("timeout", function () volume("update", tb_volume) end)
--tb_volume_timer:start()

-- Assign a hook to update temperature

-- Create a battery status Widget

-- Battery widget
bat_img = widget({ type = "imagebox" })
bat_img.image = image(beautiful.widget_bat)
battwidget = widget({ type = "textbox" })
vicious.register(battwidget, vicious.widgets.bat, '$1$2%', 61, 'BAT1')

-- Memory widget
mem_img = widget({ type = "imagebox" })
mem_img.image = image(beautiful.widget_mem)
memwidget = widget({ type = "textbox" })
vicious.register(memwidget, vicious.widgets.mem, "$2mb", 13)

-- CPU widget
cpu_img = widget({ type = "imagebox" })
cpu_img.image = image(beautiful.widget_cpu)
cpuwidget = widget({ type = "textbox" })
vicious.register(cpuwidget, vicious.widgets.cpu, "$1%")

-- Pacman updates
pac_img = widget({ type = "imagebox" })
pac_img.image = image(beautiful.widget_pacman)
pacup = widget({ type = "textbox" })
vicious.register(pacup, vicious.widgets.pkg, "$1", 1801, "Arch")

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a textclock widget
clock_img = widget({ type = "imagebox" })
clock_img.image = image(beautiful.widget_clock)
os.setlocale("fr_FR.UTF-8") -- Français
os.setlocale("C", "numeric")
--mytextclock = awful.widget.textclock({ align = "right" }," | %a %d %b  %H:%M ")

local util = require("awful.util")
local button = require("awful.button")
local calendar = nil
local offset = 0

function remove_calendar()
   if calendar ~= nil then
      naughty.destroy(calendar)
      calendar = nil
      offset = 0
   end
end

function add_calendar(inc_offset)
   local save_offset = offset
   remove_calendar()
   offset = save_offset + inc_offset
   local datespec = os.date("*t")
   day = datespec.day
   datespec = datespec.year * 12 + datespec.month - 1 + offset
   datespec = (datespec % 12 + 1) .. " " .. math.floor(datespec / 12)
   local cal = awful.util.pread("cal -m -1 " .. datespec)
   cal = string.gsub(cal, "%s(" .. day .. ")%s", " <span color='#ff8800'>%1</span> ")
   calendar = naughty.notify({
                text = string.format('<span font_desc="%s">%s</span>', "monospace", cal),
                timeout = 0, hover_timeout = 0.5,
                width = 160,
                 })
end
mytextclock = awful.widget.textclock({ align = "right" }, "%H:%M", 10)
--mytextclock = awful.widget.textclock({ align = "right" }, "%a %e %b %Y %T ", 1)
mytextclock:add_signal("mouse::enter", function()
                      add_calendar(0)
                       end)
mytextclock:add_signal("mouse::leave", remove_calendar)

mytextclock:buttons(util.table.join(
               button({ }, 3, function () add_calendar(-1) end), -- RIGHT MOUSE: clear highlight
               button({ }, 1, function () add_calendar(1) end) -- LEFT MOUSE: toggle state
         ))

--  Network usage widget
netup_img = widget({ type = "imagebox" })
netup_img.image = image(beautiful.widget_up)
netdown_img = widget({ type = "imagebox" })
netdown_img.image = image(beautiful.widget_down)
netwidget = widget({ type = "textbox" })
vicious.register(netwidget, vicious.widgets.net, '<span color="#C81717">${eth0 down_kb}</span> <span color="#5b8bbe">${eth0 up_kb}</span>', 3)

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            spacer,
            mylauncher,
            spacer,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        --mymail,
        s == 1 and mysystray or nil, separator,
        mytextclock, clock_img, separator,
        --tb_volume, sound_img, separator,
		memwidget, mem_img, separator,
		netup_img, netwidget, netdown_img, separator,
        cpuwidget, cpu_img, separator,
		--battwidget, bat_img, separator,
		--cputemp, separator,
        spacer, pacup, pac_img, spacer,
        mytasklist[s], separator,
        layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}


-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
-- Multimedia keys


globalkeys = awful.util.table.join(
	awful.key({ modkey, "Control" }, "s",      function (c) c.sticky = not c.sticky  end),
	awful.key({modkey}, "e", revelation),
	--awful.key({ }, "XF86AudioRaiseVolume", function () volume("up", tb_volume) end),
	--awful.key({ }, "XF86AudioLowerVolume", function () volume("down", tb_volume) end),
	--awful.key({ }, "XF86AudioMute", function () volume("mute", tb_volume) end),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey,           }, "i", function () awful.util.spawn("pidgin") end),
    awful.key({ modkey,           }, "g", function () awful.util.spawn("gvim") end),
    awful.key({ modkey,           }, "b", function () awful.util.spawn("banshee") end),
    awful.key({ modkey,           }, "p", function () awful.util.spawn("thunar") end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    { rule = { class = "Firefox" },
      properties = { tag = tags[1][2] } },
    { rule = { class = "Pidgin" },
      properties = { tag = tags[1][4] } },
    { rule = { class = "VirtualBox" },
      properties = { tag = tags[1][5] } },
    { rule = { class = "banshee" },
      properties = { tag = tags[1][6] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus",  function(c) c.border_color = beautiful.border_focus
                                c.border_color = beautiful.border_focus
                                c.opacity = 1
                            end)
client.add_signal("unfocus",    function(c) c.border_color = beautiful.border_normal
                                    c.border_color = beautiful.border_normal
                                    c.opacity = 0.8
                                end)
-- }}}


--run_once("wicd-gtk")
run_once("nm-applet")
run_once("parcellite")
run_once("firefox")
awful.util.spawn("wmname LG3D")
awful.util.spawn("nitrogen --restore")
awful.util.spawn("xcompmgr -cCfF -o 0.38 -O 20 -I 20 -t 0.02 -l 0.02 -r 3.2 -D2")
