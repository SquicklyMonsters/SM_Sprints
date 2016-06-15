local widget = require( "widget" )
local composer = require( "composer" )
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
local inventoryIcon;

local needsLevels;
local needsBars;
local maxNeedsLevels; -- 2880 mins = 2days*24hrs*60mins

local thoughtClouds;
local checkHungerID;
local checkTiredID;

local hungerRate = -10;
local energyRate = -10;
-- local hungerThoughtCloud;
-- local energyThoughtCloud;
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
            -- Empty bar frame
            fillOuterMiddleFrame = 1,
            fillOuterWidth = 0,
            fillOuterHeight = display.contentHeight/25,
            -- Full bar frame
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
    -- Prevent lvl going over 100% and below 0%
    if lvl > maxNeedsLevels[need] then
        lvl = maxNeedsLevels[need]
    elseif lvl < 0 then
        lvl = 0
    end
    --if need == "energy" then
        --print("change in energy", lvl)
    --end
    -- For saving the value
    needsLevels[need] = lvl
    -- Make change on need bar
    needsBars[need]:setProgress(lvl/maxNeedsLevels[need])
end

function setupAllNeedsBars()
    -- Starting x-axis and spacing between bars
    local startX = display.contentWidth/10
    local spacing = display.contentWidth/6
    local barsDir = "img/bars/"
    -- TODO: Update Bar files
    needsBars = {}
    needsBars.hunger = setUpNeedsBar(barsDir .. "HappinessBar.png", startX)
    needsBars.happiness = setUpNeedsBar(barsDir .. "HappinessBar.png", startX + spacing)
    needsBars.hygiene = setUpNeedsBar(barsDir .. "HygieneBar.png", startX + spacing*2)
    needsBars.energy = setUpNeedsBar(barsDir .. "EnergyBar.png", startX + spacing*3)
    needsBars.exp = setUpNeedsBar(barsDir .. "EnergyBar.png", startX + spacing*4)

    -- Load data from save
    needsLevels, maxNeedsLevels = getSavedLevels()

    -- Set All Needs Level
    setNeedsLevel("hunger", needsLevels.hunger)
    setNeedsLevel("happiness", needsLevels.happiness)
    setNeedsLevel("hygiene", needsLevels.hygiene)
    setNeedsLevel("energy", needsLevels.energy)
    setNeedsLevel("exp", needsLevels.exp)
end
-- -------------------------------------------------------------------------------
-- Setup All Icons Here

function setUpAllIcons()
    local iconsDir = "img/icons/UIIcons/"
    feedIcon = setUpIcon(iconsDir .. "feedIcon.png", 0.75)
    sleepIcon = setUpIcon(iconsDir .. "sleepIcon.png", 0.5)
    wakeupIcon = setUpIcon(iconsDir .. "wakeupIcon.png", 0.7)
    cleanIcon = setUpIcon(iconsDir .. "cleanIcon.png", 0.5)
    playIcon = setUpIcon(iconsDir .. "playIcon.png", 0.75)
    mostRecentFoodIcon1 = setUpIcon(iconsDir .. "cupcakeIcon.png", 0.75)
    mostRecentFoodIcon2 = setUpIcon(iconsDir .. "milkIcon.png", 0.5)
    moreFoodIcon = setUpIcon(iconsDir .. "optionsIcon.png", 0.75)
    shopIcon = setUpIcon(iconsDir .. "shopIcon.png", 0.5)
    mostRecentPlayIcon1 = setUpIcon(iconsDir .. "legomanIcon.png", 0.75)
    mostRecentPlayIcon2 = setUpIcon(iconsDir .. "footballIcon.png", 0.75)
    morePlayIcon = setUpIcon(iconsDir .. "optionsIcon.png", 0.75)

    inventoryIcon  = setUpIcon(iconsDir .. "inventoryIcon.png", 2, display.contentWidth*0.06, display.contentHeight*0.84, 1)

    
    hungerThoughtCloud = setUpIcon(iconsDir.. "hungry.png", 0.75, getMonster().x +60, getMonster().y -20)
    tiredThoughtCloud = setUpIcon(iconsDir.. "tired.png", 0.75, getMonster().x -35, getMonster().y -20)
    thoughtClouds = {hungerThoughtCloud, tiredThoughtCloud}

end

function setUpIcon(img, scale, x, y, alpha)
    x = x or getMonster().x
    y = y or getMonster().y
    alpha = alpha or 0

    icon = display.newImage(img, x, y)
    icon:scale(scale, scale)
    icon.alpha = alpha
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

-- -----------------------------------------------------------------------------
-- Thought Cloud functions

function showThoughtCloud(idx)
    if composer.getSceneName("current") == "home" then
        transition.fadeIn( thoughtClouds[idx], { time=1500 } )
    end
end

function hideThoughtCloud(idx)
    transition.fadeOut( thoughtClouds[idx], { time=1500 } )    
end

function checkHungerEventHandler(event)
    if needsBars.hunger:getProgress() < 0.4 then
        showThoughtCloud(1)
    end
end

-- Does not need to loop, since we should check again when hunger increase
function checkHunger(delay)
    if (checkHungerID ~= nil) then
        timer.cancel(checkHungerID)
    end

    local progress = needsBars.hunger:getProgress()
    local delay = delay or 5000
    if progress > 0.4 then
        -- Calculate approximate time that the hunger level will be below 40%
        -- Times 1000 to turn into 1 second, will later need to be change to 1 minute
        delay = ((progress - 0.4) / (-hungerRate/maxNeedsLevels.hunger))*1000
        hideThoughtCloud(1)
    end
    print("check if hungry next in", delay)
    checkHungerID = timer.performWithDelay(delay, checkHungerEventHandler, 1)
end

function checkTiredEventHandler(event)
    if needsBars.energy:getProgress() < 0.4 then
        showThoughtCloud(2)
    end
    -- Later will make predict time to check if energy is over 40% 
    -- due to fix rate of increasing in energy when sleep
    checkTired() 
end

function checkTired(delay)
    if (checkTiredID ~= nil) then
        timer.cancel(checkTiredID)
    end

    local progress = needsBars.energy:getProgress()
    local delay = delay or 5000
    if progress > 0.4 then
        -- Calculate approximate time that the energy level will be below 40%
        -- Times 1000 to turn into 1 second, will later need to be change to 1 minute
        delay = ((progress - 0.4) / (-energyRate/maxNeedsLevels.energy))*1000
        hideThoughtCloud(2)
    end
    --print("check if tired next in", delay)
    checkTiredID = timer.performWithDelay(delay, checkTiredEventHandler, 1)
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

function getInventoryIcon()
    return inventoryIcon
end

function getHungerThoughtCloud()
    return thoughtClouds[1]
end

function getTiredThoughtCloud()
    return thoughtClouds[2]
end

