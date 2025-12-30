--[[
    Trophy Jewelry Crafting Script
    Converts gems and silver bars into jewelry trophies
    
    Trophy recipes (each requires 1 Silver Bar + 1 gem):
    - Silver Rose Engagement Ring (Star Rose Quartz)
    - Silver Amber Ring (Amber)
    - Silver Wolf's Eye Necklace (Wolf's Eye Agate)
    - Jaded Silver Ring (Jade)
    - Silvered Pearl Ring (Pearl)
    - Topaz Silver Necklace (Topaz)
    - Silvered Peridot Ring (Peridot)
    - Silver Emerald Ring (Emerald)
    - Silver Opal Engagement Ring (Opal)
    - Blackened Pearl Silver (Blackened Pearl from AA vendor)
    
    Requirements:
    - Pack9 (last bag slot) must be a jewelry crafting container
    - Slots in Pack9 must be open
    - Can buy Silver Bars from Audri Deepfacet in PoK
]]

local mq = require('mq')
local ImGui = require('ImGui')

print('\ag[Trophy]\ax Running Jewelry Trophy Script')

-- Configuration
local config = {
    silverBarID = 16500,
    minSilverBars = 10,
    silverBarsToBuy = 40,
    minTrophyCount = 2,
    craftDelay = 400, -- ms delay between craft steps
    
    -- Gem IDs
    gems = {
        {name = "Star Rose Quartz", id = 10021, trophy = "Silver Rose Engagement Ring"},
        {name = "Amber", id = 10022, trophy = "Silver Amber Ring"},
        {name = "Wolf's Eye Agate", id = 16010, trophy = "Silver Wolf's Eye Necklace"},
        {name = "Jade", id = 10023, trophy = "Jaded Silver Ring"},
        {name = "Pearl", id = 10024, trophy = "Silvered Pearl Ring"},
        {name = "Topaz", id = 10025, trophy = "Topaz Silver Necklace"},
        {name = "Peridot", id = 10028, trophy = "Silvered Peridot Ring"},
        {name = "Emerald", id = 10029, trophy = "Silver Emerald Ring"},
        {name = "Opal", id = 10030, trophy = "Silver Opal Engagement Ring"},
    },
    
    -- Jewelry tests
    jewelryTests = {
        "Beginners Jewelery Test",
        "Freshmans Jewelery Test"
    },
    
    -- Jewelry recipes organized by test
    jewelryRecipes = {
        -- Beginners Jewelery Test recipes (all 9 types, 2 each)
        ["Beginners Jewelery Test"] = {
            {name = "Star Rose Quartz", id = 10021, trophy = "Silver Rose Engagement Ring", required = 2},
            {name = "Amber", id = 10022, trophy = "Silver Amber Ring", required = 2},
            {name = "Wolf's Eye Agate", id = 16010, trophy = "Silver Wolf's Eye Necklace", required = 2},
            {name = "Jade", id = 10023, trophy = "Jaded Silver Ring", required = 2},
            {name = "Pearl", id = 10024, trophy = "Silvered Pearl Ring", required = 2},
            {name = "Topaz", id = 10025, trophy = "Topaz Silver Necklace", required = 2},
            {name = "Peridot", id = 10028, trophy = "Silvered Peridot Ring", required = 2},
            {name = "Emerald", id = 10029, trophy = "Silver Emerald Ring", required = 2},
            {name = "Opal", id = 10030, trophy = "Silver Opal Engagement Ring", required = 2},
        },
        -- Freshmans Jewelery Test recipes
        ["Freshmans Jewelery Test"] = {
            {name = "Emerald", id = 10029, trophy = "Silver Emerald Ring", required = 4},
            {name = "Opal", id = 10030, trophy = "Silver Opal Engagement Ring", required = 4},
            {name = "Black Pearl", id = 10012, trophy = "Blackened Pearl Silver Ring", required = 1, vendor = "AA Vendor"},
            {name = "Wolf's Eye Agate", id = 16010, trophy = "Wolf's Eye Electrum Bracelet", required = 3, specialBar = "Electrum Bar", specialBarID = 16501},
            {name = "Jade", id = 10023, trophy = "Jaded Electrum Bracelet", required = 3, specialBar = "Electrum Bar", specialBarID = 16501},
            {name = "Diamond", id = nil, trophy = "Diamond Electrum Mask", required = 1, specialBar = "Electrum Bar", specialBarID = 16501, vendor = "Dropped"},
            {name = "Malachite", id = 10015, trophy = "Gold Malachite Bracelet", required = 2, specialBar = "Gold Bar", specialBarID = 16502},
            {name = "Blue Diamond", id = nil, trophy = "Blue Diamond Electrum Earring", required = 1, specialBar = "Electrum Bar", specialBarID = 16501, vendor = "Dropped"},
            {name = "Turquoise", id = 10017, trophy = "Gold Turquoise Engagement Ring", required = 2, specialBar = "Gold Bar", specialBarID = 16502},
            {name = "Hematite", id = 10018, trophy = "Golden Hematite Choker", required = 2, specialBar = "Gold Bar", specialBarID = 16502},
        },
    },
    
    -- Brewing tests and recipes
    brewingTests = {
        "Beginners Brewer Test",
        "Freshmans Brewer Test"
    },
    
    -- Brewing recipes organized by test
    brewingRecipes = {
        -- Beginners Brewer Test recipes
        ["Beginners Brewer Test"] = {
            {
                name = "Malted Milk",
                components = {
                    {name = "Bottle", id = 16598, vendor = "Brewmaster_Berina00"},
                    {name = "Bottle of Milk", id = 13087, vendor = "Chef_Denrun00"},
                    {name = "Malt", id = 16595, vendor = "Brewmaster_Berina00"}
                },
                required = 1
            },
            {
                name = "Flask of Sylvan Berry Juice",
                components = {
                    {name = "Sylvan Berries", id = 14957, quantity = 2, vendor = "Dropped"},
                    {name = "Water Flask", id = 13006, vendor = "Brewmaster_Berina00"}
                },
                required = 1
            },
            {
                name = "Bottle of Kalish",
                components = {
                    {name = "Bottle", id = 16598, vendor = "Brewmaster_Berina00"},
                    {name = "Fruit", id = 13046, vendor = "Foraged"},
                    {name = "Vegetables", id = nil, vendor = nil},
                    {name = "Water Flask", id = 13006, vendor = "Brewmaster_Berina00"}
                },
                required = 1
            },
            {
                name = "Short Beer",
                components = {
                    {name = "Barley", id = 16590, vendor = "Brewmaster_Berina00"},
                    {name = "Cask", id = 16580, vendor = "Brewmaster_Berina00"},
                    {name = "Hops", id = 16591, vendor = "Brewmaster_Berina00"},
                    {name = "Malt", id = 16595, vendor = "Brewmaster_Berina00"}
                },
                required = 2
            },
            {
                name = "Fizzle Pop",
                components = {
                    {name = "Aerated Mineral Water", id = 28021, vendor = nil},
                    {name = "Berries", id = 13045, vendor = "Foraged"},
                    {name = "Bottle", id = 16598, quantity = 2, vendor = "Brewmaster_Berina00"},
                    {name = "Sylvan Berries", id = 14957, vendor = "Dropped"}
                },
                required = 1
            },
            {
                name = "Mead",
                components = {
                    {name = "Cask", id = 16580, vendor = "Brewmaster_Berina00"},
                    {name = "Hops", id = 16591, vendor = "Brewmaster_Berina00"},
                    {name = "Malt", id = 16595, vendor = "Brewmaster_Berina00"},
                    {name = "Yeast", id = 16596, vendor = "Brewmaster_Berina00"}
                },
                required = 2
            },
            {
                name = "Honey Mead",
                components = {
                    {name = "Cask", id = 16580, vendor = "Brewmaster_Berina00"},
                    {name = "Hops", id = 16591, vendor = "Brewmaster_Berina00"},
                    {name = "Royal Jelly", id = 13145, vendor = nil},
                    {name = "Water Flask", id = 13006, vendor = "Brewmaster_Berina00"}
                },
                required = 1
            },
            {
                name = "Heady Paeala",
                components = {
                    {name = "Bottle", id = 16598, vendor = "Brewmaster_Berina00"},
                    {name = "Packet of Paeala Sap", id = 16565, quantity = 2, vendor = "Brewmaster_Berina00"},
                    {name = "Water Flask", id = 13006, vendor = "Brewmaster_Berina00"}
                },
                required = 2
            },
            {
                name = "Short Ale",
                components = {
                    {name = "Barley", id = 16590, vendor = "Brewmaster_Berina00"},
                    {name = "Cask", id = 16580, vendor = "Brewmaster_Berina00"},
                    {name = "Hops", id = 16591, vendor = "Brewmaster_Berina00"},
                    {name = "Water Flask", id = 13006, vendor = "Brewmaster_Berina00"}
                },
                required = 2
            },
            {
                name = "Lemonade",
                components = {
                    {name = "Cup of Sugar", id = 15961, vendor = "Chef_Denrun00"},
                    {name = "Lemon", id = 58281, vendor = "Chef_Denrun00"},
                    {name = "Water Flask", id = 13006, vendor = "Brewmaster_Berina00"}
                },
                required = 2
            }
        },
        -- Freshmans Brewer Test recipes
        ["Freshmans Brewer Test"] = {
            {
                name = "Short Ale",
                components = {
                    {name = "Barley", id = 16590, vendor = "Brewmaster_Berina00"},
                    {name = "Cask", id = 16580, vendor = "Brewmaster_Berina00"},
                    {name = "Hops", id = 16591, vendor = "Brewmaster_Berina00"},
                    {name = "Water Flask", id = 13006, vendor = "Brewmaster_Berina00"}
                },
                required = 3
            },
            {
                name = "Heady Paeala",
                components = {
                    {name = "Bottle", id = 16598, vendor = "Brewmaster_Berina00"},
                    {name = "Packet of Paeala Sap", id = 16565, quantity = 2, vendor = "Brewmaster_Berina00"},
                    {name = "Water Flask", id = 13006, vendor = "Brewmaster_Berina00"}
                },
                required = 4
            },
            {
                name = "Lemonade",
                components = {
                    {name = "Cup of Sugar", id = 15961, vendor = "Chef_Denrun00"},
                    {name = "Lemon", id = 58281, vendor = "Chef_Denrun00"},
                    {name = "Water Flask", id = 13006, vendor = "Brewmaster_Berina00"}
                },
                required = 3
            },
            {
                name = "Thubr's Darkened Ale",
                components = {
                    {name = "Barley", id = 16590, vendor = "Brewmaster_Berina00"},
                    {name = "Cask", id = 16580, vendor = "Brewmaster_Berina00"},
                    {name = "Malt", id = 16595, vendor = "Brewmaster_Berina00"},
                    {name = "Strange Dark Fungus", id = 19985, vendor = nil},
                    {name = "Yeast", id = 16596, vendor = "Brewmaster_Berina00"}
                },
                required = 1
            },
            {
                name = "Gnomish Spirits",
                components = {
                    {name = "Bottle", id = 16598, vendor = "Brewmaster_Berina00"},
                    {name = "Rat Ears", id = 13072, vendor = nil},
                    {name = "Rice", id = 16593, vendor = "Brewmaster_Berina00"},
                    {name = "Spider Legs", id = 13417, vendor = nil}
                },
                required = 1
            },
            {
                name = "2x Brewed 2x Stout Dwarven Ale",
                components = {
                    {name = "Cask", id = 16580, vendor = "Brewmaster_Berina00"},
                    {name = "Dwarven Ale", id = nil, quantity = 2, vendor = "Chef_Denrun00"},
                    {name = "Short Beer", id = nil, quantity = 2, vendor = "Chef_Denrun00"}
                },
                required = 1
            },
            {
                name = "Bayle's Delight",
                components = {
                    {name = "Griffon Feathers", id = nil, vendor = nil},
                    {name = "King's Thorn", id = 16999, vendor = nil},
                    {name = "Water Flask", id = 13006, vendor = "Brewmaster_Berina00"}
                },
                required = 1
            },
            {
                name = "Faydwer Schnapps",
                components = {
                    {name = "Bottle", id = 16598, vendor = "Brewmaster_Berina00"},
                    {name = "Steamfont Spring Water", id = 14956, vendor = nil},
                    {name = "Sylvan Berries", id = 14957, quantity = 2, vendor = "Dropped"},
                    {name = "Wine Yeast", id = 16597, vendor = "Brewmaster_Berina00"}
                },
                required = 1
            },
            {
                name = "Snapper Oil",
                components = {
                    {name = "Dragon Bay Snapper", id = 22770, vendor = nil},
                    {name = "Water Flask", id = 13006, vendor = "Brewmaster_Berina00"}
                },
                required = 1
            },
            {
                name = "Hulgarsh",
                components = {
                    {name = "Cask", id = 16580, vendor = "Brewmaster_Berina00"},
                    {name = "Fishing Bait", id = 13101, vendor = "Daeld_Atand00"},
                    {name = "Vodka", id = nil, quantity = 2, vendor = nil},
                    {name = "Water Flask", id = 13006, vendor = "Brewmaster_Berina00"}
                },
                required = 1
            }
        }
    },
    
    -- Pottery tests
    potteryTests = {
        "Beginners Pottery Test",
        "Freshmans Pottery Test"
    },
    
    -- Pottery recipes organized by test
    potteryRecipes = {
        ["Beginners Pottery Test"] = {
            {
                name = "Unfired Small Container",
                components = {
                    {name = "Block of Clay", id = 16901, vendor = "Sculptor_Radee"},
                    {name = "Small Jar Sketch", id = 16951, vendor = "Sculptor_Radee"},
                    {name = "Water Flask", id = 13006, vendor = "Brewmaster_Berina00"}
                },
                required = 4
            },
            {
                name = "Unfired Medium Container",
                components = {
                    {name = "Block of Clay", id = 16901, vendor = "Sculptor_Radee"},
                    {name = "Medium Jar Sketch", id = 16952, vendor = "Sculptor_Radee"},
                    {name = "Water Flask", id = 13006, vendor = "Brewmaster_Berina00"}
                },
                required = 2
            },
            {
                name = "Unfired Ceramic Lining",
                components = {
                    {name = "Ceramic Lining Sketch", id = 16964, vendor = "Sculptor_Radee"},
                    {name = "Small Block of Clay", id = 16900, vendor = "Sculptor_Radee"},
                    {name = "Water Flask", id = 13006, vendor = "Brewmaster_Berina00"}
                },
                required = 4
            },
            {
                name = "Dye Vial",
                components = {
                    {name = "Quality Firing Sheet", id = 16907, vendor = "Sculptor_Radee"},
                    {name = "Unfired Dye Vial", id = 65470, vendor = "Sculptor_Radee"}
                },
                required = 2
            },
            {
                name = "Unfired Pot",
                components = {
                    {name = "Large Block of Clay", id = 16902, vendor = "Sculptor_Radee"},
                    {name = "Metal Bits", id = nil, vendor = nil},
                    {name = "Pot Sketch", id = 16955, vendor = "Sculptor_Radee"},
                    {name = "Water Flask", id = 13006, vendor = "Brewmaster_Berina00"}
                },
                required = 2
            }
        },
        ["Freshmans Pottery Test"] = {
            -- Recipes to be added
        }
    }
}

