{{introductory_notes}}
######################################
# STARTUP PROGRAMS & SETTINGS (Early)
######################################

exec --no-startup-id autostart

{{startup_programs}}
#########################
# VARIABLES
#########################

## set to Win (but swap Alt and Win)
# alt=Mod1 win=Mod4
set $mod Mod4

set $left Tab
set $LeftShift Tab
set $right l
set $RightShift L
set $down j
set $DownShift J
set $up k
set $UpShift K

set $locked {{locked}}
set $noid --no-startup-id

#########################
# APPEARANCE
#########################

set $globalfontsize 8
font pango:Droid Sans Mono $globalfontsize

{{appearance_special}}

set $subgreen #60a471

set $white #F8F8F2
set $blue  #6272A4
set $dblue #44475A
set $ddblue #282A36
set $lgray #BFBFBF
set $red #FF5555

# class                 border     bground    text     indicator  child_border
client.focused          $subgreen  $subgreen  $white   $subgreen  $subgreen
client.focused_inactive $blue      $blue      $white   $blue      $blue
client.unfocused        $ddblue    $ddblue    $lgray   $ddblue    $ddblue
client.urgent           $dblue     $red       $white   $red       $red
client.placeholder      $ddblue    $ddblue    $white   $ddblue    $ddblue

client.background       $white

{{appearance_output}}
{{appearance_notes}}

#########################
# KEYBOARD KEYS
#########################
set $majorlightadjust major
set $mediumlightadjust medium
set $minorlightadjust minor
set $finelightadjust fine

bindsym XF86MonBrightnessDown exec --no-startup-id laptop-monitor-brightness auto '-' $majorlightadjust
bindsym XF86MonBrightnessUp exec --no-startup-id laptop-monitor-brightness auto '+' $majorlightadjust
bindsym $mod+XF86MonBrightnessDown exec --no-startup-id laptop-monitor-brightness auto '-' $mediumlightadjust
bindsym $mod+XF86MonBrightnessUp exec --no-startup-id laptop-monitor-brightness auto '+' $mediumlightadjust
bindsym $mod+Shift+XF86MonBrightnessDown exec --no-startup-id laptop-monitor-brightness auto '-' $minorlightadjust
bindsym $mod+Shift+XF86MonBrightnessUp exec --no-startup-id laptop-monitor-brightness auto '+' $minorlightadjust
bindsym $mod+Ctrl+Shift+XF86MonBrightnessDown exec --no-startup-id laptop-monitor-brightness auto '-' $finelightadjust
bindsym $mod+Ctrl+Shift+XF86MonBrightnessUp exec --no-startup-id laptop-monitor-brightness auto '+' $finelightadjust

bindsym $mod+o exec --no-startup-id /home/jtprince/advance-paste.rb

bindsym XF86KbdBrightnessDown exec --no-startup-id kbd-backlight down
bindsym XF86KbdBrightnessUp exec --no-startup-id kbd-backlight up

# TODO: fix this:
# bindsym XF86ToggleTouchpad exec --no-startup-id

#########################
# SOUND
#########################

## parentheses left and right to change volume
# if the wrong sink is being accessed, then figure out the index of your sink and (if 3 is the index):
#     pacmd set-default-sink 3
# Get the indexes being used:
#     pacmd list-sinks | egrep '(index|used by)'
set $volup exec --no-startup-id /usr/bin/pulseaudio-ctl up
set $voldown exec --no-startup-id /usr/bin/pulseaudio-ctl down
set $mute exec --no-startup-id /usr/bin/pulseaudio-ctl mute
set $mutefor exec --no-startup-id mute-for

bindsym $mod+0 $volup 2
bindsym $mod+9 $voldown 2
bindsym $mod+Shift+0 $volup 5
bindsym $mod+Shift+9 $voldown 5
bindsym $mod+Ctrl+Shift+0 $volup 20
bindsym $mod+Ctrl+Shift+9 $voldown 20
bindsym $mod+minus $mute
bindsym $mod+Shift minus $mutefor 25

