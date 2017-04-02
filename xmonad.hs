import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe, safeSpawnProg)
import XMonad.Util.EZConfig
import System.IO
import XMonad.Hooks.SetWMName
import XMonad.Hooks.Script
import qualified XMonad.StackSet as S
import XMonad.Layout.IM
import XMonad.Layout.PerWorkspace
import XMonad.Layout.ResizableTile -- Actions.WindowNavigation is nice too
import XMonad.Layout.NoBorders (smartBorders)
import XMonad.Layout.Grid
import XMonad.Layout.Named
import XMonad.Actions.WindowGo (runOrRaise)
import XMonad.Actions.Volume
import XMonad.Util.Dzen

myManageHook = composeAll
   [ appName =? "outlook.office.com__owa" --> doShift "1:comm"
   , appName =? "bazaarvoice.hipchat.com__chat" --> doShift "1:comm"
   , title =? "Signal" --> doShift "1:comm"
   , appName =? "spotify" --> doShift "="
   , manageDocks
   ]

startupStuff = do
    spawn "/usr/bin/feh --bg-scale ~/Downloads/nh-apluto-mountains-plains-9-17-15.png &"
    spawn "synclient PalmDetect=1 && synclient PalmMinz=255 && synclient HorizTwoFingerScroll=1 && synclient TapButton1=0"
    safeSpawnProg "xscreensaver"
    runOrRaise "outlook-calendar" (title =? "Calendar - John.Roesler@bazaarvoice.com")
    runOrRaise "outlook-mail" (title =? "Mail - John.Roesler@bazaarvoice.com")
    runOrRaise "hipchat" (appName =? "bazaarvoice.hipchat.com__chat")
    runOrRaise "signal" (title =? "Signal")
    runOrRaise "spotify" (appName =? "spotify")

startupStuff2 = setWMName "LG3D"

myGrid = named "myGrid" $ Mirror(GridRatio (3/4))
myLayouts = comm $ normal
  where
    normal = Tall 1 (3/100) (1/2) ||| Full ||| myGrid
    comm = onWorkspace "1:comm" myGrid

centered =
        onCurr (center 150 66)
    >=> font "-*-helvetica-*-r-*-*-64-*-*-*-*-*-*-*"
    >=> addArgs ["-fg", "#80c0ff"]
    >=> addArgs ["-bg", "#000040"]
alert = dzenConfig centered . show . round

muted :: Bool -> String
muted True = "off"
muted False = "on"

alertB = dzenConfig centered . muted

main = do
    xmproc <- spawnPipe "xmobar"

    xmonad $ defaultConfig
        { workspaces = ["1:comm","2","3","4","5","6","7","8","9","0","-","="]
        , manageHook = myManageHook <+> manageHook defaultConfig 
        , layoutHook = avoidStruts . smartBorders $ (myLayouts)
        , startupHook = startupStuff <+> startupStuff2
        , logHook = dynamicLogWithPP $ xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppTitle = xmobarColor "green" "" . shorten 100
                        , ppOrder = reverse
                        }
        , modMask = mod4Mask     -- Rebind Mod to the Windows/Apple key
        } 
        `additionalKeys`
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
        `additionalKeysP`
        [ ("<XF86AudioRaiseVolume>", raiseVolume 2 >>= alert)
        , ("<XF86AudioLowerVolume>", lowerVolume 2 >>= alert)
        , ("<XF86AudioMute>", toggleMuteChannels ["Master", "Headphone", "Speaker", "Bass Speaker"] >>= alertB)
        ]
