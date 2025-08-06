on resizeApp(positionX, positionY, sizeX, sizeY)
  log "input args: position = {" & positionX & ", " & positionY & "} size = {" & sizeX & ", " & sizeY & "}"
  tell application "System Events"
    tell first application process whose frontmost is true
        tell first window whose value of attribute "AXMain" is true
            if positionX is equal to -999999 or positionY is equal to -999999 then
                set size to {sizeX, sizeY}
            else if sizeX is equal to -999999 or sizeY is equal to -999999 then
                set position to {positionX, positionY}
            else
                set {position, size} to {{positionX, positionY}, {sizeX, sizeY}}
            end if
        end tell
    end tell
    tell first application process whose frontmost is true
        set afterPosition to position of first window whose value of attribute "AXMain" is true
        set afterSize to size of first window whose value of attribute "AXMain" is true
        if positionX is equal to -999999 or positionY is equal to -999999 then
            log "resize to: {" & item 1 of afterSize & ", " & item 2 of afterSize & "}"
        else if sizeX is equal to -999999 or sizeY is equal to -999999 then
            log "move to: {" & item 1 of afterPosition & ", " & item 2 of afterPosition & "}"
        else
            log "move to: {" & item 1 of afterPosition & ", " & item 2 of afterPosition & "}"
            log "resize to: {" & item 1 of afterSize & ", " & item 2 of afterSize & "}"
        end if
    end tell
  end tell
end resizeApp