bindsym $locked XF86AudioRaiseVolume $volup 2
bindsym $locked XF86AudioLowerVolume $voldown 2
bindsym Shift+XF86AudioRaiseVolume $volup 5
bindsym Shift+XF86AudioLowerVolume $voldown 5
bindsym $mod+Ctrl+Shift+XF86AudioRaiseVolume $volup 20
bindsym $mod+Ctrl+Shift+XF86AudioLowerVolume $voldown 20

bindsym $locked XF86AudioMute $mute

bindsym $locked Shift+XF86AudioMute exec --no-startup-id pactl-speakers toggle
bindsym $locked Shift+XF86AudioPlay exec music-player

bindsym $mod+backslash exec pavucontrol --tab 5

#########################
# Music player
#########################

set $playpause exec --no-startup-id playerctl play-pause
set $nextsong exec --no-startup-id playerctl next
set $previoussong exec --no-startup-id playerctl previous
set $seekforward exec --no-startup-id playerctl position 10+
set $seekbackward exec --no-startup-id playerctl position 10-

# commands for music player
bindsym $locked XF86AudioPlay $playpause
bindsym $locked $mod+p $playpause

bindsym $locked XF86AudioNext $nextsong
bindsym $locked $mod+bracketright $nextsong
# only implemented on some players
bindsym $locked $mod+Shift+bracketright $seekforward

bindsym $locked XF86AudioPrev $previoussong
bindsym $locked $mod+bracketleft $previoussong
# only implemented on some players
bindsym $locked $mod+Shift+bracketleft $seekbackward

#########################
# DEFAULTS
#########################

## workspace Layout <default|stacking|tabbed>
workspace_layout stacking

## focus follows mouse <yes|no>
focus_follows_mouse no

## border style for new windows
default_border normal 1

## border style for for floating windows <normal|1pixel|none>
default_floating_border normal 1

# hit same workspace focus key *again* and returns to previously focused
workspace_auto_back_and_forth yes

## orientation for new workspaces <horizontal|vertical|auto>
default_orientation vertical

# Use Mouse+$mod to drag floating windows to their wanted position
{{floating_modifier}}

#force_focus_wrapping yes

#########################
# MOVEMENT PARADIGM
#########################

# mod + <X> => move focus
# mod + Shift + <X> => move focus with selection
# mod + Ctrl + Shift + <X> => move selection (but not focus)

#########################
# WORKSPACE MOVEMENT
#########################

# move focus to next monitor
bindsym $mod+Right focus output right
bindsym $mod+Left focus output left

# move workspace and focus to next monitor
bindsym $mod+Shift+Right move workspace to output right; focus output right
bindsym $mod+Shift+Left move workspace to output left; focus output left

# just move workspace to next monitor
bindsym $mod+Ctrl+Shift+Right move workspace to output right
bindsym $mod+Ctrl+Shift+Left move workspace to output left

# move focus
bindsym $mod+period workspace next
bindsym $mod+comma workspace prev

# move with selection
bindsym $mod+Shift+period move container to workspace next; workspace next
bindsym $mod+Shift+comma move container to workspace prev; workspace prev

# just move selection
bindsym $mod+Ctrl+Shift+period move workspace next
bindsym $mod+Ctrl+Shift+comma move workspace prev

# go back to previously focused workspace
bindsym $mod+z workspace back_and_forth

# move selected to previously focused workspace and follow
bindsym $mod+Shift+z move container to workspace back_and_forth; workspace back_and_forth

# move selected to previously focused workspace
bindsym $mod+Ctrl+Shift+z move container to workspace back_and_forth

#######################
# FOCUS
#######################

# change focus
bindsym $mod+$left focus left
bindsym $mod+$right focus right
bindsym $mod+$down focus down
bindsym $mod+$up focus up

# focus the parent container
bindsym $mod+a focus parent

# focus the child container
bindsym $mod+Shift+A focus child

popup_during_fullscreen leave_fullscreen

#######################
# MOVEMENT
#######################
# move focused
bindsym $mod+Shift+$LeftShift move left
bindsym $mod+Shift+$RightShift move right
bindsym $mod+Shift+$DownShift move down
bindsym $mod+Shift+$UpShift move up

#######################
# WINDOW CONTROL
#######################

# split container in horizontal orientation
bindsym $mod+w split horizontal

# split container in vertical orientation
bindsym $mod+b split vertical

