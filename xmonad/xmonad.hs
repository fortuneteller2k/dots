import XMonad

import XMonad.Actions.CycleWS

import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.InsertPosition
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.Place
import XMonad.Hooks.SetWMName

import XMonad.Layout.Spacing
import XMonad.Layout.Tabbed
import XMonad.Layout.ToggleLayouts

import XMonad.Prompt
import XMonad.Prompt.FuzzyMatch
import XMonad.Prompt.Shell

import XMonad.Util.EZConfig
import XMonad.Util.SpawnOnce

import Data.Char
import Data.Monoid
import System.Exit

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

fontFamily = "xft:FantasqueSansMono Nerd Font:bold:size=10:antialias=true:hinting=true"

keybindings =
  [ ("M-<Return>",                 spawn "alacritty")
  , ("M-d",                        shellPrompt promptConfig)
  , ("M-q",                        kill)
  , ("M-w",                        spawn "emacsclient -nc")
  , ("M-<F2>",                     spawn "brave")
  , ("M-e",                        sendMessage ToggleLayout)
  , ("M-<Tab>",                    sendMessage NextLayout)
  , ("M-n",                        refresh)
  , ("M-s",                        windows W.swapMaster)
  , ("M--",                        sendMessage Shrink)
  , ("M-=",                        sendMessage Expand)
  , ("M-t",                        withFocused toggleFloat)
  , ("M-,",                        sendMessage (IncMasterN 1))
  , ("M-.",                        sendMessage (IncMasterN (-1)))
  , ("M-<Left>",                   prevWS)
  , ("M-<Right>",                  nextWS)
  , ("<Print>",                    spawn "/home/fortuneteller2k/.config/scripts/screenshot.sh wind")
  , ("M-<Print>",                  spawn "/home/fortuneteller2k/.config/scripts/screenshot.sh area")
  , ("M-S-s",                      spawn "/home/fortuneteller2k/.config/scripts/screenshot.sh full")
  , ("M-S-q",                      io (exitWith ExitSuccess))
  , ("M-S-<Delete>",               spawn "slock")
  , ("M-S-c",                      withFocused $ \w -> spawn ("xkill -id " ++ show w))
  , ("M-S-r",                      spawn $ "xmonad --recompile && xmonad --restart")
  , ("M-S-<Left>",                 shiftToPrev >> prevWS)
  , ("M-S-<Right>",                shiftToNext >> nextWS)
  , ("C-<Left>",                   windows W.focusUp)
  , ("C-<Right>",                  windows W.focusDown)
  , ("<XF86AudioMute>",            spawn "/home/fortuneteller2k/.config/scripts/volume.sh mute")
  , ("<XF86AudioRaiseVolume>",     spawn "/home/fortuneteller2k/.config/scripts/volume.sh up")
  , ("<XF86AudioLowerVolume>",     spawn "/home/fortuneteller2k/.config/scripts/volume.sh down")
  , ("<XF86MonBrightnessUp>",      spawn "xbacklight -inc 10")
  , ("<XF86MonBrightnessDown>",    spawn "xbacklight -dec 10")
  ]
  where
    toggleFloat w = windows (\s -> if M.member w (W.floating s)
                              then W.sink w s
                              else (W.float w (W.RationalRect 0.15 0.15 0.7 0.7) s))

promptConfig = def
  { font                = fontFamily
  , bgColor             = "#16161c"
  , fgColor             = "#fdf0ed"
  , bgHLight            = "#fab795"
  , fgHLight            = "#16161c"
  , borderColor         = "#fab795"
  , promptBorderWidth   = 0
  , position            = Top
  , height              = 20
  , historySize         = 256
  , historyFilter       = id
  , showCompletionOnTab = False
  , searchPredicate     = fuzzyMatch
  , sorter              = fuzzySort
  , defaultPrompter     = id $ map toLower
  , alwaysHighlight     = True
  , maxComplRows        = Just 5
  }

layouts = avoidStruts
          $ spacingRaw False (Border 6 6 6 6) True (Border 2 2 2 2) True
          $ toggleLayouts Full tiled ||| tabbed shrinkText tabTheme
  where
     tiled = Tall nmaster delta ratio
     nmaster = 1
     ratio = toRational (2/(1+sqrt(5)::Double)) -- inverse golden ratio
     delta = 3/100

tabTheme = def
  { fontName            = fontFamily
  , activeColor         = "#fab795"
  , inactiveColor       = "#16161c"
  , urgentColor         = "#e95678"
  , activeBorderColor   = "#fab795"
  , inactiveBorderColor = "#16161c"
  , urgentBorderColor   = "#e95678"
  , activeTextColor     = "#16161c"
  , inactiveTextColor   = "#fdf0ed"
  , urgentTextColor     = "#16161c"
  }

windowRules = placeHook (smart (0.5, 0.5))
  <+> composeAll
  [ className =? "Gimp"                                   --> doFloat
  , (className =? "Ripcord" <&&> title =? "Preferences")  --> doFloat
  , className =? "Xmessage"                               --> doFloat
  , className =? "Lxappearance"                           --> doFloat
  , className =? "Xephyr"                                 --> doFloat
  , resource  =? "desktop_window"                         --> doIgnore
  , resource  =? "kdesktop"                               --> doIgnore
  , isDialog                                              --> doF W.swapUp ]
  <+> insertPosition End Newer -- same effect as attachaside patch in dwm
  <+> manageDocks
  <+> manageHook defaultConfig

autostart = do
  spawnOnce "xsetroot -cursor_name left_ptr &"
  spawnOnce "systemctl --user restart polybar &"
  spawnOnce "nitrogen --restore &"
  spawnOnce "xss-lock slock &"
  spawnOnce "xidlehook --not-when-fullscreen --not-when-audio --timer 600 slock '' &"
  setWMName "LG3D"

cfg = docks $ ewmh $ def
  { focusFollowsMouse  = True
  , borderWidth        = 2
  , modMask            = mod1Mask
  , workspaces         = ["A","B","C","D","E","F","G","H","I"]
  , normalBorderColor  = "#16161c"
  , focusedBorderColor = "#fab795"
  , layoutHook         = layouts
  , manageHook         = windowRules
  , logHook            = fadeInactiveLogHook 0.95
  , handleEventHook    = fullscreenEventHook <+> ewmhDesktopsEventHook
  , startupHook        = autostart
  } `additionalKeysP` keybindings

main = xmonad cfg -- "that was easy, xmonad rocks!"
