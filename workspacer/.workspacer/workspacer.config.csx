#r "C:\Users\chenkua\scoop\apps\workspacer\current\workspacer.Shared.dll"
#r "C:\Users\chenkua\scoop\apps\workspacer\current\plugins\workspacer.Bar\workspacer.Bar.dll"
#r "C:\Users\chenkua\scoop\apps\workspacer\current\plugins\workspacer.ActionMenu\workspacer.ActionMenu.dll"
#r "C:\Users\chenkua\scoop\apps\workspacer\current\plugins\workspacer.FocusIndicator\workspacer.FocusIndicator.dll"

using System;
using workspacer;
using workspacer.Bar;
using workspacer.ActionMenu;
using workspacer.FocusIndicator;

Action<IConfigContext> doConfig = context =>
{
    // Uncomment to switch update branch (or to disable updates)
    //context.Branch = Branch.None

    // From https://github.com/rickbutton/workspacer/blob/master/src/workspacer/Keybinds/KeybindManager.cs
    // From https://workspacer.org/config/
    // From https://github.com/rickbutton/workspacer/blob/master/src/workspacer.Shared/Keybind/KeyModifiers.cs
    var mod = KeyModifiers.LAlt;
    context.Keybinds.UnsubscribeAll();
    context.Keybinds.Subscribe(MouseEvent.LButtonDown,                   () => context.Workspaces.SwitchFocusedMonitorToMouseLocation());
    context.Keybinds.Subscribe(mod,                      Keys.A,         () => context.Enabled = !context.Enabled,                                    "toggle enable/disable");
    context.Keybinds.Subscribe(mod | KeyModifiers.Shift, Keys.C,         () => context.Workspaces.FocusedWorkspace.CloseFocusedWindow(),              "close focused window");
    context.Keybinds.Subscribe(mod,                      Keys.Space,     () => context.Workspaces.FocusedWorkspace.NextLayoutEngine(),                "next layout");
    context.Keybinds.Subscribe(mod | KeyModifiers.Shift, Keys.Space,     () => context.Workspaces.FocusedWorkspace.PreviousLayoutEngine(),            "previous layout");
    context.Keybinds.Subscribe(mod,                      Keys.N,         () => context.Workspaces.FocusedWorkspace.ResetLayout(),                     "reset layout");
    context.Keybinds.Subscribe(mod,                      Keys.Up,        () => context.Workspaces.FocusedWorkspace.FocusNextWindow(),                 "focus next window");
    context.Keybinds.Subscribe(mod,                      Keys.Down,      () => context.Workspaces.FocusedWorkspace.FocusPreviousWindow(),             "focus previous window");
    context.Keybinds.Subscribe(mod,                      Keys.M,         () => context.Workspaces.FocusedWorkspace.FocusPrimaryWindow(),              "focus primary window");
    context.Keybinds.Subscribe(mod,                      Keys.Enter,     () => context.Workspaces.FocusedWorkspace.SwapFocusAndPrimaryWindow(),       "swap focus and primary window");
    context.Keybinds.Subscribe(mod | KeyModifiers.Shift, Keys.Up,        () => context.Workspaces.FocusedWorkspace.SwapFocusAndNextWindow(),          "swap focus and next window");
    context.Keybinds.Subscribe(mod | KeyModifiers.Shift, Keys.Down,      () => context.Workspaces.FocusedWorkspace.SwapFocusAndPreviousWindow(),      "swap focus and previous window");
    context.Keybinds.Subscribe(mod,                      Keys.H,         () => context.Workspaces.FocusedWorkspace.ShrinkPrimaryArea(),               "shrink primary area");
    context.Keybinds.Subscribe(mod,                      Keys.L,         () => context.Workspaces.FocusedWorkspace.ExpandPrimaryArea(),               "expand primary area");
    context.Keybinds.Subscribe(mod,                      Keys.Oemcomma,  () => context.Workspaces.FocusedWorkspace.IncrementNumberOfPrimaryWindows(), "increment # primary windows");
    context.Keybinds.Subscribe(mod,                      Keys.OemPeriod, () => context.Workspaces.FocusedWorkspace.DecrementNumberOfPrimaryWindows(), "decrement # primary windows");
    context.Keybinds.Subscribe(mod,                      Keys.T,         () => context.Windows.ToggleFocusedWindowTiling(),                           "toggle tiling for focused window");
    context.Keybinds.Subscribe(mod | KeyModifiers.Shift, Keys.Q,         context.Quit,                                                                "quit workspacer");
    context.Keybinds.Subscribe(mod,                      Keys.Q,         context.Restart,                                                             "restart workspacer");
    context.Keybinds.Subscribe(mod,                      Keys.D1,        () => context.Workspaces.SwitchToWorkspace(0),                               "switch to workspace 1");
    context.Keybinds.Subscribe(mod,                      Keys.D2,        () => context.Workspaces.SwitchToWorkspace(1),                               "switch to workspace 2");
    context.Keybinds.Subscribe(mod,                      Keys.D3,        () => context.Workspaces.SwitchToWorkspace(2),                               "switch to workspace 3");
    context.Keybinds.Subscribe(mod,                      Keys.D4,        () => context.Workspaces.SwitchToWorkspace(3),                               "switch to workspace 4");
    context.Keybinds.Subscribe(mod,                      Keys.D5,        () => context.Workspaces.SwitchToWorkspace(4),                               "switch to workspace 5");
    context.Keybinds.Subscribe(mod,                      Keys.D6,        () => context.Workspaces.SwitchToWorkspace(5),                               "switch to workspace 6");
    context.Keybinds.Subscribe(mod,                      Keys.D7,        () => context.Workspaces.SwitchToWorkspace(6),                               "switch to workspace 7");
    context.Keybinds.Subscribe(mod,                      Keys.D8,        () => context.Workspaces.SwitchToWorkspace(7),                               "switch to workspace 8");
    context.Keybinds.Subscribe(mod,                      Keys.D9,        () => context.Workspaces.SwitchToWorkspace(8),                               "switch to workpsace 9");
    context.Keybinds.Subscribe(mod,                      Keys.Left,      () => context.Workspaces.SwitchToPreviousWorkspace(),                        "switch to previous workspace");
    context.Keybinds.Subscribe(mod,                      Keys.Right,     () => context.Workspaces.SwitchToNextWorkspace(),                            "switch to next workspace");
    context.Keybinds.Subscribe(mod,                      Keys.Oemtilde,  () => context.Workspaces.SwitchToLastFocusedWorkspace(),                     "switch to last focused workspace");
    context.Keybinds.Subscribe(mod,                      Keys.W,         () => context.Workspaces.SwitchFocusedMonitor(0),                            "focus monitor 1");
    context.Keybinds.Subscribe(mod,                      Keys.E,         () => context.Workspaces.SwitchFocusedMonitor(1),                            "focus monitor 2");
    context.Keybinds.Subscribe(mod,                      Keys.R,         () => context.Workspaces.SwitchFocusedMonitor(2),                            "focus monitor 3");
    context.Keybinds.Subscribe(mod | KeyModifiers.Shift, Keys.W,         () => context.Workspaces.MoveFocusedWindowToMonitor(0),                      "move focused window to monitor 1");
    context.Keybinds.Subscribe(mod | KeyModifiers.Shift, Keys.E,         () => context.Workspaces.MoveFocusedWindowToMonitor(1),                      "move focused window to monitor 2");
    context.Keybinds.Subscribe(mod | KeyModifiers.Shift, Keys.R,         () => context.Workspaces.MoveFocusedWindowToMonitor(2),                      "move focused window to monitor 3");
    context.Keybinds.Subscribe(mod | KeyModifiers.Shift, Keys.D1,        () => context.Workspaces.MoveFocusedWindowToWorkspace(0),                    "switch focused window to workspace 1");
    context.Keybinds.Subscribe(mod | KeyModifiers.Shift, Keys.D2,        () => context.Workspaces.MoveFocusedWindowToWorkspace(1),                    "switch focused window to workspace 2");
    context.Keybinds.Subscribe(mod | KeyModifiers.Shift, Keys.D3,        () => context.Workspaces.MoveFocusedWindowToWorkspace(2),                    "switch focused window to workspace 3");
    context.Keybinds.Subscribe(mod | KeyModifiers.Shift, Keys.D4,        () => context.Workspaces.MoveFocusedWindowToWorkspace(3),                    "switch focused window to workspace 4");
    context.Keybinds.Subscribe(mod | KeyModifiers.Shift, Keys.D5,        () => context.Workspaces.MoveFocusedWindowToWorkspace(4),                    "switch focused window to workspace 5");
    context.Keybinds.Subscribe(mod | KeyModifiers.Shift, Keys.D6,        () => context.Workspaces.MoveFocusedWindowToWorkspace(5),                    "switch focused window to workspace 6");
    context.Keybinds.Subscribe(mod | KeyModifiers.Shift, Keys.D7,        () => context.Workspaces.MoveFocusedWindowToWorkspace(6),                    "switch focused window to workspace 7");
    context.Keybinds.Subscribe(mod | KeyModifiers.Shift, Keys.D8,        () => context.Workspaces.MoveFocusedWindowToWorkspace(7),                    "switch focused window to workspace 8");
    context.Keybinds.Subscribe(mod | KeyModifiers.Shift, Keys.D9,        () => context.Workspaces.MoveFocusedWindowToWorkspace(8),                    "switch focused window to workspace 9");
    context.Keybinds.Subscribe(mod,                      Keys.O,         () => context.Windows.DumpWindowDebugOutput(),                               "dump debug info to console for all windows");
    context.Keybinds.Subscribe(mod | KeyModifiers.Shift, Keys.O,         () => context.Windows.DumpWindowUnderCursorDebugOutput(),                    "dump debug info to console for window under cursor");
    context.Keybinds.Subscribe(mod | KeyModifiers.Shift, Keys.I,         () => context.ToggleConsoleWindow(),                                         "toggle debug console");
    context.Keybinds.Subscribe(mod | KeyModifiers.Shift, Keys.Oem2,      () => context.Keybinds.ShowKeybindDialog(),                                  "open keybind window");

    context.AddBar();
    context.AddFocusIndicator();
    var actionMenu = context.AddActionMenu();

    context.DefaultLayouts = () => new ILayoutEngine[] {
        new TallLayoutEngine(),
        new VertLayoutEngine(),
        new FullLayoutEngine()
    };

    context.WorkspaceContainer.CreateWorkspaces("one", "two", "three", "four", "five");

    context.WindowRouter.AddFilter((window) => !window.Title.Contains("Remote Desktop"));
    context.WindowRouter.AddFilter((window) => !window.Title.Contains("Virtual Machine"));
    context.WindowRouter.AddFilter((window) => !window.Title.Contains("Hyper-V"));
    context.WindowRouter.AddFilter((window) => !window.Title.Contains("Windows Sandbox"));
    context.WindowRouter.AddFilter((window) => !window.Title.Contains("Snip"));
    context.WindowRouter.AddFilter((window) => !window.Title.Contains("Sketch"));
};
return doConfig;
