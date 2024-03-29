-- Super awesome reference to borrow the code from
-- https://github.com/jonascj/.xmonad/blob/master/xmonad.hs
-- https://www.youtube.com/watch?v=FX26s8INUYo&t=80s

import Data.Monoid
import Graphics.X11.ExtraTypes.XF86
import Graphics.X11.Xlib.Cursor
import System.Exit
import XMonad
import XMonad.Actions.CycleWS
import XMonad.Actions.MouseResize
import XMonad.Hooks.DynamicBars
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, defaultPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Layout.Grid
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.Reflect
import XMonad.Layout.Renamed
import XMonad.Layout.SimpleFloat
import XMonad.Layout.Spacing
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import XMonad.Util.Cursor
import XMonad.Util.Run
import XMonad.Util.Ungrab
import qualified Data.Time.LocalTime as LT
import qualified XMonad.Hooks.ManageDocks
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

-- My terminal to use
myTerminal      = "~/repos/kitty/kitty.app/bin/kitty"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = False

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
myBorderWidth   = 2

-- The mod key
myModMask       = mod1Mask

-- The default number of workspaces (virtual screens) and their names.
myWorkspaces    = ["1","2","3","4","5","6","7","8","9"]

-- Colors for unfocused and focused windows, respectively.
myNormalBorderColor  = "#282c34"
myFocusedBorderColor = "#46d9ff"

-- Key bindings. Add, modify or remove key bindings here.
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

    -- launch dmenu
    , ((modm .|. shiftMask, xK_p     ), spawn "dmenu_run")

    -- Switch to the last workspace, similar to tmux last window
    , ((modm,               xK_a     ), toggleWS)

    -- close focused window
    , ((modm,               xK_q     ), unGrab *> kill)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm .|. shiftMask, xK_n     ), refresh)

    -- Move to next/previous workspace
    , ((modm,               xK_n     ), nextWS)
    , ((modm,               xK_p     ), prevWS)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm,               xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm,               xK_l     ), sendMessage Shrink)  -- This is flipped, since I want the master pane on the right

    -- Expand the master area
    , ((modm,               xK_h     ), sendMessage Expand)  -- This is flipped, since I want the master pane on the right

    -- Send window to float
    , ((modm,               xK_f     ), sendMessage (MT.Toggle NBFULL)
                                        >> sendMessage ToggleStruts
                                        -- >> toggleSmartSpacing -- Ubuntu 18.04 has 0.13, which this method doesn't exist
                                        )

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Screenshot
    -- , ((modm              , xK_s     ), unGrab *> spawn "~/.local/bin/shot")
    -- , ((modm .|. shiftMask, xK_s     ), unGrab *> spawn "~/.local/bin/shot -s")
    , ((modm              , xK_s     ), spawn "~/.local/bin/shot")
    , ((modm .|. shiftMask, xK_s     ), spawn "~/.local/bin/shot -s")

    -- Lock the screen
    , ((modm .|. shiftMask                , xK_c     ), spawn "xscreensaver-command -lock")
    , ((modm .|. shiftMask .|. controlMask, xK_c     ), spawn "xscreensaver-command -lock ; sleep 10 ; systemctl suspend")
    -- , ((modm .|. shiftMask             , xK_c     ), spawn "xautolock -locknow")

    -- Start the arandr
    , ((modm              , xK_x     ), spawn "arandr")

    -- Start the pavucontros
    , ((modm .|. shiftMask, xK_v     ), spawn "pavucontrol")

    -- Quit xmonad
    , ((modm .|. shiftMask .|. controlMask, xK_q     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm .|. shiftMask, xK_q     ), spawn "pkill stalonetray ; xmonad --recompile; xmonad --restart")

    -- Startup many things
    , ((modm .|. shiftMask, xK_y     ), myMoreStartup)

    -- Run xmessage with a summary of the default keybindings (useful for beginners)
    , ((modm .|. shiftMask, xK_slash ), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))
    ]

    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    ++
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
    ]

    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    ++
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]
    ]

    -- Manipulate volume
    ++
    [ ((0, xF86XK_AudioMute), mute)
    , ((0, xF86XK_AudioLowerVolume), quieter)
    , ((0, xF86XK_AudioRaiseVolume), louder)
    , ((modm .|. shiftMask, xK_z), mute)
    , ((modm              , xK_z), quieter)
    , ((modm              , xK_v), louder)
    ]

    -- Manupulate backlight
    ++
    [ ((0, xF86XK_MonBrightnessDown), dimmer)
    , ((0, xF86XK_MonBrightnessUp), brighter)
    , ((modm              , xK_b), dimmer)
    , ((modm .|. shiftMask, xK_b), brighter)
    ]

    where
        brighter = spawn "xbacklight -inc 10"
        dimmer = spawn "xbacklight -dec 10"
        mute = spawn "amixer -D pulse -q set Master toggle"
        quieter = spawn "amixer -D pulse -q set Master 5%-"
        louder = spawn "amixer -D pulse -q set Master 5%+"


