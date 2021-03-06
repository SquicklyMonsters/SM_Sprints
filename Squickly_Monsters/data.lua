-- Load external libraries
local json = require("json")
-------------------------------------------------------------------------------
-- Local variables go HERE

local invenList;
local itemQuantities;
local gold;
local platinum;
local maxSize = 9;

local foodRecentList;
local playRecentList;

local needsLevels;
local maxNeedsLevels;

local monsterLevel;
local monsterName;

local background;

local hungerRate = -50;
local happinessRate = -50;
local hygieneRate = -50;
local energyRate = -50;

local receiveDate;
local dailyLoginCount;

local saveRate;
local dataFile = system.pathForFile( "data.txt", system.DocumentsDirectory )

-- -------------------------------------------------------------------------------

-- Temp for customize background first time visit bug
local firstTimeCustBG;

function getVisitedCustBG()
  if firstTimeCustBG == true then
    firstTimeCustBG = false
    return true
  else
    return false
  end
  firstTimeCustBG = getFirstTimeCustBG()
  updateVisitedCustBG()
end

function getFirstTimeCustBG()
    return firstTimeCustBG
end

-- -------------------------------------------------------------------------------

function writeFile(file, contents)
    file = io.open(file, "w")
    file:write(contents)
    io.close(file)
end

function saveData()
    local outTable =
    {
    -- UI Data
    foodRecentList, playRecentList,
    -- Inventory Data
    invenList, itemQuantities, gold, platinum,
    -- Needs Data
    	{
    	maxNeedsLevels.hunger,
    	maxNeedsLevels.happiness,
    	maxNeedsLevels.hygiene,
    	maxNeedsLevels.energy,
    	maxNeedsLevels.exp
    	},

    	{
    	needsLevels.hunger,
    	needsLevels.happiness,
    	needsLevels.hygiene,
    	needsLevels.energy,
    	needsLevels.exp
    	},
    -- Monster
    monsterLevel,
    monsterName,
    -- Background
    background,
    -- Daily Rewards
    receiveDate,
    dailyLoginCount,
	}
    local contents = json.encode(outTable)
    writeFile(dataFile, contents)
    print("Save by Data Sage")
end

function setAutoSaveRate(rate) -- 1000 = 1sec
	if saveRate ~= nil then
		timer.cancel(saveRate)
	end
    saveRate = timer.performWithDelay(rate, saveData, -1)
end
-- -------------------------------------------------------------------------------

function readFile(file)
    -- read all contents of file into a string
    local contents = file:read( "*a" )
    inTable = json.decode(contents);
    io.close( file ) -- important!
    return inTable
end

function loadData()
    local file = io.open( dataFile, "r" )

    if file then
        local inTable = readFile(file)

        local UIIdx = 1
        foodRecentList = inTable[UIIdx]
        playRecentList = inTable[UIIdx + 1]

        local invIdx = 3
        invenList = inTable[invIdx]
        itemQuantities = inTable[invIdx + 1]
        gold = inTable[invIdx + 2]
        platinum = inTable[invIdx + 3]

        local needIdx = 7
        maxNeedsLevels =
        {
        hunger = inTable[needIdx][1],
        happiness = inTable[needIdx][2],
        hygiene = inTable[needIdx][3],
        energy = inTable[needIdx][4],
        exp = inTable[needIdx][5]
    	}
        needsLevels =
        {
        hunger = inTable[needIdx + 1][1],
        happiness = inTable[needIdx + 1][2],
        hygiene = inTable[needIdx + 1][3],
        energy = inTable[needIdx + 1][4],
        exp = inTable[needIdx + 1][5]
    	}

        local monIdx = 9
        monsterLevel = inTable[monIdx]
        monsterName = inTable[monIdx + 1]

        local bgIdx = 11
        background = inTable[bgIdx]
        firstTimeCustBG = true

        local rewIdx = 12
        receiveDate = inTable[rewIdx]
        dailyLoginCount = inTable[rewIdx + 1]

    else
    	foodRecentList = {}
        playRecentList = {}

        invenList = {}
        itemQuantities = {}
        gold = 99999
        platinum = 99999

        maxNeedsLevels = {
            hunger = 2880,
            happiness = 2880,
            hygiene = 2880,
            energy = 2880,
            exp = 2880,
        }
        needsLevels = {
            hunger = 1440,
            happiness = 1440,
            hygiene = 1440,
            energy = 1440,
            exp = 1440,
        }

        monsterLevel = 1
        monsterName = "egg_electric"
        background = "img/bg/ice.png"
        firstTimeCustBG = true
        receiveDate = nil
        dailyLoginCount = 0

    end

    print("Load by Data Sage")
end
-- -------------------------------------------------------------------------------
-- Inventory Data Modify

-- Adds new item to inventory
function addToInventory(itemName)
    -- If number of item will not exceed limit size: add item
    if #invenList < maxSize then
        table.insert(invenList, itemName)
        table.insert(itemQuantities, 1)
    end
end

-- Increase quantity of the item if it already exists
function increaseQuantity(idx)
    itemQuantities[idx] = itemQuantities[idx] + 1
end

-- Reduce quantity of the item when use
function reduceQuantity(idx)
    itemQuantities[idx] = itemQuantities[idx] - 1
    if itemQuantities[idx] > 0 then
        return itemQuantities[idx]
    else
        removeItem(idx)
    end
end

function removeItem(idx)
    table.remove(invenList,idx)
    table.remove(itemQuantities,idx)
end

function isInInventory(name)
    for i, itemName in ipairs(invenList) do
        -- If item exists in inventory: return its index
        if itemName == name then
            return i
        end
    end
    return false
end

function useItem(item)
    local idx = isInInventory(item.name)
    if idx then
        local quantity = reduceQuantity(idx)
        item:use(item.type)
        saveData()
    end
end

-- -------------------------------------------------------------------------------
-- Background Data Modify

function saveBackground()
    newBG = getChosenBG()
    if newBG ~= nil then
        background = newBG
        saveData()
    end
end

-- -------------------------------------------------------------------------------
-- Inventory Data
function getInventoryData()
	return invenList, itemQuantities, gold, platinum
end

function getGold()
	return gold
end

function getPlatinum()
	return platinum
end

function getInvenList()
	return invenList
end

function getItemQuantities()
	return itemQuantities
end

-- --

function setGold(in_gold)
    gold = in_gold
end

function setPlatinum(in_platinum)
    platinum = in_platinum
end

-- Need levels

function getNeedsLevels()
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

-- --

function setNeedsLevels(level)
    needsLevels = level
end

-- UI

function getRecentList()
    return foodRecentList, playRecentList
end

-- Background

function getSaveBackground()
    return background
end

-- Monster

function getMonsterLevel()
	return monsterLevel
end

function getMonsterName()
    return monsterName
end

-- --

function setMonsterLevel(level)
    monsterLevel = level
end

function setMonsterName(name)
    monsterName = name
end

-- Need Rates

function getHungerRate()
	return hungerRate
end

function getHappinessRate()
	return happinessRate
end

function getHygieneRate()
	return hygieneRate
end

function getEnergyRate()
	return energyRate
end

-- Daily Rewards

function getReceiveDate()
    return receiveDate
end

function getDailyLoginCount()
    return dailyLoginCount
end

-- --

function setReceiveDate(date)
    receiveDate = date
end


function setDailyLoginReward(stackLogInCount)
    dailyLoginCount = stackLogInCount
end

-- -------------------------------------------------------------------------------
