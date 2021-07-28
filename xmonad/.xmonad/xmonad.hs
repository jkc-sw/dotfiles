
-- Super awesome reference to borrow the code from
-- https://github.com/jonascj/.xmonad/blob/master/xmonad.hs

import Data.Monoid
import Graphics.X11.ExtraTypes.XF86
import Graphics.X11.Xlib.Cursor
import System.Exit
import XMonad
import XMonad.Actions.MouseResize
import XMonad.Hooks.DynamicBars
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, defaultPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.NoBorders
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
myModMask       = mod4Mask

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
    , ((modm,               xK_p     ), spawn ". ~/.shellfunc ; dmenu_run")

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
    , ((modm              , xK_s     ), unGrab *> spawn "export SCREENSHOT_DIR=$HOME/Downloads ; mkdir -p $SCREENSHOT_DIR ; sleep 0.2; scrot -m \"$SCREENSHOT_DIR/%Y-%m-%d-%H%M%S_\\$wx\\$h.png\"")
    , ((modm .|. shiftMask, xK_s     ), unGrab *> spawn "export SCREENSHOT_DIR=$HOME/Downloads ; mkdir -p $SCREENSHOT_DIR ; sleep 0.2; scrot -s \"$SCREENSHOT_DIR/%Y-%m-%d-%H%M%S_\\$wx\\$h.png\"")

    -- Lock the screen
    -- , ((modm .|. shiftMask, xK_l     ), spawn "xscreensaver-command -lock")
    , ((modm .|. shiftMask, xK_l     ), spawn "xautolock -locknow")

    -- Start the arandr
    , ((modm              , xK_a     ), spawn "arandr")

    -- Start the pavucontros
    , ((modm              , xK_v     ), spawn "pavucontrol")

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm              , xK_q     ), spawn "xmonad --recompile; xmonad --restart")

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
    [ ((0, xF86XK_AudioMute),     spawn "amixer -D pulse -q set Master toggle")
    , ((0, xF86XK_AudioLowerVolume), spawn "amixer -D pulse -q set Master 5%-")
    , ((0, xF86XK_AudioRaiseVolume), spawn "amixer -D pulse -q set Master 5%+")
    ]

    -- Manupulate backlight
    ++
    [ ((0, xF86XK_MonBrightnessDown),   spawn "xbacklight -dec 10")
    , ((0, xF86XK_MonBrightnessUp),   spawn "xbacklight -inc 10")
    ]


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
    $ smartBorders
    -- $ mySpace 8 -- Ubuntu 18.04 has 0.13, which this method doesn't exist
    $ mouseResize
    $ windowArrange
    $ mkToggle (NBFULL ?? NOBORDERS ?? EOT)
    $ tiled ||| Mirror tiled ||| Full ||| simpleFloat
  where
     tiled   = Tall nmaster delta ratio  -- default tiling algorithm partitions the screen into two panes
     nmaster = 1  -- The default number of windows in the master pane
     ratio   = 1/2  -- Default proportion of screen occupied by master pane
     delta   = 3/100  -- Percent of screen to increment by when resizing panes

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

-- Log hook
myLogHook = do
    multiPP myLogPP myLogPP

-- Run xmonad with the settings you specify. No need to modify this.
main = do
    spawn "feh --bg-scale ~/.xmonad/pure-black.png"

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
    "-- launching and killing programs",
    "Launch terminal                                        : mod-Shift-Enter",
    "Launch dmenu                                           : mod-p",
    "Launch gmrun                                           : mod-Shift-p",
    "Launch arandr                                          : mod-a",
    "Launch pavucontrol                                     : mod-v",
    "Close/kill the focused window                          : mod-Shift-c",
    "",
    "-- Change layout/workspace",
    "Rotate through the available layout algorithms         : mod-Space",
    "Toggle full screen layout                              : mod-f",
    "Reset the layouts on the current workSpace to default  : mod-Shift-Space",
    "Resize/refresh viewed windows to the correct size      : mod-n",
    "Push window back into tiling; unfloat and re-tile it   : mod-t",
    "",
    "-- move focus",
    "Move focus to the next window                          : mod-Tab",
    "Move focus to the previous window                      : mod-Shift-Tab",
    "Move focus to the next window                          : mod-j",
    "Move focus to the previous window                      : mod-k",
    "Move focus to the master window                        : mod-m",
    "",
    "-- swap windows",
    "Swap the focused window and the master window          : mod-Return",
    "Swap the focused window with the next window           : mod-Shift-j",
    "Swap the focused window with the previous window       : mod-Shift-k",
    "",
    "-- resizing windows",
    "Shrink the master area                                 : mod-h",
    "Expand the master area                                 : mod-l",
    "Increment the number of windows in the master area     : mod-comma  (mod-,)",
    "Deincrement the number of windows in the master area   : mod-period (mod-.)",
    "",
    "-- screen shot",
    "Taking entire desktop screenshot                       : mod-s",
    "Taking select area screenshot                          : mod-shift-s",
    "",
    "-- quit, or restart",
    "Lock screen                                            : mod-Shift-l",
    "Quit xmonad                                            : mod-Shift-q",
    "Restart xmonad                                         : mod-q",
    "Switch to workSpace N                                  : mod-[1..9]",
    "",
    "-- Workspaces & screens",
    "Move client to workspace N                             : mod-Shift-[1..9]",
    "Switch to physical/Xinerama screens 1, 2, or 3         : mod-{w,e,r}",
    "Move client to screen 1, 2, or 3                       : mod-Shift-{w,e,r}",
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