-- Mouse bindings: default actions bound to mouse events
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

-- Layouts:
myLayout = avoidStruts
    $ applyToMany
    $ full
        ||| tiled
        ||| grid
        ||| simpleFloat
  where
    applyToMany = smartBorders
        . mouseResize
        . windowArrange
        . mkToggle (NBFULL ?? NOBORDERS ?? EOT)
    surround = spacing 6  -- . mySpace 8  -- Ubuntu 18.04 has 0.13, which this method doesn't exist

    -- Tile: Master and stack layout
    tiled   = renamed [Replace "Tile"] $ reflectHoriz . surround $ Tall nmaster delta ratio
    nmaster = 1  -- The default number of windows in the master pane
    ratio   = 0.618  -- Default proportion of screen occupied by master pane
    delta   = 3/100  -- Percent of screen to increment by when resizing panes

    -- Grid
    grid = renamed [Replace "Grid"] $ reflectHoriz $ surround Grid

    -- Full
    full = renamed [Replace "Full"] $ surround Full

-- Window rules:
myManageHook = manageDocks <+> composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore
    , isFullscreen --> doFullFloat
    ]

-- Event handling
myEventHook = do
    dynStatusBarEventHook barCreator barDestroyer <+> docksEventHook  -- <+> fullscreenEventHook, -- Use meta-f to switch to full instead

-- Startup hook
myStartupHook = do
    dynStatusBarStartup barCreator barDestroyer
    setDefaultCursor xC_left_ptr
    setWMName "LG3D"

-- Log hook
myLogHook = do
    multiPP myLogPP myLogPP

-- Some startup action
myStartup = do
    spawn "~/.local/bin/wm_start.sh"

-- More startup
myMoreStartup = do
    spawn "~/.local/bin/wm_start_adv.sh"

-- Run xmonad with the settings you specify. No need to modify this.
main = do
    myStartup

    xmonad $ docks $ ewmh $ defaultConfig {
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,
        keys               = myKeys,
        mouseBindings      = myMouseBindings,
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        logHook            = myLogHook,
        startupHook        = myStartupHook
    }

