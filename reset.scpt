on run argv
    set positionX to system attribute "bounds1"
    set positionY to system attribute "bounds2"
    set sizeW to system attribute "bounds3"
    set sizeH to system attribute "bounds4"
    tell application "System Events"
        tell first application process whose frontmost is true
            tell first window whose value of attribute "AXMain" is true
                set {position, size} to {{positionX, positionY}, {sizeW, sizeH}}
            end tell
        end tell
    end tell
end run
