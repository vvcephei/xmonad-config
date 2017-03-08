import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig
import System.IO
import XMonad.Hooks.SetWMName
import XMonad.Hooks.Script
import qualified XMonad.StackSet as S

myManageHook = composeAll
   [ appName =? "outlook.office.com__owa" --> doShift "1:comm"
   --, className =? "XDvi"      --> doShift "7:dvi"
   --, className =? "Xmessage"  --> doFloat
   , manageDocks
   ]

startupStuff = do
    spawn "/usr/bin/feh --bg-scale ~/Downloads/nh-apluto-mountains-plains-9-17-15.png &"
    spawn "synclient PalmDetect=1 && synclient PalmMinz=255 && synclient HorizTwoFingerScroll=1 && synclient TapButton1=0"
    spawn "xscreensaver &"

startupStuff2 = setWMName "LG3D"

main = do
    xmproc <- spawnPipe "xmobar"

    xmonad $ defaultConfig
        { workspaces = ["1:comm","2","3","4","5","6","7","8","9","0","-","="]
        , manageHook = myManageHook <+> manageHook defaultConfig 
        , layoutHook = avoidStruts(layoutHook defaultConfig)
        , startupHook = startupStuff <+> startupStuff2
        , logHook = dynamicLogWithPP $ xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        -- , ppTitle = \s -> ""
                        , ppTitle = xmobarColor "green" "" . shorten 100
                        , ppOrder = reverse
                        }
        , modMask = mod4Mask     -- Rebind Mod to the Windows key
        } `additionalKeys`
          [ ((mod4Mask .|. shiftMask, xK_z), spawn "xscreensaver-command -lock")
          , ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s")
          , ((0, xK_Print), spawn "scrot")
          , ((mod4Mask, xK_0), (windows $ S.greedyView "0"))
          , ((mod4Mask .|. shiftMask, xK_0), (windows $ S.shift "0"))
          , ((mod4Mask, xK_minus), (windows $ S.greedyView "-"))
          , ((mod4Mask .|. shiftMask, xK_minus), (windows $ S.shift "-"))
          , ((mod4Mask, xK_equal), (windows $ S.greedyView "="))
          , ((mod4Mask .|. shiftMask, xK_equal), (windows $ S.shift "="))
          ]