-- GUI State
local guiOpen = true
local showGUI = true
local isRunning = false
local buyingBrewingComponents = false
local brewingTestToBuy = ""
local buyingPotteryComponents = false
local potteryTestToBuy = ""
local currentStatus = "Idle"
local currentStep = ""
local progressData = {}
local startTrophyQuest = false  -- Flag to trigger trophy quest
local startPotteryQuest = false  -- Flag to trigger pottery quest
local startBreweryQuest = false  -- Flag to trigger brewery quest
local startTurnIn = false  -- Flag to trigger turn-in process (jewelry)
local startBrewerTurnIn = false  -- Flag to trigger turn-in process (brewing)
local selectedBrewingTest = 1  -- Default to first test (Beginners Brewer Test)
local selectedPotteryTest = 1  -- Default to first test (Beginners Pottery Test)
local selectedJewelryTest = 1  -- Default to first test (Beginners Jewelery Test)

-- Function to initialize progress data based on selected test
local function initializeProgressData()
    progressData = {}
    local selectedTestName = config.jewelryTests[selectedJewelryTest]
    local recipes = config.jewelryRecipes[selectedTestName]
    
    if recipes then
        for _, recipe in ipairs(recipes) do
            table.insert(progressData, {
                trophy = recipe.trophy,
                gemName = recipe.name,
                count = 0,
                target = recipe.required,
                complete = false
            })
        end
    end
end

-- Initialize progress data with default test
initializeProgressData()

-- Utility functions (must be defined before use)
local function delay(ms)
    -- Use doevents loop instead of mq.delay for coroutine compatibility
    if not ms or ms <= 0 then return end
    local endTime = os.clock() * 1000 + ms
    while (os.clock() * 1000) < endTime do
        mq.doevents()
    end
end

local function findItemCount(itemName)
    return mq.TLO.FindItemCount('=' .. itemName)() or 0
end

local function isNavigating()
    return mq.TLO.Navigation.Active()
end

-- Update progress data
local function updateProgress()
    for i, item in ipairs(progressData) do
        local count = findItemCount(item.trophy)
        item.count = count
        item.complete = (count >= item.target)
    end
end

-- Calculate overall completion percentage
local function getOverallProgress()
    local totalComplete = 0
    local totalItems = #progressData
    
    for _, item in ipairs(progressData) do
        if item.complete then
            totalComplete = totalComplete + 1
        end
    end
    
    return math.floor((totalComplete / totalItems) * 100)
end

-- Check for Freshman Jeweler Scorecard
local function checkForCard()
    local cardCount = findItemCount('Freshman Jeweler Scorecard')
    if cardCount > 0 then
        return true, string.format("You have the Freshman Jeweler Scorecard in inventory (%d)", cardCount)
    else
        return false, "Freshman Jeweler Scorecard not found"
    end
end

-- Check for existing Jeweler Trophy
local function haveJeweler()
    -- Check all inventory locations including equipped items
    -- Slots: 0-22 are worn/equipped, 23-32 are general inventory
    for slot = 0, 32 do
        local item = mq.TLO.Me.Inventory(slot)
        if item and item.Name() then
            local itemName = item.Name()
            if itemName and itemName:find("Jeweler Trophy") then
                return true, string.format("You have the %s already", itemName)
            end
        end
        
        -- Check items in bags within this slot (only applies to bag slots)
        if slot >= 23 then
            local container = mq.TLO.Me.Inventory(slot).Container()
            if container and container > 0 then
                for bagSlot = 1, container do
                    local bagItem = mq.TLO.Me.Inventory(slot).Item(bagSlot)
                    if bagItem and bagItem.Name() then
                        local bagItemName = bagItem.Name()
                        if bagItemName and bagItemName:find("Jeweler Trophy") then
                            return true, string.format("You have the %s already", bagItemName)
                        end
                    end
                end
            end
        end
    end
    
    return false, "No Jeweler Trophy found"
end

-- Check Jewelry Making skill level
local function checkJewelrySkill()
    local skillLevel = mq.TLO.Me.Skill('Jewelry Making')() or 0
    
    if skillLevel < 50 then
        return false, string.format("Jewelry Making skill at %d - need to skill up before trophy request (requires 50+)", skillLevel)
    else
        return true, string.format("Jewelry Making skill: %d (sufficient for trophy)", skillLevel)
    end
end

-- Check Pottery skill level
local function checkPotterySkill()
    local skillLevel = mq.TLO.Me.Skill('Pottery')() or 0
    
    if skillLevel < 50 then
        return false, string.format("Pottery skill at %d - not enough pottery skill to request trophy quest (requires 50+)", skillLevel)
    else
        return true, string.format("Pottery skill: %d (sufficient for trophy)", skillLevel)
    end
end

-- Check Brewing skill level
local function checkBrewingSkill()
    local skillLevel = mq.TLO.Me.Skill('Brewing')() or 0
    
    if skillLevel < 50 then
        return false, string.format("Brewing skill at %d - not enough brewing skill to request trophy quest (requires 50+)", skillLevel)
    else
        return true, string.format("Brewing skill: %d (sufficient for trophy)", skillLevel)
    end
end

-- Navigation functions

local function navToSpawn(spawnName)
    local spawn = mq.TLO.Spawn(spawnName)
    if not spawn or not spawn.ID() then
        print(string.format('\ar[Trophy]\ax Could not find spawn: %s', spawnName))
        return false
    end
    
    mq.cmdf('/nav spawn "%s"', spawnName)
    
    -- Wait for navigation to complete (max 4 minutes)
    local maxWait = 240000 -- 4 minutes in ms
    local startTime = os.clock() * 1000
    while isNavigating() and ((os.clock() * 1000 - startTime) < maxWait) do
        mq.doevents()
        delay(100)
    end
    
    return true
end

local function navToID(id)
    print(string.format('\ay[Trophy]\ax navToID called with ID: %d', id))
    
    local spawn = mq.TLO.Spawn(string.format('id %d', id))
    if not spawn or not spawn.ID() then
        print(string.format('\ar[Trophy]\ax Could not find spawn with ID: %d', id))
        return false
    end
    
    print(string.format('\ay[Trophy]\ax Found spawn: %s (ID: %d)', spawn.Name() or 'Unknown', id))
    print(string.format('\ay[Trophy]\ax Issuing /nav id %d', id))
    mq.cmdf('/nav id %d', id)
    
    -- Wait for nav to start (max 2 seconds)
    local startTime = os.clock() * 1000
    print('\ay[Trophy]\ax Waiting for navigation to start...')
    while not isNavigating() and ((os.clock() * 1000 - startTime) < 2000) do
        mq.doevents()
        delay(50)
    end
    
    if not isNavigating() then
        print('\ar[Trophy]\ax Navigation did not start!')
        return false
    end
    
    print('\ay[Trophy]\ax Navigation started, waiting for completion...')
    -- Wait for nav to complete and get close
    while isNavigating() do
        local distance = spawn.Distance3D() or 999
        if distance < 15 then
            print(string.format('\ay[Trophy]\ax Close enough to target (distance: %.1f)', distance))
            break
        end
        mq.doevents()
        delay(50)
    end
    
    print('\ay[Trophy]\ax Navigation complete, targeting spawn...')
    -- Target the spawn
    if spawn.Distance3D() and spawn.Distance3D() < 15 then
        mq.cmdf('/target id %d', id)
        
        -- Wait for target to be acquired (max 2 seconds)
        startTime = os.clock() * 1000
        while mq.TLO.Target.ID() ~= id and ((os.clock() * 1000 - startTime) < 2000) do
            mq.doevents()
            delay(50)
        end
        
        mq.cmd('/face fast')
        print('\ay[Trophy]\ax Target acquired and facing')
    end
    
    return true
end

local function travelTo(zoneName)
    mq.cmdf('/travelto %s', zoneName)
    
    -- Wait for navigation to complete (max 4 minutes)
    local maxWait = 240000 -- 4 minutes in ms
    local startTime = os.clock() * 1000
    while isNavigating() and ((os.clock() * 1000 - startTime) < maxWait) do
        mq.doevents()
        delay(100)
    end
end

