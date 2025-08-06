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
----TPL_REPLACE_WITH_CONFIG

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