on run args
    -- 打印命令行参数
    set argsString to "Args: "
    repeat with theArg in args
        set argsString to argsString & theArg & " "
    end repeat
    log argsString

    -- 处理比例数据
    set command to item 1 of args as string
    set whichScreen to item 2 of args as string
    set positionType to item 3 of args as string
    if command as string is equal to "custom" then
        set positionType to ""
        set percentX to item 3 of args as real
        set percentY to item 4 of args as real
        set percentW to item 5 of args as real
        set percentH to item 6 of args as real
    else if command as string is equal to "resize" then
        set positionType to ""
        set percentX to -999999
        set percentY to -999999
        set percentW to item 3 of args as real
        set percentH to item 4 of args as real
    else if command as string is equal to "move" then
        set positionType to ""
        set percentX to item 3 of args as real
        set percentY to item 4 of args as real
        set percentW to -999999
        set percentH to -999999
    end if

    -- 获取屏幕边界坐标
    tell application "Finder" to set screenBound to get bounds of window of desktop
    set screenBoundX to item 1 of screenBound
    set screenBoundY to item 2 of screenBound
    set screenBoundW to item 3 of screenBound
    set screenBoundH to item 4 of screenBound

    -- 获取屏幕大小
    set screenResolutionInfo to paragraphs of (do shell script "displayplacer list | awk -f split-screen.awk")
    set mainScreenX to (item 1 of screenResolutionInfo) as integer
    set mainScreenY to (item 2 of screenResolutionInfo) as integer
    set mainScreenW to (item 3 of screenResolutionInfo) as integer
    set mainScreenH to (item 4 of screenResolutionInfo) as integer
    set dualScreenX to (item 5 of screenResolutionInfo) as integer
    set dualScreenY to (item 6 of screenResolutionInfo) as integer
    set dualScreenW to (item 7 of screenResolutionInfo) as integer
    set dualScreenH to (item 8 of screenResolutionInfo) as integer

    log "---- bounds position & size"
    log "globalScreenBound: " & screenBoundX & ", " & screenBoundY & ", " & screenBoundW & ", " & screenBoundH
    log "mainScreenBound: " & mainScreenX & ", " & mainScreenY & ", " & mainScreenW & ", " & mainScreenH
    log "dualScreenBound: " & dualScreenX & ", " & dualScreenY & ", " & dualScreenW & ", " & dualScreenH

    -- height of menubar
    set heightOfMenubar to 25
    set mainScreenY to mainScreenY + heightOfMenubar
    set dualScreenY to dualScreenY + heightOfMenubar
    set mainScreenH to mainScreenH - heightOfMenubar
    set dualScreenH to dualScreenH - heightOfMenubar

    log "---- actual position & size"
    log "ActualMainBound: " & mainScreenX & ", " & mainScreenY & ", " & mainScreenW & ", " & mainScreenH
    log "ActualDualBound: " & dualScreenX & ", " & dualScreenY & ", " & dualScreenW & ", " & dualScreenH

    -- 计算相对比例
    if positionType as string is equal to "left" then
        set {percentX, percentY, percentW, percentH} to {0.00, 0.00, 49.00, 100.00}
    else if positionType as string is equal to "right" then
        set {percentX, percentY, percentW, percentH} to {51.00, 0.00, 49.00, 100.00}
    else if positionType as string is equal to "top" then
        set {percentX, percentY, percentW, percentH} to {15.00, 0.00, 85.00, 49.00}
    else if positionType as string is equal to "bottom" then
        set {percentX, percentY, percentW, percentH} to {15.00, 51.00, 85.00, 49.00}
    else if positionType as string is equal to "full" then
        set {percentX, percentY, percentW, percentH} to {0.00, 0.00, 100.00, 100.00}
    else if positionType as string is equal to "large" then
        set {percentX, percentY, percentW, percentH} to {10.00, 10.00, 80.00, 80.00}
    else if positionType as string is equal to "large.left" then
        set {percentX, percentY, percentW, percentH} to {0.00, 10.00, 80.00, 80.00}
    else if positionType as string is equal to "large.right" then
        set {percentX, percentY, percentW, percentH} to {20.00, 10.00, 80.00, 80.00}
    else if positionType as string is equal to "medium" then
        set {percentX, percentY, percentW, percentH} to {15.00, 15.00, 70.00, 70.00}
    else if positionType as string is equal to "medium.left" then
        set {percentX, percentY, percentW, percentH} to {0.00, 15.00, 70.00, 70.00}
    else if positionType as string is equal to "medium.right" then
        set {percentX, percentY, percentW, percentH} to {30.00, 15.00, 70.00, 70.00}
    else if positionType as string is equal to "small" then
        set {percentX, percentY, percentW, percentH} to {20.00, 20.00, 60.00, 60.00}
    else if positionType as string is equal to "small.left" then
        set {percentX, percentY, percentW, percentH} to {0.00, 20.00, 60.00, 60.00}
    else if positionType as string is equal to "small.right" then
        set {percentX, percentY, percentW, percentH} to {40.00, 20.00, 60.00, 60.00}
    else if positionType as string is equal to "tiny" then
        set {percentX, percentY, percentW, percentH} to {25.00, 25.00, 50.00, 50.00}
    else if positionType as string is equal to "tiny.left" then
        set {percentX, percentY, percentW, percentH} to {0.00, 25.00, 50.00, 50.00}
    else if positionType as string is equal to "tiny.right" then
        set {percentX, percentY, percentW, percentH} to {50.00, 25.00, 50.00, 50.00}
    else if positionType as string is equal to "1/4" then
        set {percentX, percentY, percentW, percentH} to {0.00, 0.00, 49.00, 49.00}
    else if positionType as string is equal to "2/4" then
        set {percentX, percentY, percentW, percentH} to {51.00, 0.00, 49.00, 49.00}
    else if positionType as string is equal to "3/4" then
        set {percentX, percentY, percentW, percentH} to {0.00, 51.00, 49.00, 49.00}
    else if positionType as string is equal to "4/4" then
        set {percentX, percentY, percentW, percentH} to {51.00, 51.00, 49.00, 49.00}
    else if positionType as string is equal to "3.1" then
        set {percentX, percentY, percentW, percentH} to {0.00, 0.00, 90.00, 90.00}
    else if positionType as string is equal to "3.2" then
        set {percentX, percentY, percentW, percentH} to {5.00, 5.00, 90.00, 90.00}
    else if positionType as string is equal to "3.3" then
        set {percentX, percentY, percentW, percentH} to {10.00, 10.00, 90.00, 90.00}
    else if positionType as string is equal to "4.1" then
        set {percentX, percentY, percentW, percentH} to {0.00, 0.00, 85.00, 85.00}
    else if positionType as string is equal to "4.2" then
        set {percentX, percentY, percentW, percentH} to {5.00, 5.00, 85.00, 85.00}
    else if positionType as string is equal to "4.3" then
        set {percentX, percentY, percentW, percentH} to {15.00, 15.00, 85.00, 85.00}
    else if positionType as string is equal to "4.4" then
        set {percentX, percentY, percentW, percentH} to {20.00, 20.00, 85.00, 85.00}
    else if positionType as string is equal to "5.1" then
        set {percentX, percentY, percentW, percentH} to {0.00, 0.00, 80.00, 80.00}
    else if positionType as string is equal to "5.2" then
        set {percentX, percentY, percentW, percentH} to {5.00, 5.00, 80.00, 80.00}
    else if positionType as string is equal to "5.3" then
        set {percentX, percentY, percentW, percentH} to {10.00, 10.00, 80.00, 80.00}
    else if positionType as string is equal to "5.4" then
        set {percentX, percentY, percentW, percentH} to {15.00, 15.00, 80.00, 80.00}
    else if positionType as string is equal to "5.5" then
        set {percentX, percentY, percentW, percentH} to {20.00, 20.00, 80.00, 80.00}
    else if positionType as string is equal to "7.1" then
        set {percentX, percentY, percentW, percentH} to {0.00, 0.00, 70.00, 70.00}
    else if positionType as string is equal to "7.2" then
        set {percentX, percentY, percentW, percentH} to {5.00, 5.00, 70.00, 70.00}
    else if positionType as string is equal to "7.3" then
        set {percentX, percentY, percentW, percentH} to {10.00, 10.00, 70.00, 70.00}
    else if positionType as string is equal to "7.4" then
        set {percentX, percentY, percentW, percentH} to {15.00, 15.00, 70.00, 70.00}
    else if positionType as string is equal to "7.5" then
        set {percentX, percentY, percentW, percentH} to {20.00, 20.00, 70.00, 70.00}
    else if positionType as string is equal to "7.6" then
        set {percentX, percentY, percentW, percentH} to {25.00, 25.00, 70.00, 70.00}
    else if positionType as string is equal to "7.7" then
        set {percentX, percentY, percentW, percentH} to {30.00, 30.00, 70.00, 70.00}
    else if positionType as string is equal to "huge" then
        set {percentX, percentY, percentW, percentH} to {5.00, 5.00, 90.00, 90.00}
    else if positionType as string is equal to "mini" then
        set {percentX, percentY, percentW, percentH} to {32.50, 32.50, 35.00, 35.00}
    else if positionType as string is equal to "wechat" then
        set {percentX, percentY, percentW, percentH} to {0.00, 0.00, 40.00, 50.00}
    else if positionType as string is equal to "1/6" then
        set {percentX, percentY, percentW, percentH} to {0.00, 0.00, 49.00, 32.00}
    else if positionType as string is equal to "2/6" then
        set {percentX, percentY, percentW, percentH} to {51.00, 0.00, 49.00, 32.00}
    else if positionType as string is equal to "3/6" then
        set {percentX, percentY, percentW, percentH} to {0.00, 34.00, 49.00, 32.00}
    else if positionType as string is equal to "4/6" then
        set {percentX, percentY, percentW, percentH} to {51.00, 34.00, 49.00, 32.00}
    else if positionType as string is equal to "5/6" then
        set {percentX, percentY, percentW, percentH} to {0.00, 68.00, 49.00, 32.00}
    else if positionType as string is equal to "6/6" then
        set {percentX, percentY, percentW, percentH} to {51.00, 68.00, 49.00, 32.00}
    else if positionType as string is equal to "douyin" then
        set {percentX, percentY, percentW, percentH} to {0.00, 0.00, 50.00, 50.00}
    else if positionType as string is equal to "win" then
        set {percentX, percentY, percentW, percentH} to {10.00, 10.00, 90.00, 90.00}
    else if positionType as string is equal to "cal" then
        set {percentX, percentY, percentW, percentH} to {49.00, 20.00, 51.00, 80.00}
    else if positionType as string is equal to "yuyin" then
        set {percentX, percentY, percentW, percentH} to {65.00, 0.00, 35.00, 40.00}
    else if positionType as string is equal to "h3.1" then
        set {percentX, percentY, percentW, percentH} to {0.00, 0.00, 32.00, 100.00}
    else if positionType as string is equal to "h3.2" then
        set {percentX, percentY, percentW, percentH} to {34.00, 0.00, 32.00, 100.00}
    else if positionType as string is equal to "h3.3" then
        set {percentX, percentY, percentW, percentH} to {68.00, 0.00, 32.00, 100.00}
    else if positionType as string is equal to "ominifocus" then
        set {percentX, percentY, percentW, percentH} to {0.00, 80.00, 30.00, 20.00}
    else if positionType as string is equal to "meeting" then
        set {percentX, percentY, percentW, percentH} to {2.00, 2.00, 96.00, 96.00}
    else if positionType as string is equal to "perf.left" then
        set {percentX, percentY, percentW, percentH} to {0.00, 0.00, 50.00, 40.00}
    else if positionType as string is equal to "perf.right" then
        set {percentX, percentY, percentW, percentH} to {50.00, 0.00, 50.00, 40.00}
    else if positionType as string is equal to "perf.bottom" then
        set {percentX, percentY, percentW, percentH} to {0.00, 40.00, 100.00, 60.00}
    else if positionType as string is equal to "perf.top" then
        set {percentX, percentY, percentW, percentH} to {0.00, 0.00, 100.00, 40.00}
    end if

    if whichScreen as string is equal to "current" then
        tell application "System Events"
            tell first application process whose frontmost is true
                set currPosition to position of first window whose value of attribute "AXMain" is true
                log "CurrentPosition: " & currPosition
                if item 1 of currPosition <= mainScreenW then
                    set whichScreen to "main"
                else
                    set whichScreen to "dual"
                end if
            end tell
        end tell
    else if whichScreen as string is equal to "other" then
        tell application "System Events"
            tell first application process whose frontmost is true
                set currPosition to position of first window whose value of attribute "AXMain" is true
                log "CurrentPosition: " & currPosition
                if item 1 of currPosition < mainScreenW then
                    set whichScreen to "dual"
                else
                    set whichScreen to "main"
                end if
            end tell
        end tell
    end if

    -- 单位转换
    if percentX > 1 then
        set percentX to percentX / 100
    end if
    if percentY > 1 then
        set percentY to percentY / 100
    end if
    if percentW > 1 then
        set percentW to percentW / 100
    end if
    if percentH > 1 then
        set percentH to percentH / 100
    end if

    -- 计算实际位置大小
    if whichScreen as string is equal to "dual" then
        if percentX is equal to -999999 then
            set newSizeX to -999999
        else
            set newSizeX to dualScreenW * percentX + dualScreenX
        end if
        if percentY is equal to -999999 then
            set newSizeY to -999999
        else
            set newSizeY to dualScreenH * percentY + dualScreenY
        end if
        if percentW is equal to -999999 then
            set newSizeW to -999999
        else
            set newSizeW to dualScreenW * percentW
        end if
        if percentH is equal to -999999 then
            set newSizeH to -999999
        else
            set newSizeH to dualScreenH * percentH
        end if
    else
        if percentX is equal to -999999 then
            set newSizeX to -999999
        else
            set newSizeX to mainScreenW * percentX + mainScreenX
        end if
        if percentY is equal to -999999 then
            set newSizeY to -999999
        else
            set newSizeY to mainScreenH * percentY + mainScreenY
        end if
        if percentW is equal to -999999 then
            set newSizeW to -999999
        else
            set newSizeW to mainScreenW * percentW
        end if
        if percentH is equal to -999999 then
            set newSizeH to -999999
        else
            set newSizeH to mainScreenH * percentH
        end if
    end if

    log "---- action"
    log "command = " & command & "; whichScreen = " & whichScreen & "; positionType = " & positionType
    resizeApp(newSizeX as integer, newSizeY as integer, newSizeW as integer, newSizeH as integer)
end run