-- Vendor functions
local function buyItem(itemName, amount, closeMerchant, itemID)
    if closeMerchant == nil then closeMerchant = true end
    
    local currentCount = findItemCount(itemName)
    if currentCount >= amount then
        return true
    end
    
    local qty = amount - currentCount
    
    -- Try to find item in merchant list - prefer ID for exact match, fallback to name
    local listItem = nil
    if itemID then
        -- Use item ID for exact matching
        listItem = mq.TLO.Window('MerchantWnd').Child('MW_ItemList').List(tostring(itemID), 3)()
        if listItem then
            print(string.format('\ay[Trophy]\ax Debug: Found %s using item ID: %d', itemName, itemID))
        end
    end
    
    -- Fallback to name-based search
    if not listItem then
        listItem = mq.TLO.Window('MerchantWnd').Child('MW_ItemList').List('=' .. itemName, 2)()
        if listItem then
            print(string.format('\ay[Trophy]\ax Debug: Found %s using exact name match', itemName))
        end
    end
    
    if not listItem then
        print(string.format('\ar[Trophy]\ax Could not find %s in merchant window', itemName))
        return false
    end
    
    mq.cmdf('/notify MerchantWnd MW_ItemList listselect %d', listItem)
    delay(500)
    
    print(string.format('\ay[Trophy]\ax Buying %s until I get %d', itemName, amount))
    
    while qty > 0 do
        local beforeCount = findItemCount(itemName)
        
        if qty > 999 then
            mq.cmd('/buyitem 1000')
            -- Wait for item count to increase
            local maxWait = 3000
            local startTime = os.clock() * 1000
            while findItemCount(itemName) <= beforeCount and ((os.clock() * 1000 - startTime) < maxWait) do
                mq.doevents()
                delay(50)
            end
        else
            mq.cmdf('/buyitem %d', qty)
            -- Wait for item count to increase
            local maxWait = 5000
            local startTime = os.clock() * 1000
            while findItemCount(itemName) <= beforeCount and ((os.clock() * 1000 - startTime) < maxWait) do
                mq.doevents()
                delay(50)
            end
        end
        
        local newCount = findItemCount(itemName)
        if newCount > beforeCount then
            local percent = math.floor((newCount / amount) * 100)
            print(string.format('\ar[Trophy]\ax %d\aw/\ar%d\ax %s \at%d%%\ax Done', 
                newCount, amount, itemName, percent))
        end
        
        qty = amount - newCount
    end
    
    -- Close merchant window only if requested
    if closeMerchant then
        while mq.TLO.Window('MerchantWnd').Open() do
            mq.cmd('/nomodkey /notify MerchantWnd MW_Done_Button leftmouseup')
            delay(50)
        end
    end
    
    return true
end

local function replenishSilverBars()
    currentStep = "Buying Silver Bars"
    print(string.format('\ay[Trophy]\ax I only have \ar%d\ay Silver Bars. Going to get more.', 
        findItemCount('Silver Bar')))
    
    print('\ay[Trophy]\ax Looking for Audri Deepfacet...')
    local audriSpawn = mq.TLO.Spawn('Audri Deepfacet')
    if not audriSpawn or not audriSpawn.ID() then
        print('\ar[Trophy]\ax Could not find Audri Deepfacet')
        currentStep = "Error: Cannot find Audri Deepfacet"
        return false
    end
    
    print(string.format('\ay[Trophy]\ax Found Audri Deepfacet (ID: %d), navigating...', audriSpawn.ID()))
    local navResult = navToID(audriSpawn.ID())
    
    if not navResult then
        print('\ar[Trophy]\ax Failed to navigate to Audri Deepfacet')
        currentStep = "Error: Navigation failed"
        return false
    end
    
    print('\ay[Trophy]\ax Opening merchant window...')
    mq.cmd('/click right target')
    
    -- Wait for merchant window to open
    local maxWait = 2000
    local startTime = os.clock() * 1000
    while not mq.TLO.Window('MerchantWnd').Child('MW_ItemList').List('Silver Bar', 2)() and ((os.clock() * 1000 - startTime) < maxWait) do
        mq.doevents()
        delay(50)
    end
    
    if not mq.TLO.Window('MerchantWnd').Child('MW_ItemList').List('Silver Bar', 2)() then
        print('\ar[Trophy]\ax Merchant window did not open or Silver Bar not found')
        currentStep = "Error: Cannot find Silver Bar in merchant"
        return false
    end
    
    print(string.format('\ay[Trophy]\ax Buying %d Silver Bars...', config.silverBarsToBuy))
    buyItem('Silver Bar', config.silverBarsToBuy)
    currentStep = "Silver Bars restocked"
    print('\ag[Trophy]\ax Silver Bars restocked successfully')
    return true
end

-- Crafting functions
local function cleanup()
    -- Clear craft container slots
    mq.cmd('/itemnotify in pack9 1 leftmouseup')
    delay(config.craftDelay)
    mq.cmd('/autoinventory')
    
    mq.cmd('/itemnotify in pack9 2 leftmouseup')
    delay(config.craftDelay)
    mq.cmd('/autoinventory')
end

local function craftTrophy(gemName, trophyName, gemID, barName, barID)
    -- Default to Silver Bar if not specified
    barName = barName or "Silver Bar"
    barID = barID or config.silverBarID
    
    local barCount = findItemCount(barName)
    local gemCount = findItemCount(gemName)
    
    if barCount < 1 or gemCount < 1 then
        return false
    end
    
    if isNavigating() then
        return false
    end
    
    -- Clear inventory cursor
    mq.cmd('/autoinventory')
    delay(config.craftDelay)
    
    -- Place gem in slot 1 (use ctrl to pick up single item from anywhere in inventory)
    -- MQ will automatically find the item by name
    mq.cmdf('/nomodkey /ctrlkey /itemnotify "%s" leftmouseup', gemName)
    delay(config.craftDelay)
    
    if mq.TLO.Cursor.ID() then
        mq.cmd('/itemnotify in pack9 1 leftmouseup')
        delay(config.craftDelay)
    else
        print(string.format('\ar[Trophy]\ax Failed to pick up %s', gemName))
        cleanup()
        return false
    end
    
    -- Place bar in slot 2 (use ctrl to pick up single item)
    mq.cmdf('/nomodkey /ctrlkey /itemnotify "%s" leftmouseup', barName)
    delay(config.craftDelay)
    
    if mq.TLO.Cursor.ID() then
        mq.cmd('/itemnotify in pack9 2 leftmouseup')
        delay(config.craftDelay)
    else
        print(string.format('\ar[Trophy]\ax Failed to pick up %s', barName))
        cleanup()
        return false
    end
    
    -- Combine
    mq.cmd('/notify ContainerCombine_Items Container_Combine leftmouseup')
    delay(config.craftDelay)
    
    -- Auto inventory result
    mq.cmd('/autoinventory')
    delay(config.craftDelay)
    
    -- Cleanup any remaining items
    cleanup()
    
    return true
end

-- Trophy building loop
local function buildTrophies()
    currentStatus = "Building Trophies"
    print('\ag[Trophy]\ax Starting trophy building loop')
    
    -- Get recipes for selected test
    local selectedTestName = config.jewelryTests[selectedJewelryTest]
    local recipes = config.jewelryRecipes[selectedTestName]
    
    while isRunning do
        updateProgress()
        
        -- First pass: Calculate what we need to build
        local totalNeeded = 0
        local silverBarsNeeded = 0
        local craftQueue = {}
        local canContinue = true
        
        for _, recipe in ipairs(recipes) do
            local trophyCount = findItemCount(recipe.trophy)
            local needed = recipe.required - trophyCount
            
            if needed > 0 then
                totalNeeded = totalNeeded + needed
                -- Add to appropriate bar count (Silver or special like Electrum)
                if recipe.specialBar then
                    -- Don't add to silverBarsNeeded, will be handled separately
                else
                    silverBarsNeeded = silverBarsNeeded + needed
                end
                
                -- Check if we have the gems needed
                local gemCount = findItemCount(recipe.name)
                
                table.insert(craftQueue, {
                    gem = {name = recipe.name, trophy = recipe.trophy, id = recipe.id, vendor = recipe.vendor},
                    bar = {name = recipe.specialBar or "Silver Bar", id = recipe.specialBarID or config.silverBarID},
                    needed = needed,
                    current = trophyCount,
                    hasGems = gemCount >= needed,
                    required = recipe.required
                })
                
                print(string.format('\ay[Trophy]\ax Need to craft %d more %s (have %d, need %d)', 
                    needed, recipe.trophy, trophyCount, recipe.required))
            end
        end
        
        -- If nothing to craft, we're done
        if totalNeeded == 0 then
            currentStatus = "Complete!"
            currentStep = "All configured trophies complete"
            print(string.format('\ag[Trophy]\ax All trophies for %s complete!', selectedTestName))
            isRunning = false
            break
        end
        
        -- Navigate to Audri if needed and check materials
        local needToVisitVendor = false
        local currentSilverBars = findItemCount('Silver Bar')
        
        -- Check if silver bars are needed
        if currentSilverBars < silverBarsNeeded then
            needToVisitVendor = true
        end
        
        -- Check for special bars (like Electrum)
        local specialBarsNeeded = {}
        for _, item in ipairs(craftQueue) do
            if item.bar.name ~= "Silver Bar" then
                if not specialBarsNeeded[item.bar.name] then
                    specialBarsNeeded[item.bar.name] = {needed = 0, id = item.bar.id}
                end
                specialBarsNeeded[item.bar.name].needed = specialBarsNeeded[item.bar.name].needed + item.needed
            end
        end
        
        -- Check if special bars are missing
        for barName, barInfo in pairs(specialBarsNeeded) do
            local currentCount = findItemCount(barName)
            if currentCount < barInfo.needed then
                needToVisitVendor = true
                break
            end
        end
        
        -- Check if any gems are missing
        for _, item in ipairs(craftQueue) do
            if not item.hasGems then
                needToVisitVendor = true
                break
            end
        end
        
        if needToVisitVendor then
            print('\ay[Trophy]\ax Need to visit vendor for materials...')
            
            local audriSpawn = mq.TLO.Spawn('Audri Deepfacet')
            if not audriSpawn or not audriSpawn.ID() then
                print('\ar[Trophy]\ax Cannot find Audri Deepfacet!')
                currentStatus = "Error"
                currentStep = "Cannot find Audri Deepfacet"
                isRunning = false
                break
            end
            
            local distance = audriSpawn.Distance3D() or 999
            
            -- Navigate if too far
            if distance > 15 then
                print(string.format('\ay[Trophy]\ax Audri is %.1f units away, navigating...', distance))
                currentStep = "Navigating to Audri Deepfacet"
                navToID(audriSpawn.ID())
                delay(1000)
            end
            
            -- Open merchant window
            print('\ay[Trophy]\ax Opening merchant window...')
            mq.cmd('/target Audri Deepfacet')
            delay(500)
            mq.cmd('/click right target')
            delay(2000)
            
            if not mq.TLO.Window('MerchantWnd').Open() then
                print('\ar[Trophy]\ax Failed to open merchant window!')
                currentStatus = "Error"
                currentStep = "Cannot open merchant window"
                isRunning = false
                break
            end
            
            -- Wait for merchant window to fully populate
            delay(500)
            
            -- Buy silver bars if needed
            if currentSilverBars < silverBarsNeeded then
                local toBuy = silverBarsNeeded - currentSilverBars + 10
                print(string.format('\ay[Trophy]\ax Buying %d Silver Bars...', toBuy))
                currentStep = string.format("Buying %d Silver Bars", toBuy)
                buyItem('Silver Bar', currentSilverBars + toBuy, false, config.silverBarID)  -- Don't close merchant, use ID
            end
            
            -- Buy special bars if needed
            for barName, barInfo in pairs(specialBarsNeeded) do
                local currentCount = findItemCount(barName)
                if currentCount < barInfo.needed then
                    local toBuy = barInfo.needed - currentCount + 5
                    print(string.format('\ay[Trophy]\ax Buying %d %s...', toBuy, barName))
                    currentStep = string.format("Buying %d %s", toBuy, barName)
                    local success = buyItem(barName, currentCount + toBuy, false, barInfo.id)
                    if not success then
                        print(string.format('\ar[Trophy]\ax Failed to buy %s', barName))
                        canContinue = false
                    else
                        -- Verify we got the bars
                        delay(500)
                        local newCount = findItemCount(barName)
                        if newCount < barInfo.needed then
                            print(string.format('\ar[Trophy]\ax Still don\'t have enough %s (have %d, need %d)', barName, newCount, barInfo.needed))
                            canContinue = false
                        end
                    end
                end
            end
            
            -- Try to buy gems that are missing
            for _, item in ipairs(craftQueue) do
                if not item.hasGems then
                    local currentGemCount = findItemCount(item.gem.name)
                    local gemsToBuy = item.needed - currentGemCount
                    
                    -- Skip items that aren't from Audri Deepfacet (e.g., AA Vendor items)
                    if item.gem.vendor and item.gem.vendor ~= "Audri Deepfacet" then
                        print(string.format('\ay[Trophy]\ax Skipping %s - must be obtained from %s manually', item.gem.name, item.gem.vendor))
                        if currentGemCount < item.needed then
                            canContinue = false
                        end
                    elseif gemsToBuy > 0 then
                        print(string.format('\ay[Trophy]\ax Attempting to buy %d %s (ID: %d)...', gemsToBuy, item.gem.name, item.gem.id))
                        currentStep = string.format("Buying %s", item.gem.name)
                        
                        -- Use item ID for exact matching
                        local success = buyItem(item.gem.name, currentGemCount + gemsToBuy, false, item.gem.id)  -- Don't close merchant, use ID
                        if success then
                            item.hasGems = true
                        else
                            print(string.format('\ar[Trophy]\ax Failed to buy %s', item.gem.name))
                            canContinue = false
                        end
                    end
                end
            end
            
            -- Close merchant window
            while mq.TLO.Window('MerchantWnd').Open() do
                mq.cmd('/nomodkey /notify MerchantWnd MW_Done_Button leftmouseup')
                delay(50)
            end
            
            -- Final verification: Check all materials before crafting
            delay(1000)  -- Give time for inventory to update
            
            -- Verify Silver Bars
            if silverBarsNeeded > 0 then
                local actualSilver = findItemCount('Silver Bar')
                if actualSilver < silverBarsNeeded then
                    print(string.format('\ar[Trophy]\ax Insufficient Silver Bars! Have %d, need %d', actualSilver, silverBarsNeeded))
                    canContinue = false
                end
            end
            
            -- Verify Special Bars
            for barName, barInfo in pairs(specialBarsNeeded) do
                local actualCount = findItemCount(barName)
                if actualCount < barInfo.needed then
                    print(string.format('\ar[Trophy]\ax Insufficient %s! Have %d, need %d', barName, actualCount, barInfo.needed))
                    canContinue = false
                end
            end
            
            -- Verify Gems
            for _, item in ipairs(craftQueue) do
                local actualGems = findItemCount(item.gem.name)
                if actualGems < item.needed then
                    print(string.format('\ar[Trophy]\ax Insufficient %s! Have %d, need %d', item.gem.name, actualGems, item.needed))
                    canContinue = false
                end
            end
        end
        
        -- If we can't get required gems, stop
        if not canContinue then
            print('\ar[Trophy]\ax Cannot continue - missing gems that vendor does not sell')
            print('\ar[Trophy]\ax Please obtain the required gems manually')
            currentStatus = "Stopped"
            currentStep = "Missing gems - obtain manually"
            isRunning = false
            break
        end
        
        -- Second pass: Craft what we need
        for _, item in ipairs(craftQueue) do
            while findItemCount(item.gem.trophy) < item.required and isRunning do
                local barCount = findItemCount(item.bar.name)
                local gemCount = findItemCount(item.gem.name)
                
                if barCount < 1 or gemCount < 1 then
                    print(string.format('\ar[Trophy]\ax Ran out of materials for %s (%s: %d, %s: %d)', 
                        item.gem.trophy, item.bar.name, barCount, item.gem.name, gemCount))
                    break
                end
                
                if not isNavigating() then
                    local trophyCount = findItemCount(item.gem.trophy)
                    currentStep = string.format('Crafting %s (%d/%d)', item.gem.trophy, trophyCount, item.required)
                    craftTrophy(item.gem.name, item.gem.trophy, item.gem.id, item.bar.name, item.bar.id)
                    delay(500)
                end
            end
        end
        
        delay(1000)
    end