# enter fullscreen mode for the focused container
bindsym $mod+f fullscreen
bindsym $mod+Ctrl+Shift+F fullscreen global

# change container layout (stacked, tabbed, default)
bindsym $mod+s layout stacking
bindsym $mod+t layout tabbed
bindsym $mod+d layout default

# --------
# |      |
# --------
# |      |
# --------
# layout windows horizontally (IOW, split vertically)
bindsym $mod+h layout splitv

# -----
# | | |
# | | |
# -----
# layout windows vertically (IOW, split horizontally)
bindsym $mod+v layout splith

# toggle tiling / floating
bindsym $mod+Shift+space floating toggle

# change focus between tiling / floating windows
bindsym $mod+space focus mode_toggle


#######################
# WORKSPACES
#######################

set $ws1 1:w1
set $ws2 2:w2
set $ws3 3:w3
set $ws4 4:w4
set $ws5 5:w5
set $ws6 6:w6
set $ws7 7:w7
set $ws8 8:w8

# switch to workspace
bindsym $mod+1 workspace $ws1
bindsym $mod+2 workspace $ws2
bindsym $mod+3 workspace $ws3
bindsym $mod+4 workspace $ws4
bindsym $mod+5 workspace $ws5
bindsym $mod+6 workspace $ws6
bindsym $mod+7 workspace $ws7
bindsym $mod+8 workspace $ws8
# bindsym $mod+9 workspace 9
# bindsym $mod+0 workspace 10

# move focused container to workspace and follow
bindsym $mod+Shift+1 move container to workspace $ws1; workspace $ws1
bindsym $mod+Shift+2 move container to workspace $ws2; workspace $ws2
bindsym $mod+Shift+3 move container to workspace $ws3; workspace $ws3
bindsym $mod+Shift+4 move container to workspace $ws4; workspace $ws4
bindsym $mod+Shift+5 move container to workspace $ws5; workspace $ws5
bindsym $mod+Shift+6 move container to workspace $ws6; workspace $ws6
bindsym $mod+Shift+7 move container to workspace $ws7; workspace $ws7
bindsym $mod+Shift+8 move container to workspace $ws8; workspace $ws8

# move focused container to workspace
bindsym $mod+Ctrl+Shift+1 move workspace $ws1
bindsym $mod+Ctrl+Shift+2 move workspace $ws2
bindsym $mod+Ctrl+Shift+3 move workspace $ws3
bindsym $mod+Ctrl+Shift+4 move workspace $ws4
bindsym $mod+Ctrl+Shift+5 move workspace $ws5
bindsym $mod+Ctrl+Shift+6 move workspace $ws6
bindsym $mod+Ctrl+Shift+7 move workspace $ws7
bindsym $mod+Ctrl+Shift+8 move workspace $ws8

#######################
# App/Window Prefs
#######################

for_window [window_role="pop-up"] floating enabled

#######################
# RESIZE
#######################

# resize window (you can also use the mouse for that - (Alt-right-click))
# I only *grow* windows, for simplicity's sake

#bindsym $left resize shrink left 10 px or 10 ppt
bindsym $mod+Ctrl+Shift+$LeftShift resize grow   left 10 px or 10 ppt

#bindsym l resize shrink right 10 px or 10 ppt
bindsym $mod+Ctrl+Shift+$RightShift resize grow   right 10 px or 10 ppt

#bindsym j resize shrink down 10 px or 10 ppt
bindsym $mod+Ctrl+Shift+$DownShift resize grow   down 10 px or 10 ppt

#bindsym k resize shrink up 10 px or 10 ppt
bindsym $mod+Ctrl+Shift+$UpShift resize grow   up 10 px or 10 ppt

#########################
# Preferred applications
#########################

set $chrome_env_opts {{chrome_environment_opts}}
set $browser1 google-chrome-stable --user-data-dir=/home/jtprince/.config/chrome-personal $chrome_env_opts
set $browser2 google-chrome-stable $chrome_env_opts
set $newwindow --new-window

bindsym $mod+x exec terminal-emulator

bindsym $mod+i exec $browser1
bindsym $mod+Shift+I exec $browser2
bindsym $mod+Ctrl+Shift+I exec firefox -P personal

