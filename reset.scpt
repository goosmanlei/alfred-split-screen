-- 编写applescript脚本，实现设置当前前台窗口位置的功能：
-- 1) 读取环境变量bounds1, bounds2, bounds3, bound4，分别代表要设置位置的x、y坐标和宽度、高度
-- 2) 首先读取当前前台应用的AXEnhancedUserInterface属性值，将其保存在一个变量中，关闭当前前台应用的AXEnhancedUserInterface
-- 3）按照读取到的环境变量值，调用set {postion, size}设置当前前台窗口的新位置
-- 4) 使用第2步保存的AXEnhancedUserInterface属性值，将其恢复到当前前台应用
-- 所编写的程序遵循下列要求：
-- 1）采用简洁的英文注释
-- 2）使用清晰的英文日志记录前台应用名称、修改前的AXEnhancedUserInterface属性值，要修改的位置坐标和宽高
-- 3）代码简洁清晰
on run
    -- Read environment variables
    set posX to system attribute "bounds1"
    set posY to system attribute "bounds2"
    set winW to system attribute "bounds3"
    set winH to system attribute "bounds4"

    tell application "System Events"
        -- Get frontmost process
        set frontProc to first process whose frontmost is true
        set appName to name of frontProc

        -- Save AXEnhancedUserInterface value
        set oldAX to value of attribute "AXEnhancedUserInterface" of frontProc

        -- Disable AXEnhancedUserInterface
        set value of attribute "AXEnhancedUserInterface" of frontProc to false

        -- Get first window and set position and size
        tell first application process whose frontmost is true
            tell first window whose value of attribute "AXMain" is true
                set {position, size} to {{posX, posY}, {winW, winH}}
            end tell
        end tell

        -- Restore AXEnhancedUserInterface
        set value of attribute "AXEnhancedUserInterface" of frontProc to oldAX
        log "App = " & appName & "; OriginalAXEnhancedUserInterface = " & oldAX & "; {{x, y}, {width, height}} = {{" & posX & ", " & posY & "}, {" & winW & ", " & winH & "}}"
    end tell
end run