end

-- Main execution
local function main()
    print('\ag[Trophy]\ax Main function started')
    currentStatus = "Running"
    
    local currentZone = mq.TLO.Zone.ShortName()
    print(string.format('\ay[Trophy]\ax Current zone: %s', currentZone))
    
    -- Check if we need to get the trophy first
    local hasSkill, skillMessage = checkJewelrySkill()
    local hasTrophy, trophyMessage = haveJeweler()
    local hasCard, cardMessage = checkForCard()
    
    -- If we have skill above 50 but no trophy and no scorecard, we need to get the trophy first
    if hasSkill and not hasTrophy and not hasCard and startTrophyQuest then
        currentStatus = "Trophy Quest"
        currentStep = "Need to obtain Jeweler Trophy - Traveling to Freeport West"
        print('\ay[Trophy]\ax Jewelry Making skill sufficient but no trophy or scorecard found')
        print('\ay[Trophy]\ax Starting Trophy Quest - Traveling to Freeport West')
        mq.cmdf('/travelto freeportwest')
        
        -- Wait while navigation is active
        currentStep = "Traveling to Freeport West..."
        print('\ay[Trophy]\ax Waiting for navigation to complete...')
        while isNavigating() do
            mq.doevents()
            delay(100)
        end
        
        -- Wait until we detect we're in Freeport West
        currentStep = "Waiting for zone confirmation..."
        print('\ay[Trophy]\ax Waiting for zone to be confirmed as freeportwest...')
        while mq.TLO.Zone.ShortName() ~= 'freeportwest' do
            mq.doevents()
            delay(100)
        end
        
        print('\ay[Trophy]\ax Arrived in Freeport West')
        currentStep = "Arrived in Freeport West - Pausing 10 seconds"
        
        -- Pause for 10 seconds
        print('\ay[Trophy]\ax Pausing for 10 seconds...')
        delay(10000)
        
        -- Navigate to Event Coordinator Baublie Diggs
        currentStep = "Navigating to Event Coordinator Baublie Diggs"
        print('\ay[Trophy]\ax Navigating to Event Coordinator Baublie Diggs...')
        mq.cmd('/nav spawn "Event Coordinator Baublie Diggs"')
        
        -- Wait while navigation is active
        while isNavigating() do
            mq.doevents()
            delay(100)
        end
        
        print('\ay[Trophy]\ax Navigation stopped, checking for NPC...')
        
        -- Check if NPC is within 20 distance
        local npc = mq.TLO.Spawn('Event Coordinator Baublie Diggs')
        if npc and npc.Distance() and npc.Distance() <= 20 then
            currentStep = "Found Event Coordinator - Targeting"
            print(string.format('\ay[Trophy]\ax Event Coordinator Baublie Diggs detected at distance %.1f', npc.Distance()))
            
            -- Target the NPC
            mq.cmd('/target Event Coordinator Baublie Diggs')
            print('\ay[Trophy]\ax Targeting Event Coordinator Baublie Diggs...')
            
            -- Wait 2 seconds
            delay(2000)
            
            -- Say jewelry
            currentStep = "Speaking to Event Coordinator"
            print('\ay[Trophy]\ax Saying "jewelry" to Event Coordinator...')
            mq.cmd('/say jewelry')
            
            -- Wait a bit for dialogue to process
            delay(3000)
            
            print('\ag[Trophy]\ax Trophy quest dialogue initiated')
        else
            print('\ar[Trophy]\ax Event Coordinator Baublie Diggs not found within 20 distance!')
            currentStep = "Error: NPC not found"
        end
        
        currentZone = 'freeportwest'
        startTrophyQuest = false  -- Reset flag after initiating quest
    end
    
    -- Handle pottery quest
    if startPotteryQuest then
        currentStatus = "Getting Pottery Quest"
        
        -- Travel to Freeport West if not already there
        if currentZone ~= 'freeportwest' then
            currentStep = "Traveling to Freeport West"
            print('\ay[Trophy]\ax Traveling to Freeport West for pottery quest...')
            travelTo('freeportwest')
            
            -- Wait until we detect we're in Freeport West
            currentStep = "Waiting for zone confirmation..."
            print('\ay[Trophy]\ax Waiting for zone to be confirmed as freeportwest...')
            while mq.TLO.Zone.ShortName() ~= 'freeportwest' do
                mq.doevents()
                delay(100)
            end
            
            print('\ay[Trophy]\ax Arrived in Freeport West')
            currentStep = "Arrived in Freeport West - Pausing 10 seconds"
            
            -- Pause for 10 seconds
            print('\ay[Trophy]\ax Pausing for 10 seconds...')
            delay(10000)
            
            -- Navigate to Event Coordinator Baublie Diggs
            currentStep = "Navigating to Event Coordinator Baublie Diggs"
            print('\ay[Trophy]\ax Navigating to Event Coordinator Baublie Diggs...')
            mq.cmd('/nav spawn "Event Coordinator Baublie Diggs"')
            
            -- Wait while navigation is active
            while isNavigating() do
                mq.doevents()
                delay(100)
            end
            
            print('\ay[Trophy]\ax Navigation stopped, checking for NPC...')
            
            -- Check if NPC is within 20 distance
            local npc = mq.TLO.Spawn('Event Coordinator Baublie Diggs')
            if npc and npc.Distance() and npc.Distance() <= 20 then
                currentStep = "Found Event Coordinator - Targeting"
                print(string.format('\ay[Trophy]\ax Event Coordinator Baublie Diggs detected at distance %.1f', npc.Distance()))
                
                -- Target the NPC
                mq.cmd('/target Event Coordinator Baublie Diggs')
                print('\ay[Trophy]\ax Targeting Event Coordinator Baublie Diggs...')
                
                -- Wait 2 seconds
                delay(2000)
                
                -- Say pottery
                currentStep = "Speaking to Event Coordinator"
                print('\ay[Trophy]\ax Saying "pottery" to Event Coordinator...')
                mq.cmd('/say pottery')
                
                -- Wait a bit for dialogue to process
                delay(3000)
                
                print('\ag[Trophy]\ax Pottery quest dialogue initiated')
            else
                print('\ar[Trophy]\ax Event Coordinator Baublie Diggs not found within 20 distance!')
                currentStep = "Error: NPC not found"
            end
            
            currentZone = 'freeportwest'
            startPotteryQuest = false  -- Reset flag after initiating quest
        end
        
        -- Return to PoK
        currentStep = "Returning to PoK"
        print('\ay[Trophy]\ax Traveling to PoK from Freeport')
        travelTo('poknowledge')
        currentZone = 'poknowledge'
        
        -- Stop here - quest complete
        currentStatus = "Quest Complete"
        currentStep = "Pottery quest obtained. Ready to craft."
        print('\ag[Trophy]\ax Pottery quest complete!')
        isRunning = false
        startPotteryQuest = false
        return
    end
    
    -- Handle brewery quest
    if startBreweryQuest then
        currentStatus = "Getting Brewery Quest"
        
        -- Travel to Freeport West if not already there
        if currentZone ~= 'freeportwest' then
            currentStep = "Traveling to Freeport West"
            print('\ay[Trophy]\ax Traveling to Freeport West for brewery quest...')
            travelTo('freeportwest')
            
            -- Wait until we detect we're in Freeport West
            currentStep = "Waiting for zone confirmation..."
            print('\ay[Trophy]\ax Waiting for zone to be confirmed as freeportwest...')
            while mq.TLO.Zone.ShortName() ~= 'freeportwest' do
                mq.doevents()
                delay(100)
            end
            
            print('\ay[Trophy]\ax Arrived in Freeport West')
            currentStep = "Arrived in Freeport West - Pausing 10 seconds"
            
            -- Pause for 10 seconds
            print('\ay[Trophy]\ax Pausing for 10 seconds...')
            delay(10000)
            
            -- Navigate to Event Coordinator Baublie Diggs
            currentStep = "Navigating to Event Coordinator Baublie Diggs"
            print('\ay[Trophy]\ax Navigating to Event Coordinator Baublie Diggs...')
            mq.cmd('/nav spawn "Event Coordinator Baublie Diggs"')
            
            -- Wait while navigation is active
            while isNavigating() do
                mq.doevents()
                delay(100)
            end
            
            print('\ay[Trophy]\ax Navigation stopped, checking for NPC...')
            
            -- Check if NPC is within 20 distance
            local npc = mq.TLO.Spawn('Event Coordinator Baublie Diggs')
            if npc and npc.Distance() and npc.Distance() <= 20 then
                currentStep = "Found Event Coordinator - Targeting"
                print(string.format('\ay[Trophy]\ax Event Coordinator Baublie Diggs detected at distance %.1f', npc.Distance()))
                
                -- Target the NPC
                mq.cmd('/target Event Coordinator Baublie Diggs')
                print('\ay[Trophy]\ax Targeting Event Coordinator Baublie Diggs...')
                
                -- Wait 2 seconds
                delay(2000)
                
                -- Say brewery
                currentStep = "Speaking to Event Coordinator"
                print('\ay[Trophy]\ax Saying "brewery" to Event Coordinator...')
                mq.cmd('/say brewery')
                
                -- Wait a bit for dialogue to process
                delay(3000)
                
                print('\ag[Trophy]\ax Brewery quest dialogue initiated')
            else
                print('\ar[Trophy]\ax Event Coordinator Baublie Diggs not found within 20 distance!')
                currentStep = "Error: NPC not found"
            end
            
            currentZone = 'freeportwest'
            startBreweryQuest = false  -- Reset flag after initiating quest
        end
        
        -- Return to PoK
        currentStep = "Returning to PoK"
        print('\ay[Trophy]\ax Traveling to PoK from Freeport')
        travelTo('poknowledge')
        currentZone = 'poknowledge'
        
        -- Stop here - quest complete
        currentStatus = "Quest Complete"
        currentStep = "Brewery quest obtained. Ready to craft."
        print('\ag[Trophy]\ax Brewery quest complete!')
        isRunning = false
        startBreweryQuest = false
        return
    end
    
    -- Handle trophy collection from event coordinator
    if currentZone == 'freeportwest' then
        currentStep = "Returning to PoK"
        print('\ay[Trophy]\ax Traveling to PoK from Freeport')
        travelTo('poknowledge')
        currentZone = 'poknowledge'
        
        -- Stop here - quest complete, don't continue to automation
        currentStatus = "Quest Complete"
        currentStep = "Trophy quest obtained. Ready to craft."
        print('\ag[Trophy]\ax Trophy quest complete! Stopped before crafting automation.')
        isRunning = false
        return
    end
    
    -- Make sure we're in PoK
    if currentZone ~= 'poknowledge' then
        currentStatus = "Error"
        currentStep = "Must be in PoK to run this script"
        print('\ar[Trophy]\ax Must be in PoK to run this script')
        isRunning = false
        return
    end
    
    -- Check silver bar supply
    if findItemCount('Silver Bar') < config.minSilverBars then
        replenishSilverBars()
    end
    
    -- Build trophies
    buildTrophies()
    
    currentStatus = "Complete"
    currentStep = "Trophy crafting complete!"
    print('\ag[Trophy]\ax Trophy crafting complete!')
    isRunning = false
