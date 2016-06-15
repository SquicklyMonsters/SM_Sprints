require("savegame") -- For Testing
local composer = require("composer")
-- -------------------------------------------------------------------------------
-- Local variables go HERE

local background;

local notifications;

-- -------------------------------------------------------------------------------

function cacheVariables()
    background = getBackground()
end

function buyNotice(i)
    notifications[i].alpha = 1
    transition.fadeOut( notifications[i], { time=500 } )
end

function setUpNotifications()
    local boughtNotice = display.newImageRect("img/icons/UIIcons/buy.png", 150, 150)
    boughtNotice.x = display.contentCenterX
    boughtNotice.y = display.contentCenterY
    boughtNotice.alpha = 0

    local cantBuyNotice = display.newImageRect("img/icons/UIIcons/cannotbuy.png", 150, 150)
    cantBuyNotice.x = display.contentCenterX
    cantBuyNotice.y = display.contentCenterY
    cantBuyNotice.alpha = 0

    notifications = {boughtNotice, cantBuyNotice}
    return notifications
end

function refreshDisplayCurrency(goldText, platinumText)
    goldText.text = "Gold: " .. getCurrentGold()
    platinumText.text = "Platinum: " .. getCurrentPlatinum()
end
-- -------------------------------------------------------------------------------

-- -------------------------------------------------------------------------------
-- Hide / Show Icons with Lock

-- -------------------------------------------------------------------------------
-- Add All Event Listeners Here