-- Help string
help :: String
help = unlines ["The default modifier key is 'alt'. Default keybindings:",
    "",
    "-- run apps",
    "Launch terminal                                        : mod-Shift-Enter",
    "Launch dmenu                                           : mod-Shift-p",
    "Launch arandr                                          : mod-x",
    "Launch pavucontrol                                     : mod-Shift-v",
    "Close/kill the focused window                          : mod-q",
    "",
    "-- layout or workspaces",
    "Change to last workspace                               : mod-a",
    "Change to next workspace                               : mod-n",
    "Change to prev workspace                               : mod-p",
    "Rotate through the available layout algorithms         : mod-Space",
    "Toggle full screen layout                              : mod-f",
    "Reset the layouts on the current workSpace to default  : mod-Shift-Space",
    "Resize/refresh viewed windows to the correct size      : mod-Shift-n",
    "Push window back into tiling; unfloat and re-tile it   : mod-t",
    "",
    "-- focus",
    "Focus to the next window                               : mod-Tab",
    "Focus to the previous window                           : mod-Shift-Tab",
    "Focus to the next window                               : mod-j",
    "Focus to the previous window                           : mod-k",
    "Focus to the master window                             : mod-m",
    "Focus to physical/Xinerama screens 1, 2, or 3          : mod-{w,e,r}",
    "Focus to workSpace N                                   : mod-[1..9]",
    "",
    "-- swap move windows",
    "Swap the focused window and the master window          : mod-Return",
    "Swap the focused window with the next window           : mod-Shift-j",
    "Swap the focused window with the previous window       : mod-Shift-k",
    "Move client to workspace N                             : mod-Shift-[1..9]",
    "Move client to screen 1, 2, or 3                       : mod-Shift-{w,e,r}",
    "",
    "-- resizing windows",
    "Shrink the master area                                 : mod-h",
    "Expand the master area                                 : mod-l",
    "Increment the number of windows in the master area     : mod-comma  (mod-,)",
    "Deincrement the number of windows in the master area   : mod-period (mod-.)",
    "",
    "-- screenshot",
    "Taking entire desktop screenshot                       : mod-s",
    "Taking select area screenshot                          : mod-shift-s",
    "",
    "-- system",
    "Brighter screen                                        : mod-Shift-b",
    "Dimmer screen                                          : mod-b",
    "Mute Audio                                             : mod-Shift-z",
    "Louder Audio                                           : mod-v",
    "Quieter Audio                                          : mod-z",
    "Lock screen                                            : mod-Shift-c",
    "Put system to sleep                                    : mod-Ctrl-Shift-c",
    "Quit xmonad                                            : mod-Ctrl-Shift-q",
    "Restart xmonad                                         : mod-Shift-q",
    "Additional Startup                                     : mod-Shift-y",
    "",
    "-- Mouse bindings",
    "Set the window to floating mode and move by dragging   : mod-button1",
    "Raise the window to the top of the stack               : mod-button2",
    "Set the window to floating mode and resize by dragging : mod-button3"]

-- Functions to handle the status bar creation
barCreator :: DynamicStatusBar
barCreator (S sid) = do
    t <- liftIO LT.getZonedTime
    trace (show t ++ ": XMonad barCreator " ++ show sid)
    if (sid == 0) then spawn "stalonetray --config ~/.config/stalonetray/stalonetrayrc" else return ()
    spawnPipe barcmd
        where barcmd
                | sid == 0 = ("xmobar --screen " ++ show sid ++ " ~/.config/xmobar/xmobarrc")
                | sid >= 1 = ("xmobar --screen " ++ show sid ++ " ~/.config/xmobar/xmobarrc-side")

barDestroyer :: DynamicStatusBarCleanup
barDestroyer = do
    t <- liftIO LT.getZonedTime
    trace (show t ++ ": XMonad barDestroyer")

-- Get the number of windows
windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

-- How the status bar is configured
myLogPP :: PP
myLogPP = xmobarPP
    { ppCurrent         = xmobarColor "#98be65" "" . wrap "[" "]" --  Current workspace
    , ppVisible         = xmobarColor "#98be65" ""                --  Visible but not current workspace
    , ppHidden          = xmobarColor "#82AAFF" "" . wrap "*" ""  --  Hidden workspaces
    , ppHiddenNoWindows = xmobarColor "#c792ea" ""                --  Hidden workspaces (no windows)
    , ppTitle           = xmobarColor "#b3afc2" "" . shorten 60   --  Title of active window
    , ppSep             = " : "                                   --  Separator character
    , ppUrgent          = xmobarColor "#C45500" "" . wrap "!" "!" --  Urgent workspace
    , ppExtras          = [windowCount]                           --  # of windows current workspace
    , ppOrder           = \(ws:l:t:ex) -> [ws,l]++ex++[t]         --  order of things in xmobar
    }

-- -- Add space around the window -- Ubuntu 18.04 has 0.13, which this method doesn't exist
-- mySpace i = spacingRaw False (Border 0 i 0 i) True (Border i 0 i 0) True

-- vim:et sw=4 ts=4 sts=4