end

-- Turn-in function for jewelry trophies
local function turnInTrophies()
    print('\ag[Trophy]\ax Starting Turn-In process...')
    currentStatus = "Turn-In"
    
    local currentZone = mq.TLO.Zone.ShortName()
    
    -- Travel to Freeport West if not already there
    if currentZone ~= 'freeportwest' then
        currentStep = "Traveling to Freeport West for turn-in"
        print('\ay[Trophy]\ax Traveling to Freeport West...')
        mq.cmdf('/travelto freeportwest')
        
        -- Wait while navigation is active
        while isNavigating() do
            mq.doevents()
            delay(100)
        end
        
        -- Wait until we detect we're in Freeport West
        print('\ay[Trophy]\ax Waiting for zone to be confirmed as freeportwest...')
        while mq.TLO.Zone.ShortName() ~= 'freeportwest' do
            mq.doevents()
            delay(100)
        end
        
        print('\ay[Trophy]\ax Arrived in Freeport West')
        currentStep = "Arrived in Freeport West - Pausing 10 seconds"
        delay(10000)
    end
    
    -- Navigate to Judge Marion
    currentStep = "Navigating to Judge Marion"
    print('\ay[Trophy]\ax Navigating to Judge Marion...')
    mq.cmd('/nav spawn "Judge Marion"')
    
    -- Wait while navigation is active
    while isNavigating() do
        mq.doevents()
        delay(100)
    end
    
    print('\ay[Trophy]\ax Navigation stopped, checking for Judge Marion...')
    
    -- Check if Judge Marion is within 20 distance
    local npc = mq.TLO.Spawn('Judge Marion')
    if npc and npc.Distance() and npc.Distance() <= 20 then
        currentStep = "Found Judge Marion - Turning in items"
        print(string.format('\ay[Trophy]\ax Judge Marion detected at distance %.1f', npc.Distance()))
        
        -- Target the NPC
        mq.cmd('/target Judge Marion')
        delay(2000)
        
        -- Collect all jewelry trophies to turn in
        local itemsToTurnIn = {}
        for _, item in ipairs(progressData) do
            local count = findItemCount(item.trophy)
            if count > 0 then
                print(string.format('\ay[Trophy]\ax Found %d x %s to turn in', count, item.trophy))
                table.insert(itemsToTurnIn, {name = item.trophy, count = count})
            end
        end
        
        if #itemsToTurnIn == 0 then
            print('\ar[Trophy]\ax No jewelry items found to turn in!')
            currentStep = "No items to turn in"
            startTurnIn = false
            isRunning = false
            return
        end
        
        -- Turn in items, 4 at a time with 2 second delay
        local totalTurnedIn = 0
        for _, itemData in ipairs(itemsToTurnIn) do
            local itemsGiven = 0
            while itemsGiven < itemData.count do
                local batchSize = math.min(4, itemData.count - itemsGiven)
                
                for i = 1, batchSize do
                    print(string.format('\ay[Trophy]\ax Giving %s to Judge Marion (%d/%d)', itemData.name, itemsGiven + i, itemData.count))
                    
                    -- Pick up the item
                    mq.cmdf('/nomodkey /ctrlkey /itemnotify "%s" leftmouseup', itemData.name)
                    delay(500)
                    
                    -- Give it to the target
                    mq.cmd('/click left target')
                    delay(500)
                end
                
                itemsGiven = itemsGiven + batchSize
                totalTurnedIn = totalTurnedIn + batchSize
                currentStep = string.format("Turned in %d items...", totalTurnedIn)
                
                -- Wait 2 seconds before next batch
                if itemsGiven < itemData.count then
                    delay(2000)
                end
            end
        end
        
        print(string.format('\ag[Trophy]\ax Successfully turned in %d items to Judge Marion!', totalTurnedIn))
        currentStep = string.format("Turn-in complete! (%d items)", totalTurnedIn)
    else
        print('\ar[Trophy]\ax Judge Marion not found within 20 distance!')
        currentStep = "Error: Judge Marion not found"
    end
    
    startTurnIn = false
    isRunning = false
end

-- Turn-in function for brewing trophies
local function turnInBrewerTrophies()
    print('\ag[Trophy]\ax Starting Brewer Turn-In process...')
    currentStatus = "Brewer Turn-In"
    
    local currentZone = mq.TLO.Zone.ShortName()
    
    -- Travel to Freeport West if not already there
    if currentZone ~= 'freeportwest' then
        currentStep = "Traveling to Freeport West for turn-in"
        print('\ay[Trophy]\ax Traveling to Freeport West...')
        mq.cmdf('/travelto freeportwest')
        
        -- Wait while navigation is active
        while isNavigating() do
            mq.doevents()
            delay(100)
        end
        
        -- Wait until we detect we're in Freeport West
        print('\ay[Trophy]\ax Waiting for zone to be confirmed as freeportwest...')
        while mq.TLO.Zone.ShortName() ~= 'freeportwest' do
            mq.doevents()
            delay(100)
        end
        
        print('\ay[Trophy]\ax Arrived in Freeport West')
        currentStep = "Arrived in Freeport West - Pausing 10 seconds"
        delay(10000)
    end
    
    -- Navigate to Judge Marion
    currentStep = "Navigating to Judge Marion"
    print('\ay[Trophy]\ax Navigating to Judge Marion...')
    mq.cmd('/nav spawn "Judge Marion"')
    
    -- Wait while navigation is active
    while isNavigating() do
        mq.doevents()
        delay(100)
    end
    
    print('\ay[Trophy]\ax Navigation stopped, checking for Judge Marion...')
    
    -- Check if Judge Marion is within 20 distance
    local npc = mq.TLO.Spawn('Judge Marion')
    if npc and npc.Distance() and npc.Distance() <= 20 then
        currentStep = "Found Judge Marion - Turning in items"
        print(string.format('\ay[Trophy]\ax Judge Marion detected at distance %.1f', npc.Distance()))
        
        -- Target the NPC
        mq.cmd('/target Judge Marion')
        delay(2000)
        
        -- Collect all brewing items to turn in from the selected test
        local selectedTestName = config.brewingTests[selectedBrewingTest]
        local recipes = config.brewingRecipes[selectedTestName]
        local itemsToTurnIn = {}
        
        for _, recipe in ipairs(recipes) do
            local count = findItemCount(recipe.name)
            if count > 0 then
                print(string.format('\ay[Trophy]\ax Found %d x %s to turn in', count, recipe.name))
                table.insert(itemsToTurnIn, {name = recipe.name, count = count})
            end
        end
        
        if #itemsToTurnIn == 0 then
            print('\ar[Trophy]\ax No brewing items found to turn in!')
            currentStep = "No items to turn in"
            startBrewerTurnIn = false
            isRunning = false
            return
        end
        
        -- Turn in items, 4 at a time with 2 second delay
        local totalTurnedIn = 0
        for _, itemData in ipairs(itemsToTurnIn) do
            local itemsGiven = 0
            while itemsGiven < itemData.count do
                local batchSize = math.min(4, itemData.count - itemsGiven)
                
                for i = 1, batchSize do
                    print(string.format('\ay[Trophy]\ax Giving %s to Judge Marion (%d/%d)', itemData.name, itemsGiven + i, itemData.count))
                    
                    -- Pick up the item
                    mq.cmdf('/nomodkey /ctrlkey /itemnotify "%s" leftmouseup', itemData.name)
                    delay(500)
                    
                    -- Give it to the target
                    mq.cmd('/click left target')
                    delay(500)
                end
                
                itemsGiven = itemsGiven + batchSize
                totalTurnedIn = totalTurnedIn + batchSize
                currentStep = string.format("Turned in %d items...", totalTurnedIn)
                
                -- Wait 2 seconds before next batch
                if itemsGiven < itemData.count then
                    delay(2000)
                end
            end
        end
        
        print(string.format('\ag[Trophy]\ax Successfully turned in %d items to Judge Marion!', totalTurnedIn))
        currentStep = string.format("Turn-in complete! (%d items)", totalTurnedIn)
    else
        print('\ar[Trophy]\ax Judge Marion not found within 20 distance!')
        currentStep = "Error: Judge Marion not found"
    end
    
    startBrewerTurnIn = false
    isRunning = false
