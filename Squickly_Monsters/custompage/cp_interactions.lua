local composer = require("composer")
require("monsterList")

-- -------------------------------------------------------------------------------
-- Local variables go HERE
local resizer = display.contentHeight/320

local evolveIcon;
local name_display;
local HW_display;
local disc_display;

local DisplayName;
local Height;
local Weight;
local Description;
local levelToEvolve;
local nextEvolution;

local evolveIsShow = false;
local isTouchAble;
local canEvolve;

-- -------------------------------------------------------------------------------

function isTouchAbleFunc()
    return isTouchAble
end

function enableEvolveTouch()
    isTouchAble = true
end

function disableEvolveTouch()
    isTouchAble = false
end

function isEvolable()
    return canEvolve
end

function enableEvolution()
    canEvolve = true
end

function disableEvolution()
    canEvolve = false
end

function updateAllMonsterDescriptions(monsterName)
    local displayTable = getMonsterDescription(monsterName)
    DisplayName, Height, Weight, Description, levelToEvolve, nextEvolution = displayTable[1],displayTable[2],displayTable[3],displayTable[4],displayTable[5],displayTable[6]
    evolveIcon.image = updateEvolveIcon(levelToEvolve, nextEvolution)
    name_display.text = "Name: "..DisplayName
    HW_display.text = "H: "..Height.."cm, W: "..Weight.."kg"
    disc_display.text = Description

    isTouchAble = true

    if nextEvolution ~= nil then
        if getMonsterLevel() >= levelToEvolve then
            return 1
        end
    end
    return 0
end

function displayAllMonsterDescriptions(monsterName)
    local displayTable = getMonsterDescription(monsterName)
    DisplayName, Height, Weight, Description, levelToEvolve, nextEvolution = displayTable[1],displayTable[2],displayTable[3],displayTable[4],displayTable[5],displayTable[6]
    evolveIcon = displayEvolveIcon(levelToEvolve, nextEvolution)
    name_display = setUpText(DisplayName, 20, display.contentCenterX-100*resizer, display.contentCenterY-115*resizer, 1)
    HW_display = setUpText("H: "..Height.."cm, W: "..Weight.."kg", 20, display.contentCenterX-100*resizer, display.contentCenterY-15*resizer, 1)
    disc_display = setUpText(Description,  20, display.contentCenterX-100*resizer, display.contentCenterY+85*resizer, 1)
    return evolveIcon, name_display, HW_display, disc_display
end

-- -------------------------------------------------------------------------------
-- Hide / Show Display Stuff

function setUpIcon(img, scale, x, y, alpha)
    icon = display.newImage(img, x, y)
    icon:scale(scale, scale)
    icon.alpha = alpha
    return icon
end

function setUpText(text, size, x, y, alpha)
    displayText = display.newText(text, x, y, 300*resizer, 0, native.systemFontBold, size*resizer, "left")
    displayText:setFillColor( 1.0, 1.0, 1.0 )
    displayText.alpha = alpha
    return displayText
end

function updateEvolveIcon(levelToEvolve, nextEvolution)
    if nextEvolution ~= nil then
        if getMonsterLevel() >= levelToEvolve then
            local iconFile
            if string.starts(getMonsterName(), "egg") then
                return "img/icons/UIIcons/hatchEggIcon.png"
            end
        end
    end
    return "img/icons/UIIcons/evolveNow.png"
end

function displayEvolveIcon(levelToEvolve, nextEvolution)
    if nextEvolution ~= nil then
        if getMonsterLevel() >= levelToEvolve then
            if string.starts(getMonsterName(), "egg") then
                return setUpIcon("img/icons/UIIcons/hatchEggIcon.png", 0.7*resizer, display.contentCenterX+200*resizer, display.contentCenterY-100*resizer, 1)
            end
        end
    end
    return setUpIcon("img/icons/UIIcons/evolveNow.png", 0.7*resizer, display.contentCenterX+200*resizer, display.contentCenterY-100*resizer, 1)
end
-- -------------------------------------------------------------------------------
-- Set reaction when press button

function evolveButtonClicked(event)
    if isTouchAble then
        if event.phase == "ended" then
            if evolveIsShow then
                composer.gotoScene(composer.getSceneName("current"))
                evolveIsShow = false
            else
                composer.showOverlay("custompage.cp_evolve")
                evolveIsShow = true
            end
        end
    end
end

-- -------------------------------------------------------------------------------
-- Add All Event Listeners Here

function addListeners()
    if evolveIcon~=nil then
        evolveIcon:addEventListener("touch", evolveButtonClicked)
    end
end
