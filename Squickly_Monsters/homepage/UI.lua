local widget = require( "widget" )
require("loadgame")
-------------------------------------------------------------------------------
-- Local variables go HERE

local feedIcon;
local sleepIcon;
local wakeupIcon;
local cleanIcon;
local playIcon;
local mostRecentFoodIcon1;
local mostRecentFoodIcon2;
local moreFoodIcon;
local shopIcon;
local mostRecentPlayIcon1;
local mostRecentPlayIcon2;
local morePlayIcon;

local maxNeedsLevels; -- 2880 mins = 2days*24hrs*60mins 
local needsLevels;
local needsBars;

-- -------------------------------------------------------------------------------
-- Set up needs bar

function setUpNeedsBar(fileName, left)
    local options = {
        width = 192,
        height = 64,
        numFrames = 2,
        sheetContentWidth = 384,
        sheetContentHeight = 64
    }
    local progressSheet = graphics.newImageSheet( fileName, options )

    return widget.newProgressView(
        {
            sheet = progressSheet,
            fillOuterMiddleFrame = 1,
            fillOuterWidth = 0,
            fillOuterHeight = display.contentHeight/25,
            fillInnerMiddleFrame = 2,
            fillWidth = 0,
            fillHeight = display.contentHeight/25,
            left = left,
            top = 10,
            width = display.contentWidth/8,
            isAnimated = true
        }
    )
end

function setNeedsLevel(need, lvl)
    needsLevels[need] = lvl
    needsBars[need]:setProgress(lvl/maxNeedsLevels[need])
end

function setupAllNeedsBars()
    local startX = display.contentWidth/10
    local spacing = display.contentWidth/6

    -- TODO: Update Bar files
    needsBars = {}
    needsBars.hunger = setUpNeedsBar("img/others/HappinessBar.png", startX)
    needsBars.happiness = setUpNeedsBar("img/others/HappinessBar.png", startX + spacing)
    needsBars.hygiene = setUpNeedsBar("img/others/HygieneBar.png", startX + spacing*2)
    needsBars.energy = setUpNeedsBar("img/others/EnergyBar.png", startX + spacing*3)
    needsBars.exp = setUpNeedsBar("img/others/EnergyBar.png", startX + spacing*4)

    -- Set All Needs Level
    needsLevels, maxNeedsLevels = getSavedLevels()
    print(needsLevels)

    setNeedsLevel("hunger", needsLevels.hunger)
    setNeedsLevel("happiness", needsLevels.happiness)
    setNeedsLevel("hygiene", needsLevels.hygiene)
    setNeedsLevel("energy", needsLevels.energy)
    setNeedsLevel("exp", needsLevels.exp)
end
-- -------------------------------------------------------------------------------
-- Setup All Icons Here

function setUpAllIcons()
    feedIcon = setUpIcon("img/others/feedIcon.png", 0.75)
    sleepIcon = setUpIcon("img/others/sleepIcon.png", 0.5)
    wakeupIcon = setUpIcon("img/others/wakeupIcon.png", 0.7)
    cleanIcon = setUpIcon("img/others/cleanIcon.png", 0.5)
    playIcon = setUpIcon("img/others/playIcon.png", 0.75)
    mostRecentFoodIcon1 = setUpIcon("img/others/cupcakeIcon.png", 0.75)
    mostRecentFoodIcon2 = setUpIcon("img/others/milkIcon.png", 0.5)
    moreFoodIcon = setUpIcon("img/others/optionsIcon.png", 0.75)
    shopIcon = setUpIcon("img/others/shopIcon.png", 0.5)
    mostRecentPlayIcon1 = setUpIcon("img/others/legomanIcon.png", 0.75)
    mostRecentPlayIcon2 = setUpIcon("img/others/footballIcon.png", 0.75)
    morePlayIcon = setUpIcon("img/others/optionsIcon.png", 0.75)
end

function setUpIcon(img, scale)
    icon = display.newImage(img, getMonster().x, getMonster().y)
    icon:scale(scale, scale)
    icon.alpha = 0
    return icon
end

-- -------------------------------------------------------------------------------
-- Needs Rate Event Handler

local function needRateEventHandler( event )
    local params = event.source.params

    changeNeedsLevel(params.need, params.change)
end

-- ------------------------------------------------
-- Adds forever increasing/decreasing needs level

function setRateLongTerm(need, rate, amount) 
    -- increasing is boolean val which shows that rate should increase if true
    -- rate is frequency of the change, amount is the magnitude of change
    -- rate 1000 = 1sec, -1 is infinite interations
    local tmp = timer.performWithDelay(rate, needRateEventHandler, -1)
    tmp.params = {need=need, change=amount}
    if needBar == energyBar then
        return tmp
    end
end
-- ------------------------------------------------
-- Changing by a certain amount (Still needs to have more calculations later)

function changeNeedsLevel(need, change)
    setNeedsLevel(need, needsLevels[need] + change)
end

-- -------------------------------------------------------------------------------
-- Get needs level

function getCurrentNeedsLevels()
    return needsLevels
end

function getMaxNeedsLevels()
    return maxNeedsLevels
end

function getHungerLevel()
    return needsLevels.hunger
end

function getHappinessLevel()
    return needsLevels.happiness
end

function getHygieneLevel()
    return needsLevels.hygiene
end

function getEnergyLevel()
    return needsLevels.energy
end

function getExpLevel()
    return needsLevels.exp
end

-- -------------------------------------------------------------------------------
-- Get needs bar

function getHungerBar()
    return needsBars.hunger
end

function getHappinessBar()
    return needsBars.happiness
end

function getHygieneBar()
    return needsBars.hygiene
end

function getEnergyBar()
    return needsBars.energy
end

function getExpBar()
    return needsBars.exp
end

-- -------------------------------------------------------------------------------
-- Get icons

function getFeedIcon()
    return feedIcon
end

function getSleepIcon()
    return sleepIcon
end

function getWakeupIcon()
    return wakeupIcon
end

function getCleanIcon()
    return cleanIcon
end

function getPlayIcon()
    return playIcon
end

function getMostRecentFoodIcon1()
    return mostRecentFoodIcon1
end

function getMostRecentFoodIcon2()
    return mostRecentFoodIcon2
end

function getMoreFoodIcon()
    return moreFoodIcon
end

function getShopIcon()
    return shopIcon
end

function getMostRecentPlayIcon1()
    return mostRecentPlayIcon1
end

function getMostRecentPlayIcon2()
    return mostRecentPlayIcon2
end

function getMorePlayIcon()
    return morePlayIcon
end