end

-- Jewelry Tab Content
local function renderJewelryTab()
    -- Dropdown to select jewelry test
    ImGui.Text("Select Jewelry Test:")
    local changed = false
    selectedJewelryTest, changed = ImGui.Combo("##JewelryTest", selectedJewelryTest, config.jewelryTests, #config.jewelryTests)
    
    -- Reinitialize progress data if test selection changed
    if changed then
        initializeProgressData()
        print(string.format('\ay[Trophy]\ax Switched to %s', config.jewelryTests[selectedJewelryTest]))
    end
    
    local selectedTestName = config.jewelryTests[selectedJewelryTest]
    
    ImGui.Separator()
    ImGui.Text(selectedTestName)
    ImGui.Separator()
    
    -- Check for Intricate Jewelers Glass (final trophy) - Check this FIRST
    local glassCount = findItemCount('Intricate Jewelers Glass')
    if glassCount > 0 then
        ImGui.PushStyleColor(ImGuiCol.Text, 0, 1, 0, 1)
        ImGui.SetWindowFontScale(1.5)
        ImGui.Text("Jewelry Trophy Complete")
        ImGui.SetWindowFontScale(1.0)
        ImGui.PopStyleColor()
        return
    end
    
    -- Trophy Quest Detection - Show only if no trophy exists
    local hasSkill, skillMessage = checkJewelrySkill()
    local hasTrophy, trophyMessage = haveJeweler()
    local hasCard, cardMessage = checkForCard()
    
    if hasSkill and not hasTrophy and not hasCard then
        ImGui.PushStyleColor(ImGuiCol.Text, 1, 0.5, 0, 1)
        ImGui.Text("Trophy Quest Available:")
        ImGui.PopStyleColor()
        ImGui.Indent(20)
        ImGui.TextColored(0.9, 0.7, 0, 1, "You have sufficient Jewelry Making skill but no trophy.")
        ImGui.TextColored(0.9, 0.7, 0, 1, "Click the button below to get the trophy quest in Freeport West.")
        
        -- Get Quest Button
        if ImGui.Button("Get Quest", 120, 30) then
            startTrophyQuest = true
            isRunning = true  -- Start the main loop to execute the quest
            print('\ag[Trophy]\ax Starting Trophy Quest...')
        end
        
        ImGui.Unindent(20)
        ImGui.Separator()
    end
    
    -- Status Section
    ImGui.PushStyleColor(ImGuiCol.Text, 1, 1, 0, 1)
    ImGui.Text(string.format("Status: %s", currentStatus))
    ImGui.PopStyleColor()
    
    if currentStep and currentStep ~= "" then
        ImGui.TextColored(0.7, 0.7, 0.7, 1, currentStep)
    end
    
    ImGui.Separator()
    
    -- Check for Freshman Jeweler Scorecard
    local hasCard, cardMessage = checkForCard()
    if hasCard then
        ImGui.PushStyleColor(ImGuiCol.Text, 0, 1, 0, 1)
        ImGui.Text(cardMessage)
        ImGui.PopStyleColor()
    else
        ImGui.PushStyleColor(ImGuiCol.Text, 1, 0.5, 0, 1)
        ImGui.Text(cardMessage)
        ImGui.PopStyleColor()
    end
    
    -- Check for existing Jeweler Trophy
    local hasTrophy, trophyMessage = haveJeweler()
    if hasTrophy then
        ImGui.PushStyleColor(ImGuiCol.Text, 0, 1, 0, 1)
        ImGui.Text(trophyMessage)
        ImGui.PopStyleColor()
        
        -- Check jewelry skill and show appropriate tip (only when trophy exists)
        local skillLevel = mq.TLO.Me.Skill('Jewelry Making')() or 0
        if skillLevel <= 300 then
            ImGui.Separator()
            ImGui.PushStyleColor(ImGuiCol.Text, 1, 1, 0, 1)
            ImGui.Text(string.format("Jewelry Making Skill: %d", skillLevel))
            ImGui.PopStyleColor()
            
            if skillLevel >= 50 and skillLevel < 102 then
                ImGui.TextColored(0.9, 0.7, 0, 1, "Skill-Up Tip: Raise to 102 with Electrum Bar + Jade")
            elseif skillLevel >= 102 and skillLevel < 202 then
                ImGui.TextColored(0.9, 0.7, 0, 1, "Skill-Up Tip: Raise to 202 with Goldbar + Fire Emerald")
            elseif skillLevel >= 202 and skillLevel <= 300 then
                ImGui.TextColored(0.9, 0.7, 0, 1, "Skill-Up Tip: Continue skilling with your current recipes")
            end
        end
    else
        ImGui.PushStyleColor(ImGuiCol.Text, 0.7, 0.7, 0.7, 1)
        ImGui.Text(trophyMessage)
        ImGui.PopStyleColor()
    end
    
    -- Check Jewelry Making skill
    local hasSkill, skillMessage = checkJewelrySkill()
    if hasSkill then
        ImGui.PushStyleColor(ImGuiCol.Text, 0, 1, 0, 1)
        ImGui.Text(skillMessage)
        ImGui.PopStyleColor()
    else
        ImGui.PushStyleColor(ImGuiCol.Text, 1, 0, 0, 1)
        ImGui.Text(skillMessage)
        ImGui.PopStyleColor()
    end
    
    ImGui.Separator()
    
    -- Silver Bar Count
    local silverCount = findItemCount('Silver Bar')
    local silverColor = silverCount >= config.minSilverBars and {0, 1, 0, 1} or {1, 0, 0, 1}
    ImGui.TextColored(silverColor[1], silverColor[2], silverColor[3], silverColor[4], 
                     string.format("Silver Bars: %d", silverCount))
    
    ImGui.Separator()
    
    -- Only show recipe list if trophy is NOT found
    local hasTrophy, _ = haveJeweler()
    if not hasTrophy then
        -- Get recipes for selected test
        local selectedTestName = config.jewelryTests[selectedJewelryTest]
        local recipes = config.jewelryRecipes[selectedTestName]
        
        -- Recipe List
        ImGui.Text("Jewelry Recipes:")
        ImGui.Spacing()
        
        if ImGui.BeginChild("JewelryRecipeList", 480, 400, true) then
            for _, recipe in ipairs(recipes) do
                -- Check if finished product exists
                local finishedCount = findItemCount(recipe.trophy)
                local hasFinished = finishedCount > 0
                local requiredCount = recipe.required
                local isRecipeComplete = finishedCount >= requiredCount
                
                -- Recipe name with count
                if isRecipeComplete then
                    ImGui.PushStyleColor(ImGuiCol.Text, 0, 1, 0, 1)
                    local recipeName = string.format("%s [%d/%d]", recipe.trophy, finishedCount, requiredCount)
                    ImGui.Text(recipeName)
                    ImGui.PopStyleColor()
                else
                    ImGui.PushStyleColor(ImGuiCol.Text, 0.3, 0.8, 1.0, 1)
                    local recipeName = recipe.trophy
                    if hasFinished then
                        recipeName = string.format("%s [%d/%d]", recipe.trophy, finishedCount, requiredCount)
                    else
                        recipeName = recipeName .. string.format(" (Need: %d)", recipe.required)
                    end
                    ImGui.Text(recipeName)
                    ImGui.PopStyleColor()
                    
                    ImGui.Indent(20)
                    ImGui.TextColored(0.7, 0.7, 0.7, 1, "Components:")
                    ImGui.Indent(10)
                    
                    -- Bar component (Silver Bar or special bar like Electrum)
                    local barName = recipe.specialBar or "Silver Bar"
                    local barID = recipe.specialBarID or config.silverBarID
                    local barCount = findItemCount(barName)
                    local barNeeded = recipe.required
                    local hasBar = barCount > 0
                    local barIDText = barID and string.format("(ID: %d)", barID) or "(ID: Unknown)"
                    
                    if hasBar then
                        if barCount >= barNeeded then
                            ImGui.TextColored(0, 1, 0, 1, string.format("%s [Have: %d] x%d %s [Audri Deepfacet]", 
                                barName, barCount, barNeeded, barIDText))
                        else
                            ImGui.TextColored(1, 1, 0, 1, string.format("%s [Have: %d, Need: %d] %s [Audri Deepfacet]", 
                                barName, barCount, barNeeded, barIDText))
                        end
                    else
                        ImGui.TextColored(0.9, 0.9, 0.9, 1, string.format("%s x%d %s [Audri Deepfacet]", 
                            barName, barNeeded, barIDText))
                    end
                    
                    -- Gem component
                    local gemCount = findItemCount(recipe.name)
                    local gemNeeded = recipe.required
                    local hasGem = gemCount > 0
                    local gemVendor = recipe.vendor or "Audri Deepfacet"
                    local gemIDText = recipe.id and string.format("(ID: %d)", recipe.id) or "(ID: Unknown)"
                    
                    if hasGem then
                        if gemCount >= gemNeeded then
                            ImGui.TextColored(0, 1, 0, 1, string.format("%s [Have: %d] x%d %s [%s]", 
                                recipe.name, gemCount, gemNeeded, gemIDText, gemVendor))
                        else
                            ImGui.TextColored(1, 1, 0, 1, string.format("%s [Have: %d, Need: %d] %s [%s]", 
                                recipe.name, gemCount, gemNeeded, gemIDText, gemVendor))
                        end
                    else
                        ImGui.TextColored(0.9, 0.9, 0.9, 1, string.format("%s x%d %s [%s]", 
                            recipe.name, gemNeeded, gemIDText, gemVendor))
                    end
                    
                    ImGui.Unindent(10)
                    ImGui.Unindent(20)
                end
                
                ImGui.Spacing()
                ImGui.Separator()
            end
        end
        ImGui.EndChild()
        
        ImGui.Separator()
    end
    
    -- Control Buttons
    if not isRunning then
        local selectedTestName = config.jewelryTests[selectedJewelryTest]
        local buttonLabel = "Start " .. selectedTestName
        if ImGui.Button(buttonLabel, 220, 40) then
            -- Flag to start the process in main loop
            print(string.format('\ag[Trophy]\ax Starting %s...', selectedTestName))
            isRunning = true
        end
        ImGui.SameLine()
        if ImGui.Button("Turn-In", 100, 40) then
            print('\ag[Trophy]\ax Turn-In button pressed...')
            startTurnIn = true
            isRunning = true
        end
        ImGui.SameLine()
        if ImGui.Button("End", 100, 40) then
            print('\ag[Trophy]\ax End button pressed, terminating script...')
            guiOpen = false
            mq.exit()
        end
    else
        ImGui.PushStyleColor(ImGuiCol.Button, 1, 0, 0, 1)
        if ImGui.Button("Stop", 220, 40) then
            isRunning = false
            currentStatus = "Stopped by user"
            currentStep = ""
        end
        ImGui.PopStyleColor()
        
        ImGui.SameLine()
        ImGui.TextColored(1, 1, 0, 1, "Running...")
    end
end

-- Buy pottery components from vendors
local function buyPotteryComponents(testName)
    local recipes = config.potteryRecipes[testName]
    if not recipes or #recipes == 0 then
        print('\ar[Trophy]\ax No recipes found for ' .. testName)
        return
    end
    
    -- Aggregate all components by vendor
    local vendorItems = {
        ["Sculptor_Radee"] = {},
        ["Brewmaster_Berina00"] = {}
    }
    
    -- Scan all recipes and aggregate component quantities needed
    for _, recipe in ipairs(recipes) do
        local finishedCount = findItemCount(recipe.name)
        local stillNeeded = (recipe.required or 1) - finishedCount
        
        if stillNeeded > 0 then
            for _, component in ipairs(recipe.components) do
                -- Only process components from known vendors (skip nil/unknown vendors)
                if component.vendor == "Sculptor_Radee" or component.vendor == "Brewmaster_Berina00" then
                    local neededQty = (component.quantity or 1) * stillNeeded
                    local currentCount = findItemCount(component.name)
                    local toBuy = math.max(0, neededQty - currentCount)
                    
                    if toBuy > 0 then
                        -- Check if this item already exists in vendor list
                        local existingItem = nil
                        for _, item in ipairs(vendorItems[component.vendor]) do
                            if item.id == component.id then
                                existingItem = item
                                break
                            end
                        end
                        
                        if existingItem then
                            existingItem.qty = existingItem.qty + toBuy
                        else
                            table.insert(vendorItems[component.vendor], {
                                name = component.name,
                                id = component.id,
                                qty = toBuy
                            })
                        end
                    end
                end
            end
        end
    end
    
    -- Buy from Sculptor_Radee
    if #vendorItems["Sculptor_Radee"] > 0 then
        print('\ag[Trophy]\ax Navigating to Sculptor Radee...')
        mq.cmd('/nav spawn Sculptor_Radee')
        
        -- Wait for nav to complete
        while mq.TLO.Navigation.Active() do
            mq.delay(100)
        end
        mq.delay(500)
        
        -- Target and open merchant
        mq.cmd('/target Sculptor_Radee')
        mq.delay(300)
        mq.cmd('/click right target')
        mq.delay(1000)
        
        -- Wait for merchant window
        while not mq.TLO.Window('MerchantWnd').Open() do
            mq.delay(100)
        end
        mq.delay(500)
        
        -- Buy all items from this vendor in one session
        for _, item in ipairs(vendorItems["Sculptor_Radee"]) do
            print(string.format('\ag[Trophy]\ax Buying %d x %s', item.qty, item.name))
            local currentCount = findItemCount(item.name)
            buyItem(item.name, currentCount + item.qty, false, item.id)
        end
        
        -- Close merchant
        mq.cmd('/nomodkey /notify MerchantWnd MW_Done_Button leftmouseup')
        mq.delay(300)
        
        print('\ag[Trophy]\ax Finished purchasing from Sculptor Radee')
    end
    
    -- Buy from Brewmaster_Berina00
    if #vendorItems["Brewmaster_Berina00"] > 0 then
        print('\ag[Trophy]\ax Navigating to Brewmaster Berina...')
        mq.cmd('/nav spawn Brewmaster_Berina00')
        
        -- Wait for nav to complete
        while mq.TLO.Navigation.Active() do
            mq.delay(100)
        end
        mq.delay(500)
        
        -- Target and open merchant
        mq.cmd('/target Brewmaster_Berina00')
        mq.delay(300)
        mq.cmd('/click right target')
        mq.delay(1000)
        
        -- Wait for merchant window
        while not mq.TLO.Window('MerchantWnd').Open() do
            mq.delay(100)
        end
        mq.delay(500)
        
        -- Buy all items from this vendor in one session
        for _, item in ipairs(vendorItems["Brewmaster_Berina00"]) do
            print(string.format('\ag[Trophy]\ax Buying %d x %s', item.qty, item.name))
            local currentCount = findItemCount(item.name)
            buyItem(item.name, currentCount + item.qty, false, item.id)
        end
        
        -- Close merchant
        mq.cmd('/nomodkey /notify MerchantWnd MW_Done_Button leftmouseup')
        mq.delay(300)
        
        print('\ag[Trophy]\ax Finished purchasing from Brewmaster Berina')
    end
    
    print('\ag[Trophy]\ax Pottery component purchase complete!')
end

-- Buy brewing components from vendors
local function buyBrewingComponents(testName)
    local recipes = config.brewingRecipes[testName]
    if not recipes or #recipes == 0 then
        print('\ar[Trophy]\ax No recipes found for ' .. testName)
        return
    end
    
    -- Aggregate all components by vendor
    local vendorItems = {
        ["Brewmaster_Berina00"] = {},
        ["Chef_Denrun00"] = {}
    }
    
    -- Scan all recipes and aggregate component quantities needed
    for _, recipe in ipairs(recipes) do
        local finishedCount = findItemCount(recipe.name)
        local stillNeeded = (recipe.required or 1) - finishedCount
        
        if stillNeeded > 0 then
            for _, component in ipairs(recipe.components) do
                -- Only process components from known vendors (skip foraged/dropped/nil)
                if component.vendor == "Brewmaster_Berina00" or component.vendor == "Chef_Denrun00" then
                    local neededQty = (component.quantity or 1) * stillNeeded
                    local currentCount = findItemCount(component.name)
                    local toBuy = math.max(0, neededQty - currentCount)
                    
                    if toBuy > 0 then
                        -- Check if this item already exists in vendor list
                        local existingItem = nil
                        for _, item in ipairs(vendorItems[component.vendor]) do
                            if item.id == component.id then
                                existingItem = item
                                break
                            end
                        end
                        
                        if existingItem then
                            existingItem.qty = existingItem.qty + toBuy
                        else
                            table.insert(vendorItems[component.vendor], {
                                name = component.name,
                                id = component.id,
                                qty = toBuy
                            })
                        end
                    end
                end
            end
        end
    end
    
    -- Buy from Brewmaster_Berina00
    if #vendorItems["Brewmaster_Berina00"] > 0 then
        print('\ag[Trophy]\ax Navigating to Brewmaster Berina...')
        mq.cmd('/nav spawn Brewmaster_Berina00')
        
        -- Wait for nav to complete
        while mq.TLO.Navigation.Active() do
            mq.delay(100)
        end
        mq.delay(500)
        
        -- Target and open merchant
        mq.cmd('/target Brewmaster_Berina00')
        mq.delay(300)
        mq.cmd('/click right target')
        mq.delay(1000)
        
        -- Wait for merchant window
        while not mq.TLO.Window('MerchantWnd').Open() do
            mq.delay(100)
        end
        mq.delay(500)
        
        -- Buy all items from this vendor in one session
        for _, item in ipairs(vendorItems["Brewmaster_Berina00"]) do
            print(string.format('\ag[Trophy]\ax Buying %d x %s', item.qty, item.name))
            local currentCount = findItemCount(item.name)
            buyItem(item.name, currentCount + item.qty, false, item.id)
        end
        
        -- Close merchant
        mq.cmd('/nomodkey /notify MerchantWnd MW_Done_Button leftmouseup')
        mq.delay(300)
        
        print('\ag[Trophy]\ax Finished purchasing from Brewmaster Berina')
    end
    
    -- Buy from Chef_Denrun00
    if #vendorItems["Chef_Denrun00"] > 0 then
        print('\ag[Trophy]\ax Navigating to Chef Denrun...')
        mq.cmd('/nav spawn Chef_Denrun00')
        
        -- Wait for nav to complete
        while mq.TLO.Navigation.Active() do
            mq.delay(100)
        end
        mq.delay(500)
        
        -- Target and open merchant
        mq.cmd('/target Chef_Denrun00')
        mq.delay(300)
        mq.cmd('/click right target')
        mq.delay(1000)
        
        -- Wait for merchant window
        while not mq.TLO.Window('MerchantWnd').Open() do
            mq.delay(100)
        end
        mq.delay(500)
        
        -- Buy all items from this vendor in one session
        for _, item in ipairs(vendorItems["Chef_Denrun00"]) do
            print(string.format('\ag[Trophy]\ax Buying %d x %s', item.qty, item.name))
            local currentCount = findItemCount(item.name)
            buyItem(item.name, currentCount + item.qty, false, item.id)
        end
        
        -- Close merchant
        mq.cmd('/nomodkey /notify MerchantWnd MW_Done_Button leftmouseup')
        mq.delay(300)
        
        print('\ag[Trophy]\ax Finished purchasing from Chef Denrun')
    end
    
    print('\ag[Trophy]\ax Component purchase complete!')
end

-- Brewing Tab Content
local function renderBrewingTab()
    -- Dropdown to select brewing test
    ImGui.Text("Select Brewing Test:")
    local changed = false
    selectedBrewingTest, changed = ImGui.Combo("##BrewingTest", selectedBrewingTest, config.brewingTests, #config.brewingTests)
    
    local selectedTestName = config.brewingTests[selectedBrewingTest]
    
    ImGui.Separator()
    ImGui.Text(selectedTestName)
    ImGui.Separator()
    
    -- Check for Beginner Brewer Trophy or Freshman Brewer Trophy
    local beginnerTrophyCount = findItemCount('Beginner Brewer Trophy')
    local freshmanTrophyCount = findItemCount('Freshman Brewer Trophy')
    local journeymanTrophyCount = findItemCount('Journeyman Brewer Trophy')
    local expertTrophyCount = findItemCount('Expert Brewer Trophy')
    if beginnerTrophyCount > 0 or freshmanTrophyCount > 0 or journeymanTrophyCount > 0 or expertTrophyCount > 0 then
        ImGui.PushStyleColor(ImGuiCol.Text, 0, 1, 0, 1)
        ImGui.SetWindowFontScale(1.5)
        ImGui.Text("Brewing Trophy Complete")
        ImGui.SetWindowFontScale(1.0)
        ImGui.PopStyleColor()
        return
    end
    
    -- Check Brewing skill
    local hasSkill, skillMessage = checkBrewingSkill()
    if hasSkill then
        ImGui.PushStyleColor(ImGuiCol.Text, 0, 1, 0, 1)
        ImGui.Text(skillMessage)
        ImGui.PopStyleColor()
    else
        ImGui.PushStyleColor(ImGuiCol.Text, 1, 0, 0, 1)
        ImGui.Text(skillMessage)
        ImGui.PopStyleColor()
    end
    
    ImGui.Separator()
    
    -- Quest button
    ImGui.PushStyleColor(ImGuiCol.Text, 1, 0.5, 0, 1)
    ImGui.Text("Brewery Quest:")
    ImGui.PopStyleColor()
    ImGui.Indent(20)
    ImGui.TextColored(0.9, 0.7, 0, 1, "Click the button below to get the brewery quest in Freeport West.")
    ImGui.Indent(-20)
    
    if not isRunning then
        if ImGui.Button("Get Brewery Quest", 220, 40) then
            print('\ag[Trophy]\ax Getting brewery quest...')
            startBreweryQuest = true
            isRunning = true
        end
    else
        ImGui.PushStyleColor(ImGuiCol.Button, 1, 0, 0, 1)
        ImGui.Button("Working...", 220, 40)
        ImGui.PopStyleColor()
    end
    
    ImGui.Separator()
    
    local recipes = config.brewingRecipes[selectedTestName]
    
    if not recipes or #recipes == 0 then
        ImGui.TextColored(0.9, 0.7, 0, 1, "Recipes for this test have not been added yet.")
        ImGui.TextColored(0.7, 0.7, 0.7, 1, "Check back later for updates!")
        return
    end
    
    -- Recipe List
    ImGui.Text("Brewing Recipes:")
    ImGui.Spacing()
    
    if ImGui.BeginChild("BrewingRecipeList", 480, 400, true) then
        for _, recipe in ipairs(recipes) do
            -- Check if finished product exists
            local finishedCount = findItemCount(recipe.name)
            local hasFinished = finishedCount > 0
            local requiredCount = recipe.required or 1
            local isRecipeComplete = finishedCount >= requiredCount
            
            -- Recipe name with count
            if isRecipeComplete then
                ImGui.PushStyleColor(ImGuiCol.Text, 0, 1, 0, 1)
                local recipeName = string.format("%s [%d/%d]", recipe.name, finishedCount, requiredCount)
                ImGui.Text(recipeName)
                ImGui.PopStyleColor()
            else
                ImGui.PushStyleColor(ImGuiCol.Text, 0.3, 0.8, 1.0, 1)
                local recipeName = recipe.name
                if hasFinished then
                    recipeName = string.format("%s [%d/%d]", recipe.name, finishedCount, requiredCount)
                elseif recipe.required and recipe.required > 1 then
                    recipeName = recipeName .. string.format(" (Need: %d)", recipe.required)
                end
                ImGui.Text(recipeName)
                ImGui.PopStyleColor()
                
                ImGui.Indent(20)
                ImGui.TextColored(0.7, 0.7, 0.7, 1, "Components:")
                ImGui.Indent(10)
                for _, component in ipairs(recipe.components) do

                    local componentCount = findItemCount(component.name)
                    local hasComponent = componentCount > 0
                    local neededQty = component.quantity or 1
                    
                    local idText = component.id and string.format(" (ID: %d)", component.id) or " (ID: Unknown)"
                    local quantityText = component.quantity and string.format(" x%d", component.quantity) or ""
                    local vendorText = ""
                    if component.vendor then
                        if component.vendor == "Foraged" then
                            vendorText = " [Foraged]"
                        elseif component.vendor == "Dropped" then
                            vendorText = " [Dropped]"
                        else
                            vendorText = string.format(" [%s]", component.vendor)
                        end
                    else
                        vendorText = " [Vendor: Unknown]"
                    end
                    
                    if hasComponent then
                        if componentCount >= neededQty then
                            ImGui.TextColored(0, 1, 0, 1, string.format("%s [Have: %d]%s%s%s", 
                                component.name, componentCount, quantityText, idText, vendorText))
                        else
                            ImGui.TextColored(1, 1, 0, 1, string.format("%s [Have: %d, Need: %d]%s%s", 
                                component.name, componentCount, neededQty, idText, vendorText))
                        end
                    else
                        ImGui.TextColored(0.9, 0.9, 0.9, 1, component.name .. quantityText .. idText .. vendorText)
                    end
                end
                ImGui.Unindent(10)
                ImGui.Unindent(20)
            end
            
            ImGui.Spacing()
            ImGui.Separator()
            ImGui.Spacing()
        end
    end
    ImGui.EndChild()
    
    ImGui.Separator()
    
    -- Buy Components Button
    if not buyingBrewingComponents then
        if ImGui.Button("Buy Components", 220, 40) then
            print('\ag[Trophy]\ax Starting component purchase for ' .. selectedTestName)
            buyingBrewingComponents = true
            brewingTestToBuy = selectedTestName
        end
        ImGui.SameLine()
        if ImGui.Button("Turn-In", 100, 40) then
            print('\ag[Trophy]\ax Brewer Turn-In button pressed...')
            startBrewerTurnIn = true
            isRunning = true
        end
    else
        ImGui.PushStyleColor(ImGuiCol.Button, 0, 0.5, 0, 1)
        ImGui.Button("Buying Components...", 220, 40)
        ImGui.PopStyleColor()
    end
    
    ImGui.TextColored(0.9, 0.7, 0, 1, "Brewing automation coming soon!")
end

-- Pottery Tab Content
local function renderPotteryTab()
    -- Dropdown to select pottery test
    ImGui.Text("Select Pottery Test:")
    local changed = false
    selectedPotteryTest, changed = ImGui.Combo("##PotteryTest", selectedPotteryTest, config.potteryTests, #config.potteryTests)
    
    local selectedTestName = config.potteryTests[selectedPotteryTest]
    
    ImGui.Separator()
    ImGui.Text(selectedTestName)
    ImGui.Separator()
    
    -- Check for Beginner Potter Trophy or Freshman Potter Trophy
    local beginnerTrophyCount = findItemCount('Beginner Potter Trophy')
    local freshmanTrophyCount = findItemCount('Freshman Potter Trophy')
    local journeymanTrophyCount = findItemCount('Journeyman Potter Trophy')
    local expertTrophyCount = findItemCount('Expert Potter Trophy')
    if beginnerTrophyCount > 0 or freshmanTrophyCount > 0 or journeymanTrophyCount > 0 or expertTrophyCount > 0 then
        ImGui.PushStyleColor(ImGuiCol.Text, 0, 1, 0, 1)
        ImGui.SetWindowFontScale(1.5)
        ImGui.Text("Pottery Trophy Complete")
        ImGui.SetWindowFontScale(1.0)
        ImGui.PopStyleColor()
        return
    end
    
    -- Check Pottery skill
    local hasSkill, skillMessage = checkPotterySkill()
    if hasSkill then
        ImGui.PushStyleColor(ImGuiCol.Text, 0, 1, 0, 1)
        ImGui.Text(skillMessage)
        ImGui.PopStyleColor()
    else
        ImGui.PushStyleColor(ImGuiCol.Text, 1, 0, 0, 1)
        ImGui.Text(skillMessage)
        ImGui.PopStyleColor()
    end
    
    ImGui.Separator()
    
    -- Quest button
    ImGui.PushStyleColor(ImGuiCol.Text, 1, 0.5, 0, 1)
    ImGui.Text("Pottery Quest:")
    ImGui.PopStyleColor()
    ImGui.Indent(20)
    ImGui.TextColored(0.9, 0.7, 0, 1, "Click the button below to get the pottery quest in Freeport West.")
    ImGui.Indent(-20)
    
    if not isRunning then
        if ImGui.Button("Get Pottery Quest", 220, 40) then
            print('\\ag[Trophy]\\ax Getting pottery quest...')
            startPotteryQuest = true
            isRunning = true
        end
    else
        ImGui.PushStyleColor(ImGuiCol.Button, 1, 0, 0, 1)
        ImGui.Button("Working...", 220, 40)
        ImGui.PopStyleColor()
    end
    
    ImGui.Separator()
    
    local recipes = config.potteryRecipes[selectedTestName]
    
    if not recipes or #recipes == 0 then
        ImGui.TextColored(0.9, 0.7, 0, 1, "Recipes for this test have not been added yet.")
        ImGui.TextColored(0.7, 0.7, 0.7, 1, "Check back later for updates!")
        return
    end
    
    -- Recipe list section
    ImGui.PushStyleColor(ImGuiCol.Text, 1, 0.5, 0, 1)
    ImGui.Text("Pottery Recipes:")
    ImGui.PopStyleColor()
    
    ImGui.BeginChild("PotteryRecipeList", 0, 380, true)
    if recipes then
        for _, recipe in ipairs(recipes) do
            local recipeCount = findItemCount(recipe.name)
            local isRecipeComplete = recipeCount >= recipe.required
            
            -- Recipe name with count vs required
            if isRecipeComplete then
                ImGui.PushStyleColor(ImGuiCol.Text, 0, 1, 0, 1)
                ImGui.Text(string.format("[%d/%d] %s", recipeCount, recipe.required, recipe.name))
                ImGui.PopStyleColor()
            elseif recipeCount > 0 then
                ImGui.PushStyleColor(ImGuiCol.Text, 1, 1, 0, 1)
                ImGui.Text(string.format("[%d/%d] %s", recipeCount, recipe.required, recipe.name))
                ImGui.PopStyleColor()
            else
                ImGui.PushStyleColor(ImGuiCol.Text, 1, 0, 0, 1)
                ImGui.Text(string.format("[%d/%d] %s", recipeCount, recipe.required, recipe.name))
                ImGui.PopStyleColor()
            end
            
            -- Component list (only show if recipe is NOT complete)
            if not isRecipeComplete and recipe.components and #recipe.components > 0 then
                ImGui.Indent(20)
                ImGui.PushStyleColor(ImGuiCol.Text, 0.7, 0.7, 1, 1)
                ImGui.Text("Components:")
                ImGui.PopStyleColor()
                ImGui.Indent(10)
                for _, component in ipairs(recipe.components) do
                    local quantityText = ""
                    if component.quantity and component.quantity > 1 then
                        quantityText = string.format(" x%d", component.quantity)
                    end
                    
                    local idText = ""
                    if component.id then
                        idText = string.format(" (ID: %d)", component.id)
                    end
                    
                    local vendorText = ""
                    if component.vendor then
                        vendorText = string.format(" [%s]", component.vendor)
                    end
                    
                    -- Check inventory for component
                    local componentCount = findItemCount(component.name)
                    if componentCount > 0 then
                        local neededQty = (component.quantity or 1) * recipe.required
                        if componentCount >= neededQty then
                            ImGui.TextColored(0, 1, 0, 1, string.format("%s [Have: %d]%s%s%s", 
                                component.name, componentCount, quantityText, idText, vendorText))
                        else
                            ImGui.TextColored(1, 1, 0, 1, string.format("%s [Have: %d, Need: %d]%s%s", 
                                component.name, componentCount, neededQty, idText, vendorText))
                        end
                    else
                        ImGui.TextColored(0.9, 0.9, 0.9, 1, component.name .. quantityText .. idText .. vendorText)
                    end
                end
                ImGui.Unindent(10)
                ImGui.Unindent(20)
            end
            
            ImGui.Spacing()
            ImGui.Separator()
            ImGui.Spacing()
        end
    end
    ImGui.EndChild()
    
    ImGui.Separator()
    
    -- Buy Components Button
    if not buyingPotteryComponents then
        if ImGui.Button("Buy Components", 220, 40) then
            print('\ag[Trophy]\ax Starting component purchase for ' .. selectedTestName)
            buyingPotteryComponents = true
            potteryTestToBuy = selectedTestName
        end
    else
        ImGui.PushStyleColor(ImGuiCol.Button, 0, 0.5, 0, 1)
        ImGui.Button("Buying Components...", 220, 40)
        ImGui.PopStyleColor()
    end
    
    ImGui.Separator()
    
    ImGui.TextColored(0.9, 0.7, 0, 1, "Pottery automation coming soon!")
end

local function renderGUI()
    if not guiOpen then return end
    
    ImGui.SetNextWindowSize(500, 600, ImGuiCond.FirstUseEver)
    local openWindow, shouldShow = ImGui.Begin('Trophy Crafting Assistant', true, ImGuiWindowFlags.None)
    
    if not openWindow then

        guiOpen = false
    end
    
    if openWindow then

        local charName = mq.TLO.Me.CleanName() or "Unknown"
        local zone = mq.TLO.Zone.ShortName() or "Unknown"
        
        ImGui.Text(string.format("Character: %s", charName))
        ImGui.Text(string.format("Zone: %s", zone))
        ImGui.Separator()
        

        if ImGui.BeginTabBar("TrophyTabs", ImGuiTabBarFlags.None) then

            if ImGui.BeginTabItem("Jewelry") then
                renderJewelryTab()
                ImGui.EndTabItem()
            end
            
            if ImGui.BeginTabItem("Brewing") then
                renderBrewingTab()
                ImGui.EndTabItem()
            end
            
            if ImGui.BeginTabItem("Pottery") then
                renderPotteryTab()
                ImGui.EndTabItem()
            end
            
            ImGui.EndTabBar()
        end
    end
    
    ImGui.End()
end

mq.imgui.init('TrophyJeweler', renderGUI)

print('\ag[Trophy]\ax GUI initialized. Use the window to start crafting.')

local hasRunMain = false

while guiOpen do

    mq.doevents()
    
    if isRunning and not hasRunMain then
        hasRunMain = true
        if startTurnIn then
            turnInTrophies()
        elseif startBrewerTurnIn then
            turnInBrewerTrophies()
        elseif startPotteryQuest then
            main()  -- Pottery quest uses main() to handle quest logic
        elseif startBreweryQuest then
            main()  -- Brewery quest uses main() to handle quest logic
        else
            main()
        end
        hasRunMain = false
    end
    
    -- Handle brewing component purchases
    if buyingBrewingComponents then
        buyBrewingComponents(brewingTestToBuy)
        buyingBrewingComponents = false
        brewingTestToBuy = ""
    end
    
    -- Handle pottery component purchases
    if buyingPotteryComponents then
        buyPotteryComponents(potteryTestToBuy)
        buyingPotteryComponents = false
        potteryTestToBuy = ""
    end
    
    delay(50)
end

print('\ag[Trophy]\ax Script terminated.')
mq.exit()