bindsym XF86Mail exec $browser1 $newwindow https://mail.google.com
bindsym $mod+e exec $browser1 $newwindow http://mail.google.com
bindsym $mod+Shift+E exec $browser2 $newwindow http://mail.google.com

bindsym $mod+c exec $browser1 $newwindow http://calendar.google.com
bindsym $mod+Ctrl+Shift+C exec $browser2 $newwindow http://calendar.google.com

# bindsym $mod+y exec $browser1 $newwindow https://mail.google.com/tasks/ig
# bindsym $mod+Shift+Y exec $browser2 $newwindow https://mail.google.com/tasks/ig

bindsym $mod+n exec file-manager

bindsym $mod+Shift+T exec todo

bindsym XF86Documents exec libreoffice --minimized --nologo --writer
# bindsym $mod+g exec env NVIM_GTK_NO_HEADERBAR=1 nvim-gtk -- -c 'let g:pymode_rope=0'
bindsym $mod+g exec alacritty -e sleep-and-start-nvim

bindsym XF86Calculator exec --no-startup-id notifications-toggle

bindsym XF86Phone exec $browser1 $newwindow http://voice.google.com

{{screenshot_commands}}

###########################
# Keyboard shortcuts
###########################

{{middle_click}}

# ☆ <Favorites> toggles monitor setting
set $monitor_laptop_cmd {{monitor_laptop_cmd}}
set $monitor_primary1_cmd {{monitor_primary1_cmd}}
set $monitor_primary2_cmd {{monitor_primary2_cmd}}

bindsym $locked XF86Display exec --no-startup-id $monitor_laptop_cmd
bindsym $locked XF86HomePage exec --no-startup-id $monitor_primary1_cmd
bindsym $locked XF86Favorites exec --no-startup-id $monitor_primary2_cmd

{{laptop_keyboard_toggle}}

###########################
# LIFE, DEATH, and SLEEPING
###########################

# kill focused window
bindsym $mod+Shift+C kill

# open a file in gvim with fzf
# WIP: for some reason this will not work (but will when launched from # terminal)!
# for_window [instance="menu-launcher"] floating enable
# bindsym $mod+Shift+O exec --no-startup-id urxvt -title "launch in gvim" -name "menu-launcher" -e bash -c 'cmd=$(fzfo); setsid -f $cmd'
bindsym $mod+Shift+P exec dmenu_run

# rofi:
# yay -S dmenu-recent-aliases-git
# bindsym $mod+Shift+P exec rofi -show run

# restart sway/i3 inplace (preserves your layout/session, can be used to upgrade i3)
# bindsym $mod+Shift+R restart

# Reload the configuration file
bindsym $mod+Shift+U reload

# Exit sway (logs you out of your Wayland session)
bindsym $mod+Shift+Q exec {{exit_cmd}}

# power/on-off management:
# note, you may need to: sudo chmod u+s /sbin/poweroff
bindsym $mod+Ctrl+Shift+P exec --no-startup-id before-i3-exit && systemctl poweroff
bindsym $mod+Ctrl+Shift+R exec --no-startup-id before-i3-exit && systemctl reboot
# suspend (RAM)
bindsym $mod+Ctrl+Shift+S exec --no-startup-id suspend-with-screenlock
bindsym $mod+Ctrl+Shift+H exec --no-startup-id hibernate-with-screenlock

{{special_sleep}}

bindsym XF86Sleep exec --no-startup-id suspend-with-screenlock


{{scratchpad}}

{{misc_editing}}

#######################
# BAR
#######################

bar {
  mode dock
  position bottom
  font pango:Droid Sans Mono $globalfontsize, Icons $globalfontsize
  status_command status.rb

  # Seems like we want tray on any monitor, so comment out
  # tray_output primary

  colors {
    background $ddblue
    statusline $white
    separator  $ddblue

    # class            border     bground    text
    focused_workspace  $subgreen  $subgreen  $white
    active_workspace   $ddblue    $dblue     $white
    inactive_workspace $ddblue    $ddblue    $lgray
    urgent_workspace   $red       $red       $white
    binding_mode       $red       $red       $white
  }
}

{{scripting}}

{{keybindings}}
