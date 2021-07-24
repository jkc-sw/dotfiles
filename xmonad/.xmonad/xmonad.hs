
import XMonad
import Data.Monoid
import System.Exit
import XMonad.Util.Run
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, defaultPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Layout.SimpleFloat
import Graphics.X11.ExtraTypes.XF86
import XMonad.Util.Ungrab

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

-- My terminal to use
myTerminal      = "kitty"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = False

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
--
myBorderWidth   = 2

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask       = mod1Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
myWorkspaces    = ["1","2","3","4","5","6","7","8","9"]

-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor  = "#282c34"
myFocusedBorderColor = "#46d9ff"

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

    -- launch dmenu
    , ((modm,               xK_p     ), spawn "dmenu_run")

    -- launch gmrun
    , ((modm .|. shiftMask, xK_p     ), spawn "gmrun")

    -- close focused window
    , ((modm .|. shiftMask, xK_c     ), kill)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

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
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Screenshot
    , ((modm              , xK_s     ), unGrab *> spawn "export SCREENSHOT_DIR=$HOME/Downloads ; mkdir -p $SCREENSHOT_DIR ; sleep 0.2; scrot -m \"$SCREENSHOT_DIR/%Y-%m-%d-%H%M%S_\\$wx\\$h.png\"")
    , ((modm .|. shiftMask, xK_s     ), unGrab *> spawn "export SCREENSHOT_DIR=$HOME/Downloads ; mkdir -p $SCREENSHOT_DIR ; sleep 0.2; scrot -s \"$SCREENSHOT_DIR/%Y-%m-%d-%H%M%S_\\$wx\\$h.png\"")

    -- Lock the screen
    , ((modm .|. shiftMask, xK_l     ), spawn "xscreensaver-command -lock")

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    -- , ((modm              , xK_q     ), spawn "pkill stalonetray; pkill xmobar; xmonad --recompile; xmonad --restart")
    , ((modm              , xK_q     ), spawn "xmonad --recompile; xmonad --restart")

    -- Run xmessage with a summary of the default keybindings (useful for beginners)
    , ((modm .|. shiftMask, xK_slash ), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
    ++

    -- Manipulate volume
    [ ((0, xF86XK_AudioMute),        spawn "amixer -D pulse -q set Master toggle")
    , ((0, xF86XK_AudioLowerVolume), spawn "amixer -D pulse -q set Master 5%-")
    , ((0, xF86XK_AudioRaiseVolume), spawn "amixer -D pulse -q set Master 5%+")
    ]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
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

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
myLayout = avoidStruts (tiled ||| Mirror tiled ||| Full ||| simpleFloat)
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 1/2

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore ]

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = mempty


------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = return ()

-- Get the number of windows
windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main = do
    xmproc <- spawnPipe "xmobar ~/.config/xmobar/xmobarrc"
    -- spawn "nautilus --no-desktop -n &" -- The flag doesn't exist anymore

    spawn "stalonetray --config ~/.config/stalonetray/stalonetrayrc"

    xmonad $ docks def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        logHook            = dynamicLogWithPP $ xmobarPP
            { ppOutput          = hPutStrLn xmproc                        --  xmobar on monitor 1
            , ppCurrent         = xmobarColor "#98be65" "" . wrap "[" "]" --  Current workspace
            , ppVisible         = xmobarColor "#98be65" ""                --  Visible but not current workspace
            , ppHidden          = xmobarColor "#82AAFF" "" . wrap "*" ""  --  Hidden workspaces
            , ppHiddenNoWindows = xmobarColor "#c792ea" ""                --  Hidden workspaces (no windows)
            , ppTitle           = xmobarColor "#b3afc2" "" . shorten 60   --  Title of active window
            , ppSep             = " : "                                   --  Separator character
            , ppUrgent          = xmobarColor "#C45500" "" . wrap "!" "!" --  Urgent workspace
            , ppExtras          = [windowCount]                           --  # of windows current workspace
            , ppOrder           = \(ws:l:t:ex) -> [ws,l]++ex++[t]         --  order of things in xmobar
            },
        startupHook        = myStartupHook
    }

-- | Finally, a copy of the default bindings in simple textual tabular format.
help :: String
help = unlines ["The default modifier key is 'alt'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "Launch xterminal                                               : mod-Shift-Enter",
    "Launch dmenu                                                   : mod-p",
    "Launch gmrun                                                   : mod-Shift-p",
    "Close/kill the focused window                                  : mod-Shift-c",
    "Rotate through the available layout algorithms                 : mod-Space",
    "Reset the layouts on the current workSpace to default          : mod-Shift-Space",
    "Resize/refresh viewed windows to the correct size              : mod-n",
    "",
    "-- move focus up or down the window stack",
    "Move focus to the next window                                  : mod-Tab",
    "Move focus to the previous window                              : mod-Shift-Tab",
    "Move focus to the next window                                  : mod-j",
    "Move focus to the previous window                              : mod-k",
    "Move focus to the master window                                : mod-m",
    "",
    "-- modifying the window order",
    "Swap the focused window and the master window                  : mod-Return",
    "Swap the focused window with the next window                   : mod-Shift-j",
    "Swap the focused window with the previous window               : mod-Shift-k",
    "",
    "-- resizing the master/slave ratio",
    "Shrink the master area                                         : mod-h",
    "Expand the master area                                         : mod-l",
    "",
    "-- floating layer support",
    "Push window back into tiling; unfloat and re-tile it           : mod-t",
    "",
    "-- increase or decrease number of windows in the master area",
    "Increment the number of windows in the master area             : mod-comma  (mod-,)",
    "Deincrement the number of windows in the master area           : mod-period (mod-.)",
    "",
    "-- screen shot",
    "Taking entire desktop screenshot                               : mod-s",
    "Taking select area screenshot                                  : mod-shift-s",
    "",
    "-- quit, or restart",
    "Lock screen                                                    : mod-Shift-l",
    "Quit xmonad                                                    : mod-Shift-q",
    "Restart xmonad                                                 : mod-q",
    "Switch to workSpace N                                          : mod-[1..9]",
    "",
    "-- Workspaces & screens",
    "Move client to workspace N                                     : mod-Shift-[1..9]",
    "Switch to physical/Xinerama screens 1, 2, or 3                 : mod-{w,e,r}",
    "Move client to screen 1, 2, or 3                               : mod-Shift-{w,e,r}",
    "",
    "default actions bound to mouse events                          : -- Mouse bindings",
    "Set the window to floating mode and move by dragging           : mod-button1",
    "Raise the window to the top of the stack                       : mod-button2",
    "Set the window to floating mode and resize by dragging         : mod-button3"]


-- vim:et sw=4 ts=4 sts=4

